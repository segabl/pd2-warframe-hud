
core:module("CoreSubtitlePresenter")

local show_text_original = Hooks:GetFunction(OverlayPresenter, "show_text")
Hooks:OverrideFunction(OverlayPresenter, "show_text", function (self, ...)
	if Utils:IsInLoadingState() or not _G.WFHud._objective_panel then
		return show_text_original(self, ...)
	end
end)
