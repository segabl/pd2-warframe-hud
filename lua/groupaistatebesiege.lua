Hooks:OverrideFunction(GroupAIStateBesiege, "set_damage_reduction_buff_hud", function (self)
	local law1team = self:_get_law1_team()
	if law1team then
		WFHud._objective_panel:set_vip(law1team.damage_reduction and math.round(law1team.damage_reduction * 100))
	end
end)
