local hud_scale = WFHud.settings.hud_scale
local font_scale = WFHud.settings.font_scale

---@class HUDPlayerEquipment
---@field new fun(self, panel):HUDPlayerEquipment
HUDPlayerEquipment = HUDPlayerEquipment or WFHud:panel_class()

---@param panel Panel
function HUDPlayerEquipment:init(panel)
	self._weapon_index = 1

	self._panel = panel:panel({
		visible = false
	})

	self._bag_icon = self._panel:bitmap({
		visible = false,
		texture = "guis/textures/pd2/hud_tabs",
		texture_rect = { 2, 34, 20, 17 },
		color = WFHud.settings.colors.default,
		w = 20 * hud_scale,
		h = 17 * hud_scale
	})
	self._bag_icon:set_right(self._panel:w())

	self._bag_text = self._panel:text({
		visible = false,
		text = "THERMAL DRILL",
		font = WFHud.fonts.default,
		font_size = WFHud.font_sizes.default * font_scale * hud_scale,
		color = WFHud.settings.colors.default,
	})

	self:_align_bag_text()

	self._ammo_text = self._panel:text({
		color = WFHud.settings.colors.default,
		text = "30",
		font = WFHud.fonts.large,
		font_size = WFHud.font_sizes.huge * font_scale * hud_scale,
		y = self._bag_icon:bottom() + 32
	})

	self._total_ammo_text = self._panel:text({
		color = WFHud.settings.colors.default,
		text = "/ 120",
		font = WFHud.fonts.bold,
		font_size = WFHud.font_sizes.default * font_scale * hud_scale,
		y = self._ammo_text:y()
	})

	self:_align_ammo_text()

	self._weapon_name = self._panel:text({
		color = WFHud.settings.colors.default,
		text = "AMCAR RIFLE",
		font = WFHud.fonts.default,
		font_size = WFHud.font_sizes.small * font_scale * hud_scale,
		y = self._total_ammo_text:bottom()
	})

	self._fire_mode_text = self._panel:text({
		color = WFHud.settings.colors.muted,
		text = "AUTO",
		font = WFHud.fonts.default,
		font_size = WFHud.font_sizes.small * font_scale * hud_scale,
		y = self._total_ammo_text:bottom()
	})

	self:_align_weapon_text()

	self._equipment_list = HUDIconList:new(self._panel, 0, self._fire_mode_text:bottom(), 24 * hud_scale, 24 * hud_scale, WFHud.settings.colors.default)
	self._item_list = HUDIconList:new(self._panel, 0, self._fire_mode_text:bottom(), self._panel:w(), 24 * hud_scale, WFHud.settings.colors.default)

	self:_align_equipment()

	self._stamina_panel = self._panel:panel({
		y = self._item_list:bottom() + 4,
		w = 128 * hud_scale,
		h = 5 * hud_scale
	})
	self._stamina_panel:set_right(self._panel:w())

	self._stamina_bar_bg = self._stamina_panel:bitmap({
		texture = "guis/textures/wfhud/bar",
		color = WFHud.settings.colors.bg:with_alpha(0.5),
		w = self._stamina_panel:w(),
		h = self._stamina_panel:h(),
		layer = -1
	})

	self._stamina_bar = self._stamina_panel:bitmap({
		texture = "guis/textures/wfhud/bar",
		color = WFHud.settings.colors.default,
		w = self._stamina_panel:w(),
		h = self._stamina_panel:h()
	})

	self._stamina_text = self._panel:text({
		color = WFHud.settings.colors.default,
		text = "50",
		font = WFHud.fonts.bold,
		font_size = WFHud.font_sizes.small * font_scale * hud_scale,
		align = "right",
		y = self._stamina_panel:bottom()
	})

	self._stamina_ratio = 1

	self._panel:set_h(self._stamina_panel:bottom() + self._stamina_text:font_size())
	self._panel:set_rightbottom(panel:w() - WFHud.settings.margin_h, panel:h() - WFHud.settings.margin_v)
