Hooks:PreHook(HUDBossBar, "set_unit", "set_unit_boss_pre", function (self, unit)
	if not alive(unit) and not self._fading_out then
		if self._queued_sounds then
			if math.random() < 0.5 then
				table.insert(self._queued_sounds, WFHud.mod_path .. "assets/boss/11.ogg")
				table.insert(self._subs, "This death is temporary, my existence is forever. I cannot be destroyed.")
			else
				table.insert(self._queued_sounds, WFHud.mod_path .. "assets/boss/12.ogg")
				table.insert(self._subs, "Behold, they cut me down but still I speak. I am energy and I cannot be destroyed.")
			end
		end
		return
	end

	if self._unit or self._audio_source then
		return
	end

	self._audio_source = XAudio.Source:new()
	self._audio_source:set_relative(false)
	self._queued_sounds = {
		WFHud.mod_path .. "assets/boss/01.ogg",
		WFHud.mod_path .. "assets/boss/02.ogg",
		WFHud.mod_path .. "assets/boss/03.ogg",
		WFHud.mod_path .. "assets/boss/04.ogg",
		WFHud.mod_path .. "assets/boss/05.ogg",
		WFHud.mod_path .. "assets/boss/06.ogg",
		WFHud.mod_path .. "assets/boss/07.ogg",
		WFHud.mod_path .. "assets/boss/08.ogg",
		WFHud.mod_path .. "assets/boss/09.ogg",
		WFHud.mod_path .. "assets/boss/10.ogg",
	}
	self._subs = {
		"Look at them, they come to this place when they know they are not pure.",
		"Tenno use the keys, but they are mere trespassers. Only I, Vor, know the true power of the Void.",
		"I was cut in half, destroyed, but through it's Janus Key, the Void called to me. It brought me here and here I was reborn.",
		"We cannot blame these creatures, they are being led by a false prophet, an impostor who knows not the secrets of the Void.",
		"Behold the Tenno, come to scavenge and desecrate this sacred realm.",
		"My brothers, did I not tell of this day? Did I not prophesize this moment?",
		"Now, I will stop them. Now I am changed, reborn through the energy of the Janus Key. Forever bound to the Void.",
		"Let it be known, if the Tenno want true salvation, they will lay down their arms, and wait for the baptism of my Janus key.",
		"It is time. I will teach these trespassers the redemptive power of my Janus key. They will learn it's simple truth.",
		"The Tenno are lost, and they will resist. But I, Vor, will cleanse this place of their impurity."
	}

	managers.hud:add_updator("vor", function ()
		if self._audio_source:get_state() ~= XAudio.Source.PLAYING then
			if self._current_buffer then
				self._current_buffer:close()
				self._current_buffer = nil
			end

			local path = table.remove(self._queued_sounds, 1)
			if not path then
				return
			end
			local sub = table.remove(self._subs, 1)

			self._current_buffer = XAudio.Buffer:new(path)
			self._audio_source:set_buffer(self._current_buffer)
			self._audio_source:play()
			WFHud.objective_panel:set_subtitle("VOR", sub, self._current_buffer:get_length() + 1, true)
		end
	end)

	HUDObjectivePanel.CHARACTER_COLORS["VOR"] = WFHud.settings.colors.enemy

	local set_sub = HUDObjectivePanel.set_subtitle
	HUDObjectivePanel.set_subtitle = function (self, speaker, text, duration, force)
		if force or not self._force or self._subtitle_panel:alpha() <= 0 then
			self._force = force
			set_sub(self, speaker, text, duration)
		end
	end
end)

local hud_scale = WFHud.settings.hud_scale
local font_scale = WFHud.settings.font_scale

Hooks:PostHook(HUDBossBar, "set_unit", "set_unit_boss_post", function (self, unit)
	if not self._unit then
		return
	end

	self._name_text:set_text("VOR")
	local _, _, w = self._name_text:text_rect()
	self._name_text:set_w(w - self._name_text:kern() * hud_scale * font_scale * 0.5)
	self._name_text:set_center_x(self._panel:w() * 0.5)
end)
