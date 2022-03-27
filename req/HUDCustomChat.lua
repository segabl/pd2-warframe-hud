local hud_scale = WFHud.settings.hud_scale
local font_scale = WFHud.settings.font_scale
local chat_scale = hud_scale * font_scale * 0.75

---@class HUDCustomChat
---@field new fun():HUDCustomChat
HUDCustomChat = HUDCustomChat or WFHud:panel_class()

HUDCustomChat.MESSAGE_DISPLAY_TIME = 10
HUDCustomChat.MAX_MESSAGE_HISTORY = 100
HUDCustomChat.MAX_MESSAGE_LENGTH = 200

function HUDCustomChat:init(ws, panel)
	self._scroll_offset = 0

	self._ws = ws
	self._panel = panel:panel({
		visible = WFHud.settings.chat.enabled,
		layer = 0,
		w = WFHud.settings.chat.w,
		h = WFHud.settings.chat.h,
		x = WFHud.settings.chat.x,
		y = WFHud.settings.chat.y
	})

	self._component_panel = self._panel:panel({
		visible = false
	})

	self:_create_background()
	self:_create_input_panel()
	self:_create_output_panel()
	self:_create_status_panel()
	self:_create_buttons()

	self:_layout()

	if WFHud.settings.chat.enabled then
		managers.chat:register_receiver(ChatManager.GAME, self)
	end
end

function HUDCustomChat:_create_background()
	self._bg_panel = self._component_panel:panel({
		layer = -10,
		halign = "grow",
		valign = "grow"
	})

	self._tile_sizes = {
		{{ 56, 36 }, { 24, 36 }, { 16, 36 }},
		{{ 56, 16 }, { 24, 16 }, { 16, 16 }},
		{{ 56, 44 }, { 24, 44 }, { 16, 44 }}
	}
	self._background_tiles = {{},{},{}}

	local x_off, y_off = 0, 0
	local tile_w, tile_h = 0, 0
	for y = 1, 3 do
		for x = 1, 3 do
			tile_w = self._tile_sizes[y][x][1]
			tile_h = self._tile_sizes[y][x][2]
			self._background_tiles[y][x] = self._bg_panel:bitmap({
				alpha = 0.75,
				texture = "guis/textures/wfhud/chat",
				texture_rect = { x_off, y_off, tile_w, tile_h }
			})
			x_off = x_off + tile_w
		end
		x_off = 0
		y_off = y_off + tile_h
	end
end

function HUDCustomChat:_create_input_panel()
	self._input_panel = self._component_panel:panel({
		h = 28 * chat_scale
	})

	self._send_message_text = self._input_panel:text({
		layer = -1,
		font = WFHud.fonts.default,
		font_size = WFHud.font_sizes.small * hud_scale * font_scale,
		text = managers.localization:to_upper_text("hud_chat_send_message"),
		color = WFHud.settings.colors.default:with_alpha(0.5),
		vertical = "center"
	})

	self._input_text = self._input_panel:text({
		layer = -1,
		font = WFHud.fonts.default,
		font_size = WFHud.font_sizes.small * hud_scale * font_scale,
		text = "",
		color = WFHud.settings.colors.default,
		vertical = "center"
	})

	self._caret = self._input_panel:rect({
		color = WFHud.settings.colors.default,
		w = 2,
		h = self._input_panel:h() - 6,
		y = 3
	})
end

function HUDCustomChat:_create_output_panel()
	self._output_panel = self._panel:panel({
		alpha = 0
	})

	self._lines_panel = self._output_panel:panel()

	self._scrollbar_bg = self._component_panel:rect({
		layer = -1,
		color = WFHud.settings.colors.default,
		alpha = 0.1,
		w = 12 * chat_scale
	})

	self._scrollbar = self._component_panel:rect({
		color = WFHud.settings.colors.default,
		alpha = 0.8,
		w = self._scrollbar_bg:w()
	})
end

