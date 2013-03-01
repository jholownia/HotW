local Behavior = CreateAIBehavior("RacingCarRacing",
{
	Constructor = function(self, vehicle)
		vehicle.Racing.isComingBackToTrack = nil;
		AI.SetPathToFollow(vehicle.id, "");		-- This is to make the "next nearest road" just the "nearest road"
		g_gameRules:FollowNextNearestRoad(vehicle);
	end,

	OnEndWithinLookAheadDistance = function(self, vehicle)
		g_gameRules:FollowNextNearestRoad(vehicle);
	end,

	OnPathFollowingStuck = function(self, vehicle)
		g_gameRules.Server:SvBringBackToTrack(vehicle.id);
	end,

	OnReachedFinish = function(self, vehicle)
		vehicle.Racing.timeFinished = _time;
		vehicle:Event_DisableMovement();
		AI.SetBehaviorVariable(vehicle.id, "ai_driven", false);
	end,
});
