-- FogOfWarIdle behavior
-- Created by Francesco Roccucci

-- Simple example

local Behavior = CreateAIBehavior("FogOfWarIdle",
{
	Alertness = 0,

	Constructor = function (self, entity)
		Log("Idling...");
		entity:SelectPipe(0,"_first_");
	end,	
	
	---------------------------------------------
	OnEnemySeen = function( self, entity, fDistance, data )
		-- called when the enemy sees a living player
		Log("Enemy Seen");
		AI.Signal(SIGNALFILTER_SENDER,1,"TO_ATTACK",entity.id);
	end,
})