function HUDCustomChat:_create_status_panel()
	self._status_panel = self._panel:panel({
		alpha = 0,
		h = self._input_panel:h()
	})

	local connection_map = managers.controller:get_settings(managers.controller:get_default_wrapper_type()):get_connection_map()
	local chat_binding = connection_map.toggle_chat:get_input_name_list()
	local chat_key = chat_binding and chat_binding[1] or "t"
	local text = self._status_panel:text({
		font = WFHud.fonts.default,
		font_size = WFHud.font_sizes.small * hud_scale * font_scale,
		text = Input:keyboard():button_name_str(Idstring(chat_key)):upper(),
		color = WFHud.settings.colors.default,
		vertical = "center"
	})
	local _, _, w, h = text:text_rect()
	text:set_size(w, h)

	local ratio = self._status_panel:h() / 32
	w = math.max(8 * ratio, w - 4 * ratio)

	local outline_l = self._status_panel:bitmap({
		texture = "guis/textures/wfhud/chat_icons",
		texture_rect = { 0, 0, 12, 32 },
		w = 12 * ratio,
		h = 32 * ratio
	})

	local outline_c = self._status_panel:bitmap({
		texture = "guis/textures/wfhud/chat_icons",
		texture_rect = { 12, 0, 8, 32 },
		w = w,
		h = 32 * ratio,
		x = outline_l:right()
	})

	self._status_panel:bitmap({
		texture = "guis/textures/wfhud/chat_icons",
		texture_rect = { 20, 0, 12, 32 },
		w = 12 * ratio,
		h = 32 * ratio,
		x = outline_c:right()
	})

	text:set_center(outline_c:center())
end

function HUDCustomChat:_create_buttons()
	self._resize_top_button = self._component_panel:bitmap({
		alpha = 0.5,
		texture = "guis/textures/wfhud/chat_icons",
		texture_rect = { 64 + 16, 0, 16, 16 },
		w = 16 * chat_scale,
		h = 16 * chat_scale
	})

	self._resize_bottom_button = self._component_panel:bitmap({
		alpha = 0.5,
		texture = "guis/textures/wfhud/chat_icons",
		texture_rect = { 64 + 16, 16, 16, 16 },
		w = 16 * chat_scale,
		h = 16 * chat_scale
	})

	self._minimize_button = self._component_panel:bitmap({
		alpha = 0.5,
		texture = "guis/textures/wfhud/chat_icons",
		texture_rect = { 32, 0, 32, 32 },
		w = 16 * chat_scale,
		h = 16 * chat_scale
	})
end

function HUDCustomChat:_layout()
	local x, y, w, h = self._panel:shape()
	local min_w, min_h = self:_min_chat_size()
	local max_w, max_h = self._panel:parent():size()

	self._panel:set_size(math.clamp(w, min_w, max_w), math.clamp(h, min_h, max_h))
	self._component_panel:set_size(self._panel:size())

	x = math.min(x < 0 and WFHud.settings.margin_h or x, max_w - self._panel:w())
	y = math.min(y < 0 and max_h - WFHud.settings.margin_v - self._panel:h() or y, max_h - self._panel:h())
	self._panel:set_position(x, y)

	x, y, w, h = self._panel:shape()

	local x_off, y_off = 0, 0
	local tile_w, tile_h = 0, 0
	for y = 1, 3 do
		for x = 1, 3 do
			local tile = self._background_tiles[y][x]
			tile_w = x == 2 and math.max(0, w - x_off - self._tile_sizes[y][3][1] * chat_scale) or self._tile_sizes[y][x][1] * chat_scale
			tile_h = y == 2 and math.max(0, h - y_off - self._tile_sizes[3][x][2] * chat_scale) or self._tile_sizes[y][x][2] * chat_scale
			tile:set_size(tile_w, tile_h)
			tile:set_position(x_off, y_off)
			x_off = x_off + tile_w
		end
		x_off = 0
		y_off = y_off + tile_h
	end

	self._input_panel:set_w(w - 66 * chat_scale)
	self._input_panel:set_leftbottom(50 * chat_scale, h)

	self._output_panel:set_size(w - 30 * chat_scale, h - 68 * chat_scale)
	self._output_panel:set_position(17 * chat_scale, 36 * chat_scale)

	self._status_panel:set_w(w)
	self._status_panel:set_lefttop(self._output_panel:leftbottom())

	self._resize_top_button:set_righttop(w, 0)
	self._resize_bottom_button:set_rightbottom(w, h)
	self._minimize_button:set_center(self._resize_top_button:x(), 16 * chat_scale)

	self:_layout_output(true)
end

