-- AICharacter: Car

--------------------------------------------------------------------------
--	Crytek Source File.
-- 	Copyright (C), Crytek Studios, 2001-2005.
--------------------------------------------------------------------------
--	$Id$
--	$DateTime$
--	Description: Character SCRIPT for basic Car (4 wheeled vehicle) 
-- this is non combat ground vehicle
--  
--------------------------------------------------------------------------
--  History:
--  - 17/05/2005   : Created by Luciano Morpurgo
--
--------------------------------------------------------------------------

AICharacter.Car = {

	AnyBehavior = {
		STOP_VEHICLE = "CarIdle",
	},
	
	CarIdle = {
		-----------------------------------

		ACT_GOTO           = "CarGoto",
		STOP_VEHICLE 			 = "",
		VEHICLE_GOTO_DONE  = "",
		OnEnemySeen       = "CarAlerted",
		TO_CAR_IDLE        = "",
		TO_CAR_SKID				 = "CarSkid",
	},

	CarAlerted = {
		-----------------------------------
		ACT_GOTO           = "",
		STOP_VEHICLE 			 = "CarIdle",
		VEHICLE_GOTO_DONE  = "",
		OnEnemySeen       = "",
		TO_CAR_IDLE        = "",
		TO_CAR_SKID				 = "CarSkid",
		-----------------------------------
		OnNoTarget         = "CarIdle",
	},

	CarGoto = {
		-----------------------------------
		ACT_GOTO           = "",
		STOP_VEHICLE 			 = "CarIdle",
		VEHICLE_GOTO_DONE  = "CarIdle",
		OnEnemySeen       = "CarAlerted",
		TO_CAR_IDLE        = "",
		TO_CAR_SKID				 = "CarSkid",
	},
	
	CarSkid = {
		-----------------------------------
		STOP_VEHICLE 			 = "CarIdle",
		VEHICLE_GOTO_DONE  = "",
		OnEnemySeen       = "",

		TO_CAR_IDLE        = "CarIdle",
		TO_CAR_SKID				 = "",
	},

}
