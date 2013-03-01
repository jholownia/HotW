local Behavior = CreateAIBehavior("VtolGoto", "HeliGoto",
{
	Alertness = 0,
	
	OnEnemySeen = function( self, entity, fDistance )
		AIBehavior.HELIDEFAULT:heliRequest2ndGunnerShoot( entity );
	end,
})