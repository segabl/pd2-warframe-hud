local hud_scale = WFHud.settings.hud_scale
local font_scale = WFHud.settings.font_scale

---@class HUDSpecialPickup
---@field new fun(self, panel, y):HUDSpecialPickup
HUDSpecialPickup = HUDSpecialPickup or WFHud:panel_class()

function HUDSpecialPickup:init(panel, y)
	self._pickup_queue = {}

	self._panel = panel:panel({
		layer = 10,
		visible = false,
		h = 256 * hud_scale,
		y = y
	})

	self._bg = self._panel:bitmap({
		layer = -2,
		texture = "guis/textures/wfhud/pickup_bg"
	})
	self._bg:set_size(self._bg:texture_width() * hud_scale, self._bg:texture_height() * hud_scale)

	self._bg_effect_panel = self._panel:panel({
		layer = -3,
		alpha = 0,
		w = 256 * hud_scale,
		h = 256 * hud_scale
	})

	self._bg_dots = self._bg_effect_panel:bitmap({
		layer = -2,
		texture = "guis/textures/wfhud/pickup_bg_dots",
		w = self._bg_effect_panel:w() * 0.8,
		h = self._bg_effect_panel:h() * 0.8,
		color = Color("ddc16f")
	})

	self._bg_rays_big = self._bg_effect_panel:bitmap({
		layer = -1,
		texture = "guis/textures/wfhud/pickup_bg_rays_big",
		w = self._bg_effect_panel:w(),
		h = self._bg_effect_panel:h(),
		color = Color("ddc16f"),
		alpha = 0.75
	})

	self._bg_rays_small = self._bg_effect_panel:bitmap({
		texture = "guis/textures/wfhud/pickup_bg_rays_small",
		w = self._bg_effect_panel:w(),
		h = self._bg_effect_panel:h(),
		color = Color("1a1a26"),
		alpha = 0.75
	})

	self._flare_bg = self._panel:bitmap({
		visible = false,
		layer = -1,
		alpha = 0,
		texture = "guis/textures/wfhud/pickup_bg_flare",
		w = 512 * hud_scale,
		h = 54 * hud_scale,
		blend_mode = "add",
		color = Color("ddc16f"):with_alpha(0.5)
	})

	self._flare = self._panel:bitmap({
		visible = false,
		layer = 1,
		alpha = 0,
		texture = "guis/textures/wfhud/pickup_bg_flare",
		w = 1024 * hud_scale,
		h = 64 * hud_scale,
		blend_mode = "add"
	})

	self._icon = self._panel:bitmap({
		texture = "sweden",
		w = 64 * hud_scale,
		h = 64 * hud_scale
	})

	self._text = self._panel:text({
		text = "Sweden",
		font = WFHud.fonts.default,
		font_size = WFHud.font_sizes.default * font_scale * hud_scale,
		color = WFHud.settings.colors.default,
		align = "center",
		w = self._bg:w(),
		h = WFHud.font_sizes.default * font_scale * hud_scale
	})

	self:_layout()
end

function HUDSpecialPickup:_layout()
	self._bg:set_right(0)
	self._bg:set_center_y(self._panel:h() * 0.5)

	self._bg_effect_panel:set_center(self._bg:w() * 0.4, self._bg:center_y())
	self._bg_dots:set_center(self._bg_effect_panel:w() * 0.5, self._bg_effect_panel:h() * 0.5)
	self._bg_rays_big:set_center(self._bg_effect_panel:w() * 0.5, self._bg_effect_panel:h() * 0.5)
	self._bg_rays_small:set_center(self._bg_effect_panel:w() * 0.5, self._bg_effect_panel:h() * 0.5)

	self._flare_bg:set_center(self._bg_effect_panel:center())
	self._flare:set_center(self._bg_effect_panel:center())

	self._icon:set_right(0)
	self._icon:set_bottom(self._bg_effect_panel:center_y() + self._icon:h() * 0.25)

	self._text:set_right(0)
	self._text:set_y(self._bg:bottom())
end

function HUDSpecialPickup:_animate_show_panel()
	XAudio.Source:new(WFHud.sounds.special_pickup):set_volume(0.5)

	self:_layout()

	self._panel:set_alpha(1)
	self._panel:show()

	over(0.25, function (t)
		self._bg:set_right(self._bg:w() * t)
	end)

	self._bg_effect_panel:set_alpha(0)
	self._bg_effect_panel:show()
	self._bg_effect_panel:animate(callback(self, self, "_animate_background"))

	self._flare:animate(callback(self, self, "_animate_flare"))

	local icon_x = self._bg_effect_panel:center_x()
	over(0.25, function (t)
		self._icon:set_center_x(math.lerp(-icon_x, icon_x, t))
		self._text:set_center_x(math.lerp(-icon_x, icon_x, t))

		self._bg_effect_panel:set_alpha(t)
	end)

	wait(3)

	over(0.25, function (t)
		self._panel:set_alpha(1 - t)
	end)

	self._bg_effect_panel:stop()
	self._bg_effect_panel:hide()

	self._panel:hide()

	if #self._pickup_queue > 0 then
		self:_show_pickup(table.remove(self._pickup_queue, 1), true)
	end
end

function HUDSpecialPickup:_animate_background()
	local t = 0
	while true do
		self._bg_dots:set_alpha(math.abs(math.sin(t * 90)))
		self._bg_rays_big:set_rotation((t * 10) % 360)
		self._bg_rays_small:set_rotation(360 - ((t * 10) % 360))

		t = t + coroutine.yield()
	end
end

function HUDSpecialPickup:_animate_flare()
	self._flare_bg:set_alpha(0)
	self._flare_bg:show()

	self._flare:set_alpha(0)
	self._flare:show()

	local t = 0
	while t < 2 do
		self._flare_bg:set_alpha(1 - math.max(0, t - 1))
		self._flare:set_alpha(math.max(0, 1 - t))

		t = t + coroutine.yield()
	end

	self._flare_bg:hide()
	self._flare:hide()
end

function HUDSpecialPickup:_show_pickup(pickup, coroutine_call)
	self._icon:set_image(pickup.icon or "guis/textures/pd2/none_icon")
	local w, h
	if pickup.icon_rect then
		self._icon:set_texture_rect(unpack(pickup.icon_rect))
		w, h = pickup.icon_rect[3], pickup.icon_rect[4]
	else
		w, h = self._icon:texture_width(), self._icon:texture_height()
	end
	self._icon:set_h(self._icon:w() * (h / w))

	self._text:set_text(pickup.text)

	if coroutine_call then
		self:_animate_show_panel()
	else
		self._panel:stop()
		self._panel:animate(callback(self, self, "_animate_show_panel"))
	end
end

function HUDSpecialPickup:add(icon, icon_rect, text)
	local data = {
		icon = icon,
		icon_rect = icon_rect,
		text = text
	}

	if self._panel:visible() then
		table.insert(self._pickup_queue, data)
	else
		self:_show_pickup(data)
	end
end

function HUDSpecialPickup:destroy()
	if not alive(self._panel) then
		return
	end

	self._bg_effect_panel:stop()
	self._flare:stop()

	self._panel:stop()
	self._panel:parent():remove(self._panel)
end
