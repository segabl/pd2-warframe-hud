Hooks:PostHook(HUDTeammate, "init", "init_wfhud", function (self, i, teammates_panel, is_player, width)
	self._wfhud_panel = HUDPlayerPanel:new(WFHud:panel(), self._main_player)
	self._wfhud_panel._panel:set_visible(false)

	if self._main_player then
		self._wfhud_panel._panel:set_righttop(WFHud:panel():w() - WFHud.MARGIN_H, WFHud.MARGIN_V)
	else
		self._wfhud_panel._panel:set_righttop(WFHud:panel():w() - WFHud.MARGIN_H, WFHud.MARGIN_V + 88 + (i - 1) * (self._wfhud_panel._panel:h() + 4))

		self._wfhud_item_list = HUDIconList:new(WFHud:panel(), 0, self._wfhud_panel._panel:y(), WFHud:panel():w() - 200, 24, WFHud.colors.buff)
		self._wfhud_item_list._panel:set_visible(false)
	end
end)

Hooks:PostHook(HUDTeammate, "add_panel", "add_panel_wfhud", function (self)
	self._panel:set_visible(false)

	self._wfhud_panel._panel:set_visible(true)

	if self._main_player then
		if managers.player:local_player() then
			managers.player:local_player():movement():_change_stamina(0) -- ugh
		end
	end

	if self._wfhud_item_list then
		self._wfhud_item_list._panel:set_visible(true)
	end
end)

Hooks:PostHook(HUDTeammate, "remove_panel", "remove_panel_wfhud", function (self)
	self._health_set = nil
	self._armor_set = nil

	self._wfhud_panel._panel:set_visible(false)
	self._wfhud_panel:health_bar()._set_data_instant = true

	if self._main_player then
		WFHud._equipment_panel._item_list._panel:clear()
	else
		self._wfhud_item_list._panel:set_visible(false)
		self._wfhud_item_list._panel:clear()
	end
end)

Hooks:PostHook(HUDTeammate, "set_waiting", "set_waiting_wfhud", function (self)
	self._panel:set_visible(false)
end)

Hooks:PostHook(HUDTeammate, "set_name", "set_name_wfhud", function (self, name)
	self._wfhud_panel:set_name(name)
end)

Hooks:PostHook(HUDTeammate, "set_callsign", "set_callsign_wfhud", function (self, id)
	self._wfhud_panel:set_peer_id(id)
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
	if not self._main_player or not managers.player:local_player() then
		return
	end

	self._weapon_index = index

	local unit = managers.player:local_player():inventory():unit_by_selection(self._weapon_index)
	if unit then
		WFHud._equipment_panel:set_weapon(unit:base())
	end
end)

Hooks:PostHook(HUDTeammate, "set_weapon_firemode", "set_weapon_firemode_wfhud", function (self)
	if not self._main_player or not managers.player:local_player() then
		return
	end

	local unit = managers.player:local_player():inventory():unit_by_selection(self._weapon_index)
	if unit then
		WFHud._equipment_panel:set_fire_mode(unit:base())
	end
end)

Hooks:PostHook(HUDTeammate, "set_ammo_amount_by_type", "set_ammo_amount_by_type_wfhud", function (self)
	if not self._main_player or not managers.player:local_player() then
		return
	end

	local unit = managers.player:local_player():inventory():unit_by_selection(self._weapon_index)
	if unit then
		WFHud._equipment_panel:set_ammo(unit:base())
	end
end)


-- pickup items
Hooks:PostHook(HUDTeammate, "add_special_equipment", "add_special_equipment_wfhud", function (self, data)
	local item_list = self._main_player and WFHud._equipment_panel._item_list or self._wfhud_item_list
	if item_list then
		item_list:add_icon(data.id, tweak_data.hud_icons:get_icon_data(data.icon))
		if data.amount then
			item_list:set_icon_value(data.id, data.amount > 1 and data.amount)
		end
	end
end)

Hooks:PostHook(HUDTeammate, "remove_special_equipment", "remove_special_equipment_wfhud", function (self, equipment)
	local item_list = self._main_player and WFHud._equipment_panel._item_list or self._wfhud_item_list
	if item_list then
		item_list:remove_icon(equipment)
	end
end)