function HUDCustomChat:_layout_output(size_changed)
	local out_w, out_h = self._output_panel:size()
	local total_h = 0

	for _, text in ipairs(self._lines_panel:children()) do
		if size_changed then
			text:set_wrap(false)
			text:set_word_wrap(false)
			text:set_w(out_w)
			text:set_wrap(true)
			text:set_word_wrap(true)
			local _, _, _, th = text:text_rect()
			text:set_h(th)
		end
		text:set_y(total_h)

		total_h = total_h + text:h()
	end

	local lh = total_h > 0 and self._lines_panel:child(0):line_height() or 1
	self._lines_panel:set_size(out_w, total_h)
	self._lines_panel:set_bottom(out_h + lh * math.ceil((math.max(0, total_h - out_h) * self._scroll_offset) / lh))

	if total_h > out_h then
		local scroll_h = self._panel:h() - (28 + 32 + 2) * chat_scale

		self._scrollbar_bg:set_h(scroll_h)
		self._scrollbar_bg:set_righttop(self._panel:w() - chat_scale, 33 * chat_scale)
		self._scrollbar_bg:show()

		self._scrollbar:set_h(scroll_h * (out_h / total_h))
		self._scrollbar:set_righttop(self._panel:w() - chat_scale, 33 * chat_scale + (scroll_h - self._scrollbar:h()) * (1 - self._scroll_offset))
		self._scrollbar:show()
	else
		self._scrollbar_bg:hide()
		self._scrollbar:hide()
	end
end

function HUDCustomChat:_min_chat_size()
	local min_w = math.max((self._tile_sizes[1][1][1] + self._tile_sizes[1][3][1]) * chat_scale, 200)
	local min_h = math.max((self._tile_sizes[1][1][2] + self._tile_sizes[3][1][2]) * chat_scale, 100)
	return min_w, min_h
end

function HUDCustomChat:_animate_fade_out(o, delay)
	o:set_alpha(1)
	wait(delay or 0)
	over(0.5, function (t)
		o:set_alpha(1 - t)
	end)
	o:set_alpha(0)
end

function HUDCustomChat:_animate_blink(o)
	while true do
		o:show()
		wait(0.3)
		o:hide()
		wait(0.3)
	end
end

function HUDCustomChat:_check_key(k)
	local text = self._input_text
	local s, e = text:selection()
	local n = utf8.len(text:text())

	if k == Idstring("backspace") then
		if s > 0 then
			text:set_selection(s - 1, e)
			text:replace_text("")
		end
	elseif k == Idstring("delete") then
		if s < n then
			text:set_selection(s, e + 1)
			text:replace_text("")
		end
	elseif k == Idstring("left") then
		if e > 0 then
			text:set_selection(e - 1, e - 1)
		end
	elseif k == Idstring("right") then
		if e < n then
			text:set_selection(e + 1, e + 1)
		end
	elseif k == Idstring("enter") or k == Idstring("num enter") then
		self:send_message()
	elseif k == Idstring("esc") then
		self:_close_chat()
	elseif Input:keyboard():down(Idstring("left ctrl")) then
		if k == Idstring("v") then
			text:replace_text(string.sub(string.gsub(Application:get_clipboard() or "", "\n", ""), 1, HUDCustomChat.MAX_MESSAGE_LENGTH - n))
		end
	end

	s, e = text:selection()
	n = utf8.len(text:text())
	text:set_selection(math.clamp(s > e and e or s, 0, n), math.clamp(s > e and s or e, 0, n))

	self._send_message_text:set_visible(n == 0)

	self:_update_caret()
end

function HUDCustomChat:_close_chat()
	self._input_text:set_text("")
	self._input_text:set_selection(0, 0)
	managers.hud:set_chat_focus(false)
end

function HUDCustomChat:_update_caret()
	local text = self._input_text
	local x = text:selection_rect()
	local _, _, w = text:text_rect()
	text:set_w(w)

	self._caret:set_world_x(x ~= 0 and x or self._input_panel:world_x())
	if w <= self._input_panel:w() then
		text:set_x(0)
	elseif self._caret:x() > self._input_panel:w() - 2 then
		local delta = self._input_panel:w() - 2 - self._caret:x()
		text:move(delta, 0)
		self._caret:move(delta, 0)
	elseif self._caret:x() < 0 then
		local delta = -self._caret:x()
		text:move(delta, 0)
		self._caret:move(delta, 0)
	end
end

function HUDCustomChat:show()
	if self._focus then
		return
	end

	self._panel:set_layer(100)

	self._skip_first_key = true
	self._key_pressed = nil
	self._focus = true

	self._component_panel:show()

	self._output_panel:stop()
	self._output_panel:set_alpha(1)
	self._status_panel:stop()
	self._status_panel:set_alpha(0)

	self._caret:animate(callback(self, self, "_animate_blink"))

	managers.mouse_pointer:use_mouse({
		mouse_move = callback(self, self, "mouse_move"),
		mouse_press = callback(self, self, "mouse_press"),
		mouse_release = callback(self, self, "mouse_release"),
		id = "wfhud_chat"
	})

	self._ws:connect_keyboard(Input:keyboard())
	self._input_panel:key_press(callback(self, self, "key_press"))
	self._input_panel:key_release(callback(self, self, "key_release"))
	self._input_panel:enter_text(callback(self, self, "enter_text"))
