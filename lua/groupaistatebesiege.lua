Hooks:OverrideFunction(GroupAIStateBesiege, "set_damage_reduction_buff_hud", function (self)
	local law1team = self._teams and self:_get_law1_team()
	if law1team then
		WFHud.objective_panel:set_vip(law1team.damage_reduction and math.round(law1team.damage_reduction * 100))
	end
end)

Hooks:PostHook(GroupAIStateBesiege, "set_assault_endless", "set_assault_endless_wfhud", function (self, enabled)
	local law1team = self._teams and self:_get_law1_team()
	if law1team then
		WFHud.objective_panel:set_vip(enabled and math.round((law1team.damage_reduction or 0) * 100))
	end
end)
