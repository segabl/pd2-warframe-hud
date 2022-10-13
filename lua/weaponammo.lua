local ids_texture = Idstring("texture")
local ammo_icon_redirects = {
	smg = "pistol",
}

local function set_ammo_total(self, ammo_total)
	if self._setup and self._setup.user_unit ~= managers.player:player_unit() then
		return
	end

	local current = self.get_ammo_total and self:get_ammo_total() or math.huge
	if current >= ammo_total then
		return
	end

	local categories = self:weapon_tweak_data().categories
	local category = categories[#categories]
	local ammo_icon = "guis/textures/wfhud/hud_icons/pickup_ammo_" .. (ammo_icon_redirects[category] or category)
	if not DB:has(ids_texture, Idstring(ammo_icon)) then
		ammo_icon = "guis/textures/wfhud/hud_icons/pickup_ammo"
	end
	WFHud:add_pickup(category .. "_ammo", ammo_total - current, nil, ammo_icon)
end

if RaycastWeaponBase then
	Hooks:PreHook(RaycastWeaponBase, "set_ammo_total", "set_ammo_total_wfhud", set_ammo_total)
end

if WeaponAmmo then
	Hooks:PreHook(WeaponAmmo, "set_ammo_total", "set_ammo_total_wfhud", set_ammo_total)
end
