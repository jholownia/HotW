local Xaxis =0;
local Yaxis =1;
local Zaxis =2;

local Behavior = CreateAIBehavior("HeliBase",
{
	HELI_AUTOFIRE_CHECK_NOTARGET = function( self, entity )
		if ( entity.AI.autoFire == 0 ) then
			local vFwd = {};
			SubVectors( vFwd, entity.AI.autoFireTargetPos, entity:GetPos() );
			NormalizeVector( vFwd );
			if ( dotproduct3d( vFwd, entity:GetDirectionVector(Yaxis) ) > math.cos( 90.0 * 3.1415 / 180.0 ) ) then
				AI.SetRefPointPosition( entity.id, entity.AI.autoFireTargetPos );
				entity.AI.autoFire = entity.AI.autoFire + 1;
				AI.CreateGoalPipe("heliShootMissileA");
				AI.PushGoal("heliShootMissileA","locate",0,"refpoint");
				AI.PushGoal("heliShootMissileA","acqtarget",0,"");
				AI.PushGoal("heliShootMissileA","firecmd",0,FIREMODE_CONTINUOUS);
				entity:InsertSubpipe(0,"heliShootMissileA");
			end
		end

		if ( entity.AI.autoFire > 0 ) then
			if ( entity.AI.autoFire == 5 ) then
				AI.CreateGoalPipe("heliStopMissileA");
				AI.PushGoal("heliStopMissileA","firecmd",0,0);
				entity:InsertSubpipe(0,"heliStopMissileA");
			end
			entity.AI.autoFire = entity.AI.autoFire +1;
		end

	end,

	HELI_AUTOFIRE_CHECK = function( self, entity )

		local target = AI.GetAttentionTargetEntity( entity.id );
		if ( target and AI.Hostile( entity.id, target.id ) ) then -- we need target
		
			if ( entity.AI.autoFire == 0 ) then
				local vFwd = {};
				SubVectors( vFwd, target:GetPos(), entity:GetPos() );
				NormalizeVector( vFwd );
				if ( dotproduct3d( vFwd, entity:GetDirectionVector(Yaxis) ) > math.cos( 90.0 * 3.1415 / 180.0 ) ) then
					if ( AIBehavior.HELIDEFAULT:heliDoesUseMachineGun( entity ) == false ) then
						AI.SetRefPointPosition( entity.id, entity.AI.autoFireTargetPos );
						entity.AI.autoFire = entity.AI.autoFire + 1;
						AI.CreateGoalPipe("heliShootMissileB");
						AI.PushGoal("heliShootMissileB","firecmd",0,FIREMODE_CONTINUOUS);
						entity:InsertSubpipe(0,"heliShootMissileB");
					end
				end
			end

			if ( entity.AI.autoFire > 0 ) then
				if ( entity.AI.autoFire == 10 ) then
					AI.CreateGoalPipe("heliStopMissileB");
					AI.PushGoal("heliStopMissileB","firecmd",0,0);
					entity:InsertSubpipe(0,"heliStopMissileB");
				end
				entity.AI.autoFire = entity.AI.autoFire +1;
			end			

		end
	
	end,
})