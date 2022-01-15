Hooks:PostHook(HUDAssaultCorner, "init", "init_wfhud", function (self)
	self._hud_panel:child("assault_panel"):set_visible(false)
	self._hud_panel:child("hostages_panel"):set_visible(false)
	self._hud_panel:child("point_of_no_return_panel"):set_visible(false)
	self._hud_panel:child("casing_panel"):set_visible(false)
	if self._hud_panel:child("wave_panel") then
		self._hud_panel:child("wave_panel"):set_visible(false)
	end
end)

function HUDAssaultCorner:_animate_show_casing(casing_panel, delay_time) end
function HUDAssaultCorner:_animate_show_noreturn(point_of_no_return_panel, delay_time) end
function HUDAssaultCorner:_animate_wave_completed(panel, assault_hud) end
function HUDAssaultCorner:_animate_wave_started(panel, assault_hud) end
function HUDAssaultCorner:_popup_wave(text, color) end
function HUDAssaultCorner:set_buff_enabled(buff_name, enabled) end
function HUDAssaultCorner:_show_icon_assaultbox(icon_assaultbox) end
function HUDAssaultCorner:_show_hostages() end
function HUDAssaultCorner:_start_assault(text_list) end