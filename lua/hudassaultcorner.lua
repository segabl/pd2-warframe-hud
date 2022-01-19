Hooks:PostHook(HUDAssaultCorner, "init", "init_wfhud", function (self)
	self._hud_panel:child("assault_panel"):set_visible(false)
	self._hud_panel:child("hostages_panel"):set_visible(false)
	self._hud_panel:child("casing_panel"):set_visible(false)
	if self._hud_panel:child("wave_panel") then
		self._hud_panel:child("wave_panel"):set_visible(false)
	end
end)

Hooks:PostHook(HUDAssaultCorner, "_update_noreturn", "_update_noreturn_wfhud", function (self)
	local point_of_no_return_panel = self._hud_panel:child("point_of_no_return_panel")
	local icon_noreturnbox = point_of_no_return_panel:child("icon_noreturnbox")
	local point_of_no_return_text = self._noreturn_bg_box:child("point_of_no_return_text")
	local point_of_no_return_timer = self._noreturn_bg_box:child("point_of_no_return_timer")

	point_of_no_return_panel:set_position(0, 280)

	self._noreturn_bg_box:set_position(34, 2)

	icon_noreturnbox:set_position(0, 0)
	icon_noreturnbox:set_blend_mode("normal")

	point_of_no_return_text:set_position(0, 0)
	point_of_no_return_text:set_h(icon_noreturnbox:h())
	point_of_no_return_text:set_align("left")
	point_of_no_return_text:set_blend_mode("normal")
	point_of_no_return_text:set_font(Idstring(tweak_data.menu.medium_font))
	point_of_no_return_text:set_font_size(24)

	local _, _, w = point_of_no_return_text:text_rect()
	point_of_no_return_timer:set_position(w + 5, 0)
	point_of_no_return_timer:set_h(icon_noreturnbox:h())
	point_of_no_return_timer:set_align("left")
	point_of_no_return_timer:set_blend_mode("normal")
	point_of_no_return_timer:set_font(Idstring(tweak_data.menu.medium_font))
	point_of_no_return_timer:set_font_size(24)
end)

function HUDAssaultCorner:_animate_show_casing(casing_panel, delay_time) end
function HUDAssaultCorner:_animate_wave_completed(panel, assault_hud) end
function HUDAssaultCorner:_animate_wave_started(panel, assault_hud) end
function HUDAssaultCorner:_popup_wave(text, color) end
function HUDAssaultCorner:set_buff_enabled(buff_name, enabled) end
function HUDAssaultCorner:_show_icon_assaultbox(icon_assaultbox) end
function HUDAssaultCorner:_show_hostages() end
function HUDAssaultCorner:_start_assault(text_list) end