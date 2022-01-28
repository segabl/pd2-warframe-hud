-- we're really gonna have to do tag team stuff here
local mapping = {
	sync_tag_team = {
		enabled = true, values = { "player", "tag_team_base" }
	},
	end_tag_team = {
		enabled = false, values = { "player", "tag_team_base" }
	}
}

Hooks:PostHook(BaseNetworkSession, "send_to_peers", "send_to_peers_wfhud", function (self, name)
	local m = mapping[name]
	if m then
		if m.enabled then
			WFHud:add_buff(unpack(m.values))
		else
			WFHud:remove_buff(unpack(m.values))
		end
	end
end)
