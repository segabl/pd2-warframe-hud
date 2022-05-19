-- Helper
function NewRaycastWeaponBase:has_underbarrel()
	if self._cached_underbarrel == nil and self._assembly_complete then
		self._cached_underbarrel = false

		local gadgets = managers.weapon_factory:get_parts_from_weapon_by_type_or_perk("underbarrel", self._factory_id, self._blueprint)
		local gadget = nil

		for _, id in pairs(gadgets) do
			gadget = self._parts[id]
			local gadget_base = gadget and gadget.unit and gadget.unit:base() or gadget.base and gadget:base()
			if gadget_base and gadget_base:overrides_weapon_firing() then
				self._cached_underbarrel = true
				break
			end
		end
	end

	return self._cached_underbarrel
end
