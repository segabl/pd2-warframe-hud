local hud_scale = WFHud.settings.hud_scale
local font_scale = WFHud.settings.font_scale

---@class HUDHealthBar
HUDHealthBar = HUDHealthBar or WFHud:panel_class()

HUDHealthBar.RIGHT_TO_LEFT = 1
HUDHealthBar.LEFT_TO_RIGHT = 2

HUDHealthBar.ANIM_TIME_GAIN = 0.5
HUDHealthBar.ANIM_TIME_LOSS = 0.2

function HUDHealthBar:init(panel, x, y, width, height, text_size, has_caps, bar_texture)
	self._direction = HUDHealthBar.RIGHT_TO_LEFT

	self._max_health_ratio = 0
	self._max_armor_ratio = 0

	self._health_ratio = 0
	self._armor_ratio = 0

	self._has_caps = has_caps

	self._set_data_instant = true

	self._health_color = WFHud.colors.health
	self._shield_color = WFHud.colors.shield

	self._panel = panel:panel({
		x = x,
		y = y,
		w = width,
		h = (text_size and math.ceil(text_size * 0.9) or 0) + height,
		layer = 1
	})

	if text_size then
		self._font_size = text_size

		self._health_text = self._panel:text({
			color = self._health_color,
			text = "100",
			font = text_size > WFHud.font_sizes.default * font_scale * hud_scale and WFHud.fonts.large or WFHud.fonts.default,
			font_size = text_size,
			align = "right"
		})

		self._armor_text = self._panel:text({
			color = WFHud.colors.shield,
			text = "100",
			font = text_size > WFHud.font_sizes.default * font_scale * hud_scale and WFHud.fonts.large or WFHud.fonts.default,
			font_size = text_size,
			align = "right"
		})
	end

	self._health_bar = self._panel:bitmap({
		texture = bar_texture or "guis/textures/wfhud/bar",
		color = self._health_color,
		w = 0,
		h = height
	})

	if has_caps then
		self._health_bar_cap_l = self._panel:bitmap({
			texture = "guis/textures/wfhud/bar_caps",
			texture_rect = { 0, 0, 32, 32 },
			color = WFHud.colors.default,
			w = height,
			h = height,
			layer = 2
		})

		self._health_bar_cap_r = self._panel:bitmap({
			texture = "guis/textures/wfhud/bar_caps",
			texture_rect = { 32, 0, -32, 32 },
			color = WFHud.colors.default,
			w = height,
			h = height,
			layer = 2
		})
	end

	self._health_loss_indicator = panel:bitmap({
		alpha = 0,
		texture = "guis/textures/wfhud/bar",
		color = self._health_color,
		h = height * 4,
		layer = 2
	})

	self._armor_bar = self._panel:bitmap({
		texture = bar_texture or "guis/textures/wfhud/bar",
		color = WFHud.colors.shield,
		w = 0,
		h = height
	})

	self._armor_loss_indicator = panel:bitmap({
		alpha = 0,
		texture = "guis/textures/wfhud/bar",
		color = WFHud.colors.shield,
		h = height * 4,
		layer = 2
	})

	self._armor_bar_overlay_1 = self._panel:bitmap({
		visible = false,
		texture = "guis/textures/wfhud/shield_overlay",
		blend_mode = "add",
		color = WFHud.colors.shield,
		alpha = 0.5,
		w = 0,
		h = height,
		layer = 1
	})

	self._armor_bar_overlay_2 = self._panel:bitmap({
		visible = false,
		texture = "guis/textures/wfhud/shield_overlay",
		blend_mode = "add",
		color = WFHud.colors.shield,
		alpha = 0.5,
		w = 0,
		h = height,
		layer = 1
	})

	self._bg_bar = self._panel:bitmap({
		texture = bar_texture or "guis/textures/wfhud/bar",
		color = WFHud.colors.bg:with_alpha(0.5),
		w = has_caps and width - height * 0.5 or width,
		h = height * 0.85,
		layer = -1
	})

	self._invulnerability_overlay = self._panel:bitmap({
		visible = false,
		texture = "guis/textures/wfhud/invulnerability_overlay",
		h = height,
		layer = 2
	})
	self._invulnerability_overlay:set_w(self._invulnerability_overlay:texture_width() * (height / self._invulnerability_overlay:texture_height()))

	self._overlay_w = self._armor_bar_overlay_1:texture_width() * 0.5
	self._overlay_h = self._armor_bar_overlay_1:texture_height()

	self:_layout()
