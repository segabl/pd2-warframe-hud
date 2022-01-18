HUDPlayerEquipment = class()

function HUDPlayerEquipment:init(panel)
	self._panel = panel:panel({
		w = 400
	})

	self._ammo_text = self._panel:text({
		color = WFHud.colors.default,
		text = "123",
		font = tweak_data.menu.pd2_large_font,
		font_size = 40
	})

	self._total_ammo_text = self._panel:text({
		color = WFHud.colors.default,
		text = "/456",
		font = tweak_data.menu.pd2_large_font,
		font_size = 20
	})

	self:_align_ammo_text()

	self._weapon_name = self._panel:text({
		color = WFHud.colors.default,
		text = "AMCAR RIFLE",
		font = tweak_data.menu.medium_font,
		font_size = 20,
		y = self._total_ammo_text:bottom()
	})

	self._fire_mode_text = self._panel:text({
		color = WFHud.colors.muted,
		text = "AUTO",
		font = tweak_data.menu.medium_font,
		font_size = 20,
		y = self._total_ammo_text:bottom()
	})

	self:_align_weapon_text()

	self._stamina_panel = self._panel:panel({
		x = self._panel:w() - 128,
		y = self._fire_mode_text:bottom() + 4,
		w = 128,
		h = 5
	})

	self._stamina_bar_bg = self._stamina_panel:bitmap({
		texture = "guis/textures/wfhud/bar",
		color = WFHud.colors.bg:with_alpha(0.5),
		w = self._stamina_panel:w(),
		h = self._stamina_panel:h(),
		layer = -1
	})

	self._stamina_bar = self._stamina_panel:bitmap({
		texture = "guis/textures/wfhud/bar",
		color = WFHud.colors.default,
		w = self._stamina_panel:w(),
		h = self._stamina_panel:h()
	})

	self._stamina_text = self._panel:text({
		color = WFHud.colors.default,
		text = "50",
		font = tweak_data.menu.medium_font,
		font_size = 20,
		align = "right",
		y = self._stamina_panel:bottom()
	})

	self._stamina_ratio = 1

	self._panel:set_h(self._stamina_panel:bottom() + 20)

end

function HUDPlayerEquipment:_align_ammo_text()
	local _, _, w, h = self._ammo_text:text_rect()
	self._ammo_text:set_size(w, h)

	local _, _, w, h = self._total_ammo_text:text_rect()
	self._total_ammo_text:set_size(w, h)

	self._total_ammo_text:set_rightbottom(self._panel:w(), self._ammo_text:y() + self._ammo_text:h())
	self._ammo_text:set_right(self._total_ammo_text:x() - self._total_ammo_text:h() * 0.25)
end

function HUDPlayerEquipment:_align_weapon_text()
	local _, _, w, h = self._weapon_name:text_rect()
	self._weapon_name:set_size(w, h)

	local _, _, w, h = self._fire_mode_text:text_rect()
	self._fire_mode_text:set_size(w, h)

	self._fire_mode_text:set_right(self._panel:w())
	self._weapon_name:set_right(self._fire_mode_text:x() - self._fire_mode_text:h() * 0.25)
end

function HUDPlayerEquipment:set_ammo(wbase)
	local mag_max, mag, total = wbase:ammo_info()
	self._ammo_text:set_text(tostring(mag_max <= 1 and total or mag))
	self._total_ammo_text:set_text(mag_max <= 1 and "   " or string.format("/%u", total - mag))

	self:_align_ammo_text()
end

function HUDPlayerEquipment:set_fire_mode(wbase)
	local gadget_base = wbase:gadget_overrides_weapon_functions()
	local underbarrel_type = gadget_base and (gadget_base.GADGET_TYPE == "underbarrel_launcher" and "LAUNCHER" or "UNDERBARREL")
	self._fire_mode_text:set_text(underbarrel_type or wbase:can_toggle_firemode() and wbase:fire_mode():upper() or "")
	self:_align_weapon_text()
end

function HUDPlayerEquipment:set_weapon(wbase)
	local tweak = tweak_data.weapon[wbase._name_id]

	self._weapon_name:set_text(managers.localization:to_upper_text(tweak.name_id))

	self:set_fire_mode(wbase)
	self:set_ammo(wbase)
end

function HUDPlayerEquipment:set_stamina(current, total, instant)
	local ratio = math.min(current / total, 1)

	if instant then
		self._stamina_ratio = ratio
		self._stamina_bar:set_w(self._stamina_bar_bg:w() * ratio)
		self._stamina_text:set_text(tostring(math.round(current)))
	else
		local start = self._stamina_ratio
		self._stamina_bar:stop()
		self._stamina_bar:animate(function (o)
			over(math.abs(start - ratio), function (t)
				self:set_stamina(math.lerp(start, ratio, t) * total, total, true)
			end)
		end)
	end
end
