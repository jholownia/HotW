--------------------------------------------------------------------------------------------------
--	: by Kirill
--	: single unit human combat pipes
--	
--------------------------------------------------------------------------------------------------

function PipeManager:OnInitSingle()

	--run to target and do melee. abort if trget moves for more than 2.5m
	AI.BeginGoalPipe("melee_far_during_reload");
		AI.PushGoal("firecmd", 0, 0);
		AI.PushGoal("run", 0, 2);
		AI.PushGoal("bodypos", 0, BODYPOS_STAND);
		AI.PushGoal("stick",0,1.3,0,STICK_BREAK, -1);
		AI.PushLabel("STICK_LOOP");
			AI.PushGoal("branch", 1, "END", IF_TARGET_MOVED_SINCE_START, 2.5);	-- this will check if current weapon has/allows melee
		AI.PushGoal("branch", 1, "STICK_LOOP", IF_ACTIVE_GOALS);
		AI.PushGoal("clear", 0, 0);	 -- stops approaching - 0 means keep att. target
		AI.PushGoal("firecmd", 1, FIREMODE_MELEE);
		AI.PushGoal("timeout", 1, 0.7);
		AI.PushLabel("END");
		AI.PushGoal("hide",1,10,HM_NEAREST+HM_INCLUDE_SOFTCOVERS);
		AI.PushGoal("signal",0,1,"HANDLE_RELOAD",0);
	AI.EndGoalPipe();

	--run to target and do melee. abort if trget moves for more than 2.5m
	AI.BeginGoalPipe("melee_far");
		AI.PushGoal("firecmd", 0, 0);
		AI.PushGoal("run", 0, 2);
		AI.PushGoal("bodypos", 0, BODYPOS_STAND);
		AI.PushGoal("stick",0,1.3,0,STICK_BREAK, -1);
		AI.PushLabel("STICK_LOOP");
			AI.PushGoal("branch", 1, "END", IF_TARGET_MOVED_SINCE_START, 2.5);	-- this will check if current weapon has/allows melee
		AI.PushGoal("branch", 1, "STICK_LOOP", IF_ACTIVE_GOALS);
		AI.PushGoal("clear", 0, 0);	 -- stops approaching - 0 means keep att. target
		AI.PushGoal("firecmd", 1, FIREMODE_MELEE);
		AI.PushGoal("timeout", 1, 0.7);
		AI.PushLabel("END");		
		AI.PushGoal("signal",0,1,"COVER_NORMALATTACK",0);
	AI.EndGoalPipe();

	--close to target - just do melee
	AI.BeginGoalPipe("melee_close");
		AI.PushGoal("bodypos", 0, BODYPOS_STAND);
		AI.PushGoal("firecmd", 1, FIREMODE_MELEE);
		AI.PushGoal("timeout", 1, 0.7);
		AI.PushGoal("signal",0,1,"COVER_NORMALATTACK",0);
	AI.EndGoalPipe();

	---------------------------------------------
	AI.BeginGoalPipe("goto_point");
		AI.PushGoal("acqtarget",0,"");
		AI.PushGoal("bodypos", 0, BODYPOS_CROUCH);
		AI.PushGoal("run", 0, 1);
		AI.PushGoal("approach", 1, 1);
--		AI.PushGoal("firecmd",1,FIREMODE_BURST);
		AI.PushGoal("firecmd",1,FIREMODE_OFF);
		AI.PushGoal("lookaround",1,45,3,2,5,AI_BREAK_ON_LIVE_TARGET);
--		AI.PushGoal("timeout",1,0.5,0.8);
	AI.EndGoalPipe();


end