end

function HUDHealthBar:_layout()
	self._health_bar:set_bottom(self._panel:h())
	self._armor_bar:set_bottom(self._panel:h())

	self._health_loss_indicator:set_center_y(self._panel:y() + self._health_bar:center_y())
	self._armor_loss_indicator:set_center_y(self._panel:y() + self._armor_bar:center_y())

	self._bg_bar:set_center(self._panel:w() * 0.5, self._health_bar:center_y())

	self._invulnerability_overlay:set_center(self._bg_bar:center_x(), self._bg_bar:center_y())

	if self._has_caps then
		self._health_bar_cap_l:set_x(0)
		self._health_bar_cap_l:set_center_y(self._bg_bar:center_y())

		self._health_bar_cap_r:set_right(self._panel:w())
		self._health_bar_cap_r:set_center_y(self._bg_bar:center_y())
	end
end

function HUDHealthBar:_start_shield_animation()
	if self._shield_animated then
		return
	end

	self._shield_animated = true

	self._armor_bar_overlay_1:set_visible(true)
	self._armor_bar_overlay_2:set_visible(true)

	self._armor_bar_overlay_1:animate(function (o)
		local t = 0
		while true do
			local w, h = self._armor_bar:size()
			o:set_position(self._armor_bar:position())
			o:set_size(w, h)
			o:set_texture_rect(self._overlay_w - (self._overlay_w * t * 0.35) % self._overlay_w, (1 + math.sin(t * 30)) * 0.5 * (self._overlay_h - h), w, h)
			t = t + coroutine.yield()
		end
	end)

	self._armor_bar_overlay_2:animate(function (o)
		local t = 0
		while true do
			local w, h = self._armor_bar:size()
			o:set_position(self._armor_bar:position())
			o:set_size(w, h)
			o:set_texture_rect(self._overlay_w - (self._overlay_w * t * 0.2) % self._overlay_w, (1 + math.cos(t * 45)) * 0.5 * (self._overlay_h - h), w, h)
			t = t + coroutine.yield()
		end
	end)
end

function HUDHealthBar:_stop_shield_animation()
	if not self._shield_animated then
		return
	end

	self._armor_bar_overlay_1:stop()
	self._armor_bar_overlay_2:stop()

	self._armor_bar_overlay_1:set_visible(false)
	self._armor_bar_overlay_2:set_visible(false)

	self._shield_animated = false
end

function HUDHealthBar:_layout_health_armor_text()
	local _, _, w = self._health_text:text_rect()
	self._armor_text:set_right(self._panel:w() - w)
end

function HUDHealthBar:set_invulnerable(state)
	if not not self._invulnerable == not not state then
		return
	end

	self._invulnerable = state
	self._invulnerability_overlay:set_visible(state)
	self:set_health_color(self._health_color)
	self:set_shield_color(self._shield_color)
end

function HUDHealthBar:set_health_color(color)
	self._health_color = color or WFHud.colors.health

	local avg = (self._health_color.r + self._health_color.g + self._health_color.b) / 3
	self._health_color_invul = Color(avg, avg, avg)

	local use_color = self._invulnerable and self._health_color_invul or self._health_color
	self._health_bar:set_color(use_color)
	self._health_loss_indicator:set_color(use_color)
	if self._health_text then
		self._health_text:set_color(use_color)
	end
end

function HUDHealthBar:set_shield_color(color)
	self._shield_color = color or WFHud.colors.shield

	local avg = (self._shield_color.r + self._shield_color.g + self._shield_color.b) / 3
	self._shield_color_invul = Color(avg, avg, avg)

	local use_color = self._invulnerable and self._shield_color_invul or self._shield_color
	self._armor_bar:set_color(use_color)
	self._armor_loss_indicator:set_color(use_color)
	if self._armor_text then
		self._armor_text:set_color(use_color)
	end

	self._armor_bar_overlay_1:set_color(use_color)
	self._armor_bar_overlay_2:set_color(use_color)
