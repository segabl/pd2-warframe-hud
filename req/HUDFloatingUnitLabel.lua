local mvec_add = mvector3.add
local mvec_dir = mvector3.direction
local mvec_dot = mvector3.dot
local mvec_mul = mvector3.multiply
local mvec_set = mvector3.set
local tmp_vec = Vector3()

HUDFloatingUnitLabel = class()

function HUDFloatingUnitLabel:init(panel, compact)
	self._panel = panel:panel({
		visible = false,
		w = 320
	})

	self._unit_text = self._panel:text({
		text = "ENEMY",
		font = tweak_data.menu.medium_font,
		font_size = 20,
		color = WFHud.colors.default,
		align = "center"
	})

	self._health_bar = HUDHealthBar:new(self._panel, 0, 16, 128, 8, nil)
	self._health_bar._panel:set_center_x(self._panel:w() * 0.5)
	self._health_bar._panel:set_alpha(compact and 0 or 1)
	self._health_bar:set_direction(HUDHealthBar.LEFT_TO_RIGHT)

	self._health_bar_cap_l = self._panel:bitmap({
		alpha = compact and 0 or 1,
		texture = "guis/textures/wfhud/bar_caps",
		texture_rect = { 0, 0, 32, 32 },
		color = WFHud.colors.default,
		w = 8,
		h = 8,
		layer = 2
	})
	self._health_bar_cap_l:set_center(self._health_bar._panel:x() + 2, self._health_bar._panel:y() + self._health_bar._health_bar:center_y())

	self._health_bar_cap_r = self._panel:bitmap({
		alpha = compact and 0 or 1,
		texture = "guis/textures/wfhud/bar_caps",
		texture_rect = { 32, 0, -32, 32 },
		color = WFHud.colors.default,
		w = 8,
		h = 8,
		layer = 2
	})
	self._health_bar_cap_r:set_center(self._health_bar._panel:right() - 2, self._health_bar._panel:y() + self._health_bar._health_bar:center_y())

	self._level_text = self._panel:text({
		visible = not compact,
		text = "100",
		font = tweak_data.menu.medium_font,
		font_size = 26,
		color = WFHud.colors.default,
		align = "center",
		y = self._health_bar._panel:bottom()
	})

	self._health_bar_pointer = self._panel:bitmap({
		visible = not compact,
		texture = "guis/textures/wfhud/bar_caps",
		texture_rect = { 32, 0, 32, 32 },
		color = WFHud.colors.default:with_alpha(0.25),
		x = self._panel:w() * 0.5 - 16,
		y = self._health_bar._panel:bottom() - 4,
		w = 32,
		h = 32,
		layer = -1
	})

	self._panel:set_h(compact and self._health_bar_cap_r:bottom() or self._health_bar_pointer:bottom())
end

function HUDFloatingUnitLabel:update(t, dt)
	if not alive(self._unit) or not alive(self._panel) then
		return
	end

	local ws = managers.hud._workspace
	local cam = managers.viewport:get_current_camera()

	if cam then
		local movement = self._unit:movement()
		local pos = movement._obj_head and movement._obj_head:position() or movement:m_head_pos()

		local dis = mvec_dir(tmp_vec, cam:position(), pos)
		self._panel:set_visible(mvec_dot(cam:rotation():y(), tmp_vec) >= 0)

		mvec_set(tmp_vec, math.UP)
		mvec_mul(tmp_vec, 15 + 1000 / dis)
		mvec_add(tmp_vec, pos)

		local screen_pos = ws:world_to_screen(cam, tmp_vec)
		self._panel:set_center_x(screen_pos.x)
		self._panel:set_bottom(screen_pos.y)
	end

	local hp, max_hp, armor, max_armor
	if self._tracked_health_bar then
		hp, max_hp = self._tracked_health_bar._health, self._tracked_health_bar._max_health
		armor, max_armor = self._tracked_health_bar._armor, self._tracked_health_bar._max_armor
	else
		hp, max_hp = (self._unit:character_damage()._health or 10) * 10, (self._unit:character_damage()._HEALTH_INIT or 10) * 10
		armor, max_armor = 0, 0
	end

	if self._unit_hp ~= hp or self._unit_armor ~= armor then
		self._health_bar:set_max_health(max_hp)
		self._health_bar:set_health(hp, self._unit_hp == nil)
		self._health_bar:set_max_armor(armor)
		self._health_bar:set_armor(max_armor, self._unit_armor == nil)
		self._unit_hp = hp
		self._unit_armor = armor
	end
end

function HUDFloatingUnitLabel:_create_unit_level(unit_info)
	local index = tweak_data:difficulty_to_index(Global.game_settings.difficulty)
	if unit_info:type() == "team_ai" then
		return index * 10 + 20
	end
	local diff_mul = managers.groupai:state()._difficulty_value or 0
	local base_lvl = 1 + math.round((index - 1) * 10 + math.random() * 5 + diff_mul * 40)
	unit_info._level = math.ceil(base_lvl * (unit_info:is_civilian() and 0.2 or unit_info:is_special() and 1.5 or unit_info:is_boss() and 2 or 1))
	return unit_info._level
end

function HUDFloatingUnitLabel:set_unit(unit)
	if not alive(self._panel) then
		return
	end

	if unit == self._unit and not self._fading_out then
		return
	end

	local alpha = self._panel:alpha()

	if alive(unit) then
		self._unit = unit
		self._unit_hp = nil
		self._unit_armor = nil

		local character_data = managers.criminals:character_data_by_unit(unit)
		local teammate_panel = managers.hud._teammate_panels[character_data and character_data.panel_id]
		self._tracked_health_bar = teammate_panel and teammate_panel._wfhud_panel and teammate_panel._wfhud_panel:health_bar()

		local info = HopLib:unit_info_manager():get_info(unit)
		if info then
			self._unit_text:set_text(info:nickname():upper())
			self._level_text:set_text(tostring(info:level() or self:_create_unit_level(info)))
		end

		self._fading_out = false

		self._panel:stop()
		self._panel:animate(function (o)
			over((1 - alpha) * 0.25, function (t)
				o:set_alpha(math.lerp(alpha, 1, t))
			end)
		end)
	elseif not self._fading_out then
		self._fading_out = true

		self._panel:stop()
		self._panel:animate(function (o)
			wait((not alive(self._unit) or self._unit:character_damage()._dead) and 0 or 0.5)
			over(alpha * 0.25, function (t)
				o:set_alpha(math.lerp(alpha, 0, t))
			end)
		end)
	end
end

function HUDFloatingUnitLabel:set_health_visible(state)
	if not alive(self._panel) then
		return
	end

	local alpha = self._health_bar._panel:alpha()

	if state then
		self._health_fading_out = false

		self._health_bar._panel:stop()
		self._health_bar._panel:animate(function (o)
			over((1 - alpha) * 0.25, function (t)
				local a = math.lerp(alpha, 1, t)
				o:set_alpha(a)
				self._health_bar_cap_l:set_alpha(a)
				self._health_bar_cap_r:set_alpha(a)
			end)
		end)
	elseif not self._health_fading_out then
		self._health_fading_out = true

		self._health_bar._panel:stop()
		self._health_bar._panel:animate(function (o)
			over(alpha * 0.25, function (t)
				local a = math.lerp(alpha, 0, t)
				o:set_alpha(a)
				self._health_bar_cap_l:set_alpha(a)
				self._health_bar_cap_r:set_alpha(a)
			end)
		end)
	end
end

function HUDFloatingUnitLabel:destroy()
	self._panel:stop()
	self._panel:parent():remove(self._panel)
end
