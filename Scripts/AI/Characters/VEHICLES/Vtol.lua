-- AICharacter: Vtol

--------------------------------------------------------------------------
--	Crytek Source File.
-- 	Copyright (C), Crytek Studios, 2001-2006.
--------------------------------------------------------------------------
--	$Id$
--	$DateTime$
--	Description: Character SCRIPT for Vtol
--  
--------------------------------------------------------------------------
--  History:
--  - 13/06/2005   : the first version by Tetsuji Iwasaki
--
--------------------------------------------------------------------------

AICharacter.Vtol = {

	VtolIdle = {
		-----------------------------------
		TO_HELI_EMERGENCYLANDING = "",

		TO_HELI_SMOOTHGOTO		= "VtolSmoothGoto",
		TO_HELI_REINFORCEMENT = "VtolReinforcement",
		TO_HELI_LANDING       = "VtolLanding",
		TO_HELI_LANDING2      = "VtolLanding",
		TO_HELI_IDLE          = "",

		TO_VTOL_FLY           = "VtolFly",

		ACT_GOTO              = "VtolGoto",
		VEHICLE_GOTO_DONE     = "",
		STOP_VEHICLE          = "",	

		MAKE_ME_IGNORANT			= "VtolIgnorant",
		MAKE_ME_UNIGNORANT		= "VtolUnIgnorant",

	},
	

	VtolGoto = {
		-----------------------------------
		TO_HELI_EMERGENCYLANDING = "",

		TO_HELI_SMOOTHGOTO		= "",
		TO_HELI_REINFORCEMENT = "VtolReinforcement",
		TO_HELI_LANDING       = "VtolLanding",
		TO_HELI_LANDING2      = "VtolLanding",
		TO_HELI_IDLE          = "",

		TO_VTOL_FLY           = "VtolFly",

		ACT_GOTO              = "",
		VEHICLE_GOTO_DONE     = "VtolIdle",
		STOP_VEHICLE          = "VtolIdle",

		OnEnemySeen          = "",	

		MAKE_ME_IGNORANT			= "VtolIgnorant",
		MAKE_ME_UNIGNORANT		= "VtolUnIgnorant",

	},

	VtolReinforcement = {
		-----------------------------------
		TO_HELI_EMERGENCYLANDING = "",
	
		TO_HELI_SMOOTHGOTO		= "",
		TO_HELI_REINFORCEMENT = "",
		TO_HELI_LANDING       = "VtolLanding",
		TO_HELI_LANDING2      = "VtolLanding",
		TO_HELI_IDLE          = "VtolIdle",

		TO_VTOL_FLY           = "",

		ACT_GOTO              = "",
		VEHICLE_GOTO_DONE     = "",
		STOP_VEHICLE          = "VtolIdle",

		OnEnemySeen          = "",	

		MAKE_ME_IGNORANT			= "VtolIgnorant",
		MAKE_ME_UNIGNORANT		= "VtolUnIgnorant",

	},

	VtolLanding = {
		-----------------------------------
		TO_HELI_EMERGENCYLANDING = "",
	
		TO_HELI_SMOOTHGOTO		= "",
		TO_HELI_REINFORCEMENT = "VtolReinforcement",
		TO_HELI_LANDING       = "",
		TO_HELI_LANDING2      = "",
		TO_HELI_IDLE          = "VtolIdle",

		TO_VTOL_FLY           = "",

		ACT_GOTO              = "",
		VEHICLE_GOTO_DONE     = "",
		STOP_VEHICLE          = "VtolIdle",

		OnEnemySeen          = "",	

		MAKE_ME_IGNORANT			= "VtolIgnorant",
		MAKE_ME_UNIGNORANT		= "VtolUnIgnorant",

	},


	VtolSmoothGoto = {
		-----------------------------------
		TO_HELI_EMERGENCYLANDING = "VtolEmergencyLanding",

		TO_HELI_SMOOTHGOTO		= "",
		TO_HELI_REINFORCEMENT = "",
		TO_HELI_LANDING       = "VtolLanding",
		TO_HELI_LANDING2      = "VtolLanding",
		TO_HELI_IDLE          = "VtolIdle",

		TO_VTOL_FLY           = "",

		ACT_GOTO              = "",
		VEHICLE_GOTO_DONE     = "",
		STOP_VEHICLE          = "VtolIdle",

		OnEnemySeen          = "",	

		MAKE_ME_IGNORANT			= "VtolIgnorant",
		MAKE_ME_UNIGNORANT		= "VtolUnIgnorant",

	},


	VtolIgnorant = {

		-----------------------------------
		TO_HELI_EMERGENCYLANDING = "",

		TO_HELI_SMOOTHGOTO		= "",
		TO_HELI_REINFORCEMENT = "",
		TO_HELI_LANDING       = "",
		TO_HELI_LANDING2      = "",
		TO_HELI_IDLE          = "VtolIdle",

		TO_VTOL_FLY           = "",

		ACT_GOTO              = "",
		VEHICLE_GOTO_DONE     = "",
		STOP_VEHICLE          = "",

		OnEnemySeen          = "",	

		MAKE_ME_IGNORANT			= "",
		MAKE_ME_UNIGNORANT		= "",

	},

	VtolUnIgnorant = {

		-----------------------------------
		TO_HELI_EMERGENCYLANDING = "",

		TO_HELI_SMOOTHGOTO		= "",
		TO_HELI_REINFORCEMENT = "",
		TO_HELI_LANDING       = "",
		TO_HELI_LANDING2      = "",
		TO_HELI_IDLE          = "VtolIdle",

		TO_VTOL_FLY           = "",

		ACT_GOTO              = "",
		VEHICLE_GOTO_DONE     = "",
		STOP_VEHICLE          = "",

		OnEnemySeen          = "",	

		MAKE_ME_IGNORANT			= "",
		MAKE_ME_UNIGNORANT		= "",

	},

	VtolFly = {

		-----------------------------------
		TO_HELI_EMERGENCYLANDING = "",

		TO_HELI_SMOOTHGOTO		= "",
		TO_HELI_REINFORCEMENT = "",
		TO_HELI_LANDING       = "",
		TO_HELI_LANDING2      = "",
		TO_HELI_IDLE          = "VtolIdle",

		TO_VTOL_FLY           = "",

		ACT_GOTO              = "",
		VEHICLE_GOTO_DONE     = "",
		STOP_VEHICLE          = "",

		OnEnemySeen          = "",	

		MAKE_ME_IGNORANT			= "",
		MAKE_ME_UNIGNORANT		= "",

	},


}