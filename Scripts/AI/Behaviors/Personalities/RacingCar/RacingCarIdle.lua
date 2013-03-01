local Behavior = CreateAIBehavior("RacingCarIdle",
{
	Constructor = function(self, vehicle)
		vehicle:SelectPipe(0, "_first_");
	end,

	OnRaceStart = function(self, vehicle)
		vehicle:Event_EnableMovement();

		local driverId = vehicle:GetDriverId();
		if (driverId ~= NULL_ENTITY) then
			local driver = System.GetEntity(driverId);
			if (driver and driver.actor and (not driver.actor:IsPlayer())) then
				AI.SetBehaviorVariable(vehicle.id, "ai_driven", true);
			end
		end
	end,
});
