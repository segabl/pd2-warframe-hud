ECMJammerBase.ACTIVE_FEEDBACK = 0

Hooks:PreHook(ECMJammerBase, "set_active", "set_active_wfhud", function (self, active)
	if self._jammer_active == active then
		return
	end

	if active then
		WFHud:add_buff("game", "ecm_jammer", nil, self._battery_life)
	else
		WFHud:remove_buff("game", "ecm_jammer")
	end
end)

local _set_feedback_active_original = ECMJammerBase._set_feedback_active
function ECMJammerBase:_set_feedback_active(state, ...)
	local was_active = self._feedback_active

	_set_feedback_active_original(self, state, ...)

	if was_active == self._feedback_active then
		return
	end

	if state then
		ECMJammerBase.ACTIVE_FEEDBACK = ECMJammerBase.ACTIVE_FEEDBACK + 1
		WFHud:add_buff("game", "ecm_feedback", nil, self._feedback_duration)
	else
		ECMJammerBase.ACTIVE_FEEDBACK = math.max(ECMJammerBase.ACTIVE_FEEDBACK - 1, 0)
		if ECMJammerBase.ACTIVE_FEEDBACK <= 0 then
			WFHud:remove_buff("game", "ecm_feedback")
		end
	end
end
