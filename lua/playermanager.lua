local values_swap = {
	armor_break_invulnerable = true
}
local hide_value = {
	armor_break_invulnerable = true
}
local function set_invulnerable(state)
	local teammate_panel = managers.hud and managers.hud:get_teammate_panel_by_peer()
	if teammate_panel then
		teammate_panel:set_invulnerable(state)
	end
end
Hooks:PostHook(PlayerManager, "activate_temporary_upgrade", "activate_temporary_upgrade_wfhud", function (self, category, upgrade)
	local data = self:upgrade_value(category, upgrade)
	if type(data) == "table" then
		WFHud:add_buff(category, upgrade, not hide_value[upgrade] and (values_swap[upgrade] and data[2] or data[1]), values_swap[upgrade] and data[1] or data[2])
		-- not the best way but works
		if upgrade == "armor_break_invulnerable" then
			set_invulnerable(true)
			DelayedCalls:Add("wfhud_player_invul_end", data[1], set_invulnerable)
		end
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
		WFHud:add_buff("player", "cocaine_stacking", tostring(math.ceil(absorption * 10)))
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
	if type(attack_data.damage) == "number" then
		WFHud:add_damage_pop(unit, attack_data)
	end
end)


local _attempt_pocket_ecm_jammer_original = PlayerManager._attempt_pocket_ecm_jammer
function PlayerManager:_attempt_pocket_ecm_jammer(...)
	local result = _attempt_pocket_ecm_jammer_original(self, ...)

	if result then
		WFHud:add_buff("player", "pocket_ecm_jammer_base", nil, self:player_unit():inventory():get_jammer_time())
	end

	return result
end


-- tag team duration is basically impossible to figure out thanks to lots of local functions
Hooks:PostHook(PlayerManager, "sync_tag_team", "sync_tag_team_wfhud", function (self, tagged)
	if tagged == self:local_player() then
		WFHud:add_buff("player", "tag_team_base", nil, nil)
	end
end)

Hooks:PostHook(PlayerManager, "end_tag_team", "end_tag_team_wfhud", function (self, tagged)
	if tagged == self:local_player() then
		WFHud:remove_buff("player", "tag_team_base")
	end
end)


Hooks:PreHook(PlayerManager, "add_cable_ties", "add_cable_ties_wfhuf", function (self, amount)
	local equipment = tweak_data.equipments.specials.cable_tie
	local owned_equipment = self._equipment.specials.cable_tie
	local current_amount = owned_equipment and owned_equipment.amount and Application:digest_value(owned_equipment.amount, false) or 0
	local added = math.min(current_amount + amount, equipment.max_quantity) - current_amount
	if added > 0 then
		local texture, texture_rect = WFHud:get_icon_data(equipment.icon)
		WFHud:add_pickup("cable_tie", added, nil, texture, texture_rect)
	end
end)

Hooks:PreHook(PlayerManager, "add_grenade_amount", "add_grenade_amount_wfhud", function (self, amount)
	if amount < 1 then
		return
	end

	local peer_id = managers.network:session():local_peer():id()
	local grenade = self._global.synced_grenades[peer_id].grenade
	local tweak = tweak_data.blackmarket.projectiles[grenade]
	if tweak.base_cooldown then
		return
	end

	local current_amount = Application:digest_value(self._global.synced_grenades[peer_id].amount, false)
	local added = math.min(current_amount + amount, self:get_max_grenades_by_peer_id(peer_id)) - current_amount

	if added > 0 then
		local texture, texture_rect = WFHud:get_icon_data(tweak.icon)
		WFHud:add_pickup(grenade, added, managers.localization:text(tweak.name_id), texture, texture_rect)
	end
end)


Hooks:PreHook(PlayerManager, "add_special", "add_special_wfhud", function (self, params)
	local silent = params.silent
	params.silent = true

	if silent then
		return
	end

	local name = params.equipment or params.name
	local equipment = tweak_data.equipments.specials[name]
	local owned_equipment = self._equipment.specials[name]
	if not equipment then
		return
	end

	local amount = params.amount or equipment.quantity or 1
	local current_amount = owned_equipment and (owned_equipment.amount and Application:digest_value(owned_equipment.amount, false) or 1) or 0
	local max_amount = params.transfer and equipment.transfer_quantity or equipment.max_quantity or equipment.quantity or 1
	local added_amount = math.min(current_amount + amount, max_amount) - current_amount
	if added_amount <= 0 then
		return
	end

	if WFHud.settings.rare_mission_equipment then
		local texture, texture_rect = WFHud:get_icon_data(equipment.icon)
		local text = managers.localization:text(equipment.text_id):pretty(true):gsub("%s+", " ") .. (added_amount > 1 and " x " .. tostring(added_amount) or "")
		WFHud:add_special_pickup(texture, texture_rect, text)
	else
		local texture, texture_rect = tweak_data.hud_icons:get_icon_data(equipment.icon)
		local text = managers.localization:text(equipment.text_id):pretty(true):gsub("%s+", " ")
		WFHud:add_pickup(name, added_amount, text, texture, texture_rect)
	end

	if owned_equipment then
		return
	end

	local action_message = equipment.action_message
	local unit = self:player_unit()
	if action_message and alive(unit) then
		managers.network:session():send_to_peers_synched("sync_show_action_message", unit, action_message)
	end
end)
