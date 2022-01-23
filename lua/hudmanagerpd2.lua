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


local _add_name_label_original = HUDManager._add_name_label
function HUDManager:_add_name_label(data)
	local id = _add_name_label_original(self, data)

	local label_data = self._hud.name_labels[#self._hud.name_labels]
	if label_data and label_data.id == id then
		label_data.panel:set_visible(false)

		local wflabel = HUDFloatingUnitLabel:new(WFHud:panel(), true)
		wflabel:set_unit(data.unit)

		if WFHud._unit_aim_label and WFHud._unit_aim_label._unit == data.unit then
			WFHud._unit_aim_label:set_unit(nil, true)
		end

		self:add_updator("wfhud" .. id, callback(wflabel, wflabel, "update"))
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
		-- TODO (maybe)
	end

	return id
end

Hooks:PreHook(HUDManager, "_remove_name_label", "_remove_name_label_wfhud", function (self, id)
	for _, data in pairs(self._hud.name_labels) do
		if data.id == id then
			local unit_data = data.movement and data.movement._unit:unit_data() or data.vehicle and data.vehicle:unit_data()
			if unit_data and unit_data._wfhud_label then
				self:remove_updator("wfhud" .. id)
				unit_data._wfhud_label:destroy()
				unit_data._wfhud_label = nil
			end
			return
		end
	end
end)

function HUDManager:_update_name_labels(t, dt) end


Hooks:PostHook(HUDManager, "set_stamina_value", "set_stamina_value_wfhud", function (self, value)
	self._teammate_panels[HUDManager.PLAYER_PANEL]:set_stamina(value, nil)
end)

Hooks:PostHook(HUDManager, "set_max_stamina", "set_max_stamina_wfhud", function (self, value)
	self._teammate_panels[HUDManager.PLAYER_PANEL]:set_stamina(nil, value)
end)


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
