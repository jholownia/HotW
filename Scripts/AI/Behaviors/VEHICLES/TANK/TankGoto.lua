local Behavior = CreateAIBehavior("TankGoto", "VehicleGoto",
{
	Alertness = 0,

	---------------------------------------------------------------------------------------------------------------------------------------
	OnBulletRain = function ( self, entity, sender )	

		-- called when there are bullet impacts nearby


	end,

	---------------------------------------------
	OnEnemyDamage = function( self, entity, sender, data )

		-- called when AI is damaged by an enemy AI
		
	end,

	--------------------------------------------------------------------------
	OnSomebodyDied = function( self, entity, sender )
	end,

	OnGroupMemberDied = function( self, entity, sender )
	end,

	OnGroupMemberDiedNearest = function( self, entity, sender, data )
		AI.Signal(SIGNALFILTER_GROUPONLY, 1, "OnGroupMemberDied",entity.id,data);
	end,

	--------------------------------------------------------------------------
	TANK_PROTECT_ME = function( self, entity, sender )

		if ( AI.GetSpeciesOf(entity.id) == AI.GetSpeciesOf(sender.id) ) then

			entity.AI.protect = sender.id;

			if ( entity.id == sender.id ) then
				if (entity.AI.mindType == 3 ) then
					entity.AI.mindType = 2;
				end
			else
				if (entity.AI.mindType == 2 ) then
					entity.AI.mindType = 3;
				end
			end

		end

	end,
})