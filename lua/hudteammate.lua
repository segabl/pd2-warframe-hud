local hud_scale = WFHud.settings.hud_scale
local font_scale = WFHud.settings.font_scale

local panels = {}
local panels_y = WFHud.settings.margin_v + 88 * hud_scale
local panels_offset = 4 * hud_scale
local function align_wfhud_panels()
	local y = panels_y
	for _, panel in ipairs(panels) do
		if panel._wfhud_panel and panel._wfhud_panel:visible() then
			panel._wfhud_panel:set_y(y)
			panel._wfhud_item_list:set_y(y)
			y = y + panel._wfhud_panel:h() + panels_offset
		end
	end
end

Hooks:PostHook(HUDTeammate, "init", "init_wfhud", function (self, i, teammates_panel, is_player, width)
	self._wfhud_panel = HUDPlayerPanel:new(WFHud:panel(), self._main_player)
	self._wfhud_panel:hide()
	self._wfhud_panel:set_right(WFHud:panel():w() - WFHud.settings.margin_h)

	if self._main_player then
		self._wfhud_panel:set_y(WFHud.settings.margin_v)
	else
		self._wfhud_item_list = HUDIconList:new(WFHud:panel(), 0, self._wfhud_panel:y(), self._wfhud_panel:right() - 152 * hud_scale, 24 * hud_scale, WFHud.settings.colors.buff)
		self._wfhud_item_list:hide()

		table.insert(panels, self)
	end
end)

Hooks:PostHook(HUDTeammate, "add_panel", "add_panel_wfhud", function (self)
	self._panel:hide()

	self._wfhud_panel:show()

	if self._main_player then
		WFHud.equipment_panel:show()
		if managers.player:local_player() then
			managers.player:local_player():movement():_change_stamina(0) -- ugh
		end
	end

	if self._wfhud_item_list then
		self._wfhud_item_list:show()
	end

	align_wfhud_panels()
end)

Hooks:PostHook(HUDTeammate, "remove_panel", "remove_panel_wfhud", function (self)
	self._health_set = nil
	self._armor_set = nil

	self._wfhud_panel:hide()
	self._wfhud_panel:health_bar()._set_data_instant = true

	if self._main_player then
		WFHud.equipment_panel:hide()
		WFHud.equipment_panel:clear()
	else
		self._wfhud_item_list:hide()
		self._wfhud_item_list:clear()
	end

	align_wfhud_panels()
end)

Hooks:PostHook(HUDTeammate, "set_waiting", "set_waiting_wfhud", function (self)
	self._panel:hide()
end)

Hooks:PostHook(HUDTeammate, "set_name", "set_name_wfhud", function (self, name)
	self._wfhud_panel:set_name(name)
end)

Hooks:PostHook(HUDTeammate, "set_callsign", "set_callsign_wfhud", function (self, id)
	self._wfhud_panel:set_peer_id(id, self._ai)
end)

Hooks:PostHook(HUDTeammate, "set_health", "set_health_wfhud", function (self)
	self._health_set = true
	if self._health_set and self._armor_set then
		self._wfhud_panel:health_bar():set_data(self._health_data.current * 10, self._health_data.total * 10, self._armor_data.current * 10, self._armor_data.total * 10)
	end
end)

Hooks:PostHook(HUDTeammate, "set_armor", "set_armor_wfhud", function (self)
	self._armor_set = true
	if self._health_set and self._armor_set then
		self._wfhud_panel:health_bar():set_data(self._health_data.current * 10, self._health_data.total * 10, self._armor_data.current * 10, self._armor_data.total * 10)
	end
end)

function HUDTeammate:set_invulnerable(state)
	self._wfhud_panel:health_bar():set_invulnerable(state)
end

Hooks:PostHook(HUDTeammate, "set_condition", "set_condition_wfhud", function (self, icon, text)
	if text and text ~= "" then
		self._wfhud_panel:health_bar():set_health_text(text:upper():gsub("%p", ""), true)
		self._wfhud_panel:health_bar():set_armor_text("", true)
	else
		self._wfhud_panel:health_bar():set_health_text(nil, false)
		self._wfhud_panel:health_bar():set_armor_text(nil, false)
	end
end)

