
local icons = {
	blue_eagle = "guis/dlcs/gage_pack_jobs/textures/pd2/gage_popup_img_blue",
	green_mantis = "guis/dlcs/gage_pack_jobs/textures/pd2/gage_popup_img_green",
	purple_snake = "guis/dlcs/gage_pack_jobs/textures/pd2/gage_popup_img_purple",
	red_spider = "guis/dlcs/gage_pack_jobs/textures/pd2/gage_popup_img_red",
	yellow_bull = "guis/dlcs/gage_pack_jobs/textures/pd2/gage_popup_img_yellow"
}

Hooks:PostHook(GageAssignmentBase, "show_pickup_msg", "show_pickup_msg_wfhud", function (self, peer_id)
	if (managers.network:session() and managers.network:session():peer(peer_id or 1)) == managers.network:session():local_peer() then
		local name_id = tweak_data.gage_assignment:get_value(self._assignment, "name_id")
		WFHud:add_special_pickup(icons[self._assignment], { 0, 0, 128, 192 }, managers.localization:text(name_id))
	end
end)
