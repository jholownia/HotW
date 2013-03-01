-- AICharacter: TankFixed

--------------------------------------------------------------------------
--	Crytek Source File.
-- 	Copyright (C), Crytek Studios, 2001-2004.
--------------------------------------------------------------------------
--	$Id$
--	$DateTime$
--	Description: Character SCRIPT for Tank
--  
--------------------------------------------------------------------------
--  History:
--  - 06/02/2005   : Created by Kirill Bulatsev
--  - 17/07/2006   : Dulplicated for the special tank by Tetsuji
--  
--------------------------------------------------------------------------

AICharacter.TankFixed = {
	
	Constructor = function(self,entity)	
--		entity.AI.DesiredFireDistance[1] = 30; -- main gun
--		entity.AI.DesiredFireDistance[2] = 6; -- secondary machine gun
		entity.AI.weaponIdx = 1; --temp: select main gun by default
	end,
	
	AnyBehavior = {
		STOP_VEHICLE = "TankFixedIdle",
	},
	
	TankFixedIdle = {
		-----------------------------------
		ACT_GOTO            = "TankFixedGoto",

		STOP_VEHICLE 			  = "",
		VEHICLE_GOTO_DONE   = "",

		TO_TANKCLOSE_ATTACK = "";
	
		OnEnemySeen        = "",		

	},
	
	TankFixedGoto = {
		-----------------------------------
		ACT_GOTO            = "",

		STOP_VEHICLE 			  = "TankFixedIdle",
		VEHICLE_GOTO_DONE   = "TankFixedIdle",

		TO_TANKCLOSE_ATTACK = "";
	
		OnEnemySeen        = "",		

	},

	TankFixedAttack = {
		-----------------------------------
		ACT_GOTO            = "",

		STOP_VEHICLE 			  = "TankFixedIdle",
		VEHICLE_GOTO_DONE   = "TankFixedIdle",

		TO_TANKCLOSE_ATTACK = "";
	
		OnEnemySeen        = "",		

	},

	
}
