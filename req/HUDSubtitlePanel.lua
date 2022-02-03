HUDSubtitlePanel = class()

HUDSubtitlePanel.CHARACTER_COLORS = {
	default = WFHud.colors.friendly,
	bul = WFHud.colors.enemy,
	com = WFHud.colors.enemy,
	mrb = Color("ffff99"),
	mrp = Color("ff66aa")
}

function HUDSubtitlePanel:init(panel, x, y)
	self._panel = panel:panel({
		alpha = 0,
		x = x,
		y = y,
		w = 300
	})

	self._name = self._panel:text({
		font = WFHud.fonts.bold,
		font_size = WFHud.font_sizes.default,
		color = WFHud.colors.friendly,
		h = WFHud.font_sizes.default
	})

	self._text = self._panel:text({
		font = WFHud.fonts.default,
		font_size = WFHud.font_sizes.default,
		color = WFHud.colors.default,
		y = WFHud.font_sizes.default,
		wrap = true,
		word_wrap = true
	})
end

function HUDSubtitlePanel:_animate_show_subtitle(duration, panel)
	panel:set_alpha(0)
	over(0.1, function (t)
		panel:set_alpha(t)
	end)
	wait(duration)
	over(0.1, function (t)
		panel:set_alpha(1 - t)
	end)
	panel:set_alpha(0)
end

function HUDSubtitlePanel:set_subtitle(speaker, text, duration)
	local loc_id = speaker and "hud_sub_name_" .. speaker
	local name = loc_id and managers.localization:exists(loc_id) and managers.localization:to_upper_text(loc_id) or speaker and speaker:upper() or ""

	self._name:set_text(name)
	self._name:set_color(HUDSubtitlePanel.CHARACTER_COLORS[speaker] or HUDSubtitlePanel.CHARACTER_COLORS.default)
	self._text:set_text(text or "")
	self._panel:stop()
	self._panel:animate(callback(self, self, "_animate_show_subtitle", duration or 3))
end
