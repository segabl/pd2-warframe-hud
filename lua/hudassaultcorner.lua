Hooks:PostHook(HUDAssaultCorner, "init", "init_wfhud", function (self)
	self._hud_panel:child("assault_panel"):set_alpha(0)
	self._hud_panel:child("hostages_panel"):set_alpha(0)
	self._hud_panel:child("casing_panel"):set_alpha(0)
end)

Hooks:PostHook(HUDAssaultCorner, "_update_noreturn", "_update_noreturn_wfhud", function (self)
	local point_of_no_return_panel = self._hud_panel:child("point_of_no_return_panel")
	local icon_noreturnbox = point_of_no_return_panel:child("icon_noreturnbox")
	local point_of_no_return_text = self._noreturn_bg_box:child("point_of_no_return_text")
	local point_of_no_return_timer = self._noreturn_bg_box:child("point_of_no_return_timer")

	point_of_no_return_panel:set_position(0, 270)

	self._noreturn_bg_box:set_position(34, 2)

	icon_noreturnbox:set_position(0, 0)
	icon_noreturnbox:set_blend_mode("normal")

	point_of_no_return_text:set_position(0, 0)
	point_of_no_return_text:set_h(icon_noreturnbox:h())
	point_of_no_return_text:set_align("left")
	point_of_no_return_text:set_blend_mode("normal")
	point_of_no_return_text:set_font(Idstring(WFHud.fonts.default))
	point_of_no_return_text:set_font_size(24)

	local _, _, w = point_of_no_return_text:text_rect()
	point_of_no_return_timer:set_position(w + 5, 0)
	point_of_no_return_timer:set_h(icon_noreturnbox:h())
	point_of_no_return_timer:set_align("left")
	point_of_no_return_timer:set_blend_mode("normal")
	point_of_no_return_timer:set_font(Idstring(WFHud.fonts.default))
	point_of_no_return_timer:set_font_size(24)
end)

Hooks:PostHook(HUDAssaultCorner, "setup_wave_display", "setup_wave_display_wfhud", function (self, top, right)
	local wave_panel = self._hud_panel:child("wave_panel")
	if not wave_panel then
		return
	end

	wave_panel:set_position(34, 270)
	wave_panel:set_w(500)

	wave_panel:child("waves_icon"):set_visible(false)

	self._wave_bg_box:set_position(0, 0)
	self._wave_bg_box:set_size(wave_panel:w(), wave_panel:h())

	local num_waves = self._wave_bg_box:child("num_waves")
	num_waves:set_align("left")
	num_waves:set_halign("left")
	num_waves:set_valign("top")
	num_waves:set_blend_mode("normal")
	num_waves:set_font(Idstring(WFHud.fonts.default))
	num_waves:set_font_size(24)
	num_waves:set_position(0, 0)
	num_waves:set_size(wave_panel:w(), wave_panel:h())
end)

Hooks:PostHook(HUDAssaultCorner, "set_buff_enabled", "set_buff_enabled_wfhud", function (self, buff_name, enabled)
	if not enabled then
		return
	end

	local buffs_panel = self._hud_panel:child("buffs_panel")

	buffs_panel:set_position(0, 270)
	buffs_panel:set_w(500)

	self._vip_bg_box:set_size(buffs_panel:w(), buffs_panel:h())
	self._vip_bg_box:set_position(0, 0)

	self._vip_bg_box:child("vip_icon"):set_size(24, 24)
	self._vip_bg_box:child("vip_icon"):set_position(0, 0)
end)

function HUDAssaultCorner:get_completed_waves_string()
	local current = managers.network:session():is_host() and managers.groupai:state():get_assault_number() or self._wave_number
	local max = self._max_waves or current
	local remaining = self._assault and max - current + 1 or max - current

	return managers.localization:to_upper_text("hud_waves_remaining", { NUM = remaining })
end

function HUDAssaultCorner:_offset_hostage(is_offseted, hostage_panel)
	if self._start_assault_after_hostage_offset then
		self._start_assault_after_hostage_offset = nil
		self:start_assault_callback()
	end
end
