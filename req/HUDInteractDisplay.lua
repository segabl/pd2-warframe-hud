local mvec_add = mvector3.add
local mvec_set = mvector3.set
local tmp_vec = Vector3()
local label_offset = Vector3(0, 0, 10)

HUDInteractDisplay = class()

function HUDInteractDisplay:init(panel)
	self._panel = panel:panel({
		layer = -1,
		h = 16,
		visible = false
	})

	self._interact_circle = CircleBitmapGuiObject:new(self._panel, {
		radius = 8,
		image = "guis/textures/pd2/hud_progress_32px",
		color = Color.white
	})

	self._interact_text = self._panel:text({
		visible = false,
		text = "Press F to pay respects",
		font = WFHud.fonts.default,
		font_size = WFHud.font_sizes.default,
		color = WFHud.colors.default
	})

	self._interact_text_active = self._panel:text({
		visible = false,
		text = "Paying respects",
		font = WFHud.fonts.default,
		font_size = WFHud.font_sizes.default,
		color = WFHud.colors.default
	})

	self._interact_text_invalid = self._panel:text({
		visible = false,
		text = "Aim at valid surface",
		font = WFHud.fonts.default,
		font_size = WFHud.font_sizes.default,
		color = WFHud.colors.debuff
	})

	self:_layout()
end

function HUDInteractDisplay:_layout()
	local text_x = self._interact_circle._circle:right() + 4
	self._interact_text:set_x(text_x)
	self._interact_text_active:set_x(text_x)
	self._interact_text_invalid:set_x(text_x)

	local _, _, tw = self._interact_text:text_rect()
	self._interact_text:set_w(tw)
	_, _, tw = self._interact_text_active:text_rect()
	self._interact_text_active:set_w(tw)
	_, _, tw = self._interact_text_invalid:text_rect()
	self._interact_text_invalid:set_w(tw)
end

function HUDInteractDisplay:show_interact(text)
	self._interact_visible = true

	self._interact_text:set_text(text)
	self._interact_text:set_visible(not self._interacting_text or not self._interact_active)

	self:_layout()
end

function HUDInteractDisplay:hide_interact()
	self._interact_visible = false

	self._interact_text:set_visible(false)

	self._panel:set_visible(false)
end

function HUDInteractDisplay:show_interaction_circle(text, duration)
	self._interact_active = true

	self._interact_circle._circle:stop()
	if duration then
		self._interact_circle._circle:animate(function ()
			over(duration, function (t)
				self._interact_circle:set_current(t)
			end)
		end)
	end

	self._interacting_text = text

	if not text then
		return
	end

	self._interact_text:set_visible(false)
	self._interact_text_active:set_text(text)
	self._interact_text_active:set_visible(true)

	self:_layout()
end

function HUDInteractDisplay:hide_interaction_circle()
	self._interact_active = false

	self._interact_text:set_visible(self._interact_visible)
	self._interact_text_active:set_visible(false)
	self._interact_text_invalid:set_visible(false)
	self._interact_circle._circle:stop()
	self._interact_circle:set_current(0)

	self._panel:set_visible(false)
end

function HUDInteractDisplay:set_valid(invalid_text)
	if invalid_text then
		self._interact_text_invalid:set_text(invalid_text)
		self._interact_text_invalid:set_visible(true)
		self._interact_text:set_visible(false)
		self._interact_text_active:set_visible(false)

		self:_layout()
	else
		self._interact_text_invalid:set_visible(false)
		self._interact_text:set_visible(not self._interacting_text or not self._interact_active)
		self._interact_text_active:set_visible(self._interacting_text and self._interact_active)
	end
end

function HUDInteractDisplay:set_interaction_progress(t)
	self._interact_circle:set_current(t)
end

function HUDInteractDisplay:update(t, dt)
	if not self._interact_visible and not self._interact_active then
		self._panel:set_visible(false)
		return
	end

	local active_text = self._interact_text_active:visible() and self._interact_text_active or self._interact_text_invalid:visible() and self._interact_text_invalid or self._interact_text
	local half_width = active_text:w() * 0.5 + active_text:x()

	local unit = managers.interaction:active_unit()
	local pos = unit and unit:interaction():interact_position()
	if pos then
		mvec_set(tmp_vec, pos)
		mvec_add(tmp_vec, label_offset)
		local screen_pos = WFHud._ws:world_to_screen(managers.viewport:get_current_camera(), tmp_vec)
		self._panel:set_position(screen_pos.x - half_width, screen_pos.y - self._panel:h() * 0.5)
	else
		self._panel:set_position(self._panel:parent():w() * 0.5 - half_width, self._panel:parent():h() * 0.5 - self._panel:h() * 0.5)
	end

	self._panel:set_visible(true)
end
