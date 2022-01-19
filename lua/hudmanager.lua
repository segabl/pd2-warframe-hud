Hooks:PostHook(HUDManager, "_setup_player_info_hud_pd2", "_setup_player_info_hud_pd2_wfhud", function (self)
	WFHud:setup(self)
end)

Hooks:PostHook(HUDManager, "update", "update_wfhud", function (self, t, dt)
	WFHud:update(t, dt)
end)


local _add_name_label_original = HUDManager._add_name_label
function HUDManager:_add_name_label(data)
	local id = _add_name_label_original(self, data)

	local label_data = self._hud.name_labels[#self._hud.name_labels]
	if label_data and label_data.id == id then
		label_data.panel:set_visible(false)

		local hud = self:script(PlayerBase.PLAYER_INFO_HUD_FULLSCREEN_PD2)

		local wflabel = HUDFloatingUnitLabel:new(hud.panel, true)
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
