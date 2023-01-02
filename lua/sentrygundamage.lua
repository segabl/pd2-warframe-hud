-- stuff to make damage numbers show up correctly against turrets
local damage_bullet_original = SentryGunDamage.damage_bullet
function SentryGunDamage:damage_bullet(attack_data, ...)
	self._wfhud_current_attack_data = attack_data

	if attack_data.col_ray and attack_data.col_ray.body and attack_data.col_ray.body:name() == self._bag_body_name_ids then
		attack_data.headshot = true
	end

	local result = damage_bullet_original(self, attack_data, ...)

	self._wfhud_current_attack_data = nil

	return result
end

Hooks:PreHook(SentryGunDamage, "_apply_damage", "_apply_damage_wfhud", function (self, damage, dmg_shield)
	local attack_data = self._wfhud_current_attack_data
	if attack_data and type(damage) == "number" then
		attack_data.raw_damage = damage
		attack_data.critical_hit = damage > attack_data.damage * (attack_data.headshot and tweak_data.weapon[self._unit:base():get_name_id()].BAG_DMG_MUL or 1) * 1.5
	end
end)
