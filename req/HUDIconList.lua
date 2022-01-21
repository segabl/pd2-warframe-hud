HUDIconList = class()

function HUDIconList:init(panel, x, y, width, height, icon_color)
	self._size = height
	self._spacing = height / 6
	self._icon_color = icon_color

	self._panel = panel:panel({
		x = x,
		y = y,
		w = width,
		h = height
	})
end

function HUDIconList:_layout_panel()
	for i, child in pairs(self._panel:children()) do
		child:set_right(self._panel:w() - (i - 1) * (self._size + self._spacing))
	end
end

function HUDIconList:add_icon(name, texture, texture_rect)
	local icon_panel = self._panel:child(name)
	if icon_panel then
		if texture then
			icon_panel:child("bitmap"):set_image(texture, unpack(texture_rect))
		end
		return
	end

	icon_panel = self._panel:panel({
		name = name,
		w = self._size,
		h = self._size
	})

	icon_panel:bitmap({
		name = "bitmap",
		texture = texture,
		texture_rect = texture_rect,
		color = self._icon_color,
		alpha = 0.75,
		w = self._size,
		h = self._size
	})

	icon_panel:text({
		name = "value",
		align = "right",
		vertical = "bottom",
		text = "",
		color = WFHud.colors.default,
		font = tweak_data.menu.medium_font,
		font_size = 18,
		layer = 1,
		w = self._size,
		h = self._size + 4
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
		icon_panel:child("value"):set_text(value and tostring(value) or "")
	end
end

function HUDIconList:set_icon_enabled(name, state)
	local icon_panel = self._panel:child(name)
	if icon_panel then
		icon_panel:child("bitmap"):set_alpha(state and 0.75 or 0.15)
	end
end