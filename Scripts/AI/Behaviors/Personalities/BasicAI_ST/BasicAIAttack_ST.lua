-- BasicAI behavior using the selection tree feature
-- Created by Sascha Hoba

-- Simple selection tree example

local Behavior = CreateAIBehavior("BasicAIAttack_ST",
{
	Alertness = 2,

	Constructor = function (self, entity)
		Log("Basic AI Attacking...");
		
		local point = g_Vectors.temp_v1
		if (AI.GetTacticalPoints(entity.id, "ReachableGridTest", point)) then
			AI.SetRefPointPosition(entity.id, point);
			entity:SelectPipe(0, "bai_attack_st");
		else
			entity:SelectPipe(0, "Empty");
		end
	end,	
	
	Destructor = function(self, entity)
	end,	
	
})