--------------------------------------------------
-- SneakerSearch
--------------------------
--   created: Mikko Mononen 21-6-2006

local Behavior = CreateAIBehavior("Cover2SearchST",
{
	Alertness = 1,

	---------------------------------------------
	Constructor = function(self, entity)
		entity:Readibility("searching_for_enemy",1,1,0.3,1.0);

		-- check if the AI is at the edge of the territory and cannot move.
		if(AI_Utils:IsTargetOutsideTerritory(entity) == 1) then
			-- at the edge, wait, aim and shoot.
			entity:SelectPipe(0,"sn_wait_and_aim");
		else
			-- enough space, search.
			entity:SelectPipe(0,"cv_seek_target_random");
		end
				
		entity.AI.lastLookAtTime = _time;
	end,

	---------------------------------------------
	Destructor = function(self, entity)
		entity.anchor = nil;
	end,

	---------------------------------------------
	OnEnemySeen = function( self, entity, fDistance, data )
		-- called when the enemy sees a living player
		entity:MakeAlerted();
		entity:TriggerEvent(AIEVENT_DROPBEACON);
		
		if (entity.AI.firstContact) then
			entity:Readibility("first_contact",1,3, 0.1,0.4);
			AI.Signal(SIGNALFILTER_SENDER, 1, "ENEMYSEEN_FIRST_CONTACT",entity.id);
		else
			entity:Readibility("during_combat",1,3, 0.1,0.4);
			AI.Signal(SIGNALFILTER_SENDER, 1, "ENEMYSEEN_DURING_COMBAT",entity.id);
		end
		
	end,
	
	---------------------------------------------
	OnNoTarget = function( self, entity )
	end,

	---------------------------------------------
	COVER_NORMALATTACK = function (self, entity)
		-- check if the AI is at the edge of the territory and cannot move.
		if(AI_Utils:IsTargetOutsideTerritory(entity) == 1) then
			-- at the edge, wait, aim and shoot.
			entity:SelectPipe(0,"sn_wait_and_aim");
		else
			-- enough space, search.
			entity:SelectPipe(0,"cv_seek_target_random");
		end
	end,

	---------------------------------------------
	OnReload = function( self, entity )
--		entity:Readibility("reloading",1);
	end,

	--------------------------------------------------
	HIDE_FAILED = function (self, entity, sender)
		-- no hide points
		entity:SelectPipe(0,"cv_seek_target_nocover");
	end,

	--------------------------------------------------
	LOOK_FOR_TARGET = function (self, entity, sender)
		-- check if the AI is at the edge of the territory and cannot move.
		if(AI_Utils:IsTargetOutsideTerritory(entity) == 1) then
			-- at the edge, wait, aim and shoot.
			entity:SelectPipe(0,"sn_wait_and_aim");
		else
			-- enough space, search.
			entity:SelectPipe(0,"cv_seek_target_random");
		end
	end,	

	--------------------------------------------------
	ENEMYSEEN_FIRST_CONTACT = function (self, entity, sender)
		-- there is still some room for moving.
		AI.SetBehaviorVariable(entity.id, "Search", false);
		AI.SetBehaviorVariable(entity.id, "Seek", true);
	end,

	--------------------------------------------------
	ENEMYSEEN_DURING_COMBAT = function (self, entity, sender)
		-- there is still some room for moving.
		AI.SetBehaviorVariable(entity.id, "Search", false);
		AI.SetBehaviorVariable(entity.id, "Attack", true);
	end,

	---------------------------------------------
	OnInterestingSoundHeard = function( self, entity )
		entity:TriggerEvent(AIEVENT_DROPBEACON);
		AI_Utils:CheckThreatened(entity, 15.0);
	end,
	
	---------------------------------------------
	OnThreateningSoundHeard = function( self, entity, fDistance )
		entity:TriggerEvent(AIEVENT_DROPBEACON);
		AI_Utils:CheckThreatened(entity, 15.0);
	end,

	---------------------------------------------
	OnSomethingSeen = function( self, entity )
		entity:TriggerEvent(AIEVENT_DROPBEACON);
		AI_Utils:CheckThreatened(entity, 15.0);
	end,

	---------------------------------------------
	OnThreateningSeen = function( self, entity )
		entity:TriggerEvent(AIEVENT_DROPBEACON);
		AI_Utils:CheckThreatened(entity, 15.0);
	end,

	---------------------------------------------
	INVESTIGATE_CONTINUE = function( self, entity )
		entity:SelectPipe(0,"cv_investigate_threat_closer");
	end,
	
	---------------------------------------------
	INVESTIGATE_DONE = function( self, entity )
		self:COVER_NORMALATTACK(entity);
	end,
})
