local hud_scale = WFHud.settings.hud_scale
local font_scale = WFHud.settings.font_scale

---@class HUDIconList
---@field new fun():HUDIconList
HUDIconList = HUDIconList or WFHud:panel_class()

function HUDIconList:init(panel, x, y, width, height, icon_color)
	self._size = height
	self._spacing = height / 8
	self._icon_color = icon_color

	self._panel = panel:panel({
		x = x,
		y = y,
		w = width,
		h = height + 4
	})
end

function HUDIconList:_layout_panel()
	for i, child in pairs(self._panel:children()) do
		child:set_right(self._panel:w() - (i - 1) * (self._size + self._spacing))
	end
end

function HUDIconList:add_icon(name, texture, texture_rect)
	if not texture then
		return
	end

	local icon_panel = self._panel:child(name)
	if icon_panel then
		icon_panel:clear()
	else
		icon_panel = self._panel:panel({
			name = name,
			w = self._size,
			h = self._panel:h()
		})
	end

	local image = icon_panel:bitmap({
		name = "bitmap",
		texture = texture,
		texture_rect = texture_rect,
		color = self._icon_color,
		alpha = 0.85,
		w = self._size,
		h = self._size
	})
	local ratio = texture_rect and texture_rect[4] / texture_rect[3] or image:texture_height() / image:texture_width()
	image:set_size(ratio < 1 and self._size or self._size / ratio, ratio < 1 and self._size * ratio or self._size)
	image:set_center(icon_panel:w() * 0.5, self._size * 0.5)

	local panel = icon_panel:panel({
		layer = 1,
		name = "value_panel",
		w = WFHud.font_sizes.tiny * font_scale * hud_scale * 1.25,
		h = WFHud.font_sizes.tiny * font_scale * hud_scale,
		visible = false
	})
	panel:set_center_x(icon_panel:w() * 0.5)
	panel:set_bottom(icon_panel:h())

	panel:rect({
		halign = "grow",
		valign = "grow",
		color = WFHud.colors.bg:with_alpha(0.75)
	})

	panel:text({
		layer = 1,
		name = "value_text",
		halign = "grow",
		valign = "grow",
		align = "center",
		vertical = "center",
		text = "",
		color = WFHud.colors.default,
		font = WFHud.fonts.default_no_shadow,
		font_size = WFHud.font_sizes.tiny * font_scale * hud_scale
	})

	self:_layout_panel()
end

function HUDIconList:remove_icon(name)
	local icon_panel = self._panel:child(name)
	if icon_panel then
		self._panel:remove(icon_panel)
		self:_layout_panel()
	end
end

function HUDIconList:set_icon_value(name, value)
	local icon_panel = self._panel:child(name)
	if icon_panel then
		local value_panel = icon_panel:child("value_panel")
		if value then
			value_panel:child("value_text"):set_text(tostring(value))
			value_panel:show()
		else
			value_panel:hide()
		end
	end
end

function HUDIconList:set_icon_enabled(name, state)
	local icon_panel = self._panel:child(name)
	if icon_panel then
		icon_panel:child("bitmap"):set_alpha(state and 0.75 or 0.15)
	end
end

function HUDIconList:destroy()
	if not alive(self._panel) then
		return
	end

	self._panel:stop()
	self._panel:parent():remove(self._panel)
end
