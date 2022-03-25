if not WFHud.settings.chat.enabled then
	return
end

Hooks:PostHook(HUDChat, "init", "init_wfhud", function (self)
	self._panel:hide()
	managers.chat:unregister_receiver(self._channel_id, self)
end)
