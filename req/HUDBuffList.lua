if HUDBuffListItem then
	return
end

HUDBuffListItem = class()

HUDBuffListItem.ICON_SIZE = 40
HUDBuffListItem.ICON_SPACING = 4
HUDBuffListItem.NAME_DISPLAY_TIME = 3
HUDBuffListItem.PANEL_SHIFT_TIME = 0.05
HUDBuffListItem.CATEGORY_TEXTURE_RECTS = {
	speed = { 0, 0, 64, 64 },
	stamina = { 64, 0, 64, 64 },
	damage_dampener = { 128, 0, 64, 64 },
	critical_hit = { 192, 0, 64, 64 },
	health = { 0, 64, 64, 64 },
	armor = { 64, 64, 64, 64 },
	reload_speed = { 128, 64, 64, 64 },
	damage = { 192, 64, 64, 64 }
}

function HUDBuffListItem:init(parent_panel, upgrade_data, value, duration)
	self._upgrade_data = upgrade_data

	self._panel = parent_panel:panel({
		w = 320,
		h = self.ICON_SIZE + WFHud.font_sizes.small * 5
	})

	self._icon = self._panel:bitmap({
		texture = upgrade_data.texture,
		texture_rect = upgrade_data.texture_rect,
		color = upgrade_data.is_debuff and WFHud.colors.debuff or WFHud.colors.buff,
		w = self.ICON_SIZE,
		h = self.ICON_SIZE
	})
	self._icon:set_center(self._panel:w() * 0.5, self._panel:h() * 0.5 - WFHud.font_sizes.small * 0.5)

	-- Icon text
	self._icon_text = self._panel:text({
		text = " ",
		align = "center",
		color = WFHud.colors.default,
		font_size = WFHud.font_sizes.small,
		font = WFHud.fonts.bold,
	})
	local _, _, _, h = self._icon_text:text_rect()
	self._icon_text:set_h(h)
	self._icon_text:set_top(self._icon:bottom())

	-- Overlay text
	self._overlay_text_panel = self._panel:panel({
		visible = false
	})
	self._overlay_text_panel:set_top(self._icon:top())
	self._overlay_text_panel:rect({
		layer = 1,
		halign = "grow",
		valign = "grow",
		color = WFHud.colors.bg:with_alpha(0.75)
	})
	self._overlay_text = self._overlay_text_panel:text({
		layer = 2,
		halign = "grow",
		valign = "grow",
		text = " ",
		align = "center",
		vertical = "center",
		color = WFHud.colors.default,
		font_size = WFHud.font_sizes.small * 0.8,
		font = WFHud.fonts.default_no_shadow
	})

	-- Overlay icon
	self._overlay_icon = self._panel:bitmap({
		texture = "guis/textures/wfhud/buff_categories",
		texture_rect = HUDBuffListItem.CATEGORY_TEXTURE_RECTS[self._upgrade_data.icon_category],
		visible = false,
		layer = 2,
		color = WFHud.colors.default,
		w = HUDBuffListItem.ICON_SIZE * 0.5,
		h = HUDBuffListItem.ICON_SIZE * 0.5
	})
	self._overlay_icon:set_left(self._icon:left())
	self._overlay_icon:set_bottom(self._icon:bottom())

	-- Skill name
	self._flipped = HUDBuffListItem._last_activated_buff and not HUDBuffListItem._last_activated_buff._flipped
	self._name_arrow = self._panel:bitmap({
		visible = not upgrade_data.hide_name,
		texture = "guis/textures/pd2/scrollbar_arrows",
		color = upgrade_data.is_debuff and WFHud.colors.debuff or WFHud.colors.buff,
		alpha = 0,
		w = WFHud.font_sizes.small * 0.5,
		h = WFHud.font_sizes.small * 0.5,
		rotation = self._flipped and 180 or 0
	})
	self._name_arrow:set_center_x(self._icon:center_x() + 1)
	if self._flipped then
		self._name_arrow:set_bottom(self._icon:top() - WFHud.font_sizes.small * 0.25)
	else
		self._name_arrow:set_top(self._icon_text:bottom() + WFHud.font_sizes.small * 0.25)
	end

	self._name = self._panel:text({
		visible = not upgrade_data.hide_name,
		text = managers.localization:text(upgrade_data.name_id):pretty(true),
		align = "center",
		color = upgrade_data.is_debuff and WFHud.colors.debuff or WFHud.colors.buff,
		alpha = 0,
		font_size = WFHud.font_sizes.small,
		font = WFHud.fonts.bold
	})
	local _, _, w, h = self._name:text_rect()
	self._name:set_size(w, h)
	self._name:set_center_x(self._icon:center_x())
	if self._flipped then
		self._name:set_bottom(self._name_arrow:top())
	else
		self._name:set_top(self._name_arrow:bottom())
	end

	self:set_values(value, duration)
	self:set_category_icon_visibility(not upgrade_data.is_debuff and not self._upgrade_data.icon_category == "damage")
end

