Hooks:OverrideFunction(HUDInteraction, "show_interact", function (self, data)
	WFHud.interact_display:show_interact(data.text:upper())
end)

Hooks:OverrideFunction(HUDInteraction, "remove_interact", function (self)
	WFHud.interact_display:hide_interact()
end)

Hooks:OverrideFunction(HUDInteraction, "show_interaction_bar", function (self)
	WFHud.interact_display:show_interaction_circle(managers.interaction:active_unit() and managers.localization:to_upper_text(managers.interaction:active_unit():interaction()._tweak_data.action_text_id or "hud_action_generic"))
end)

Hooks:OverrideFunction(HUDInteraction, "hide_interaction_bar", function (self, complete)
	WFHud.interact_display:hide_interaction_circle()
end)

Hooks:OverrideFunction(HUDInteraction, "set_bar_valid", function (self, valid, text_id)
	WFHud.interact_display:set_valid(not valid and managers.localization:to_upper_text(text_id))
end)

Hooks:OverrideFunction(HUDInteraction, "set_interaction_bar_width", function (self, current, total)
	WFHud.interact_display:set_interaction_progress(math.clamp(current / total, 0, 1))
end)
