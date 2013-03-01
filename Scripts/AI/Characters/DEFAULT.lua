-- AICharacter: DEFAULT INTERNAL

-- COVER CHARACTER SCRIPT

AICharacter.DEFAULT = {

	NoBehaviorFound = {
		BackToJob			 = "FIRST",
		BackToPrevious = "PREVIOUS",

		START_SWIMMING  = "Swim",
		STOP_SWIMMING  = "PREVIOUS",

		ORDER_SEARCH = "",
		OnEndFollow = "Job_StandIdle",
		
		FASTKILL = "FastKill",
		
		ACT_DIALOG 			= "Dialog",
	},

	-----------------------------------
	-- Vehicles related
	InVehicle = {	
		exited_vehicle_investigate = "Job_Investigate",
		exited_vehicle = "FIRST",
		do_exit_vehicle= "FIRST",
	},

	EnteringVehicle = {
		exited_vehicle = "FIRST",
		do_exit_vehicle= "FIRST",
	},

	InVehicleGunner = {	
		exited_vehicle_investigate = "Job_Investigate",
		exited_vehicle = "FIRST",
		do_exit_vehicle= "FIRST",
		controll_vehicleGunner = "InVehicleControlledGunner",
	},

	InVehicleControlledGunner = {	
		exited_vehicle_investigate = "Job_Investigate",
		exited_vehicle = "FIRST",
		do_exit_vehicle= "FIRST",
	},

	InVehicleTranquilized = {
		OnFallAndPlayWakeUp = 		"PREVIOUS",
		OnFallAndPlay			= "",
		RESUME_FOLLOWING =				"",
		ENTERING_VEHICLE =				"",
		USE_MOUNTED_WEAPON =			"",
		OnEnemySeen =						"",
		OnBulletRain =						"",
		OnGrenadeSeen =						"",
		OnInterestingSoundHeard =	"",
		OnThreateningSoundHeard =	"",
		entered_vehicle	=					"",
		exited_vehicle =					"",
		exited_vehicle_investigate = "",
		OnSomethingSeen =					"",
		GO_TO_SEEK =							"",
		GO_TO_IDLE = 							"",
		GO_TO_SEARCH =						"",
		GO_TO_ATTACK =						"",
		GO_TO_AVOIDEXPLOSIVES =   "",
		GO_TO_ALERT =							"",
		GO_TO_CHECKDEAD =					"",
	},

	UseMountedTranquilized = {
		OnFallAndPlayWakeUp = 		"UseMountedIdle",
		RESUME_FOLLOWING =				"",
		ENTERING_VEHICLE =				"",
		USE_MOUNTED_WEAPON =			"",
		OnEnemySeen =						"",
		OnBulletRain =						"",
		OnGrenadeSeen =						"",
		OnInterestingSoundHeard =	"",
		OnThreateningSoundHeard =	"",
		entered_vehicle	=					"",
		exited_vehicle =					"",
		exited_vehicle_investigate = "",
		OnSomethingSeen =					"",
		GO_TO_SEEK =							"",
		GO_TO_IDLE = 							"",
		GO_TO_SEARCH =						"",
		GO_TO_ATTACK =						"",
		GO_TO_AVOIDEXPLOSIVES =   "",
		GO_TO_ALERT =							"",
		GO_TO_CHECKDEAD =					"",
	},
	
	FastKill = {
		FASTKILL_EXIT  = "PREVIOUS",
		TO_SEEK =					"",
	},
		
	Dialog = {
		ACT_DIALOG_OVER	= "PREVIOUS",
	},

}