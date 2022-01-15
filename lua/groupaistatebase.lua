local categories = { "speed", "stamina", "critical_hit", "damage_dampener", "health", "armor" }
local function check_hostage_buffs(gstate)
	local mul
	local pm = managers.player
	local minions = pm:num_local_minions() or 0
	local hostages_total = gstate._hostage_headcount + minions
	local hostage_max_num
	for _, v in pairs(categories) do
		hostage_max_num = math.min(hostages_total, tweak_data:get_raw_value("upgrades", "hostage_max_num", v) or hostages_total)

		-- Multiplier bonuses
		mul = 1 + (pm:team_upgrade_value(v, "hostage_multiplier", 1) - 1) * hostage_max_num
		if mul ~= 1 then
			WFHud:add_buff(v, "hostage_multiplier", WFHud.value_format.percentage_mul(mul))
		else
			WFHud:remove_buff(v, "hostage_multiplier")
		end

		mul = 1 + (pm:team_upgrade_value(v, "passive_hostage_multiplier", 1) - 1) * hostage_max_num
		if mul ~= 1 then
			WFHud:add_buff(v, "passive_hostage_multiplier", WFHud.value_format.percentage_mul(mul))
		else
			WFHud:remove_buff(v, "passive_hostage_multiplier")
		end

		mul = 1 + (pm:upgrade_value("player", "hostage_" .. v .. "_multiplier", 1) - 1) * hostage_max_num
		if mul ~= 1 then
			WFHud:add_buff("player", "hostage_" .. v .. "_multiplier", WFHud.value_format.percentage_mul(mul))
		else
			WFHud:remove_buff("player", "hostage_" .. v .. "_multiplier")
		end

		mul = 1 + (pm:upgrade_value("player", "passive_hostage_" .. v .. "_multiplier", 1) - 1) * hostage_max_num
		if mul ~= 1 then
			WFHud:add_buff("player", "passive_hostage_" .. v .. "_multiplier", WFHud.value_format.percentage_mul(mul))
		else
			WFHud:remove_buff("player", "passive_hostage_" .. v .. "_multiplier")
		end

		-- Additive bonuses
		mul = pm:team_upgrade_value(v, "hostage_addend", 0) * hostage_max_num
		if mul ~= 0 then
			WFHud:add_buff(v, "hostage_addend", mul)
		else
			WFHud:remove_buff(v, "hostage_addend")
		end

		mul = pm:team_upgrade_value(v, "passive_hostage_addend", 0) * hostage_max_num
		if mul ~= 0 then
			WFHud:add_buff(v, "passive_hostage_addend", mul)
		else
			WFHud:remove_buff(v, "passive_hostage_addend")
		end

		mul = pm:upgrade_value("player", "hostage_" .. v .. "_addend", 0) * hostage_max_num
		if mul ~= 0 then
			WFHud:add_buff("player", "hostage_" .. v .. "_addend", mul)
		else
			WFHud:remove_buff("player", "hostage_" .. v .. "_addend")
		end

		mul = pm:upgrade_value("player", "passive_hostage_" .. v .. "_addend", 0) * hostage_max_num
		if mul ~= 0 then
			WFHud:add_buff("player", "passive_hostage_" .. v .. "_addend", mul)
		else
			WFHud:remove_buff("player", "passive_hostage_" .. v .. "_addend")
		end
	end

	if minions > 0 then
		mul = pm:upgrade_value("player", "minion_master_speed_multiplier", 1)
		if mul > 1 then
			WFHud:add_buff("player", "minion_master_speed_multiplier", WFHud.value_format.percentage_mul(mul))
		end
		mul = pm:upgrade_value("player", "minion_master_health_multiplier", 1)
		if mul > 1 then
			WFHud:add_buff("player", "minion_master_health_multiplier", WFHud.value_format.percentage_mul(mul))
		end
	else
		WFHud:remove_buff("player", "minion_master_speed_multiplier")
		WFHud:remove_buff("player", "minion_master_health_multiplier")
	end

end

Hooks:PostHook(GroupAIStateBase, "sync_hostage_headcount", "sync_hostage_headcount_wfhud", check_hostage_buffs)
Hooks:PostHook(GroupAIStateBase, "sync_converted_enemy", "sync_converted_enemy_wfhud", check_hostage_buffs)
Hooks:PostHook(GroupAIStateBase, "convert_hostage_to_criminal", "convert_hostage_to_criminal_wfhud", check_hostage_buffs)
Hooks:PostHook(GroupAIStateBase, "remove_minion", "remove_minion_wfhud", check_hostage_buffs)


Hooks:PostHook(GroupAIStateBase, "set_unit_teamAI", "set_unit_teamAI_wfhud", function (self, unit)
	unit:character_damage():_set_hud_panel_hp()
end)
