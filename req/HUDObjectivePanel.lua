HUDObjectivePanel = class()

HUDObjectivePanel.ICON_TEXTURE_RECTS = {
	default = { 0, 0, 48, 48 },
	defend = { 0, 48, 48, 48 },
	attack = { 48, 0, 48, 48 },
	extract = { 48, 48, 48, 48 }
}

HUDObjectivePanel.ICON_COLORS = {
	default = WFHud.colors.objective,
	attack = WFHud.colors.attack,
	extract = WFHud.colors.extract
}

function HUDObjectivePanel:init(panel, x, y)
	self._last_time = 0

	self._panel = panel:panel({
		x = x,
		y = y,
		w = 500
	})

	self._objective_icon = self._panel:bitmap({
		visible = false,
		texture = "guis/textures/wfhud/icons",
		texture_rect = HUDObjectivePanel.ICON_TEXTURE_RECTS.default,
		color = WFHud.colors.objective,
		w = 24,
		h = 24
	})

	self._objective_text = self._panel:text({
		visible = false,
		text = "GO DO A CRIME",
		font = WFHud.fonts.bold,
		font_size = WFHud.font_sizes.default,
		color = WFHud.colors.default,
		h = 24,
		vertical = "center"
	})

	self._objective_detail = self._panel:text({
		visible = false,
		text = "CRIMES DONE: 0/99",
		font = WFHud.fonts.default,
		font_size = WFHud.font_sizes.default,
		color = WFHud.colors.default,
		h = 24,
		vertical = "center"
	})

	self._waves_text = self._panel:text({
		visible = false,
		text = "WAVES REMAINING: 3",
		font = WFHud.fonts.default,
		font_size = WFHud.font_sizes.default,
		color = WFHud.colors.default,
		h = 24,
		vertical = "center"
	})

	self._time_text = self._panel:text({
		text = "13:37",
		font = WFHud.fonts.default,
		font_size = WFHud.font_sizes.default,
		color = WFHud.colors.default,
		h = 24,
		vertical = "center"
	})


	self._vip_icon = self._panel:bitmap({
		visible = false,
		texture = "guis/textures/wfhud/icons",
		texture_rect = HUDObjectivePanel.ICON_TEXTURE_RECTS.attack,
		color = WFHud.colors.attack,
		w = 24,
		h = 24
	})

	self._vip_text = self._panel:text({
		visible = false,
		text = managers.localization:to_upper_text("hud_objectives_defeat_winters"),
		font = WFHud.fonts.bold,
		font_size = WFHud.font_sizes.default,
		color = WFHud.colors.default,
		h = 24,
		vertical = "center"
	})

	self._vip_detail = self._panel:text({
		visible = false,
		text = managers.localization:to_upper_text("hud_objectives_damage_resistance", { NUM = "0" }),
		font = WFHud.fonts.default,
		font_size = WFHud.font_sizes.default,
		color = WFHud.colors.default,
		h = 24,
		vertical = "center"
	})

	self:_layout()
end

function HUDObjectivePanel:_layout()
	self._objective_icon:set_position(0, 0)

	local text_x = self._objective_icon:right() + 8
	self._objective_text:set_position(text_x, self._objective_icon:y())
	self._objective_detail:set_position(text_x, self._objective_detail:visible() and self._objective_text:bottom() or self._objective_text:y())
	self._waves_text:set_position(text_x, self._waves_text:visible() and self._objective_detail:bottom() or self._objective_detail:y())
	self._time_text:set_position(text_x, self._waves_text:bottom())

	self._vip_icon:set_position(0, self._time_text:bottom() + self._vip_icon:h())
	self._vip_text:set_position(text_x, self._vip_icon:y())
	self._vip_detail:set_position(text_x, self._vip_text:bottom())
end

function HUDObjectivePanel:set_icon(icon)
	self._objective_icon:set_texture_rect(unpack(HUDObjectivePanel.ICON_TEXTURE_RECTS[icon] or HUDObjectivePanel.ICON_TEXTURE_RECTS.default))
	self._objective_icon:set_color(HUDObjectivePanel.ICON_COLORS[icon] or HUDObjectivePanel.ICON_COLORS.default)
end

function HUDObjectivePanel:set_objective(text)
	if text then
		self._objective_icon:set_visible(true)
		self._objective_text:set_text(text)
		self._objective_text:set_visible(true)
	else
		self._objective_icon:set_visible(false)
		self._objective_text:set_visible(false)
	end

	self:_layout()
end

function HUDObjectivePanel:set_objective_detail(text)
	if text then
		self._objective_detail:set_text(text)
		self._objective_detail:set_visible(true)
	else
		self._objective_detail:set_visible(false)
	end

	self:_layout()
end

function HUDObjectivePanel:set_waves_text(text)
	if text then
		self._waves_text:set_text(text)
		self._waves_text:set_visible(true)
	else
		self._waves_text:set_visible(false)
	end

	self:_layout()
end

function HUDObjectivePanel:set_time(time, is_point_of_no_return)
	time = math.abs(time)
	if math.floor(time) == self._last_time or self._point_of_no_return and not is_point_of_no_return then
		return
	end

	self._last_time = time

	time = math.floor(time)
	local hours = math.floor(time / 3600)
	time = time - hours * 3600
	local minutes = math.floor(time / 60)
	time = time - minutes * 60
	local seconds = math.round(time)
	local text = hours > 0 and string.format("%02u:%02u:%02u", hours, minutes, seconds) or string.format("%02u:%02u", minutes, seconds)

	if self._point_of_no_return then
		text = self._point_of_no_return .. ": " .. text
		self._time_text:set_color(WFHud.colors.debuff)
	else
		self._time_text:set_color(WFHud.colors.default)
	end

	self._time_text:set_text(text)
end

function HUDObjectivePanel:set_point_of_no_return(text)
	self._point_of_no_return = text
	self._time_text:set_font(Idstring(text and WFHud.fonts.bold or WFHud.fonts.default))
end

function HUDObjectivePanel:set_vip(buff)
	if buff then
		self._vip_icon:set_visible(true)
		self._vip_text:set_visible(true)
		self._vip_detail:set_text(managers.localization:to_upper_text("hud_objectives_damage_resistance", { NUM = buff }))
		self._vip_detail:set_visible(true)
	else
		self._vip_icon:set_visible(false)
		self._vip_text:set_visible(false)
		self._vip_detail:set_visible(false)
	end

	self:_layout()
end
