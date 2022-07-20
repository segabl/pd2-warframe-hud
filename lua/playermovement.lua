Hooks:PostHook(PlayerMovement, "on_morale_boost", "on_morale_boost_wfhud", function (self)
	WFHud:add_buff("player", "morale_boost", nil, tweak_data.upgrades.morale_boost_time)
end)
