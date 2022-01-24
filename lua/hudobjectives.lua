Hooks:PostHook(HUDObjectives, "init", "init_wfhud", function (self)
	local objective_panel = self._hud_panel:child("objectives_panel")
	objective_panel:hide()
	objective_panel:set_alpha(0)
end)

Hooks:OverrideFunction(HUDObjectives, "activate_objective", function (self, data)
	self._active_objective_id = data.id

	WFHud._objective_panel:set_objective(data.text:upper())
	if data.amount then
		WFHud._objective_panel:set_objective_detail(managers.localization:to_upper_text("hud_objectives_completed", { CURRENT = data.current_amount or 0, TOTAL = data.amount }))
	elseif not managers.skirmish:is_skirmish() then
		WFHud._objective_panel:set_objective_detail(nil)
	end
end)

Hooks:OverrideFunction(HUDObjectives, "complete_objective", function (self, data)
	if self._active_objective_id ~= data.id then
		return
	end

	WFHud._objective_panel:set_objective(nil)
	if not managers.skirmish:is_skirmish() then
		WFHud._objective_panel:set_objective_detail(nil)
	end
end)

Hooks:OverrideFunction(HUDObjectives, "update_amount_objective", function (self, data)
	if self._active_objective_id ~= data.id then
		return
	end

	if data.amount then
		WFHud._objective_panel:set_objective_detail(managers.localization:to_upper_text("hud_objectives_completed", { CURRENT = data.current_amount, TOTAL = data.amount }))
	elseif not managers.skirmish:is_skirmish() then
		WFHud._objective_panel:set_objective_detail(nil)
	end
end)
