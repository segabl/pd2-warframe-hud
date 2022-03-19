Hooks:PostHook(HUDObjectives, "init", "init_wfhud", function (self)
	if not self._hud_panel then
		return
	end

	local objective_panel = self._hud_panel:child("objectives_panel")
	objective_panel:hide()
	objective_panel:set_alpha(0)
end)

local function set_objective_detail(data)
	if data.amount then
		if data.id == "heist_chill2" then
			WFHud.objective_panel:set_objective_detail(managers.localization:to_upper_text("hud_bags_remaining", { NUM = data.current_amount }))
		else
			WFHud.objective_panel:set_objective_detail(managers.localization:to_upper_text("hud_objectives_completed", { CURRENT = data.current_amount or 0, TOTAL = data.amount }))
		end
	else
		WFHud.objective_panel:set_objective_detail(nil)
	end
end

local obj_id_icons = {
	heist_chill2 = "defend",
	hud_skm_1 = "defend"
}

Hooks:OverrideFunction(HUDObjectives, "activate_objective", function (self, data)
	self._active_objective_id = data.id

	WFHud.objective_panel:set_icon(ElementAreaTrigger.ACTIVE_ESCAPES > 0 and "extract" or obj_id_icons[data.id])
	WFHud.objective_panel:set_objective(data.id == "heist_chill2" and managers.localization:to_upper_text("hud_objectives_protect_bags") or data.text:upper())

	set_objective_detail(data)
end)

Hooks:OverrideFunction(HUDObjectives, "update_amount_objective", function (self, data)
	if self._active_objective_id ~= data.id then
		return
	end

	set_objective_detail(data)
end)

Hooks:OverrideFunction(HUDObjectives, "complete_objective", function (self, data)
	if self._active_objective_id ~= data.id then
		return
	end

	WFHud.objective_panel:set_objective(nil)
	WFHud.objective_panel:set_objective_detail(nil)
end)
