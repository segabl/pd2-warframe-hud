Hooks:PostHook(HUDPresenter, "init", "init_wfhud", function (self)
	if self._hud_panel:child("present_panel") then
		self._hud_panel:child("present_panel"):hide()
		self._hud_panel:child("present_panel"):set_alpha(0)
	end

	self._present_panel = WFHud:panel():panel({
		visible = false,
		y = WFHud:panel():h() * 0.2,
		w = 0,
		h = 2 * WFHud.font_sizes.default
	})

	self._present_title = self._present_panel:text({
		font = WFHud.fonts.bold,
		font_size = WFHud.font_sizes.default,
		color = WFHud.colors.default,
		align = "center",
		vertical = "center",
		halign = "grow",
		h = WFHud.font_sizes.default,
		y = 0
	})

	self._present_text = self._present_panel:text({
		font = WFHud.fonts.default,
		font_size = WFHud.font_sizes.default,
		color = WFHud.colors.default,
		align = "center",
		vertical = "center",
		halign = "grow",
		h = WFHud.font_sizes.default,
		y = WFHud.font_sizes.default
	})
end)

Hooks:OverrideFunction(HUDPresenter, "present", function (self, params)
	self._present_queue = self._present_queue or {}

	-- Don't present objectives, we have an objective panel for that
	if params.event == managers.objectives:get_stinger_id() then
		managers.hud._sound_source:post_event(params.event)
		return
	end

	if self._presenting and not self._presenting.is_hint and params.is_hint then
		table.insert(self._present_queue, params)
		return
	end

	self:_present_information(params)
end)

Hooks:OverrideFunction(HUDPresenter, "_present_information", function (self, params)
	if params.event then
		managers.hud._sound_source:post_event(params.event)
	end

	self._presenting = params

	self._present_title:set_text(params.title and utf8.to_upper(params.title) or "")
	self._present_text:set_text(utf8.to_upper(params.text:gsub("%p$", "")))

	self._present_panel:stop()
	self._present_panel:animate(function (o)
		local x = o:parent():w() * 0.5
		local w = o:parent():w()

		o:set_w(0)
		o:show()
		over(1, function (t)
			o:set_w(w * t)
			o:set_center_x(x)
		end)
		wait(params.time or 3)
		over(1, function (t)
			o:set_w(w * (1 - t))
			o:set_center_x(x)
		end)
		o:hide()

		self:_present_done()
	end)
end)
