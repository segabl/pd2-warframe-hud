function TeamAIDamage:_set_hud_panel_hp()
	if self._panel_id == nil then
		local character_data = managers.criminals:character_data_by_unit(self._unit)
		self._panel_id = character_data and character_data.panel_id or false
	end

	if not self._panel_id then
		return
	end

	managers.hud:set_teammate_health(self._panel_id, {
		current = self._health,
		total = self._HEALTH_INIT,
		max = self._HEALTH_INIT
	})
end

Hooks:PostHook(TeamAIDamage, "_apply_damage", "_apply_damage_wfhud", TeamAIDamage._set_hud_panel_hp)
Hooks:PostHook(TeamAIDamage, "_regenerated", "_regenerated_wfhud", TeamAIDamage._set_hud_panel_hp)
