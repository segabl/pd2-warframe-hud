local hud_scale = WFHud.settings.hud_scale
local font_scale = WFHud.settings.font_scale

Hooks:PostHook(HUDPlayerDowned, "init", "init_wfhud", function (self)
	local downed_panel = self._hud_panel:child("downed_panel")
	local timer_msg = downed_panel:child("timer_msg")

	timer_msg:set_font(WFHud.font_ids.default)
	timer_msg:set_font_size(WFHud.font_sizes.default * font_scale * hud_scale)
	timer_msg:set_h(WFHud.font_sizes.default * font_scale * hud_scale)
	timer_msg:set_top(downed_panel:h() * 0.15)

	self._hud.timer:set_font(WFHud.font_ids.bold)
	self._hud.timer:set_font_size(WFHud.font_sizes.default * font_scale * hud_scale)
	self._hud.timer:set_h(WFHud.font_sizes.default * font_scale * hud_scale)
	self._hud.timer:set_top(timer_msg:bottom())

	self._hud.arrest_finished_text:set_font(WFHud.font_ids.default)
	self._hud.arrest_finished_text:set_font_size(WFHud.font_sizes.default * font_scale * hud_scale)
	self._hud.arrest_finished_text:set_h(WFHud.font_sizes.default * font_scale * hud_scale)
	self._hud.arrest_finished_text:set_top(downed_panel:h() * 0.15)
end)
