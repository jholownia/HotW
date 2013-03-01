local Xaxis =0;
local Yaxis =1;
local Zaxis =2;

local Behavior = CreateAIBehavior("HeliPatrol", "HeliBase",
{
	Alertness = 1,

	--------------------------------------------------------------------------
	Constructor = function ( self, entity, data )

		-- called when the behavior is selected
		-- the extra data is from the signal that caused the behavior transition
		entity.AI.vOrgPatrollPosition = {};
		CopyVector( entity.AI.vOrgPatrollPosition, entity:GetPos() );

		-- for common signal handlers.

		AI.CreateGoalPipe("heliPatrol");
		AI.PushGoal("heliPatrol","lookat",0,-500,0);
		AI.PushGoal("heliPatrol","run",0,0);
		AI.PushGoal("heliPatrol","continuous",0,1);
		AI.PushGoal("heliPatrol","followpath", 0, false, false, false, 0, 10, true );
		AI.PushGoal("heliPatrol","timeout",1,0.2);
		AI.PushGoal("heliPatrol","branch",1,-1);
		AI.PushGoal("heliPatrol","signal",1,1,"HELI_COMBAT_PATROL",SIGNALFILTER_SENDER);

		AI.CreateGoalPipe("heliPatrolGoUp");
		AI.PushGoal("heliPatrolGoUp","locate",0,"refpoint");
		AI.PushGoal("heliPatrolGoUp","lookat",0,0,0,true,1);
		AI.PushGoal("heliPatrolGoUp","run",0,2);
		AI.PushGoal("heliPatrolGoUp","continuous",0,1);
		AI.PushGoal("heliPatrolGoUp","followpath", 0, false, false, false, 0, -1, true );
		AI.PushGoal("heliPatrolGoUp","timeout",1,0.2);
		AI.PushGoal("heliPatrolGoUp","branch",1,-1);
		AI.PushGoal("heliPatrolGoUp","signal",0,1,"HELI_COMBAT_PATROL",SIGNALFILTER_SENDER);

		entity.AI.bBlockSignal = false;

		AI.CreateGoalPipe("heliPatrolDefault");
		-- devalue the target in case the heli comes this behavior having the target.
		-- AI.PushGoal("heliPatrolDefault","devalue",0,1); 
		AI.PushGoal("heliPatrolDefault","timeout",1,0.1);
		AI.PushGoal("heliPatrolDefault","signal",0,1,"HELI_COMBAT_PATROL",SIGNALFILTER_SENDER);
		entity:SelectPipe(0,"heliPatrolDefault");


	end,

	---------------------------------------------
	Destructor = function ( self, entity, data )
		-- called when the behavior is de-selected
		-- the extra data is from the signal that is causing the behavior transition
	end,

	---------------------------------------------
	OnPathFound = function( self, entity, sender )
		-- called when the AI has requested a path and it's been computed succesfully
	end,	
	--------------------------------------------------------------------------
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
		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AI.Hostile( entity.id, target.id )) then
			AI.Signal(SIGNALFILTER_SENDER,1,"TO_HELI_ATTACK", entity.id);
			return;
		end
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
		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AI.Hostile( entity.id, target.id )) then
			AI.Signal(SIGNALFILTER_SENDER,1,"TO_HELI_ATTACK", entity.id);
			return;
		end

		if ( AIBehavior.HELIDEFAULT:heliCheckDamage( entity, data ) == false ) then
			return;
		end

		if ( entity.AI.bBlockSignal == false ) then

			local targetEntity = System.GetEntity( data.id );
			if ( targetEntity ) then

				entity.AI.bBlockSignal = true;
		
				local vDir = {};
				local vCheckPos = {};
				SubVectors( vDir, targetEntity:GetPos(), entity:GetPos() );
				vDir.z = 0;
				local distance = LengthVector( vDir );
				if ( distance < 100 ) then
					return;
				end

				local vMid = {};

				NormalizeVector( vDir );
				FastScaleVector( vDir, vDir, ( distance - 100 ) );
				FastSumVectors( vCheckPos, vDir, entity:GetPos() );
				AIBehavior.HELIDEFAULT:GetAimingPosition2( entity, vCheckPos, targetEntity:GetPos() );

				FastSumVectors( vMid, vCheckPos, entity:GetPos() );
				FastScaleVector( vMid, vMid, 0.5 );

				local index = 1;
				AIBehavior.HELIDEFAULT:heliAddPathLine( entity, vMid, index );
				index = index + 1;
				AIBehavior.HELIDEFAULT:heliAddPathLine( entity, vCheckPos, index );

				if ( AIBehavior.HELIDEFAULT:heliCommitPathLine( entity, index, false ) == false ) then
					return;
				end

				CopyVector( entity.AI.vOrgPatrollPosition, entity:GetPos() );

				local bRun = 1;
				if ( entity.AI.isVtol == true ) then
					bRun = 0;
				end

				AI.SetRefPointPosition( entity.id , targetEntity:GetPos()  ); -- look target

				entity.AI.autoFire = 0
				entity.AI.autoFireTargetPos = {};
				CopyVector( entity.AI.autoFireTargetPos, targetEntity:GetPos() );

				AI.CreateGoalPipe("heliDamageAction");
				AI.PushGoal("heliDamageAction","locate",0,"refpoint");
				AI.PushGoal("heliDamageAction","lookat",0,0,0,true,1);
				AI.PushGoal("heliDamageAction","run",0,bRun);
				AI.PushGoal("heliDamageAction","continuous",0,1);
				AI.PushGoal("heliDamageAction","followpath", 0, false, false, false, 0, 10, true );
				AI.PushGoal("heliDamageAction","signal",1,1,"HELI_AUTOFIRE_CHECK_NOTARGET",SIGNALFILTER_SENDER);
				AI.PushGoal("heliDamageAction","timeout",1,0.2);
				AI.PushGoal("heliDamageAction","branch",1,-2);
				AI.PushGoal("heliDamageAction","firecmd",0,0);
				AI.PushGoal("heliDamageAction","signal",0,1,"HELI_COMBAT_PATROL",SIGNALFILTER_SENDER);
				AI.PushGoal("heliDamageAction","timeout",1,0.2);
				entity:InsertSubpipe(0,"heliDamageAction");

			end
	
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

	--------------------------------------------------------------------------
	HELI_COMBAT_PATROL = function ( self, entity )

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AIBehavior.HELIDEFAULT:heliCheckHostile( entity, target )==true ) then
			self:OnEnemySeen( entity, 0.0 );
		end

		entity.AI.bBlockSignal = false;

		local vMyPos = {};
		local vLookTarget = {};
		CopyVector( vMyPos, entity:GetPos() );
		local height = System.GetTerrainElevation( vMyPos );

		if ( height + 30.0 > vMyPos.z ) then
		
			-- if too far away from the original position
			local index = 1;
			AIBehavior.HELIDEFAULT:heliAddPathLine( entity, entity:GetPos(), index );
			index = index + 1;
			vMyPos.z =vMyPos.z + 30.0;

			AIBehavior.HELIDEFAULT:heliAddPathLine( entity, vMyPos, index );
			if ( AIBehavior.HELIDEFAULT:heliCommitPathLine( entity, index, false ) == false ) then
				AI.Signal(SIGNALFILTER_SENDER,1,"TO_HELI_ATTACK", entity.id);
				return;
			end
			FastScaleVector( vLookTarget, entity:GetDirectionVector(1), 300.0 );
			FastSumVectors( vLookTarget, vLookTarget, entity:GetPos() );
			AI.SetRefPointPosition( entity.id, vLookTarget );

			entity:SelectPipe(0,"heliPatrolGoUp");

			return;
		elseif ( DistanceVectors( entity:GetPos(), entity.AI.vOrgPatrollPosition ) > 150.0 ) then

			-- if too far away from the original position

			if ( height + 30.0 > entity.AI.vOrgPatrollPosition.z ) then
				entity.AI.vOrgPatrollPosition.z = height + 30.0;
			end

			local index = 1;
			AIBehavior.HELIDEFAULT:heliAddPathLine( entity, entity:GetPos(), index );
			index = index + 1;
			AIBehavior.HELIDEFAULT:heliAddPathLine( entity, entity.AI.vOrgPatrollPosition, index );
			if ( AIBehavior.HELIDEFAULT:heliCommitPathLine( entity, index, false ) == false ) then
				AI.Signal(SIGNALFILTER_SENDER,1,"TO_HELI_ATTACK", entity.id);
				return;
			end
			
		else

			local index = AIBehavior.HELIDEFAULT:heliMakePathCircle2( entity, 60.0, 1.0 );
			if ( AIBehavior.HELIDEFAULT:heliCommitPathLine( entity,  index, true ) == false ) then
				AI.Signal(SIGNALFILTER_SENDER,1,"TO_HELI_ATTACK", entity.id);
				return;
			end

		end

		entity:SelectPipe(0,"heliPatrol");

	end,
})