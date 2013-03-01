Script.ReloadScript( "SCRIPTS/Entities/actor/BasicActor.lua");
Script.ReloadScript( "SCRIPTS/Entities/AI/Shared/BasicAI.lua");

Grunt_x = 
{	
  colliderEnergyScale = 10,
  colliderRagdollScale = 150,
  
	Properties = 
	{	
		esNavigationType = "MediumSizedCharacters",
		voiceType = "enemy",
		objFrozenModel = "",
		Damage =
		{
		  bNoGrab = 0,
			bNoDeath = 0,
			FallPercentage = 20,
			FallSleepTime = 2,
			health = 250,
		},
		distanceToHideFrom = 3,
		preferredCombatDistance = 20,		-- preferred combat distance from the target
		esFaction = "Grunts",
		equip_EquipmentPack = "AI",
		fileHitDeathReactionsParamsDataFile = "Libs/HitDeathReactionsData/HitDeathReactions_Grunt.xml",
		
		CharacterSounds =
		{	
			footstepEffect = "footstep_grunt",			-- Footstep mfx library to use
			remoteFootstepEffect = "footstep_grunt",		-- Footstep mfx library to use for remote players
			bFootstepGearEffect = 1,				-- This plays a sound from materialfx
			footstepIndGearAudioSignal_Walk = "",   -- This directly plays the specified audiosignal on every footstep
			footstepIndGearAudioSignal_Run = "",	-- This directly plays the specified audiosignal on every footstep
			foleyEffect = "foley_grunt",						-- Foley signal effect name
		},
	},
	
	gameParams =
	{			
		inertia = 0.0, --the more, the faster the speed change: 1 is very slow, 10 is very fast already 
		inertiaAccel = 0.0,
			
		backwardMultiplier = 0.5,--speed is multiplied by this amount when going backward
	},
	
	-- the AI movement ability 
	AIMovementAbility =
	{
		pathFindPrediction = 0.5,		-- predict the start of the path finding in the future to prevent turning back when tracing the path.
		allowEntityClampingByAnimation = 1,
		usePredictiveFollowing = 1,
		walkSpeed = 2.0, -- set up for humans
		runSpeed = 4.0,
		sprintSpeed = 6.4,
		b3DMove = 0,
		pathType = "AIPATH_DEFAULT",
		pathLookAhead = 1, 
		pathRadius = 0.4,
		pathSpeedLookAheadPerSpeed = -1.5,
		cornerSlowDown = 0.75,
		maxAccel = 3.0,
		maxDecel = 8.0,
		maneuverSpeed = 1.5,
		velDecay = 0.5,
		minTurnRadius = 0,	-- meters
		maxTurnRadius = 3,	-- meters
		maneuverTrh = 2.0,  -- when cross(dir, desiredDir) > this use manouvering
		resolveStickingInTrace = 1,
		pathRegenIntervalDuringTrace = 4,
		lightAffectsSpeed = 1,

		-- These are actually aiparams (as they may be changed during game and need to get serialized),
		-- but defined here so that designers do not try to change them.
		lookIdleTurnSpeed = 30,
		lookCombatTurnSpeed = 50,
		aimTurnSpeed = -1, --120,
		fireTurnSpeed = -1, --120,
		
		-- Adjust the movement speed based on the angel between body dir and move dir.
		directionalScaleRefSpeedMin = 1.0,
		directionalScaleRefSpeedMax = 8.0,

		AIMovementSpeeds = 
		{
			--         { default, min, max }
			Relaxed =
			{
				Slow   = { 1.0,     1.0, 1.9 },
				Walk   = { 1.3,     1.0, 1.9 },
				Run    = { 4.5,     2.0, 7.2 },
			},
			Combat =
			{
				Slow   = { 0.8,     0.8, 1.3 },
				Walk   = { 1.3,     0.8, 1.3 },
				Run    = { 4.5,     2.3, 6.0 },
				Sprint = { 6.5,     2.3, 6.5 },
			},
			Crouch =
			{
				Slow   = { 0.5,     0.3, 1.3 },
				Walk   = { 0.9,     0.3, 1.3 },
				Run    = { 3.5,     2.7, 5.5 },
			},
			Stealth =
			{
				Slow   = { 0.8,     0.7, 1.0 },
				Walk   = { 0.9,     0.7, 1.0 },
				Run    = { 3.5,     2.7, 5.5 },
			},
			Cover =
			{
				Slow   = { 1.0,     1.0, 1.0 },
				Walk   = { 1.9,     1.9, 1.9 },
				Run    = { 7.0,     7.0, 7.0 },
				Sprint = { 7.0,     7.0, 7.0 },
			},
			Prone =
			{
				Slow   = { 0.4,     0.4, 0.5 },
				Walk   = { 0.5,     0.4, 0.5 },
				Run    = { 0.5,     0.4, 0.5 },
			},
			Swim =
			{
				Slow   = { 0.5,     0.6, 0.7 },
				Walk   = { 0.6,     0.6, 0.7 },
				Run    = { 3.0,     2.9, 4.3 },
			},
		},
	},
	
	AI_changeCoverLastTime = 0,	
	AI_changeCoverInterval = 7,
	

	--melee stuff
	melee =
	{
		damageRadius = 1.1,								-- size of the damage box.
	},
}


function Grunt_x:OnResetCustom()
	AI.ModifySmartObjectStates(self.id, "-Busy");
	self:ReleaseTargetPOI();
end


-------------------------------------------------------------------------------------------------------
--function Grunt_x:OnInit(  )
--
----	dump(BasicAI);
--	mergef( self, BasicAI, 1 );
----	dump(self);
--	BasicAI.Server_OnInit( self );
--	BasicAI.Client_OnInit( self );
--
--	self.cnt:CounterSetValue("Boredom", 0 );
--	
----	self:MakeAlerted();
--	
----	BasicPlayer.Server_OnInit( self );	
----	BasicAI.OnInit( self );
--
--end

--Grunt=CreateAI(Grunt_x)
-----------------------------------------------------------------------------------------------------
--function Grunt_x:Event_Talk(sender)
--	BroadcastEvent(self, "Talk");
--	AI.Signal(SIGNALFILTER_SENDER,1,"OnBored", self.id);
--	System.Log("SENDING TALK");
--end
-----------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------

--Grunt_x.FlowEvents =
--{
--	Inputs =
--	{
--		Alert = { Grunt_x.Event_Alert, "bool" },
--		Talk = { Grunt_x.Event_Talk, "bool" },
--	},
--	Outputs =
--	{
--		Alert = "bool",
--		Talk = "bool",
--	},
--}

-----------------------------------------------------------------------------------------------------
-- Points of interest
-----------------------------------------------------------------------------------------------------

function Grunt_x:SetTargetPOI(poi)
	self.AI.poiId = poi.id;
	AI.SetRefPointPosition(self.id, poi:GetWorldPos());
end


function Grunt_x:ReleaseTargetPOI()
	if (self.AI.poiId) then
		AI.ModifySmartObjectStates(self.AI.poiId, "-Busy");
		self.AI.poiId = nil;
	end
end


