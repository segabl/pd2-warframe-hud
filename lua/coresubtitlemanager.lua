core:module("CoreSubtitleManager")

Hooks:OverrideFunction(SubtitleManager, "_update_presenter_visibility", function (self)
	self._show_subtitles = (not managers.user or managers.user:get_setting("subtitle"))
	if self._custom_subs_shown then
		self:presenter():hide()
	end
end)

Hooks:PostHook(SubtitleManager, "show_subtitle", "show_subtitle_wfhud", function (self, string_id, duration, macros, ...)
	if self._show_subtitles and not Utils:IsInLoadingState() and _G.WFHud.objective_panel then
		_G.WFHud.objective_panel:set_subtitle(string_id:match("^(.-)_"), managers.localization:text(string_id, macros), duration or 3)
		if not self._custom_subs_shown then
			self._custom_subs_shown = true
			self:_update_presenter_visibility()
		end
	end
end)

Hooks:PostHook(SubtitleManager, "clear_subtitle", "clear_subtitle_wfhud", function (self)
	if _G.WFHud.objective_panel then
		_G.WFHud.objective_panel:set_subtitle(nil, nil, nil)
	end
end)
