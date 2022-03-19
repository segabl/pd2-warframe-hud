local hud_scale = WFHud.settings.hud_scale
local font_scale = WFHud.settings.font_scale

HUDChat.line_height = WFHud.font_sizes.small * font_scale * hud_scale

local init_original = HUDChat.init
function HUDChat:init(ws, hud, ...)
	init_original(self, WFHud:ws(), { panel = WFHud:panel() }, ...)

	self._panel:set_h(self._panel:parent():h())
	self._panel:set_leftbottom(WFHud.settings.margin_h, self._panel:parent():h() - WFHud.settings.margin_v)

	self._output_width = self._panel_width
	self:_layout_input_panel()
	self:_layout_output_panel()
end

Hooks:PostHook(HUDChat, "_create_input_panel", "_create_input_panel_wfhud", function (self)
	self._input_panel:set_h(HUDChat.line_height)

	self._input_panel:child("say"):set_w(0)
	self._input_panel:child("input_bg"):set_h(self._input_panel:h())

	local input_text = self._input_panel:child("input_text")
	input_text:set_font(WFHud.font_ids.default)
	input_text:set_font_size(HUDChat.line_height)
	input_text:set_h(self._input_panel:h())
end)

Hooks:PostHook(HUDChat, "_on_focus", "_on_focus_wfhud", function (self)
	self._panel:child("output_panel"):child("output_bg"):show()
end)

Hooks:PostHook(HUDChat, "_loose_focus", "_loose_focus_wfhud", function (self)
	self._panel:child("output_panel"):child("output_bg"):hide()
end)

Hooks:OverrideFunction(HUDChat, "receive_message", function (self, name, message, color, icon)
	local output_panel = self._panel:child("output_panel")
	local time_name = string.format("[%s] %s", os.date("%H:%M"), name)
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
		text = string.format("%s: %s", time_name, message),
		font = WFHud.fonts.default,
		font_size = HUDChat.line_height,
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
		output_panel:child("output_bg"):hide()
		output_panel:stop()
		output_panel:animate(callback(self, self, "_animate_show_component"), output_panel:alpha())
		output_panel:animate(callback(self, self, "_animate_fade_output"))
	end
end)

function HUDChat:_animate_fade_output()
	wait(15)
	over(1, function (t)
		self:set_output_alpha(1 - t)
	end)
	self:set_output_alpha(0)
end

Hooks:OverrideFunction(HUDChat, "update_caret", function (self)
	local text = self._input_panel:child("input_text")
	local caret = self._input_panel:child("caret")
	local s, e = text:selection()
	local x, y, w, h = text:selection_rect()

	if s == 0 and e == 0 then
		x = text:align() == "center" and text:world_x() + text:w() / 2 or text:world_x()
		y = text:world_y()
	end

	h = text:h()

	if w < 2 then
		w = 2
	end

	if not self._focus then
		w = 0
		h = 0
	end

	caret:set_world_shape(x, y + 2, w, h - 4)
	self:set_blinking(s == e and self._focus)
end)
