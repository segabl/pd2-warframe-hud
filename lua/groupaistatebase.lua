Hooks:PostHook(GroupAIStateBase, "sync_hostage_headcount", "sync_hostage_headcount_wfhud", function ()
	WFHud:check_hostage_buffs()
end)

Hooks:PostHook(GroupAIStateBase, "set_unit_teamAI", "set_unit_teamAI_wfhud", function (self, unit)
	unit:character_damage():_set_hud_panel_hp()
end)
