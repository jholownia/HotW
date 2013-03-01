-- FogOfWarEscape behavior
-- Created by Francesco Roccucci

-- Simple example

--

local Behavior = CreateAIBehavior("FogOfWarEscape",
{
	Alertness = 2,
	
	AI.BeginGoalPipe("fow_escape");
		AI.PushGoal("locate",0, "atttarget");
		AI.PushGoal("run",0,1);
		AI.PushGoal("backoff",1,5,0);
		AI.PushGoal("signal",1,1,"TO_ATTACK");		
	AI.EndGoalPipe();	


	Constructor = function (self, entity)
		Log("Running away!");
		entity:SelectPipe(0,"fow_escape");
	end,
	
})