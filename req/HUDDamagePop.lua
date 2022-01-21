local mvec_add = mvector3.add
local mvec_dir = mvector3.direction
local mvec_dot = mvector3.dot
local mvec_lerp = mvector3.lerp
local mvec_set = mvector3.set
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

	local size = WFHud.font_sizes.default + 8 * self._crit_mod

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
		font = WFHud.fonts.default,
		font_size = size,
		color = WFHud.colors.damage[self._crit_mod + 1],
		x = 0
	})

	self._pos = pos

	self._dir = Vector3(-0.5 + math.random(), -0.5 + math.random(), math.random())
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

		local size = (WFHud.font_sizes.default + 8 * self._crit_mod) * math.bezier(self.SCALE_CURVE, t)

		self._damage_text:set_font_size(size)
		local _, _, tw, _ = self._damage_text:text_rect()

		if self._proc_bitmap then
			self._proc_bitmap:set_size(size * 0.8, size * 0.8)
			self._proc_bitmap:set_x(tw)
		end

		mvec_lerp(tmp_vec, self._dir, math.DOWN, t)
		mvec_add(self._offset, tmp_vec)

		mvec_set(tmp_vec, self._offset)
		mvec_add(tmp_vec, self._pos)

		local screen_pos = ws:world_to_screen(cam, tmp_vec)
		self._panel:set_size(tw + (self._proc_bitmap and size * 0.8 or 0), size)
		self._panel:set_center(screen_pos.x, screen_pos.y)
		self._panel:set_alpha(math.bezier(self.ALPHA_CURVE, t))

		mvec_dir(tmp_vec, cam:position(), self._pos)
		self._panel:set_visible(mvec_dot(cam:rotation():y(), tmp_vec) >= 0)
	end)

	self._panel:parent():remove(self._panel)
end
