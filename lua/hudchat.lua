if not WFHud.settings.custom_chat then
	return
end

Hooks:PostHook(HUDChat, "init", "init_wfhud", function (self)
	self._panel:hide()
	managers.chat:unregister_receiver(self._channel_id, self)
end)
