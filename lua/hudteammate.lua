Hooks:PostHook(HUDTeammate, "init", "init_wfhud", function (self, i, teammates_panel, is_player, width)
	local main_panel = teammates_panel:parent()

	self._wfhud_panel = HUDPlayerPanel:new(main_panel, self._main_player)
	self._wfhud_panel._panel:set_visible(false)

	if self._main_player then
		self._wfhud_panel._panel:set_righttop(main_panel:w(), 32)

		self._wfhud_equipment_panel = HUDPlayerEquipment:new(main_panel)
		self._wfhud_equipment_panel._panel:set_visible(false)
		self._wfhud_equipment_panel._panel:set_rightbottom(main_panel:w(), main_panel:h())
	else
		self._wfhud_panel._panel:set_righttop(main_panel:w(), 32 + 80 + (i - 1) * (self._wfhud_panel._panel:h() + 4))
	end
end)

Hooks:PostHook(HUDTeammate, "add_panel", "add_panel_wfhud", function (self)
	self._panel:set_visible(false)

	self._wfhud_panel._panel:set_visible(true)
	if self._wfhud_equipment_panel then
		self._wfhud_equipment_panel._panel:set_visible(true)

		if managers.player:local_player() then
			managers.player:local_player():movement():_change_stamina(0) -- ugh
		end
	end
end)

Hooks:PostHook(HUDTeammate, "remove_panel", "remove_panel_wfhud", function (self)
	self._health_set = nil
	self._armor_set = nil

	self._wfhud_panel._panel:set_visible(false)
	self._wfhud_panel:health_bar()._set_data_instant = true

	if self._wfhud_equipment_panel then
		self._wfhud_equipment_panel._panel:set_visible(false)
	end
end)

Hooks:PostHook(HUDTeammate, "set_waiting", "set_waiting_wfhud", function (self)
	self._panel:set_visible(false)
end)

Hooks:PostHook(HUDTeammate, "set_name", "set_name_wfhud", function (self, name)
	if self._main_player then
		local spec = managers.skilltree:get_specialization_value("current_specialization")
		name = string.format("%s [%u]", managers.localization:to_upper_text(tweak_data.skilltree.specializations[spec].name_id), managers.experience:current_level())
	end
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

function HUDTeammate:set_stamina(current, total)
	if not self._wfhud_equipment_panel then
		return
	end

	self._current_stamina = current or self._current_stamina
	self._total_stamina = total or self._total_stamina

	if self._current_stamina and self._total_stamina then
		self._wfhud_equipment_panel:set_stamina(self._current_stamina, self._total_stamina)
	end
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
	if not self._wfhud_equipment_panel or not managers.player:local_player() then
		return
	end

	self._weapon_index = index

	local unit = managers.player:local_player():inventory():unit_by_selection(self._weapon_index)
	if unit then
		self._wfhud_equipment_panel:set_weapon(unit:base())
	end
end)

Hooks:PostHook(HUDTeammate, "set_weapon_firemode", "set_weapon_firemode_wfhud", function (self)
	if not self._wfhud_equipment_panel or not managers.player:local_player() then
		return
	end

	local unit = managers.player:local_player():inventory():unit_by_selection(self._weapon_index)
	if unit then
		self._wfhud_equipment_panel:set_fire_mode(unit:base())
	end
end)

Hooks:PostHook(HUDTeammate, "set_ammo_amount_by_type", "set_ammo_amount_by_type_wfhud", function (self)
	if not self._wfhud_equipment_panel or not managers.player:local_player() then
		return
	end

	local unit = managers.player:local_player():inventory():unit_by_selection(self._weapon_index)
	if unit then
		self._wfhud_equipment_panel:set_ammo(unit:base())
	end
end)
