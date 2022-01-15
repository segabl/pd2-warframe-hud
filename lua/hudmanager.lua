Hooks:PostHook(HUDManager, "_setup_player_info_hud_pd2", "_setup_player_info_hud_pd2_wfhud", function (self)
	WFHud:setup(self)
end)

Hooks:PostHook(HUDManager, "update", "update_wfhud", function (self, t, dt)
	WFHud:update(t, dt)
end)


function HUDManager:_add_name_label(data) end
