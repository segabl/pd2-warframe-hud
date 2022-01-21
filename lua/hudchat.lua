HUDChat.line_height = 20

Hooks:PostHook(HUDChat, "init", "init_wfhud", function (self)
	self._panel:set_h(self._panel:parent():h())
	self._panel:set_bottom(self._panel:parent():h())

	self._output_width = self._panel_width
	self:_layout_input_panel()
	self:_layout_output_panel()
end)

Hooks:PostHook(HUDChat, "_create_input_panel", "_create_input_panel_wfhud", function (self)
	self._input_panel:child("say"):set_w(0)

	local input_text = self._input_panel:child("input_text")
	input_text:set_font(Idstring(WFHud.fonts.default))
	input_text:set_font_size(20)
end)

Hooks:PostHook(HUDChat, "_on_focus", "_on_focus_wfhud", function (self)
	self._panel:child("output_panel"):child("output_bg"):set_visible(true)
end)

Hooks:PostHook(HUDChat, "_loose_focus", "_loose_focus_wfhud", function (self)
	self._panel:child("output_panel"):child("output_bg"):set_visible(false)
end)

function HUDChat:receive_message(name, message, color, icon)
	local output_panel = self._panel:child("output_panel")
	local time_name = string.format("[%s] %s: ", os.date("%H:%M"), name)
	local len = utf8.len(time_name)

	local line = output_panel:text({
		halign = "left",
		vertical = "top",
		hvertical = "top",
		wrap = true,
		align = "left",
		blend_mode = "normal",
		word_wrap = true,
		y = 0,
		layer = 0,
		text = time_name .. message,
		font = WFHud.fonts.default,
		font_size = 20,
		x = 0,
		color = color
	})
	local total_len = utf8.len(line:text())

	line:set_range_color(0, len, color)
	line:set_range_color(len, total_len, Color.white)

	local _, _, _, h = line:text_rect()

	line:set_h(h)
	table.insert(self._lines, { line })
	line:set_kern(line:kern())
	self:_layout_output_panel()

	if not self._focus then
		output_panel:child("output_bg"):set_visible(false)
		output_panel:stop()
		output_panel:animate(callback(self, self, "_animate_show_component"), output_panel:alpha())
		output_panel:animate(callback(self, self, "_animate_fade_output"))
	end
end
