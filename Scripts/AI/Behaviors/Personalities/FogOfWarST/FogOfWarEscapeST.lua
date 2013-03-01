-- FogOfWarEscape behavior
-- Created by Francesco Roccucci

-- Simple example

--

local Behavior = CreateAIBehavior("FogOfWarEscapeST",
{
	Alertness = 2,


	Constructor = function (self, entity)
		Log("Running away!");
		entity:SelectPipe(0, "fow_escape_st");
	end,
	
	Destructor = function(self, entity)
	end,	
	
	AnalyzeSituation = function (self, entity, sender, data)
		local min_dist = 10.0;
		local range = 5.0;	
		local distance = AI.GetAttentionTargetDistance(entity.id);
		if(distance > min_dist and distance < (min_dist + range)) then
			AI.SetBehaviorVariable(entity.id, "IsClose", false);
		elseif(distance > (min_dist + range)) then
			AI.SetBehaviorVariable(entity.id, "IsFar", true);
			AI.SetBehaviorVariable(entity.id, "IsClose", false);
		end	
	end,
	
})