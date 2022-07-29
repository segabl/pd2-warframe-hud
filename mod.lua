if not WFHud then

	blt.xaudio.setup()

	local ext_mapping = {
		dds = Idstring("texture"),
		font = Idstring("font")
	}
	local function collect_files(base_dir, dir, tbl)
		dir = dir or ""
		tbl = tbl or {}
		for _, dname in pairs(file.GetDirectories(base_dir .. dir)) do
			collect_files(base_dir, dir .. dname .. "/", tbl)
		end
		for _, fname in pairs(file.GetFiles(base_dir .. dir)) do
			local name, ext = fname:match("(.+)%.([^.]+)")
			if ext_mapping[ext] then
				table.insert(tbl, {
					ext = ext_mapping[ext],
					path = dir .. name,
					file = base_dir .. dir .. fname
				})
			end
		end
		return tbl
	end

	HopLib:load_assets(collect_files(ModPath .. "assets/", "fonts/wfhud/"))
	HopLib:load_assets(collect_files(ModPath .. "assets/", "guis/textures/wfhud/"))

	WFHud = {}
	WFHud.mod_path = ModPath
	WFHud.save_path = SavePath .. "wfhud.json"
	WFHud.skill_map = {
		temporary = {}
	}
	WFHud.settings = {
		hud_scale = 1,
		font_scale = 1,
		margin_h = 48,
		margin_v = 32,
		vanilla_ammo = false,
		vanilla_fonts = false,
		buff_list = true,
		rare_mission_equipment = true,
		health_labels = true,
		damage_popups = true,
		waypoints = true,
		world_interactions = true,
		boss_bar = true,
		player_panels = {
			show_deployables = true,
			show_downs = true,
			use_peer_colors = false
		},
		chat = {
			enabled = true,
			timestamps = 1,
			keep_open = true,
			inline = true,
			use_peer_colors = false,
			x = -1,
			y = -1,
			w = 400,
			h = 200
		},
		colors = {
			default = Color("ffffff"),
			muted = Color("808080"),
			bg = Color("404040"),
			buff = Color("01d8ff"),
			debuff = Color("cc2a28"),
			health = Color("cc2a28"),
			shield = Color("01d8ff"),
			armor = Color("e0a635"),
			object = Color("6dada7"),
			objective = Color("e9ba08"),
			attack = Color("c80406"),
			extract = Color("43b306"),
			friendly = Color("0795d5"),
			enemy = Color("c80406"),
			boss = Color("ead79f"),
			damage = Color("ffffff"),
			yellow_crit = Color("ffff00"),
			orange_crit = Color("fe6c09"),
			red_crit = Color("fe0000"),
			squad_chat = Color("569cfe"),
			private_chat = Color("ee8bf0")
		}
	}
	WFHud.default_colors = clone(WFHud.settings.colors)
	WFHud.fonts = {
		default = "fonts/wfhud/default",
		bold = "fonts/wfhud/bold",
		large = "fonts/wfhud/large",
		default_no_shadow = "fonts/wfhud/default_no_shadow",
		bold_no_shadow = "fonts/wfhud/bold_no_shadow",
		large_no_shadow = "fonts/wfhud/large_no_shadow",
		boss = "fonts/wfhud/boss"
	}
	WFHud.font_ids = table.remap(WFHud.fonts, function (k, v) return k, Idstring(v) end)
	WFHud.font_sizes = {
		tiny = 12,
		small = 16,
		default = 18,
		large = 22,
		huge = 44
	}
	WFHud.value_format = {
		default = function (val) return tostring(val < 1 and math.round(val * 100) / 100 or val < 10 and math.round(val * 10) / 10 or math.round(val)) end,
		percentage_mul = function (val) return math.abs(math.ceil((val - 1) * 100)) .. "%" end,
		percentage = function (val) return math.ceil(val * 100) .. "%" end,
		damage = function (val) return tostring(math.ceil(val * 100) / 10) end
	}
	WFHud.proc_type = {
		hurt = "impact",
		heavy_hurt = "impact",
		shield_knock = "impact",
		expl_hurt = "blast",
		taser_tased = "electricity"
	}
	WFHud.sounds = {
		special_pickup = XAudio.Buffer:new(ModPath .. "assets/sounds/special_pickup.ogg")
	}

	if io.file_is_readable(WFHud.save_path) then
		local data = io.load_as_json(WFHud.save_path)
		if not data then
			return
		end

		for k, v in pairs(data.colors or {}) do
			data.colors[k] = Color(v)
		end
		table.replace(WFHud.settings, data, true)
	end

	function WFHud:panel_class(...)
		local c = class(...)
		for k, v in pairs(Panel or {}) do
			if type(v) == "function" and not c[k] then
				c[k] = function (s, ...)
					return s._panel[k](s._panel, ...)
				end
			end
		end
		return c
	end

	function WFHud:setup()
		self:_create_skill_icon_map()

		self:_check_font_replacements()

		if not self.use_default_fonts then
			for _, v in pairs(self.font_ids) do
				managers.dyn_resource:load(ext_mapping.font, v, managers.dyn_resource.DYN_RESOURCES_PACKAGE)
			end
		end

		self._ws = managers.gui_data:create_fullscreen_workspace()
		self._ws:panel():hide()

		self._unit_slotmask = managers.slot:get_mask("persons") + managers.slot:get_mask("bullet_impact_targets")
		self._unit_slotmask_no_walls = self._unit_slotmask - managers.slot:get_mask("bullet_blank_impact_targets")
		self._next_unit_raycast_t = 0

		self:create_hud_elements()
	end

	function WFHud:create_hud_elements()
		self.unit_aim_label = HUDFloatingUnitLabel:new(self:panel(), true)
		self.buff_list = HUDBuffList:new(self:panel(), 0, 0, self:panel():w() - 240 * self.settings.hud_scale, 256 * self.settings.hud_scale)
		self.equipment_panel = HUDPlayerEquipment:new(self:panel())
		self.interact_display = HUDInteractDisplay:new(self:panel())
		self.objective_panel = HUDObjectivePanel:new(self:panel(), WFHud.settings.margin_h, 192)
		self.pickup_list = HUDPickupList:new(self:panel())
		self.special_pickup = HUDSpecialPickup:new(self:panel(), self:panel():h() * 0.95 - 256 * self.settings.hud_scale)
		self.boss_bar = HUDBossBar:new(self:panel(), math.round(self.buff_list:h() * 0.35))
		self.chat = HUDCustomChat:new(self:ws(), self:panel())
	end

	function WFHud:update(t, dt)
		self:_check_player_forward_ray(t)

		self.unit_aim_label:update(t, dt)
		self.buff_list:update(t, dt)
		self.interact_display:update(t, dt)
		self.pickup_list:update(t, dt)
		self.chat:update(t, dt)
	end

	function WFHud:ws()
		return self._ws
	end

	function WFHud:panel()
		return self._ws:panel()
	end

	function WFHud:add_damage_pop(unit, attack_data)
		if not self.settings.damage_popups or attack_data.is_fire_dot_damage then
			return
		end

		local col_ray = attack_data.col_ray or {}
		local pos = not attack_data.fire_dot_data and (col_ray.position or col_ray.hit_position or attack_data.pos) or mvector3.copy(unit:movement():m_stand_pos())

		local proc
		if attack_data.variant == "fire" then
			proc = "heat"
		elseif attack_data.variant == "poison" then
			proc = "toxin"
		elseif col_ray.body and col_ray.body:name() == unit:character_damage()._ids_plate_name then
			proc = "puncture"
		else
			local result = attack_data.result and attack_data.result.type
			proc = WFHud.proc_type[result] or result
		end

		local damage = attack_data.damage > 0 and attack_data.raw_damage or attack_data.damage
		return HUDDamagePop:new(self:panel(), pos, damage, proc, attack_data.critical_hit, attack_data.headshot)
	end

	function WFHud:add_buff(category, upgrade, value, duration)
		if self.buff_list and Utils:IsInHeist() then
			local upgrade_data = self.skill_map[category] and self.skill_map[category][upgrade]
			if not upgrade_data then
				log("[WFHud] No upgrade definition for " .. tostring(category) .. "." .. tostring(upgrade))
				return
			end

			if not self.settings.buff_list and not upgrade_data.ignore_disabled then
				return
			end

			self.buff_list:add_buff(upgrade_data, value, duration)
		end
	end

	function WFHud:remove_buff(category, upgrade)
		if self.buff_list then
			local upgrade_data = self.skill_map[category] and self.skill_map[category][upgrade]
			if upgrade_data then
				self.buff_list:remove_buff(upgrade_data)
			end
		end
	end

	function WFHud:add_pickup(id, amount, text, texture, texture_rect)
		if self.pickup_list and Utils:IsInHeist() then
			local string_id = "hud_pickup_" .. id
			self.pickup_list:add(id, texture, texture_rect, amount, text or managers.localization:exists(string_id) and managers.localization:text(string_id) or id:pretty(true))
		end
	end

	function WFHud:add_special_pickup(icon, icon_rect, text)
		if self.special_pickup and Utils:IsInHeist() and self.settings.rare_mission_equipment then
			self.special_pickup:add(icon, icon_rect, text)
		end
	end

	local redirects = {
		equipment_bank_manager_key = "equipment_keycard",
		equipment_born_tool = "equipment_bfd_tool",
		equipment_elevator_key = "equipment_generic_key",
		equipment_gasoline_pent = "equipment_diesel",
		equipment_key_chain_pent = "equipment_key_chain_pex",
		equipment_rfid_tag_02 = "equipment_rfid_tag_01",
		equipment_stash_server = "equipment_harddrive",
		equipment_thermite_red2 = "equipment_gasoline",
		equipment_usb_with_data = "equipment_usb_no_data",
		equipment_vial = "equipment_bloodvial",
		equipment_vialOK = "equipment_bloodvialok",
		pd2_c4 = "equipment_c4",
		pd2_generic_saw = "equipment_saw"
	}
	function WFHud:get_icon_data(icon_id)
		if not icon_id then
			return
		end
		icon_id = redirects[icon_id] or icon_id
		local icon_id_level = icon_id .. "_" .. tostring(Global.game_settings.level_id)
		local custom_level_texture = "guis/textures/wfhud/hud_icons/" .. (redirects[icon_id_level] or icon_id_level)
		if DB:has(ext_mapping.dds, Idstring(custom_level_texture)) then
			return custom_level_texture
		end
		local custom_texture = "guis/textures/wfhud/hud_icons/" .. (redirects[icon_id] or icon_id)
		if DB:has(ext_mapping.dds, Idstring(custom_texture)) then
			return custom_texture
		end
		return tweak_data.hud_icons:get_icon_data(icon_id)
	end

	local mvec_add = mvector3.add
	local mvec_mul = mvector3.multiply
	local mvec_set = mvector3.set
	local to_vec = Vector3()
	function WFHud:_check_player_forward_ray(t)
		if self._next_unit_raycast_t > t then
			return
		end

		self._next_unit_raycast_t = t + 0.05

		local player = managers.player:local_player()
		if not alive(player) or not self.settings.health_labels then
			if self._unit_aim_custom_label then
				self._unit_aim_custom_label:set_health_visible(false)
				self._unit_aim_custom_label = nil
			end
			self.unit_aim_label:set_unit(nil)
			return
		end

		local cam = player:camera()
		local from = cam:position()
		mvec_set(to_vec, cam:forward())
		mvec_mul(to_vec, 10000)
		mvec_add(to_vec, from)
		local ray1 = World:raycast("ray", from, to_vec, "slot_mask", self._unit_slotmask_no_walls, "sphere_cast_radius", 30)
		local ray2 = World:raycast("ray", from, to_vec, "slot_mask", self._unit_slotmask)

		local unit = ray1 and (not ray2 or ray2.unit == ray1.unit or ray2.distance > ray1.distance) and ray1.unit or ray2 and ray2.unit
		if unit and unit ~= self.boss_bar._unit then
			if unit:in_slot(8) and alive(unit:parent()) then
				unit = unit:parent()
			end

			if unit:character_damage() and not unit:character_damage()._dead then
				local unit_data = unit:unit_data()

				if self._unit_aim_custom_label and unit_data._wfhud_label ~= self._unit_aim_custom_label then
					self._unit_aim_custom_label:set_health_visible(false)
					self._unit_aim_custom_label = nil
				end

				if unit_data._wfhud_label then
					self._unit_aim_custom_label = unit_data._wfhud_label
					self._unit_aim_custom_label:set_health_visible(true)
					self.unit_aim_label:set_unit(nil)
				else
					self.unit_aim_label:set_unit(unit)
				end

				return
			end
		end

		if self._unit_aim_custom_label then
			self._unit_aim_custom_label:set_health_visible(false)
			self._unit_aim_custom_label = nil
		end
		self.unit_aim_label:set_unit(nil)
	end

	function WFHud:_create_skill_icon_map()
		local cat_by_up = {
			interacting_damage_multiplier = "damage_dampener",
			hostage_absorption = "damage_dampener"
		}
		local cat_find = {
			{ "reload", "reload_speed" },
			{ "speed", "speed" },
			{ "crit", "critical_hit" },
			{ "stamina", "stamina" },
			{ "armor", "armor" },
			{ "dmg_dampener", "damage_dampener" },
			{ "damage_dampener", "damage_dampener" },
			{ "damage_resist", "damage_dampener" },
			{ "damage_reduction", "damage_dampener" },
			{ "dmg", "damage" },
			{ "damage", "damage" },
			{ "health", "health" }
		}
		local function get_category(cat, up)
			if cat_by_up[up] then
				return cat_by_up[up]
			end
			for _, v in ipairs(cat_find) do
				if cat:find(v[1]) or up:find(v[1]) then
					return v[2]
				end
			end
			local m = up:match("([a-z]+)_multiplier")
			return m or cat
		end

		local cat_format = {
			damage_dampener = WFHud.value_format.percentage_mul,
			damage = WFHud.value_format.percentage_mul,
			speed = WFHud.value_format.percentage_mul,
			reload_speed = WFHud.value_format.percentage_mul
		}
		local up_format = {
			chico_injector = WFHud.value_format.percentage,
			melee_life_leech = WFHud.value_format.percentage,
			pocket_ecm_kill_dodge = WFHud.value_format.percentage,
			unseen_increased_crit_chance = WFHud.value_format.percentage_mul
		}
		local function get_value_format(icon_cat, up)
			if up_format[up] then
				return up_format[up]
			end
			if cat_format[icon_cat] then
				return cat_format[icon_cat]
			end
			return WFHud.value_format.default
		end
		local function set_skill_map_data(cat, up, var, val)
			local data = self.skill_map[cat] and self.skill_map[cat][up]
			if data then
				data[var] = val
			end
		end
		local function set_skill_map(cat1, up1, cat2, up2)
			self.skill_map[cat1] = self.skill_map[cat1] or {}
			self.skill_map[cat1][up1] = self.skill_map[cat2] and self.skill_map[cat2][up2]
		end

		-- Collect skill mappings
		for _, skill in pairs(tweak_data.skilltree.skills) do
			for _, level in ipairs(skill) do
				for _, upgrade in pairs(level.upgrades or {}) do
					local def = tweak_data.upgrades.definitions[upgrade]
					local cat = def and def.upgrade and def.upgrade.category
					local up = def and def.upgrade and def.upgrade.upgrade
					if cat and up then
						self.skill_map[cat] = self.skill_map[cat] or {}
						self.skill_map[cat][up] = {}
						self.skill_map[cat][up].key = cat .. "." .. up
						self.skill_map[cat][up].icon_category = get_category(cat, up)
						self.skill_map[cat][up].name_id = skill.name_id
						self.skill_map[cat][up].texture_rect = { skill.icon_xy[1] * 80, skill.icon_xy[2] * 80, 80, 80 }
						self.skill_map[cat][up].texture = "guis/textures/wfhud/skill_icons_clean"
						self.skill_map[cat][up].value_format = get_value_format(self.skill_map[cat][up].icon_category, up)
					end
				end
			end
		end

		-- Collect perk deck mappings
		local my_deck_index = managers.skilltree:get_specialization_value("current_specialization")
		for deck_index, deck in ipairs(tweak_data.skilltree.specializations) do
			for card_index, card in ipairs(deck) do
				if card_index % 2 == 1 then
					for _, upgrade in pairs(card.upgrades) do
						local def = tweak_data.upgrades.definitions[upgrade]
						local cat = def and def.upgrade and def.upgrade.category
						local up = def and def.upgrade and def.upgrade.upgrade
						if cat and up and (not self.skill_map[cat] or not self.skill_map[cat][up] or not self.skill_map[cat][up].my_deck) then
							self.skill_map[cat] = self.skill_map[cat] or {}
							self.skill_map[cat][up] = {}
							self.skill_map[cat][up].key = cat .. "." .. up
							self.skill_map[cat][up].icon_category = get_category(cat, up)
							self.skill_map[cat][up].name_id = card.name_id
							self.skill_map[cat][up].texture_rect = { card.icon_xy[1] * 64, card.icon_xy[2] * 64, 64, 64 }
							self.skill_map[cat][up].texture = "guis/" .. (card.texture_bundle_folder and "dlcs/" .. tostring(card.texture_bundle_folder) .. "/" or "")  .. "textures/pd2/specialization/icons_atlas"
							self.skill_map[cat][up].value_format = get_value_format(self.skill_map[cat][up].icon_category, up)
							self.skill_map[cat][up].my_deck = deck_index == my_deck_index
						end
					end
				end
			end
		end

		-- Link team skills
		set_skill_map("temporary", "team_damage_speed_multiplier_received", "temporary", "damage_speed_multiplier")
		set_skill_map("temporary", "first_aid_damage_reduction", "first_aid_kit", "damage_reduction_upgrade")
		set_skill_map("temporary", "unseen_strike", "player", "unseen_increased_crit_chance")

		-- Set allowed buffs for disabled buff list
		set_skill_map_data("player", "armor_health_store_amount", "ignore_disabled", true)
		set_skill_map_data("player", "cocaine_stacking", "ignore_disabled", true)
		set_skill_map_data("player", "tag_team_base", "ignore_disabled", true)
		set_skill_map_data("player", "pocket_ecm_jammer_base", "ignore_disabled", true)
		set_skill_map_data("temporary", "chico_injector", "ignore_disabled", true)
		set_skill_map_data("temporary", "copr_ability", "ignore_disabled", true)

		-- Create custom mappings
		self.skill_map.player = self.skill_map.player or {}
		self.skill_map.player.stoic_dot = {
			key = "player.stoic_dot",
			name_id = "hud_dot",
			texture_rect = { 96, 0, 48, 48 },
			texture = "guis/textures/wfhud/damage_types",
			value_format = WFHud.value_format.default,
			is_debuff = true,
			hide_name = true,
			custom = true,
			ignore_disabled = true
		}

		-- non player specific mappings
		self.skill_map.game = {
			hostages = {
				key = "game.hostages",
				name_id = "hud_hostages",
				texture_rect = { 0, 0, 80, 80 },
				texture = "guis/textures/wfhud/info_icons",
				value_format = WFHud.value_format.default,
				custom = true,
				ignore_disabled = true
			},
			downs = {
				key = "game.downs",
				name_id = "hud_downs",
				texture_rect = { 1 * 80, 0, 80, 80 },
				texture = "guis/textures/wfhud/info_icons",
				value_format = WFHud.value_format.default,
				hide_name = true,
				custom = true,
				ignore_disabled = true
			},
			ecm_jammer = {
				key = "game.ecm_jammer",
				name_id = "hud_ecm_jammer",
				texture_rect = { 6 * 80, 2 * 80, 80, 80 },
				texture = "guis/textures/wfhud/skill_icons_clean",
				value_format = WFHud.value_format.default,
				custom = true
			},
			ecm_feedback = {
				key = "game.ecm_feedback",
				name_id = "hud_ecm_feedback",
				texture_rect = { 6 * 80, 3 * 80, 80, 80 },
				texture = "guis/textures/wfhud/skill_icons_clean",
				value_format = WFHud.value_format.default,
				custom = true
			}
		}
	end

	function WFHud:_check_font_replacements()
		local replace_languages = {
			schinese = true,
			japanese = true,
			korean = true
		}
		if not replace_languages[HopLib:get_game_language()] and not self.settings.vanilla_fonts then
			return
		end

		self.fonts.default = tweak_data.menu.pd2_medium_font
		self.fonts.bold = tweak_data.menu.pd2_medium_font
		self.fonts.default_no_shadow = tweak_data.menu.pd2_medium_font
		self.fonts.bold_no_shadow = tweak_data.menu.pd2_medium_font
		self.fonts.large = tweak_data.menu.pd2_large_font
		self.fonts.large_no_shadow = tweak_data.menu.pd2_large_font
		self.fonts.boss = tweak_data.menu.pd2_large_font

		self.font_ids = table.remap(self.fonts, function (k, v) return k, Idstring(v) end)

		self.use_default_fonts = true
	end

	Hooks:Add("LocalizationManagerPostInit", "LocalizationManagerPostInitWFHud", function(loc)
		HopLib:load_localization(WFHud.mod_path .. "loc/", loc)
	end)

	Hooks:Add("MenuManagerBuildCustomMenus", "MenuManagerBuildCustomMenusWFHud", function(menu_manager, nodes)

		local function set_settings_value(name, value)
			local settings_table = WFHud.settings
			local path = name:split("%.")
			for i = 1, #path - 1 do
				settings_table = settings_table[path[i]]
				if not settings_table then
					log("[WFHud] Could not save setting " .. name .. "!")
					return
				end
			end
			settings_table[path[#path]] = value
		end

		function MenuCallbackHandler:WFHud_number_value(item)
			item:set_value(math.round_with_precision(item:value(), 2))
			set_settings_value(item:name(), item:value())
		end

		function MenuCallbackHandler:WFHud_integer_value(item)
			item:set_value(math.round(item:value()))
			set_settings_value(item:name(), item:value())
		end

		function MenuCallbackHandler:WFHud_boolean_value(item)
			set_settings_value(item:name(), item:value() == "on")
		end

		function MenuCallbackHandler:WFHud_color_value(item)
			set_settings_value(item:name(), item:value())
		end

		function MenuCallbackHandler:WFHud_reset_colors()
			WFHud.settings.colors = clone(WFHud.default_colors)
			for k, item in pairs(WFHud._color_menu_items or {}) do
				item:set_value(WFHud.default_colors[k])
			end
		end

		function MenuCallbackHandler:WFHud_save()
			local data = deep_clone(WFHud.settings)
			for k, v in pairs(data.colors) do
				data.colors[k] = string.format("%02x%02x%02x", v.r * 255, v.g * 255, v.b * 255)
			end
			io.save_as_json(data, WFHud.save_path)
		end

		local menu_ids = {
			main =  "wfhud_menu_main",
			player_panels = "wfhud_menu_player_panels",
			chat = "wfhud_menu_chat",
			colors = "wfhud_menu_colors"
		}
		for _, v in pairs(menu_ids) do
			MenuHelper:NewMenu(v)
		end

		MenuHelper:AddSlider({
			id = "hud_scale",
			title = "menu_wfhud_hud_scale",
			desc = "menu_wfhud_hud_scale_desc",
			callback = "WFHud_number_value",
			value = WFHud.settings.hud_scale,
			min = 0.5,
			max = 2,
			step = 0.05,
			show_value = true,
			menu_id = menu_ids.main,
			priority = 99
		})

		MenuHelper:AddSlider({
			id = "font_scale",
			title = "menu_wfhud_font_scale",
			desc = "menu_wfhud_font_scale_desc",
			callback = "WFHud_number_value",
			value = WFHud.settings.font_scale,
			min = 0.5,
			max = 2,
			step = 0.05,
			show_value = true,
			menu_id = menu_ids.main,
			priority = 98
		})

		MenuHelper:AddDivider({
			size = 16,
			menu_id = menu_ids.main,
			priority = 89
		})

		MenuHelper:AddSlider({
			id = "margin_h",
			title = "menu_wfhud_margin_h",
			desc = "menu_wfhud_margin_h_desc",
			callback = "WFHud_integer_value",
			value = WFHud.settings.margin_h,
			min = 0,
			max = 128,
			step = 8,
			show_value = true,
			menu_id = menu_ids.main,
			priority = 88
		})

		MenuHelper:AddSlider({
			id = "margin_v",
			title = "menu_wfhud_margin_v",
			desc = "menu_wfhud_margin_v_desc",
			callback = "WFHud_integer_value",
			value = WFHud.settings.margin_v,
			min = 0,
			max = 128,
			step = 8,
			show_value = true,
			menu_id = menu_ids.main,
			priority = 87
		})

		MenuHelper:AddDivider({
			size = 16,
			menu_id = menu_ids.main,
			priority = 79
		})

		MenuHelper:AddToggle({
			id = "buff_list",
			title = "menu_wfhud_buff_list",
			desc = "menu_wfhud_buff_list_desc",
			callback = "WFHud_boolean_value",
			value = WFHud.settings.buff_list,
			menu_id = menu_ids.main,
			priority = 78
		})

		MenuHelper:AddToggle({
			id = "rare_mission_equipment",
			title = "menu_wfhud_rare_mission_equipment",
			desc = "menu_wfhud_rare_mission_equipment_desc",
			callback = "WFHud_boolean_value",
			value = WFHud.settings.rare_mission_equipment,
			menu_id = menu_ids.main,
			priority = 77
		})

		MenuHelper:AddToggle({
			id = "health_labels",
			title = "menu_wfhud_health_labels",
			desc = "menu_wfhud_health_labels_desc",
			callback = "WFHud_boolean_value",
			value = WFHud.settings.health_labels,
			menu_id = menu_ids.main,
			priority = 76
		})

		MenuHelper:AddToggle({
			id = "boss_bar",
			title = "menu_wfhud_boss_bar",
			desc = "menu_wfhud_boss_bar_desc",
			callback = "WFHud_boolean_value",
			value = WFHud.settings.boss_bar,
			menu_id = menu_ids.main,
			priority = 75
		})

		MenuHelper:AddToggle({
			id = "damage_popups",
			title = "menu_wfhud_damage_popups",
			desc = "menu_wfhud_damage_popups_desc",
			callback = "WFHud_boolean_value",
			value = WFHud.settings.damage_popups,
			menu_id = menu_ids.main,
			priority = 74
		})

		MenuHelper:AddToggle({
			id = "waypoints",
			title = "menu_wfhud_waypoints",
			desc = "menu_wfhud_waypoints_desc",
			callback = "WFHud_boolean_value",
			value = WFHud.settings.waypoints,
			menu_id = menu_ids.main,
			priority = 73
		})

		MenuHelper:AddToggle({
			id = "world_interactions",
			title = "menu_wfhud_world_interactions",
			desc = "menu_wfhud_world_interactions_desc",
			callback = "WFHud_boolean_value",
			value = WFHud.settings.world_interactions,
			menu_id = menu_ids.main,
			priority = 72
		})

		MenuHelper:AddDivider({
			size = 16,
			menu_id = menu_ids.main,
			priority = 69
		})

		MenuHelper:AddToggle({
			id = "vanilla_ammo",
			title = "menu_wfhud_vanilla_ammo",
			desc = "menu_wfhud_vanilla_ammo_desc",
			callback = "WFHud_boolean_value",
			value = WFHud.settings.vanilla_ammo,
			menu_id = menu_ids.main,
			priority = 68
		})

		MenuHelper:AddToggle({
			id = "vanilla_fonts",
			title = "menu_wfhud_vanilla_fonts",
			desc = "menu_wfhud_vanilla_fonts_desc",
			callback = "WFHud_boolean_value",
			value = WFHud.settings.vanilla_fonts,
			menu_id = menu_ids.main,
			priority = 68
		})

		MenuHelper:AddDivider({
			size = 16,
			menu_id = menu_ids.main,
			priority = 59
		})

		MenuHelper:AddButton({
			id = "chat",
			title = "menu_wfhud_chat",
			next_node = menu_ids.chat,
			menu_id = menu_ids.main,
			priority = 58
		})

		MenuHelper:AddButton({
			id = "player_panels",
			title = "menu_wfhud_player_panels",
			next_node = menu_ids.player_panels,
			menu_id = menu_ids.main,
			priority = 57
		})

		MenuHelper:AddDivider({
			size = 16,
			menu_id = menu_ids.main,
			priority = 56
		})

		MenuHelper:AddButton({
			id = "colors",
			title = "menu_wfhud_colors",
			next_node = menu_ids.colors,
			menu_id = menu_ids.main,
			priority = 55
		})

		-- Chat
		MenuHelper:AddToggle({
			id = "chat.enabled",
			title = "menu_wfhud_enabled",
			desc = "menu_wfhud_chat_enabled_desc",
			callback = "WFHud_boolean_value",
			value = WFHud.settings.chat.enabled,
			menu_id = menu_ids.chat,
			priority = 99
		})

		MenuHelper:AddDivider({
			size = 16,
			menu_id = menu_ids.chat,
			priority = 89
		})

		MenuHelper:AddMultipleChoice({
			id = "chat.timestamps",
			title = "menu_wfhud_chat_timestamps",
			desc = "menu_wfhud_chat_timestamps_desc",
			callback = "WFHud_integer_value",
			value = WFHud.settings.chat.timestamps,
			items = {
				"menu_wfhud_chat_timestamps_real_time",
				"menu_wfhud_chat_timestamps_real_time_am_pm",
				"menu_wfhud_chat_timestamps_heist_time",
				"menu_off"
			},
			menu_id = menu_ids.chat,
			priority = 88
		})

		MenuHelper:AddDivider({
			size = 16,
			menu_id = menu_ids.chat,
			priority = 79
		})

		MenuHelper:AddToggle({
			id = "chat.keep_open",
			title = "menu_wfhud_chat_keep_open",
			desc = "menu_wfhud_chat_keep_open_desc",
			callback = "WFHud_boolean_value",
			value = WFHud.settings.chat.keep_open,
			menu_id = menu_ids.chat,
			priority = 78
		})
		--[[
		MenuHelper:AddToggle({
			id = "chat.inline",
			title = "menu_wfhud_chat_inline",
			desc = "menu_wfhud_chat_inline_desc",
			callback = "WFHud_boolean_value",
			value = WFHud.settings.chat.inline,
			menu_id = menu_ids.chat,
			priority = 77
		})
		]]
		MenuHelper:AddToggle({
			id = "chat.use_peer_colors",
			title = "menu_wfhud_use_peer_colors",
			desc = "menu_wfhud_chat_use_peer_colors_desc",
			callback = "WFHud_boolean_value",
			value = WFHud.settings.chat.use_peer_colors,
			menu_id = menu_ids.chat,
			priority = 76
		})

		-- Player panels
		MenuHelper:AddToggle({
			id = "player_panels.show_deployables",
			title = "menu_wfhud_player_panels_show_deployables",
			desc = "menu_wfhud_player_panels_show_deployables_desc",
			callback = "WFHud_boolean_value",
			value = WFHud.settings.player_panels.show_deployables,
			menu_id = menu_ids.player_panels,
			priority = 99
		})

		MenuHelper:AddToggle({
			id = "player_panels.show_downs",
			title = "menu_wfhud_player_panels_show_downs",
			desc = "menu_wfhud_player_panels_show_downs_desc",
			callback = "WFHud_boolean_value",
			value = WFHud.settings.player_panels.show_downs,
			menu_id = menu_ids.player_panels,
			priority = 98
		})

		MenuHelper:AddToggle({
			id = "player_panels.use_peer_colors",
			title = "menu_wfhud_use_peer_colors",
			desc = "menu_wfhud_player_panels_use_peer_colors_desc",
			callback = "WFHud_boolean_value",
			value = WFHud.settings.player_panels.use_peer_colors,
			menu_id = menu_ids.player_panels,
			priority = 97
		})

		-- Colors
		MenuHelper:AddButton({
			id = "colors.reset",
			title = "menu_wfhud_colors_reset",
			callback = "WFHud_reset_colors",
			menu_id = menu_ids.colors,
			priority = 99
		})

		MenuHelper:AddDivider({
			size = 16,
			menu_id = menu_ids.colors,
			priority = 89
		})

		if not MenuHelperPlus then
			MenuHelper:AddButton({
				id = "colors.beardlib_required",
				title = "menu_wfhud_colors_beardlib_required",
				menu_id = menu_ids.colors,
				priority = 88
			})
		end

		for _, v in pairs(menu_ids) do
			nodes[v] = MenuHelper:BuildMenu(v, { back_callback = "WFHud_save" })
		end

		if MenuHelperPlus then
			local sorted_colors = {
				"default",
				"muted",
				"bg",
				"buff" ,
				"debuff",
				"health",
				"shield",
				"armor",
				"object",
				"objective",
				"attack",
				"extract",
				"friendly",
				"enemy",
				"boss",
				"damage",
				"yellow_crit",
				"orange_crit",
				"red_crit",
				"squad_chat"
			}
			WFHud._color_menu_items = {}
			for i, v in pairs(sorted_colors) do
				WFHud._color_menu_items[v] = MenuHelperPlus:AddColorButton({
					id = "colors." .. v,
					title = "menu_wfhud_colors_" .. v,
					callback = "WFHud_color_value",
					value = WFHud.settings.colors[v],
					node_name = menu_ids.colors,
					priority = 90 - i
				})
			end
		end

		MenuHelper:AddMenuItem(nodes["blt_options"], menu_ids.main, "menu_wfhud")
	end)


	dofile(ModPath .. "req/HUDHealthBar.lua")
	dofile(ModPath .. "req/HUDIconList.lua")
	dofile(ModPath .. "req/HUDPlayerPanel.lua")
	dofile(ModPath .. "req/HUDPlayerEquipment.lua")
	dofile(ModPath .. "req/HUDFloatingUnitLabel.lua")
	dofile(ModPath .. "req/HUDBuffList.lua")
	dofile(ModPath .. "req/HUDDamagePop.lua")
	dofile(ModPath .. "req/HUDInteractDisplay.lua")
	dofile(ModPath .. "req/HUDObjectivePanel.lua")
	dofile(ModPath .. "req/HUDPickupList.lua")
	dofile(ModPath .. "req/HUDSpecialPickup.lua")
	dofile(ModPath .. "req/HUDBossBar.lua")
	dofile(ModPath .. "req/HUDCustomChat.lua")

end

if RequiredScript then

	local fname = WFHud.mod_path .. RequiredScript:gsub(".+/(.+)", "lua/%1.lua")
	if io.file_is_readable(fname) then
		dofile(fname)
	end

end
