Hooks:PostHook(GroupAIStateBase, "sync_hostage_headcount", "sync_hostage_headcount_wfhud", function ()
	WFHud:check_hostage_buffs()
end)

Hooks:PostHook(GroupAIStateBase, "set_unit_teamAI", "set_unit_teamAI_wfhud", function (self, unit)
	unit:character_damage():_set_hud_panel_hp()
end)


Hooks:PostHook(GroupAIStateBase, "on_enemy_registered", "on_enemy_registered_wfhud", function (self, unit)
	local tweak_table = unit:base()._tweak_table
	if tweak_table:find("boss") and not tweak_table:find("stealth") and not tweak_table:find("no_armor") then
		WFHud._boss_bar:set_unit(unit)
	end
end)
