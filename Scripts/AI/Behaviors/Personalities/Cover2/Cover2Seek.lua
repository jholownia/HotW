--------------------------------------------------
-- Cover2Seek
--------------------------
--   created: Mikko Mononen 21-6-2006


local Behavior = CreateAIBehavior("Cover2Seek", "Cover2Attack",
{
	Alertness = 1,

	---------------------------------------------
	Constructor = function (self, entity)

		entity:GettingAlerted();

		if(not entity.AI.target) then
			entity.AI.target = {x=0, y=0, z=0};
		else
			ZeroVector(entity.AI.target);
		end
		
		entity.AI.lastBulletReactionTime = _time - 10;
		entity.AI.lastLookatTime = _time - 10;
		
		local range = entity.Properties.preferredCombatDistance;
		local radius = 4.0;
		if(AI.GetNavigationType(entity.id) == NAV_WAYPOINT_HUMAN) then
			range = range / 2;
			radius = 2.5;
		end
		
		AI.SetPFBlockerRadius(entity.id, eNB_DEAD_BODIES, -radius);
		AI.SetPFBlockerRadius(entity.id, eNB_EXPLOSIVES, radius);
		AI.SetPFBlockerRadius(entity.id, eNB_REF_POINT, 0);
  	
		entity.AI.seekCount = 0;

		-- If using secondary weapon or running low on ammo, reload.
		-- If the target is not visible, this will also switch back
		-- to the primary weapon an reload it.
		if(entity:CheckCurWeapon() == 1 or entity:GetAmmoLeftPercent() < 0.25) then
			entity.AI.reloadReturnToSeek = true;
			AI.Signal(SIGNALFILTER_SENDER,1,"TO_RELOAD",entity.id);
		end

		if(entity:CheckCurWeapon() == 1) then
			AI.LogEvent(">> PRIMARY weapon"..entity:GetName());
			entity:SelectPrimaryWeapon();
		end

		--self:COVER_NORMALATTACK(entity);
		-- Call the derived behavior attack logic
		AI.Signal(SIGNALFILTER_SENDER,1,"COVER_NORMALATTACK",entity.id);

		if (AI_Utils:CanThrowGrenade(entity) == 1) then
			entity:InsertSubpipe(AIGOALPIPE_NOTDUPLICATE,"sn_throw_grenade");
		end
	end,

	---------------------------------------------
	Destructor = function (self, entity)
	
	end,

	---------------------------------------------
	COVER_NORMALATTACK = function (self, entity)

		local state = GS_SEEK; 
		
		if (entity.AI.seekCount > 1) then
			local target = AI.GetTargetType(entity.id);
			if (target == AITARGET_NONE) then
				AI.Signal(SIGNALFILTER_SENDER,1,"TO_SEARCH",entity.id);
				return;
			elseif (AI.GetAttentionTargetDistance(entity.id) < 4.0) then
				AI.Signal(SIGNALFILTER_SENDER,1,"TO_SEARCH",entity.id);
				return;
			end
		end
		
		entity.AI.seekCount = entity.AI.seekCount + 1;

		if (state == GS_ADVANCE) then
			AI.Signal(SIGNALFILTER_SENDER,1,"TO_ATTACK",entity.id);
		elseif (state == GS_SEARCH or state == GS_ALERTED or state == GS_IDLE) then
			AI.Signal(SIGNALFILTER_SENDER,1,"TO_SEARCH",entity.id);
		else
					
			local rand = random(1,10);
			if( rand <= 10 and rand >= 6) then
				entity:SelectPipe(0,"cm_seek_retreat");
			elseif(rand <= 5 and rand >= 3)then
				entity:SelectPipe(0,"cv_seek_defend");
			else
				entity:SelectPipe(AIGOALPIPE_NOTDUPLICATE,"cv_cohesion");
			end

			-- Free attack, move towards the enemy.
			if(AI_Utils:IsTargetOutsideTerritory(entity) == 0) then
				entity:SelectPipe(0,"cv_seek_direct");
			else
				entity:SelectPipe(0,"cv_seek");
			end
		end
	end,

	---------------------------------------------
	SEEK_DIRECT_DONE = function (self, entity)
		AI.Signal(SIGNALFILTER_SENDER,1,"TO_SEARCH",entity.id);
	end,

	---------------------------------------------
	OnNoTargetAwareness = function (self, entity)
		AI.Signal(SIGNALFILTER_SENDER,1,"TO_SEARCH",entity.id);
	end,

	---------------------------------------------
	OnNoTargetVisible = function (self, entity)
		-- empty
		--if(AI_Utils:IsTargetOutsideStandbyRange(entity) == 1) then
		--	entity.AI.hurryInStandby = 0;
		--	AI.Signal(SIGNALFILTER_SENDER, 1, "TO_THREATENED_STANDBY",entity.id);
		--else
			AI.Signal(SIGNALFILTER_SENDER, 1, "TO_THREATENED",entity.id);
		--end
	end,

	---------------------------------------------
	ADVANCE_NOPATH = function (self, entity, sender)
		-- no path could be found to the advance target, do something meaningful.
		entity:SelectPipe(0,"sn_use_cover_safe");
		-- Do not try to advance here again.
--		AI.SetCurrentHideObjectUnreachable(entity.id);
	end,

	--------------------------------------------------
	OnCoverCompromised = function(self, entity, sender, data)
		local target = AI.GetTargetType(entity.id);
		if(target == AITARGET_NONE) then
--			-- Advance towards the enemy
			local	beaconPos = g_Vectors.temp_v1;
			AI.GetBeaconPosition(entity.id, beaconPos);
			AI.SetRefPointPosition(entity.id,beaconPos);
			
			if(AI_Utils:IsTargetOutsideTerritory(entity) == 0) then
				entity:SelectPipe(0,"sn_fast_advance_to_target");
			else
				entity:SelectPipe(0,"cv_refpoint_investigate"); 
			end
					
		elseif(target == AITARGET_ENEMY or target == AITARGET_MEMORY) then
			AI.Signal(SIGNALFILTER_SENDER, 1, "TO_ATTACK",entity.id);
		else
			entity:SelectPipe(0,"do_nothing");
			entity:SelectPipe(0,"sn_use_cover_safe");			
		end
	end,

	---------------------------------------------
	OnNoTarget = function( self, entity )
		AI.Signal(SIGNALFILTER_SENDER,1,"TO_SEARCH",entity.id);
	end,

	---------------------------------------------
	OnEnemySeen = function( self, entity, fDistance, data )
		entity:MakeAlerted();
		entity:TriggerEvent(AIEVENT_DROPBEACON);

		if (entity.AI.firstContact) then
			AI.Signal(SIGNALFILTER_SENDER, 1, "ENEMYSEEN_FIRST_CONTACT",entity.id);
		else
			AI.Signal(SIGNALFILTER_SENDER, 1, "ENEMYSEEN_DURING_COMBAT",entity.id);
		end

	end,

	---------------------------------------------
	OnReload = function( self, entity )
--		entity:Readibility("reloading",1);
	end,
	
	---------------------------------------------
	OnInterestingSoundHeard = function( self, entity )
		entity:InsertSubpipe(AIGOALPIPE_NOTDUPLICATE,"cv_look_at_target");
	end,

	---------------------------------------------
	OnThreateningSoundHeard = function( self, entity )
		--AI.LogEvent(">>SEEK "..entity:GetName().." OnThreateningSoundHeard");

		local dt = entity.AI.lastLookatTime - _time;
		if(dt > 6.0) then
			entity:InsertSubpipe(AIGOALPIPE_NOTDUPLICATE,"cv_look_at_lastop", "probabletarget");
			entity.AI.lastLookatTime = _time;
		end

		entity:InsertSubpipe(AIGOALPIPE_NOTDUPLICATE,"cv_look_at_target_threat");
	end,

	---------------------------------------------
	OnThreateningSeen = function( self, entity )
		local dt = entity.AI.lastLookatTime - _time;
		if(dt > 6.0) then
			entity:InsertSubpipe(AIGOALPIPE_NOTDUPLICATE,"cv_look_at_lastop", "probabletarget");
			entity.AI.lastLookatTime = _time;
		end
	end,

	---------------------------------------------	
	OnSomethingSeen	= function( self, entity )
		entity:InsertSubpipe(AIGOALPIPE_NOTDUPLICATE,"cv_look_at_target_threat");
	end,

	---------------------------------------------
	OnBadHideSpot = function ( self, entity, sender,data)
--		entity:SelectPipe(0,"sn_wait_and_shoot");
	end,
	--------------------------------------------------
	OnNoHidingPlace = function( self, entity, sender,data )
--		entity:SelectPipe(0,"sn_wait_and_shoot");
	end,	
	--------------------------------------------------
	OnNoPathFound = function( self, entity, sender,data )
--		entity:SelectPipe(0,"sn_wait_and_shoot");
	end,	

	--------------------------------------------------
	TARGET_DISTANCE_REACHED = function ( self, entity, sender,data)
		self:LOOK_FOR_TARGET(entity, sender,data);
	end,

	--------------------------------------------------
	LOOK_FOR_TARGET	= function ( self, entity, sender,data)
		
		local state = GS_SEEK;
		
		local rand = random(1,10);
		if( rand <= 10 and rand >= 6) then
			state = GS_SEARCH;
		elseif(rand <= 5 and rand >= 3)then
			state = GS_IDLE;
		end
		
		
		if(state == GS_SEARCH or state == GS_IDLE) then
			AI.Signal(SIGNALFILTER_SENDER,1,"TO_SEARCH",entity.id);
		else
			local	beaconPos = g_Vectors.temp_v1;
			AI.GetBeaconPosition(entity.id, beaconPos);
	
			local probTargetPos = AI.GetProbableTargetPosition(entity.id);
			local distToTerrEdge = 100000.0;
	
			if(entity.AI.TerritoryShape) then
				probTargetPos = AI.ConstrainPointInsideGenericShape(probTargetPos, entity.AI.TerritoryShape, 1);
				distToTerrEdge = AI.DistanceToGenericShape(entity:GetPos(), entity.AI.TerritoryShape, 1);
			end
	
			local probTargetDist = DistanceVectors(entity:GetPos(), probTargetPos);
	
			-- check if the AI is at the edge of the territory and cannot move.
			if(distToTerrEdge < 3.0 and probTargetDist < 7.0) then
				entity:SelectPipe(0,"sn_wait_and_shoot"); 
			else
				entity:SelectPipe(0,"cv_refpoint_investigate"); 
			end
		end
	end,

	--------------------------------------------------
	ENEMYSEEN_FIRST_CONTACT = function (self, entity, sender)
		local target = AI.GetTargetType(entity.id);
		if (target == AITARGET_ENEMY) then
			AI.Signal(SIGNALFILTER_SENDER, 1, "TO_ATTACK",entity.id);
		else
			entity:SelectPipe(0,"cv_refpoint_investigate"); 
		end
	end,

	--------------------------------------------------
	ENEMYSEEN_DURING_COMBAT = function (self, entity, sender)
		local target = AI.GetTargetType(entity.id);
		if (target == AITARGET_ENEMY) then
			AI.Signal(SIGNALFILTER_SENDER, 1, "TO_ATTACK",entity.id);
		else
			AI.Signal(SIGNALFILTER_SENDER, 1, "TO_SEARCH",entity.id); 
		end
	end,

	---------------------------------------------
	SEEK_KILLER = function(self, entity)
	end,
	--------------------------------------------------
	OnGroupChanged = function (self, entity)
	end,
})
