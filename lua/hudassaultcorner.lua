Hooks:PostHook(HUDAssaultCorner, "init", "init_wfhud", function (self)
	if not self._hud_panel then
		return
	end

	self._hud_panel:child("assault_panel"):set_alpha(0)
	self._hud_panel:child("assault_panel"):hide()
	self._hud_panel:child("hostages_panel"):set_alpha(0)
	self._hud_panel:child("hostages_panel"):hide()
	self._hud_panel:child("casing_panel"):set_alpha(0)
	self._hud_panel:child("casing_panel"):hide()
	self._hud_panel:child("point_of_no_return_panel"):set_alpha(0)
	self._hud_panel:child("point_of_no_return_panel"):hide()
	self._hud_panel:child("buffs_panel"):set_alpha(0)
	self._hud_panel:child("buffs_panel"):hide()
	if self._hud_panel:child("wave_panel") then
		self._hud_panel:child("wave_panel"):set_alpha(0)
		self._hud_panel:child("wave_panel"):hide()
	end
end)

Hooks:OverrideFunction(HUDAssaultCorner, "show_point_of_no_return_timer", function (self, id)
	local noreturn_data = self:_get_noreturn_data(id)
	WFHud._objective_panel:set_point_of_no_return(noreturn_data.text_id)
end)

Hooks:OverrideFunction(HUDAssaultCorner, "hide_point_of_no_return_timer", function (self)
	WFHud._objective_panel:set_point_of_no_return(nil)
end)

Hooks:OverrideFunction(HUDAssaultCorner, "feed_point_of_no_return_timer", function (self, time)
	WFHud._objective_panel:set_time(time, true)
end)

Hooks:OverrideFunction(HUDAssaultCorner, "get_completed_waves_string", function (self)
	local current = managers.network:session():is_host() and managers.groupai:state():get_assault_number() or self._wave_number
	local max = self._max_waves or current
	local remaining = self._assault and max - current + 1 or max - current
	local text = managers.localization:to_upper_text("hud_waves_remaining", { NUM = remaining })

	WFHud._objective_panel:set_objective_detail(text)

	return text
end)
