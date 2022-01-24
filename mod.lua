if not WFHud then

	local mvec_add = mvector3.add
	local mvec_mul = mvector3.multiply
	local mvec_set = mvector3.set
	local tmp_vec = Vector3()

	local ids_font = Idstring("font")
	local ids_texture = Idstring("texture")
	HopLib:load_assets({
		{ ext = ids_texture, path = "guis/textures/wfhud/skill_icons_clean", file = ModPath .. "assets/guis/textures/wfhud/skill_icons_clean.dds" },
		{ ext = ids_texture, path = "guis/textures/wfhud/buff_categories", file = ModPath .. "assets/guis/textures/wfhud/buff_categories.dds" },
		{ ext = ids_texture, path = "guis/textures/wfhud/damage_types", file = ModPath .. "assets/guis/textures/wfhud/damage_types.dds" },
		{ ext = ids_texture, path = "guis/textures/wfhud/bar", file = ModPath .. "assets/guis/textures/wfhud/bar.dds" },
		{ ext = ids_texture, path = "guis/textures/wfhud/bar_caps", file =  ModPath .. "assets/guis/textures/wfhud/bar_caps.dds" },
		{ ext = ids_texture, path = "guis/textures/wfhud/shield_overlay", file = ModPath .. "assets/guis/textures/wfhud/shield_overlay.dds" },
		{ ext = ids_texture, path = "guis/textures/wfhud/avatar_placeholder", file = ModPath .. "assets/guis/textures/wfhud/avatar_placeholder.dds" },
		{ ext = ids_texture, path = "guis/textures/wfhud/invulnerability_overlay", file = ModPath .. "assets/guis/textures/wfhud/invulnerability_overlay.dds" },
		{ ext = ids_texture, path = "guis/textures/wfhud/icons", file = ModPath .. "assets/guis/textures/wfhud/icons.dds" },
		{ ext = ids_texture, path = "fonts/wfhud/default", file = ModPath .. "assets/fonts/wfhud/default.dds" },
		{ ext = ids_texture, path = "fonts/wfhud/default_no_shadow", file = ModPath .. "assets/fonts/wfhud/default_no_shadow.dds" },
		{ ext = ids_texture, path = "fonts/wfhud/bold", file = ModPath .. "assets/fonts/wfhud/bold.dds" },
		{ ext = ids_texture, path = "fonts/wfhud/bold_no_shadow", file = ModPath .. "assets/fonts/wfhud/bold_no_shadow.dds" },
		{ ext = ids_texture, path = "fonts/wfhud/large", file = ModPath .. "assets/fonts/wfhud/large.dds" },
		{ ext = ids_texture, path = "fonts/wfhud/large_no_shadow", file = ModPath .. "assets/fonts/wfhud/large_no_shadow.dds" },
		{ ext = ids_font, path = "fonts/wfhud/default", file = ModPath .. "assets/fonts/wfhud/default.font" },
		{ ext = ids_font, path = "fonts/wfhud/default_no_shadow", file = ModPath .. "assets/fonts/wfhud/default_no_shadow.font" },
		{ ext = ids_font, path = "fonts/wfhud/bold", file = ModPath .. "assets/fonts/wfhud/bold.font" },
		{ ext = ids_font, path = "fonts/wfhud/bold_no_shadow", file = ModPath .. "assets/fonts/wfhud/bold_no_shadow.font" },
		{ ext = ids_font, path = "fonts/wfhud/large", file = ModPath .. "assets/fonts/wfhud/large.font" },
		{ ext = ids_font, path = "fonts/wfhud/large_no_shadow", file = ModPath .. "assets/fonts/wfhud/large_no_shadow.font" },
	})

	dofile(ModPath .. "req/HUDHealthBar.lua")
	dofile(ModPath .. "req/HUDIconList.lua")
	dofile(ModPath .. "req/HUDPlayerPanel.lua")
	dofile(ModPath .. "req/HUDPlayerEquipment.lua")
	dofile(ModPath .. "req/HUDFloatingUnitLabel.lua")
	dofile(ModPath .. "req/HUDBuffList.lua")
	dofile(ModPath .. "req/HUDDamagePop.lua")
	dofile(ModPath .. "req/HUDInteractDisplay.lua")
	dofile(ModPath .. "req/HUDObjectivePanel.lua")

	WFHud = {}
	WFHud.mod_path = ModPath
	WFHud.skill_map = {}
	WFHud.colors = {
		default = Color.white,
		muted = Color(0.5, 0.5, 0.5),
		buff = Color(0.012, 0.74, 0.89),
		debuff = Color(0.753, 0.180, 0.173),
		shield = Color(0.012, 0.74, 0.89),
		health = Color(0.753, 0.180, 0.173),
		bg = Color(0.75, 0.25, 0.25, 0.25),
		objective = Color(0.85, 0.65, 0.04),
		attack = Color(0.784, 0.16, 0.24),
		extract = Color(0.263, 0.7, 0.24),
		damage = {
			Color(1, 1, 1, 1),
			Color(1, 1, 1, 0),
			Color(1, 1, 0.5, 0),
			Color(1, 1, 0, 0)
		}
	}
	WFHud.fonts = {
		default = "fonts/wfhud/default",
		default_no_shadow = "fonts/wfhud/default_no_shadow",
		bold = "fonts/wfhud/bold",
		bold_no_shadow = "fonts/wfhud/bold_no_shadow",
		large = "fonts/wfhud/large",
		large_no_shadow = "fonts/wfhud/large_no_shadow"
	}
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
	WFHud.MARGIN_H = 48
	WFHud.MARGIN_V = 32

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
			melee_life_leech = WFHud.value_format.percentage
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
						if cat and up and (not self.skill_map[cat] or not self.skill_map[cat][up] or deck_index == my_deck_index) then
							self.skill_map[cat] = self.skill_map[cat] or {}
							self.skill_map[cat][up] = {}
							self.skill_map[cat][up].key = cat .. "." .. up
							self.skill_map[cat][up].icon_category = get_category(cat, up)
							self.skill_map[cat][up].name_id = card.name_id
							self.skill_map[cat][up].texture_rect = { card.icon_xy[1] * 64, card.icon_xy[2] * 64, 64, 64 }
							self.skill_map[cat][up].texture = "guis/" .. (card.texture_bundle_folder and "dlcs/" .. tostring(card.texture_bundle_folder) .. "/" or "")  .. "textures/pd2/specialization/icons_atlas"
							self.skill_map[cat][up].value_format = get_value_format(self.skill_map[cat][up].icon_category, up)
						end
					end
				end
			end
		end

		-- Create custom mappings
		self.skill_map.player.stoic_dot = {
			key = "player.stoic_dot",
			icon_category = "health",
			name_id = "wfhud_dot",
			texture_rect = { 96, 0, 48, 48 },
			texture = "guis/textures/wfhud/damage_types",
			value_format = WFHud.value_format.default,
			is_debuff = true,
			hide_name = true
		}

	end

	function WFHud:setup()
		for _, v in pairs(self.fonts) do
			managers.dyn_resource:load(ids_font, Idstring(v), managers.dyn_resource.DYN_RESOURCES_PACKAGE)
		end

		self._ws = self._ws or managers.gui_data:create_fullscreen_workspace()
		self._ws:panel():set_layer(-10)

		self._t = 0

		self:_create_skill_icon_map()

		self._damage_pops = {}
		self._damage_pop_key = 1

		self._unit_slotmask = managers.slot:get_mask("persons") + managers.slot:get_mask("bullet_impact_targets")

		self._unit_aim_label = HUDFloatingUnitLabel:new(self:panel())
		self._buff_list = HUDBuffList:new(self:panel(), 0, 0, self:panel():w() - 240, 256)
		self._equipment_panel = HUDPlayerEquipment:new(self:panel())
		self._equipment_panel._panel:set_rightbottom(self:panel():w() - WFHud.MARGIN_H, self:panel():h() - WFHud.MARGIN_V)
		self._interact_display = HUDInteractDisplay:new(self:panel())
		self._objective_panel = HUDObjectivePanel:new(self:panel(), WFHud.MARGIN_H, 200)
	end

	function WFHud:update(t, dt)
		self:check_player_forward_ray()

		self._unit_aim_label:update(t, dt)
		self._buff_list:update(t, dt)
		self._interact_display:update(t, dt)

		self._t = t
	end

	function WFHud:panel()
		return self._ws:panel()
	end

	function WFHud:check_player_forward_ray()
		local player = managers.player:local_player()
		if not alive(player) then
			self._unit_aim_label:set_unit(nil)
			return
		end

		local cam = player:camera()
		local from = cam:position()
		mvec_set(tmp_vec, cam:forward())
		mvec_mul(tmp_vec, 10000)
		mvec_add(tmp_vec, from)
		local ray = World:raycast("ray", from, tmp_vec, "slot_mask", self._unit_slotmask, "sphere_cast_radius", 20)

		local unit = ray and ray.unit
		if unit then
			if unit:in_slot(8) and alive(unit:parent()) then
				unit = unit:parent()
			end

			if unit:movement() and unit:character_damage() and not unit:character_damage()._dead then
				local unit_data = unit:unit_data()

				if self._unit_aim_custom_label and unit_data._wfhud_label ~= self._unit_aim_custom_label then
					self._unit_aim_custom_label:set_health_visible(false)
					self._unit_aim_custom_label = nil
				end

				if unit_data._wfhud_label then
					self._unit_aim_custom_label = unit_data._wfhud_label
					self._unit_aim_custom_label:set_health_visible(true)
				else
					self._unit_aim_label:set_unit(unit)
				end

				return
			end
		end

		if self._unit_aim_custom_label then
			self._unit_aim_custom_label:set_health_visible(false)
			self._unit_aim_custom_label = nil
		end
		self._unit_aim_label:set_unit(nil)
	end

	function WFHud:add_buff(category, upgrade, value, duration)
		if self._buff_list and Utils:IsInHeist() then
			local upgrade_data = self.skill_map[category] and self.skill_map[category][upgrade]
			if not upgrade_data then
				log("[WFHud] No upgrade definition for " .. tostring(category) .. "." .. tostring(upgrade))
				return
			end
			self._buff_list:add_buff(upgrade_data, value, duration)
		end
	end

	function WFHud:remove_buff(category, upgrade)
		if self._buff_list then
			local upgrade_data = self.skill_map[category] and self.skill_map[category][upgrade]
			if upgrade_data then
				self._buff_list:remove_buff(upgrade_data)
			end
		end
	end

	local categories = { "speed", "stamina", "critical_hit", "damage_dampener", "health", "armor" }
	function WFHud:check_hostage_buffs()
		local mul
		local pm = managers.player
		local minions = pm:num_local_minions() or 0
		local hostages_total = managers.groupai:state()._hostage_headcount + minions
		local hostage_max_num
		for _, v in pairs(categories) do
			hostage_max_num = math.min(hostages_total, tweak_data:get_raw_value("upgrades", "hostage_max_num", v) or hostages_total)

			-- Multiplier bonuses
			mul = 1 + (pm:team_upgrade_value(v, "hostage_multiplier", 1) - 1) * hostage_max_num
			if mul ~= 1 then
				self:add_buff(v, "hostage_multiplier", self.value_format.percentage_mul(mul))
			else
				WFHud:remove_buff(v, "hostage_multiplier")
			end

			mul = 1 + (pm:team_upgrade_value(v, "passive_hostage_multiplier", 1) - 1) * hostage_max_num
			if mul ~= 1 then
				self:add_buff(v, "passive_hostage_multiplier", self.value_format.percentage_mul(mul))
			else
				self:remove_buff(v, "passive_hostage_multiplier")
			end

			mul = 1 + (pm:upgrade_value("player", "hostage_" .. v .. "_multiplier", 1) - 1) * hostage_max_num
			if mul ~= 1 then
				self:add_buff("player", "hostage_" .. v .. "_multiplier", self.value_format.percentage_mul(mul))
			else
				self:remove_buff("player", "hostage_" .. v .. "_multiplier")
			end

			mul = 1 + (pm:upgrade_value("player", "passive_hostage_" .. v .. "_multiplier", 1) - 1) * hostage_max_num
			if mul ~= 1 then
				self:add_buff("player", "passive_hostage_" .. v .. "_multiplier", self.value_format.percentage_mul(mul))
			else
				self:remove_buff("player", "passive_hostage_" .. v .. "_multiplier")
			end

			-- Additive bonuses
			mul = pm:team_upgrade_value(v, "hostage_addend", 0) * hostage_max_num
			if mul ~= 0 then
				self:add_buff(v, "hostage_addend", mul)
			else
				self:remove_buff(v, "hostage_addend")
			end

			mul = pm:team_upgrade_value(v, "passive_hostage_addend", 0) * hostage_max_num
			if mul ~= 0 then
				self:add_buff(v, "passive_hostage_addend", mul)
			else
				self:remove_buff(v, "passive_hostage_addend")
			end

			mul = pm:upgrade_value("player", "hostage_" .. v .. "_addend", 0) * hostage_max_num
			if mul ~= 0 then
				self:add_buff("player", "hostage_" .. v .. "_addend", mul)
			else
				self:remove_buff("player", "hostage_" .. v .. "_addend")
			end

			mul = pm:upgrade_value("player", "passive_hostage_" .. v .. "_addend", 0) * hostage_max_num
			if mul ~= 0 then
				self:add_buff("player", "passive_hostage_" .. v .. "_addend", mul)
			else
				self:remove_buff("player", "passive_hostage_" .. v .. "_addend")
			end
		end

		if minions > 0 then
			self:add_buff("player", "convert_enemies", minions)

			mul = pm:upgrade_value("player", "minion_master_speed_multiplier", 1)
			if mul > 1 then
				self:add_buff("player", "minion_master_speed_multiplier", self.value_format.percentage_mul(mul))
			end
			mul = pm:upgrade_value("player", "minion_master_health_multiplier", 1)
			if mul > 1 then
				self:add_buff("player", "minion_master_health_multiplier", self.value_format.percentage_mul(mul))
			end
		else
			self:remove_buff("player", "convert_enemies")
			self:remove_buff("player", "minion_master_speed_multiplier")
			self:remove_buff("player", "minion_master_health_multiplier")
		end
	end

	function WFHud:add_damage_pop(unit, attack_data)
		if attack_data.is_fire_dot_damage then
			return
		end

		local col_ray = attack_data.col_ray or {}
		local pos = not attack_data.fire_dot_data and (col_ray.position or col_ray.hit_position or attack_data.pos) or mvector3.copy(unit:movement():m_stand_pos())

		local proc
		if attack_data.variant == "fire" and managers.fire:is_set_on_fire(unit) then
			proc = "heat"
		elseif unit:character_damage()._has_plate and col_ray.body and col_ray.body:name() == unit:character_damage()._ids_plate_name then
			proc = "puncture"
		else
			local result = attack_data.result and attack_data.result.type
			proc = WFHud.proc_type[result] or result
		end

		if self._damage_pops[self._damage_pop_key] then
			self._damage_pops[self._damage_pop_key]:destroy()
		end

		return HUDDamagePop:new(self:panel(), pos, attack_data.raw_damage or attack_data.damage, proc, attack_data.critical_hit, attack_data.headshot)
	end

	Hooks:Add("LocalizationManagerPostInit", "LocalizationManagerPostInitWFHud", function(loc)
		HopLib:load_localization(WFHud.mod_path .. "loc/", loc)
	end)

end

if RequiredScript then

	local fname = WFHud.mod_path .. RequiredScript:gsub(".+/(.+)", "lua/%1.lua")
	if io.file_is_readable(fname) then
		dofile(fname)
	end

end
