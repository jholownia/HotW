AI.RegisterTacticalPointQuery({
	Name = "Civilian_HideFromEnemy",
	{
		Generation =
		{
			cover_from_attentionTarget_around_puppet = 25,
		},
		Conditions =
		{
			reachable = true,
		},
		Weights =
		{
			distance_to_puppet = -1,
		},
	},	
});
