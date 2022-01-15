Hooks:PostHook(PlayerDamage, "set_health", "set_health_wfhud", function (self, health)
	local pm = managers.player
	local health_ratio = self:health_ratio()
	local damage_health_ratio = pm:get_damage_health_ratio(health_ratio, "melee")

	local mul = pm:upgrade_value("player", "melee_damage_health_ratio_multiplier", 0) * damage_health_ratio
	if mul > 0 then
		WFHud:add_buff("player", "melee_damage_health_ratio_multiplier", WFHud.value_format.percentage(mul))
	else
		WFHud:remove_buff("player", "melee_damage_health_ratio_multiplier")
	end

	mul = pm:upgrade_value("player", "damage_health_ratio_multiplier", 0) * damage_health_ratio
	if mul > 0 then
		WFHud:add_buff("player", "damage_health_ratio_multiplier", WFHud.value_format.percentage(mul))
	else
		WFHud:remove_buff("player", "damage_health_ratio_multiplier")
	end
end)


Hooks:PostHook(PlayerDamage, "delay_damage", "delay_damage_wfhud", function (self)
	WFHud:add_buff("player", "stoic_dot", nil, tweak_data.upgrades.values.player.damage_control_auto_shrug[1])
end)

Hooks:PostHook(PlayerDamage, "clear_delayed_damage", "clear_delayed_damage_wfhud", function (self)
	WFHud:remove_buff("player", "stoic_dot")
end)
