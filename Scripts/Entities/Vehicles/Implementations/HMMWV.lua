HMMWV =
{
	Properties = 
	{	
		bDisableEngine = 0,
		material = "",
		Modification = "",
		soclasses_SmartObjectClass = "Car",
	},
	
	Client = {},
	Server = {},
}

HMMWV.AIProperties = 
{
  AIType = AIOBJECT_CAR,
  
  PropertiesInstance = 
  {
    aibehavior_behaviour = "CarIdle",
  },
  
  Properties = 
  {
    aicharacter_character = "Car",
  },
  
  AIMovementAbility = 
  {
		maxAccel = 12,
		maxDecel = 6,
		minTurnRadius = 4,
		maxTurnRadius = 15,    
		walkSpeed = 50,
		runSpeed = 50,	-- Maximum speed (without boost)
		sprintSpeed = 50,

		maneuverSpeed = 0,	-- Brake at peaks
		slopeSlowDown = 0.02,

		maneuverTrh = 0,
		pathType = "AIPATH_RACING_CAR",
		pathLookAhead = 30,
		pathRadius = 2,
		pathSpeedLookAheadPerSpeed = 0,
		cornerSlowDown = 0,
		pathFindPrediction = 1.0,
		velDecay = 0,
		resolveStickingInTrace = 0,
		pathRegenIntervalDuringTrace = 3,
		avoidanceRadius = 3,
  }, 
}
