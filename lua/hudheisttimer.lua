Hooks:PostHook(HUDHeistTimer, "init", "init_wfhud", function (self)
	self._heist_timer_panel:hide()
	self._heist_timer_panel:set_alpha(0)
end)

Hooks:OverrideFunction(HUDHeistTimer, "set_time", function (self, time)
	WFHud.objective_panel:set_time(time)
end)
