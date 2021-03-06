-----------------------------------------------------------
-- Cover3 Interested Behavior
-----------------------------------------------------------
-- Created: Matthew Jack 12-10-2009
-- Description: Based on the Cover2 behavior,
--              reapplied to use behavior trees
-----------------------------------------------------------

local Behavior = CreateAIBehavior("Cover3Interested",
{
	Alertness = 0,
	
	Constructor = function (self, entity)

		-- store original position.
		if(not entity.AI.idlePos) then
			entity.AI.idlePos = {x=0, y=0, z=0};
			CopyVector(entity.AI.idlePos, entity:GetPos());
		end

  	AI.SetPFBlockerRadius(entity.id, eNB_DEAD_BODIES, 7);
  	AI.SetPFBlockerRadius(entity.id, eNB_EXPLOSIVES, 7);

		entity.AI.firstContact = true;
		
		-- Search at least 10s.
		entity.AI.allowLeave = false;
		entity.AI.searchTimer = Script.SetTimerForFunction(10*1000.0,"AIBehavior.Cover2Interested.SEARCH_TIMER",entity);

	end,
	
	---------------------------------------------
	Destructor = function (self, entity)
		if (entity.AI.searchTimer) then
			Script.KillTimer(entity.AI.searchTimer);
		end
	end,

	---------------------------------------------
	SEARCH_TIMER = function(entity,timerid)
		entity.AI.searchTimer = nil;
		entity.AI.allowLeave = true;
		if (AI.GetTargetType(entity.id) == AITARGET_NONE) then
			AI.SetRefPointPosition(entity.id,entity.AI.idlePos);
			entity:SelectPipe(0,"cv_get_back_to_idlepos");
		end
	end,
	
	---------------------------------------------
	INVESTIGATE_DONE = function( self, entity )
		local target = AI.GetTargetType(entity.id);
		if(target == AITARGET_ENEMY) then
			AI.Signal(SIGNALFILTER_SENDER, 1, "TO_ATTACK",entity.id);
		else
			AI.SetRefPointPosition(entity.id,entity.AI.idlePos);
			entity:SelectPipe(0,"cv_get_back_to_idlepos");
		end
		entity:HolsterItem(true);
	end,

	---------------------------------------------
	INVESTIGATE_READABILITY = function( self, entity )
		entity:Readibility("alert_idle_relax",1);
	end,
	
	---------------------------------------------
	OnNoTarget = function( self, entity )
		if (entity.AI.allowLeave == true) then
			self:INVESTIGATE_DONE(entity);
		end
	end,

	---------------------------------------------
	OnEnemySeen = function( self, entity, fDistance, data )
		entity:MakeAlerted();
		entity:TriggerEvent(AIEVENT_DROPBEACON);
	end,

	---------------------------------------------
	OnEnemyMemory = function( self, entity )
	end,

	---------------------------------------------
	OnInterestingSoundHeard = function( self, entity )
		entity:Readibility("idle_interest_hear",1,1,0.6,1);
		AI_Utils:CheckInterested(entity);
	end,

	---------------------------------------------
	OnSomethingSeen = function( self, entity )
		entity:Readibility("idle_interest_see",1,1,0.6,1);
		AI_Utils:CheckInterested(entity);
	end,

	---------------------------------------------
	OnReload = function( self, entity )
	end,

	---------------------------------------------
	OnNoHidingPlace = function( self, entity, sender )
	end,	

	--------------------------------------------------
	OnNoFormationPoint = function ( self, entity, sender)
	end,

	--------------------------------------------------
	OnCoverRequested = function ( self, entity, sender)
	end,

	---------------------------------------------
	OnDamage = function ( self, entity, sender)
	end,
	
	--------------------------------------------------
	ENEMYSEEN_FIRST_CONTACT = function (self, entity, sender)
		if(AI.GetTargetType(entity.id) ~= AITARGET_ENEMY) then
			AI.Signal(SIGNALFILTER_SENDER,1,"TO_SEEK",entity.id);
		end
	end,
})