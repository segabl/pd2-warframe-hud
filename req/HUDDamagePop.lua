local tmp_vec = Vector3()

HUDDamagePop = class()

HUDDamagePop.ALPHA_CURVE = { 1, 1, 0.5, 0 }
HUDDamagePop.SCALE_CURVE = { 1, 0.5, 1.5, 1.5 }
HUDDamagePop.PROC_TYPE_TEXTURE_RECTS = {
	impact = { 0, 0, 48, 48 },
	puncture = { 48, 0, 48, 48 },
	electricity = { 0, 48, 48, 48 },
	heat = { 48, 48, 48, 48 },
	toxin = { 96, 48, 48, 48 },
	blast = { 144, 48, 48, 48 }
}

function HUDDamagePop:init(panel, pos, damage, proc_type, is_crit, is_headshot)
	self._crit_mod = (is_crit and 1 or 0) + (is_headshot and 1 or 0)

	self._panel = panel:panel({
		layer = self._crit_mod
	})

	local size = 24 + 8 * self._crit_mod

	if self.PROC_TYPE_TEXTURE_RECTS[proc_type] then
		self._proc_bitmap = self._panel:bitmap({
			texture = "guis/textures/wfhud/damage_types",
			texture_rect = self.PROC_TYPE_TEXTURE_RECTS[proc_type],
			color = WFHud.colors.damage[self._crit_mod + 1],
			w = size,
			h = size
		})
	end

	self._damage_text = self._panel:text({
		text = string.format("%u", damage * 10),
		font = tweak_data.menu.medium_font,
		font_size = size,
		color = WFHud.colors.damage[self._crit_mod + 1],
		x = self._proc_bitmap and size
	})

	self._pos = pos

	self._dir = Vector3(-1 + math.random() * 2, -math.random())
	self._offset = Vector3()

	self._panel:animate(callback(self, self, "animate"))
end

function HUDDamagePop:animate()
	local ws = managers.hud._workspace
	local cam = managers.viewport:get_current_camera()

	over(1, function (t)
		if not alive(cam) then
			return
		end

		local size = (24 + 8 * self._crit_mod) * math.bezier(self.SCALE_CURVE, t)

		self._damage_text:set_font_size(size)
		local _, _, tw, _ = self._damage_text:text_rect()

		if self._proc_bitmap then
			self._proc_bitmap:set_size(size, size)
			self._damage_text:set_x(size)
		end

		local dis_scale = 200 / mvector3.direction(tmp_vec, cam:position(), self._pos)
		self._panel:set_visible(mvector3.dot(cam:rotation():y(), tmp_vec) >= 0)

		mvector3.lerp(tmp_vec, self._dir, math.Y, t)
		mvector3.add(self._offset, tmp_vec)
		local screen_pos = ws:world_to_screen(cam, self._pos)

		self._panel:set_size(tw + (self._proc_bitmap and size or 0), size)
		self._panel:set_center(screen_pos.x + self._offset.x * dis_scale, screen_pos.y + self._offset.y * dis_scale)
		self._panel:set_alpha(math.bezier(self.ALPHA_CURVE, t))
	end)

	self._panel:parent():remove(self._panel)
end
