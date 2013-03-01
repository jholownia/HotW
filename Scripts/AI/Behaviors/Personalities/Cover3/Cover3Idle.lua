-----------------------------------------------------------
-- Cover3 Idle Behavior
-----------------------------------------------------------
-- Created: Matthew Jack 12-10-2009
-- Description: Based on the Cover2 behavior,
--              reapplied to use behavior trees
-----------------------------------------------------------

local Behavior = CreateAIBehavior("Cover3Idle", "HBaseIdle",
{
		Constructor = function(self,entity)
		local profile = "Cover3";		
		if (profile) then
			local bKeepConditions = true;
			if (bForceReset and bForceReset == true) then
				bKeepConditions = false;
			end
			AI.ClearTempTarget(entity.id);
		end

		
		entity:InitAIRelaxed();
		
		-- set combat class
		if ( entity.inventory:GetItemByClass("LAW") ) then
			AI.ChangeParameter( entity.id, AIPARAM_COMBATCLASS, AICombatClasses.InfantryRPG );
		else
			AI.ChangeParameter( entity.id, AIPARAM_COMBATCLASS, AICombatClasses.Infantry );
		end

		if ( entity.AI and entity.AI.needsAlerted ) then
			AI.Signal(SIGNALFILTER_SENDER, 1, "INCOMING_FIRE",entity.id);
			entity.AI.needsAlerted = nil;
		end	
	end,	
	
  ------------------------------------------------------------------------------------------
  OnBehaviorChangeRequest = function( self, entity )
		AI.SetReadyForNodeChange(entity.id);	
  end,

  ------------------------------------------------------------------------------------------
	DelayedBehaviorChange = function( entity )
    AI.SetReadyForNodeChange(entity.id);
	end,
	
	---------------------------------------------
	OnQueryUseObject = function ( self, entity, sender, extraData )
	end,

	---------------------------------------------
	OnEnemySeen = function( self, entity, fDistance, data )
		entity:MakeAlerted();
		entity:TriggerEvent(AIEVENT_DROPBEACON);
		entity.AI.firstContact = true;
	end,

	---------------------------------------------
	OnNoTarget = function(self,entity,sender)
	end,

	---------------------------------------------
	OnTankSeen = function( self, entity, fDistance )
	end,
	
	---------------------------------------------
	OnHeliSeen = function( self, entity, fDistance )
	end,

	---------------------------------------------
	OnTargetDead = function( self, entity )
		-- called when the attention target died
		entity:Readibility("target_down",1,1,0.3,0.5);
	end,
	
	--------------------------------------------------
	OnNoHidingPlace = function( self, entity, sender,data )
	end,	

	---------------------------------------------
	OnBackOffFailed = function(self,entity,sender)
	end,

	---------------------------------------------
	SEEK_KILLER = function(self, entity)
	end,


	---------------------------------------------
	DRAW_GUN = function( self, entity )
		if(not entity.inventory:GetCurrentItemId()) then
			entity:HolsterItem(false);
		end
	end,
	
	---------------------------------------------
	OnEnemyMemory = function( self, entity )
		-- called when the enemy can no longer see its foe, but remembers where it saw it last
	end,
	
	---------------------------------------------
	OnSomethingSeen = function( self, entity )
	  -- Still work to be done here
		-- called when the enemy sees a foe which is not a living player
		entity:Readibility("idle_interest_see",1,1,0.6,1);
		AI_Utils:CheckInterested(entity);
		AI.ModifySmartObjectStates(entity.id,"UseMountedWeaponInterested");
	end,
	
	---------------------------------------------
	OnThreateningSeen = function( self, entity )
	  --[[ MTJ-Cover3
	  -- Still work to be done here
		-- called when the enemy hears a scary sound
		entity:Readibility("idle_interest_see",1,1,0.6,1);
		entity:TriggerEvent(AIEVENT_DROPBEACON);
		if(AI_Utils:IsTargetOutsideStandbyRange(entity) == 1) then
			entity.AI.hurryInStandby = 0;
			AI.Signal(SIGNALFILTER_SENDER, 1, "TO_THREATENED_STANDBY",entity.id);
		else
			AI.Signal(SIGNALFILTER_SENDER, 1, "TO_THREATENED",entity.id);
		end

		AI.ModifySmartObjectStates(entity.id,"UseMountedWeaponInterested");
		--]]
	end,
	
	---------------------------------------------
	OnInterestingSoundHeard = function( self, entity )
		-- check if we should check the sound or not.
		entity:Readibility("idle_interest_hear",1,1,0.6,1);
		AI_Utils:CheckInterested(entity);
		AI.ModifySmartObjectStates(entity.id,"UseMountedWeaponInterested");
	end,

	---------------------------------------------
	OnThreateningSoundHeard = function( self, entity, fDistance )
	  --[[ MTJ-Cover3
		-- called when the enemy hears a scary sound
		entity:Readibility("idle_alert_threat_hear",1,1,0.6,1);
		entity:TriggerEvent(AIEVENT_DROPBEACON);
		if(AI_Utils:IsTargetOutsideStandbyRange(entity) == 1) then
			entity.AI.hurryInStandby = 0;
			AI.Signal(SIGNALFILTER_SENDER, 1, "TO_THREATENED_STANDBY",entity.id);
		else
			AI.Signal(SIGNALFILTER_SENDER, 1, "TO_THREATENED",entity.id);
		end

		AI.ModifySmartObjectStates(entity.id,"UseMountedWeaponInterested");
		--]]
	end,

	--------------------------------------------------
	INVESTIGATE_BEACON = function (self, entity, sender)
		entity:Readibility("ok_battle_state",1,1,0.6,1);
			-- MTJ Cover3 More work needed here
		AI.Signal(SIGNALFILTER_SENDER, 1, "TO_THREATENED",entity.id);
	end,
		
	--------------------------------------------------
	OnCoverRequested = function ( self, entity, sender)
	end,

	---------------------------------------------
	OnDamage = function ( self, entity, sender)
		-- called when the enemy is damaged
		entity:Readibility("taking_fire",1,1,0.3,0.5);
		entity:GettingAlerted();
	end,

	---------------------------------------------
	OnEnemyDamage = function (self, entity, sender, data)
		-- called when the enemy is damaged
		entity:GettingAlerted();
		entity:Readibility("taking_fire",1,1,0.3,0.5);

		-- set the beacon to the enemy pos
		local shooter = System.GetEntity(data.id);
		if(shooter) then
			AI.SetBeaconPosition(entity.id, shooter:GetPos());
		else
			entity:TriggerEvent(AIEVENT_DROPBEACON);
		end

		AI.Signal(SIGNALFILTER_GROUPONLY_EXCEPT,1,"INCOMING_FIRE",entity.id);

		-- dummy call to this one, just to make sure that the initial position is checked correctly.
		AI_Utils:IsTargetOutsideStandbyRange(entity);

		-- MTJ Cover 3 More work needed here
		AI.Signal(SIGNALFILTER_SENDER, 1, "TO_HIDE",entity.id);
	end,

	---------------------------------------------
	OnReload = function( self, entity )
	end,


	---------------------------------------------
	OnBulletRain = function(self, entity, sender, data)
		-- only react to hostile bullets.

		if(AI.Hostile(entity.id, sender.id)) then
			entity:GettingAlerted();
			if(AI.GetTargetType(entity.id)==AITARGET_NONE) then
				local	closestCover = AI.GetNearestHidespot(entity.id, 3, 15, sender:GetPos());
				if(closestCover~=nil) then
					AI.SetBeaconPosition(entity.id, closestCover);
				else
					AI.SetBeaconPosition(entity.id, sender:GetPos());
				end
			else
				entity:TriggerEvent(AIEVENT_DROPBEACON);
			end
			entity:Readibility("bulletrain",1,1,0.1,0.4);

			-- dummy call to this one, just to make sure that the initial position is checked correctly.
			AI_Utils:IsTargetOutsideStandbyRange(entity);

			AI.Signal(SIGNALFILTER_GROUPONLY_EXCEPT,1,"INCOMING_FIRE",entity.id);
			
			-- MTJ Cover3 More work needed here
			AI.Signal(SIGNALFILTER_SENDER, 1, "TO_HIDE",entity.id);
		else
			if(sender==g_localActor) then 
				entity:Readibility("friendly_fire",1,0.6,1);
				entity:InsertSubpipe(AIGOALPIPE_NOTDUPLICATE,"look_at_player_5sec");			
				entity:InsertSubpipe(AIGOALPIPE_NOTDUPLICATE,"do_nothing");		-- make the timeout goal in previous subpipe restart if it was there already
			end
		end
	end,

	--------------------------------------------------
	OnCollision = function(self,entity,sender,data)
		if(AI.GetTargetType(entity.id) ~= AITARGET_ENEMY) then 
			if(AI.Hostile(entity.id,data.id)) then 
				entity:SelectPipe(0,"short_look_at_lastop",data.id);
			end
		end
	end,	
	
	--------------------------------------------------
	OnCloseContact = function ( self, entity, sender,data)
	end,

	--------------------------------------------------
	OnGroupMemberDied = function(self, entity, sender, data)
		--AI.LogEvent(entity:GetName().." OnGroupMemberDied!");
		entity:GettingAlerted();
		-- MTJ Cover3 More work needed here
		AI.Signal(SIGNALFILTER_SENDER,1,"TO_HIDE",entity.id);
	end,

	--------------------------------------------------
	COVER_NORMALATTACK = function (self, entity, sender)
	end,

	--------------------------------------------------
	INVESTIGATE_TARGET = function (self, entity, sender)
		entity:SelectPipe(0,"cv_investigate_threat");	
	end,

	---------------------------------------------
	ENEMYSEEN_FIRST_CONTACT = function( self, entity )
	  --[[ MTJ-Cover3
		if(AI.GetTargetType(entity.id) ~= AITARGET_ENEMY) then
			entity:Readibility("idle_interest_see",1,1,0.6,1);
			if(AI_Utils:IsTargetOutsideStandbyRange(entity) == 1) then
				entity.AI.hurryInStandby = 1;
				AI.Signal(SIGNALFILTER_SENDER, 1, "TO_THREATENED_STANDBY",entity.id);
			else
				AI.Signal(SIGNALFILTER_SENDER, 1, "TO_THREATENED",entity.id);
			end
		end
		--]]
	end,

	--------------------------------------------------
	ENEMYSEEN_DURING_COMBAT = function (self, entity, sender)
	  --[[ MTJ-Cover3
	  -- When would this be sent?
		entity:GettingAlerted();
		if(AI.GetTargetType(entity.id) ~= AITARGET_ENEMY) then
			AI.Signal(SIGNALFILTER_SENDER,1,"TO_SEEK",entity.id);
		end
	--]]
	end,

	---------------------------------------------
	INCOMING_FIRE = function (self, entity, sender)
		entity:GettingAlerted();

		if(DistanceVectors(sender:GetPos(), entity:GetPos()) < 15.0) then
			-- near to the guy who is being shot, hide!
			-- MTJ Cover3 More work needed here
			AI.Signal(SIGNALFILTER_SENDER, 1, "TO_HIDE",entity.id);
		else
			-- further away, threatened!
			if(AI_Utils:IsTargetOutsideStandbyRange(entity) == 1) then
				entity.AI.hurryInStandby = 1;
				AI.Signal(SIGNALFILTER_SENDER, 1, "TO_THREATENED_STANDBY",entity.id);
			else
				AI.Signal(SIGNALFILTER_SENDER, 1, "TO_THREATENED",entity.id);
			end
		end
	end,

	---------------------------------------------
	TREE_DOWN = function (self, entity, sender)
		entity:Readibility("bulletrain",1,1,0.1,0.4);
	end,
	--------------------------------------------------
	OnLeaderReadabilitySeek = function(self, entity, sender)
		entity:Readibility("signalMove",1,10);
	end,
	--------------------------------------------------
	OnLeaderReadabilityAlarm = function(self, entity, sender)
		entity:Readibility("signalGetDown",1,10);
	end,
	--------------------------------------------------
	OnLeaderReadabilityAdvanceLeft = function(self, entity, sender)
		entity:Readibility("signalAdvance",1,10);
	end,
	--------------------------------------------------
	OnLeaderReadabilityAdvanceRight = function(self, entity, sender)
		entity:Readibility("signalAdvance",1,10);
	end,
	--------------------------------------------------
	OnLeaderReadabilityAdvanceForward = function(self, entity, sender)
		entity:Readibility("signalAdvance",1,10);
	end,
	
	---------------------------------------------
	OnFriendlyDamage = function ( self, entity, sender,data)
		if(data.id==g_localActor.id) then 
			entity:Readibility("friendly_fire",1,1, 0.6,1);
			if(entity:IsUsingPipe("stand_only")) then 
				entity:InsertSubpipe(AIGOALPIPE_NOTDUPLICATE,"look_at_player_5sec");			
				entity:InsertSubpipe(AIGOALPIPE_NOTDUPLICATE,"do_nothing");		-- make the timeout goal in previous subpipe restart if it was there already
			end
		end
	end,

	---------------------------------------------
	SELECT_SEC_WEAPON = function (self, entity)
		entity:SelectSecondaryWeapon();
	end,

	---------------------------------------------
	SELECT_PRI_WEAPON = function (self, entity)
		entity:SelectPrimaryWeapon();
	end,

	---------------------------------------------
	OnShapeEnabled = function (self, entity, sender, data)
		--Log(entity:GetName().."OnShapeEnabled");
		if(data.iValue == AIAnchorTable.COMBAT_TERRITORY) then
			AI_Utils:SetupTerritory(entity, false);
		elseif(data.iValue == AIAnchorTable.ALERT_STANDBY_IN_RANGE) then
			AI_Utils:SetupStandby(entity);
		end
	end,

	---------------------------------------------
	OnShapeDisabled = function (self, entity, sender, data)
		--Log(entity:GetName().."OnShapeDisabled");
		if(data.iValue == 1) then
			-- refshape
			AI_Utils:SetupStandby(entity);
		elseif(data.iValue == 2) then
			-- territory
			AI_Utils:SetupTerritory(entity, false);
		elseif(data.iValue == 3) then
			-- refshape and territory
			AI_Utils:SetupTerritory(entity, false);
			AI_Utils:SetupStandby(entity);
		end
		
	end,

	---------------------------------------------
	SET_TERRITORY = function (self, entity, sender, data)

		-- If the current standby area is the same as territory, clear the standby.
		if(entity.AI.StandbyEqualsTerritory) then
			entity.AI.StandbyShape = nil;
		end

		entity.AI.TerritoryShape = data.ObjectName;
		newDist = AI.DistanceToGenericShape(entity:GetPos(), entity.AI.TerritoryShape, 0);

		local curDist = 10000000.0;
		if(entity.AI.StandbyShape) then
			curDist = AI.DistanceToGenericShape(entity:GetPos(), entity.AI.StandbyShape, 0);
		end

--		Log(" - curdist:"..tostring(curDist));
--		Log(" - newdist:"..tostring(newDist));

		if(newDist < curDist) then
			if(entity.AI.TerritoryShape) then
				entity.AI.StandbyShape = entity.AI.TerritoryShape;
			end
			entity.AI.StandbyEqualsTerritory = true;
		end

		if(entity.AI.StandbyShape) then
			entity.AI.StandbyValid = true;
			AI.SetRefShapeName(entity.id, entity.AI.StandbyShape);
		else
			entity.AI.StandbyValid = false;
			AI.SetRefShapeName(entity.id, "");
		end

		if(entity.AI.TerritoryShape) then
			AI.SetTerritoryShapeName(entity.id, entity.AI.TerritoryShape);
		else
			AI.SetTerritoryShapeName(entity.id, "");
		end

	end,

	---------------------------------------------
	CLEAR_TERRITORY = function (self, entity, sender, data)
		entity.AI.StandbyEqualsTerritory = false;
		entity.AI.StandbyShape = nil;
		entity.AI.TerritoryShape = nil;

		AI.SetRefShapeName(entity.id, "");
		AI.SetTerritoryShapeName(entity.id, "");
	end,

	--------------------------------------------------
	OnCallReinforcements = function (self, entity, sender, data)
	  --[[ MTJ-Cover3
		entity.AI.reinfSpotId = data.id;
		entity.AI.reinfType = data.iValue;

--		AI.LogEvent(">>> "..entity:GetName().." OnCallReinforcements");

		AI.Signal(SIGNALFILTER_SENDER,1,"TO_CALL_REINFORCEMENTS",entity.id);
		--]]
	end,

	--------------------------------------------------
	OnGroupChanged = function (self, entity)
	 --[[ MTJ-Cover3
		-- TODO: goto the nearest group
		if (AI.GetTargetType(entity.id)~=AITARGET_ENEMY) then
			AI.BeginGoalPipe("cv_goto_beacon");
				AI.PushGoal("locate",0,"beacon");
				AI.PushGoal("approach",1,4,AILASTOPRES_USE,15,"",3);
				AI.PushGoal("signal",1,1,"GROUP_REINF_DONE",0);
			AI.EndGoalPipe();
			entity:SelectPipe(0,"cv_goto_beacon");
		end
		--]]
	end,
	--------------------------------------------------
	GROUP_REINF_DONE = function (self, entity)
		-- MTJ Obsoleted by the BT, except for the timing!
		--AI_Utils:CommonContinueAfterReaction(entity);
	end,

	--------------------------------------------------
	OnExposedToFlashBang = function (self, entity, sender, data)

		if (data.iValue == 1) then
			-- near
			entity:SelectPipe(0,"sn_flashbang_reaction_flinch");
		else
			-- visible
			entity:SelectPipe(0,"sn_flashbang_reaction");
		end
	end,

	--------------------------------------------------
	FLASHBANG_GONE = function (self, entity)
		entity:SelectPipe(0,"do_nothing");
		-- MTJ Obsoleted by the BT, except for the timing!
		-- Choose proper action after being interrupted.
		--AI_Utils:CommonContinueAfterReaction(entity);
	end,

	--------------------------------------------------
	OnExposedToSmoke = function (self, entity)
		--System.Log(">>>>"..entity:GetName().." OnExposedToSmoke");
		entity:Readibility("cough",1,115,0.1,4.5);
	end,

	---------------------------------------------
	OnExposedToExplosion = function(self, entity, data)
		self:OnCloseCollision(entity, data);
	end,

	---------------------------------------------
	OnCloseCollision = function(self, entity, data)		
		-- Brought inline from ChooseFlinchReaction as only place used,
		-- and requiring adaption for Cover3
		
		local dir = AI.GetDirLabelToPoint(entity.id, data.point);
		local pipeName = "sn_flinch_front";
		if (dir == 1) then
			pipeName = "sn_flinch_front"; -- Not back? Is there a "back"?
		elseif (dir == 2) then
			pipeName = "sn_flinch_left";
		elseif (dir == 3) then
			pipeName = "sn_flinch_right";
		else
			pipeName = "sn_flinch_above";
		end
		entity:InsertSubpipe(0,pipeName);
		
	end,

	---------------------------------------------
	OnGroupMemberMutilated = function(self, entity)
	  --[[ MTJ-Cover3
--		System.Log(">>"..entity:GetName().." OnGroupMemberMutilated");
		AI.Signal(SIGNALFILTER_SENDER,1,"TO_PANIC",entity.id);
		--]]
	end,

	---------------------------------------------
	OnTargetCloaked = function(self, entity)
		entity:SelectPipe(0,"sn_target_cloak_reaction");
	end,

	---------------------------------------------
	PANIC_DONE = function(self, entity)
		AI.Signal(SIGNALFILTER_GROUPONLY_EXCEPT, 1, "ENEMYSEEN_FIRST_CONTACT",entity.id);
		-- Choose proper action after being interrupted.
		-- MTJ Obsoleted by the BT, except for the timing!
		--AI_Utils:CommonContinueAfterReaction(entity);
	end,

	
	--------------------------------------------------	
	OnOutOfAmmo = function (self,entity, sender)
		entity:Readibility("reload",1,4,0.1,0.4);
		if (entity.Reload == nil) then
			--System.Log("  - no reload available");
			do return end
		end
		entity:Reload();
	end,
	
	---------------------------------------------
	SET_DEFEND_POS = function(self, entity, sender, data)
		--System.Log(">>>>"..entity:GetName().." SET_DEFEND_POS");
		if (data and data.point) then
			AI.SetRefPointPosition(entity.id,data.point);
		end
	end,

	---------------------------------------------
	CLEAR_DEFEND_POS = function(self, entity, sender, data)
	end,


	---------------------------------------------
	OnFallAndPlay	= function( self, entity, data )
	-- Being knocked down or shot with the sleep bullet	
		AI.SetRefPointPosition(entity.id, data.point);
		if (entity.DoPainSounds) then
			entity:DoPainSounds();
		end
		-- Clear any pending reactions
		entity:SelectPipe(0,"do_nothing");
	end,


	---------------------------------------------
	OnFallAndPlayWakeUp	= function(self, entity, data)
	end,
})