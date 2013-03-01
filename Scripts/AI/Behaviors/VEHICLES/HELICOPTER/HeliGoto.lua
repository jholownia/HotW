local Behavior = CreateAIBehavior("HeliGoto", "VehicleGoto",
{
	OnEnemySeen = function( self, entity, fDistance )

		if ( entity.AI.vehicleIgnorantIssued == true ) then
			return;
		end

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AI.Hostile( entity.id, target.id ) ) then
			AI.Signal(SIGNALFILTER_SENDER, 1, "TO_HELI_ATTACK", entity.id);
		end

	end,
	--------------------------------------------------------------------------
	OnBulletRain = function ( self, entity, sender, data )	
		self:OnEnemyDamage( entity, sender, data );
	end,
	---------------------------------------------
	OnEnemyDamage = function ( self, entity, sender, data )

		if ( entity.AI.vehicleIgnorantIssued == true ) then
			return;
		end

		if ( AIBehavior.HELIDEFAULT:heliCheckDamage( entity, data ) == false ) then
			return;
		end
		AI.Signal(SIGNALFILTER_SENDER, 1, "TO_HELI_PATROL", entity.id);

	end,
})