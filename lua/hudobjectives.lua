Hooks:PostHook(HUDObjectives, "init", "init_wfhud", function (self)
	local objective_panel = self._hud_panel:child("objectives_panel")
	objective_panel:set_y(200)

	local objective_icon = objective_panel:child("icon_objectivebox")
	objective_icon:set_image("guis/textures/wfhud/objective")
	objective_icon:set_color(WFHud.colors.objective)

	local objective_text = objective_panel:child("objective_text")
	objective_text:set_font(Idstring(tweak_data.menu.medium_font))
	objective_text:set_font_size(24)
	objective_text:set_y(objective_icon:center_y() - 10)

	local amount_text = objective_panel:child("amount_text")
	amount_text:set_font(Idstring(tweak_data.menu.medium_font))
	amount_text:set_font_size(24)
	amount_text:set_y(objective_icon:center_y() - 10)

	self._bg_box:set_alpha(0)
end)

Hooks:PostHook(HUDObjectives, "update_amount_objective", "update_amount_objective_wfhud", function (self, data)
	local objective_panel = self._hud_panel:child("objectives_panel")
	local amount_text = objective_panel:child("amount_text")
	if not alive(amount_text) then
		return
	end

	local objective_text = objective_panel:child("objective_text")
	local _, _, w = objective_text:text_rect()

	amount_text:set_text(string.format(" (%u/%u)", data.current_amount or 0, data.amount))
	amount_text:set_x(objective_text:x() + w)
end)
