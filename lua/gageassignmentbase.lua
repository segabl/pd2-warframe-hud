Hooks:PostHook(GageAssignmentBase, "show_pickup_msg", "show_pickup_msg_wfhud", function (self, peer_id)
	if (managers.network:session() and managers.network:session():peer(peer_id or 1)) == managers.network:session():local_peer() then
		local name_id = tweak_data.gage_assignment:get_value(self._assignment, "name_id")
		WFHud:add_special_pickup("guis/textures/wfhud/hud_icons/pickup_" .. self._assignment, nil, managers.localization:text(name_id))
	end
end)
