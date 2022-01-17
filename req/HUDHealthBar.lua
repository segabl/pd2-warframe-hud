HUDHealthBar = class()

HUDHealthBar.RIGHT_TO_LEFT = 1
HUDHealthBar.LEFT_TO_RIGHT = 2

function HUDHealthBar:init(panel, x, y, width, height, text_size)
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
		w = width,
		h = height * 0.85,
		layer = -1
	})
	self._bg_bar:set_center_y(self._health_bar:center_y())

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
	if self._health_armor_text then
		local health = tostring(math.ceil(self._health))
		local armor = self._max_armor > 0 and tostring(math.ceil(self._armor)) or ""
		local full = string.format("%s%s", armor, health)
		self._health_armor_text:set_text(full)
		self._health_armor_text:set_color(WFHud.colors.health)
		self._health_armor_text:set_range_color(0, armor:len(), WFHud.colors.shield)
	end
end

function HUDHealthBar:update(t, dt)
	if self._max_armor > 0 then
		self._armor_bar_overlay_1:set_position(self._armor_bar:position())
		self._armor_bar_overlay_2:set_position(self._armor_bar:position())

		local w, h = self._armor_bar:size()

		self._armor_bar_overlay_1:set_size(w, h)
		self._armor_bar_overlay_2:set_size(w, h)

		self._armor_bar_overlay_1:set_texture_rect(self._overlay_w - w - ((t * 80) % (self._overlay_w * 0.5)), (1 + math.sin(t * 10)) * 0.5 * (self._overlay_h - h), w, h)
		self._armor_bar_overlay_2:set_texture_rect(self._overlay_w - w - ((t * 40) % (self._overlay_w * 0.5)), (1 + math.cos(t * 20)) * 0.5 * (self._overlay_h - h), w, h)
	end
end

function HUDHealthBar:set_direction(dir)
	self._direction = dir
end

function HUDHealthBar:set_max_health(max_health)
	self._max_health = max_health
end

function HUDHealthBar:set_max_armor(max_armor)
	self._max_armor = max_armor

	if self._max_armor > 0 then
		self:_start_shield_animation()
	else
		self:_stop_shield_animation()
	end
end

function HUDHealthBar:set_health(value, instant)
	local max_ratio = self._max_health / (self._max_health + self._max_armor)

	if instant then
		self._health_bar:set_w((self._panel:w() / self._max_health) * value * max_ratio)
		if self._direction == HUDHealthBar.RIGHT_TO_LEFT then
			self._health_bar:set_right(self._panel:w())
		else
			self._health_bar:set_left(0)
		end
		self._health = value

		self:_set_health_armor_text()

		return
	end

	self._health_bar:stop()
	self._health_loss_indicator:stop()
	self._health_loss_indicator:set_visible(false)

	local start = self._health
	if value > self._health then

		self._health_bar:animate(function ()
			over(0.5, function (t)
				self:set_health(math.lerp(start, value, t), true)
			end)
		end)

	else

		self:set_health(value, true)
		self._health_loss_indicator:animate(function (o)
			o:set_w((self._panel:w() / self._max_health) * (start - value) * max_ratio)
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

function HUDHealthBar:set_armor(value, instant)
	local max_ratio = self._max_armor / (self._max_health + self._max_armor)

	if instant then
		self._armor_bar:set_w((self._panel:w() / self._max_armor) * value * max_ratio)
		if self._direction == HUDHealthBar.RIGHT_TO_LEFT then
			self._armor_bar:set_right(self._panel:w() * max_ratio)
		else
			self._armor_bar:set_left(self._panel:w() - self._panel:w() * max_ratio)
		end
		self._armor = value

		self:_set_health_armor_text()

		return
	end

	self._armor_bar:stop()
	self._armor_loss_indicator:stop()
	self._armor_loss_indicator:set_visible(false)

	local start = self._armor
	if value > self._armor then

		self._armor_bar:animate(function ()
			over(0.5, function (t)
				self:set_armor(math.lerp(start, value, t), true)
			end)
		end)

	else

		self:set_armor(value, true)
		self._armor_loss_indicator:animate(function (o)
			o:set_w((self._panel:w() / self._max_armor) * (start - value) * max_ratio)
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
