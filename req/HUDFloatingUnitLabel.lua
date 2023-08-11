local hud_scale = WFHud.settings.hud_scale
local font_scale = WFHud.settings.font_scale

local mvec_add = mvector3.add
local mvec_dis = mvector3.distance
local mvec_mul = mvector3.multiply
local mvec_set = mvector3.set
local tmp_vec1 = Vector3()
local tmp_vec2 = Vector3()

---@class HUDFloatingUnitLabel
---@field new fun(self, panel, health_visible, managed_unit):HUDFloatingUnitLabel
HUDFloatingUnitLabel = HUDFloatingUnitLabel or WFHud:panel_class()

---@param panel Panel
---@param health_visible boolean?
---@param managed_unit Unit?
function HUDFloatingUnitLabel:init(panel, health_visible, managed_unit)
	self._health_faded_out = true
	self._panel_faded_out = true
	self._health_visible = health_visible -- this is to keep the health bar visible on non permanent labels

	self._panel = panel:panel({
		alpha = 0,
		w = 240 * hud_scale,
		layer = -100
	})

	self._unit_text = self._panel:text({
		text = "ENEMY",
		font = WFHud.fonts.default,
		font_size = WFHud.font_sizes.small * font_scale * hud_scale,
		color = WFHud.settings.colors.default,
		align = "center"
	})

	self._health_bar = HUDHealthBar:new(self._panel, 0, 0, 112 * hud_scale, 8 * hud_scale, nil, true)
	self._health_bar:set_direction(HUDHealthBar.LEFT_TO_RIGHT)

	self._level_text = self._panel:text({
		text = "100",
		font = WFHud.fonts.bold,
		font_size = WFHud.font_sizes.default * font_scale * hud_scale,
		color = WFHud.settings.colors.default,
		align = "center"
	})

	self._pointer = self._panel:bitmap({
		texture = "guis/textures/wfhud/bar_caps",
		texture_rect = { 32, 0, 32, 32 },
		color = WFHud.settings.colors.default:with_alpha(0.25),
		w = 32 * hud_scale,
		h = 32 * hud_scale,
		layer = -1
	})

	self:_layout()

	-- Is this label used for a single unit only?
	if managed_unit then
		if WFHud.unit_aim_label and WFHud.unit_aim_label._unit == managed_unit then
			WFHud.unit_aim_label:set_unit(nil, true)
		end

		self:set_unit(managed_unit, true, true)

		self._managed_upd_id = "wfhud_name_label" .. tostring(self)
		managers.hud:add_updator(self._managed_upd_id, callback(self, self, "update"))
	end
end

function HUDFloatingUnitLabel:_layout()
	local w = self._panel:w()

	self._unit_text:set_position(0, 0)

	self._health_bar:_layout()

	self._health_bar:set_alpha((self._health_visible or not self._compact) and 1 or 0)
	self._health_bar:set_center_x(w * 0.5)
	self._health_bar:set_y(self._unit_text:font_size())

	self._level_text:set_visible(not self._compact)
	self._level_text:set_position(0, self._health_bar:bottom() - 2)

	self._pointer:set_visible(not self._compact)
	self._pointer:set_center_x(w * 0.5)
	self._pointer:set_y(self._health_bar:bottom() - 6)

	self._panel:set_h(self._pointer:bottom())

	self._label_offset = self._compact and self._panel:h() - self._health_bar:bottom() or 0
end

function HUDFloatingUnitLabel:_create_unit_level(unit_info)
	local index = tweak_data:difficulty_to_index(Global.game_settings.difficulty)
	local diff_mul = managers.groupai:state()._difficulty_value or 0
	local base_lvl = 5 + (index - 2) * 15 + math.random(0, 5) + diff_mul * 30
	unit_info._level = math.ceil(base_lvl * (unit_info:is_civilian() and 0.1 or unit_info:is_special() and 1.25 or unit_info:is_boss() and 1.5 or 1))
	return unit_info._level
end

