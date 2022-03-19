Hooks:PostHook(HUDTemp, "init", "init_wfhud", function (self)
	if not self._hud_panel then
		return
	end

	self._hud_panel:child("temp_panel"):set_alpha(0)
	self._hud_panel:child("temp_panel"):hide()
end)

Hooks:OverrideFunction(HUDTemp, "show_carry_bag", function (self, carry_id, value)
	local carry_data = tweak_data.carry[carry_id]
	WFHud.equipment_panel:set_bag(managers.localization:to_upper_text(carry_data and carry_data.name_id))
end)

Hooks:OverrideFunction(HUDTemp, "hide_carry_bag", function (self)
	WFHud.equipment_panel:set_bag(nil)
end)

Hooks:OverrideFunction(HUDTemp, "set_throw_bag_text", function (self) end)

Hooks:OverrideFunction(HUDTemp, "set_stamina_value", function (self, value)
	self._curr_stamina = value
	WFHud.equipment_panel:set_stamina(self._curr_stamina, self._max_stamina)
end)

Hooks:OverrideFunction(HUDTemp, "set_max_stamina", function (self, value)
	self._max_stamina = value
	WFHud.equipment_panel:set_stamina(self._curr_stamina, self._max_stamina)
end)
