HUDHealthBar = class()

HUDHealthBar.RIGHT_TO_LEFT = 1
HUDHealthBar.LEFT_TO_RIGHT = 2

function HUDHealthBar:init(panel, x, y, width, height, text_size, has_caps)
	self._direction = HUDHealthBar.RIGHT_TO_LEFT

	self._max_health = 1
	self._max_armor = 0

	self._health = 1
	self._armor = 0

	self._panel = panel:panel({
		x = x,
		y = y,
		w = width,
		h = (text_size and math.ceil(text_size * 0.85) or 0) + height,
		layer = 1
	})

	if text_size then
		self._health_armor_text = self._panel:text({
			color = WFHud.colors.health,
			text = "123456",
			font = tweak_data.menu.pd2_large_font,
			font_size = text_size,
			align = "right"
		})
	end

	self._health_bar = self._panel:bitmap({
		texture = "guis/textures/wfhud/bar",
		color = WFHud.colors.health,
		w = width,
		h = height
	})
	self._health_bar:set_bottom(self._panel:h())

	self._bg_bar = self._panel:bitmap({
		texture = "guis/textures/wfhud/bar",
		color = WFHud.colors.bg:with_alpha(0.5),
		x = has_caps and height * 0.25 or 0,
		w = has_caps and width - height * 0.5 or width,
		h = height * 0.85,
		layer = -1
	})
	self._bg_bar:set_center_y(self._health_bar:center_y())

	if has_caps then
		self._health_bar_cap_l = self._panel:bitmap({
			texture = "guis/textures/wfhud/bar_caps",
			texture_rect = { 0, 0, 32, 32 },
			color = WFHud.colors.default,
			x = 0,
			w = height,
			h = height,
			layer = 2
		})
		self._health_bar_cap_l:set_center_y(self._health_bar:center_y())

		self._health_bar_cap_r = self._panel:bitmap({
			texture = "guis/textures/wfhud/bar_caps",
			texture_rect = { 32, 0, -32, 32 },
			color = WFHud.colors.default,
			x = self._panel:w() - height,
			w = height,
			h = height,
			layer = 2
		})
		self._health_bar_cap_r:set_center_y(self._health_bar:center_y())
	end

	self._health_loss_indicator = panel:bitmap({
		visible = false,
		texture = "guis/textures/wfhud/bar",
		color = WFHud.colors.health,
		h = height * 4,
		layer = 2
	})
	self._health_loss_indicator:set_center_y(self._panel:y() + self._health_bar:center_y())

	self._armor_bar = self._panel:bitmap({
		texture = "guis/textures/wfhud/bar",
		color = WFHud.colors.shield,
		w = 0,
		h = height
	})
	self._armor_bar:set_bottom(self._panel:h())

	self._armor_loss_indicator = panel:bitmap({
		visible = false,
		texture = "guis/textures/wfhud/bar",
		color = WFHud.colors.shield,
		h = height * 4,
		layer = 2
	})
	self._armor_loss_indicator:set_center_y(self._panel:y() + self._health_bar:center_y())

	self._armor_bar_overlay_1 = self._panel:bitmap({
		visible = false,
		texture = "guis/textures/wfhud/shield_overlay",
		blend_mode = "add",
		color = WFHud.colors.shield:with_alpha(0.5),
		w = 0,
		h = height,
		layer = 1
	})

	self._armor_bar_overlay_2 = self._panel:bitmap({
		visible = false,
		texture = "guis/textures/wfhud/shield_overlay",
		blend_mode = "add",
		color = WFHud.colors.shield:with_alpha(0.5),
		w = 0,
		h = height,
		layer = 1
	})

	self._overlay_w = self._armor_bar_overlay_1:texture_width() * 0.5
	self._overlay_h = self._armor_bar_overlay_1:texture_height()
end

function HUDHealthBar:_start_shield_animation()
	if self._shield_animated then
		return
	end

	self._shield_animated = true

	self._armor_bar_overlay_1:set_visible(true)
	self._armor_bar_overlay_2:set_visible(true)

	self._armor_bar_overlay_1:animate(function (o)
		while true do
			over(7, function (t)
				local w, h = self._armor_bar:size()

				o:set_position(self._armor_bar:position())
				o:set_size(w, h)
				o:set_texture_rect(self._overlay_w - (self._overlay_w * t * 2) % self._overlay_w, (1 + math.sin(t * 360)) * 0.5 * (self._overlay_h - h), w, h)
			end)
		end
	end)

	self._armor_bar_overlay_2:animate(function (o)
		while true do
			over(12, function (t)
				local w, h = self._armor_bar:size()

				o:set_position(self._armor_bar:position())
				o:set_size(w, h)
				o:set_texture_rect(self._overlay_w - (self._overlay_w * t * 2) % self._overlay_w, (1 + math.cos(t * 360)) * 0.5 * (self._overlay_h - h), w, h)
			end)
		end
	end)
