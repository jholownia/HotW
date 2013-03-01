-- AICharacter: FogOfWar
-- Created by Francesco Roccucci

-- Simple example

AICharacter.FogOfWar = {

	Class = UNIT_CLASS_INFANTRY,
	
	-------------------------------------------------------------------------------------------------------
	AnyBehavior = {
		
		RETURN_TO_FIRST 	= "FIRST",
		TO_ATTACK			= "FogOfWarAttack",
		TO_SEEK				= "FogOfWarSeek",
		TO_ESCAPE 			= "FogOfWarEscape",
		TO_IDLE 			= "FogOfWarIdle",
	},

}