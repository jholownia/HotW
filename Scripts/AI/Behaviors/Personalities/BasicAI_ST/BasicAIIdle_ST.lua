-- BasicAI behavior using the selection tree feature
-- Created by Sascha Hoba

-- Simple selection tree example

local Behavior = CreateAIBehavior("BasicAIIdle_ST",
{
	Alertness = 0,

	Constructor = function (self, entity)
		Log("Basic AI Idling...");
		AI.SetBehaviorVariable(entity.id, "AwareOfEnemy", false);
		entity:SelectPipe(0,"bai_idle_st");
	end,	
	
	Destructor = function(self, entity)
	end,	
	
})