Hooks:PostHook(HUDTeammate, "set_weapon_selected", "set_weapon_selected_wfhud", function (self, index)
	if self._main_player and managers.player:local_player() then
		WFHud.equipment_panel:set_weapon(index)
	end
end)

Hooks:PostHook(HUDTeammate, "set_weapon_firemode", "set_weapon_firemode_wfhud", function (self)
	if self._main_player and managers.player:local_player() then
		WFHud.equipment_panel:set_fire_mode()
	end
end)

Hooks:PostHook(HUDTeammate, "set_ammo_amount_by_type", "set_ammo_amount_by_type_wfhud", function (self)
	if self._main_player and managers.player:local_player() then
		WFHud.equipment_panel:set_ammo()
	end
end)


-- pickup items
Hooks:PostHook(HUDTeammate, "add_special_equipment", "add_special_equipment_wfhud", function (self, data)
	local item_list = self._main_player and WFHud.equipment_panel._item_list or self._wfhud_item_list
	if item_list then
		item_list:add_icon(data.id, tweak_data.hud_icons:get_icon_data(data.icon))
		if data.amount then
			item_list:set_icon_value(data.id, data.amount > 1 and data.amount)
		end
	end
end)

Hooks:PostHook(HUDTeammate, "remove_special_equipment", "remove_special_equipment_wfhud", function (self, equipment)
	local item_list = self._main_player and WFHud.equipment_panel._item_list or self._wfhud_item_list
	if item_list then
		item_list:remove_icon(equipment)
	end
end)

Hooks:PostHook(HUDTeammate, "set_special_equipment_amount", "set_special_equipment_amount_wfhud", function (self, equipment_id, amount)
	local item_list = self._main_player and WFHud.equipment_panel._item_list or self._wfhud_item_list
	if item_list then
		item_list:set_icon_value(equipment_id, amount > 1 and amount)
	end
end)


Hooks:PostHook(HUDTeammate, "set_carry_info", "set_carry_info_wfhud", function (self)
	if self._wfhud_item_list then
		self._wfhud_item_list:add_icon("carry_bag", tweak_data.hud_icons:get_icon_data("pd2_loot"))
	end
end)

Hooks:PostHook(HUDTeammate, "remove_carry_info", "remove_carry_info_wfhud", function (self)
	if self._wfhud_item_list then
		self._wfhud_item_list:remove_icon("carry_bag")
	end
end)


-- equipment
Hooks:PostHook(HUDTeammate, "set_deployable_equipment_amount", "set_deployable_equipment_amount_wfhud", function (self, index, data)
	local item_list = self._main_player and WFHud.equipment_panel._equipment_list or WFHud.settings.player_panels.show_deployables and self._wfhud_item_list
	if not item_list then
		return
	end

	if self._main_player or data.amount > 0 then
		item_list:add_icon("equipment1", tweak_data.hud_icons:get_icon_data(data.icon))
		item_list:set_icon_value("equipment1", data.amount > 1 and data.amount)
		item_list:set_icon_enabled("equipment1", data.amount > 0)
	else
		item_list:remove_icon("equipment1")
	end

	if self._main_player then
		WFHud.equipment_panel:_align_equipment()
	end
end)

Hooks:PostHook(HUDTeammate, "set_deployable_equipment_amount_from_string", "set_deployable_equipment_amount_from_string_wfhud", function (self, index, data)
	local item_list = self._main_player and WFHud.equipment_panel._equipment_list or WFHud.settings.player_panels.show_deployables and self._wfhud_item_list
	if not item_list then
		return
	end

	for i, v in ipairs(data.amount) do
		if self._main_player or v > 0 then
			item_list:add_icon("equipment" .. i, tweak_data.hud_icons:get_icon_data(data.icon))
			item_list:set_icon_value("equipment" .. i, v > 1 and v)
			item_list:set_icon_enabled("equipment" .. i, v > 0)
		else
			item_list:remove_icon("equipment" .. i)
		end
	end

	if self._main_player then
		WFHud.equipment_panel:_align_equipment()
	end
end)

