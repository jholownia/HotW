-- FogOfWarSeek behavior
-- Created by Francesco Roccucci

-- Simple example

local Behavior = CreateAIBehavior("FogOfWarSeekST",
{
	Alertness = 1,

	Constructor = function (self, entity)
		Log("Approaching!");
		entity:SelectPipe(0, "fow_seek_st");
	end,
	
	Destructor = function(self, entity)
	end,
	
	AnalyzeSituation = function (self, entity, sender, data)	
		local min_dist = 10.0;
		local range = 5.0;	
		local distance = AI.GetAttentionTargetDistance(entity.id);
		if(distance > (min_dist + range)) then
			AI.SetBehaviorVariable(entity.id, "IsFar", true);
		elseif(distance < (min_dist + range)) then
			AI.SetBehaviorVariable(entity.id, "IsFar", false);
		end			
	end,
})