function HUDBuffListItem:set_values(value, duration)
	self._expired = false

	if not self._initialized then
		if not HUDBuffListItem._last_activated_buff or HUDBuffListItem._last_activated_buff._upgrade_data.name_id ~= self._upgrade_data.name_id then
			self._name_arrow:animate(function (o)
				over(duration and math.min(duration, HUDBuffListItem.NAME_DISPLAY_TIME) or HUDBuffListItem.NAME_DISPLAY_TIME, function (f)
					o:set_alpha((1 - f) * HUDBuffListItem.NAME_DISPLAY_TIME * 8)
					self._name:set_alpha((1 - f) * HUDBuffListItem.NAME_DISPLAY_TIME * 8)
				end)
				self._flipped = nil
			end)
		end
		HUDBuffListItem._last_activated_buff = self
		self._initialized = true
	end

	if duration then
		self._duration = duration

		self._icon_text:stop()
		self._icon_text:animate(function (o)
			local val
			over(duration, function (f)
				val = duration * (1 - f)
				o:set_text(string.format("%1.1f", val))
			end)
			self._expired = true
		end)
	end

	if type(value) =="string" or type(value) == "number" then
		if type(value) == "number" then
			value = self._upgrade_data.value_format(value)
		end
		if self._duration then
			self._overlay_text:set_text(tostring(value))
			local _, _, w, h = self._overlay_text:text_rect()
			self._overlay_text_panel:set_size(w + 4, h + 2)
			self._overlay_text_panel:set_right(self._icon:right())
			self._overlay_text_panel:set_visible(true)
		else
			self._icon_text:set_text(tostring(value))
		end
	end
end

function HUDBuffListItem:set_category_icon_visibility(state)
	self._overlay_icon:set_visible(HUDBuffListItem.CATEGORY_TEXTURE_RECTS[self._upgrade_data.icon_category] and state)
end

function HUDBuffListItem:set_index(i)
	if self._current_index then
		local old_i = self._current_index
		self._panel:animate(function (o)
			over(HUDBuffListItem.PANEL_SHIFT_TIME, function (f)
				o:set_center_x(o:parent():w() - (HUDBuffListItem.ICON_SIZE + HUDBuffListItem.ICON_SPACING) * ((i * f + old_i * (1 - f)) - 1) - HUDBuffListItem.ICON_SIZE * 0.5)
				local outside = o:x() + self._name:right() - o:parent():w()
				if outside > 0 then
					self._name:set_x(self._name:x() - outside)
				end
			end)
		end)
	else
		self._panel:set_center_x(self._panel:parent():w() - (HUDBuffListItem.ICON_SIZE + HUDBuffListItem.ICON_SPACING) * (i - 1) - HUDBuffListItem.ICON_SIZE * 0.5)
		local outside = self._panel:x() + self._name:right() - self._panel:parent():w()
		if outside > 0 then
			self._name:set_x(self._name:x() - outside)
		end
		self._panel:animate(function (o)
			over(HUDBuffListItem.PANEL_SHIFT_TIME * 2, function (f)
				o:set_y(math.lerp(-HUDBuffListItem.ICON_SIZE * 0.5, 0, f))
			end)
		end)
	end
	self._current_index = i
end

function HUDBuffListItem:destroy()
	if HUDBuffListItem._last_activated_buff and HUDBuffListItem._last_activated_buff._upgrade_data.name_id == self._upgrade_data.name_id then
		HUDBuffListItem._last_activated_buff = nil
		self._flipped = nil
	end
	if alive(self._panel) then
		self._panel:stop()
		self._name_arrow:stop()
		self._icon_text:stop()
		self._panel:parent():remove(self._panel)
	end
end


HUDBuffList = class()

function HUDBuffList:init(parent_panel, x, y, width, height)
	self._buff_list = {}
	self._buff_map = {}

	self._panel = parent_panel:panel({
		w = width,
		h = height,
		x = x,
		y = y
	})
end

function HUDBuffList:_get_existing_buff(upgrade_data)
	return self._buff_map[upgrade_data.name_id] and self._buff_map[upgrade_data.name_id][upgrade_data.key]
end

function HUDBuffList:_set_buff(upgrade_data, buff)
	self._buff_map[upgrade_data.name_id] = self._buff_map[upgrade_data.name_id] or {}
	local existing_buff = self._buff_map[upgrade_data.name_id][upgrade_data.key]
	if existing_buff then
		existing_buff._expired = true
		existing_buff:destroy()
	end
	self._buff_map[upgrade_data.name_id][upgrade_data.key] = buff
end

function HUDBuffList:add_buff(upgrade_data, value, duration)
	--log(tostring(upgrade_data.name_id), tostring(upgrade_data.key))
	local buff = self:_get_existing_buff(upgrade_data)
	if buff then
		buff:set_values(value, duration)
		return
	end
	buff = HUDBuffListItem:new(self._panel, upgrade_data, value, duration)
	table.insert(self._buff_list, buff)
	buff:set_index(#self._buff_list)
	self:_set_buff(upgrade_data, buff)
	if table.size(self._buff_map[upgrade_data.name_id]) > 1 then
		for _, b in pairs(self._buff_map[upgrade_data.name_id]) do
			b:set_category_icon_visibility(true)
		end
	end
end

function HUDBuffList:remove_buff(upgrade_data)
	local buff = self:_get_existing_buff(upgrade_data)
	if buff then
		buff._expired = true
	end
end

function HUDBuffList:update(t, dt)
	local remove = {}
	for i, buff in ipairs(self._buff_list) do
		if buff._expired then
			table.insert(remove, i - #remove)
			self:_set_buff(buff._upgrade_data, nil)
		elseif #remove > 0 then
			buff:set_index(i - #remove)
		end
	end
	for _, i in pairs(remove) do
		table.remove(self._buff_list, i)
	end
end
