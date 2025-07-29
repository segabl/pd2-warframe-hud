ElementAreaTrigger.ACTIVE_ESCAPES = {}

local function check_executed_objects(trigger, current, checked)
	if not current or checked[current] then
		return
	end

	checked[current] = true

	for _, params in pairs(current._values.on_executed) do
		local element = current:get_mission_element(params.id)
		if getmetatable(element) == ElementMissionEnd then
			if trigger._values.enabled then
				return true
			end
		elseif check_executed_objects(trigger, element, checked) then
			return true
		end
	end
end

Hooks:PostHook(ElementAreaTrigger, "on_set_enabled", "on_set_enabled_wfhud", function(self)
	if check_executed_objects(self, self, {}) then
		ElementAreaTrigger.ACTIVE_ESCAPES[self] = true
		WFHud.objective_panel:set_icon("extract")
	else
		ElementAreaTrigger.ACTIVE_ESCAPES[self] = nil
		if not next(ElementAreaTrigger.ACTIVE_ESCAPES) then
			WFHud.objective_panel:set_icon(nil)
		end
	end
end)
