local HUDBGBox_create_original = HUDBGBox_create
function HUDBGBox_create(panel, ...)
	local box_panel = HUDBGBox_create_original(panel, ...)

	box_panel:child("bg"):set_visible(false)
	box_panel:child("left_top"):set_visible(false)
	box_panel:child("left_bottom"):set_visible(false)
	box_panel:child("right_top"):set_visible(false)
	box_panel:child("right_bottom"):set_visible(false)

	return box_panel
end

Hooks:PostHook(HUDObjectives, "init", "init_wfhud", function (self)
	local objective_panel = self._hud_panel:child("objectives_panel")
	objective_panel:set_y(200)

	local objective_icon = objective_panel:child("icon_objectivebox")
	objective_icon:set_image("guis/textures/wfhud/objective")
	objective_icon:set_color(WFHud.colors.objective)
	objective_icon:set_y(8)

	local objective_text = objective_panel:child("objective_text")
	objective_text:set_font(Idstring(WFHud.fonts.default))
	objective_text:set_font_size(WFHud.font_sizes.default)
	objective_text:set_vertical("center")
	objective_text:set_h(objective_icon:h())
	objective_text:set_y(objective_icon:y())

	local amount_text = objective_panel:child("amount_text")
	amount_text:set_font(Idstring(WFHud.fonts.default))
	amount_text:set_font_size(WFHud.font_sizes.default)
	amount_text:set_vertical("center")
	amount_text:set_h(objective_icon:h())
	amount_text:set_y(objective_icon:y())

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

function HUDObjectives:_animate_icon_objectivebox(icon_objectivebox)
	icon_objectivebox:set_y(8)

	over(2, function (t)
		icon_objectivebox:set_y(8 + math.round(math.sin(t * 360 * 4) * 8 * (1 - t)))
	end)

	icon_objectivebox:set_y(8)
end
