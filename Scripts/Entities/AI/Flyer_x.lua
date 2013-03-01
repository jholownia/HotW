Script.ReloadScript("SCRIPTS/Entities/actor/BasicActor.lua");
Script.ReloadScript("SCRIPTS/Entities/AI/Shared/BasicAI.lua");

Flyer_x = 
{
	AnimationGraph = "",
	
	AIType = AIOBJECT_2D_FLY,

	PropertiesInstance = 
	{
		aibehavior_behaviour = "FlyerIdle",
	},

	Properties = 
	{
		esBehaviorSelectionTree = "Flyer",
		
		fileModel = "Objects/Characters/Dragon/Dragon.cdf",		
		
		Damage =
		{
			health = 1,
		},
	},

	gameParams =
	{
		stance =
		{
			{
				stanceId = STANCE_STAND,
				normalSpeed = 10,
				maxSpeed = 20,
				heightCollider = 0,
				heightPivot = -1,
				size = { x = 3, y = 3, z = 3 },
				viewOffset = { x = 0, y = 0, z = 0 },
				name = "fly",
			},
		},
	},
	
	AIMovementAbility =
	{
		b3DMove = 1,
		optimalFlightHeight = 15,
		minFlightHeight = 10,
		maxFlightHeight = 30,
		pathType = AIPATH_HELI,
	},
}


function Flyer_x:OnResetCustom()
	self.AI.bUpdate = false;
end
