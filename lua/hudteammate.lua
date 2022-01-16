Hooks:PostHook(HUDTeammate, "init", "init_wfhud", function (self, i, teammates_panel, is_player, width)
	local main_panel = teammates_panel:parent()
	self._wfhud_panel = HUDPlayerPanel:new(main_panel, 0, 0, self._main_player)

	if self._main_player then
		self._wfhud_panel._panel:set_righttop(main_panel:w(), 32)
	else
		self._wfhud_panel._panel:set_righttop(main_panel:w(), 32 + 80 + (i - 1) * (self._wfhud_panel._panel:h() + 4))
	end
	self._wfhud_panel._panel:set_visible(false)
end)

Hooks:PostHook(HUDTeammate, "add_panel", "add_panel_wfhud", function (self)
	self._panel:set_visible(false)
	self._wfhud_panel._panel:set_visible(true)
end)

Hooks:PostHook(HUDTeammate, "remove_panel", "remove_panel_wfhud", function (self)
	self._wfhud_panel._panel:set_visible(false)
end)

Hooks:PostHook(HUDTeammate, "set_name", "set_name_wfhud", function (self, name)
	if self._main_player then
		local spec = managers.skilltree:get_specialization_value("current_specialization")
		name = string.format("%s [%u]", managers.localization:to_upper_text(tweak_data.skilltree.specializations[spec].name_id), managers.experience:current_level())
	end
	self._wfhud_panel:set_name(name)
end)

Hooks:PostHook(HUDTeammate, "set_callsign", "set_callsign", function (self, id)
	self._wfhud_panel:set_peer_id(id)
end)

Hooks:PostHook(HUDTeammate, "set_health", "set_health_wfhud", function (self, data)
	self._wfhud_panel:health_bar():set_max_health(data.total * 10)
	self._wfhud_panel:health_bar():set_health(data.current * 10)
end)

Hooks:PostHook(HUDTeammate, "set_armor", "set_armor_wfhud", function (self, data)
	self._wfhud_panel:health_bar():set_max_armor(data.total * 10)
	self._wfhud_panel:health_bar():set_armor(data.current * 10)
end)
