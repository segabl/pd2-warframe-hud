Hooks:PostHook(HUDChat, "init", "init_wfhud", function (self)
	self._panel:set_bottom(self._panel:parent():h())
end)
