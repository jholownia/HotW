-- AICharacter: Cover2

-- COVER CHARACTER SCRIPT

AICharacter.Cover2 = {

	Class = UNIT_CLASS_INFANTRY,
	TeamRole = GU_HUMAN_COVER,
	
	Constructor = function(self,entity)
		entity.AI.target = {x=0, y=0, z=0};
		entity.AI.targetFound = 0;
		AI_Utils:SetupTerritory(entity);
		AI_Utils:SetupStandby(entity);
	end,
	
	AnyBehavior = {
		ENTERING_VEHICLE =				"EnteringVehicle",
		RETURN_TO_FIRST =					"FIRST",
		USE_MOUNTED_WEAPON = 			"UseMounted",
		USE_MOUNTED_WEAPON_INIT = "UseMountedIdle",
		GO_TO_DUMB =							"Dumb",
		GO_TO_AVOIDEXPLOSIVES =   "Cover2AvoidExplosives",
		GO_TO_AVOIDVEHICLE =   		"Cover2AvoidVehicle",
		GO_TO_CHECKDEAD =					"CheckDead",
		OnFallAndPlay =						"HBaseTranquilized",

		TO_ATTACK				= "Cover2Attack",
		TO_RUSH_ATTACK	= "Cover2RushAttack",
		TO_HIDE					= "Cover2Hide",
		TO_AVOID_TANK		= "Cover2AvoidTank",
		TO_RPG_ATTACK		= "Cover2RPGAttack",
		TO_THREATENED		= "Cover2Threatened",
		TO_THREATENED_STANDBY = "Cover2ThreatenedStandby",
		TO_INTERESTED		= "Cover2Interested",
		TO_SEEK					= "Cover2Seek",
		TO_SEARCH				= "Cover2Search",
		TO_RELOAD				= "Cover2Reload",
		TO_CALL_REINFORCEMENTS	= "Cover2CallReinforcements",
		TO_IDLE					= "Cover2Idle",
		TO_PANIC					= "Cover2Panic",
		TO_PREVIOUS				= "PREVIOUS",
		TO_STATIC 			= "HBaseStaticShooter",
		
	},
	
	HBaseAlerted = {
			
	},
	
	HBaseTranquilized = {
		GO_TO_IDLE =							"Cover2Idle",
		RESUME_FOLLOWING =				"",
		ENTERING_VEHICLE =				"",
		USE_MOUNTED_WEAPON =			"",
		OnEnemySeen =						"",
		OnTankSeen =							"",
		OnHeliSeen =							"",
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
		GO_TO_AVOIDVEHICLE =   		"",
		GO_TO_ALERT =							"",
		GO_TO_CHECKDEAD =					"",
	},
	
	UseMounted = {
		ORDER_HIDE = "",
		ORDER_FIRE = "",
		USE_MOUNTED_WEAPON = "",
		ACT_GOTO = "Cover2Idle",
		ACT_FOLLOWPATH = "Cover2Idle",
	},

	UseMountedIdle = {
		USE_MOUNTED_WEAPON = "",
		--OnEnemySeen = "UseMounted",
		--OnEnemyDamage = "UseMounted",
		--OnBulletRain = "UseMounted",
		TO_USE_MOUNTED = "UseMounted",
		TOO_FAR_FROM_WEAPON = "Cover2Idle",
		ACT_GOTO = "Cover2Idle",
		ACT_FOLLOWPATH = "Cover2Idle",
	},
	

	Cover2AvoidExplosives = {
		GO_TO_IDLE =							"Cover2Idle",
		RESUME_FOLLOWING =				"",
		ENTERING_VEHICLE =				"",
		USE_MOUNTED_WEAPON =			"",
		OnEnemySeen =						"",
		OnBulletRain =						"",
		OnGrenadeSeen =						"",
		OnInterestingSoundHeard =	"",
		OnThreateningSoundHeard =	"",
		OnSomethingSeen =					"",
		OnNoTarget = 							"",
	},

	Cover2AvoidVehicles = {
		GO_TO_IDLE =							"Cover2Idle",
		RESUME_FOLLOWING =				"",
		ENTERING_VEHICLE =				"",
		USE_MOUNTED_WEAPON =			"",
	},

	Cover2Idle = {
	
		OnEnemySeen    = "",
		OnInterestingSoundHeard = "",
		OnSomethingSeen	= "",
		OnThreateningSoundHeard = "",
		OnBulletRain		= "",
		OnNearMiss			= "",
		OnEnemyDamage		= "",
		OnGroupMemberDiedNearest 	= "",
		OnSomebodyDied	= "",
		ENEMYSEEN_FIRST_CONTACT	 		= "",
		ENEMYSEEN_DURING_COMBAT		= "",
		OnExplosionDanger		= "HBaseGrenadeRun",
		-----------------------------------
		-- Vehicles related
		entered_vehicle = "InVehicle",
		exited_vehicle 	= "PREVIOUS",
	},

	Cover2Panic = {
	},

	Cover2Interested = {
	},

	Cover2Threatened = {
	},
	
	Cover2Hide = {
	},
	
	Cover2AvoidTank = {
	},

	Cover2RPGAttack= {
	},
	
	Cover2Seek = {
	},

	Cover2Search = {
	},

	Cover2Attack = {
	},

	Cover2Reload = {
	},

	Cover2CallReinforcements = {
	},

	Cover2AttackGroup = {
	},
	
	CheckDead = {
	},
	
	-- Vehicles related signals
	-- there are some cases that you have to mask signals when you add in AnyBehavior.
	-- these charactors also should be supported for cover2/Sneaker/Camper 10/07/2006 tetsuji

	EnteringVehicle = {
		exited_vehicle = "FIRST",
		do_exit_vehicle= "FIRST",
		TO_ATTACK				= "",
		TO_HIDE					= "",
		TO_THREATENED		= "",
		TO_THREATENED_STANDBY = "",
		TO_INTERESTED		= "",
		TO_SEEK					= "",
		TO_SEARCH				= "",
		TO_PANIC				= "",
		entered_vehicle = "InVehicle",
		entered_vehicle_gunner = "InVehicleGunner",
		OnFallAndPlay    = "InVehicleTranquilized",
	},


	InVehicle = {

		exited_vehicle_investigate = "Job_Investigate",
		exited_vehicle = "FIRST",
		do_exit_vehicle= "FIRST",

		OnEnemySeen =						"InVehicleAlerted",
		OnTankSeen =							"",
		OnHeliSeen =							"",
		OnInterestingSoundHeard =	"",
		OnSomethingSeen =					"",
		OnBulletRain =						"",
		OnEnemyDamage	=						"",
		OnDamage =								"",
		OnGroupMemberDied	=				"",
		INCOMING_FIRE =						"",
		ENEMYSEEN_FIRST_CONTACT	 		= "",
		ENEMYSEEN_DURING_COMBAT		= "",
		GO_TO_HIDE =							"",

		TO_ATTACK				= "",
		TO_HIDE					= "",
		TO_THREATENED		= "",
		TO_THREATENED_STANDBY = "",
		TO_INTERESTED		= "",
		TO_SEEK					= "",
		TO_SEARCH				= "",
		TO_AVOID_TANK		= "",
		TO_PANIC				= "",

		controll_vehicle = "InVehicleControlled",

		OnFallAndPlay    = "InVehicleTranquilized",
	},
	
	InVehicleAlerted = {
		exited_vehicle_investigate = "Job_Investigate",
		exited_vehicle = "FIRST",
		do_exit_vehicle= "FIRST",

		OnEnemySeen =						"",
		OnTankSeen =							"",
		OnHeliSeen =							"",
		OnInterestingSoundHeard =	"",
		OnSomethingSeen =					"",
		OnBulletRain =						"",
		OnEnemyDamage	=						"",
		OnDamage =								"",
		OnGroupMemberDied	=				"",
		INCOMING_FIRE =						"",
		ENEMYSEEN_FIRST_CONTACT	 		= "",
		ENEMYSEEN_DURING_COMBAT		= "",
		GO_TO_HIDE =							"",

		TO_ATTACK				= "",
		TO_HIDE					= "",
		TO_THREATENED		= "",
		TO_THREATENED_STANDBY = "",
		TO_INTERESTED		= "",
		TO_SEEK					= "",
		TO_SEARCH				= "",
		TO_AVOID_TANK		= "",
		TO_PANIC				= "",

		controll_vehicle = "InVehicleControlled",
		OnFallAndPlay    = "InVehicleTranquilized",
	},

	InVehicleGunner = {

		exited_vehicle_investigate = "Job_Investigate",
		exited_vehicle = "FIRST",
		do_exit_vehicle= "FIRST",

		OnEnemySeen =						"",
		OnTankSeen =							"",
		OnHeliSeen =							"",
		OnInterestingSoundHeard =	"",
		OnSomethingSeen =					"",
		OnBulletRain =						"",
		OnEnemyDamage	=						"",
		OnDamage =								"",
		OnGroupMemberDied	=				"",
		INCOMING_FIRE =						"",
		ENEMYSEEN_FIRST_CONTACT	 		= "",
		ENEMYSEEN_DURING_COMBAT		= "",
		GO_TO_HIDE =							"",

		TO_ATTACK				= "",
		TO_HIDE					= "",
		TO_THREATENED		= "",
		TO_THREATENED_STANDBY = "",
		TO_INTERESTED		= "",
		TO_SEEK					= "",
		TO_SEARCH				= "",
		TO_AVOID_TANK		= "",
		TO_PANIC				= "",

		controll_vehicleGunner = "InVehicleControlledGunner",

		TO_CHANGE_SEAT	= "InVehicleChangeSeat",

		OnFallAndPlay   = "InVehicleTranquilized",

	},

	InVehicleControlledGunner = {	

		exited_vehicle_investigate = "Job_Investigate",
		exited_vehicle = "FIRST",
		do_exit_vehicle= "FIRST",

		OnEnemySeen =						"",
		OnTankSeen =							"",
		OnHeliSeen =							"",
		OnInterestingSoundHeard =	"",
		OnSomethingSeen =					"",
		OnBulletRain =						"",
		OnEnemyDamage	=						"",
		OnDamage =								"",
		OnGroupMemberDied	=				"",
		INCOMING_FIRE =						"",
		ENEMYSEEN_FIRST_CONTACT	 		= "",
		ENEMYSEEN_DURING_COMBAT		= "",
		GO_TO_HIDE =							"",

		TO_ATTACK				= "",
		TO_HIDE					= "",
		TO_THREATENED		= "",
		TO_THREATENED_STANDBY = "",
		TO_INTERESTED		= "",
		TO_SEEK					= "",
		TO_SEARCH				= "",
		TO_AVOID_TANK		= "",
		TO_PANIC				= "",

		TO_CHANGE_SEAT	= "InVehicleChangeSeat",

		OnFallAndPlay   = "InVehicleTranquilized",

	},

	InVehicleControlled = {	
		exited_vehicle_investigate = "Job_Investigate",
		exited_vehicle = "FIRST",
		do_exit_vehicle= "FIRST",

		OnEnemySeen =						"",
		OnTankSeen =							"",
		OnHeliSeen =							"",
		OnInterestingSoundHeard =	"",
		OnSomethingSeen =					"",
		OnBulletRain =						"",
		OnEnemyDamage	=						"",
		OnDamage =								"",
		OnGroupMemberDied	=				"",
		INCOMING_FIRE =						"",
		ENEMYSEEN_FIRST_CONTACT	 		= "",
		ENEMYSEEN_DURING_COMBAT		= "",
		GO_TO_HIDE =							"",

		TO_ATTACK				= "",
		TO_HIDE					= "",
		TO_THREATENED		= "",
		TO_THREATENED_STANDBY = "",
		TO_INTERESTED		= "",
		TO_SEEK					= "",
		TO_SEARCH				= "",
		TO_AVOID_TANK		= "",
		TO_PANIC				= "",

		OnFallAndPlay    = "InVehicleTranquilized",
	},

	InVehicleChangeSeat = {

		exited_vehicle_investigate = "Job_Investigate",
		exited_vehicle = "FIRST",
		do_exit_vehicle= "FIRST",

		OnEnemySeen =						"",
		OnTankSeen =							"",
		OnHeliSeen =							"",
		OnInterestingSoundHeard =	"",
		OnSomethingSeen =					"",
		OnBulletRain =						"",
		OnEnemyDamage	=						"",
		OnDamage =								"",
		OnGroupMemberDied	=				"",
		INCOMING_FIRE =						"",
		ENEMYSEEN_FIRST_CONTACT	 		= "",
		ENEMYSEEN_DURING_COMBAT		= "",
		GO_TO_HIDE =							"",

		TO_ATTACK				= "",
		TO_HIDE					= "",
		TO_THREATENED		= "",
		TO_THREATENED_STANDBY = "",
		TO_INTERESTED		= "",
		TO_SEEK					= "",
		TO_SEARCH				= "",
		TO_AVOID_TANK		= "",
		TO_PANIC				= "",

		OnFallAndPlay    = "InVehicleTranquilized",
	},

	Dumb = {
		GO_TO_IDLE =							"Cover2Idle",
		RESUME_FOLLOWING =				"",
		ENTERING_VEHICLE =				"",
		USE_MOUNTED_WEAPON =			"",
		OnEnemySeen =						"",
		OnTankSeen =							"",
		OnHeliSeen =							"",
		OnBulletRain =						"",
		OnGrenadeSeen =						"",
		OnInterestingSoundHeard =	"",
		OnThreateningSoundHeard =	"",
		entered_vehicle	=					"",
		exited_vehicle =					"",
		exited_vehicle_investigate = "",
		OnSomethingSeen =					"",
		TO_ATTACK				= "",
		TO_RUSH_ATTACK	= "",
		TO_HIDE					= "",
		TO_AVOID_TANK		= "",
		TO_RPG_ATTACK		= "",
		TO_THREATENED		= "",
		TO_THREATENED_STANDBY = "",
		TO_INTERESTED		= "",
		TO_SEEK					= "",
		TO_SEARCH				= "",
		TO_RELOAD				= "",
		TO_CALL_REINFORCEMENTS	= "",
		ENEMYSEEN_FIRST_CONTACT	 		= "",
		ENEMYSEEN_DURING_COMBAT		= "",
		TO_PANIC				= "",
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

}