Hooks:PostHook(HUDTeammate, "set_grenade_cooldown", "set_grenade_cooldown_wfhud", function (self, data)
	if not self._main_player then
		return
	end

	local grenades_panel = self._player_panel:child("grenades_panel")
	grenades_panel:stop()

	local end_time = data and data.end_time
	if not end_time then
		WFHud.equipment_panel._equipment_list:set_icon_value("grenade", "")
		return
	end

	grenades_panel:animate(function ()
		local duration = end_time - managers.game_play_central:get_heist_timer()
		over(duration, function (t)
			WFHud.equipment_panel._equipment_list:set_icon_value("grenade", math.ceil(duration * (1 - t)))
		end)
	end)

	WFHud.equipment_panel:_align_equipment()
end)

Hooks:PostHook(HUDTeammate, "set_grenades_amount", "set_grenades_amount_wfhud", function (self, data)
	if not self._main_player then
		return
	end

	WFHud.equipment_panel._equipment_list:add_icon("grenade", tweak_data.hud_icons:get_icon_data(data.icon))
	WFHud.equipment_panel._equipment_list:set_icon_value("grenade", data.amount > 1 and data.amount)
	WFHud.equipment_panel._equipment_list:set_icon_enabled("grenade", data.amount > 0)
	WFHud.equipment_panel:_align_equipment()
end)

Hooks:PostHook(HUDTeammate, "set_cable_tie", "set_cable_tie_wfhud", function (self, data)
	if not self._main_player then
		return
	end

	WFHud.equipment_panel._equipment_list:add_icon("cable_ties", tweak_data.hud_icons:get_icon_data(data.icon))
	WFHud.equipment_panel._equipment_list:set_icon_value("cable_ties", data.amount > 1 and data.amount)
	WFHud.equipment_panel._equipment_list:set_icon_enabled("cable_ties", data.amount > 0)
	WFHud.equipment_panel:_align_equipment()
end)

Hooks:PostHook(HUDTeammate, "set_cable_ties_amount", "set_cable_ties_amount_wfhud", function (self, amount)
	if not self._main_player then
		return
	end

	WFHud.equipment_panel._equipment_list:set_icon_value("cable_ties", amount > 1 and amount)
	WFHud.equipment_panel._equipment_list:set_icon_enabled("cable_ties", amount > 0)
	WFHud.equipment_panel:_align_equipment()
end)


Hooks:PreHook(HUDTeammate, "set_delayed_damage", "set_delayed_damage_wfhud", function (self, damage)
	if not self._main_player then
		return
	end

	if damage > 0 then
		local duration = (not self._delayed_damage or damage > self._delayed_damage) and tweak_data.upgrades.values.player.damage_control_auto_shrug[1]
		WFHud:add_buff("player", "stoic_dot", math.ceil(damage * 10), duration)
	else
		WFHud:remove_buff("player", "stoic_dot")
	end
end)


Hooks:PostHook(HUDTeammate, "set_revives_amount", "set_revives_amount_wfhud", function (self, revives)
	revives = WFHud.settings.player_panels.show_downs and revives
	if self._main_player then
		if revives and revives > 0 then
			WFHud:add_buff("game", "downs", revives - 1)
		else
			WFHud:remove_buff("game", "downs")
		end
	elseif self._wfhud_item_list then
		if revives and revives > 0 then
			self._wfhud_item_list:add_icon("downs", WFHud.skill_map.game.downs.texture, WFHud.skill_map.game.downs.texture_rect)
			self._wfhud_item_list:set_icon_value("downs", revives - 1)
		else
			self._wfhud_item_list:remove_icon("downs")
		end
	end
end)


Hooks:PostHook(HUDTeammate, "set_ammo_amount_by_type", "set_ammo_amount_by_type", function (self, type, _, _, total, max)
	if not self._main_player then
		self._wfhud_panel:set_ammo(type, total, max)
	end
end)
