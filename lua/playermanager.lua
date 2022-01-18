local values_swap = {
	armor_break_invulnerable = true
}
local hide_value = {
	armor_break_invulnerable = true
}
Hooks:PostHook(PlayerManager, "activate_temporary_upgrade", "activate_temporary_upgrade_wfhud", function (self, category, upgrade)
	local data = self:upgrade_value(category, upgrade)
	if type(data) == "table" then
		WFHud:add_buff(category, upgrade, not hide_value[upgrade] and (values_swap[upgrade] and data[2] or data[1]), values_swap[upgrade] and data[1] or data[2])
	end
end)
Hooks:PostHook(PlayerManager, "activate_temporary_upgrade_by_level", "activate_temporary_upgrade_by_level_wfhud", function (self, category, upgrade, level)
	local upgrade_level = self:upgrade_level(category, upgrade, 0) or 0
	if level > upgrade_level then
		return
	end
	local data = self:upgrade_value_by_level(category, upgrade, level, 0)
	if type(data) == "table" then
		WFHud:add_buff(category, upgrade, not hide_value[upgrade] and (values_swap[upgrade] and data[2] or data[1]), values_swap[upgrade] and data[1] or data[2])
	end
end)
Hooks:PostHook(PlayerManager, "deactivate_temporary_upgrade", "deactivate_temporary_upgrade_wfhud", function (self, category, upgrade)
	WFHud:remove_buff(category, upgrade)
end)


Hooks:PostHook(PlayerManager, "aquire_upgrade", "aquire_upgrade_wfhud", function (self, upgrade)
	WFHud:add_buff(upgrade.category, upgrade.upgrade, upgrade.value)
end)
Hooks:PostHook(PlayerManager, "unaquire_upgrade", "unaquire_upgrade_wfhud", function (self, upgrade)
	WFHud:remove_buff(upgrade.category, upgrade.upgrade)
end)
Hooks:PostHook(PlayerManager, "aquire_team_upgrade", "aquire_team_upgrade_wfhud", function (self, upgrade)
	WFHud:add_buff(upgrade.category, upgrade.upgrade, upgrade.value)
end)
Hooks:PostHook(PlayerManager, "unaquire_team_upgrade", "unaquire_team_upgrade_wfhud", function (self, upgrade)
	WFHud:remove_buff(upgrade.category, upgrade.upgrade)
end)


Hooks:PostHook(PlayerManager, "set_synced_cocaine_stacks", "set_synced_cocaine_stacks_wfhud", function (self)
	local absorption = self:get_best_cocaine_damage_absorption(managers.network:session():local_peer():id())
	if absorption > 0 then
		WFHud:add_buff("player", "cocaine_stacking", WFHud.value_format.damage(absorption))
	else
		WFHud:remove_buff("player", "cocaine_stacking")
	end
end)


Hooks:PostHook(PlayerManager, "set_damage_absorption", "set_damage_absorption_wfhud", function (self, key, value)
	if value > 0 then
		WFHud:add_buff("damage", key, WFHud.value_format.damage(value))
	else
		WFHud:remove_buff("damage", key)
	end
end)


Hooks:PostHook(PlayerManager, "_on_enemy_killed_bloodthirst", "_on_enemy_killed_bloodthirst_wfhud", function (self, equipped_unit, variant)
	if variant == "melee" then
		local data = self:upgrade_value("player", "melee_kill_increase_reload_speed", 0)
		if data and type(data) ~= "number" then
			WFHud:add_buff("player", "melee_kill_increase_reload_speed", WFHud.value_format.percentage_mul(data[1]), data[2])
		end
	end
end)
Hooks:PostHook(PlayerManager, "set_melee_dmg_multiplier", "set_melee_dmg_multiplier_wfhud", function (self, value)
	if value > 1 then
		WFHud:add_buff("player", "melee_damage_stacking", WFHud.value_format.percentage_mul(value))
	end
end)
Hooks:PostHook(PlayerManager, "reset_melee_dmg_multiplier", "reset_melee_dmg_multiplier_wfhud", function (self)
	WFHud:remove_buff("player", "melee_damage_stacking")
end)


Hooks:PostHook(PlayerManager, "_dodge_shot_gain", "_dodge_shot_gain_wfhud", function (self, value)
	if not value then
		return
	end
	if value > 0 then
		WFHud:add_buff("player", "dodge_shot_gain", WFHud.value_format.percentage(value))
	else
		WFHud:remove_buff("player", "dodge_shot_gain")
	end
end)


local property_mapping = {
	desperado = {
		category = "pistol",
		upgrade = "stacked_accuracy_bonus",
		value_function = WFHud.value_format.percentage_mul,
		time_key = "max_time"
	},
	trigger_happy = {
		category = "pistol",
		upgrade = "stacking_hit_damage_multiplier",
		value_function = WFHud.value_format.percentage_mul,
		time_key = "max_time"
	},
	shock_and_awe_reload_multiplier = {
		category = "player",
		upgrade = "automatic_faster_reload",
		value_function = WFHud.value_format.percentage_mul
	},
	revive_damage_reduction = {
		category = "player",
		upgrade = "revive_damage_reduction",
		value_function = WFHud.value_format.percentage_mul
	},
	revived_damage_reduction = {
		category = "temporary",
		upgrade = "revive_damage_reduction",
		value_function = WFHud.value_format.percentage_mul,
		time_key = 2
	}
}
local function check_property(pm, name)
	local mapping = property_mapping[name]
	if not mapping then
		return
	end
	local val = pm:get_property(name) or pm:get_temporary_property(name)
	if val then
		local data = pm:upgrade_value(mapping.category, mapping.upgrade)
		local value_function = mapping.value_function or WFHud.value_format.default
		WFHud:add_buff(mapping.category, mapping.upgrade, value_function(val), type(data) =="table" and data[mapping.time_key])
	else
		WFHud:remove_buff(mapping.category, mapping.upgrade)
	end
end
Hooks:PostHook(PlayerManager, "add_to_property", "add_to_property_wfhud", check_property)
Hooks:PostHook(PlayerManager, "mul_to_property", "mul_to_property_wfhud", check_property)
Hooks:PostHook(PlayerManager, "remove_property", "remove_property_wfhud", check_property)
Hooks:PostHook(PlayerManager, "set_property", "set_property_wfhud", check_property)
Hooks:PostHook(PlayerManager, "activate_temporary_property", "activate_temporary_property_wfhud", check_property)
Hooks:PostHook(PlayerManager, "add_to_temporary_property", "add_to_temporary_property_wfhud", check_property)


local check_hostage_buffs = function ()	WFHud:check_hostage_buffs() end
Hooks:PostHook(PlayerManager, "count_up_player_minions", "count_up_player_minions_wfhud", check_hostage_buffs)
Hooks:PostHook(PlayerManager, "count_down_player_minions", "count_down_player_minions_wfhud", check_hostage_buffs)


Hooks:PostHook(PlayerManager, "on_damage_dealt", "on_damage_dealt_wfhud", function (self, unit, attack_data)
	if type(attack_data.damage) ~= "number" or attack_data.damage <= 0 or attack_data.is_fire_dot_damage then
		return
	end

	WFHud:add_damage_pop(unit, attack_data)
end)
