Hooks:PostHook(PlayerInventory, "_start_jammer_effect", "_start_jammer_effect_wfhud", function (self)
	if self._jammer_data then
		WFHud:add_buff("player", "pocket_ecm_jammer_base", nil, self._jammer_data.t - TimerManager:game():time())
	end
end)

Hooks:PostHook(PlayerInventory, "_start_feedback_effect", "_start_feedback_effect_wfhud", function (self)
	if self._jammer_data then
		WFHud:add_buff("player", "pocket_ecm_jammer_base", nil, self._jammer_data.t - TimerManager:game():time())
	end
end)
