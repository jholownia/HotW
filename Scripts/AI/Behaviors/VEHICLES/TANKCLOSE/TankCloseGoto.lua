local Behavior = CreateAIBehavior("TankCloseGoto", "VehicleGoto",
{
	Alertness = 0,

	OnBulletRain = function ( self, entity, sender )	
	end,

	---------------------------------------------
	OnEnemyDamage = function( self, entity, sender, data )
	end,
})
