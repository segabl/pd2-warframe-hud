local add_ammo_original = RaycastWeaponBase.add_ammo
function RaycastWeaponBase:add_ammo(...)
	local picked_up, add_amount = add_ammo_original(self, ...)

	if picked_up and add_amount > 0 and self._setup.user_unit == managers.player:player_unit() then
		local categories = self:weapon_tweak_data().categories
		local id = categories[#categories] .. "_ammo"
		WFHud:add_pickup(id, add_amount)
	end

	return picked_up, add_amount
end
