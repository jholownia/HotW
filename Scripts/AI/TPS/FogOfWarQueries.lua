AI.TacticalPositionManager.Grunt = AI.TacticalPositionManager.Grunt or {};

function AI.TacticalPositionManager.Grunt:OnInit()
	
	AI.RegisterTacticalPointQuery({
		Name = "FogOfWarEscapeCoverQuery",
		{
			Generation =
			{
				hidespots_from_attentionTarget_around_puppet = 25,
			},
			Conditions =
			{
				min_distance_to_attentionTarget = 10.0,
				canReachBefore_the_attentionTarget = true,
				hasShootingPosture_to_attentionTarget = true,
			},
			Weights =
			{
				distance_to_puppet = 0.1,
				distance_to_attentionTarget = 0.9,
			},
		},	
	});

end