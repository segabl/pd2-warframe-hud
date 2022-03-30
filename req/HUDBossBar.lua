local hud_scale = WFHud.settings.hud_scale
local font_scale = WFHud.settings.font_scale

---@class HUDBossBar
---@field new fun():HUDBossBar
HUDBossBar = HUDBossBar or WFHud:panel_class()

function HUDBossBar:init(panel, y)
	self._panel = panel:panel({
		layer = 100,
		visible = false,
		alpha = 0,
		w = panel:w() * 0.4 * math.min(hud_scale, 1),
		y = y
	})
	self._panel:set_center_x(panel:w() * 0.5)

	self._name_text = self._panel:text({
		text = "THE BOSS",
		font = WFHud.fonts.boss,
		font_size = WFHud.font_sizes.huge * font_scale * hud_scale * 0.75,
		kern = not WFHud.use_default_fonts and -12,
		color = WFHud.settings.colors.boss
	})
	self._name_text:set_h(self._name_text:font_size())

	self._bg1 = self._panel:bitmap({
		layer = -2,
		texture = "guis/textures/wfhud/boss_hud",
		texture_rect = { 0, 0, 640, 16 },
		w = 640 * hud_scale * 0.75,
		h = 16 * hud_scale * 0.75,
		y = self._name_text:bottom() - 4 * hud_scale
	})
	self._bg1:set_center_x(self._panel:w() * 0.5)

	self:_create_health_bar()

	self._bg2 = self._panel:bitmap({
		layer = -2,
		texture = "guis/textures/wfhud/boss_hud",
		texture_rect = { 0, 16, 640, 48 },
		w = 640 * hud_scale * 0.75,
		h = 48 * hud_scale * 0.75,
		y = self._health_bar:bottom() - 2 * hud_scale
	})
	self._bg2:set_center_x(self._panel:w() * 0.5)

	self._level_text = self._panel:text({
		layer = -1,
		text = "99",
		font = WFHud.fonts.default,
		font_size = WFHud.font_sizes.default * font_scale * hud_scale,
		color = WFHud.settings.colors.boss,
		align = "center"
	})
	self._level_text:set_h(self._level_text:font_size())
	self._level_text:set_center_y(self._bg2:center_y())

	self._panel:set_h(math.max(self._level_text:bottom(), self._bg2:bottom()))
end

function HUDBossBar:_create_health_bar()
	self._health_bar = HUDHealthBar:new(self._panel, 1, self._bg1:bottom() + 4 * hud_scale, self._panel:w() - 2, 8 * hud_scale, nil, nil, true)
	self._health_bar:set_direction(HUDHealthBar.LEFT_TO_RIGHT)
	self._health_bar._bg_bar:set_h(self._health_bar._health_bar:h())
	self._health_bar:_layout()

	self._health_bar_border = self._panel:polyline({
		color = Color.black,
		line_width = 1,
		closed = true,
		points = {
			Vector3(self._health_bar:x() - 0.5, self._health_bar:y() - 0.5, 0),
			Vector3(self._health_bar:right() + 0.5, self._health_bar:y() - 0.5, 0),
			Vector3(self._health_bar:right() + 0.5, self._health_bar:bottom() + 0.5, 0),
			Vector3(self._health_bar:x() - 0.5, self._health_bar:bottom() + 0.5, 0),
		}
	})

	self._health_bar_shadow = self._panel:gradient({
		orientation = "vertical",
		w = self._health_bar:w() + 2,
		h = 8 * hud_scale,
		y = self._health_bar:bottom(),
		gradient_points = {
			0, Color.black:with_alpha(0.5),
			1, Color.transparent
		}
	})
end

function HUDBossBar:_clbk_unit_damaged(unit)
	local char_dmg = unit:character_damage()
	local hp = (char_dmg._health or 10) * 10
	local max_hp = (char_dmg._HEALTH_INIT or char_dmg._current_max_health or 10) * 10

	self._health_bar:set_data(hp, max_hp, 0, 0)
	self._health_bar:set_invulnerable(char_dmg._immortal or char_dmg._invulnerable)

	if hp <= 0 or char_dmg._dead then
		self:set_unit(nil)
	end
end

function HUDBossBar:_clbk_unit_destroyed()
	self:set_unit(nil)
end

function HUDBossBar:_animate_show(panel)
	panel:show()
	over(1.5, function (t)
		panel:set_alpha(t)
	end)
	panel:set_alpha(1)
end

function HUDBossBar:_animate_hide(panel)
	over(0.5, function (t)
		panel:set_alpha(1 - t)
	end)
	panel:set_alpha(0)
	panel:hide()
end

function HUDBossBar:set_unit(unit)
	if not alive(unit) and not self._fading_out then
		if alive(self._unit) then
			self._unit:character_damage():remove_listener("wfhud_boss_bar")
			self._unit:base():remove_destroy_listener("wfhud_boss_bar")
		end
		self._unit = nil

		self._fading_out = true
		self._panel:animate(callback(self, self, "_animate_hide"))
		return
	end

	if self._unit then
		return
	end

	local unit_info = HopLib:unit_info_manager():get_info(unit)
	if not unit_info then
		return
	end

	self._name_text:set_text(unit_info:nickname():upper())
	local _, _, w = self._name_text:text_rect()
	self._name_text:set_w(w - self._name_text:kern() * hud_scale * font_scale * 0.5)
	self._name_text:set_center_x(self._panel:w() * 0.5)

	self._level_text:set_text(tostring(unit_info:level() or HUDFloatingUnitLabel._create_unit_level(self, unit_info)))

	self._health_bar:set_data(1, 1, 0, 0, true)
	self._health_bar:set_invulnerable(false)

	unit:character_damage():add_listener("wfhud_boss_bar", nil, callback(self, self, "_clbk_unit_damaged"))
	unit:base():add_destroy_listener("wfhud_boss_bar", callback(self, self, "_clbk_unit_destroyed"))

	self:_clbk_unit_damaged(unit)

	self._unit = unit

	self._fading_out = false

	self._panel:animate(callback(self, self, "_animate_show"))
end

dofile(WFHud.mod_path .. "assets/boss/boss.lua")
