Hooks:PostHook(HUDAssaultCorner, "init", "init_wfhud", function (self)
	if not self._hud_panel then
		return
	end

	local h_offset = (WFHud:panel():w() - self._hud_panel:w()) * 0.5
	local v_offset = (WFHud:panel():h() - self._hud_panel:h()) * 0.5

	local assault_panel = self._hud_panel:child("assault_panel")
	if assault_panel then
		assault_panel:set_position(WFHud.MARGIN_H - h_offset, WFHud.MARGIN_V - v_offset)
		assault_panel:child("icon_assaultbox"):set_left(self._bg_box_size + 3)
		self._bg_box:set_position(0, 0)
	end

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

local sync_set_assault_mode_original = HUDAssaultCorner.sync_set_assault_mode
function HUDAssaultCorner:sync_set_assault_mode(mode, ...)
	return sync_set_assault_mode_original(self, mode == "phalanx" and "normal" or mode, ...)
end

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
