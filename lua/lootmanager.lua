Hooks:OverrideFunction(LootManager, "show_small_loot_taken_hint", function (self, type, multiplier)
	WFHud:add_pickup("money", self:get_real_value(type, multiplier), nil, "guis/textures/wfhud/hud_icons/pickup_money")
end)
