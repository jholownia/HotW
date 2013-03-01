-- FogOfWarAttack behavior
-- Created by Francesco Roccucci

-- Simple example

local Behavior = CreateAIBehavior("FogOfWarAttackST",
{
	Alertness = 2,
	
	Constructor = function (self, entity)
		entity:MakeAlerted();
		entity:DrawWeaponNow();	
		self:AnalyzeSituation(entity);
	end,
	
	Destructor = function(self, entity)
	end,	
	
	AnalyzeSituation = function (self, entity, sender, data)
		local min_dist = 10.0;
		local range = 5.0;
		if(AI.GetAttentionTargetDistance(entity.id) < min_dist) then
			Log("Too close!!!!");
			AI.SetBehaviorVariable(entity.id, "IsClose", true);
			AI.SetBehaviorVariable(entity.id, "IsFar", false);
			return;
		elseif(AI.GetAttentionTargetDistance(entity.id) > min_dist + range) then
			Log("Too far!!!");
			AI.SetBehaviorVariable(entity.id, "IsFar", true);
			AI.SetBehaviorVariable(entity.id, "IsClose", false);
			return;
		end	
		Log("Attack!!!!!")
		entity:SelectPipe(0, "fow_fire_st");			
	end,
})