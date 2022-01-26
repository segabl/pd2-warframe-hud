local skill_checks = {
	"melee_damage_health_ratio_multiplier", -- berserker
	"damage_health_ratio_multiplier", -- berserker
	"armor_regen_damage_health_ratio_multiplier", -- yakuza
	"movement_speed_damage_health_ratio_multiplier" -- yakuza
}
Hooks:PostHook(PlayerDamage, "set_health", "set_health_wfhud", function (self, health)
	local pm = managers.player
	local health_ratio = self:health_ratio()
	local damage_health_ratio = pm:get_damage_health_ratio(health_ratio, "melee")

	for _, v in pairs(skill_checks) do
		local mul = pm:upgrade_value("player", v, 0) * damage_health_ratio
		if mul > 0 then
			WFHud:add_buff("player", v, WFHud.value_format.percentage(mul))
		else
			WFHud:remove_buff("player", v)
		end
	end

	-- leech remaining hits
	if pm:has_activate_temporary_upgrade("temporary", "copr_ability") then
		local max_health = self:_max_health() * self._max_health_reduction
		local health_chunk = max_health * pm:upgrade_value("player", "copr_static_damage_ratio", 0)
		WFHud:add_buff("temporary", "copr_ability", math.max(0, math.ceil(math.min(health, max_health) / health_chunk)))
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
function PlayerDamage:_update_armor_hud(t, dt) end

Hooks:PostHook(PlayerDamage, "set_armor", "set_armor_wfhud", function (self)
	managers.hud:set_player_armor({
		current = self:get_real_armor(),
		total = self:_max_armor()
	})
end)


-- grinder heal over time
Hooks:PostHook(PlayerDamage, "add_damage_to_hot", "add_damage_to_hot_wfhud", function (self)
	local hot = self._damage_to_hot_stack[#self._damage_to_hot_stack]
	local duration = hot.next_tick - TimerManager:game():time() + (self._doh_data.tick_time or 1) * (hot.ticks_left - 1)
	WFHud:add_buff("player", "damage_to_hot", nil, duration)
end)
