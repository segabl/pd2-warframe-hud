local hud_scale = WFHud.settings.hud_scale
local font_scale = WFHud.settings.font_scale

HUDPickup = WFHud:panel_class()

HUDPickup.ICON_SIZE = WFHud.font_sizes.default * font_scale * hud_scale
HUDPickup.DISPLAY_DURATION = 3

function HUDPickup:init(panel, id, icon, icon_rect, amount, item)
	self._id = id
	self._amount = amount

	self._display_duration = HUDPickup.DISPLAY_DURATION

	self._panel = panel:panel({
		alpha = 0,
		y = panel:h() - HUDPickup.ICON_SIZE,
		h = HUDPickup.ICON_SIZE
	})

	self._icon = self._panel:bitmap({
		visible = icon and true or false,
		texture = icon,
		texture_rect = icon_rect,
		w = HUDPickup.ICON_SIZE,
		h = HUDPickup.ICON_SIZE
	})

	self._amount_text = self._panel:text({
		text = tostring(amount),
		font = WFHud.fonts.default,
		font_size = WFHud.font_sizes.default * font_scale * hud_scale,
		vertical = "center"
	})

	self._item_text = self._panel:text({
		text = " " .. item:upper(),
		font = WFHud.fonts.default,
		font_size = WFHud.font_sizes.default * font_scale * hud_scale,
		vertical = "center"
	})

	self:_layout()

	self._panel:animate(callback(self, self, "_animate_panel_display"))
end

function HUDPickup:_layout()
	local _, _, w = self._amount_text:text_rect()
	self._amount_text:set_w(w)
	self._amount_text:set_x(self._icon:visible() and self._icon:right() + HUDPickup.ICON_SIZE / 4 or 0)

	_, _, w = self._item_text:text_rect()
	self._item_text:set_w(w)
	self._item_text:set_x(self._amount_text:right())

	self._panel:set_w(self._item_text:right())
	self._panel:set_center_x(self._panel:parent():w() * 0.5)
end

function HUDPickup:_animate_panel_display(panel)
	over(0.25, function (t)
		panel:set_alpha(t)
	end)
	panel:set_alpha(1)

	while self._display_duration > 0 do
		self._display_duration = -coroutine.yield() + self._display_duration
	end

	self._fading_out = true
	over(0.25, function (t)
		panel:set_alpha(1 - t)
	end)
	panel:set_alpha(0)
	self._dead = true
end

function HUDPickup:add_amount(amount)
	self._amount = self._amount + amount
	self._amount_text:set_text(tostring(self._amount))
	self:_layout()

	self._display_duration = math.max(HUDPickup.DISPLAY_DURATION * 0.5, self._display_duration)
end

function HUDPickup:destroy()
	if not alive(self._panel) then
		return
	end

	self._panel:stop()
	self._panel:parent():remove(self._panel)
end


HUDPickupList = WFHud:panel_class()

function HUDPickupList:init(panel)
	self._pickups = {}

	self._panel = panel:panel({
		h = panel:h() - WFHud.settings.margin_v
	})
end

function HUDPickupList:add(id, icon, icon_rect, amount, item)
	for _, v in pairs(self._pickups) do
		if v._id == id and not v._fading_out then
			v:add_amount(amount)
			return
		end
	end

	table.insert(self._pickups, HUDPickup:new(self._panel, id, icon, icon_rect, amount, item))
end

function HUDPickupList:update(t, dt)
	local i = 1
	while i <= #self._pickups do
		local pickup = self._pickups[i]
		if pickup._dead then
			table.remove(self._pickups, i)
		else
			local target_bottom = self._panel:h() - (#self._pickups - i) * pickup:h()
			local y_diff = target_bottom - pickup:bottom()
			if y_diff ~= 0 then
				if math.abs(y_diff) > 1 then
					local y_off = math.sign(y_diff) * dt * pickup:h() * 4
					pickup:set_bottom(pickup:bottom() + y_off)
				else
					pickup:set_bottom(target_bottom)
				end
			end
			i = i + 1
		end
	end
end

function HUDPickupList:destroy()
	if not alive(self._panel) then
		return
	end

	for _, pickup in pairs(self._pickups) do
		pickup:destroy()
	end

	self._panel:stop()
	self._panel:parent():remove(self._panel)
end
