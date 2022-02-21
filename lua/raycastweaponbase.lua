local ids_texture = Idstring("texture")
local ammo_icon_redirects = {
	revolver = "pistol",
	smg = "pistol",
}

local add_ammo_original = RaycastWeaponBase.add_ammo
function RaycastWeaponBase:add_ammo(...)
	local picked_up, add_amount = add_ammo_original(self, ...)

	if picked_up and add_amount > 0 and self._setup.user_unit == managers.player:player_unit() then
		local categories = self:weapon_tweak_data().categories
		local category = categories[#categories]
		local ammo_icon = "guis/textures/wfhud/hud_icons/pickup_ammo_" .. (ammo_icon_redirects[category] or category)
		if not DB:has(ids_texture, Idstring(ammo_icon)) then
			ammo_icon = "guis/textures/wfhud/hud_icons/pickup_ammo"
		end
		WFHud:add_pickup(category .. "_ammo", add_amount, nil, ammo_icon)
	end

	return picked_up, add_amount
end