end

function HUDPlayerEquipment:_align_bag_text()
	local _, _, w, h = self._bag_text:text_rect()
	self._bag_text:set_size(w, h)
	self._bag_text:set_right(self._bag_icon:x() - 8)
	self._bag_text:set_center_y(self._bag_icon:center_y())
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

function HUDPlayerEquipment:_align_equipment()
	self._equipment_list:set_w((self._equipment_list._size + self._equipment_list._spacing) * #self._equipment_list:children())
	self._equipment_list:_layout_panel()
	self._equipment_list:set_right(self._panel:w())
	self._item_list:set_right(self._equipment_list:x())
end

function HUDPlayerEquipment:set_bag(bag_text)
	if bag_text then
		self._bag_icon:set_visible(true)
		self._bag_text:set_text(bag_text)
		self._bag_text:set_visible(true)
		self:_align_bag_text()
	else
		self._bag_icon:set_visible(false)
		self._bag_text:set_visible(false)
	end
end

function HUDPlayerEquipment:set_ammo()
	local unit = managers.player:local_player():inventory():unit_by_selection(self._weapon_index)
	local wbase = unit and unit:base()
	if not wbase then
		return
	end

	local mag_max, mag, total = wbase:ammo_info()
	if mag_max <= 1 then
		self._ammo_text:set_text(tostring(total))
		self._ammo_text:set_alpha(mag < 1 and 0.5 or 1)
		self._total_ammo_text:set_text("   ")
	else
		local alt_ammo = managers.user:get_setting("alt_hud_ammo") and getmetatable(wbase) ~= SawWeaponBase
		self._ammo_text:set_text(tostring(mag))
		self._ammo_text:set_alpha(1)
		self._total_ammo_text:set_text(string.format("/ %u", alt_ammo and math.max(0, total - mag) or total))
	end

	self:_align_ammo_text()
end

function HUDPlayerEquipment:set_fire_mode()
	local unit = managers.player:local_player():inventory():unit_by_selection(self._weapon_index)
	local wbase = unit and unit:base()
	if not wbase then
		return
	end

	local loc_id
	local fire_mode_text = ""
	local gadget_base = wbase:gadget_overrides_weapon_functions()
	if gadget_base and gadget_base.is_underbarrel and gadget_base:is_underbarrel() then
		fire_mode_text = gadget_base.GADGET_TYPE
		loc_id = "hud_fire_mode_" .. fire_mode_text
	elseif wbase:can_toggle_firemode() or wbase.has_underbarrel and wbase:has_underbarrel() or wbase._alt_fire_data then
		fire_mode_text = wbase.in_burst_mode and wbase:in_burst_mode() and "burst" or wbase.alt_fire_active and wbase:alt_fire_active() and "alt" or wbase:fire_mode()
		loc_id = "hud_fire_mode_" .. fire_mode_text
	end
	fire_mode_text = loc_id and managers.localization:exists(loc_id) and managers.localization:to_upper_text(loc_id) or fire_mode_text:upper()
	self._fire_mode_text:set_text(fire_mode_text)
	self:_align_weapon_text()
end

function HUDPlayerEquipment:set_weapon(index)
	local data = index == 1 and managers.blackmarket:equipped_secondary() or managers.blackmarket:equipped_primary()
	self._weapon_name:set_text(data.custom_name or managers.localization:to_upper_text(tweak_data.weapon[data.weapon_id].name_id))

	self._weapon_index = index

	self:set_fire_mode()
	self:set_ammo()
end

function HUDPlayerEquipment:set_stamina(current, total, instant)
	if not current or not total then
		return
	end

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

function HUDPlayerEquipment:clear()
	self._item_list:clear()
	self._equipment_list:clear()
end

function HUDPlayerEquipment:destroy()
	if not alive(self._panel) then
		return
	end

	self._equipment_list:destroy()
	self._item_list:destroy()

	self._stamina_bar:stop()

	self._panel:stop()
	self._panel:parent():remove(self._panel)
end
