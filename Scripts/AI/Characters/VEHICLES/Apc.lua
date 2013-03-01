-- AICharacter: Apc

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

AICharacter.APC = {
	
	Constructor = function(self,entity)	
--		entity.AI_DesiredFireDistance[1] = 30; -- main gun
--		entity.AI_DesiredFireDistance[2] = 6; -- secondary machine gun
		entity.AI.weaponIdx = 1; --temp: select main gun by default
	end,
	
	AnyBehavior = {
		STOP_VEHICLE = "TankIdle",
	},

	APCIdle = {
		-----------------------------------
		ACT_GOTO           = "TankGoto",

		STOP_VEHICLE 			 = "",
		VEHICLE_GOTO_DONE  = "",

		TO_TANK_ALERT      = "",
		TO_TANK_ALERT2     = "",
		TO_TANK_ATTACK     = "",
		TO_TANK_MOVE       = "",
	
		OnEnemySeen       = "TankAttack",		
		TO_TANK_EMERGENCYEXIT = "",	
		TO_TANK_IDLE = "TankIdle",	

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
		TO_TANK_EMERGENCYEXIT = "",	
		TO_TANK_IDLE = "TankIdle",	

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
		TO_TANK_EMERGENCYEXIT = "",	
		TO_TANK_IDLE = "TankIdle",	

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
		TO_TANK_EMERGENCYEXIT = "",	
		TO_TANK_IDLE = "TankIdle",	
	
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
		TO_TANK_EMERGENCYEXIT = "TankEmergencyExit",	
		TO_TANK_IDLE = "TankIdle",	

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
		TO_TANK_EMERGENCYEXIT = "",	
		TO_TANK_IDLE = "TankIdle",	

	},

	TankEmergencyExit = {
		-----------------------------------
		ACT_GOTO           = "",

		STOP_VEHICLE 			 = "TankIdle",	
		VEHICLE_GOTO_DONE  = "",

		TO_TANK_ALERT      = "",
		TO_TANK_ALERT2     = "",
		TO_TANK_ATTACK     = "TankAttack",
		TO_TANK_MOVE       = "",

		OnEnemySeen       = "",

		TO_TANK_EMERGENCYEXIT = "",	
		TO_TANK_IDLE = "TankIdle",	

	},
	
}
