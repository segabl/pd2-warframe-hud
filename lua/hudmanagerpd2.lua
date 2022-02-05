Hooks:PreHook(HUDManager, "init", "init_wfhud", function (self)
	WFHud:setup()
end)

Hooks:PostHook(HUDManager, "update", "update_wfhud", function (self, t, dt)
	WFHud:update(t, dt)
end)

Hooks:PostHook(HUDManager, "set_enabled", "set_enabled_wfhud", function (self)
	WFHud:panel():show()
end)

Hooks:PostHook(HUDManager, "set_disabled", "set_disabled_wfhud", function (self)
	WFHud:panel():hide()
end)

Hooks:PostHook(HUDManager, "show", "show_wfhud", function (self, name)
	if name == PlayerBase.PLAYER_INFO_HUD_FULLSCREEN then
		WFHud:panel():show()
	end
end)

Hooks:PostHook(HUDManager, "hide", "hide_wfhud", function (self, name)
	if name == PlayerBase.PLAYER_INFO_HUD_FULLSCREEN then
		WFHud:panel():hide()
	end
end)


-- add custom name labels
local _add_name_label_original = HUDManager._add_name_label
function HUDManager:_add_name_label(data)
	local id = _add_name_label_original(self, data)

	local label_data = self._hud.name_labels[#self._hud.name_labels]
	if label_data and label_data.id == id then
		label_data.panel:set_visible(false)

		local wflabel = HUDFloatingUnitLabel:new(WFHud:panel())
		wflabel:set_unit(data.unit, true, true)
		wflabel._upd_id = "wfhud_name_label" .. id

		if WFHud._unit_aim_label and WFHud._unit_aim_label._unit == data.unit then
			WFHud._unit_aim_label:set_unit(nil, true)
		end

		self:add_updator(wflabel._upd_id, callback(wflabel, wflabel, "update"))
		data.unit:unit_data()._wfhud_label = wflabel
	end

	return id
end

local add_vehicle_name_label_original = HUDManager.add_vehicle_name_label
function HUDManager:add_vehicle_name_label(data)
	local id = add_vehicle_name_label_original(self, data)

	local label_data = self._hud.name_labels[#self._hud.name_labels]
	if label_data and label_data.id == id then
		label_data.panel:set_visible(false)

		local wflabel = HUDFloatingUnitLabel:new(WFHud:panel())
		wflabel:set_unit(data.unit, true, true)
		wflabel._upd_id = "wfhud_vehicle_label" .. id

		if WFHud._unit_aim_label and WFHud._unit_aim_label._unit == data.unit then
			WFHud._unit_aim_label:set_unit(nil, true)
		end

		self:add_updator(wflabel._upd_id, callback(wflabel, wflabel, "update"))
		data.unit:unit_data()._wfhud_label = wflabel
	end

	return id
end

Hooks:PreHook(HUDManager, "_remove_name_label", "_remove_name_label_wfhud", function (self, id)
	for _, data in pairs(self._hud.name_labels) do
		if data.id == id then
			local unit_data = data.movement and data.movement._unit:unit_data() or data.vehicle and data.vehicle:unit_data()
			if unit_data and unit_data._wfhud_label then
				self:remove_updator(unit_data._wfhud_label._upd_id)
				unit_data._wfhud_label:destroy()
				unit_data._wfhud_label = nil
			end
			return
		end
	end
end)

function HUDManager:_update_name_labels(t, dt) end


-- move ai stopped icon to icon list
function HUDManager:set_ai_stopped(ai_id, stopped)
	local teammate_panel = self._teammate_panels[ai_id]

	if not teammate_panel or stopped and not teammate_panel._ai or not teammate_panel._wfhud_item_list then
		return
	end

	if stopped then
		teammate_panel._wfhud_item_list:add_icon("ai_stop", tweak_data.hud_icons.ai_stopped.texture, tweak_data.hud_icons.ai_stopped.texture_rect)
	else
		teammate_panel._wfhud_item_list:remove_icon("ai_stop")
	end
end

if Keepers then
	Hooks:PostHook(Keepers, "reset_label", "reset_label_wfhud", function (self, unit, is_converted, icon)
		if is_converted then
			return
		end

		local data = managers.criminals:character_data_by_unit(unit)
		local teammate_panel = data and managers.hud._teammate_panels[data.panel_id]
		if not teammate_panel or not teammate_panel._ai or not teammate_panel._wfhud_item_list then
			return
		end

		if icon then
			teammate_panel._wfhud_item_list:add_icon("ai_stop", tweak_data.hud_icons:get_icon_data(icon))
		else
			teammate_panel._wfhud_item_list:remove_icon("ai_stop")
		end
	end)
end


-- Why are you using a custom interaction radial for the downed HUD?
Hooks:OverrideFunction(HUDManager, "pd_start_progress", function (self, current, total, msg)
	if not self:script(PlayerBase.PLAYER_DOWNED_HUD) then
		return
	end

	WFHud._interact_display:show_interaction_circle(utf8.to_upper(managers.localization:text(msg)), total)

	self._hud_player_downed:hide_timer()
end)

Hooks:OverrideFunction(HUDManager, "pd_stop_progress", function (self)
	if not self:script(PlayerBase.PLAYER_DOWNED_HUD) then
		return
	end

	WFHud._interact_display:hide_interaction_circle()

	self._hud_player_downed:show_timer()
end)


-- waypoint stuff
local wp_size = 32
local icon_size = wp_size * 0.5

local add_waypoint_original = HUDManager.add_waypoint
function HUDManager:add_waypoint(id, data, ...)
	local string_id = tostring(id)
	local bg_visible = not string_id:find("^susp") and (not CustomWaypoints or not string_id:find(CustomWaypoints.prefix))

	data.blend_mode = bg_visible and "normal" or data.blend_mode
	data.radius = data.radius or 200

	add_waypoint_original(self, id, data, ...)

	local hud = managers.hud:script(PlayerBase.PLAYER_INFO_HUD_PD2)
	if not hud then
		return
	end

	local ratio
	local wp_data = self._hud.waypoints[id]

	ratio = wp_data.bitmap:h() / wp_data.bitmap:w()
	if bg_visible then
		wp_data.bitmap:set_size(ratio < 1 and icon_size or icon_size / ratio, ratio < 1 and icon_size * ratio or icon_size)
		wp_data.bitmap:set_color((data.color or WFHud.colors.default):with_alpha(1))
		wp_data.size = Vector3(wp_size, wp_size)
	end

	ratio = wp_data.arrow:h() / wp_data.arrow:w()
	wp_data.arrow:set_size(ratio < 1 and icon_size or icon_size / ratio, ratio < 1 and icon_size * ratio or icon_size)
	wp_data.arrow:set_color((data.color or WFHud.colors.default):with_alpha(1))

	wp_data.text:set_font(WFHud.font_ids.default)
	wp_data.text:set_font_size(WFHud.font_sizes.small)
	local _, _, w, _ = wp_data.text:text_rect()
	wp_data.text:set_w(w)
	if wp_data.distance then
		wp_data.distance:set_font(WFHud.font_ids.default)
		wp_data.distance:set_font_size(WFHud.font_sizes.small)
	end
	if wp_data.timer_gui then
		wp_data.timer_gui:set_font(WFHud.font_ids.default)
		wp_data.timer_gui:set_font_size(WFHud.font_sizes.small)
	end

	wp_data.bg = hud.panel:bitmap({
		visible = bg_visible,
		layer = wp_data.bitmap:layer() - 1,
		name = "bg" .. id,
		texture = "guis/textures/wfhud/icons",
		texture_rect = { 96, 0, 48, 48 },
		w = wp_size,
		h = wp_size,
		color = data.color or WFHud.colors.default
	})
end

Hooks:PostHook(HUDManager, "change_waypoint_icon", "change_waypoint_icon_wfhud", function (self, id)
	local wp_data = self._hud.waypoints[id]
	if not wp_data or not wp_data.bg:visible() then
		return
	end

	local ratio = wp_data.bitmap:h() / wp_data.bitmap:w()
	wp_data.bitmap:set_size(ratio < 1 and icon_size or icon_size / ratio, ratio < 1 and icon_size * ratio or icon_size)
	wp_data.size = Vector3(wp_size, wp_size)
end)

Hooks:PostHook(HUDManager, "change_waypoint_arrow_color", "change_waypoint_arrow_color_wfhud", function (self, id, color)
	local wp_data = self._hud.waypoints[id]
	if not wp_data or not wp_data.bg:visible() then
		return
	end

	wp_data.bitmap:set_color(color:with_alpha(1))
	wp_data.bg:set_color(color:with_alpha(1))
end)

Hooks:PreHook(HUDManager, "remove_waypoint", "remove_waypoint_wfhud", function (self, id)
	local wp_data = self._hud.waypoints[id]
	if not wp_data then
		return
	end

	local hud = managers.hud:script(PlayerBase.PLAYER_INFO_HUD_PD2)
	if not hud then
		return
	end

	local waypoint_panel = hud.panel
	waypoint_panel:remove(wp_data.bg)
end)

local mvec_norm = mvector3.normalize
local mvec_set = mvector3.set
local mvec_sub = mvector3.subtract
local wp_pos = Vector3()
local wp_dir = Vector3()
local wp_dir_normalized = Vector3()
local wp_cam_forward = Vector3()
local wp_onscreen_direction = Vector3()
local wp_onscreen_target_pos = Vector3()

-- all this just to disable scale change :(
Hooks:OverrideFunction(HUDManager, "_update_waypoints", function (self, t, dt)
	local cam = managers.viewport:get_current_camera()

	if not cam then
		return
	end

	local cam_pos = managers.viewport:get_current_camera_position()
	local cam_rot = managers.viewport:get_current_camera_rotation()

	mrotation.y(cam_rot, wp_cam_forward)

	for _, data in pairs(self._hud.waypoints) do
		local panel = data.bitmap:parent()

		if data.state == "sneak_present" then
			data.current_position = Vector3(panel:center_x(), panel:center_y())

			data.bitmap:set_center(data.current_position.x, data.current_position.y)
			data.bg:set_center(data.current_position.x, data.current_position.y)

			data.slot = nil
			data.state = "present_ended"
			data.in_timer = 0

			if data.distance then
				data.distance:set_visible(true)
			end
		elseif data.state == "present" then
			data.current_position = Vector3(panel:center_x() + data.slot_x, panel:center_y() + panel:center_y() / 2)

			data.bitmap:set_center(data.current_position.x, data.current_position.y)
			data.bg:set_center(data.current_position.x, data.current_position.y)
			data.text:set_center_x(data.bitmap:center_x())
			data.text:set_top(data.bitmap:bottom())

			data.present_timer = data.present_timer - dt

			if data.present_timer <= 0 then
				data.slot = nil
				data.state = "present_ended"
				data.in_timer = 0

				if data.distance then
					data.distance:set_visible(true)
				end
			end
		else
			data.position = data.unit and data.unit:position() or data.position

			mvec_set(wp_pos, self._saferect:world_to_screen(cam, data.position))
			mvec_set(wp_dir, data.position)
			mvec_sub(wp_dir, cam_pos)
			mvec_set(wp_dir_normalized, wp_dir)
			mvec_norm(wp_dir_normalized)

			local dot = mvector3.dot(wp_cam_forward, wp_dir_normalized)

			if dot < 0 or panel:outside(mvector3.x(wp_pos), mvector3.y(wp_pos)) then
				if data.state ~= "offscreen" then
					data.state = "offscreen"

					data.arrow:set_visible(true)

					data.off_timer = 0 - (1 - data.in_timer)

					if data.distance then
						data.distance:set_visible(false)
					end

					if data.timer_gui then
						data.timer_gui:set_visible(false)
					end
				end

				local direction = wp_onscreen_direction
				local panel_center_x, panel_center_y = panel:center()

				mvector3.set_static(direction, wp_pos.x - panel_center_x, wp_pos.y - panel_center_y, 0)
				mvec_norm(direction)

				local distance = data.radius * tweak_data.scale.hud_crosshair_offset_multiplier
				local target_pos = wp_onscreen_target_pos

				mvector3.set_static(target_pos, panel_center_x + mvector3.x(direction) * distance, panel_center_y + mvector3.y(direction) * distance, 0)

				data.off_timer = math.clamp(data.off_timer + dt / data.move_speed, 0, 1)

				if data.off_timer ~= 1 then
					mvec_set(data.current_position, math.bezier({
						data.current_position,
						data.current_position,
						target_pos,
						target_pos
					}, data.off_timer))
				else
					mvec_set(data.current_position, target_pos)
				end

				data.bitmap:set_center(mvector3.x(data.current_position), mvector3.y(data.current_position))
				data.bg:set_center(mvector3.x(data.current_position), mvector3.y(data.current_position))
				data.arrow:set_center(mvector3.x(data.current_position) + direction.x * 24, mvector3.y(data.current_position) + direction.y * 24)

				local angle = math.X:angle(direction) * math.sign(direction.y)
				data.arrow:set_rotation(angle)

				data.text:set_center_x(data.bitmap:center_x())
				data.text:set_top(data.bitmap:bottom())
			else
				if data.state == "offscreen" then
					data.state = "onscreen"

					data.arrow:set_visible(false)

					data.in_timer = 0 - (1 - data.off_timer)

					if data.distance then
						data.distance:set_visible(true)
					end

					if data.timer_gui then
						data.timer_gui:set_visible(true)
					end
				end

				if data.in_timer ~= 1 then
					data.in_timer = math.clamp(data.in_timer + dt / data.move_speed, 0, 1)

					mvec_set(data.current_position, math.bezier({
						data.current_position,
						data.current_position,
						wp_pos,
						wp_pos
					}, data.in_timer))
				else
					mvec_set(data.current_position, wp_pos)
				end

				data.bitmap:set_center(mvector3.x(data.current_position), mvector3.y(data.current_position))
				data.bg:set_center(mvector3.x(data.current_position), mvector3.y(data.current_position))

				data.text:set_center_x(data.bitmap:center_x())
				data.text:set_top(data.bitmap:bottom())

				if data.distance then
					local length = wp_dir:length()
					data.distance:set_text(string.format("%.0f", length / 100) .. "m")
					data.distance:set_center_x(data.bitmap:center_x())
					data.distance:set_top(data.bitmap:bottom())
				end
			end
		end

		if data.timer_gui then
			data.timer_gui:set_center_x(data.bitmap:center_x())
			data.timer_gui:set_bottom(data.bitmap:top())

			if data.pause_timer == 0 then
				data.timer = data.timer - dt
				local text = data.timer < 0 and "00" or (math.round(data.timer) < 10 and "0" or "") .. math.round(data.timer)
				data.timer_gui:set_text(text)
			end
		end
	end
end)


-- present hints as mid text
function HUDManager:show_hint(params)
	params.time = params.time or 2
	params.is_hint = true
	self:present_mid_text(params)
end


-- move mask on text
Hooks:PostHook(HUDManager, "show", "show_wfhud", function (self, name)
	local mask_off_hud = Idstring("guis/mask_off_hud")
	if name == mask_off_hud and self:alive("guis/mask_off_hud") then
		local mask_on_text = self:script("guis/mask_off_hud").mask_on_text
		mask_on_text:set_font(WFHud.font_ids.default)
		mask_on_text:set_font_size(WFHud.font_sizes.default)
		mask_on_text:parent():set_y(mask_on_text:parent():parent():h() * 0.75)
	end
end)
