-- FogOfWarAttack behavior
-- Created by Francesco Roccucci

-- Simple example

local Behavior = CreateAIBehavior("FogOfWarAttack",
{
	Alertness = 2,

	AI.BeginGoalPipe("fow_fire");
		AI.PushGoal("locate", 0, "player");	
		AI.PushGoal("firecmd",0,FIREMODE_BURST,AILASTOPRES_USE);
		AI.PushGoal("timeout",1,1,1);
		AI.PushGoal("firecmd",0,0);
		AI.PushGoal("signal",0,1,"FOW_NORMALATTACK",SIGNALFILTER_SENDER);
	AI.EndGoalPipe();
	
	Constructor = function (self, entity)
		entity:MakeAlerted();
		entity:DrawWeaponNow();
		AI.Signal(SIGNALFILTER_SENDER,1,"FOW_NORMALATTACK",entity.id);
	end,
	
	FOW_NORMALATTACK = function (self, entity, sender)
		local min_dist = 10.0;
		local range = 5.0;
		if(AI.GetAttentionTargetDistance(entity.id) < min_dist) then
			Log("Too close!!!!");
			AI.Signal(SIGNALFILTER_SENDER,1,"TO_ESCAPE",entity.id);
			return;
		elseif(AI.GetAttentionTargetDistance(entity.id) > min_dist + range) then
			Log("Too far!!!");
			AI.Signal(SIGNALFILTER_SENDER,1,"TO_SEEK",entity.id,min_dist);
			return;
		end
		Log("Attack!!!!!")
		entity:SelectPipe(0,"fow_fire");	
	end,
	
	OnLostSightOfTarget = function( self, entity )
		Log("OnLostSightOfTarget");
		AI.Signal(SIGNALFILTER_SENDER,1,"TO_IDLE",entity.id);
	end,
})