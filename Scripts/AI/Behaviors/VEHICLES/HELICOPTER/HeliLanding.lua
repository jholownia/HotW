local Behavior = CreateAIBehavior("HeliLanding", "HeliReinforcement",
{
	Alertness = 0,

	Constructor = function( self, entity, sender, data )

		AIBehavior.HeliReinforcement:Constructor( entity );

	end,
})