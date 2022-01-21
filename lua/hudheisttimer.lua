Hooks:PostHook(HUDHeistTimer, "init", "init_hophud", function (self)
	self._timer_text:set_font(Idstring(WFHud.fonts.default))
	self._timer_text:set_font_size(24)
	self._timer_text:set_align("left")

	self._heist_timer_panel:set_x(34)
	self._heist_timer_panel:set_y(230)
end)
