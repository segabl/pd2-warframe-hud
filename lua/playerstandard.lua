Hooks:PostHook(PlayerStandard, "_start_action_interact", "_start_action_interact_wfhud", function (self)
	local mul = managers.player:upgrade_value("player", "interacting_damage_multiplier", 1)
	if mul ~= 1 then
		WFHud:add_buff("player", "interacting_damage_multiplier", mul)
	end
end)

Hooks:PostHook(PlayerStandard, "_interupt_action_interact", "_interupt_action_interact_wfhud", function (self)
	WFHud:remove_buff("player", "interacting_damage_multiplier")
end)

Hooks:PostHook(PlayerStandard, "_do_melee_damage", "_do_melee_damage_wfhud", function (self, t)
	local stack = self._state_data.stacking_dmg_mul and self._state_data.stacking_dmg_mul.melee
	if stack and stack[1] and stack[2] then
		local mul = managers.player:upgrade_value("melee", "stacking_hit_damage_multiplier", 0) * stack[2]
		WFHud:add_buff("melee", "stacking_hit_damage_multiplier", WFHud.value_format.percentage(mul), stack[1] - t)
	end
end)
