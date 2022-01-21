Hooks:PostHook(HUDTemp, "init", "init_wfhud", function (self)
	local bag_text = self._bg_box:child("bag_text")
	bag_text:set_font(Idstring(WFHud.fonts.default))
	bag_text:set_font_size(24)
	bag_text:set_align("right")
	bag_text:set_x(0)
end)

function HUDTemp:set_throw_bag_text() end
