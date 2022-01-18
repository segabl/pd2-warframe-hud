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


Hooks:PostHook(PlayerDamage, "add_armor_stored_health", "add_armor_stored_health_wfhud", function (self)
	WFHud:add_buff("player", "armor_health_store_amount", WFHud.value_format.default(self._armor_stored_health * 10))
end)

Hooks:PostHook(PlayerDamage, "clear_armor_stored_health", "clear_armor_stored_health_wfhud", function ()
	WFHud:remove_buff("player", "armor_health_store_amount")
end)


-- why would you update the armor hud every frame?
function PlayerDamage:_update_armor_hud(t, dt)
	if self._hurt_value then
		self._hurt_value = math.min(1, self._hurt_value + dt)
	end
end

Hooks:PostHook(PlayerDamage, "set_armor", "set_armor_wfhud", function (self)
	managers.hud:set_player_armor({
		current = self:get_real_armor(),
		total = self:_max_armor()
	})
end)
