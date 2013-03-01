-- AICharacter: Aaa

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
--
--------------------------------------------------------------------------

AICharacter.AAA = {
	
	Constructor = function(self,entity)	
--		entity.AI_DesiredFireDistance[1] = 30; -- main gun
--		entity.AI_DesiredFireDistance[2] = 6; -- secondary machine gun
		entity.AI.weaponIdx = 1; --temp: select main gun by default
	end,
	
	AnyBehavior = {
		STOP_VEHICLE = "TankIdle",
	},

	AAAIdle = {
		-----------------------------------
		ACT_GOTO           = "TankGoto",

		STOP_VEHICLE 			 = "",
		VEHICLE_GOTO_DONE  = "",

		TO_TANK_ALERT      = "",
		TO_TANK_ALERT2     = "",
		TO_TANK_ATTACK     = "",
		TO_TANK_MOVE       = "",
	
		OnEnemySeen       = "TankAttack",		

	},
		
	TankIdle = {
		-----------------------------------
		ACT_GOTO           = "TankGoto",

		STOP_VEHICLE 			 = "",
		VEHICLE_GOTO_DONE  = "",

		TO_TANK_ALERT      = "",
		TO_TANK_ALERT2     = "",
		TO_TANK_ATTACK     = "",
		TO_TANK_MOVE       = "",
	
		OnEnemySeen       = "TankAttack",		

	},

	TankGoto = {
		-----------------------------------
		ACT_GOTO           = "",

		STOP_VEHICLE 			 = "TankIdle",	
		VEHICLE_GOTO_DONE  = "TankIdle",

		TO_TANK_ALERT      = "",
		TO_TANK_ALERT2     = "",
		TO_TANK_ATTACK     = "",
		TO_TANK_MOVE       = "",
	
		OnEnemySeen       = "TankAttack",		

	},

	TankAttack = {
		-----------------------------------
		ACT_GOTO           = "",

		STOP_VEHICLE 			 = "TankIdle",	
		VEHICLE_GOTO_DONE  = "",

		TO_TANK_ALERT      = "",
		TO_TANK_ALERT2     = "",
		TO_TANK_ATTACK     = "",
		TO_TANK_MOVE       = "TankMove",
	
		OnEnemySeen       = "",
	
	},

	TankMove = {
		-----------------------------------
		ACT_GOTO           = "",

		STOP_VEHICLE 			 = "TankIdle",	
		VEHICLE_GOTO_DONE  = "",

		TO_TANK_ALERT      = "",
		TO_TANK_ALERT2     = "TankAlert",
		TO_TANK_ATTACK     = "TankAttack",
		TO_TANK_MOVE       = "",
	
		OnEnemySeen       = "",

	},

	TankAlert = {
		-----------------------------------
		ACT_GOTO           = "",

		STOP_VEHICLE 			 = "TankIdle",	
		VEHICLE_GOTO_DONE  = "",

		TO_TANK_ALERT      = "",
		TO_TANK_ALERT2     = "",
		TO_TANK_ATTACK     = "TankAttack",
		TO_TANK_MOVE       = "",
	
		OnEnemySeen       = "",

	},


	
}
