local Behavior = CreateAIBehavior("HeliAttack", "HeliBase",
{
	Alertness = 2,
	
	Constructor = function(self , entity )

		AI.CreateGoalPipe("heliAttackDefault");
		AI.PushGoal("heliAttackDefault","timeout",1,0.3);
		AI.PushGoal("heliAttackDefault","signal",0,1,"HELI_STAY_ATTACK",SIGNALFILTER_SENDER);
		entity:InsertSubpipe(0,"heliAttackDefault");
		return;


	end,
	--------------------------------------------------------------------------
	TO_HELI_EMERGENCYLANDING = function( self, entity, sender, data )
	end,

	--------------------------------------------------------------------------
	HELI_STAY_ATTACK = function( self, entity )

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AI.Hostile( entity.id, target.id ) ) then

				local target = AI.GetAttentionTargetEntity( entity.id );
				if ( target and AI.Hostile( entity.id, target.id ) ) then
					if ( AI.GetTypeOf( target.id ) == AIOBJECT_VEHICLE ) then
						if ( target.AIMovementAbility.pathType == AIPATH_TANK or target.AIMovementAbility.pathType == AIPATH_BOAT ) then
							AI.SetExtraPriority( target.id , 100.0 );
							AI.Signal(SIGNALFILTER_SENDER, 1, "TO_HELI_HOVERATTACK3", entity.id);
							return;
						end
					end
				end
				AI.Signal(SIGNALFILTER_SENDER, 1, "TO_HELI_HOVERATTACK2", entity.id);
				return;

			end
		
				AI.Signal(SIGNALFILTER_SENDER,1,"TO_HELI_PATROL", entity.id);
				return;
			
	end,

	---------------------------------------------
	OnPathFound = function( self, entity, sender )
		-- called when the AI has requested a path and it's been computed succesfully
	end,	
	---------------------------------------------
	OnNoTarget = function( self, entity )
		-- called when the AI stops having an attention target
	end,
	---------------------------------------------
	OnSomethingSeen = function( self, entity )
		-- called when the enemy sees a foe which is not a living player
	end,
	---------------------------------------------
	OnEnemySeen = function( self, entity, fDistance )
		-- called when the AI sees a living enemy
	end,
	---------------------------------------------
	OnSeenByEnemy = function( self, entity, sender )
	end,
	---------------------------------------------
	OnCloseContact= function( self, entity )
		-- called when AI gets at close distance to an enemy
	end,
	---------------------------------------------
	OnEnemyMemory = function( self, entity )
		-- called when the AI can no longer see its enemy, but remembers where it saw it last
	end,
	---------------------------------------------
	OnInterestingSoundHeard = function( self, entity )
		-- called when the AI hears an interesting sound
	end,
	---------------------------------------------
	OnThreateningSoundHeard = function( self, entity )
		-- called when the AI hears a threatening sound
	end,
	
	--------------------------------------------------------------------------
	OnBulletRain = function ( self, entity, sender, data )	
		self:OnEnemyDamage( entity, sender, data );
	end,
	--------------------------------------------------------------------------
	OnSoreDamage = function ( self, entity, sender, data )
		self:OnEnemyDamage( entity, sender, data );
	end,
	---------------------------------------------
	OnEnemyDamage = function ( self, entity, sender, data )

		if ( AIBehavior.HELIDEFAULT:heliCheckDamageRatio( entity ) == true ) then
			return;
		end
		if ( AIBehavior.HELIDEFAULT:heliCheckDamage( entity, data ) == false ) then
			return;
		end

	end,
	
	---------------------------------------------
	OnDamage = function ( self, entity, sender, data )
	end,
	
	---------------------------------------------
	OnGroupMemberDied = function( self, entity, sender )
		-- called when a member of same species dies nearby
	end,
	---------------------------------------------
	OnObjectSeen = function( self, entity, fDistance, data )
		-- called when the AI sees an object registered for this kind of signal
		-- data.iValue = AI object type
		-- example
		-- if (data.iValue == 150) then -- grenade
		--	 ...
		if ( data.iValue == AIOBJECT_RPG) then
			entity:InsertSubpipe(0,"devalue_target");
		end

	end,
})