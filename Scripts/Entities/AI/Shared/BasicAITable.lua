--------------------------------------------------------------------------
--	Crytek Source File.
-- 	Copyright (C), Crytek Studios, 2001-2005.
--------------------------------------------------------------------------
--
--	Description: this is table of shared AI properties for all the actors
--	Actor will have to override property value if it has to be different 
--	from defaults. Please don't just duplicate this table for every new 
--	actor.
--  
--------------------------------------------------------------------------
--  History:
--  - 13/06/2005   15:36 : Created by Kirill Bulatsev
--
--------------------------------------------------------------------------


BasicAITable = {

------------------------------------------------------------------------------------

	PropertiesInstance = {
		soclasses_SmartObjectClass = "",
		groupid = 173,
		bAutoDisable = 1,		
		nVariation = 0,
		
			AI =
			{
				bHostileIfAttacked = 0,
			},		
		},

	Properties = {

		rank = 4,

		reaction = 1,	-- time to start shooting with nominal accuracy
		commrange = 30.0,
		
		bFactionHostility = 1,
		fGroupHostility = 0,
		
		AnimPack = "",
		SoundPack = "",		
		SoundPackAlternative = "",
		nVoiceID = 0,
		aicharacter_character = "",
		esBehaviorSelectionTree = "Cover2ST",
		esNavigationType = "",
		
		esCommConfig = "",
		esVoice = "",
		fileModel = "Objects/Characters/sdk_player/sdk_player.cdf",
		nModelVariations=0,
		bTrackable=1,
		bSquadMate=0,
		bSquadMateIncendiary=0,
		bGrenades=0,
		IdleSequence = "None",
		bIdleStartOnSpawn = 0,
		
		bCannotSwim = 0,
		bInvulnerable = 0,
		bNanoSuit = 0,

		eiColliderMode = 0, -- zero as default, meaning 'script does not care and does not override graph, etc'.

		awarenessOfPlayer = 0,
		RateOfDeath = 
		{
		  accuracy = 1.0,
		  attackrange = 70,
		  reactionTime = 1.0,
		},

		Perception =
		{
			--how visible am I
			camoScale = 1,
			--movement related parameters
			--VELmultyplier = (velBase + velScale*CurrentVel^2);
			--current priority gets scaled by VELmultyplier
			velBase = 1,
			velScale = .03,
			--fov/angle related
			FOVPrimary = 80,			-- normal fov
			FOVSecondary = 160,		-- periferial vision fov
			--ranges			
			sightrange = 70,
			sightrangeVehicle = -1,	-- how far do i see vehicles
			--how heights of the target affects visibility
			--// compare against viewer height
			-- fNewIncrease *= targetHeight/stanceScale
			stanceScale = 1.9,
			-- Sensitivity to sound 0=deaf, 1=normal
			audioScale = 1,
			-- Equivalent to camo scale, used with thermal vision.
			heatScale = 1,
			-- Flag indicating that the agent has thermal vision.
			bThermalVision = 0,
			-- controls how often targets can be switched, 
			-- this parameter corresponds to minimum amount of time the agent will hold aquired target before selectng another one
			-- default = 0 
			persistence = 0,
			-- controls how long the attention target have had to be invisible to make the player stunts effective again
			stuntReactionTimeOut = 3.0,
			-- controls how sensitive the agent is to react to collision events (scales the collision event distance).
			collisionReactionScale = 1.0,	
			-- flag indicating if the agent perception is affected by light conditions.
			bIsAffectedByLight = 0,	
			-- Value between 0..1 indicating the minimum alarm level.
			minAlarmLevel = 0,	
				
			-- Perception config (used by target tracks)
			-- TODO: Expand config to encompass the values above
			config = "Human",
			
			-- Target track variables
			TargetTracks =
			{
				classThreat = 1,	-- Archetype threat value for target track mod 'ArchetypeThreat'
				targetLimit = 0,	-- How many agents can target me at a time (0 for infinite)
			},
		},
		Interest =
		{
		  bInterested = 1,
		  MinInterestLevel = 0.0,
		  Angle = 270.0,
		},
		Readability = 
	 	{
	 		bIgnoreAnimations = 0,
	 		bIgnoreVoice = 0,			
		},
	},

	-- the AI movement ability 
	AIMovementAbility =
	{
		b3DMove = 0,
		pathLookAhead = 2,
		pathRadius = 0.3,
		walkSpeed = 2.0, -- set up for humans
		runSpeed = 4.0,
		sprintSpeed = 6.4,
		maxAccel = 1000000.0,
		maxDecel = 1000000.0,
		maneuverSpeed = 1.5,
		minTurnRadius = 0,	-- meters
		maxTurnRadius = 3,	-- meters
		maneuverTrh = 2.0,  -- when cross(dir, desiredDir) > this use manouvering
		resolveStickingInTrace = 1,
		pathRegenIntervalDuringTrace = 4,
		avoidanceRadius = 1.5,
		pathType = "AIPATH_HUMAN",
	},

	AIFireProperties = {
	},
	AI = {},
	
	-- now fast I forget the target (S-O-M speed)
	forgetTimeTarget = 16.0,
	forgetTimeSeek = 20.0,
	forgetTimeMemory = 20.0,
}

-------------------------------------------------------------------------------------------------------
