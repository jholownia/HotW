--------------------------------------------------
--    Created By: Luciano
--   Description: 	Cover goes hiding under fire
--------------------------
--

local Behavior = CreateAIBehavior("Cover2HideST",
{
	Alertness = 1,

	-----------------------------------------------------
	Constructor = function(self,entity)
		entity:GettingAlerted();

--		entity.AI.changeCoverLastTime = _time;
--		entity.AI.changeCoverInterval = random(7,11);
--		entity.AI.fleeLastTime = _time;
--		entity.AI.lastLiveEnemyTime = _time;
--		entity.AI.lastBulletReactionTime = _time - 10;
--		entity.AI.lastFriendInWayTime = _time - 10;

		entity.AI.lastBulletReactionTime = _time - 10;
		
		entity:Readibility("taking_fire",1,1, 0.1,0.4);
		self:HandleThreat(entity);
	end,
	
	-----------------------------------------------------
	Destructor = function(self,entity)
	end,

	-----------------------------------------------------
	HandleThreat = function(self, entity, sender)
		local	dt = _time - entity.AI.lastBulletReactionTime;
		if(dt > 0.5) then
			if(not sender or AI.Hostile(entity.id, sender.id)) then
				entity.AI.lastBulletReactionTime = _time;
				entity:SelectPipe(0,"do_nothing");
				entity:SelectPipe(0,"cv_hide_unknown");
			end
		end
		
	end,

	-----------------------------------------------------
	COVER_NORMALATTACK = function(self, entity)
		-- Choose proper action after being interrupted.
		AI_Utils:CommonContinueAfterReaction(entity);
	end,

	---------------------------------------------
	OnEnemyMemory = function( self, entity )
		-- called when the enemy stops having an attention target
	end,
	
	---------------------------------------------
	OnNoTarget = function( self, entity )
		-- called when the enemy stops having an attention target
--		self:HandleThreat(entity);
	end,

	---------------------------------------------		
	OnEnemySeen = function( self, entity, fDistance, data )
		entity:MakeAlerted();
		entity:TriggerEvent(AIEVENT_DROPBEACON);
		AI.SetBehaviorVariable(entity.id, "Hide", false);
		local dist = AI.GetAttentionTargetDistance(entity.id);

		if (entity.AI.firstContact) then
			entity:Readibility("first_contact",1,3, 0.1,0.4);
			AI.Signal(SIGNALFILTER_SENDER, 1, "ENEMYSEEN_FIRST_CONTACT",entity.id);
		else
			entity:Readibility("during_combat",1,3, 0.1,0.4);
			AI.Signal(SIGNALFILTER_SENDER, 1, "ENEMYSEEN_DURING_COMBAT",entity.id);
		end
		AI.SetBehaviorVariable(entity.id, "Attack", true);
	end,

	---------------------------------------------		
	OnInterestingSoundHeard = function( self, entity, fDistance )
--		entity:TriggerEvent(AIEVENT_CLEAR);
	end,

	---------------------------------------------
	OnThreateningSeen = function( self, entity )
		entity:TriggerEvent(AIEVENT_DROPBEACON);
	end,

	---------------------------------------------		
	OnThreateningSoundHeard = function( self, entity, fDistance )
		entity:TriggerEvent(AIEVENT_DROPBEACON);
	end,

	---------------------------------------------		
	OnSommethingSeen = function( self, entity, fDistance )
		entity:TriggerEvent(AIEVENT_DROPBEACON);
	end,

	---------------------------------------------
	OnEnemyDamage = function ( self, entity, sender,data)

		entity.AI.coverCompromized = true;

		-- set the beacon to the enemy pos
		local shooter = System.GetEntity(data.id);
		if(shooter) then
			AI.SetBeaconPosition(entity.id, shooter:GetPos());
			AI.Signal(SIGNALFILTER_SENDER,1,"INCOMING_FIRE",entity.id);
		end

		-- called when the enemy is damaged
		self:HandleThreat(entity, shooter);
		
		entity:Readibility("taking_fire",1,1, 0.1,0.4);
	end,

	---------------------------------------------
	OnBulletRain = function(self, entity, sender, data)
		entity:Readibility("bulletrain",1,1, 0.1,0.4);
		self:HandleThreat(entity, sender);

		local shooter = System.GetEntity(sender.id);
		if(shooter) then
			AI.SetBeaconPosition(entity.id, shooter:GetPos());
			AI.Signal(SIGNALFILTER_SENDER,1,"INCOMING_FIRE",entity.id);
		end
	end,

	---------------------------------------------
	OnReload = function( self, entity )
	end,

	--------------------------------------------------------
	OnHideSpotReached = function(self,entity,sender)
	end,

	---------------------------------------------
	INCOMING_FIRE = function (self, entity, sender)
	end,
})
