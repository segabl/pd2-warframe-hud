Hooks:PostHook(PlayerStandard, "_start_action_interact", "_start_action_interact_wfhud", function (self)
	local mul = managers.player:upgrade_value("player", "interacting_damage_multiplier", 1)
	if mul ~= 1 then
		WFHud:add_buff("player", "interacting_damage_multiplier", mul)
	end
end)

Hooks:PostHook(PlayerStandard, "_interupt_action_interact", "_interupt_action_interact_wfhud", function (self)
	WFHud:remove_buff("player", "interacting_damage_multiplier")
end)