Hooks:PostHook(HUDTeammate, "set_special_equipment_amount", "set_special_equipment_amount_wfhud", function (self, equipment_id, amount)
	local item_list = self._main_player and WFHud._equipment_panel._item_list or self._wfhud_item_list
	if item_list then
		item_list:set_icon_value(equipment_id, amount > 1 and amount)
	end
end)


-- equipment
Hooks:PostHook(HUDTeammate, "set_deployable_equipment_amount", "set_deployable_equipment_amount_wfhud", function (self, index, data)
	if not self._main_player then
		return
	end

	WFHud._equipment_panel._equipment_list:add_icon("equipment", tweak_data.hud_icons:get_icon_data(data.icon))
	WFHud._equipment_panel._equipment_list:set_icon_value("equipment", data.amount > 1 and data.amount)
	WFHud._equipment_panel._equipment_list:set_icon_enabled("equipment", data.amount > 0)
	WFHud._equipment_panel:_align_equipment()
end)

Hooks:PostHook(HUDTeammate, "set_deployable_equipment_amount_from_string", "set_deployable_equipment_amount_from_string_wfhud", function (self, index, data)
	if not self._main_player then
		return
	end

	WFHud._equipment_panel._equipment_list:add_icon("equipment", tweak_data.hud_icons:get_icon_data(data.icon))
	WFHud._equipment_panel._equipment_list:set_icon_value("equipment", table.concat(data.amount, "|"))
	WFHud._equipment_panel._equipment_list:set_icon_enabled("equipment", table.inject(data.amount, 0, function (a, b) return a + b end) > 0)
	WFHud._equipment_panel:_align_equipment()
end)

Hooks:PostHook(HUDTeammate, "set_grenade_cooldown", "set_grenade_cooldown_wfhud", function (self, data)
	if not self._main_player then
		return
	end

	local grenades_panel = self._player_panel:child("grenades_panel")
	grenades_panel:stop()

	local end_time = data and data.end_time
	if not end_time then
		WFHud._equipment_panel._equipment_list:set_icon_value("grenade", "")
		WFHud._equipment_panel._equipment_list:set_icon_enabled("grenade", true)
		return
	end

	WFHud._equipment_panel._equipment_list:set_icon_enabled("grenade", false)
	grenades_panel:animate(function ()
		local duration = end_time - managers.game_play_central:get_heist_timer()
		over(duration, function (t)
			WFHud._equipment_panel._equipment_list:set_icon_value("grenade", math.ceil(duration * (1 - t)))
		end)
	end)

	WFHud._equipment_panel:_align_equipment()
end)

Hooks:PostHook(HUDTeammate, "set_grenades_amount", "set_grenades_amount_wfhud", function (self, data)
	if not self._main_player then
		return
	end

	WFHud._equipment_panel._equipment_list:add_icon("grenade", tweak_data.hud_icons:get_icon_data(data.icon))
	WFHud._equipment_panel._equipment_list:set_icon_value("grenade", data.amount > 1 and data.amount)
	WFHud._equipment_panel._equipment_list:set_icon_enabled("grenade", data.amount > 0)
	WFHud._equipment_panel:_align_equipment()
end)

Hooks:PostHook(HUDTeammate, "set_cable_tie", "set_cable_tie_wfhud", function (self, data)
	if not self._main_player then
		return
	end

	WFHud._equipment_panel._equipment_list:add_icon("cable_ties", tweak_data.hud_icons:get_icon_data(data.icon))
	WFHud._equipment_panel._equipment_list:set_icon_value("cable_ties", data.amount > 1 and data.amount)
	WFHud._equipment_panel._equipment_list:set_icon_enabled("cable_ties", data.amount > 0)
	WFHud._equipment_panel:_align_equipment()
end)

Hooks:PostHook(HUDTeammate, "set_cable_ties_amount", "set_cable_ties_amount_wfhud", function (self, amount)
	if not self._main_player then
		return
	end

	WFHud._equipment_panel._equipment_list:set_icon_value("cable_ties", amount > 1 and amount)
	WFHud._equipment_panel._equipment_list:set_icon_enabled("cable_ties", amount > 0)
	WFHud._equipment_panel:_align_equipment()
end)