end

function HUDHealthBar:_stop_shield_animation()
	self._armor_bar_overlay_1:stop()
	self._armor_bar_overlay_2:stop()

	self._armor_bar_overlay_1:set_visible(false)
	self._armor_bar_overlay_2:set_visible(false)

	self._shield_animated = false
end

function HUDHealthBar:_set_health_armor_text()
	if not self._health_armor_text or self._custom_text then
		return
	end

	local health = tostring(math.round(self._health))
	local armor = self._max_armor > 0 and tostring(math.round(self._armor)) or ""
	local full = string.format("%s%s", armor, health)
	self._health_armor_text:set_text(full)
	self._health_armor_text:set_color(WFHud.colors.health)
	self._health_armor_text:set_range_color(0, armor:len(), WFHud.colors.shield)
end

function HUDHealthBar:set_custom_text(text)
	if not self._health_armor_text then
		return
	end

	self._custom_text = text
	if text then
		self._health_armor_text:set_text(text)
		self._health_armor_text:set_color(WFHud.colors.health)
	else
		self:_set_health_armor_text()
	end
end

function HUDHealthBar:set_direction(dir)
	self._direction = dir
end

function HUDHealthBar:set_health(current, total, instant)
	if self._health == current and self._max_health == total then
		return
	end

	self._max_health = total
	local max_ratio = self._max_health / (self._max_health + self._max_armor)

	if instant then
		self._health_bar:set_w((self._bg_bar:w() / self._max_health) * current * max_ratio)
		if self._direction == HUDHealthBar.RIGHT_TO_LEFT then
			self._health_bar:set_right(self._bg_bar:right())
		else
			self._health_bar:set_left(self._bg_bar:x())
		end
		self._health = current

		self:_set_health_armor_text()
		return
	end

	self._health_bar:stop()
	self._health_loss_indicator:stop()
	self._health_loss_indicator:set_visible(false)

	local start = self._health
	if current > self._health then

		self._health_bar:animate(function ()
			over(0.5, function (t)
				self:set_health(math.lerp(start, current, t), total, true)
			end)
		end)

	else

		self:set_health(current, total, true)
		self._health_loss_indicator:animate(function (o)
			o:set_w((self._bg_bar:w() / self._max_health) * (start - current) * max_ratio)
			if self._direction == HUDHealthBar.RIGHT_TO_LEFT then
				o:set_right(self._panel:x() + self._health_bar:x())
			else
				o:set_x(self._panel:x() + self._health_bar:right())
			end
			o:set_visible(true)
			over(0.2, function (t)
				o:set_alpha(1 - t)
			end)
			o:set_visible(false)
		end)

	end
end

function HUDHealthBar:set_armor(current, total, instant)
	if self._armor == current and self._max_armor == total then
		return
	end

	if self._max_armor <= 0 and total > 0 then
		self:_start_shield_animation()
	else
		self:_stop_shield_animation()
	end

	self._max_armor = total
	local max_ratio = self._max_armor / (self._max_health + self._max_armor)

	if instant then
		self._armor_bar:set_w((self._bg_bar:w() / self._max_armor) * current * max_ratio)
		if self._direction == HUDHealthBar.RIGHT_TO_LEFT then
			self._armor_bar:set_right(self._bg_bar:x() + self._bg_bar:w() * max_ratio)
		else
			self._armor_bar:set_left(self._bg_bar:right() - self._bg_bar:w() * max_ratio)
		end
		self._armor = current

		self:_set_health_armor_text()
		return
	end

	self._armor_bar:stop()
	self._armor_loss_indicator:stop()
	self._armor_loss_indicator:set_visible(false)

	local start = self._armor
	if current > self._armor then

		self._armor_bar:animate(function ()
			over(0.5, function (t)
				self:set_armor(math.lerp(start, current, t), total, true)
			end)
		end)

	else

		self:set_armor(current, total, true)
		self._armor_loss_indicator:animate(function (o)
			o:set_w((self._bg_bar:w() / self._max_armor) * (start - current) * max_ratio)
			if self._direction == HUDHealthBar.RIGHT_TO_LEFT then
				o:set_right(self._panel:x() + self._armor_bar:x())
			else
				o:set_left(self._panel:x() + self._armor_bar:right())
			end
			o:set_visible(true)
			over(0.2, function (t)
				o:set_alpha(1 - t)
			end)
			o:set_visible(false)
		end)

	end
end
