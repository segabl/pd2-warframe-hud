if not WFHud.settings.chat.enabled then
	return
end

Hooks:PostHook(HUDChat, "init", "init_wfhud", function (self)
	self._panel:hide()
	self._panel:set_alpha(0)
	managers.chat:unregister_receiver(self._channel_id, self)
end)
