Hooks:PostHook(HUDInteraction, "init", "init_wfhud", function (self)
	self._circle_radius = 8
	self._sides = 8

	local interact_text = self._hud_panel:child(self._child_name_text)
	interact_text:set_font(Idstring(WFHud.fonts.default))
	interact_text:set_font_size(24)
	interact_text:set_h(24)
	interact_text:set_center(self._hud_panel:w() * 0.5, self._hud_panel:h() * 0.5)

	local invalid_text = self._hud_panel:child(self._child_ivalid_name_text)
	invalid_text:set_font(Idstring(WFHud.fonts.default))
	invalid_text:set_font_size(24)
	invalid_text:set_h(24)
	invalid_text:set_center(self._hud_panel:w() * 0.5, self._hud_panel:h() * 0.5)
end)

Hooks:PostHook(HUDInteraction, "show_interact", "show_interact_wfhud", function (self)
	local interact_text = self._hud_panel:child(self._child_name_text)
	local _, _, tw = interact_text:text_rect()
	interact_text:set_center(self._hud_panel:w() * 0.5, self._hud_panel:h() * 0.5)

	if self._interact_circle then
		self._interact_circle:set_position(interact_text:center_x() - tw * 0.5 - self._circle_radius * 2 - 4, interact_text:y() + 2)
	end

	if self._interact_circle_locked then -- press2hold compat
		self._interact_circle_locked:set_position(interact_text:center_x() - tw * 0.5 - self._circle_radius * 2 - 4, interact_text:y() + 2)
	end

	interact_text:stop()
	interact_text:animate(function (o) -- mfw I use animate for everything
		local ws = managers.hud._saferect
		local cam = managers.viewport:get_current_camera()
		while alive(ws) and alive(cam) do
			local unit = managers.interaction:active_unit()
			local pos = unit and unit:interaction():interact_position()
			if pos then
				local screen_pos = ws:world_to_screen(cam, pos)
				o:set_center(screen_pos.x, screen_pos.y)
				if self._interact_circle then
					_, _, tw = interact_text:text_rect()
					self._interact_circle:set_position(o:center_x() - tw * 0.5 - self._circle_radius * 2 - 4, o:y() + 2)
					if self._interact_circle_locked then -- press2hold compat
						self._interact_circle_locked:set_position(o:center_x() - tw * 0.5 - self._circle_radius * 2 - 4, o:y() + 2)
					end
				end
			end
			coroutine.yield()
		end
	end)
end)

Hooks:PostHook(HUDInteraction, "remove_interact", "remove_interact_wfhud", function (self)
	if not alive(self._hud_panel) then
		return
	end

	self._hud_panel:child(self._child_name_text):stop()
end)

Hooks:PostHook(HUDInteraction, "show_interaction_bar", "show_interaction_bar_wfhud", function (self)
	if not self._interact_circle then
		return
	end

	local interact_text = self._hud_panel:child(self._child_name_text)
	local unit = managers.interaction:active_unit()
	if unit then
		local action_text = managers.localization:to_upper_text(unit:interaction()._tweak_data.action_text_id or "hud_action_generic")
		self._old_interaction_text = self._old_interaction_text or interact_text:text()
		interact_text:set_text(action_text)
	end

	self._interact_circle._circle:set_image("guis/textures/pd2/hud_progress_32px")
	if self._interact_circle._bg_circle then
		self._interact_circle._bg_circle:set_alpha(0)
	end

	if self._interact_circle_locked then -- press2hold compat
		self._interact_circle_locked._circle:set_image("guis/textures/pd2/hud_progress_32px")
	end
end)

function HUDInteraction:hide_interaction_bar(complete)
	local interact_text = self._hud_panel:child(self._child_name_text)
	local unit = managers.interaction:active_unit()
	if unit and self._old_interaction_text then
		interact_text:set_text(self._old_interaction_text)
		self._old_interaction_text = nil
	end

	if self._interact_circle then
		self._interact_circle:remove()
		self._interact_circle = nil
	end

	if self._interact_circle_locked then -- press2hold compat
		self._interact_circle_locked:remove()
		self._interact_circle_locked = nil
	end
end

Hooks:PostHook(HUDInteraction, "set_bar_valid", "set_bar_valid_wfhud", function (self, valid)
	if not self._interact_circle then
		return
	end

	self._interact_circle._circle:set_image(valid and "guis/textures/pd2/hud_progress_32px" or "guis/textures/wfhud/hud_progress_32px_invalid")

	local text = self._hud_panel:child(valid and self._child_name_text or self._child_ivalid_name_text)
	local _, _, tw = text:text_rect()
	self._interact_circle:set_position(text:center_x() - tw * 0.5 - self._circle_radius * 2 - 4, text:y() + 2)
end)
