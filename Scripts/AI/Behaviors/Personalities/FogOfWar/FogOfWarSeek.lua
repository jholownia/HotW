-- FogOfWarSeek behavior
-- Created by Francesco Roccucci

-- Simple example

local Behavior = CreateAIBehavior("FogOfWarSeek",
{
	Alertness = 1,
	
	AI.BeginGoalPipe("fow_approach");
		AI.PushGoal("locate",0, "atttarget");
		AI.PushGoal("run",0,1);
		AI.PushGoal("stick",1,10.0,AILASTOPRES_USE, STICK_BREAK);
		AI.PushGoal("signal",0,1,"TO_ATTACK");
	AI.EndGoalPipe();	


	Constructor = function (self, entity)
		Log("Approaching!");
		entity:SelectPipe(0,"fow_approach");
	end,
	
})