ElementAreaTrigger.ACTIVE_ESCAPES = 0

local function check_executed_objects(area_trigger, current, recursion_depth)
	current = current or area_trigger
	recursion_depth = recursion_depth or 2

	for _, params in pairs(current._values.on_executed) do
		local element = current:get_mission_element(params.id)
		local element_class = getmetatable(element)
		if element_class == ElementMissionEnd then
			if area_trigger._values.enabled then
				ElementAreaTrigger.ACTIVE_ESCAPES = ElementAreaTrigger.ACTIVE_ESCAPES + 1
				WFHud._objective_panel:set_icon("extract")
			else
				ElementAreaTrigger.ACTIVE_ESCAPES = ElementAreaTrigger.ACTIVE_ESCAPES - 1
				if ElementAreaTrigger.ACTIVE_ESCAPES <= 0 then
					WFHud._objective_panel:set_icon(nil)
				end
			end
			return true
		elseif element_class == MissionScriptElement and recursion_depth > 0 then
			if check_executed_objects(area_trigger, element, recursion_depth - 1) then
				return true
			end
		end
	end
end

Hooks:PostHook(ElementAreaTrigger, "on_set_enabled", "on_set_enabled_wfhud", check_executed_objects)