function HUDFloatingUnitLabel:update(t, dt)
	if not alive(self._unit) or not alive(self._panel) then
		if self._managed_upd_id then
			self:destroy()
		end
		return
	end

	local ws = managers.hud._workspace
	local cam = managers.viewport:get_current_camera()

	if cam then
		local pos = self._unit_mvmt and (self._unit_mvmt._obj_head and self._unit_mvmt._obj_head:position() or self._unit_mvmt:m_head_pos())
		if not pos then
			pos = tmp_vec2
			mvec_set(pos, math.UP)
			mvec_mul(pos, self._health_bar_offset)
			mvec_add(pos, self._unit:position())
		end

		mvec_set(tmp_vec1, math.UP)
		mvec_mul(tmp_vec1, 30 - mvec_dis(cam:position(), pos) / 1000)
		mvec_add(tmp_vec1, pos)

		local screen_pos = ws:world_to_screen(cam, tmp_vec1)
		self._panel:set_center_x(screen_pos.x)
		self._panel:set_bottom(screen_pos.y + self._label_offset)
		self._panel:set_visible(screen_pos.z > 0)
	end

	local hp, max_hp, armor, max_armor, invulnerable
	-- TODO: improve this mess
	if self._character_data and not self._linked_health_bar then
		local teammate_panel = managers.hud._teammate_panels[self._character_data and self._character_data.panel_id]
		self._linked_health_bar = teammate_panel and teammate_panel._wfhud_panel and teammate_panel._wfhud_panel:health_bar()
	end

	if self._linked_health_bar then
		hp, max_hp = self._linked_health_bar._health_ratio * self._linked_health_bar._max_health_ratio * 100, self._linked_health_bar._max_health_ratio * 100
		armor, max_armor = self._linked_health_bar._armor_ratio * self._linked_health_bar._max_armor_ratio * 100, self._linked_health_bar._max_armor_ratio * 100
		invulnerable = self._linked_health_bar._invulnerable
	elseif self._unit_dmg then
		local dmg = self._unit_dmg
		local has_shield = self._unit_base and self._unit_base._is_module
		hp, max_hp = (dmg._health or 10) * 10, (dmg._HEALTH_INIT or dmg._current_max_health or 10) * 10
		armor, max_armor = (has_shield and dmg._shield_health or 0) * 10, (has_shield and dmg._SHIELD_HEALTH_INIT or 0) * 10
		invulnerable = dmg._invulnerable or dmg._immortal and dmg._health <= 1 or (dmg._health_ratio or 0) <= (dmg._lower_health_percentage_limit or -1)
	else
		hp, max_hp = 1, 1
		armor, max_armor = 0, 0
		invulnerable = true
	end

	local skip_anim = self._panel:alpha() == 0 or self._health_bar:alpha() == 0 or not self._panel:visible()
	self._health_bar:set_data(hp, max_hp, armor, max_armor, skip_anim)
	self._health_bar:set_invulnerable(invulnerable)
end

function HUDFloatingUnitLabel:set_unit(unit, instant, compact_override)
	if not alive(self._panel) then
		return
	end

	if unit == self._unit and not self._panel_faded_out then
		return
	end

	local alpha = self._panel:alpha()
	local unit_info = alive(unit) and HopLib:unit_info_manager():get_info(unit)
	if unit_info then
		self._unit = unit
		self._unit_dmg = unit:character_damage()
		self._unit_mvmt = unit:movement()
		self._unit_base = unit:base()

		self._health_bar._set_data_instant = true

		self._character_data = managers.criminals:character_data_by_unit(unit)

		if unit:vehicle_driving() then
			self._health_bar:set_health_color(WFHud.settings.colors.object)
			self._health_bar_offset = unit:vehicle_driving().hud_label_offset or 100
			self._compact = true
		else
			if self._unit_base and self._unit_base.has_tag and self._unit_base:has_tag("tank") then
				self._health_bar:set_health_color(WFHud.settings.colors.armor)
			else
				self._health_bar:set_health_color(WFHud.settings.colors.health)
			end
			self._health_bar_offset = 100
			self._compact = false
		end

		if compact_override ~= nil then
			self._compact = compact_override
		end

		self._unit_text:set_text(unit_info:nickname())
		self._level_text:set_text(tostring(unit_info:level() or self:_create_unit_level(unit_info)))

		self._panel_faded_out = false

		self._panel:stop()

		self:_layout()

		if instant then
			self._panel:set_alpha(1)
			return
		end

		self._panel:animate(function (o)
			over((1 - alpha) * 0.25, function (t)
				o:set_alpha(math.lerp(alpha, 1, t))
			end)
		end)
	elseif not self._panel_faded_out then
		self._panel_faded_out = true

		self._panel:stop()

		if instant then
			self._panel:set_alpha(0)
			return
		end

		self._panel:animate(function (o)
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

	if not self._health_faded_out ~= not state then
		return
	end

	local alpha = self._health_bar:alpha()
	if state then
		self._health_faded_out = false

		self._health_bar:stop()

		self:_layout()

		self._health_bar:animate(function (o)
			over((1 - alpha) * 0.25, function (t)
				o:set_alpha(math.lerp(alpha, 1, t))
			end)
		end)
	else
		self._health_faded_out = true

		self._health_bar:stop()
		self._health_bar:animate(function (o)
			over(alpha * 0.25, function (t)
				o:set_alpha(math.lerp(alpha, 0, t))
			end)
		end)
	end
end

function HUDFloatingUnitLabel:destroy()
	if self._managed_upd_id then
		if managers.hud then
			managers.hud:remove_updator(self._managed_upd_id)
		end
		self._managed_upd_id = nil
	end

	if not alive(self._panel) then
		return
	end

	self._panel:stop()
	self._panel:parent():remove(self._panel)
end