end

function HUDHealthBar:set_health_text(text, override)
	if not self._health_text then
		return
	end

	if override == nil then
		if self._health_text_override then
			self._health_text_override = text
			return
		else
			self._health_text:set_text(text)
		end
	elseif override then
		if not self._health_text_override then
			self._health_text_override = self._health_text:text()
		end
		self._health_text:set_text(text)
		local _, _, w = self._health_text:text_rect()
		local scale = math.min(self._health_text:parent():w() / w, 1)
		self._health_text:set_font_size(self._font_size * scale)
	else
		if self._health_text_override then
			self._health_text:set_text(self._health_text_override)
			self._health_text:set_font_size(self._font_size)
			self._health_text_override = nil
		else
			return
		end
	end

	self:_layout_health_armor_text()
end

function HUDHealthBar:set_armor_text(text, override)
	if not self._armor_text then
		return
	end

	if override == nil then
		if self._armor_text_override then
			self._armor_text_override = text
			return
		else
			self._armor_text:set_text(text)
		end
	elseif override then
		if not self._armor_text_override then
			self._armor_text_override = self._armor_text:text()
		end
		self._armor_text:set_text(text)
	else
		if self._armor_text_override then
			self._armor_text:set_text(self._armor_text_override)
			self._armor_text_override = nil
		else
			return
		end
	end

	self:_layout_health_armor_text()
end

function HUDHealthBar:set_direction(dir)
	self._direction = dir
end

