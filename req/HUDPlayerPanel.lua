local hud_scale = WFHud.settings.hud_scale
local font_scale = WFHud.settings.font_scale

---@class HUDPlayerPanel
---@field new fun():HUDPlayerPanel
HUDPlayerPanel = HUDPlayerPanel or WFHud:panel_class()

function HUDPlayerPanel:init(panel, main_player)
	self._is_main_player = main_player

	self._panel = panel:panel()

	-- peer data (avatar + infamy)
	self._peer_info_panel = self._panel:panel({
		visible = not main_player,
		w = 32 * hud_scale,
		h = 32 * hud_scale
	})

	self._peer_avatar = self._peer_info_panel:bitmap({
		texture = "guis/textures/wfhud/avatar_placeholder",
		w = self._peer_info_panel:w(),
		h = self._peer_info_panel:h(),
		alpha = 0.75
	})

	self._peer_rank = self._peer_info_panel:text({
		align = "right",
		vertical = "bottom",
		text = "0",
		color = WFHud.settings.colors.default,
		font = WFHud.fonts.default,
		font_size = WFHud.font_sizes.small * font_scale * hud_scale,
		layer = 1,
		w = self._peer_info_panel:w() - 4,
		h = self._peer_info_panel:h()
	})

	self._peer_info_panel:set_right(self._panel:w())


	-- healthbar
	local health_bar_w = (main_player and 160 or 96) * font_scale * hud_scale
	local health_bar_h = (main_player and 8 or 5) * hud_scale
	local health_bar_font_size = (main_player and WFHud.font_sizes.huge or WFHud.font_sizes.small) * font_scale * hud_scale
	self._health_bar = HUDHealthBar:new(self._panel, 0, 0, health_bar_w, health_bar_h, health_bar_font_size)
	self._health_bar:set_right(main_player and self._panel:w() or self._peer_info_panel:x() - 4)


	-- level bar
	self._level_panel = self._panel:panel({
		visible = not main_player,
		x = self._health_bar:x(),
		y = self._health_bar:bottom() + 1,
		w = health_bar_w,
		h = 2 * hud_scale,
		layer = -1
	})

	self._level_bar_bg = self._level_panel:bitmap({
		texture = "guis/textures/wfhud/bar",
		color = WFHud.settings.colors.bg:with_alpha(0.5),
		w = self._level_panel:w(),
		h = self._level_panel:h(),
		layer = -1
	})

	self._level_bar = self._level_panel:bitmap({
		texture = "guis/textures/wfhud/bar",
		color = WFHud.settings.colors.default,
		w = self._level_panel:w(),
		h = self._level_panel:h()
	})


	-- peer id
	self._peer_id_panel = self._panel:panel({
		y = main_player and self._health_bar:bottom() or self._level_panel:bottom(),
		w = 16 * font_scale * hud_scale,
		h = 16 * font_scale * hud_scale,
		layer = -1
	})
	self._peer_id_panel:set_right(self._level_panel:right())

	self._peer_id_bg = self._peer_id_panel:bitmap({
		texture = "guis/textures/wfhud/peer_bg",
		w = self._peer_id_panel:h(),
		h = self._peer_id_panel:w()
	})

	self._peer_id_text = self._peer_id_panel:text({
		text = "0",
		font = WFHud.fonts.bold_no_shadow,
		font_size = WFHud.font_sizes.tiny * font_scale * hud_scale,
		color = WFHud.settings.colors.default:invert():with_alpha(0.75),
		align = "center",
		vertical = "center",
		layer = 1
	})


	-- name + level
	self._level_text = self._panel:text({
		visible = false,
		text = "[100]",
		font = WFHud.fonts.bold,
		font_size = WFHud.font_sizes.small * font_scale * hud_scale,
		color = WFHud.settings.colors.default,
		align = "right",
		y = main_player and self._health_bar:bottom() or self._level_panel:bottom(),
		w = self._level_panel:right() - self._peer_id_panel:w() - (main_player and 8 or 4) * font_scale,
		layer = -1
	})

	self._name_text = self._panel:text({
		text = "Player",
		font = WFHud.fonts.default,
		font_size = WFHud.font_sizes.small * font_scale * hud_scale,
		color = WFHud.settings.colors.default,
		align = "right",
		y = main_player and self._health_bar:bottom() or self._level_panel:bottom(),
		w = self._level_panel:right() - self._peer_id_panel:w() - (main_player and 8 or 4) * font_scale,
		layer = -1
	})

	self._panel:set_h(self._peer_id_panel:bottom() + 3)

	self._peer_info_panel:set_center_y(self._panel:h() * 0.5)
end

function HUDPlayerPanel:set_peer_id(id)
	self._peer_id_text:set_text(tostring(id))
	self._peer_id_bg:set_color(WFHud.settings.player_panels.use_peer_colors and tweak_data.chat_colors[id] or WFHud.settings.colors.default)

	if self._is_main_player then
		return
	end

	local peer = managers.network:session():peer(id)
	if not peer then
		self._peer_rank:set_text("0")
		self._level_bar:set_w(self._level_bar_bg:w())
		self._level_bar:set_right(self._level_bar_bg:right())
		self._peer_avatar:set_image("guis/textures/wfhud/avatar_placeholder")
		return
	end

	self._peer_rank:set_text(tostring(peer:rank()))
	self._level_bar:set_w(self._level_bar_bg:w() * ((peer:level() or 0) / 100))
	self._level_bar:set_right(self._level_bar_bg:right())

	Steam:friend_avatar(Steam.MEDIUM_AVATAR, peer:user_id(), function (texture)
		self._peer_avatar:set_image(texture)
	end)
end

function HUDPlayerPanel:set_name(name)
	self._level_text:set_visible(self._is_main_player)

	if self._is_main_player then
		local spec = managers.skilltree:get_specialization_value("current_specialization")

		self._level_text:set_text(string.format(" [%u]", managers.experience:current_level()))
		local _, _, tw = self._level_text:text_rect()
		self._name_text:set_w(self._level_panel:right() -  self._peer_id_panel:w() - 8 * font_scale - tw)
		name = managers.localization:to_upper_text(tweak_data.skilltree.specializations[spec].name_id)
	end

	self._name_text:set_text(name)
end

function HUDPlayerPanel:health_bar()
	return self._health_bar
end

function HUDPlayerPanel:hide()
	self._panel:hide()
	self:set_peer_id(0)
end

function HUDPlayerPanel:destroy()
	if not alive(self._panel) then
		return
	end

	self._health_bar:destroy()

	self._panel:stop()
	self._panel:parent():remove(self._panel)
end
