-- fixing some absurd label offsets...
Hooks:PostHook(VehicleTweakData, "init", "init_wfhud", function (self)
	self.bike_1.hud_label_offset = 120
	self.bike_2.hud_label_offset = 120
	self.blackhawk_1.hud_label_offset = 300
	self.boat_rib_1.hud_label_offset = 80
	self.muscle.hud_label_offset = 140
end)
