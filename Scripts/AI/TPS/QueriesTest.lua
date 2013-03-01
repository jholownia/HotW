
----------------------------------------------------------------------------------------
--  Description: Tactical Position specifications for testing purposes
--  Created by: Matthew Jack
----------------------------------------------------------------------------------------

AI.TacticalPositionManager.Test = AI.TacticalPositionManager.Test or {};

function AI.TacticalPositionManager.Test:OnInit()

	AI.RegisterTacticalPointQuery ( {
		Name = "RefPointHideTest",
		{
				Generation =	{	hidespots_from_attentionTarget_around_referencePoint = 15 },
				Conditions = 	{  },
				Weights =			{ distance_from_attentionTarget = -1.0 },
		},
	} );

	AI.RegisterTacticalPointQuery ( {
		Name = "RandomTest",
		{
				Parameters =	{ density = 1 },
				Generation =	{	grid_around_puppet = 2.6 },
				Conditions = 	{ },
				Weights =			{ random = 1.0 },
		},
	} );

	AI.RegisterTacticalPointQuery ( {
		Name = "DirectnessTest",
		{
				Generation =	{	hidespots_from_player_around_player = 45 },
				Conditions = 	{ towards_the_player = true, canReachBefore_the_player = true },
				Weights =			{ directness_to_player = 1.0 },
		},
	} );
	
	AI.RegisterTacticalPointQuery ( {
		Name = "DensityTest",
		{
				Generation =	{	hidespots_from_player_around_player = 40 },
				Conditions = 	{ canReachBefore_the_player = true },
				Weights =			{ coverDensity = 1.0 },
		},
	} );
	
	
	AI.RegisterTacticalPointQuery ( {
		Name = "VisibilityTest",
		{
				Generation =	{	hidespots_from_player_around_player = 25 },
				Conditions = 	{ min_cameraCenter = 0.0 },
				Weights =			{ cameraCenter = 1.0, distance_from_player = -0.2,  distance_from_puppet = -0.2 },
		},
	} );

	AI.RegisterTacticalPointQuery ( {
		Name = "HostilesTest",
		{
				Generation =	{	hidespots_from_player_around_puppet = 20 },
				Conditions = 	{  },
				Weights =			{ hostilesDistance = 1.0 },
		},
	} );
	
	AI.RegisterTacticalPointQuery ( {
		Name = "LineOfFireTest",
		{
				Generation =	{	hidespots_from_player_around_player = 15 },
				Conditions = 	{ crossesLineOfFire_from_player = true },
				Weights =			{ distance_from_player = -1.0, distance_from_puppet = -1.0 },
		},
	} );
	
	
	
	AI.RegisterTacticalPointQuery ( {
		Name = "SimpleHide",
		{
				Generation =	{	hidespots_from_attentionTarget_around_puppet = 20 },
				Conditions = 	{ canReachBefore_the_attentionTarget = true, 
												--min_distanceLeft_to_attentionTarget = 0,
											},
				Weights =			{ coverSuperior = 1.0,  
												distance_from_puppet = -1.0, 
												distance_to_attentionTarget = -1.0
												
				 },
		},
	} );


	AI.RegisterTacticalPointQuery ( {
		Name = "SimpleSquadmate",
		{
				Generation =	{	hidespots_from_attentionTarget_around_player = 25 },
				Conditions = 	{ crossesLineOfFire_from_player = false },
				Weights =			{ canReachBefore_the_attentionTarget = 2.0, distance_from_player = -1.0, cameraCenter = 1.0 },
		},
		{
				Generation =	{	hidespots_from_player_around_player = 25 },
				Conditions = 	{  },
				Weights =			{ distance_from_player = -1.0, cameraCenter = 1.0 },
		},
	} );


	AI.RegisterTacticalPointQuery ( {
		Name = "ReachableGridTest",
		{
				Parameters =	{ density = 2 },
				Generation =	{	grid_around_puppet = 20 },
				Conditions = 	{ reachable = true },
				Weights =			{ distance_from_player = -1.0 },
		},
	} );


	AI.RegisterTacticalPointQuery ( {
		Name = "RaycastTest",
		{
				Parameters =	{ density = 2 },
				Generation =	{	grid_around_puppet = 20 },
				Conditions = 	{ visible_from_player = false, reachable = true },
				Weights =			{ distance_from_puppet = -1.0 },
		},
	} );
	
	AI.RegisterTacticalPointQuery({
		Name = "FlankLeftQuery",
		{
			Generation =
			{
				cover_from_attentionTarget_around_puppet = 25,
			},
			Conditions =
			{
				min_distance_from_puppet = 5.0,
				min_distance_from_attentionTarget = 5.0,
				max_distanceLeft_to_attentionTarget = 0,
				towards_the_attentionTarget = true,
				crossesLineOfFire_to_attentionTarget = false,
			},
			Weights =
			{
				distance_to_attentionTarget = -0.4,
				directness_to_attentionTarget = -0.25,
				distance_to_puppet = -0.35,
			},
		},
		{
			Generation =
			{
				cover_from_attentionTarget_around_puppet = 25,
			},
			Conditions =
			{
				min_distance_from_puppet = 2.0,
				min_distance_from_attentionTarget = 4.0,
				towards_the_attentionTarget = true,
			},
			Weights =
			{
				distance_to_attentionTarget = -0.35,
				directness_to_attentionTarget = -0.2,
				distance_to_puppet = -0.3,
				distanceLeft_to_attentionTarget = 0.15,
			},
		},		
	});
	
	
		
	AI.RegisterTacticalPointQuery({
		Name = "FlankRightQuery",
		{
			Generation =
			{
				cover_from_attentionTarget_around_puppet = 25,
			},
			Conditions =
			{
				min_distance_from_puppet = 5.0,
				min_distance_from_attentionTarget = 5.0,
				min_distanceLeft_to_attentionTarget = 0,
				towards_the_attentionTarget = true,
				crossesLineOfFire_to_attentionTarget = false,
			},
			Weights =
			{
				distance_to_attentionTarget = -0.4,
				directness_to_attentionTarget = -0.25,
				distance_to_puppet = -0.35,
			},
		},
		{
			Generation =
			{
				cover_from_attentionTarget_around_puppet = 25,
			},
			Conditions =
			{
				min_distance_from_puppet = 2.0,
				min_distance_from_attentionTarget = 4.0,
				towards_the_attentionTarget = true,
			},
			Weights =
			{
				distance_to_attentionTarget = -0.35,
				directness_to_attentionTarget = -0.2,
				distance_to_puppet = -0.3,
				distanceLeft_to_attentionTarget = -0.15,
			},
		},
	});	

end