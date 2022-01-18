local mvec_add = mvector3.add
local mvec_dir = mvector3.direction
local mvec_dot = mvector3.dot
local mvec_mul = mvector3.multiply
local mvec_set = mvector3.set
local tmp_vec = Vector3()

HUDFloatingUnitLabel = class()

function HUDFloatingUnitLabel:init(panel, compact)
	self._compact = compact

	self._panel = panel:panel({
		visible = false,
		w = 240
	})

	self._unit_text = self._panel:text({
		text = "ENEMY",
		font = tweak_data.menu.medium_font,
		font_size = 20,
		color = WFHud.colors.default,
		align = "center"
	})

	self._health_bar = HUDHealthBar:new(self._panel, 0, 18, 112, 8, nil, true)
	self._health_bar._panel:set_center_x(self._panel:w() * 0.5)
	self._health_bar._panel:set_alpha(compact and 0 or 1)
	self._health_bar:set_direction(HUDHealthBar.LEFT_TO_RIGHT)

	self._level_text = self._panel:text({
		visible = not compact,
		text = "100",
		font = tweak_data.menu.medium_font,
		font_size = 24,
		color = WFHud.colors.default,
		align = "center",
		y = self._health_bar._panel:bottom() - 2
	})

	self._pointer = self._panel:bitmap({
		visible = not compact,
		texture = "guis/textures/wfhud/bar_caps",
		texture_rect = { 32, 0, 32, 32 },
		color = WFHud.colors.default:with_alpha(0.25),
		x = self._panel:w() * 0.5 - 16,
		y = self._health_bar._panel:bottom() - 6,
		w = 32,
		h = 32,
		layer = -1
	})

	self._panel:set_h(compact and self._health_bar._health_loss_indicator:bottom() or self._pointer:bottom())
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
	-- TODO: improve this mess
	if self._character_data and not self._linked_health_bar then
		local teammate_panel = managers.hud._teammate_panels[self._character_data and self._character_data.panel_id]
		self._linked_health_bar = teammate_panel and teammate_panel._wfhud_panel and teammate_panel._wfhud_panel:health_bar()
	end
	if self._linked_health_bar then
		hp, max_hp = self._linked_health_bar._health_ratio * self._linked_health_bar._max_health_ratio * 100, self._linked_health_bar._max_health_ratio * 100
		armor, max_armor = self._linked_health_bar._armor_ratio * self._linked_health_bar._max_armor_ratio * 100, self._linked_health_bar._max_armor_ratio * 100
	else
		hp, max_hp = (self._unit:character_damage()._health or 10) * 10, (self._unit:character_damage()._HEALTH_INIT or 10) * 10
		armor, max_armor = 0, 0
	end

	local skip_anim = self._panel:alpha() == 0 or self._health_bar._panel:alpha() == 0 or not self._panel:visible()
	self._health_bar:set_data(hp, max_hp, armor, max_armor, skip_anim)
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

function HUDFloatingUnitLabel:set_unit(unit, instant)
	if not alive(self._panel) then
		return
	end

	if unit == self._unit and not self._fading_out then
		return
	end

	local alpha = self._panel:alpha()

	if alive(unit) then
		self._unit = unit

		self._health_bar._set_data_instant = true

		self._character_data = managers.criminals:character_data_by_unit(unit)

		local info = HopLib:unit_info_manager():get_info(unit)
		if info then
			self._unit_text:set_text(self._compact and info:nickname() or info:nickname():upper())
			self._level_text:set_text(tostring(info:level() or self:_create_unit_level(info)))
		end

		self._fading_out = false

		self._panel:stop()

		if instant then
			self._panel:set_alpha(1)
			return
		end

		self._panel:animate(function (o)
			over((1 - alpha) * 0.25, function (t)
				o:set_alpha(math.lerp(alpha, 1, t))
			end)
		end)
	elseif not self._fading_out then
		self._fading_out = true

		self._panel:stop()

		if instant then
			self._panel:set_alpha(0)
			return
		end

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
				o:set_alpha(math.lerp(alpha, 1, t))
			end)
		end)
	elseif not self._health_fading_out then
		self._health_fading_out = true

		self._health_bar._panel:stop()
		self._health_bar._panel:animate(function (o)
			over(alpha * 0.25, function (t)
				o:set_alpha(math.lerp(alpha, 0, t))
			end)
		end)
	end
end

function HUDFloatingUnitLabel:destroy()
	self._panel:stop()
	self._panel:parent():remove(self._panel)
end
