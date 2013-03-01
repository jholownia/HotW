-- FogOfWarIdle behavior
-- Created by Francesco Roccucci

-- Simple example

local Behavior = CreateAIBehavior("FogOfWarIdleST",
{
	Alertness = 0,

	Constructor = function (self, entity)
		Log("Idling...");
		AI.SetBehaviorVariable(entity.id, "AwareOfPlayer", false);
		entity:SelectPipe(0,"fow_idle_st");
	end,	
	
	Destructor = function(self, entity)
	end,	
	
})