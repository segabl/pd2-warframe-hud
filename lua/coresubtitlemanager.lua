core:module("CoreSubtitleManager")

Hooks:PostHook(SubtitleManager, "show_subtitle", "show_subtitle_wfhud", function (self, string_id, duration, macros, ...)
	if not Utils:IsInLoadingState() and _G.WFHud._objective_panel then
		_G.WFHud._objective_panel:set_subtitle(string_id:match("^(.-)_"), managers.localization:text(string_id, macros), duration)
	end
end)

Hooks:PostHook(SubtitleManager, "clear_subtitle", "clear_subtitle_wfhud", function (self)
	if _G.WFHud._objective_panel then
		_G.WFHud._objective_panel:set_subtitle(nil, nil, nil)
	end
end)
