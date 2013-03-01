-----------------------------------------------------------
-- Cover3 AvoidExplosives Behavior
-----------------------------------------------------------
-- Created: Matthew Jack 12-10-2009
-- Description: Based on the Cover2 behavior,
--              reapplied to use behavior trees
-----------------------------------------------------------

local Behavior = CreateAIBehavior("Cover3AvoidExplosives",
{
	Alertness = 2,
	exclusive = 1,

	-----------------------------------------------------
	Constructor = function(self,entity)
		if (entity.AI.grenadeDist) then
			if (entity.AI.grenadeDist > 6.0) then
				entity:SelectPipe(0,"cv_backoff_from_explosion_short");
			else
				entity:SelectPipe(0,"cv_backoff_from_explosion");
			end
		else
			entity:SelectPipe(0,"cv_backoff_from_explosion");
		end

		AI.Signal(SIGNALFILTER_GROUPONLY_EXCEPT,0,"GET_ALERTED",entity.id);
	end,
	
	-----------------------------------------------------
	Destructor = function(self,entity)
		AI.ModifySmartObjectStates(entity.id,"-AvoidExplosion");
		
		-- Ensure that, however we might leave this behavior, we reset the explosives flag
		-- This might not strictly be necessary, but since most dangers are short-lived, returning to them
		-- will rarely be desirable in practice
		AI.Signal(SIGNALFILTER_SENDER,0,"ResolvedExplosivesDanger",entity.id);
	end,

	---------------------------------------------
	OnEnemyMemory = function( self, entity )
		-- called when the enemy stops having an attention target
	end,
	
	---------------------------------------------
	OnNoTarget = function( self, entity )
		-- called when the enemy stops having an attention target
	end,

	---------------------------------------------
	OnGroupMemberDied = function( self, entity )
		-- called when a member of the group dies
	end,

	---------------------------------------------
	OnGroupMemberDiedNearest = function ( self, entity, sender, data )
		entity:Readibility("ai_down",1,1,0.1,0.4);
		AI.Signal(SIGNALFILTER_GROUPONLY, 1, "OnGroupMemberDied",entity.id, data );
	end,

	---------------------------------------------		
	OnEnemySeen = function( self, entity, fDistance, data )
		if (data.iValue == AITSR_SEE_STUNT_ACTION) then
			AI_Utils:ChooseStuntReaction(entity);
		elseif (data.iValue == AITSR_SEE_CLOAKED) then
			entity:SelectPipe(0,"sn_target_cloak_reaction");
		end
		entity:TriggerEvent(AIEVENT_DROPBEACON);
	end,

	---------------------------------------------		
	OnInterestingSoundHeard = function( self, entity, fDistance )
	end,

	---------------------------------------------		
	OnThreateningSoundHeard = function( self, entity, fDistance )
	end,

	---------------------------------------------
	OnThreateningSeen = function( self, entity )
		entity:TriggerEvent(AIEVENT_DROPBEACON);
	end,

	---------------------------------------------
	OnSomethingSeen = function( self, entity )
	end,

	---------------------------------------------
	OnEnemyDamage = function ( self, entity, sender,data)
	end,

	---------------------------------------------
	OnDamage = function ( self, entity, sender,data)
	end,

	--------------------------------------------------
	OnBulletRain = function ( self, entity, sender)
	end,

	---------------------------------------------
	OnReload = function( self, entity )
	end,

	--------------------------------------------------------
	OnHideSpotReached = function(self,entity,sender)
	end,

	--------------------------------------------------
	OnLowHideSpot = function( self, entity, sender)
	end,

	---------------------------------------------
	END_BACKOFF = function(self,entity)
		AI.Signal(SIGNALFILTER_SENDER,0,"ResolvedExplosivesDanger",entity.id);
	end,

	---------------------------------------------
	ENEMYSEEN_FIRST_CONTACT = function(self,entity)
	end,
	
	---------------------------------------------
	ENEMYSEEN_DURING_COMBAT = function(self,entity)
	end,

	---------------------------------------------
	OnVehicleDanger = function(self,entity)
	end,
	
	---------------------------------------------
	OnExplosionDanger = function(self,entity,sender,data)
	end,

	--------------------------------------------------
	OnGrenadeDanger = function( self, entity, sender, signalData )
	end,

	-------------------------------------------------
	GO_TO_AVOIDEXPLOSIVES = function(self,entity,sender)
	end,
	
	-------------------------------------------------
	OnBackOffFailed = function(self,entity)
		entity:SelectPipe(0,"sn_flinch_front");
	end,

	---------------------------------------------
	PANIC_DONE = function(self,entity)
		AI.Signal(SIGNALFILTER_SENDER,0,"ResolvedExplosivesDanger",entity.id);
	end,

	--------------------------------------------------
	MOUNTED_WEAPON_USABLE = function(self,entity,sender,data)
		-- sent by smart object rule
		if(data and data.id) then 
			local weapon = System.GetEntity(data.id);
			if(weapon) then
				AI.ModifySmartObjectStates(weapon.id,"Idle,-Busy");				
			end
		end
		AI.ModifySmartObjectStates(entity.id,"-Busy");				
	end,
})