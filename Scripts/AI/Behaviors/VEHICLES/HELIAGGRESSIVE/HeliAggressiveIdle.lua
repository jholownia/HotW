local Behavior = CreateAIBehavior("HeliAggressiveIdle", "HeliIdle",
{
	Constructor = function( self , entity )
		self.parent:Constructor( entity );

		AI.ChangeParameter(entity.id,AIPARAM_SIGHTENVSCALE_NORMAL,1);
		AI.ChangeParameter(entity.id,AIPARAM_SIGHTENVSCALE_ALARMED,1);
	end,
})