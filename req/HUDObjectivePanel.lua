local hud_scale = WFHud.settings.hud_scale
local font_scale = WFHud.settings.font_scale

---@class HUDObjectivePanel
---@field new fun(self, panel, x, y):HUDObjectivePanel
HUDObjectivePanel = HUDObjectivePanel or WFHud:panel_class()

HUDObjectivePanel.ICON_SIZE = 24 * hud_scale
HUDObjectivePanel.ICON_TEXTURE_RECTS = {
	default = { 0, 0, 48, 48 },
	defend = { 0, 48, 48, 48 },
	attack = { 48, 0, 48, 48 },
	extract = { 48, 48, 48, 48 }
}
HUDObjectivePanel.CHARACTER_COLORS = {
	default = WFHud.settings.colors.friendly,
	bos = WFHud.settings.colors.enemy,
	bul = WFHud.settings.colors.enemy,
	chca = WFHud.settings.colors.enemy,
	com = WFHud.settings.colors.enemy,
	yuw = WFHud.settings.colors.enemy,
	xuk = WFHud.settings.colors.enemy,
	hnc = WFHud.settings.colors.muted,
	txm = WFHud.settings.colors.muted,
	mrb = Color("ffff99"),
	mrp = Color("ff66aa")
}

function HUDObjectivePanel:init(panel, x, y)
	self._last_time = 0

	self._panel = panel:panel({
		x = x,
		y = y
	})

	self._objective_icon = self._panel:bitmap({
		visible = false,
		texture = "guis/textures/wfhud/icons",
		texture_rect = HUDObjectivePanel.ICON_TEXTURE_RECTS.default,
		color = WFHud.settings.colors.objective,
		w = HUDObjectivePanel.ICON_SIZE,
		h = HUDObjectivePanel.ICON_SIZE
	})

	self._objective_icon_overlay = panel:bitmap({
		layer = 10,
		visible = false,
		texture = "guis/textures/wfhud/icons",
		texture_rect = HUDObjectivePanel.ICON_TEXTURE_RECTS.default,
		color = WFHud.settings.colors.objective,
		w = HUDObjectivePanel.ICON_SIZE,
		h = HUDObjectivePanel.ICON_SIZE,
		blend_mode = "add"
	})

	self._objective_text = self._panel:text({
		visible = false,
		text = "GO DO A CRIME",
		font = WFHud.fonts.bold,
		font_size = WFHud.font_sizes.default * font_scale * hud_scale,
		color = WFHud.settings.colors.default,
		h = HUDObjectivePanel.ICON_SIZE,
		vertical = "center"
	})

	self._objective_detail = self._panel:text({
		visible = false,
		text = "CRIMES DONE: 0/99",
		font = WFHud.fonts.default,
		font_size = WFHud.font_sizes.default * font_scale * hud_scale,
		color = WFHud.settings.colors.default,
		h = HUDObjectivePanel.ICON_SIZE,
		vertical = "center"
	})

	self._waves_text = self._panel:text({
		visible = false,
		text = "WAVES REMAINING: 3",
		font = WFHud.fonts.default,
		font_size = WFHud.font_sizes.default * font_scale * hud_scale,
		color = WFHud.settings.colors.default,
		h = HUDObjectivePanel.ICON_SIZE,
		vertical = "center"
	})

	self._time_text = self._panel:text({
		text = "13:37",
		font = WFHud.fonts.default,
		font_size = WFHud.font_sizes.default * font_scale * hud_scale,
		color = WFHud.settings.colors.default,
		h = HUDObjectivePanel.ICON_SIZE,
		vertical = "center"
	})


	self._vip_icon = self._panel:bitmap({
		visible = false,
		texture = "guis/textures/wfhud/icons",
		texture_rect = HUDObjectivePanel.ICON_TEXTURE_RECTS.attack,
		color = WFHud.settings.colors.attack,
		w = HUDObjectivePanel.ICON_SIZE,
		h = HUDObjectivePanel.ICON_SIZE
	})

	self._vip_icon_overlay = panel:bitmap({
		layer = 10,
		visible = false,
		texture = "guis/textures/wfhud/icons",
		texture_rect = HUDObjectivePanel.ICON_TEXTURE_RECTS.attack,
		color = WFHud.settings.colors.attack,
		w = HUDObjectivePanel.ICON_SIZE,
		h = HUDObjectivePanel.ICON_SIZE,
		blend_mode = "add"
	})

	self._vip_text = self._panel:text({
		visible = false,
		text = managers.localization:to_upper_text("hud_objectives_defeat_winters"),
		font = WFHud.fonts.bold,
		font_size = WFHud.font_sizes.default * font_scale * hud_scale,
		color = WFHud.settings.colors.default,
		h = HUDObjectivePanel.ICON_SIZE,
		vertical = "center"
	})

	self._vip_detail = self._panel:text({
		visible = false,
		text = "ENEMY DAMAGE RESISTANCE: 69%",
		font = WFHud.fonts.default,
		font_size = WFHud.font_sizes.default * font_scale * hud_scale,
		color = WFHud.settings.colors.default,
		h = HUDObjectivePanel.ICON_SIZE,
		vertical = "center"
	})


	self._subtitle_panel = self._panel:panel({
		alpha = 0,
		w = 300 * font_scale * hud_scale
	})

	self._subtitle_name = self._subtitle_panel:text({
		font = WFHud.fonts.bold,
		font_size = WFHud.font_sizes.default * font_scale * hud_scale,
		color = WFHud.settings.colors.friendly,
		h = HUDObjectivePanel.ICON_SIZE
	})

	self._subtitle_text = self._subtitle_panel:text({
		font = WFHud.fonts.default,
		font_size = WFHud.font_sizes.default * font_scale * hud_scale,
		color = WFHud.settings.colors.default,
		y = self._subtitle_name:bottom(),
		wrap = true,
		word_wrap = true
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

	self._subtitle_panel:set_position(0, self._vip_detail:bottom())
end

function HUDObjectivePanel:_animate_show_icon(overlay_icon, icon)
	icon:show()
	overlay_icon:show()
	over(1, function (t)
		local s = math.lerp(1, 1.5, math.sin(t * 180))
		overlay_icon:set_size(HUDObjectivePanel.ICON_SIZE * s, HUDObjectivePanel.ICON_SIZE * s)
		overlay_icon:set_center(self._panel:x() + icon:center_x(), self._panel:y() + icon:center_y())
		overlay_icon:set_alpha(math.sin(t * 180))
	end)
	overlay_icon:hide()
end

function HUDObjectivePanel:_animate_show_text(text)
	local w = self._panel:w()
	text:set_w(0)
	text:show()
	over(0.5, function (t)
		text:set_w(t * w)
	end)
	text:set_w(w)
end

function HUDObjectivePanel:_animate_show_subtitle(panel, lines)
	panel:set_alpha(0)
	over(0.1, function (t)
		panel:set_alpha(t)
	end)
	for _, line in pairs(lines) do
		self._subtitle_text:set_text(line[1])
		wait(line[2])
	end
	over(0.1, function (t)
		panel:set_alpha(1 - t)
	end)
	panel:set_alpha(0)
end

function HUDObjectivePanel:set_icon(icon)
	local x, y, w, h = unpack(HUDObjectivePanel.ICON_TEXTURE_RECTS[icon] or HUDObjectivePanel.ICON_TEXTURE_RECTS.default)
	local color = WFHud.settings.colors[icon] or WFHud.settings.colors.objective

	self._objective_icon:set_texture_rect(x, y, w, h)
	self._objective_icon:set_color(color)

	self._objective_icon_overlay:set_texture_rect(x, y, w, h)
	self._objective_icon_overlay:set_color(color)
end

function HUDObjectivePanel:set_objective(text)
	if text then
		self._objective_icon:stop()
		self._objective_icon:animate(callback(self, self, "_animate_show_icon", self._objective_icon_overlay))

		self._objective_text:set_text(text)
		self._objective_text:stop()
		self._objective_text:animate(callback(self, self, "_animate_show_text"))
	else
		self._objective_icon:hide()
		self._objective_text:hide()
	end

	self:_layout()
end

function HUDObjectivePanel:set_objective_detail(text)
	if text then
		self._objective_detail:set_text(text)
		if not self._objective_detail:visible() then
			self._objective_detail:animate(callback(self, self, "_animate_show_text"))
		end
	else
		self._objective_detail:hide()
	end

	self:_layout()
end

function HUDObjectivePanel:set_waves_text(text)
	if text then
		self._waves_text:set_text(text)
		if not self._waves_text:visible() then
			self._waves_text:animate(callback(self, self, "_animate_show_text"))
		end
	else
		self._waves_text:hide()
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
		self._time_text:set_color(WFHud.settings.colors.debuff)
	else
		self._time_text:set_color(WFHud.settings.colors.default)
	end

	self._time_text:set_text(text)
end

function HUDObjectivePanel:set_point_of_no_return(text)
	self._point_of_no_return = text
	self._time_text:set_font(Idstring(text and WFHud.fonts.bold or WFHud.fonts.default))
end

function HUDObjectivePanel:set_vip(buff)
	if buff then
		if not self._vip_icon:visible() then
			self._vip_icon:animate(callback(self, self, "_animate_show_icon", self._vip_icon_overlay))
		end

		if not self._vip_text:visible() then
			self._vip_text:animate(callback(self, self, "_animate_show_text"))
		end

		self._vip_detail:set_text(managers.localization:to_upper_text("hud_objectives_damage_resistance", { NUM = buff }))
		if buff > 0 and not self._vip_detail:visible() then
			self._vip_detail:animate(callback(self, self, "_animate_show_text"))
		end
	else
		self._vip_icon:hide()
		self._vip_text:hide()
		self._vip_detail:hide()
	end

	self:_layout()
end

function HUDObjectivePanel:set_subtitle(speaker, text, duration)
	self._subtitle_panel:stop()

	if not speaker or not text then
		self._subtitle_panel:set_alpha(0)
		return
	end

	local split_text = text:split("%s*%c+%s*")
	local lines = {}
	for _, line in pairs(split_text) do
		table.insert(lines, { line, #split_text + duration * (line:len() / text:len()) })
	end
	self._subtitle_text:set_text(lines[1][1])

	local loc_id = "hud_sub_name_" .. speaker
	self._subtitle_name:set_text(managers.localization:exists(loc_id) and managers.localization:to_upper_text(loc_id) or speaker:upper())
	self._subtitle_name:set_color(HUDObjectivePanel.CHARACTER_COLORS[speaker] or HUDObjectivePanel.CHARACTER_COLORS.default)
	self._subtitle_panel:animate(callback(self, self, "_animate_show_subtitle"), lines)
end

function HUDObjectivePanel:destroy()
	if not alive(self._panel) then
		return
	end

	self._objective_icon:stop()
	self._objective_text:stop()
	self._objective_detail:stop()
	self._objective_icon_overlay:stop()
	self._objective_icon_overlay:parent():remove(self._objective_icon_overlay)

	self._vip_icon:stop()
	self._vip_text:stop()
	self._vip_detail:stop()
	self._vip_icon_overlay:stop()
	self._vip_icon_overlay:parent():remove(self._vip_icon_overlay)

	self._waves_text:stop()

	self._subtitle_panel:stop()

	self._panel:stop()
	self._panel:parent():remove(self._panel)
end