function HUDHealthBar:set_data(health, max_health, armor, max_armor, instant)
	if not health or not max_health or not armor or not max_armor then
		return
	end

	local total_value = max_health + max_armor
	local max_health_ratio = max_health / total_value
	local max_armor_ratio = max_armor / total_value
	local health_ratio = math.min(health / max_health, 1)
	local armor_ratio = math.min(armor / max_armor, 1)
	local max_ratio_changed = max_health_ratio ~= self._max_health_ratio or max_armor_ratio ~= self._max_armor_ratio

	instant = instant or self._set_data_instant

	if health_ratio < self._health_ratio or instant or max_ratio_changed then
		self._health_bar:stop()
		self._health_bar:set_w(math.round(self._bg_bar:w() * max_health_ratio * health_ratio))

		if instant or health_ratio >= self._health_ratio then
			self:set_health_text(tostring(math.round(health)))
		else
			-- animate health loss
			self._health_loss_indicator:stop()
			self._health_loss_indicator:animate(function (o)
				o:set_w(math.max(1, math.round(self._bg_bar:w() * max_health_ratio * (self._health_ratio - health_ratio))))
				if self._direction == HUDHealthBar.RIGHT_TO_LEFT then
					o:set_x(self._panel:x() + self._health_bar:x())
				else
					o:set_x(self._panel:x() + self._health_bar:right())
				end
				o:set_alpha(1)
				over(HUDHealthBar.ANIM_TIME_LOSS, function (t)
					o:set_alpha(1 - t)
				end)
				o:set_alpha(0)
			end)

			if self._health_text then
				self._health_text:stop()
				self._health_text:animate(function (o)
					local from = self._health_ratio * max_health
					over(HUDHealthBar.ANIM_TIME_LOSS, function (t)
						self:set_health_text(tostring(math.round(math.lerp(from, health, t))))
					end)
				end)
			end
		end
	elseif health_ratio > self._health_ratio then
		-- animate health gain
		self._health_bar:stop()
		self._health_bar:animate(function (o)
			local from = self._health_ratio
			over(HUDHealthBar.ANIM_TIME_GAIN, function (t)
				o:set_w(math.round(self._bg_bar:w() * max_health_ratio * math.lerp(from, health_ratio, t)))
				if self._direction == HUDHealthBar.RIGHT_TO_LEFT then
					o:set_right(self._bg_bar:right())
				else
					o:set_left(self._bg_bar:x())
				end
			end)
		end)

		if self._health_text then
			self._health_text:stop()
			self._health_text:animate(function (o)
				local from = self._health_ratio * max_health
				over(HUDHealthBar.ANIM_TIME_GAIN, function (t)
					self:set_health_text(tostring(math.round(math.lerp(from, health, t))))
				end)
			end)
		end
	end

	if max_armor_ratio > 0 then
		if self._max_armor_ratio == 0 then
			self:_start_shield_animation()
		end
	elseif self._max_armor_ratio > 0 then
		self:_stop_shield_animation()
	end

	if armor_ratio < self._armor_ratio or instant or max_ratio_changed then
		self._armor_bar:stop()
		self._armor_bar:set_w(math.round(self._bg_bar:w() * max_armor_ratio * armor_ratio))

		if instant or armor_ratio >= self._armor_ratio then
			self:set_armor_text(max_armor_ratio > 0 and tostring(math.round(armor)) or "")
		else
			-- animate armor loss
			self._armor_loss_indicator:stop()
			self._armor_loss_indicator:animate(function (o)
				o:set_w(math.max(1, math.round(self._bg_bar:w() * max_armor_ratio * (self._armor_ratio - armor_ratio))))
				if self._direction == HUDHealthBar.RIGHT_TO_LEFT then
					o:set_x(self._panel:x() + self._armor_bar:x())
				else
					o:set_x(self._panel:x() + self._armor_bar:right())
				end
				o:set_alpha(1)
				over(HUDHealthBar.ANIM_TIME_LOSS, function (t)
					o:set_alpha(1 - t)
				end)
				o:set_alpha(0)
			end)

			if self._armor_text then
				self._armor_text:stop()
				self._armor_text:animate(function (o)
					local from = self._armor_ratio * max_armor
					over(HUDHealthBar.ANIM_TIME_LOSS, function (t)
						self:set_armor_text(tostring(math.round(math.lerp(from, armor, t))))
					end)
				end)
			end
		end
	elseif max_armor > 0 and armor_ratio > self._armor_ratio then
		-- animate armor gain
		self._armor_bar:stop()
		self._armor_bar:animate(function (o)
			local from = self._armor_ratio
			over(HUDHealthBar.ANIM_TIME_GAIN, function (t)
				o:set_w(math.round(self._bg_bar:w() * max_armor_ratio * math.lerp(from, armor_ratio, t)))
				if self._direction == HUDHealthBar.RIGHT_TO_LEFT then
					o:set_right(math.round(self._bg_bar:x() + self._bg_bar:w() * max_armor_ratio))
				else
					o:set_left(math.round(self._bg_bar:right() - self._bg_bar:w() * max_armor_ratio))
				end
			end)
		end)

		if self._armor_text then
			self._armor_text:stop()
			self._armor_text:animate(function (o)
				local from = self._armor_ratio * max_armor
				over(HUDHealthBar.ANIM_TIME_GAIN, function (t)
					self:set_armor_text(tostring(math.round(math.lerp(from, armor, t))))
				end)
			end)
		end
	end

	-- set bar positions
	if self._direction == HUDHealthBar.RIGHT_TO_LEFT then
		self._health_bar:set_right(self._bg_bar:right())
		self._armor_bar:set_right(math.round(self._bg_bar:x() + self._bg_bar:w() * max_armor_ratio))
	else
		self._health_bar:set_left(self._bg_bar:x())
		self._armor_bar:set_left(math.round(self._bg_bar:right() - self._bg_bar:w() * max_armor_ratio))
	end

	self._set_data_instant = nil

	self._max_health_ratio = max_health_ratio
	self._max_armor_ratio = max_armor_ratio
	self._health_ratio = health_ratio
	self._armor_ratio = armor_ratio
end

function HUDHealthBar:destroy()
	if not alive(self._panel) then
		return
	end

	self:_stop_shield_animation()

	self._health_text:stop()
	self._armor_text:stop()
	self._health_bar:stop()
	self._armor_bar:stop()
	self._health_loss_indicator:stop()
	self._armor_loss_indicator:stop()

	self._health_loss_indicator:parent():remove(self._health_loss_indicator)
	self._armor_loss_indicator:parent():remove(self._armor_loss_indicator)

	self._panel:stop()
	self._panel:parent():remove(self._panel)
end
