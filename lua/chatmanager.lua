Hooks:PreHook(ChatManager, "receive_message_by_peer", "receive_message_by_peer_wfhud", function (self, channel_id, peer)
	self._last_message_peer = not self:is_peer_muted(peer) and peer
end)

Hooks:PostHook(ChatManager, "_receive_message", "_receive_message_wfhud", function (self, channel_id, name, message, color)
	self._last_message_peer = nil
end)
