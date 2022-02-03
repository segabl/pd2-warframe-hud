
core:module("CoreSubtitlePresenter")

local show_text_original = Hooks:GetFunction(OverlayPresenter, "show_text")
Hooks:OverrideFunction(OverlayPresenter, "show_text", function (self, text, ...)
	return show_text_original(self, (Utils:IsInLoadingState() or not _G.WFHud._objective_panel) and text or "", ...)
end)
