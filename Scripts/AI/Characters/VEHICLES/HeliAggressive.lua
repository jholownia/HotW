-- AICharacter: HeliAggressive

--------------------------------------------------------------------------
--	Crytek Source File.
-- 	Copyright (C), Crytek Studios, 2001-2005.
--------------------------------------------------------------------------
--	$Id$
--	$DateTime$
--	Description: Character SCRIPT for Helicopter
--  
--------------------------------------------------------------------------
--  History:
--  - 31/10/2006   : Created by Tetsuji
--
--------------------------------------------------------------------------

AICharacter.HeliAggressive = {

	HeliAggressiveIdle = {
		-----------------------------------
		TO_HELI_EMERGENCYLANDING = "",

		TO_HELI_SMOOTHGOTO		= "HeliSmoothGoto",
		TO_HELI_REINFORCEMENT = "HeliReinforcement",
		TO_HELI_LANDING       = "HeliLanding",
		TO_HELI_LANDING2      = "HeliLanding",
		TO_HELI_IDLE          = "",

		TO_HELI_HOVERATTACK2  = "",
		TO_HELI_HOVERATTACK3  = "",
		TO_HELI_PATROL        = "HeliPatrol",
		TO_HELI_ATTACK        = "HeliAttack",
		TO_HELI_PRIVIOUS			= "",
		TO_HELI_FLY						= "HeliFly",

		ACT_GOTO              = "HeliGoto",
		VEHICLE_GOTO_DONE     = "",
		STOP_VEHICLE          = "",	

		MAKE_ME_IGNORANT			= "HeliIgnorant",
		MAKE_ME_UNIGNORANT		= "HeliUnIgnorant",

	},

	HeliIdle = {
		-----------------------------------
		TO_HELI_EMERGENCYLANDING = "",

		TO_HELI_SMOOTHGOTO		= "HeliSmoothGoto",
		TO_HELI_REINFORCEMENT = "HeliReinforcement",
		TO_HELI_LANDING       = "HeliLanding",
		TO_HELI_LANDING2      = "HeliLanding",
		TO_HELI_IDLE          = "",

		TO_HELI_HOVERATTACK2  = "",
		TO_HELI_HOVERATTACK3  = "",
		TO_HELI_PATROL        = "HeliPatrol",
		TO_HELI_ATTACK        = "",
		TO_HELI_PRIVIOUS			= "",
		TO_HELI_FLY						= "HeliFly",

		ACT_GOTO              = "HeliGoto",
		VEHICLE_GOTO_DONE     = "",
		STOP_VEHICLE          = "",	

		OnEnemySeen          = "HeliAttack",		

		MAKE_ME_IGNORANT			= "HeliIgnorant",
		MAKE_ME_UNIGNORANT		= "HeliUnIgnorant",

	},
	
	HeliAttack = {
		-----------------------------------
		TO_HELI_EMERGENCYLANDING = "HeliEmergencyLanding",

		TO_HELI_SMOOTHGOTO		= "",
		TO_HELI_REINFORCEMENT = "",
		TO_HELI_LANDING       = "",
		TO_HELI_LANDING2      = "",
		TO_HELI_IDLE          = "HeliAggressiveIdle",

		TO_HELI_HOVERATTACK2  = "HeliHoverAttack2",
		TO_HELI_HOVERATTACK3  = "HeliHoverAttack3",
		TO_HELI_PATROL        = "HeliPatrol",
		TO_HELI_ATTACK        = "",
		TO_HELI_PRIVIOUS			= "",
		TO_HELI_FLY						= "",

		ACT_GOTO              = "",
		VEHICLE_GOTO_DONE     = "",
		STOP_VEHICLE          = "HeliAggressiveIdle",

		OnEnemySeen          = "",		

		MAKE_ME_IGNORANT			= "HeliIgnorant",
		MAKE_ME_UNIGNORANT		= "HeliUnIgnorant",

	},

	HeliGoto = {
		-----------------------------------
		TO_HELI_EMERGENCYLANDING = "",

		TO_HELI_SMOOTHGOTO		= "",
		TO_HELI_REINFORCEMENT = "HeliReinforcement",
		TO_HELI_LANDING       = "HeliLanding",
		TO_HELI_LANDING2      = "HeliLanding",
		TO_HELI_IDLE          = "",

		TO_HELI_HOVERATTACK2  = "",
		TO_HELI_HOVERATTACK3  = "",
		TO_HELI_PATROL        = "HeliPatrol",
		TO_HELI_ATTACK        = "",
		TO_HELI_PRIVIOUS			= "",
		TO_HELI_FLY						= "",

		ACT_GOTO              = "",
		VEHICLE_GOTO_DONE     = "HeliAggressiveIdle",
		STOP_VEHICLE          = "HeliAggressiveIdle",

		OnEnemySeen          = "HeliAttack",	

		MAKE_ME_IGNORANT			= "HeliIgnorant",
		MAKE_ME_UNIGNORANT		= "HeliUnIgnorant",

	},

	---------------------------------------------------------------

	HeliFlyOver = {
		-----------------------------------
		TO_HELI_EMERGENCYLANDING = "HeliEmergencyLanding",

		TO_HELI_SMOOTHGOTO		= "",
		TO_HELI_REINFORCEMENT = "",
		TO_HELI_LANDING       = "",
		TO_HELI_LANDING2      = "",
		TO_HELI_IDLE          = "HeliAggressiveIdle",

		TO_HELI_HOVERATTACK2  = "",
		TO_HELI_HOVERATTACK3  = "",
		TO_HELI_PATROL        = "",
		TO_HELI_ATTACK        = "HeliAttack",
		TO_HELI_PRIVIOUS			= "",
		TO_HELI_FLY						= "",

		ACT_GOTO              = "",
		VEHICLE_GOTO_DONE     = "",
		STOP_VEHICLE          = "HeliAggressiveIdle",

		OnEnemySeen          = "",	

		MAKE_ME_IGNORANT			= "HeliIgnorant",
		MAKE_ME_UNIGNORANT		= "HeliUnIgnorant",

	},

	HeliHoverAttack2 = {
		-----------------------------------
		TO_HELI_EMERGENCYLANDING = "HeliEmergencyLanding",

		TO_HELI_SMOOTHGOTO		= "",
		TO_HELI_REINFORCEMENT = "",
		TO_HELI_LANDING       = "",
		TO_HELI_LANDING2      = "",
		TO_HELI_IDLE          = "HeliAggressiveIdle",

		TO_HELI_HOVERATTACK2  = "",
		TO_HELI_HOVERATTACK3  = "",
		TO_HELI_PATROL        = "",
		TO_HELI_ATTACK        = "HeliAttack",
		TO_HELI_PRIVIOUS			= "",
		TO_HELI_FLY						= "",

		ACT_GOTO              = "",
		VEHICLE_GOTO_DONE     = "",
		STOP_VEHICLE          = "HeliAggressiveIdle",

		OnEnemySeen          = "",	

		MAKE_ME_IGNORANT			= "HeliIgnorant",
		MAKE_ME_UNIGNORANT		= "HeliUnIgnorant",

	},

	HeliHoverAttack3 = {
		-----------------------------------
		TO_HELI_EMERGENCYLANDING = "HeliEmergencyLanding",

		TO_HELI_SMOOTHGOTO		= "",
		TO_HELI_REINFORCEMENT = "",
		TO_HELI_LANDING       = "",
		TO_HELI_LANDING2      = "",
		TO_HELI_IDLE          = "HeliAggressiveIdle",

		TO_HELI_HOVERATTACK2  = "",
		TO_HELI_HOVERATTACK3  = "",
		TO_HELI_PATROL        = "",
		TO_HELI_ATTACK        = "HeliAttack",
		TO_HELI_PRIVIOUS			= "",
		TO_HELI_FLY						= "",

		ACT_GOTO              = "",
		VEHICLE_GOTO_DONE     = "",
		STOP_VEHICLE          = "HeliAggressiveIdle",

		OnEnemySeen          = "",	

		MAKE_ME_IGNORANT			= "HeliIgnorant",
		MAKE_ME_UNIGNORANT		= "HeliUnIgnorant",

	},


	HeliPickAttack = {
		-----------------------------------
		TO_HELI_EMERGENCYLANDING = "HeliEmergencyLanding",

		TO_HELI_SMOOTHGOTO		= "",
		TO_HELI_REINFORCEMENT = "",
		TO_HELI_LANDING       = "",
		TO_HELI_LANDING2      = "",
		TO_HELI_IDLE          = "HeliAggressiveIdle",

		TO_HELI_HOVERATTACK2  = "",
		TO_HELI_HOVERATTACK3  = "",
		TO_HELI_PATROL        = "",
		TO_HELI_ATTACK        = "HeliAttack",
		TO_HELI_PRIVIOUS			= "",
		TO_HELI_FLY						= "",

		ACT_GOTO              = "",
		VEHICLE_GOTO_DONE     = "",
		STOP_VEHICLE          = "HeliAggressiveIdle",

		OnEnemySeen          = "",	

		MAKE_ME_IGNORANT			= "HeliIgnorant",
		MAKE_ME_UNIGNORANT		= "HeliUnIgnorant",

	},

	HeliPatrol = {
		TO_HELI_EMERGENCYLANDING = "HeliEmergencyLanding",

		TO_HELI_SMOOTHGOTO		= "",
		TO_HELI_REINFORCEMENT = "HeliReinforcement",
		TO_HELI_LANDING       = "",
		TO_HELI_LANDING2      = "",
		TO_HELI_IDLE          = "HeliAggressiveIdle",

		TO_HELI_HOVERATTACK2  = "",
		TO_HELI_HOVERATTACK3  = "",
		TO_HELI_PATROL        = "",
		TO_HELI_ATTACK        = "HeliAttack",
		TO_HELI_PRIVIOUS			= "",
		TO_HELI_FLY						= "",

		ACT_GOTO              = "",
		VEHICLE_GOTO_DONE     = "",
		STOP_VEHICLE          = "HeliAggressiveIdle",

		OnEnemySeen          = "",	

		MAKE_ME_IGNORANT			= "HeliIgnorant",
		MAKE_ME_UNIGNORANT		= "HeliUnIgnorant",

	},
	
	HeliReinforcement = {
		TO_HELI_EMERGENCYLANDING = "",

		TO_HELI_SMOOTHGOTO		= "",
		TO_HELI_REINFORCEMENT = "",
		TO_HELI_LANDING       = "HeliLanding",
		TO_HELI_LANDING2      = "HeliLanding",
		TO_HELI_IDLE          = "HeliAggressiveIdle",

		TO_HELI_HOVERATTACK2  = "",
		TO_HELI_HOVERATTACK3  = "",
		TO_HELI_PATROL        = "HeliPatrol",
		TO_HELI_ATTACK        = "HeliAttack",
		TO_HELI_PRIVIOUS			= "",
		TO_HELI_FLY						= "",

		ACT_GOTO              = "",
		VEHICLE_GOTO_DONE     = "",
		STOP_VEHICLE          = "HeliAggressiveIdle",

		OnEnemySeen          = "",	

		MAKE_ME_IGNORANT			= "HeliIgnorant",
		MAKE_ME_UNIGNORANT		= "HeliUnIgnorant",

	},

	HeliLanding = {
		TO_HELI_EMERGENCYLANDING = "",
	
		TO_HELI_SMOOTHGOTO		= "",
		TO_HELI_REINFORCEMENT = "HeliReinforcement",
		TO_HELI_LANDING       = "",
		TO_HELI_LANDING2      = "",
		TO_HELI_IDLE          = "HeliAggressiveIdle",

		TO_HELI_HOVERATTACK2  = "",
		TO_HELI_HOVERATTACK3  = "",
		TO_HELI_PATROL        = "HeliPatrol",
		TO_HELI_ATTACK        = "HeliAttack",
		TO_HELI_PRIVIOUS			= "",
		TO_HELI_FLY						= "",

		ACT_GOTO              = "",
		VEHICLE_GOTO_DONE     = "",
		STOP_VEHICLE          = "HeliAggressiveIdle",

		OnEnemySeen          = "",	

		MAKE_ME_IGNORANT			= "HeliIgnorant",
		MAKE_ME_UNIGNORANT		= "HeliUnIgnorant",

	},

	HeliShootAt = {
		TO_HELI_EMERGENCYLANDING = "",
	
		TO_HELI_SMOOTHGOTO		= "",
		TO_HELI_REINFORCEMENT = "",
		TO_HELI_LANDING       = "",
		TO_HELI_LANDING2      = "",
		TO_HELI_IDLE          = "HeliAggressiveIdle",

		TO_HELI_HOVERATTACK2  = "",
		TO_HELI_HOVERATTACK3  = "",
		TO_HELI_PATROL        = "",
		TO_HELI_ATTACK        = "",
		TO_HELI_PRIVIOUS			= "",
		TO_HELI_FLY						= "",

		ACT_GOTO              = "",
		VEHICLE_GOTO_DONE     = "HeliAggressiveIdle",

		STOP_VEHICLE          = "HeliAggressiveIdle",

		OnEnemySeen          = "",	

		MAKE_ME_IGNORANT			= "HeliIgnorant",
		MAKE_ME_UNIGNORANT		= "HeliUnIgnorant",

	},

	HeliEmergencyLanding = {
		-----------------------------------
		TO_HELI_EMERGENCYLANDING = "",

		TO_HELI_SMOOTHGOTO		= "",
		TO_HELI_REINFORCEMENT = "",
		TO_HELI_LANDING       = "",
		TO_HELI_LANDING2      = "",
		TO_HELI_IDLE          = "",

		TO_HELI_HOVERATTACK2  = "",
		TO_HELI_HOVERATTACK3  = "",
		TO_HELI_PATROL        = "",
		TO_HELI_ATTACK        = "",
		TO_HELI_PRIVIOUS			= "",
		TO_HELI_FLY						= "",

		ACT_GOTO              = "",
		VEHICLE_GOTO_DONE     = "",
		STOP_VEHICLE          = "",

		OnEnemySeen          = "",		

		MAKE_ME_IGNORANT			= "HeliIgnorant",
		MAKE_ME_UNIGNORANT		= "HeliUnIgnorant",

	},


	HeliIgnorant = {

		-----------------------------------
		TO_HELI_EMERGENCYLANDING = "",

		TO_HELI_SMOOTHGOTO		= "",
		TO_HELI_REINFORCEMENT = "",
		TO_HELI_LANDING       = "",
		TO_HELI_LANDING2      = "",
		TO_HELI_IDLE          = "HeliAggressiveIdle",

		TO_HELI_HOVERATTACK2  = "",
		TO_HELI_HOVERATTACK3  = "",
		TO_HELI_PATROL        = "",
		TO_HELI_ATTACK        = "",
		TO_HELI_PRIVIOUS			= "",
		TO_HELI_FLY						= "",

		ACT_GOTO              = "",
		VEHICLE_GOTO_DONE     = "",
		STOP_VEHICLE          = "",

		OnEnemySeen          = "",	

		MAKE_ME_IGNORANT			= "",
		MAKE_ME_UNIGNORANT		= "",

	},

	HeliUnIgnorant = {

		-----------------------------------
		TO_HELI_EMERGENCYLANDING = "",

		TO_HELI_SMOOTHGOTO		= "",
		TO_HELI_REINFORCEMENT = "",
		TO_HELI_LANDING       = "",
		TO_HELI_LANDING2      = "",
		TO_HELI_IDLE          = "HeliAggressiveIdle",

		TO_HELI_HOVERATTACK2  = "",
		TO_HELI_HOVERATTACK3  = "",
		TO_HELI_PATROL        = "",
		TO_HELI_ATTACK        = "",
		TO_HELI_PRIVIOUS			= "",
		TO_HELI_FLY						= "",

		ACT_GOTO              = "",
		VEHICLE_GOTO_DONE     = "",
		STOP_VEHICLE          = "",

		OnEnemySeen          = "",	

		MAKE_ME_IGNORANT			= "",
		MAKE_ME_UNIGNORANT		= "",

	},
	
	HeliFly = {

		-----------------------------------
		TO_HELI_EMERGENCYLANDING = "",

		TO_HELI_SMOOTHGOTO		= "",
		TO_HELI_REINFORCEMENT = "",
		TO_HELI_LANDING       = "",
		TO_HELI_LANDING2      = "",
		TO_HELI_IDLE          = "HeliAggressiveIdle",

		TO_HELI_HOVERATTACK2  = "",
		TO_HELI_HOVERATTACK3  = "",
		TO_HELI_PATROL        = "",
		TO_HELI_ATTACK        = "HeliAttack",
		TO_HELI_PRIVIOUS			= "",
		TO_HELI_FLY						= "",

		ACT_GOTO              = "",
		VEHICLE_GOTO_DONE     = "",
		STOP_VEHICLE          = "",

		OnEnemySeen          = "",	

		MAKE_ME_IGNORANT			= "",
		MAKE_ME_UNIGNORANT		= "",

	},
	
	

}