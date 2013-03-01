-- AICharacter: Cover3

-----------------------------------------------------------
-- Cover3 Character Script
-----------------------------------------------------------
-- Created: Matthew Jack 12-10-2009
-- Description: Based on the Cover2 character, now with
--              behavior trees
-----------------------------------------------------------

AICharacter.Cover3 = {
	Class = UNIT_CLASS_INFANTRY,
	TeamRole = GU_HUMAN_COVER,
	
	Constructor = function(self,entity)
		entity.AI.target = {x=0, y=0, z=0};
		entity.AI.targetFound = 0;
		AI_Utils:SetupTerritory(entity);
		AI_Utils:SetupStandby(entity);
	end,
	
	AnyBehavior = {
		--ENTERING_VEHICLE =				"EnteringVehicle",
		--RETURN_TO_FIRST =					"FIRST",
		--USE_MOUNTED_WEAPON = 			"UseMounted",
		--USE_MOUNTED_WEAPON_INIT = "UseMountedIdle",
		--GO_TO_DUMB =							"Dumb",
		--GO_TO_AVOIDEXPLOSIVES =   "Cover3AvoidExplosives",
		--GO_TO_AVOIDVEHICLE =   		"Cover3AvoidVehicle",
		--GO_TO_CHECKDEAD =					"CheckDead",
		--OnFallAndPlay =						"HBaseTranquilized",

		BT_ATTACK				= "Cover3Attack",
		BT_INTERESTED		= "Cover3Interested",
		BT_SEEK					= "Cover3Seek",
		BT_AVOIDEXPLOSIVES = "Cover3AvoidExplosives",
		BT_FALLEN       = "Cover3Fallen",
		BT_IDLE					= "Cover3Idle",
	},
}