end

function HUDCustomChat:hide()
	if not self._focus then
		return
	end

	self._panel:set_layer(0)

	self._component_panel:hide()

	self._output_panel:stop()
	self._output_panel:animate(callback(self, self, "_animate_fade_out"), HUDCustomChat.MESSAGE_DISPLAY_TIME)
	self._status_panel:stop()
	self._status_panel:animate(callback(self, self, "_animate_fade_out"), HUDCustomChat.MESSAGE_DISPLAY_TIME)

	self._caret:stop()

	managers.mouse_pointer:remove_mouse("wfhud_chat")

	self._ws:disconnect_keyboard()
	self._input_panel:key_press(nil)
	self._input_panel:key_release(nil)
	self._input_panel:enter_text(nil)

	self._panel_resize = nil
	self._panel_move = nil
	self._key_pressed = nil
	self._focus = false
end

function HUDCustomChat:key_press(o, k)
	if managers.hud and managers.hud:showing_stats_screen() then
		return
	end

	self:_check_key(k)

	self._key_pressed = k
	self._key_repeat_t = self._t + 0.6
end

function HUDCustomChat:key_release(o, k)
	if self._key_pressed == k then
		self._key_pressed = nil
	end

	self._skip_first_key = false
end

function HUDCustomChat:enter_text(o, s)
	if self._skip_first_key then
		return
	end

	if Input:keyboard():down(Idstring("left ctrl")) or managers.hud and managers.hud:showing_stats_screen() then
		return
	end

	local text = self._input_text
	if utf8.len(text:text()) >= HUDCustomChat.MAX_MESSAGE_LENGTH then
		return
	end

	text:replace_text(s)

	self:_update_caret()

	self._send_message_text:hide()
end

function HUDCustomChat:send_message()
	local text = self._input_text
	local message = text:text()

	if string.len(message) == 0 then
		return
	end

	managers.chat:send_message(ChatManager.GAME, managers.network.account:username() or "Offline", message)

	text:set_text("")
	text:set_selection(0, 0)

	self._key_pressed = nil

	if not WFHud.settings.chat.keep_open then
		managers.hud:set_chat_focus(false)
	end
end

function HUDCustomChat:_add_message(lines_panel, line_text, color_ranges)
	if lines_panel:num_children() >= HUDCustomChat.MAX_MESSAGE_HISTORY then
		lines_panel:remove(lines_panel:child(0))
	end

	local text = lines_panel:text({
		font = WFHud.fonts.default,
		font_size = WFHud.font_sizes.small * hud_scale * font_scale,
		text = line_text,
		color = WFHud.settings.colors.default,
		word_wrap = true,
		wrap = true
	})
	local _, _, _, th = text:text_rect()
	text:set_h(th)
	if color_ranges then
		for i = 1, #color_ranges, 3 do
			text:set_range_color(color_ranges[i], color_ranges[i + 1], color_ranges[i + 2])
		end
	end

	if lines_panel ~= self._lines_panel then
		return
	end

	self._scroll_offset = 0
	self:_layout_output()

	if self._focus then
		return
	end

	self._output_panel:stop()
	self._output_panel:animate(callback(self, self, "_animate_fade_out"), HUDCustomChat.MESSAGE_DISPLAY_TIME)
	self._status_panel:stop()
	self._status_panel:animate(callback(self, self, "_animate_fade_out"), HUDCustomChat.MESSAGE_DISPLAY_TIME)
end

local time_functions = {
	[1] = function () return os.date("[%H:%M] ") end,
	[2] = function () return os.date("[%I:%M %p] ") end,
	[3] = function ()
		local time = math.floor(managers.game_play_central:get_heist_timer())
		local hours = math.floor(time / 3600)
		time = time - hours * 3600
		local minutes = math.floor(time / 60)
		time = time - minutes * 60
		local seconds = math.round(time)
		return hours > 0 and string.format("[%02u:%02u:%02u] ", hours, minutes, seconds) or string.format("[%02u:%02u] ", minutes, seconds)
	end
}
function HUDCustomChat:receive_message(name, message, color)
	local peer = managers.chat._last_message_peer
	local private, line_text, color_ranges
	if not peer and (not name or name == managers.localization:to_upper_text("menu_system_message")) then
		line_text = message
	else
		local msg, subs = message:gsub("^%[PRIVATE%](.+)", "%1")
		private = subs > 0 and peer

		local timestamp = WFHud.settings.chat.timestamps
		local time_name = (time_functions[timestamp] and time_functions[timestamp]() or "") .. name
		line_text = string.format("%s: %s", time_name, msg)
		color_ranges = {
			0, utf8.len(time_name), WFHud.settings.chat.use_peer_colors and color or private and WFHud.settings.colors.private_chat or WFHud.settings.colors.squad_chat
		}
	end

	self:_add_message(self._lines_panel, line_text, color_ranges)
