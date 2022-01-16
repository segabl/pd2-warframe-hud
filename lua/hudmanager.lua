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
		if label_data.movement then
			local wflabel = HUDFloatingUnitLabel:new(hud.panel, true)
			wflabel:set_unit(data.unit)

			self:add_updator("wfhud" .. id, callback(wflabel, wflabel, "update"))
			label_data.movement._wfhud_label = wflabel
		end
	end

	return id
end

Hooks:PreHook(HUDManager, "_remove_name_label", "_remove_name_label_wfhud", function (self, id)
	for _, data in pairs(self._hud.name_labels) do
		if data.id == id then
			if data.movement._wfhud_label then
				self:remove_updator("wfhud" .. id)
				data.movement._wfhud_label:destroy()
			end
			return
		end
	end
end)

function HUDManager:_update_name_labels(t, dt) end