end

function HUDCustomChat:mouse_move(o, x, y)
	if self._panel_resize then
		local min_w, min_h = self:_min_chat_size()
		if self._panel_resize == "top" then
			local w = math.max(x - self._panel:x() + self._panel_resize_offset_x, min_w)
			local h = math.max(self._panel:bottom() - y + self._panel_resize_offset_y, min_h)
			self._panel:set_size(w, h)
			self._panel:set_bottom(self._panel_resize_pos)
		else
			local w = math.max(x - self._panel:x() + self._panel_resize_offset_x, min_w)
			local h = math.max(y - self._panel:y() + self._panel_resize_offset_y, min_h)
			self._panel:set_size(w, h)
		end

		self:_layout()
	elseif self._panel_move then
		self._panel:set_x(math.clamp(x + self._panel_move_offset_x, 0, self._panel:parent():w() - self._panel:w()))
		self._panel:set_y(math.clamp(y + self._panel_move_offset_y, 0, self._panel:parent():h() - self._panel:h()))
	end
end

function HUDCustomChat:mouse_press(o, button, x, y)
	if button == Idstring("0") then
		if self._minimize_button:inside(x, y) then
			self._button_pressed = self._minimize_button
		elseif self._resize_top_button:inside(x, y) then
			self._panel_resize = "top"
			self._panel_resize_offset_x = self._panel:right() - x
			self._panel_resize_offset_y = y - self._panel:y()
			self._panel_resize_pos = self._panel:bottom()
		elseif self._resize_bottom_button:inside(x, y) then
			self._panel_resize = "bottom"
			self._panel_resize_offset_x = self._panel:right() - x
			self._panel_resize_offset_y = self._panel:bottom() - y
		elseif x > self._panel:world_x() + 12 * chat_scale and x < self._minimize_button:world_x() and y > self._panel:world_y() and y < self._panel:world_y() + 32 * chat_scale then
			self._panel_move = true
			self._panel_move_offset_x = self._panel:x() - x
			self._panel_move_offset_y = self._panel:y() - y
		end
	elseif button == Idstring("mouse wheel up") then
		local amount = self._lines_panel:num_children() > 0 and self._lines_panel:child(0):line_height() / (self._lines_panel:h() - self._output_panel:h()) or 0
		self._scroll_offset = math.min(1, self._scroll_offset + amount)
		self:_layout_output()
	elseif button == Idstring("mouse wheel down") then
		local amount = self._lines_panel:num_children() > 0 and self._lines_panel:child(0):line_height() / (self._lines_panel:h() - self._output_panel:h()) or 0
		self._scroll_offset = math.max(0, self._scroll_offset - amount)
		self:_layout_output()
	end
end

function HUDCustomChat:mouse_release(o, button, x, y)
	if button ~= Idstring("0") then
		return
	end

	if self._button_pressed == self._minimize_button then
		self:_close_chat()
	elseif self._panel_resize or self._panel_move then
		WFHud.settings.chat.x = self._panel:x()
		WFHud.settings.chat.y = self._panel:y()
		WFHud.settings.chat.w = self._panel:w()
		WFHud.settings.chat.h = self._panel:h()
		MenuCallbackHandler:WFHud_save()
	end

	self._button_pressed = nil
	self._panel_resize = nil
	self._panel_move = nil
end

function HUDCustomChat:update(t, dt)
	self._t = t

	if not self._focus then
		return
	end

	if self._key_pressed and self._key_repeat_t <= t then
		self:_check_key(self._key_pressed)
		self._key_repeat_t = t + 0.02
	end
end

function HUDCustomChat:destroy()
	if not alive(self._panel) then
		return
	end

	self._output_panel:stop()
	self._status_panel:stop()

	self._panel:parent():remove(self._panel)

	managers.chat:unregister_receiver(ChatManager.GAME, self)
end
