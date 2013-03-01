--
-- Goalpipes for cover2
--

function PipeManager:OnInitCover2()
	AI.LogEvent("OnInitCover2 CALLED");
	
	---------------------------------------------
	AI.BeginGoalPipe("cv_get_back_to_idlepos");
		AI.PushGoal("bodypos",0,BODYPOS_STAND);
		AI.PushGoal("firecmd",0,0);
		AI.PushGoal("run",0,0);
		AI.PushGoal("lookaround",1,45,3,2,5,AI_BREAK_ON_LIVE_TARGET);
		AI.PushGoal("locate", 0,"refpoint");
		AI.PushGoal("approach",1,2,AILASTOPRES_USE);
		AI.PushGoal("locate", 0,"probtarget");
		AI.PushGoal("lookat",0,0,0,1);
		AI.PushGoal("clear",0,0);
		AI.PushGoal("lookaround",1,45,3,2,5,AI_BREAK_ON_LIVE_TARGET);
		AI.PushGoal("signal",0,1,"RETURN_TO_FIRST",0);
	AI.EndGoalPipe();

	---------------------------------------------
	AI.BeginGoalPipe("cv_investigate_threat");
		AI.PushGoal("bodypos",1,BODYPOS_STAND,1);	
		AI.PushGoal("strafe",0,1.5,5);
		AI.PushGoal("firecmd",0,0);	
		AI.PushGoal("run",0,1);
		AI.PushGoal("lookaround",0,15,3,100,100,AI_BREAK_ON_LIVE_TARGET);
		AI.PushGoal("timeout",1,0.2,1);
		AI.PushGoal("locate", 1, "refpoint");
		--AI.PushGoal("+approach",1,20,AILASTOPRES_USE+AILASTOPRES_LOOKAT,15.0);
		AI.PushGoal("+stick",1,20,AILASTOPRES_USE,STICK_BREAK,10.0, 10);
		AI.PushGoal("signal",0,1,"INVESTIGATE_CONTINUE",0);
	AI.EndGoalPipe();

	---------------------------------------------
	AI.BeginGoalPipe("cv_investigate_threat_closer");
		AI.PushGoal("run",0,0);
		AI.PushGoal("bodypos",1,BODYPOS_STEALTH,1);	
		AI.PushGoal("firecmd",0,FIREMODE_AIM);

		AI.PushGoal("locate",0,"refpoint");
--		AI.PushGoal("+approach",1,5,AILASTOPRES_USE,15.0, 3);
		AI.PushGoal("+stick",1,5,AILASTOPRES_USE,STICK_BREAK,10.0, 3);

--		AI.PushGoal("locate",0,"refpoint");
--		AI.PushGoal("+stick",1,2,AILASTOPRES_USE,STICK_BREAK,10.0);

--		AI.PushGoal("locate", 1, "probtarget_in_territory");
--		AI.PushGoal("+approach",1,4,AILASTOPRES_USE+AILASTOPRES_LOOKAT,15.0);
--		AI.PushGoal("clear",0,0);
--		AI.PushGoal("lookaround",0,20,3,100,100,AI_BREAK_ON_LIVE_TARGET);
--		AI.PushGoal("bodypos",1,BODYPOS_CROUCH);	
--		AI.PushGoal("locate", 1, "probtarget_in_territory");
--		AI.PushGoal("+approach",1,1,AILASTOPRES_USE+AILASTOPRES_LOOKAT,15.0);
		AI.PushGoal("clear",0,0);
		AI.PushGoal("lookaround",1,120,3,1,3,AI_BREAK_ON_LIVE_TARGET);
		AI.PushGoal("signal",0,1,"INVESTIGATE_DONE",0);
	AI.EndGoalPipe();
	
	---------------------------------------------
	AI.BeginGoalPipe("cv_seek_target_random");
		AI.PushGoal("run",0,0);
		AI.PushGoal("firecmd",0,0);
		AI.PushGoal("strafe",0,4,10);
		AI.PushGoal("bodypos",1,BODYPOS_STEALTH);
		AI.PushGoal("locate", 1, "probtarget_in_territory");
		AI.PushGoal("+hide", 1, 25, HM_RANDOM+HM_AROUND_LASTOP+HM_INCLUDE_SOFTCOVERS, 1); -- lookat hide
		AI.PushGoal("branch", 1, "HIDE_OK", IF_LASTOP_SUCCEED);
			AI.PushGoal("signal",0,1,"HIDE_FAILED",0);
		AI.PushLabel("HIDE_OK");

--		AI.PushGoal("firecmd",0,FIREMODE_AIM);
		AI.PushGoal("lookaround",1,120,3,1,3,AI_BREAK_ON_LIVE_TARGET);

		AI.PushGoal("signal",0,1,"LOOK_FOR_TARGET",0);
	AI.EndGoalPipe();

	---------------------------------------------
	AI.BeginGoalPipe("cv_seek_target_nocover");

		AI.PushGoal("run",0,0);
		AI.PushGoal("firecmd",0,0);
		AI.PushGoal("strafe",0,4,10);
		AI.PushGoal("bodypos",1,BODYPOS_STEALTH);

		AI.PushGoal("locate",0,"refpoint");
		AI.PushGoal("+approach",1,-15,AILASTOPRES_USE,15,"",8);

		AI.PushGoal("lookaround",1,120,3,1,3,AI_BREAK_ON_LIVE_TARGET);

		AI.PushGoal("signal",0,1,"LOOK_FOR_TARGET",0);
	AI.EndGoalPipe();

	---------------------------------------------
	AI.BeginGoalPipe("cv_backoff_from_explosion");
		AI.PushGoal("firecmd",0,0);
		AI.PushGoal("bodypos",1,BODYPOS_STEALTH,1);
		-- Strafing significantly descreases the chances of survival and also looks unnatural
		--AI.PushGoal("firecmd",0,FIREMODE_BURST_WHILE_MOVING);
		AI.PushGoal("run",0,2);
		-- Strafing significantly descreases the chances of survival and also looks unnatural
		--AI.PushGoal("strafe",0,2,2);
		AI.PushGoal("locate",0,"refpoint");
		AI.PushGoal("+approach",1,-11,AILASTOPRES_USE+AI_REQUEST_PARTIAL_PATH,15,"",4);
		AI.PushGoal("run",0,0);
		AI.PushGoal("signal",1,1,"END_BACKOFF",SIGNALFILTER_SENDER);
	AI.EndGoalPipe();

	---------------------------------------------
	AI.BeginGoalPipe("cv_backoff_from_explosion_short");
		AI.PushGoal("firecmd",0,0);
		AI.PushGoal("bodypos",1,BODYPOS_STEALTH,1);
		-- Strafing significantly descreases the chances of survival and also looks unnatural
		--AI.PushGoal("firecmd",0,FIREMODE_BURST_WHILE_MOVING);
		AI.PushGoal("run",0,2);
		-- Strafing significantly descreases the chances of survival and also looks unnatural
		--AI.PushGoal("strafe",0,2,2);
		AI.PushGoal("locate",0,"refpoint");
		AI.PushGoal("+approach",1,-7,AILASTOPRES_USE+AI_REQUEST_PARTIAL_PATH,15,"",2);
		AI.PushGoal("run",0,0);
		AI.PushGoal("signal",1,1,"END_BACKOFF",SIGNALFILTER_SENDER);
	AI.EndGoalPipe();

	---------------------------------------------
	AI.BeginGoalPipe("cv_look_at_target");
		AI.PushGoal("locate",0,"atttarget");
		AI.PushGoal("lookat",0,0,0,1);
		AI.PushGoal("timeout",1,.6,.9);
		AI.PushGoal("clear",0,0);
	AI.EndGoalPipe();
	
	---------------------------------------------
	AI.BeginGoalPipe("cv_look_at_lastop");
		AI.PushGoal("lookat",0,0,0,1);
		AI.PushGoal("timeout",1,0.6,0.9);
		AI.PushGoal("clear",0,0);
		AI.PushGoal("lookaround",0,20,2,1,2,AI_BREAK_ON_LIVE_TARGET);
	AI.EndGoalPipe();

	---------------------------------------------
	AI.BeginGoalPipe("cv_tranquilized");
		AI.PushGoal("clear",1,1);
		--AI.PushGoal("ignoreall",0,1);
		AI.PushLabel("SLEEPYSLEEPER");
		AI.PushGoal("timeout",1,0.15);
		AI.PushGoal("branch", 1, "SLEEPYSLEEPER", BRANCH_ALWAYS);
	AI.EndGoalPipe();

	---------------------------------------------
	AI.BeginGoalPipe("cv_adjust_pos_shoot");
		AI.PushGoal("firecmd",0,1);
		AI.PushGoal("run",0,0);
		AI.PushGoal("timeout",1,0,0.4);
		AI.PushGoal("branch", 1, "CHANGE_STANCE", IF_STANCE_IS, BODYPOS_PRONE);	
		AI.PushGoal("branch", 1, "OK_STANCE", BRANCH_ALWAYS);
			AI.PushLabel("CHANGE_STANCE");
			AI.PushGoal("bodypos",0,BODYPOS_STAND);
	--		AI.PushGoal("timeout",1,0.4);
		AI.PushLabel("OK_STANCE");
		AI.PushGoal("strafe",0,10,0);
	AI.EndGoalPipe();
	
	---------------------------------------------
	AI.BeginGoalPipe("cv_adjust_pos_right_shoot");
		AI.PushGoal("cv_adjust_pos_shoot");
		AI.PushGoal("backoff",1,2.0,0,AI_MOVE_RIGHT);
	AI.EndGoalPipe();

	---------------------------------------------
	AI.BeginGoalPipe("cv_adjust_pos_right_short_shoot");
		AI.PushGoal("cv_adjust_pos_shoot");
		AI.PushGoal("backoff",1,1.0,0,AI_MOVE_RIGHT);
	AI.EndGoalPipe();

	---------------------------------------------
	AI.BeginGoalPipe("cv_adjust_pos_left_shoot");
		AI.PushGoal("cv_adjust_pos_shoot");
		AI.PushGoal("backoff",1,2.0,0,AI_MOVE_LEFT);
	AI.EndGoalPipe();

	---------------------------------------------
	AI.BeginGoalPipe("cv_adjust_pos_left_short_shoot");
		AI.PushGoal("cv_adjust_pos_shoot");
		AI.PushGoal("backoff",1,1.0,0,AI_MOVE_LEFT);
	AI.EndGoalPipe();

	---------------------------------------------
	AI.BeginGoalPipe("cv_refpoint_investigate");
		AI.PushGoal("bodypos",0,BODYPOS_STAND,1);
		AI.PushGoal("run",0,1);
		AI.PushGoal("strafe",0,1,2);
		AI.PushGoal("firecmd",0,0);	
		AI.PushGoal("lookaround",0,45,3,100,100,AI_BREAK_ON_LIVE_TARGET);
		AI.PushGoal("locate",0,"refpoint");
		AI.PushGoal("+approach",1,7,0,15.0);
		AI.PushGoal("clear",0,0);
		AI.PushGoal("firecmd",0,1);
		AI.PushGoal("bodypos",0,BODYPOS_STEALTH,1);
		AI.PushGoal("lookaround",0,45,2,100,100,AI_BREAK_ON_LIVE_TARGET);
		AI.PushGoal("locate",0,"refpoint");
		AI.PushGoal("+approach",1,1,0,15.0);
		AI.PushGoal("signal",1,1,"LOOK_FOR_TARGET",0);
	AI.EndGoalPipe();
	
	---------------------------------------------
	AI.BeginGoalPipe("su_keep_hiding");
	--	AI.PushGoal( "branch", 1, "MUST_HIDE", IF_COVER_SOFT);
	--	AI.PushGoal( "branch", 1, "SKIP_HIDE", IF_COVER_NOT_COMPROMISED);
	--		AI.PushLabel("MUST_HIDE");
		AI.PushGoal("run",0,1);
		AI.PushGoal("bodypos",1,BODYPOS_STAND);
		AI.PushGoal("hide",1,15,HM_NEAREST);
--		AI.PushLabel("SKIP_HIDE");
		AI.PushGoal("strafe",0,2,2);
		AI.PushGoal("lookaround",0,20,3,100,100,AI_BREAK_ON_LIVE_TARGET);
		AI.PushGoal("run",0,0);
		-- shoot if target is close
		AI.PushGoal( "branch", 1, "NO_SHOOT", IF_TARGET_DIST_GREATER, 25);
			AI.PushGoal("firecmd",0,1);
			AI.PushGoal( "branch", 1, "SKIP_NO_SHOOT", BRANCH_ALWAYS);			
		AI.PushLabel("NO_SHOOT");
			AI.PushGoal("firecmd",0,0);		
		AI.PushLabel("SKIP_NO_SHOOT");
		AI.PushGoal("locate",0,"probtarget");

		--AI.PushGoal("usecover",1,COVER_HIDE,.5,.7,1);
		AI.PushGoal("hide",1,15,HM_NEAREST);
		
		AI.PushGoal("clear",0,0);
		AI.PushGoal("signal",0,1,"MORE_HIDE",0);
	AI.EndGoalPipe();
	
	---------------------------------------------
	AI.BeginGoalPipe("su_stay_hidden");
--		AI.PushGoal("firecmd",0,0);	
		AI.PushGoal("run",0,1);	
		-- hide if needed
		AI.PushGoal( "branch", 1, "HIDDEN", IF_IS_HIDDEN);
			AI.PushGoal("hide",1,15,HM_NEAREST);
		AI.PushLabel("HIDDEN");
		AI.PushGoal("strafe",0,2,2);
		-- enable shooting if enemy is close
		AI.PushGoal( "branch", 1, "NO_SHOOT", IF_TARGET_DIST_GREATER, 25);
			AI.PushGoal("firecmd",0,1);
			AI.PushGoal( "branch", 1, "SKIP_NO_SHOOT", BRANCH_ALWAYS);			
		AI.PushLabel("NO_SHOOT");
			AI.PushGoal("firecmd",0,0);		
		AI.PushLabel("SKIP_NO_SHOOT");
		
		--AI.PushGoal("usecover",1,COVER_HIDE,1,2,1);
		AI.PushGoal("hide",1,15,HM_NEAREST);

		AI.PushGoal("clear",0,0);
		AI.PushGoal("signal",0,1,"MORE_HIDE",0);
	AI.EndGoalPipe();
	

	---------------------------------------------
	AI.BeginGoalPipe("su_keep_hiding_beacon");
		AI.PushGoal("locate",0,"probtarget");
		AI.PushGoal("acqtarget",0,"");
		AI.PushGoal("su_keep_hiding");
	AI.EndGoalPipe();

	---------------------------------------------
	AI.BeginGoalPipe("sn_advance_to_target");
		AI.PushGoal("firecmd",0,FIREMODE_BURST_WHILE_MOVING);
--		AI.PushGoal("check_cover_fire",1);
		AI.PushGoal("bodypos",1,BODYPOS_STAND);
		AI.PushGoal("run",0,0);
		-- sets the refpoint to the point to advance to
		AI.PushGoal("signal",0,1,"SELECT_ADVANCE_POINT",0);
--		AI.PushGoal("timeout",1,0.15);
		AI.PushGoal("run",0,2,0,25);
		AI.PushGoal("strafe",0,1,3);
		AI.PushGoal("locate",0,"refpoint");
		AI.PushGoal("+approach",1,6,AILASTOPRES_USE,2.0,"ADVANCE_NOPATH");
		AI.PushGoal("firecmd",0,1);
		AI.PushGoal("strafe",0,1.5,1.5);
		AI.PushGoal("locate",0,"refpoint");
		AI.PushGoal("+approach",1,1,AILASTOPRES_USE,2.0,"ADVANCE_NOPATH");
		AI.PushGoal("run",0,0);
--		AI.PushGoal("locate",0,"probtarget");
--		AI.PushGoal("usecover",1,COVER_HIDE,1,2,1);
--		AI.PushGoal( "branch", 1, "DONE", IF_TARGET_OUT_OF_RANGE);		
--			AI.PushGoal("signal",0,1,"COMBAT_READABILITY",0);
--			AI.PushGoal("usecover",1,COVER_UNHIDE,4,6,1);
--			AI.PushGoal("usecover",1,COVER_HIDE,2,3);
--		AI.PushLabel("DONE");
		AI.PushGoal("signal",0,1,"COVER_NORMALATTACK",0);
	AI.EndGoalPipe();

	---------------------------------------------
	AI.BeginGoalPipe("cv_look_closer");
		AI.PushGoal("strafe",0,1.5,10);
		AI.PushGoal("bodypos",0,BODYPOS_STAND);
		AI.PushGoal("timeout",1,0.5,1.5);
--		AI.PushGoal("signal",0,1,"INVESTIGATE_READABILITY",0);
		AI.PushGoal("run",0,0);
		AI.PushGoal("lookaround",0,30,3,100,100,AI_BREAK_ON_LIVE_TARGET);
--		AI.PushGoal("locate", 0,"refpoint");
--		AI.PushGoal("+approach",1,5,AILASTOPRES_USE,10.0);
		AI.PushGoal("locate",0,"refpoint");
		AI.PushGoal("+stick",1,5,AILASTOPRES_USE,STICK_BREAK,10.0);
		AI.PushGoal("clear", 0, 0);
		AI.PushGoal("lookaround",1,45,3,6,10,AI_BREAK_ON_LIVE_TARGET);
		AI.PushGoal("signal",0,1,"INVESTIGATE_DONE",0);
	AI.EndGoalPipe();

	---------------------------------------------
	AI.BeginGoalPipe("sn_use_cover");
		AI.PushGoal("firecmd",0,FIREMODE_BURST_WHILE_MOVING);
		AI.PushGoal("strafe",0,1,2);
--		AI.PushGoal("check_cover_fire",1);
		AI.PushGoal("run",0,2,0,20);
		AI.PushGoal( "branch", 1, "SKIP_HIDE", IF_COVER_NOT_COMPROMISED);
			AI.PushGoal("bodypos",1,BODYPOS_STEALTH);
			AI.PushGoal("hide",1,20,HM_NEAREST);
		AI.PushLabel("SKIP_HIDE");
		AI.PushGoal("run",0,0);
--		AI.PushGoal( "branch", 1, "HANDLE_SOFT", IF_COVER_SOFT);
			AI.PushGoal("firecmd",0,1);
			AI.PushGoal("locate",0,"probtarget");

--			AI.PushGoal("usecover",1,COVER_HIDE,0.5,1,1);
			AI.PushGoal("hide",1,15,HM_NEAREST);

			AI.PushGoal("strafe",0,2,2);
			AI.PushGoal("branch", 1, "DONE", IF_TARGET_OUT_OF_RANGE);
			AI.PushGoal("signal",0,1,"COMBAT_READABILITY",0);
			
			--AI.PushGoal("usecover",1,COVER_UNHIDE,5,7,1);
			
			AI.PushGoal("branch", 1, "DONE", BRANCH_ALWAYS);
--		AI.PushLabel("HANDLE_SOFT");
--			AI.PushGoal("strafe",0,1,2);
--			AI.PushGoal("firecmd",0,1);
--			AI.PushGoal("locate",0,"probtarget");
--			AI.PushGoal("usecover",1,COVER_HIDE,0.5,1,1);
		AI.PushLabel("DONE");
		AI.PushGoal("signal",0,1,"COVER_NORMALATTACK",0);
	AI.EndGoalPipe();

	---------------------------------------------
	AI.BeginGoalPipe("sn_close_combat_group");
		AI.PushGoal("firecmd",0,1);
		AI.PushGoal("run",0,0);
		AI.PushGoal( "branch", 1, "NO_COVER", IF_COVER_COMPROMISED);
			AI.PushGoal("strafe",0,1,2);
			AI.PushGoal("locate",0,"probtarget");

			--AI.PushGoal("usecover",1,COVER_UNHIDE,5,7,1);
			--AI.PushGoal("usecover",1,COVER_HIDE,0.1,0.3,1);
			AI.PushGoal("hide",1,15,HM_NEAREST);
			
			AI.PushGoal("branch", 1, "DONE", BRANCH_ALWAYS);
		AI.PushLabel("NO_COVER");

		AI.PushGoal( "branch", 1, "HIDE", IF_TARGET_OUT_OF_RANGE);

			AI.PushGoal("locate",0,"probtarget");
			AI.PushGoal("adjustaim",0,0,1);
			AI.PushGoal("timeout",1,5,7);
			AI.PushGoal("clear",0,0);
			AI.PushGoal("branch", 1, "DONE", BRANCH_ALWAYS);

		AI.PushLabel("HIDE");
			
			AI.PushGoal("run",0,2,0,25);
			AI.PushGoal("hide",1,15,HM_NEAREST_PREFER_SIDES+HM_INCLUDE_SOFTCOVERS);
			
		AI.PushLabel("DONE");
		AI.PushGoal("signal",0,1,"COVER_NORMALATTACK",0);
	AI.EndGoalPipe();

	---------------------------------------------
	AI.BeginGoalPipe("sn_use_cover_safe");
		AI.PushGoal("firecmd",0,FIREMODE_BURST_WHILE_MOVING);
--		AI.PushGoal("check_cover_fire",1);
		AI.PushGoal("run",0,2,0,20);
		AI.PushGoal( "branch", 1, "DO_HIDE", IF_COVER_SOFT);
		AI.PushGoal( "branch", 1, "SKIP_HIDE", IF_COVER_NOT_COMPROMISED);
		AI.PushLabel("DO_HIDE");
			AI.PushGoal("bodypos",1,BODYPOS_STEALTH);
			AI.PushGoal("strafe",0,1,2);
			AI.PushGoal("hide",1,15,HM_NEAREST);
		AI.PushLabel("SKIP_HIDE");
		
--		AI.PushGoal("locate",0,"probtarget");
--		AI.PushGoal("strafe",0,0,2);
--		AI.PushGoal("run",0,0);
--		AI.PushGoal("usecover",1,COVER_HIDE,1,1.5,1);
--		AI.PushGoal("firecmd",0,1);
--		AI.PushGoal("signal",0,1,"NOTIFY_COVERING",0);
--		AI.PushGoal("usecover",1,COVER_UNHIDE,4,6,1,1);
				
		AI.PushGoal("run",0,0);
		AI.PushGoal("firecmd",0,1);
		AI.PushGoal( "branch", 1, "SKIP_USECOVER", IF_COVER_COMPROMISED);
			AI.PushGoal("locate",0,"probtarget");
			AI.PushGoal("strafe",0,1,2);
			AI.PushGoal("signal",0,1,"NOTIFY_COVERING",0);
			
			--AI.PushGoal("usecover",1,COVER_UNHIDE,5,7,1,1);
			--AI.PushGoal("usecover",1,COVER_HIDE,0.5,1,1);
			AI.PushGoal("hide",1,15,HM_NEAREST);
			
			AI.PushGoal("branch", 1, "END_STANCE", BRANCH_ALWAYS);
		AI.PushLabel("SKIP_USECOVER");
			AI.PushGoal("locate",0,"probtarget");
			AI.PushGoal("adjustaim",0,0,1);
			AI.PushGoal("timeout",1,1.0,2.0);
			AI.PushGoal("clear",0,0);
		AI.PushLabel("DONE");

		AI.PushGoal("signal",0,1,"COVER_NORMALATTACK",0);
	AI.EndGoalPipe();

	---------------------------------------------
	AI.BeginGoalPipe("sn_close_combat");
		AI.PushGoal("firecmd",0,1);
		AI.PushGoal("run",0,1,0,4);
		AI.PushGoal("branch", 1, "NO_COVER", IF_COVER_COMPROMISED);
			AI.PushGoal("strafe",0,1,2);
			AI.PushGoal("locate",0,"probtarget");
			AI.PushGoal("run",0,0);
			
			--AI.PushGoal("usecover",1,COVER_UNHIDE,4,6,1,1);
			--AI.PushGoal("usecover",1,COVER_HIDE,0.5,1,1);
			AI.PushGoal("hide",1,15,HM_NEAREST);
			
			AI.PushGoal("branch", 1, "DONE", BRANCH_ALWAYS);
		AI.PushLabel("NO_COVER");
			AI.PushGoal("locate",0,"probtarget");
			AI.PushGoal("adjustaim",0,0,1);
			AI.PushGoal("timeout",1,3,4);
			AI.PushGoal("clear",0,0);
		AI.PushLabel("DONE");
		AI.PushGoal("signal",0,1,"COVER_NORMALATTACK",0);
	AI.EndGoalPipe();

	---------------------------------------------
	AI.BeginGoalPipe("sn_take_cover_reload");
		AI.PushGoal("firecmd",0,0);
		AI.PushGoal("branch", 1, "SKIP_STAND", IF_EXPOSED_TO_TARGET, 5, 0.15);
			-- Duck
			AI.PushGoal("locate",0,"probtarget");
			AI.PushGoal("+adjustaim",0,1,1); --hide
			AI.PushGoal("timeout",1,0.3);
			AI.PushGoal("branch", 1, "DONE", BRANCH_ALWAYS);
		AI.PushLabel("SKIP_STAND");
			-- Hide & duck
			AI.PushGoal("firecmd",0,0);
			AI.PushGoal("run", 0, 2, 0, 20);
			AI.PushGoal("bodypos",1,BODYPOS_STEALTH);
			AI.PushGoal("strafe",0,1,2);
			AI.PushGoal("locate",0,"probtarget");
			AI.PushGoal("+seekcover", 1, COVER_HIDE, 7.0, 3, 1);
--				AI.PushGoal("+seekcover", 1, COVER_HIDE, 4, 1, 1);
			AI.PushGoal("+adjustaim",0,1,1); --hide
			AI.PushGoal("timeout",1,0.3);
		AI.PushLabel("DONE");
		AI.PushGoal("run",0,0);
		AI.PushGoal("signal",0,1,"HANDLE_RELOAD",0);
	AI.EndGoalPipe();

	---------------------------------------------
	AI.BeginGoalPipe("sn_change_primary_weapon_pause");
		AI.PushGoal("firecmd",0,0);
		AI.PushGoal("locate",0,"probtarget");
		AI.PushGoal("+adjustaim",0,1,1); --hide
		AI.PushGoal("timeout",1,0.1);
		AI.PushGoal("signal",0,1,"SELECT_PRI_WEAPON",0);
		AI.PushGoal("timeout",1,0.3);
		AI.PushGoal("signal",0,1,"PRI_WEAPON_SELECTED",0);
	AI.EndGoalPipe();

	---------------------------------------------
	AI.BeginGoalPipe("sn_reload_pause");
		AI.PushGoal("firecmd",0,0);
		AI.PushGoal("timeout",1,1.3);
		AI.PushGoal("signal",0,1,"RELOAD_PAUSE_DONE",0);
	AI.EndGoalPipe();

	---------------------------------------------
	AI.BeginGoalPipe("cv_backoff_from_tank");
		AI.PushGoal("firecmd",0,0);
		AI.PushGoal("strafe",0,0,0);
		AI.PushGoal("run",0,2);
		AI.PushGoal("+bodypos",0,BODYPOS_STEALTH);
		AI.PushGoal("+backoff",1,15,0,AI_MOVE_TOWARDS_GROUP);
		AI.PushGoal("signal",0,1,"HIDE_DONE",0);
	AI.EndGoalPipe();

	---------------------------------------------
	AI.BeginGoalPipe("cv_hide_from_tank");
		AI.PushGoal("firecmd",0,0);
		AI.PushGoal("run",0,2);
		AI.PushGoal("strafe",0,1,2);
		AI.PushGoal("bodypos",1,BODYPOS_STEALTH);
		AI.PushGoal("hide",1,25,HM_FARTHEST_FROM_TARGET);
		AI.PushGoal("branch", 1, "HIDE_FAILED", IF_CANNOT_HIDE);	
		AI.PushGoal("branch", 1, "SKIP_COVER", IF_TARGET_DIST_LESS, 15);	
			AI.PushGoal("locate",0,"probtarget");
			AI.PushGoal("run",0,0);
			
			--AI.PushGoal("usecover",1,COVER_HIDE,2,3,1);
			AI.PushGoal("hide",1,15,HM_NEAREST);
			
		AI.PushLabel("SKIP_COVER");
			AI.PushGoal("signal",0,1,"HIDE_DONE",0);
			AI.PushGoal("branch", 1, "END", BRANCH_ALWAYS);	
		AI.PushLabel("HIDE_FAILED");
			AI.PushGoal("signal",1,1,"HIDE_FAILED",0);
		AI.PushLabel("END");
	AI.EndGoalPipe();

	---------------------------------------------
	AI.BeginGoalPipe("cv_hide_from_tank_beacon");
		AI.PushGoal("locate",0,"beacon");
		AI.PushGoal("acqtarget",0,"");
		AI.PushGoal("cv_hide_from_tank");
	AI.EndGoalPipe();

	---------------------------------------------
	AI.BeginGoalPipe("cv_cqb_melee");
		AI.PushGoal("melee_far");
		AI.PushGoal("signal",0,1,"HANDLE_RELOAD",0);
	AI.EndGoalPipe();

	---------------------------------------------
	AI.BeginGoalPipe("sn_attack_taunt");
--		AI.PushGoal("firecmd",0,FIREMODE_AIM);
--		AI.PushGoal("timeout",1,1.5,2.5);
		AI.PushGoal("firecmd",0,1);
		AI.PushGoal("signal",0,1,"COMBAT_READABILITY",0);
--		AI.PushGoal("timeout",1,1.0,2.0);
	AI.EndGoalPipe();

	---------------------------------------------
	AI.BeginGoalPipe("sn_look_closer_standby");
		AI.PushGoal("firecmd",0,0);
		AI.PushGoal("bodypos",1,BODYPOS_STEALTH);
		AI.PushGoal("run",0,1,0,4);
		AI.PushGoal("strafe",0,2,2);
--		AI.PushGoal("locate",0,"probtarget_in_territory_and_refshape");
		AI.PushGoal("locate",0,"refpoint");
		AI.PushGoal("+approach",1,3,AILASTOPRES_USE,10.0,"",3);
--		AI.PushGoal("locate",0,"probtarget");
--		AI.PushGoal("+seekcover", 1, COVER_UNHIDE, 7.0, 3, 1);

--		AI.PushGoal("hide",1,10,HM_NEAREST+HM_AROUND_LASTOP+HM_INCLUDE_SOFTCOVERS);
		AI.PushGoal("lookaround",1,45,3,1,2,AI_BREAK_ON_LIVE_TARGET);
		AI.PushGoal("signal",0,1,"APPROACH_DONE",0);
	AI.EndGoalPipe();

	---------------------------------------------
	AI.BeginGoalPipe("sn_wait_and_aim");
		AI.PushGoal("firecmd",0,0);
		AI.PushGoal("adjustaim",0,0,1);
--		AI.PushGoal("clear",0,1);	-- 
		AI.PushGoal("firecmd",0,FIREMODE_AIM);
		AI.PushGoal("lookaround",1,45,3,3,5,AI_BREAK_ON_LIVE_TARGET);
		AI.PushGoal("firecmd",0,0);
		AI.PushGoal("lookaround",1,45,3,3,5,AI_BREAK_ON_LIVE_TARGET);
		AI.PushGoal("signal",0,1,"LOOK_FOR_TARGET",0);
	AI.EndGoalPipe();

	---------------------------------------------
	AI.BeginGoalPipe("stealth_advance");
		AI.PushGoal("firecmd",0,0);
		AI.PushGoal("bodypos",1,BODYPOS_STEALTH);
--		AI.PushGoal("bodypos",1,BODYPOS_STAND);
		AI.PushGoal("run",0,1);
		AI.PushGoal("hide",1,15,HM_NEAREST_TO_TARGET + HM_ON_SIDE);
		AI.PushGoal( "branch", 1, "BE_CROUCHED", IF_CAN_SHOOT_TARGET_CROUCHED);
			AI.PushGoal("bodypos",1,BODYPOS_STAND);
		AI.PushLabel("BE_CROUCHED");
		AI.PushGoal("firecmd",0,FIREMODE_BURST);
		AI.PushGoal("timeout",1,5.1,6.6);		
--		AI.PushGoal("usecover",1,COVER_UNHIDE,25,27,1);
	AI.EndGoalPipe();	
		

	---------------------------------------------
	-- boss suit
	---------------------------------------------
	-- using hide spots
	AI.BeginGoalPipe("sb_advance");
		AI.PushGoal("firecmd",0,FIREMODE_BURST);
--		AI.PushGoal("bodypos",1,BODYPOS_STEALTH);
		AI.PushGoal("bodypos",1,BODYPOS_STAND);
		AI.PushGoal("run",0,1);
		AI.PushGoal("hide",1,15,HM_NEAREST_TO_TARGET + HM_ON_SIDE);
--		AI.PushGoal( "branch", 1, "BE_CROUCHED", IF_CAN_SHOOT_TARGET_CROUCHED);
--			AI.PushGoal("bodypos",1,BODYPOS_STAND);
--		AI.PushLabel("BE_CROUCHED");
		AI.PushGoal("firecmd",0,FIREMODE_BURST);
		AI.PushGoal("timeout",1,6,9.6);
--		AI.PushGoal("usecover",1,COVER_UNHIDE,25,27,1);
		AI.PushGoal("signal",0,1,"COVER_NORMALATTACK",0);
	AI.EndGoalPipe();	

	---------------------------------------------
	AI.BeginGoalPipe("sb_retreat_refpoint");
		AI.PushGoal("firecmd",0,FIREMODE_BURST);
		AI.PushGoal("bodypos",1,BODYPOS_STAND);
		AI.PushGoal("run",0,2);
		AI.PushGoal("strafe",0,0,0);				
		AI.PushGoal("locate",0,"refpoint");
		AI.PushGoal("approach",1,0,AILASTOPRES_USE);
		AI.PushGoal("firecmd",0,FIREMODE_FORCED);
		AI.PushGoal("timeout",1,3,4.6);
		
--		AI.PushGoal("branch", 1, "END", IF_NO_ENEMY_TARGET);
--			AI.PushGoal("firecmd",0,FIREMODE_BURST);		
--			AI.PushGoal("timeout",1,3,4.6);
--			AI.PushGoal("branch", 1, "END", IF_NO_ENEMY_TARGET);
--		AI.PushLabel("END");
		AI.PushGoal("signal",0,1,"COVER_NORMALATTACK",0);
	AI.EndGoalPipe();

	---------------------------------------------
	-- boss - advance to last trget pos
	AI.BeginGoalPipe("sb_advance");
		AI.PushGoal("firecmd",0,FIREMODE_BURST);
		AI.PushGoal("bodypos",1,BODYPOS_STAND);
		AI.PushGoal("run",0,2);
		AI.PushGoal("approach",1,0);
		AI.PushGoal("firecmd",0,FIREMODE_BURST);
		AI.PushGoal("signal",0,1,"COVER_NORMALATTACK",0);
	AI.EndGoalPipe();

	---------------------------------------------
	-- boss - static behavior - using refPoint - move to position
	AI.BeginGoalPipe("sb_static_move");
		AI.PushGoal("firecmd",0,FIREMODE_BURST);
--		AI.PushGoal("bodypos",1,BODYPOS_STEALTH);
		AI.PushGoal("bodypos",1,BODYPOS_STAND);
		AI.PushGoal("run",0,1);
		AI.PushGoal("locate",0,"refpoint");
		AI.PushGoal("approach",1,0,AILASTOPRES_USE);
		AI.PushGoal("firecmd",0,FIREMODE_BURST);
		AI.PushGoal("timeout",1,4.5,6);
		AI.PushGoal("signal",0,1,"TO_ATTACK",0);		
	AI.EndGoalPipe();	


	---------------------------------------------
	-- boss - static behavior - using refPoint
	AI.BeginGoalPipe("sb_static_fire");
		AI.PushGoal("firecmd",0,FIREMODE_BURST);
--		AI.PushGoal("bodypos",1,BODYPOS_STEALTH);
		AI.PushGoal("bodypos",1,BODYPOS_STAND);
		AI.PushGoal("run",0,1);
		AI.PushGoal("locate",0,"refpoint");
		AI.PushGoal("approach",1,0,AILASTOPRES_USE);
		AI.PushGoal("firecmd",0,FIREMODE_BURST);
		AI.PushGoal("timeout",1,4.5,6);
--		AI.PushLabel("FIRE_LOOP");
--			AI.PushGoal("firecmd",0,FIREMODE_BURST);
--		AI.PushGoal("branch", 1, "FIRE_LOOP", NOT + IF_SEES_TARGET);
		AI.PushGoal("signal",0,1,"COVER_NORMALATTACK",0);		
--		AI.PushGoal("branch", 1, "FIRE_LOOP", BRANCH_ALWAYS);		
	AI.EndGoalPipe();	

	---------------------------------------------
	-- boss - static behavior - using refPoint
	AI.BeginGoalPipe("sb_delay_fire");
		AI.PushGoal("firecmd",0,FIREMODE_BURST);
		AI.PushGoal("timeout",1,1.5,2);
		AI.PushGoal("signal",0,1,"COVER_NORMALATTACK",0);		
	AI.EndGoalPipe();	

	---------------------------------------------
	-- boss - close range - back off
	AI.BeginGoalPipe("sb_backoff");
		AI.PushGoal("firecmd",0,1);
		AI.PushGoal("run",0,1);
		AI.PushGoal("strafe",0,15,15);		
		AI.PushGoal("hide",1,15,HM_NEAREST_BACKWARDS,0,0);
		AI.PushGoal("signal",0,1,"COVER_NORMALATTACK",0);
	AI.EndGoalPipe();


	---------------------------------------------
	-- boss - close range
	AI.BeginGoalPipe("sb_close_combat");
		AI.PushGoal("firecmd",0,1);
		AI.PushGoal("run",0,1);
		AI.PushGoal("branch", 1, "NO_COVER", IF_COVER_COMPROMISED);
			AI.PushGoal("strafe",0,1,2);
			AI.PushGoal("locate",0,"probtarget");
			AI.PushGoal("run",0,0);

			--AI.PushGoal("usecover",1,COVER_UNHIDE,7,9,1,1);
			--AI.PushGoal("usecover",1,COVER_HIDE,2,3,1);
			AI.PushGoal("hide",1,15,HM_NEAREST);
			
			AI.PushGoal("branch", 1, "DONE", BRANCH_ALWAYS);
		AI.PushLabel("NO_COVER");

--			AI.PushGoal( "branch", 1, "MAY_CROUCH", IF_TARGET_DIST_GREATER, 7.0);
--				AI.PushGoal("bodypos",1,BODYPOS_STAND);
--				AI.PushGoal("branch", 1, "END_STANCE", BRANCH_ALWAYS);
--			AI.PushLabel("MAY_CROUCH");
--			AI.PushGoal( "branch", 1, "CROUCH", IF_CAN_SHOOT_TARGET_CROUCHED);
--				AI.PushGoal("bodypos",1,BODYPOS_STAND);
--				AI.PushGoal("branch", 1, "END_STANCE", BRANCH_ALWAYS);
--			AI.PushLabel("CROUCH");
--				AI.PushGoal("bodypos",1,BODYPOS_CROUCH);
--			AI.PushLabel("END_STANCE");

			AI.PushGoal("locate",0,"probtarget");
			AI.PushGoal("adjustaim",0,0,1);
			AI.PushGoal("timeout",1,3,4);
			AI.PushGoal("clear",0,0);

		AI.PushLabel("DONE");
		AI.PushGoal("signal",0,1,"COVER_NORMALATTACK",0);
	AI.EndGoalPipe();

	---------------------------------------------
	-- boss - walk up to target, keep shoting
	AI.BeginGoalPipe("sb_press");
		AI.PushGoal("firecmd", 0, FIREMODE_BURST);
		AI.PushGoal("run", 0, 2);
		AI.PushGoal("bodypos", 0, BODYPOS_STAND);
		AI.PushGoal("stick",0,3,0,STICK_BREAK, -1);		
		AI.PushLabel("STICK_LOOP");
			AI.PushGoal("branch", 1, "STICK_RUN", IF_TARGET_DIST_GREATER, 7);
				AI.PushGoal("branch", 1, "STICK_RUN", IF_NO_ENEMY_TARGET);
					AI.PushGoal("run", 0, 0);
					AI.PushGoal("branch", 1, "STICK_LOOP", IF_ACTIVE_GOALS);
					AI.PushGoal("branch", 1, "STICK_END", BRANCH_ALWAYS);
			AI.PushLabel("STICK_RUN");
			AI.PushGoal("run", 0, 2);
		AI.PushGoal("branch", 1, "STICK_LOOP", IF_ACTIVE_GOALS);
		AI.PushLabel("STICK_END");
		AI.PushGoal("clear", 0, 0);	 -- stops approaching - 0 means keep att. target		
		
--		AI.PushGoal("stick",1,5,0,STICK_BREAK, -1);
--		AI.PushGoal("run", 0, 0);
--		AI.PushGoal("stick",1,3,0,STICK_BREAK, -1);
--		AI.PushGoal("clear", 0, 0);	 -- stops approaching - 0 means keep att. target
		AI.PushGoal("timeout", 1, .7, 1.1);
		AI.PushGoal("signal",0,1,"COVER_NORMALATTACK",0);
	AI.EndGoalPipe();

	---------------------------------------------
	-- boss - run to target and do melee. abort if trget moves for more than 2.5m
	AI.BeginGoalPipe("sb_melee_far");
		AI.PushGoal("firecmd", 0, FIREMODE_BURST);
		AI.PushGoal("run", 0, 2);
		AI.PushGoal("bodypos", 0, BODYPOS_STAND);
		-- run up to target, keep firing		
--		AI.PushGoal("stick",0,3,0,STICK_BREAK, -1);
--		AI.PushLabel("STICK_LOOP");
--			AI.PushGoal("branch", 1, "END", IF_TARGET_MOVED_SINCE_START, 2.5);	-- this will check if current weapon has/allows melee
--		-- stop fire, power mode on, keep approaching
--		AI.PushGoal("clear", 0, 0);	 -- stops approaching - 0 means keep att. target		
--		AI.PushGoal("firecmd", 0, FIREMODE_OFF);
--		AI.PushGoal("signal",0,1,"SUIT_POWER",0);
		AI.PushGoal("stick",0,.7,0,STICK_BREAK, -1);
		AI.PushLabel("STICK_LOOP");
			AI.PushGoal("branch", 1, "END", IF_TARGET_MOVED_SINCE_START, 2.5);	-- this will check if current weapon has/allows melee
		AI.PushGoal("branch", 1, "STICK_LOOP", IF_ACTIVE_GOALS);
		AI.PushGoal("clear", 0, 0);	 -- stops approaching - 0 means keep att. target
		AI.PushGoal("firecmd", 0, FIREMODE_OFF);
		AI.PushGoal("firecmd", 1, FIREMODE_MELEE);
		AI.PushGoal("timeout", 1, 0.7);
		AI.PushLabel("END");		
		AI.PushGoal("signal",0,1,"COVER_NORMALATTACK",0);
	AI.EndGoalPipe();

	-- boss suit over
	---------------------------------------------

	AI.BeginGoalPipe("sn_advance_group_PROTO");
		AI.PushGoal("firecmd",0,FIREMODE_BURST_WHILE_MOVING);
		AI.PushGoal("bodypos",0,BODYPOS_STAND);
		AI.PushGoal("run",0,2,0,20);
		AI.PushGoal("strafe",0,2,2);
		AI.PushGoal("locate",0,"refpoint");
		AI.PushGoal("+approach",1,0,AILASTOPRES_USE,4.0);
		AI.PushGoal("signal",0,1,"COVER_NORMALATTACK",0);
	AI.EndGoalPipe();

	---------------------------------------------
	AI.BeginGoalPipe("sn_advance_group_direct_PROTO");
		AI.PushGoal("firecmd",0,FIREMODE_BURST_WHILE_MOVING);
		-- if proning, wait a bit to allow the character to raise before we start moving.
		AI.PushGoal("branch", 1, "WAIT_PRONE", IF_STANCE_IS, BODYPOS_PRONE);	
			AI.PushGoal("bodypos",1,BODYPOS_STAND);
			AI.PushGoal("branch", 1, "STANDING", BRANCH_ALWAYS);
		AI.PushLabel("WAIT_PRONE");
			AI.PushGoal("bodypos",1,BODYPOS_STAND);
			AI.PushGoal("timeout",1,1,1.5);
		AI.PushLabel("STANDING");
		AI.PushGoal("run",0,2,0,25);
		AI.PushGoal("strafe",0,2,2);
		AI.PushGoal( "branch", 1, "LONG_APPROACH", IF_TARGET_DIST_GREATER, 30);
			AI.PushGoal("locate",0,"probtarget_in_territory");
			AI.PushGoal("approach",1,4.5,AILASTOPRES_USE+AI_USE_TIME,10.0);
			AI.PushGoal("branch", 1, "APPROACH_DONE", BRANCH_ALWAYS);
		AI.PushLabel("LONG_APPROACH");
			AI.PushGoal("locate",0,"probtarget_in_territory");
			AI.PushGoal("approach",0,8,AILASTOPRES_USE+AI_USE_TIME,10.0);
		AI.PushLabel("APPROACH_DONE");
		AI.PushGoal("firecmd",0,1);
		AI.PushGoal("run",0,1,0,6);
		AI.PushGoal("hide",1,6,HM_NEAREST_TOWARDS_TARGET_PREFER_SIDES+HM_INCLUDE_SOFTCOVERS,0,0);
		AI.PushGoal("firecmd",0,0);
		AI.PushGoal("signal",0,1,"COVER_NORMALATTACK",0);
	AI.EndGoalPipe();

	---------------------------------------------
	AI.BeginGoalPipe("sn_signal_target_found");
		AI.PushGoal("bodypos",1,BODYPOS_STAND);
		AI.PushGoal("signal",1,1,"reportcontact",SIGNALID_READIBILITY,115);
		AI.PushGoal("animation",1,AIANIM_SIGNAL,"signalFollow");
		AI.PushGoal("signal",1,1,"ENEMYSEEN_FIRST_CONTACT",SIGNALFILTER_GROUPONLY_EXCEPT);
		AI.PushGoal("signal",1,1,"TO_ATTACK",0);
	AI.EndGoalPipe();

	---------------------------------------------
	AI.BeginGoalPipe("cv_signal_advance_left");
		AI.PushGoal("firecmd", 0, 0);
		AI.PushGoal("signal",1,1,"move_command",SIGNALID_READIBILITY,115);
		AI.PushGoal("animation",1,AIANIM_SIGNAL,"signalAdvanceLeft");
		AI.PushGoal("signal",1,1,"COVER_NORMALATTACK",0);
	AI.EndGoalPipe();

	---------------------------------------------
	AI.BeginGoalPipe("cv_signal_advance_right");
		AI.PushGoal("firecmd", 0, 0);
		AI.PushGoal("signal",1,1,"move_command",SIGNALID_READIBILITY,115);
		AI.PushGoal("animation",1,AIANIM_SIGNAL,"signalAdvanceRight");
		AI.PushGoal("signal",1,1,"COVER_NORMALATTACK",0);
	AI.EndGoalPipe();

	---------------------------------------------
	AI.BeginGoalPipe("cv_signal_defend");
		AI.PushGoal("firecmd", 0, 0);
		AI.PushGoal("signal",1,1,"move_command",SIGNALID_READIBILITY,115);
		AI.PushGoal("animation",1,AIANIM_SIGNAL,"signalGetDown");
		AI.PushGoal("signal",1,1,"COVER_NORMALATTACK",0);
	AI.EndGoalPipe();

	---------------------------------------------
	AI.BeginGoalPipe("sn_throw_grenade");
			AI.PushGoal("firecmd", 0, 0);
			AI.PushGoal("branch", 1, "WAIT_PRONE", IF_STANCE_IS, BODYPOS_PRONE);	
				AI.PushGoal("bodypos",1,BODYPOS_STAND);
				AI.PushGoal("branch", 1, "STANDING", BRANCH_ALWAYS);
			AI.PushLabel("WAIT_PRONE");
				AI.PushGoal("bodypos",1,BODYPOS_STAND);
				AI.PushGoal("timeout",1,1,1.5);
			AI.PushLabel("STANDING");
			AI.PushGoal("signal",1,1,"throwing_grenade",SIGNALID_READIBILITY,115);
			AI.PushGoal("timeout",1,0.5);
			AI.PushGoal("firecmd", 0, FIREMODE_SECONDARY);
			AI.PushGoal("timeout",1,2);
			AI.PushGoal("firecmd", 0, 0);
	AI.EndGoalPipe();

	---------------------------------------------
	AI.BeginGoalPipe("sn_throw_grenade_smoke");
			AI.PushGoal("locate", 0, "refpoint" );
			AI.PushGoal("firecmd", 0, 0);
			AI.PushGoal("branch", 1, "WAIT_PRONE", IF_STANCE_IS, BODYPOS_PRONE);	
				AI.PushGoal("bodypos",1,BODYPOS_STAND);
				AI.PushGoal("branch", 1, "STANDING", BRANCH_ALWAYS);
			AI.PushLabel("WAIT_PRONE");
				AI.PushGoal("bodypos",1,BODYPOS_STAND);
				AI.PushGoal("timeout",1,1,1.5);
			AI.PushLabel("STANDING");
			AI.PushGoal("signal",1,1,"throwing_grenade",SIGNALID_READIBILITY,115);
			AI.PushGoal("timeout",1,0.5);
			AI.PushGoal("firecmd", 0, FIREMODE_SECONDARY_SMOKE);
			AI.PushGoal("timeout",1,2);
			AI.PushGoal("firecmd", 0, 0);
			AI.PushGoal("signal",1,1,"GRENADE_FAIL",0);
			AI.PushGoal("timeout",1,2);
	AI.EndGoalPipe();

	---------------------------------------------
	AI.BeginGoalPipe("sn_throw_grenade_done");
			AI.PushGoal("signal",1,1,"REINF_DONE",0);
			AI.PushGoal("timeout",1,2);
	AI.EndGoalPipe();

	---------------------------------------------
	AI.BeginGoalPipe("wtg_signal_target_found_combat");
--		AI.PushGoal("ignoreall",0,1);
		AI.PushGoal("bodypos",1,BODYPOS_STAND);
		AI.PushGoal("signal",1,1,"reportcontact",SIGNALID_READIBILITY,115);
		AI.PushGoal("animation",1,AIANIM_SIGNAL,"signalFollow");
--		AI.PushGoal("ignoreall",0,0);
		AI.PushGoal("signal",1,1,"ENEMYSEEN_DURING_COMBAT",SIGNALFILTER_GROUPONLY_EXCEPT);
		AI.PushGoal("signal",1,1,"TO_WATCH_TOWER_COMBAT",0);
	AI.EndGoalPipe();

	---------------------------------------------
	AI.BeginGoalPipe("wtg_combat");
		AI.PushGoal("bodypos",0,BODYPOS_STEALTH);
		AI.PushGoal("firecmd",0,0);
		AI.PushGoal("approach",1,0.3,AILASTOPRES_USE);
		
		AI.PushGoal("firecmd",0,FIREMODE_BURST_DRAWFIRE);
		AI.PushGoal("locate",0,"probtarget");
		AI.PushGoal("adjustaim",0,0,1);
		AI.PushGoal("timeout",1,5,8);
		AI.PushGoal("clear",0,0);

		AI.PushGoal("bodypos",0,BODYPOS_CROUCH);
		AI.PushGoal("firecmd",0,0);
		AI.PushGoal("timeout",1,1,3);
		
		AI.PushGoal("signal",0,1,"COVER_NORMALATTACK",0);
	AI.EndGoalPipe();

	---------------------------------------------
	AI.BeginGoalPipe("wtg_combat_RPG");
		AI.PushGoal("bodypos",0,BODYPOS_STAND);
--			AI.PushGoal("firecmd",0,0);
		AI.PushGoal("approach",1,0.3,AILASTOPRES_USE);
		
		AI.PushGoal("locate",0,"probtarget");
		AI.PushGoal("adjustaim",0,0,1);
		AI.PushGoal("+firecmd", 0, FIREMODE_CONTINUOUS);
		AI.PushGoal("timeout",1,1.5,1.73);
		AI.PushGoal("branch", 1, "NO_CROUCHED", IF_CAN_SHOOT_TARGET);
			AI.PushGoal("clear",0,0);
			AI.PushGoal("bodypos",0,BODYPOS_CROUCH);
--				AI.PushGoal("signal",0,1,"CHOOSE_WATCH_SPOT_STRAFE",0);
--				AI.PushGoal("backoff",1,2,1,AI_BACKOFF_FROM_TARGET);				
			
			AI.PushGoal("locate",0,"probtarget");
			AI.PushGoal("+seekcover", 1, COVER_UNHIDE, 1.0, 5, 1);

		AI.PushLabel("NO_CROUCHED");
		AI.PushGoal("+waitsignal", 1, "WPN_SHOOT", nil, 2.0 );
		AI.PushGoal("firecmd", 0, FIREMODE_OFF);
--			AI.PushGoal("bodypos",0,BODYPOS_CROUCH);	
		AI.PushGoal("timeout",1,1,1.3);
		AI.PushGoal("clear",0,0);

		AI.PushGoal("signal",0,1,"COVER_NORMALATTACK",0);
	AI.EndGoalPipe();


	---------------------------------------------
	AI.BeginGoalPipe("wtg_combat_no_shot");
		AI.PushGoal("bodypos",0,BODYPOS_CROUCH);
--			AI.PushGoal("firecmd",0,0);
		AI.PushGoal("approach",1,0.3,AILASTOPRES_USE);
	AI.EndGoalPipe();


	---------------------------------------------
	AI.BeginGoalPipe("wtg_combat_close");
		AI.PushGoal("bodypos",0,BODYPOS_STAND);
		
--			AI.PushGoal("approach",1,0.3,AILASTOPRES_USE);
--			AI.PushGoal("locate",0,"probtarget");
--			AI.PushGoal("adjustaim",0,0,1);
		
		AI.PushGoal("firecmd",0,1);
		AI.PushGoal( "branch", 1, "NO_CROUCHED", IF_CAN_SHOOT_TARGET);
			AI.PushGoal("clear",0,0);
			AI.PushGoal("bodypos",0,BODYPOS_CROUCH);
		AI.PushLabel("NO_CROUCHED");
		AI.PushGoal("timeout",1,1.5,4);
--			AI.PushGoal("clear",0,0);
		AI.PushGoal("signal",0,1,"COVER_NORMALATTACK",0);
	AI.EndGoalPipe();

	---------------------------------------------
	AI.BeginGoalPipe("wtg_combat_very_close");
		AI.PushGoal("bodypos",0,BODYPOS_STAND);
		AI.PushGoal("firecmd",0,1);
		AI.PushGoal( "branch", 1, "NO_CROUCHED", NOT+IF_CAN_SHOOT_TARGET);
			AI.PushGoal("bodypos",0,BODYPOS_CROUCH);
		AI.PushLabel("NO_CROUCHED");
		AI.PushGoal("timeout",1,1.5,2);
		AI.PushGoal("signal",0,1,"COVER_NORMALATTACK",0);
	AI.EndGoalPipe();


	---------------------------------------------
	AI.BeginGoalPipe("sn_groupmember_mutilated_reaction");
		AI.PushGoal("firecmd",0,0);
		AI.PushGoal("bodypos",1,BODYPOS_STAND);
		AI.PushGoal("run",0,2,1,10);
		AI.PushGoal("signal",1,1,"ai_down",SIGNALID_READIBILITY,115);
		AI.PushGoal("backoff",1,16,10,AI_MOVE_BACKWARD+AI_MOVE_BACKRIGHT+AI_MOVE_BACKLEFT+AI_MOVE_LEFT+AI_MOVE_RIGHT,4);
		AI.PushGoal("locate",0,"probtarget");
--		AI.PushGoal("+seekcover", 1, COVER_HIDE, 10.0, 3, 1);
--		AI.PushGoal("+adjustaim",0,1,1); --hide
--		AI.PushGoal("timeout",1,0.5,1);
		AI.PushGoal("signal",1,1,"PANIC_DONE",0);
	AI.EndGoalPipe();

	---------------------------------------------
	AI.BeginGoalPipe("sn_panic_left");
		AI.PushGoal("firecmd",0,0);
--			AI.PushGoal("ignoreall",0,1);
		AI.PushGoal("signal",1,1,"surprised",SIGNALID_READIBILITY,115);
		AI.PushGoal("animation", 1, AIANIM_SIGNAL, "fearLeft", 0.6);
--			AI.PushGoal("ignoreall",0,0);
		AI.PushGoal("signal",1,1,"PANIC_DONE",0);
	AI.EndGoalPipe();

	---------------------------------------------
	AI.BeginGoalPipe("sn_panic_right");
		AI.PushGoal("firecmd",0,0);
--			AI.PushGoal("ignoreall",0,1);
		AI.PushGoal("signal",1,1,"surprised",SIGNALID_READIBILITY,115);
		AI.PushGoal("animation", 1, AIANIM_SIGNAL, "fearRight", 0.6);
--			AI.PushGoal("ignoreall",0,0);
		AI.PushGoal("signal",1,1,"PANIC_DONE",0);
	AI.EndGoalPipe();

	---------------------------------------------
	AI.BeginGoalPipe("sn_panic_front");
		AI.PushGoal("firecmd",0,0);
--			AI.PushGoal("ignoreall",0,1);
		AI.PushGoal("signal",1,1,"surprised",SIGNALID_READIBILITY,115);
		--AI.PushGoal("animation", 1, AIANIM_SIGNAL, "fearFront", 0.6);
--			AI.PushGoal("ignoreall",0,0);
		AI.PushGoal("signal",1,1,"PANIC_DONE",0);
	AI.EndGoalPipe();

	---------------------------------------------
	AI.BeginGoalPipe("sn_panic_above");
		AI.PushGoal("firecmd",0,0);
--			AI.PushGoal("ignoreall",0,1);
		AI.PushGoal("signal",1,1,"surprised",SIGNALID_READIBILITY,115);
		AI.PushGoal("animation", 1, AIANIM_SIGNAL, "fearJump", 0.6);
--			AI.PushGoal("ignoreall",0,0);
		AI.PushGoal("signal",1,1,"PANIC_DONE",0);
	AI.EndGoalPipe();

	---------------------------------------------
	AI.BeginGoalPipe("sn_panic_aboveFire");
		AI.PushGoal("firecmd",0,0);
--			AI.PushGoal("ignoreall",0,1);
		AI.PushGoal("signal",1,1,"surprised",SIGNALID_READIBILITY,115);
		AI.PushGoal("animation", 1, AIANIM_ACTION, "fearJumpFire", 0.6);
		AI.PushGoal("timeout",1,0.4);
--		AI.PushGoal("animation", 1, AIANIM_ACTION, "idle", 0.6);
--		AI.PushGoal("firecmd",0, 1);
--		AI.PushGoal("animation", 1, AIANIM_ACTION, "fearFront", 0.6);
		AI.PushGoal("firecmd",0, FIREMODE_PANIC_SPREAD);
		AI.PushGoal("timeout",1,3,4);
		AI.PushGoal("firecmd",0, 1);		
		AI.PushGoal("timeout",1,0.2,0.4);
		AI.PushGoal("animation", 1, AIANIM_ACTION, "idle", 0.6);
--			AI.PushGoal("ignoreall",0,0);
		AI.PushGoal("signal",1,1,"PANIC_DONE",0);
	AI.EndGoalPipe();


	---------------------------------------------
	AI.BeginGoalPipe("sn_flinch_left");
		AI.PushGoal("firecmd",0,0);
		AI.PushGoal("signal",1,1,"surprised",SIGNALID_READIBILITY,115);
		AI.PushGoal("animation", 1, AIANIM_SIGNAL, "fearLeft", 0.6);
		AI.PushGoal("signal",1,1,"PANIC_DONE",0);
	AI.EndGoalPipe();

	---------------------------------------------
	AI.BeginGoalPipe("sn_flinch_right");
		AI.PushGoal("firecmd",0,0);
		AI.PushGoal("signal",1,1,"surprised",SIGNALID_READIBILITY,115);
		AI.PushGoal("animation", 1, AIANIM_SIGNAL, "fearRight", 0.6);
		AI.PushGoal("signal",1,1,"PANIC_DONE",0);
	AI.EndGoalPipe();

	---------------------------------------------
	AI.BeginGoalPipe("sn_flinch_front");
		AI.PushGoal("firecmd",0,0);
		AI.PushGoal("signal",1,1,"surprised",SIGNALID_READIBILITY,115);
		--AI.PushGoal("animation", 1, AIANIM_SIGNAL, "fearFront", 0.6);
		AI.PushGoal("signal",1,1,"PANIC_DONE",0);
	AI.EndGoalPipe();

	---------------------------------------------
	AI.BeginGoalPipe("sn_flinch_above");
		AI.PushGoal("firecmd",0,0);
		AI.PushGoal("signal",1,1,"surprised",SIGNALID_READIBILITY,115);
		AI.PushGoal("animation", 1, AIANIM_SIGNAL, "fearJump", 0.6);
		AI.PushGoal("signal",1,1,"PANIC_DONE",0);
	AI.EndGoalPipe();


	---------------------------------------------
	AI.BeginGoalPipe("sn_target_cloak_reaction");
		AI.PushGoal("signal",1,1,"confused",SIGNALID_READIBILITY,115);

		AI.PushGoal("firecmd",0,0);
		AI.PushGoal("timeout",1,0,0.3);
		
		AI.PushGoal("branch", 1, "DONT_SHOOT", IF_RANDOM, 0.5);
			AI.PushGoal("bodypos",1,BODYPOS_STAND);
		AI.PushLabel("DONT_SHOOT");
			AI.PushGoal("bodypos",1,BODYPOS_STEALTH);
		AI.PushLabel("DONE_SETUP");
		
		AI.PushGoal("firecmd",0, FIREMODE_PANIC_SPREAD);
		AI.PushGoal("timeout",1,1,3);
		AI.PushGoal("firecmd",0,0);
		AI.PushGoal("bodypos",1,BODYPOS_STAND);
		AI.PushGoal("run",0,2,1,10);
		AI.PushGoal("strafe",0,2,0);
		AI.PushGoal("+seekcover", 1, COVER_HIDE, 5.0, 3, 1);
		AI.PushGoal("signal",1,1,"PANIC_DONE",0);
	AI.EndGoalPipe();

	---------------------------------------------
	AI.BeginGoalPipe("sn_flashbang_reaction");
		AI.PushGoal("ignoreall",0,1);
		AI.PushGoal("+firecmd",0,0);
		AI.PushGoal("+bodypos",0,BODYPOS_STAND);
		AI.PushGoal("+signal",1,1,"flashbang_hit",SIGNALID_READIBILITY,115);
		AI.PushGoal("+animation",0,AIANIM_ACTION,"blinded");
		AI.PushGoal("+timeout",1,4,6);
--			AI.PushGoal("+clear",0,1);
		AI.PushGoal("+ignoreall",0,0);
		AI.PushGoal("+signal",0,1,"FLASHBANG_GONE",0);
	AI.EndGoalPipe();

	---------------------------------------------
	AI.BeginGoalPipe("sn_flashbang_reaction_flinch");
		AI.PushGoal("ignoreall",0,1);
		AI.PushGoal("+firecmd",0,0);
		AI.PushGoal("+bodypos",0,BODYPOS_STAND);
		AI.PushGoal("+signal",1,1,"flashbang_hit",SIGNALID_READIBILITY,115);
		AI.PushGoal("+animation",0,AIANIM_SIGNAL,"flinch");
		AI.PushGoal("+timeout",1,2,3);
		AI.PushGoal("+ignoreall",0,0);
		AI.PushGoal("+signal",0,1,"FLASHBANG_GONE",0);
	AI.EndGoalPipe();

	---------------------------------------------
	AI.BeginGoalPipe("sn_near_bullet_reaction");
		AI.PushGoal("firecmd",0,1);
		AI.PushGoal("branch", 1, "SKIP_STAND", IF_EXPOSED_TO_TARGET, 5, 0.15);
			-- Duck
			AI.PushGoal("locate",0,"probtarget");
			AI.PushGoal("bodypos",1,BODYPOS_CROUCH);
--			AI.PushGoal("+adjustaim",0,1,1); --hide
			AI.PushGoal("timeout",1,0.5,1);
			AI.PushGoal("branch", 1, "DONE", BRANCH_ALWAYS);
		AI.PushLabel("SKIP_STAND");
			-- Hide & duck
			AI.PushGoal("firecmd",0,0);
--			AI.PushGoal("run", 0, 2, 1, 10.0);
			AI.PushGoal("run", 0, 1);
			AI.PushGoal("strafe",0,4,4);
			AI.PushGoal("bodypos",1,BODYPOS_STEALTH);
			AI.PushGoal("locate",0,"probtarget");
			AI.PushGoal("+seekcover", 1, COVER_HIDE, 7.0, 3, 1);
--			AI.PushGoal("+adjustaim",0,1,1); --hide
			AI.PushGoal("firecmd",0,1);
			AI.PushGoal("run", 0, 0);
			AI.PushGoal("seekcover", 1, COVER_UNHIDE, 3.0, 2, 1);
--			AI.PushGoal("timeout",1,0,1);
--			AI.PushGoal("timeout",1,0.5,1);
		AI.PushLabel("DONE");
		AI.PushGoal("signal",1,1,"COVER_NORMALATTACK",0);
	AI.EndGoalPipe();

	---------------------------------------------
	AI.BeginGoalPipe("sn_near_bullet_reaction_slow");
		AI.PushGoal("branch", 1, "SKIP_STAND", IF_EXPOSED_TO_TARGET, 5, 0.15);
			-- Duck
			AI.PushGoal("firecmd",0,1);
			AI.PushGoal("locate",0,"probtarget");
			AI.PushGoal("+adjustaim",0,1,1); --hide
			AI.PushGoal("timeout",1,0.5,1);
			AI.PushGoal("branch", 1, "DONE", BRANCH_ALWAYS);
		AI.PushLabel("SKIP_STAND");

			-- Randomly either sprint or run & shoot
--			AI.PushGoal("branch", 1, "DONT_SHOOT", IF_RANDOM, 0.5);
				AI.PushGoal("firecmd",0,1);
				AI.PushGoal("run", 0, 1);
				AI.PushGoal("bodypos",1,BODYPOS_STAND);
				AI.PushGoal("strafe",0,4,4);
--				AI.PushGoal("branch", 1, "DONE_SETUP", BRANCH_ALWAYS);
--			AI.PushLabel("DONT_SHOOT");
--				AI.PushGoal("firecmd",0,0);
--				AI.PushGoal("bodypos",1,BODYPOS_STEALTH);
--				AI.PushGoal("run", 0, 2);
--				AI.PushGoal("strafe",0,1,2);
--			AI.PushLabel("DONE_SETUP");

			-- Hide & duck
			AI.PushGoal("locate",0,"probtarget");
			AI.PushGoal("+seekcover", 1, COVER_HIDE, 6.0, 2, 1);
			AI.PushGoal("timeout",1,0,1);
			AI.PushGoal("seekcover", 1, COVER_UNHIDE, 3.0, 2, 1);
--			AI.PushGoal("+adjustaim",0,1,1); --hide
--			AI.PushGoal("timeout",1,0.5,1);
		AI.PushLabel("DONE");
		AI.PushGoal("signal",1,1,"COVER_NORMALATTACK",0);
	AI.EndGoalPipe();

	---------------------------------------------
	AI.BeginGoalPipe("sn_first_contact_attack");
		AI.PushGoal("firecmd",0,1);
		AI.PushGoal("strafe",0,3,2);
		AI.PushGoal("run", 0, 1);
		AI.PushGoal("bodypos",1,BODYPOS_STAND);
		AI.PushGoal("locate",0,"probtarget");
		AI.PushGoal("+seekcover", 1, COVER_HIDE, 5.0, 2, 1);
		AI.PushGoal("timeout",1,0,1);
		AI.PushGoal("seekcover", 1, COVER_UNHIDE, 3.0, 2, 1);
		AI.PushGoal("signal",1,1,"COVER_NORMALATTACK",0);
	AI.EndGoalPipe();

	---------------------------------------------
	AI.BeginGoalPipe("sn_callreinf_wave");
--		AI.PushGoal("ignoreall",0,1);
--		AI.PushGoal("clear",0,1);
		AI.PushGoal("firecmd",0,0);
		AI.PushGoal("bodypos",0,BODYPOS_STAND);
		AI.PushGoal("run",0,1,0,3);
		
		AI.PushGoal("signal",1,1,"reportcontact",SIGNALID_READIBILITY,120);
		
		AI.PushGoal("locate",0,"refpoint");
		AI.PushGoal("proximity",0,-1,"TARGET_TOO_CLOSE", AIPROX_SIGNAL_ON_OBJ_DISABLE+AIPROX_VISIBLE_TARGET_ONLY);
		
		AI.PushGoal("locate", 0, "refpoint" );
		AI.PushGoal("+animtarget", 0, 0, "callReinforcementsWave", 0.5, 5, 0.5);
		AI.PushGoal("locate", 0, "animtarget" );
		AI.PushGoal("+approach", 1, 0.0, AILASTOPRES_USE );

		AI.PushGoal("clear",0,0); -- stop proximity

		AI.PushGoal("signal",1,1,"calling_for_help",SIGNALID_READIBILITY,120);
		AI.PushGoal("timeout",1,1.25,2);
		AI.PushGoal("signal",1,1,"calling_for_help",SIGNALID_READIBILITY,120);
		AI.PushGoal("timeout",1,1.25,2);

--		AI.PushGoal("ignoreall",0,0);
		AI.PushGoal("signal",1,1,"REINF_DONE",0);
	AI.EndGoalPipe();

	---------------------------------------------
	AI.BeginGoalPipe("sn_callreinf_radio");
--		AI.PushGoal("ignoreall",0,1);
--		AI.PushGoal("clear",0,1);
		AI.PushGoal("firecmd",0,0);
		AI.PushGoal("bodypos",1,BODYPOS_STAND);
		AI.PushGoal("animation",0,AIANIM_ACTION,"callReinforcementShoulderRadio");

		AI.PushGoal("signal",1,1,"radio_reply",SIGNALID_READIBILITY,120);
		AI.PushGoal("timeout",1,1.25,2);
		AI.PushGoal("signal",1,1,"radio_reply",SIGNALID_READIBILITY,120);
		AI.PushGoal("timeout",1,1.25,2);
		
--		AI.PushGoal("ignoreall",0,0);
		AI.PushGoal("signal",1,1,"REINF_DONE",0);
	AI.EndGoalPipe();

	---------------------------------------------
	AI.BeginGoalPipe("sn_callreinf_flare");
		AI.PushGoal("firecmd",0,0);
		AI.PushGoal("bodypos",0,BODYPOS_STAND);
		AI.PushGoal("run",0,1,0,3);

		AI.PushGoal("signal",1,1,"CHOOSE_PISTOL",0);
		AI.PushGoal("timeout",1,0.5);

		AI.PushGoal("locate",0,"refpoint");
		AI.PushGoal("proximity",0,-1,"TARGET_TOO_CLOSE", AIPROX_SIGNAL_ON_OBJ_DISABLE+AIPROX_VISIBLE_TARGET_ONLY);
		
		AI.PushGoal("locate", 0, "refpoint" );
		AI.PushGoal("+animtarget", 0, 0, "callReinforcementFlare", 0.5, 5, 0.5);
		AI.PushGoal("locate", 0, "animtarget" );
		AI.PushGoal("+approach", 1, 0.0, AILASTOPRES_USE );

		AI.PushGoal("clear",0,0); -- stop proximity

		AI.PushGoal("signal",1,1,"calling_for_help",SIGNALID_READIBILITY,120);
		AI.PushGoal("signal",1,1,"DO_FLARE",0);
		AI.PushGoal("timeout",1,1);
		-- stop animation
		AI.PushGoal("animation",0,AIANIM_ACTION,"idle");
		AI.PushGoal("timeout",1,1);

		AI.PushGoal("signal",1,1,"REINF_DONE",0);
	AI.EndGoalPipe();

	---------------------------------------------
	AI.BeginGoalPipe("sn_callreinf_short_hide");
		AI.PushGoal("bodypos",0,BODYPOS_STAND);
		AI.PushGoal("run",0,2,0,10);
		AI.PushGoal("hide",1,10,HM_NEAREST+HM_BACK+HM_INCLUDE_SOFTCOVERS);
		AI.PushGoal("signal",1,1,"SETUP_REINF",0);
	AI.EndGoalPipe();


	------------------------------------------------------------------------------------------
	--
	--	RPG vs TANK related pipes
	--
	AI.BeginGoalPipe("testRPG");
		AI.PushGoal("bodypos",1,BODYPOS_STAND);--BODYPOS_CROUCH);
		AI.PushGoal("timeout",1,1);
		AI.PushGoal("firecmd",0,1);
		AI.PushGoal("timeout",1,6);
		AI.PushGoal("firecmd",0,0);
		AI.PushGoal("signal",0,1,"RPG_ATTACK",0);
	AI.EndGoalPipe();

	---------------------------------------------
	AI.BeginGoalPipe("waitRPG");
--		AI.PushGoal("bodypos",1,BODYPOS_STEALTH);
		AI.PushGoal("firecmd",0,0);		
		AI.PushGoal("timeout",1,2,3);
		AI.PushGoal("signal",0,1,"RPG_ATTACK",0);
	AI.EndGoalPipe();

	---------------------------------------------
	AI.BeginGoalPipe("approachRPG");
		AI.PushGoal("firecmd",0,0);
		AI.PushGoal("bodypos",1,BODYPOS_STEALTH);
		AI.PushGoal("run",0, 2);
		AI.PushGoal("locate",0,"refpoint");
		AI.PushGoal("+approach",1,1,AILASTOPRES_USE);
		AI.PushGoal("signal",0,1,"RPG_ONSPOT",0);
	AI.EndGoalPipe();

	---------------------------------------------
	AI.BeginGoalPipe("fleeRPG");
		AI.PushGoal("firecmd",0,0);
		AI.PushGoal("run",0,3);
		AI.PushGoal("+bodypos",0,BODYPOS_STEALTH);
		AI.PushGoal("+backoff",1,15,0,AI_MOVE_TOWARDS_GROUP);
		AI.PushGoal("signal",0,1,"RPG_ATTACK",0);
	AI.EndGoalPipe();
	--
	--	RPG vs TANK related pipes
	--
	------------------------------------------------------------------------------------------

	---------------------------------------------
	AI.BeginGoalPipe("cv_hide_unknown");
		AI.PushGoal("firecmd",0,FIREMODE_BURST_WHILE_MOVING);
		AI.PushGoal("run", 0, 1,0,1);
		AI.PushGoal("bodypos",1,BODYPOS_STAND, 1);
		AI.PushGoal("firecmd",0,1);
		AI.PushGoal("strafe",0,2,2);

		AI.PushGoal("locate",0,"probtarget");
		AI.PushGoal("+adjustaim",0,1,1,1); --hide

		AI.PushGoal("hide", 1, 15, HM_NEAREST, 0, 3);
		AI.PushGoal("branch", 1, "SKIP_BACKOFF", IF_COVER_NOT_COMPROMISED);
			AI.PushGoal("locate",0,"probtarget");
			AI.PushGoal("+seekcover", 1, COVER_HIDE, 8.0, 3, 1); -- 2=towards refpoint
		AI.PushLabel("SKIP_BACKOFF");
		
		AI.PushGoal("timeout",1,1,2);
		
		AI.PushGoal("signal",1,1,"COVER_NORMALATTACK",0);
	AI.EndGoalPipe();

	---------------------------------------------
	AI.BeginGoalPipe("cv_bullet_reaction");
--		AI.PushGoal("firecmd",0,FIREMODE_BURST_WHILE_MOVING);
		AI.PushGoal("run", 0, 1,0,1);
		AI.PushGoal("bodypos",1,BODYPOS_STAND, 1);
		AI.PushGoal("firecmd",0,1);
		AI.PushGoal("strafe",0,4,4);

		AI.PushGoal("locate",0,"probtarget");
		AI.PushGoal("+adjustaim",0,1,1); --hide

--		AI.PushGoal("hide", 1, 10, HM_NEAREST_TOWARDS_REFPOINT, 0, 3);
--		AI.PushGoal("branch", 1, "SKIP_BACKOFF", IF_COVER_NOT_COMPROMISED);
			AI.PushGoal("locate",0,"probtarget");
			AI.PushGoal("+seekcover", 1, COVER_HIDE, 5.0, 3, 1+2); -- 2=towards refpoint
--		AI.PushLabel("SKIP_BACKOFF");
--		AI.PushGoal("signal",1,1,"HIDE_DONE",0);
--		AI.PushGoal("firecmd",0,1);

--		AI.PushGoal("locate",0,"probtarget");
--		AI.PushGoal("+adjustaim",0,1,1); --hide

		AI.PushGoal("timeout",1,0.3,0.7);
		AI.PushGoal("signal",1,1,"COVER_NORMALATTACK",0);
	AI.EndGoalPipe();

	---------------------------------------------
	AI.BeginGoalPipe("cv_advance");
--		AI.PushGoal("firecmd",0,FIREMODE_BURST_WHILE_MOVING);
		AI.PushGoal("firecmd",0,1);
		AI.PushGoal("strafe",0,4,4,1);
		AI.PushGoal("run",0,1);
		AI.PushGoal("bodypos",1,BODYPOS_STAND, 1);

		AI.PushGoal("hide", 1, 17, HM_NEAREST_TOWARDS_REFPOINT+HM_INCLUDE_SOFTCOVERS, 0, 3);
		
		AI.PushGoal("branch", 1, "HIDE_OK", IF_COVER_NOT_COMPROMISED);
			AI.PushGoal("branch", 1, "INDOOR", IF_NAV_WAYPOINT_HUMAN);
				AI.PushGoal("locate",0,"refpoint");
				AI.PushGoal("+approach",1,-18,AILASTOPRES_USE+AI_REQUEST_PARTIAL_PATH,15,"",8);
--				AI.PushGoal("+movetowards",1,12);
				AI.PushGoal( "branch", 1, "HIDE_OK", BRANCH_ALWAYS);
			AI.PushLabel("INDOOR");
				AI.PushGoal("locate",0,"refpoint");
				AI.PushGoal("+approach",1,-6,AILASTOPRES_USE+AI_REQUEST_PARTIAL_PATH,15,"",3);
				--AI.PushGoal("+movetowards",1,5);
			AI.PushGoal("firecmd",0,1);
			-- shorter pause if not in cover
--			AI.PushGoal("locate",0,"probtarget");
--			AI.PushGoal("+adjustaim",0,0,1);
--			AI.PushGoal("timeout",1,1.5,3);
--			AI.PushGoal( "branch", 1, "SKIP_SHOOT", BRANCH_ALWAYS);

		AI.PushLabel("HIDE_OK");
		AI.PushGoal("branch", 1, "SKIP_SHOOT", IF_TARGET_OUT_OF_RANGE);
		AI.PushGoal("branch", 1, "SKIP_SHOOT", IF_TARGET_LOST_TIME_MORE, 5.0);

		AI.PushGoal("run", 0, 0);

		AI.PushGoal("locate",0,"probtarget");
		AI.PushGoal("+adjustaim",0,0,1);

		AI.PushGoal("branch", 1, "SKIP_UNHIDE1", IF_SEES_TARGET, 20.0);
			AI.PushGoal("locate",0,"probtarget");
			AI.PushGoal("+seekcover", 1, COVER_UNHIDE, 5.0, 2, 1+2); -- 2=towards refpoint
		AI.PushLabel("SKIP_UNHIDE1");
		AI.PushGoal("timeout",1,0.6,1);

		AI.PushGoal("branch", 1, "SKIP_SHOOT", IF_TARGET_LOST_TIME_MORE, 5.0);

		AI.PushGoal("branch", 1, "SKIP_UNHIDE2", IF_SEES_TARGET, 20.0);
			AI.PushGoal("locate",0,"probtarget");
			AI.PushGoal("+seekcover", 1, COVER_UNHIDE, 4.0, 2, 1+2); -- 2=towards refpoint
		AI.PushLabel("SKIP_UNHIDE2");
		AI.PushGoal("timeout",1,0.6,1);

		AI.PushLabel("SKIP_SHOOT");
		AI.PushGoal("signal",1,1,"COVER_NORMALATTACK",0);
	AI.EndGoalPipe();

	---------------------------------------------
	AI.BeginGoalPipe("cv_cohesion");
		AI.PushGoal("firecmd",0,FIREMODE_BURST_WHILE_MOVING);
		AI.PushGoal("strafe",0,4,2);
		AI.PushGoal("run",0,2,0,10);
		AI.PushGoal("bodypos",1,BODYPOS_STAND, 1);
		AI.PushGoal("locate",0,"refpoint");
		AI.PushGoal("+approach",1,-25,AILASTOPRES_USE+AI_REQUEST_PARTIAL_PATH,15,"",5);
		AI.PushGoal("signal",1,1,"COVER_NORMALATTACK",0);
	AI.EndGoalPipe();

	---------------------------------------------
	AI.BeginGoalPipe("cm_defend");
		AI.PushGoal("firecmd",0,FIREMODE_BURST_WHILE_MOVING);
		AI.PushGoal("strafe",0,2,6,1);
		AI.PushGoal("run",0,2,0,10);
		AI.PushGoal("bodypos",1,BODYPOS_STAND, 1);
		AI.PushGoal("branch", 1, "HIDE_OK", IF_COVER_NOT_COMPROMISED);
			AI.PushGoal("hide", 1, 17, HM_NEAREST,0,5);
			AI.PushGoal("branch", 1, "HIDE_OK", IF_COVER_NOT_COMPROMISED);
				AI.PushGoal("locate",0,"refpoint");
				AI.PushGoal("+approach",1,-10,AILASTOPRES_USE+AI_REQUEST_PARTIAL_PATH,15,"",4);

		AI.PushLabel("HIDE_OK");
		AI.PushGoal("firecmd",0,1);
		AI.PushGoal("run", 0, 0);
		
		AI.PushGoal("branch", 1, "TARGET_OK", IF_TARGET_IN_RANGE);
			-- target out of range, keep hiding
			AI.PushGoal("locate",0,"probtarget");
			AI.PushGoal("+adjustaim",0,1,1); --hide
			AI.PushGoal("+seekcover", 1, COVER_HIDE, 3.0, 2, 1);
			AI.PushGoal("timeout",1,0.5);
			AI.PushGoal("clear",0,0); -- kill adjustaim
			AI.PushGoal("branch", 1, "SKIP_SHOOT", BRANCH_ALWAYS);
		AI.PushLabel("TARGET_OK");

		AI.PushGoal("locate",0,"probtarget");
		AI.PushGoal("+adjustaim",0,0,1);
		
		-- target in range, shoot
--		AI.PushGoal("bodypos",1,BODYPOS_STAND, 1);
		AI.PushGoal("branch", 1, "SKIP_UNHIDE", IF_TARGET_LOST_TIME_LESS, 1.0);
			AI.PushGoal("locate",0,"probtarget");
			AI.PushGoal("+seekcover", 1, COVER_UNHIDE, 5.0, 2, 1);
		AI.PushLabel("SKIP_UNHIDE");
		AI.PushGoal("timeout",1,0.7,1.5);

--		AI.PushGoal("bodypos",1,BODYPOS_STAND, 1);
		AI.PushGoal("branch", 1, "SKIP_UNHIDE2", IF_TARGET_LOST_TIME_LESS, 1.0);
			AI.PushGoal("locate",0,"probtarget");
			AI.PushGoal("+seekcover", 1, COVER_UNHIDE, 3.0, 2, 1);
		AI.PushLabel("SKIP_UNHIDE2");
		AI.PushGoal("timeout",1,0.7,1.5);

		AI.PushLabel("SKIP_SHOOT");
		
		AI.PushGoal("signal",1,1,"COVER_NORMALATTACK",0);
	AI.EndGoalPipe();

	---------------------------------------------
	AI.BeginGoalPipe("cv_seek");

		AI.PushGoal("branch", 1, "SETUP_SLOW", IF_TARGET_DIST_LESS, 15.0);
			AI.PushGoal("run",0,1);
			AI.PushGoal("bodypos",1,BODYPOS_STAND, 1);
			AI.PushGoal("firecmd",0,0);
			AI.PushGoal("strafe",0,2,2);
			AI.PushGoal("firecmd",0,FIREMODE_AIM);
			AI.PushGoal("branch", 1, "SETUP_DONE", BRANCH_ALWAYS);
		AI.PushLabel("SETUP_SLOW");
			AI.PushGoal("run",0,0);
			AI.PushGoal("bodypos",1,BODYPOS_STEALTH, 1);
			AI.PushGoal("firecmd",0,FIREMODE_AIM);
			AI.PushGoal("strafe",0,4,4);
			AI.PushGoal("locate",0,"refpoint");
			AI.PushGoal("+lookat",0,0,0,1);
		AI.PushLabel("SETUP_DONE");

		AI.PushGoal("branch", 1, "APPROACH_FAR", IF_TARGET_DIST_LESS, 30.0);
			-- move to group pos 
			AI.PushGoal("locate",0,"refpoint");
			AI.PushGoal("+approach",1,-15,AILASTOPRES_USE,15,"",8);
			AI.PushGoal("branch", 1, "APPROACH_DONE", BRANCH_ALWAYS);
		AI.PushLabel("APPROACH_FAR");
			-- move closer to target
			AI.PushGoal("locate",0,"probtarget");
			AI.PushGoal("+approach",1,29,AILASTOPRES_USE,15,"",10);
		AI.PushLabel("APPROACH_DONE");

		AI.PushGoal("branch", 1, "SKIP_UNHIDE", IF_SEES_TARGET, 20.0);
			AI.PushGoal("locate",0,"probtarget");
			AI.PushGoal("+seekcover", 1, COVER_UNHIDE, 3.0, 2, 1);
		AI.PushLabel("SKIP_UNHIDE");

--		AI.PushGoal("clear",0,0); -- kill lookat

		AI.PushGoal("signal",1,1,"COVER_NORMALATTACK",0);
	AI.EndGoalPipe();

	---------------------------------------------
	AI.BeginGoalPipe("cv_seek_direct");
		AI.PushGoal("run",0,1);
		AI.PushGoal("bodypos",1,BODYPOS_STAND, 1);
		AI.PushGoal("firecmd",0,0);
		AI.PushGoal("strafe",0,2,2,1);
		AI.PushGoal("approach",1,10,0,15,"",3);

		AI.PushGoal("run",0,0);
		AI.PushGoal("bodypos",1,BODYPOS_STEALTH, 1);
		AI.PushGoal("firecmd",0,FIREMODE_AIM);
		AI.PushGoal("strafe",0,4,4,1);
		AI.PushGoal("approach",1,2,0,15,"",2);

		AI.PushGoal("locate",0,"probtarget");
		AI.PushGoal("+seekcover", 1, COVER_UNHIDE, 3.0, 2, 1);

		AI.PushGoal("signal",1,1,"SEEK_DIRECT_DONE",0);
	AI.EndGoalPipe();


	---------------------------------------------
	AI.BeginGoalPipe("cv_seek_defend");
		AI.PushGoal("firecmd",0,FIREMODE_BURST_WHILE_MOVING);
		AI.PushGoal("strafe",0,4,4);
		AI.PushGoal("run",0,1,0,16);
		AI.PushGoal("bodypos",1,BODYPOS_STAND, 1);
		AI.PushGoal("locate",0,"refpoint");
		AI.PushGoal("+approach",1,-15,AILASTOPRES_USE+AI_REQUEST_PARTIAL_PATH,15,"",7);
--		AI.PushGoal("locate",0,"probtarget");
--		AI.PushGoal("+adjustaim",0,0,1);
--		AI.PushGoal("timeout",1,0.5,2);

--		AI.PushGoal("strafe",0,2,2,1);
--		AI.PushGoal("run",0,1,0,6);
--		AI.PushGoal("bodypos",1,BODYPOS_STAND, 1);
--		AI.PushGoal("branch", 1, "HIDE_OK", IF_COVER_NOT_COMPROMISED);
--			AI.PushGoal("locate",0,"refpoint");
--			AI.PushGoal("hide", 1, 10, HM_NEAREST+HM_AROUND_LASTOP+HM_INCLUDE_SOFTCOVERS);
--		AI.PushLabel("HIDE_OK");

		AI.PushGoal("run", 0, 0);
		AI.PushGoal("firecmd",0,1);
		AI.PushGoal("locate",0,"probtarget");
		AI.PushGoal("+adjustaim",0,0,1);
		AI.PushGoal("locate",0,"probtarget");
		AI.PushGoal("+seekcover", 1, COVER_UNHIDE, 3.0, 2, 1);
		AI.PushGoal("timeout",1,2,3);
		AI.PushGoal("signal",1,1,"COVER_NORMALATTACK",0);
	AI.EndGoalPipe();

	---------------------------------------------
	AI.BeginGoalPipe("cm_seek_retreat");
		AI.PushGoal("firecmd",0,0);
		AI.PushGoal("strafe",0,2,2);
		AI.PushGoal("run",0,1);
		AI.PushGoal("bodypos",1,BODYPOS_STAND, 1);

		AI.PushGoal("hide", 1, 17, HM_NEAREST_TOWARDS_REFPOINT+HM_INCLUDE_SOFTCOVERS, 0, 3);
		
		AI.PushGoal("branch", 1, "HIDE_OK", IF_COVER_NOT_COMPROMISED);
			AI.PushGoal("branch", 1, "INDOOR", IF_NAV_WAYPOINT_HUMAN);
				AI.PushGoal("locate",0,"refpoint");
				AI.PushGoal("+approach",1,-15,AILASTOPRES_USE+AI_REQUEST_PARTIAL_PATH,15,"",7);
				AI.PushGoal( "branch", 1, "HIDE_OK", BRANCH_ALWAYS);
			AI.PushLabel("INDOOR");
				AI.PushGoal("locate",0,"refpoint");
				AI.PushGoal("+approach",1,-6,AILASTOPRES_USE+AI_REQUEST_PARTIAL_PATH,15,"",3);
			AI.PushGoal("firecmd",0,1);

		AI.PushGoal("run", 0, 0);
		AI.PushLabel("HIDE_OK");

		AI.PushGoal("firecmd",0,1);
		AI.PushGoal("locate",0,"probtarget");
		AI.PushGoal("+adjustaim",0,0,1);
		AI.PushGoal("timeout",1,0.5,3);
		AI.PushGoal("signal",1,1,"COVER_NORMALATTACK",0);
	AI.EndGoalPipe();



	---------------------------------------------
	AI.BeginGoalPipe("su_sniper");

		AI.PushGoal("signal",0,1,"SET_REFPOINT_SNIPER",0);
		AI.PushGoal("signal",0,1,"SUIT_ARMOR_MODE",0);

		-- shoot
		AI.PushGoal("firecmd",0,FIREMODE_AIM);	--warm up
		AI.PushGoal("timeout",1,0.1);

		AI.PushGoal("firecmd",0,FIREMODE_BURST_SNIPE);
		AI.PushGoal("signal",0,1,"SETUP_SNIPER",0);

		AI.PushGoal("bodypos",0,BODYPOS_STAND,1);
		AI.PushGoal("strafe",0,2,4);
		AI.PushGoal("run",0,0);
		AI.PushGoal("locate",0,"refpoint");
		AI.PushGoal("+seekcover", 1, COVER_UNHIDE, 4.0, 3, 1+2);

		AI.PushGoal("locate",0,"probtarget");
		AI.PushGoal("+adjustaim",0,0,1);
		AI.PushGoal("timeout",1,5,8);

		-- move
		AI.PushGoal("signal",0,1,"UNDO_SNIPER",0);

		AI.PushGoal("firecmd",0,0);

		AI.PushGoal("strafe",0,2,2);
		AI.PushGoal("run",0,1);
		AI.PushGoal("bodypos",0,BODYPOS_STAND,1);
--		AI.PushGoal("hide", 1, 22, HM_NEAREST_TOWARDS_REFPOINT, 0, 4);
--		AI.PushGoal("branch", 1, "HIDE_OK", IF_LASTOP_SUCCEED);
			AI.PushGoal("locate",0,"refpoint");
			AI.PushGoal("+movetowards",1,15);
--		AI.PushLabel("HIDE_OK");

		AI.PushGoal("signal",0,1,"COVER_NORMALATTACK",0);
	AI.EndGoalPipe();


	---------------------------------------------
	AI.BeginGoalPipe("su_sniper_stunt");

		AI.PushGoal("signal",0,1,"UNDO_SNIPER",0);
		AI.PushGoal("signal",0,1,"SUIT_STRENGTH_MODE",0);

		AI.PushGoal("strafe",0,2,2);
		AI.PushGoal("run",0,2,0,15);
		AI.PushGoal("bodypos",0,BODYPOS_STAND,1);
		-- move to stunt pos
		AI.PushGoal("locate",0,"refpoint");
		AI.PushGoal("+approach",1,2,AILASTOPRES_USE);

		-- shoot
		AI.PushGoal("signal",0,1,"SET_REFPOINT_SNIPER",0);
		
		AI.PushGoal("firecmd",0,FIREMODE_AIM);	--warm up
		AI.PushGoal("timeout",1,0.1);

		AI.PushGoal("firecmd",0,FIREMODE_BURST_SNIPE);
		AI.PushGoal("signal",0,1,"SETUP_SNIPER",0);

--		AI.PushGoal("bodypos",0,BODYPOS_STAND,1);
--		AI.PushGoal("strafe",0,2,4);
--		AI.PushGoal("run",0,0);
--		AI.PushGoal("locate",0,"refpoint");
--		AI.PushGoal("+seekcover", 1, COVER_UNHIDE, 4.0, 3, 1+2);

		AI.PushGoal("locate",0,"probtarget");
		AI.PushGoal("+adjustaim",0,0,1);
		AI.PushGoal("timeout",1,5,8);

		AI.PushGoal("signal",0,1,"UNDO_SNIPER",0);

		AI.PushGoal("signal",0,1,"COVER_NORMALATTACK",0);
	AI.EndGoalPipe();



	---------------------------------------------
	AI.BeginGoalPipe("su_sniper_move");

		-- move
		AI.PushGoal("signal",0,1,"SET_REFPOINT_SNIPER",0);
		AI.PushGoal("signal",0,1,"UNDO_SNIPER",0);
		AI.PushGoal("signal",0,1,"SUIT_ARMOR_MODE",0);

		AI.PushGoal("firecmd",0,0);

		AI.PushGoal("strafe",0,2,2);
		AI.PushGoal("run",0,2);
		AI.PushGoal("bodypos",0,BODYPOS_STAND,1);
		AI.PushGoal("hide", 1, 12, HM_NEAREST_TOWARDS_REFPOINT, 0, 4);
		AI.PushGoal("branch", 1, "HIDE_OK", IF_LASTOP_FAILED);
			AI.PushGoal("locate",0,"refpoint");
			AI.PushGoal("+movetowards",1,10);
			AI.PushGoal("branch", 1, "DONE", BRANCH_ALWAYS);
		AI.PushLabel("HIDE_OK");
			AI.PushGoal("locate",0,"refpoint");
			AI.PushGoal("+movetowards",1,15);
		AI.PushLabel("DONE");

		AI.PushGoal("signal",0,1,"COVER_NORMALATTACK",0);
	AI.EndGoalPipe();

	---------------------------------------------
	AI.BeginGoalPipe("su_protect_spot_move");

		AI.PushGoal("signal",0,1,"SETUP_PISTOL",0);

		AI.PushGoal("signal",0,1,"SET_REFPOINT_PROTECT",0);

		-- shoot
		AI.PushGoal("firecmd",0,FIREMODE_BURST);

		AI.PushGoal("bodypos",0,BODYPOS_STAND,1);
		AI.PushGoal("strafe",0,2,4);
		AI.PushGoal("run",0,0);
		AI.PushGoal("locate",0,"refpoint");
		AI.PushGoal("+seekcover", 1, COVER_UNHIDE, 4.0, 2, 1+2);

		-- move

		AI.PushGoal("firecmd",0,FIREMODE_BURST_WHILE_MOVING);

		AI.PushGoal("strafe",0,2,2);
		AI.PushGoal("run",0,2,1,12);
		AI.PushGoal("bodypos",0,BODYPOS_STAND,1);
--		AI.PushGoal("hide", 1, 17, HM_NEAREST_TOWARDS_REFPOINT, 0, 8);
--		AI.PushGoal("branch", 1, "HIDE_OK", IF_LASTOP_SUCCEED);
			AI.PushGoal("locate",0,"refpoint");
			AI.PushGoal("+movetowards",1,15);
--		AI.PushLabel("HIDE_OK");

		AI.PushGoal("signal",0,1,"COVER_NORMALATTACK",0);
	AI.EndGoalPipe();


	---------------------------------------------
	AI.BeginGoalPipe("su_protect_spot_defend");

		AI.PushGoal("signal",0,1,"SETUP_PISTOL",0);

		AI.PushGoal("signal",0,1,"SET_REFPOINT_PROTECT",0);

		-- shoot
		AI.PushGoal("firecmd",0,FIREMODE_BURST);

		AI.PushGoal("bodypos",0,BODYPOS_STAND,1);
		AI.PushGoal("strafe",0,2,4);
		AI.PushGoal("run",0,0);
		AI.PushGoal("locate",0,"refpoint");
		AI.PushGoal("+seekcover", 1, COVER_UNHIDE, 4.0, 2, 1+2);

		AI.PushGoal("locate",0,"probtarget");
		AI.PushGoal("+adjustaim",0,0,1);
		AI.PushGoal("timeout",1,4,6);

		-- move
		AI.PushGoal("firecmd",0,FIREMODE_BURST_WHILE_MOVING);

		AI.PushGoal("strafe",0,2,2);
		AI.PushGoal("run",0,1,0,7);
		AI.PushGoal("bodypos",0,BODYPOS_STAND,1);
		AI.PushGoal("locate",0,"refpoint");
		AI.PushGoal("+hide", 1, 15, HM_NEAREST+HM_AROUND_LASTOP+HM_INCLUDE_SOFTCOVERS, 0, 5);

		AI.PushGoal("signal",0,1,"COVER_NORMALATTACK",0);
	AI.EndGoalPipe();

	---------------------------------------------
	AI.BeginGoalPipe("su_protect_bullet_reaction");
		AI.PushGoal("signal",0,1,"SETUP_PISTOL",0);
		AI.PushGoal("firecmd",0,FIREMODE_BURST_WHILE_MOVING);
		AI.PushGoal("run", 0, 2,1,6);
		AI.PushGoal("bodypos",1,BODYPOS_STAND, 1);
		AI.PushGoal("strafe",0,4,2);
		AI.PushGoal("signal",0,1,"SET_REFPOINT_PROTECT",0);
		AI.PushGoal("hide", 1, 10, HM_NEAREST_TOWARDS_REFPOINT, 0, 3);
		AI.PushGoal("branch", 1, "SKIP_SEEK", IF_LASTOP_SUCCEED);
			AI.PushGoal("locate",0,"probtarget");
			AI.PushGoal("+seekcover", 1, COVER_HIDE, 7.0, 3, 1+2); -- 2=towards refpoint
		AI.PushLabel("SKIP_SEEK");
		AI.PushGoal("firecmd",0,1);
		AI.PushGoal("locate",0,"probtarget");
		AI.PushGoal("+adjustaim",0,1,1); --hide
		AI.PushGoal("timeout",1,0.6,1.5);
		AI.PushGoal("signal",1,1,"COVER_NORMALATTACK",0);
	AI.EndGoalPipe();


	---------------------------------------------
	AI.BeginGoalPipe("su_fast_bullet_reaction");
		AI.PushGoal("bodypos",1,BODYPOS_STAND,1);
		AI.PushGoal("strafe",0,100,100);
		AI.PushGoal("firecmd",0,FIREMODE_BURST_DRAWFIRE);
		AI.PushGoal("locate",0,"probtarget");
		AI.PushGoal("+seekcover", 1, COVER_HIDE, 3.0, 2, 1);
		AI.PushGoal("signal",1,1,"COVER_NORMALATTACK",0);
	AI.EndGoalPipe();

	---------------------------------------------
	AI.BeginGoalPipe("su_fast_threat_reaction");
		AI.PushGoal("signal",0,1,"SUIT_ARMOR_MODE",0);
		AI.PushGoal("firecmd",0,0);
		AI.PushGoal("run", 0, 0);
		AI.PushGoal("bodypos",1,BODYPOS_CROUCH);
		AI.PushGoal("strafe",0,0,0);
		AI.PushGoal("timeout",1,2,3);
		AI.PushGoal("strafe",0,100,100);
		AI.PushGoal("bodypos",1,BODYPOS_STAND,1);
		AI.PushGoal("firecmd",0,FIREMODE_AIM);
		AI.PushGoal("locate",0,"probtarget");
		AI.PushGoal("+seekcover", 1, COVER_HIDE, 3.0, 2, 1);
		AI.PushGoal("signal",1,1,"COVER_NORMALATTACK",0);
	AI.EndGoalPipe();

	---------------------------------------------
	AI.BeginGoalPipe("su_fast_threatened_sniper");
		AI.PushGoal("signal",0,1,"SETUP_SNIPER",0);
		AI.PushGoal("strafe",0,100,100);
		AI.PushGoal("bodypos",0,BODYPOS_STAND,1);
		AI.PushGoal("run",0,0);
		AI.PushGoal("firecmd",0,FIREMODE_AIM_SWEEP);
		AI.PushGoal("timeout",1,1,2);
		AI.PushGoal("signal",0,1,"INVESTIGATE_READABILITY",0);
		AI.PushGoal("signal",0,1,"SET_REFPOINT_SNIPER",0);
		AI.PushGoal("+locate", 0,"refpoint");
		AI.PushGoal("+movetowards",1,10);
	AI.EndGoalPipe();

	---------------------------------------------
	AI.BeginGoalPipe("su_fast_threatened");
		AI.PushGoal("signal",0,1,"UNDO_SNIPER",0);
		AI.PushGoal("signal",0,1,"SUIT_CLOAK_MODE",0);
		AI.PushGoal("strafe",0,100,100);
		AI.PushGoal("bodypos",0,BODYPOS_STAND,1);
		AI.PushGoal("run",0,1,0,5);
		AI.PushGoal("firecmd",0,FIREMODE_AIM_SWEEP);
--		AI.PushGoal("timeout",1,1,2);
		AI.PushGoal("signal",0,1,"INVESTIGATE_READABILITY",0);
		AI.PushGoal("signal",0,1,"SET_REFPOINT_SEEK",0);
		AI.PushGoal("+locate", 0,"refpoint");
		AI.PushGoal("+movetowards",1,15);
		--AI.PushGoal("+approach",1,-10,AILASTOPRES_USE,15.0);
		AI.PushGoal("signal",0,1,"SETUP_SNIPER",0);
		AI.PushGoal("firecmd",0,FIREMODE_AIM_SWEEP);
		AI.PushGoal("timeout",1,2,3);
	AI.EndGoalPipe();

	---------------------------------------------
	AI.BeginGoalPipe("su_threat_reaction");
		AI.PushGoal("firecmd",0,0);
		AI.PushGoal("run", 0, 0);
		AI.PushGoal("bodypos",1,BODYPOS_CROUCH);
		AI.PushGoal("strafe",0,0,0);
		AI.PushGoal("timeout",1,2,3);
		AI.PushGoal("strafe",0,100,100);
		AI.PushGoal("bodypos",1,BODYPOS_STAND,1);
		AI.PushGoal("firecmd",0,FIREMODE_AIM);
		AI.PushGoal("locate",0,"probtarget");
		AI.PushGoal("+seekcover", 1, COVER_HIDE, 3.0, 2, 1);
		AI.PushGoal("signal",1,1,"COVER_NORMALATTACK",0);
	AI.EndGoalPipe();

	---------------------------------------------
	AI.BeginGoalPipe("su_idle");
		AI.PushGoal("bodypos",0,BODYPOS_STAND);
		AI.PushGoal("run",0,0);
		AI.PushGoal("firecmd",0,FIREMODE_AIM);
--			AI.PushGoal("lookaround",1,60,4,6,10,AI_BREAK_ON_LIVE_TARGET);
	AI.EndGoalPipe();

	---------------------------------------------
	AI.BeginGoalPipe("su_threatened");
		AI.PushGoal("strafe",0,100,100);
		AI.PushGoal("bodypos",0,BODYPOS_STAND);
		AI.PushGoal("run",0,0);
		AI.PushGoal("firecmd",0,FIREMODE_AIM_SWEEP);
--			AI.PushGoal("lookaround",0,30,3,100,100,AI_BREAK_ON_LIVE_TARGET);
		AI.PushGoal("locate", 0,"probtarget_in_territory");
		AI.PushGoal("+approach",1,-20,AILASTOPRES_USE,15.0);
		AI.PushGoal("firecmd",0,FIREMODE_AIM_SWEEP);
		AI.PushGoal("signal",0,1,"INVESTIGATE_READABILITY",0);
		AI.PushGoal("timeout",1,1,3);
--		AI.PushGoal("lookaround",1,60,2,4,2,AI_BREAK_ON_LIVE_TARGET);
		AI.PushGoal("signal",0,1,"INVESTIGATE_READABILITY",0);
	AI.EndGoalPipe();

	---------------------------------------------
	AI.BeginGoalPipe("su_attack_move");
		AI.PushGoal("firecmd",0,0);
		AI.PushGoal("timeout",1,0.3);
		AI.PushGoal("strafe",0,100,100);
		AI.PushGoal("bodypos",0,BODYPOS_STAND,1);
		AI.PushGoal("run",0,0);
		AI.PushGoal("firecmd",0,0);
		AI.PushGoal("locate", 0,"probtarget_in_territory");
		AI.PushGoal("+approach",1,-15,AILASTOPRES_USE,15.0);

		AI.PushGoal("branch", 1, "SKIP_UNHIDE", IF_SEES_TARGET, 20.0);
			AI.PushGoal("locate",0,"probtarget");
			AI.PushGoal("+seekcover", 1, COVER_UNHIDE, 3.0, 2, 1);
		AI.PushLabel("SKIP_UNHIDE");

		AI.PushGoal("signal",0,1,"COVER_NORMALATTACK",0);
	AI.EndGoalPipe();

	---------------------------------------------
	AI.BeginGoalPipe("su_attack_stand");
		AI.PushGoal("bodypos",0,BODYPOS_STAND);
		AI.PushGoal("firecmd",0,FIREMODE_BURST_DRAWFIRE); --_DRAWFIRE);
		AI.PushGoal("timeout",1,3,5);
		AI.PushGoal("signal",0,1,"COVER_NORMALATTACK",0);
	AI.EndGoalPipe();

	---------------------------------------------
	AI.BeginGoalPipe("su_attack_stop_and_shoot");
		AI.PushGoal("firecmd",0,FIREMODE_BURST_DRAWFIRE); --_DRAWFIRE);
		AI.PushGoal("strafe",0,100,100);
		AI.PushGoal("bodypos",0,BODYPOS_STAND,1);
		AI.PushGoal("run",0,0);

		AI.PushGoal("locate",0,"probtarget");
		AI.PushGoal("+seekcover", 1, COVER_UNHIDE, 3.0, 2, 1);

		AI.PushGoal("timeout",1,3,5);
		AI.PushGoal("signal",0,1,"COVER_NORMALATTACK",0);
	AI.EndGoalPipe();

	---------------------------------------------
	AI.BeginGoalPipe("su_charge");
		AI.PushGoal("signal",0,1,"SUIT_ARMOR_MODE",0);
		AI.PushGoal("signal",1,1,"CHOOSE_WEAPON",0);
		AI.PushGoal("bodypos",0,BODYPOS_STAND);
		AI.PushGoal("run",0,2);
		AI.PushGoal("strafe",0,5,2);
		AI.PushGoal("firecmd",0,1);
		AI.PushGoal("stick",0,1, AI_CONSTANT_SPEED, STICK_BREAK+STICK_SHORTCUTNAV);
		AI.PushGoal("timeout",1,4.5);
		AI.PushGoal("firecmd",0,0);
		AI.PushGoal("clear",0,0);
		AI.PushGoal("signal",0,1,"COVER_NORMALATTACK",0);
	AI.EndGoalPipe();

	---------------------------------------------
	AI.BeginGoalPipe("su_melee");
		AI.PushGoal("signal",0,1,"SUIT_STRENGTH_MODE",0);
		AI.PushGoal("bodypos",0,BODYPOS_STAND);
		AI.PushGoal("run",0,2);
		AI.PushGoal("strafe",0,5,2);
		AI.PushGoal("firecmd",0,FIREMODE_MELEE);
		AI.PushGoal("stick",0,1, AI_CONSTANT_SPEED, STICK_BREAK+STICK_SHORTCUTNAV);
		AI.PushGoal("timeout",1,3.5);
		AI.PushGoal("firecmd",0,0);
		AI.PushGoal("clear",0,0);
		AI.PushGoal("signal",0,1,"MELEE_DONE",0);
	AI.EndGoalPipe();

	---------------------------------------------
	AI.BeginGoalPipe("su_melee_retreat");
		AI.PushGoal("timeout",1,0.2);
		AI.PushGoal("firecmd",0,0);
		AI.PushGoal("strafe",0,1,1,1);
		AI.PushGoal("run",0,2,1,10);
		AI.PushGoal("bodypos",1,BODYPOS_STAND, 1);

		AI.PushGoal("signal",1,1,"SUIT_CLOAK_MODE",0);

		AI.PushGoal("hide", 1, 17, HM_NEAREST+HM_INCLUDE_SOFTCOVERS, 0, 8);
		AI.PushGoal("branch", 1, "HIDE_OK", IF_COVER_NOT_COMPROMISED);
			AI.PushGoal("branch", 1, "INDOOR", IF_NAV_WAYPOINT_HUMAN);
				AI.PushGoal("locate",0,"refpoint");
				AI.PushGoal("+approach",1,-18,AILASTOPRES_USE+AI_REQUEST_PARTIAL_PATH,15,"",8);
				AI.PushGoal( "branch", 1, "HIDE_OK", BRANCH_ALWAYS);
			AI.PushLabel("INDOOR");
				AI.PushGoal("locate",0,"refpoint");
				AI.PushGoal("+approach",1,-6,AILASTOPRES_USE+AI_REQUEST_PARTIAL_PATH,15,"",3);
			AI.PushGoal("firecmd",0,1);
		AI.PushLabel("HIDE_OK");
		
		AI.PushGoal("signal",1,1,"COVER_NORMALATTACK",0);
	AI.EndGoalPipe();


	---------------------------------------------
	AI.BeginGoalPipe("su_advance");

		AI.PushGoal("signal",1,1,"SUIT_ARMOR_MODE",0);
		AI.PushGoal("signal",1,1,"CHOOSE_WEAPON",0);

		AI.PushGoal("firecmd",0,1);
		AI.PushGoal("strafe",0,1,1,1);
		AI.PushGoal("run",0,2,1,10);
		AI.PushGoal("bodypos",1,BODYPOS_STAND, 1);

--			AI.PushGoal("hide", 1, 17, HM_NEAREST_TOWARDS_REFPOINT+HM_INCLUDE_SOFTCOVERS, 0, 3);
		
--			AI.PushGoal("branch", 1, "HIDE_OK", IF_COVER_NOT_COMPROMISED);
			AI.PushGoal("branch", 1, "INDOOR", IF_NAV_WAYPOINT_HUMAN);
				AI.PushGoal("locate",0,"refpoint");
				AI.PushGoal("+approach",1,-18,AILASTOPRES_USE+AI_REQUEST_PARTIAL_PATH,15,"",8);
				AI.PushGoal( "branch", 1, "HIDE_OK", BRANCH_ALWAYS);
			AI.PushLabel("INDOOR");
				AI.PushGoal("locate",0,"refpoint");
				AI.PushGoal("+approach",1,-6,AILASTOPRES_USE+AI_REQUEST_PARTIAL_PATH,15,"",3);
			AI.PushGoal("firecmd",0,1);

		AI.PushLabel("HIDE_OK");
		AI.PushGoal("branch", 1, "SKIP_SHOOT", IF_TARGET_OUT_OF_RANGE);
		AI.PushGoal("branch", 1, "SKIP_SHOOT", IF_TARGET_LOST_TIME_MORE, 5.0);

		AI.PushGoal("run", 0, 0);

		AI.PushGoal("locate",0,"probtarget");
		AI.PushGoal("+adjustaim",0,0,1);

		AI.PushGoal("branch", 1, "SKIP_UNHIDE1", IF_SEES_TARGET, 20.0);
			AI.PushGoal("locate",0,"probtarget");
			AI.PushGoal("+seekcover", 1, COVER_UNHIDE, 5.0, 2, 1+2); -- 2=towards refpoint
		AI.PushLabel("SKIP_UNHIDE1");
--			AI.PushGoal("timeout",1,0.6,1);

--			AI.PushGoal("branch", 1, "SKIP_SHOOT", IF_TARGET_LOST_TIME_MORE, 5.0);

--			AI.PushGoal("branch", 1, "SKIP_UNHIDE2", IF_SEES_TARGET, 20.0);
--				AI.PushGoal("locate",0,"probtarget");
--				AI.PushGoal("+seekcover", 1, COVER_UNHIDE, 4.0, 2, 1+2); -- 2=towards refpoint
--			AI.PushLabel("SKIP_UNHIDE2");
--			AI.PushGoal("timeout",1,0.6,1);

		AI.PushLabel("SKIP_SHOOT");
		AI.PushGoal("signal",1,1,"COVER_NORMALATTACK",0);
	AI.EndGoalPipe();

	---------------------------------------------
	AI.BeginGoalPipe("su_stunt");

		AI.PushGoal("signal",1,1,"SUIT_STRENGTH_MODE",0);
		AI.PushGoal("signal",1,1,"CHOOSE_WEAPON",0);

		AI.PushGoal("firecmd",0,1);
		AI.PushGoal("strafe",0,4,2);
		AI.PushGoal("run",0,2,1,5);
		AI.PushGoal("bodypos",1,BODYPOS_STAND, 1);

		AI.PushGoal("locate",0,"refpoint");
		AI.PushGoal("+approach",1,0,AILASTOPRES_USE+AI_REQUEST_PARTIAL_PATH,15);

		AI.PushGoal("signal",1,1,"SUIT_ARMOR_MODE",0);

		AI.PushGoal("branch", 1, "SKIP_SHOOT", IF_TARGET_OUT_OF_RANGE);
		AI.PushGoal("branch", 1, "SKIP_SHOOT", IF_TARGET_LOST_TIME_MORE, 5.0);

		AI.PushGoal("firecmd",0,1);
		AI.PushGoal("run", 0, 0);

		AI.PushGoal("locate",0,"probtarget");
		AI.PushGoal("+adjustaim",0,0,1);

		AI.PushGoal("branch", 1, "SKIP_UNHIDE1", IF_SEES_TARGET, 20.0);
			AI.PushGoal("locate",0,"probtarget");
			AI.PushGoal("+seekcover", 1, COVER_UNHIDE, 3.0, 2, 1+2); -- 2=towards refpoint
		AI.PushLabel("SKIP_UNHIDE1");
		AI.PushGoal("timeout",1,4,6);

		AI.PushLabel("SKIP_SHOOT");
		AI.PushGoal("signal",1,1,"COVER_NORMALATTACK",0);
	AI.EndGoalPipe();

	---------------------------------------------
	AI.BeginGoalPipe("su_bullet_reaction");

		AI.PushGoal("signal",1,1,"SUIT_ARMOR_MODE",0);
		AI.PushGoal("signal",1,1,"CHOOSE_WEAPON",0);

		AI.PushGoal("run", 0, 1,0,1);
		AI.PushGoal("bodypos",1,BODYPOS_STAND, 1);
		AI.PushGoal("firecmd",0,1);
		AI.PushGoal("strafe",0,4,4);

		AI.PushGoal("locate",0,"probtarget");
		AI.PushGoal("+adjustaim",0,1,1); --hide

		AI.PushGoal("hide", 1, 10, HM_NEAREST+HM_INCLUDE_SOFTCOVERS, 0, 8);

		AI.PushGoal("locate",0,"probtarget");
		AI.PushGoal("+seekcover", 1, COVER_HIDE, 5.0, 3, 1);

		AI.PushGoal("timeout",1,0.3,0.7);
		AI.PushGoal("signal",1,1,"COVER_NORMALATTACK",0);
	AI.EndGoalPipe();

	---------------------------------------------
	AI.BeginGoalPipe("su_throw_smoke");
			AI.PushGoal("firecmd", 0, 0);
			AI.PushGoal("branch", 1, "WAIT_PRONE", IF_STANCE_IS, BODYPOS_PRONE);	
				AI.PushGoal("bodypos",1,BODYPOS_STAND);
				AI.PushGoal("branch", 1, "STANDING", BRANCH_ALWAYS);
			AI.PushLabel("WAIT_PRONE");
				AI.PushGoal("bodypos",1,BODYPOS_STAND);
				AI.PushGoal("timeout",1,1,1.5);
			AI.PushLabel("STANDING");
			AI.PushGoal("signal",1,1,"throwing_grenade",SIGNALID_READIBILITY,115);
			AI.PushGoal("timeout",1,0.5);
			AI.PushGoal("locate",0,"atttarget");
			AI.PushGoal("firecmd", 0, FIREMODE_SECONDARY_SMOKE);
			AI.PushGoal("timeout",1,1);
			AI.PushGoal("firecmd", 0, 0);
	AI.EndGoalPipe();


	---------------------------------------------
	AI.BeginGoalPipe("fl_simple_flinch");
		AI.PushGoal("ignoreall",0,1);
		AI.PushGoal("+firecmd",0,0);
		AI.PushGoal("+bodypos",0,BODYPOS_STAND);
--			AI.PushGoal("+signal",1,1,"flashbang_hit",SIGNALID_READIBILITY,115);
		AI.PushGoal("+animation",0,AIANIM_SIGNAL,"flinch");
		AI.PushGoal("+timeout",1,2,3);
		AI.PushGoal("+ignoreall",0,0);
		AI.PushGoal("+signal",0,1,"FLASHBANG_GONE",0);
	AI.EndGoalPipe();

	---------------------------------------------
	AI.BeginGoalPipe("fl_simple_bulletreaction");
		AI.PushGoal("firecmd",0,FIREMODE_BURST);
		AI.PushGoal("run", 0, 2,1,6);
		AI.PushGoal("bodypos",1,BODYPOS_STAND, 1);
		AI.PushGoal("strafe",0,4,2);
		AI.PushGoal("locate",0,"probtarget");
		AI.PushGoal("+seekcover", 1, COVER_HIDE, 4.0, 2, 1);
		AI.PushGoal("signal",0,1,"FLASHBANG_GONE",0);
	AI.EndGoalPipe();

	---------------------------------------------
	AI.BeginGoalPipe("fl_simple_follow");
		AI.PushGoal("bodypos",0,BODYPOS_STAND);
		AI.PushGoal("strafe",0,5,2);
--			AI.PushGoal("locate",0,"player");
--			AI.PushGoal("+mimic",0, 4.0, 0.2);
--			AI.PushGoal("mimicfire", 0, "player");
--			AI.PushGoal("locate", 0, "group_tac_pos");
--			AI.PushGoal("+mimicstance", 0, "player");
		AI.PushGoal("locate", 0, "group_tac_look");
		AI.PushGoal("+adjustaim",0,0,1);
		AI.PushGoal("locate", 0, "group_tac_look");
		AI.PushGoal("+lookat", 0, 0, 0, true, 1);
		AI.PushGoal("locate", 0, "group_tac_pos");
		AI.PushGoal("+stick",1,0,AILASTOPRES_USE,0,15);
	AI.EndGoalPipe();

	---------------------------------------------
	AI.BeginGoalPipe("fl_combat_follow");
		AI.PushGoal("bodypos",0,BODYPOS_STAND);
		AI.PushGoal("strafe",0,5,2);
		AI.PushGoal("firecmd",0,FIREMODE_BURST);
		AI.PushGoal("locate", 0, "group_tac_look");
		AI.PushGoal("+adjustaim",0,0,1);
		AI.PushGoal("locate", 0, "group_tac_look");
		AI.PushGoal("+lookat", 0, 0, 0, true, 1);
		AI.PushGoal("locate", 0, "group_tac_pos");
		AI.PushGoal("+stick",1,0,AILASTOPRES_USE,0,15);
	AI.EndGoalPipe();

	---------------------------------------------
	AI.BeginGoalPipe("fl_combat_follow_heavy");
		AI.PushGoal("bodypos",0,BODYPOS_STAND);
		AI.PushGoal("strafe",0,5,2);
		AI.PushGoal("firecmd",0,FIREMODE_BURST);
		AI.PushGoal("locate", 0, "group_tac_look");
		AI.PushGoal("+lookat", 0, 0, 0, true, 1);
		AI.PushGoal("locate", 0, "group_tac_pos");
		AI.PushGoal("+stick",1,0,AILASTOPRES_USE,0,15);
	AI.EndGoalPipe();

	---------------------------------------------
	AI.BeginGoalPipe("fl_just_shoot");
		AI.PushGoal("locate", 0, "probtarget");
		AI.PushGoal("+adjustaim",0,0,1);
		AI.PushGoal("firecmd",0,FIREMODE_BURST);
		AI.PushGoal("timeout",1,1.0,3.0);
		AI.PushGoal("firecmd",0,0);
		AI.PushGoal("timeout",1,0.5,1.5);
		AI.PushGoal("+signal",0,1,"COMBAT_READABILITY",0);
	AI.EndGoalPipe();

	---------------------------------------------
	AI.BeginGoalPipe("fl_melee");
		AI.PushGoal("bodypos",0,BODYPOS_STAND);
		AI.PushGoal("run",0,1);
		AI.PushGoal("strafe",0,5,2);
		AI.PushGoal("firecmd",0,FIREMODE_MELEE);
		AI.PushGoal("stick",0,1,0,STICK_BREAK+STICK_SHORTCUTNAV);
		AI.PushGoal("timeout",1,2.5);
		AI.PushGoal("firecmd",0,0);
		AI.PushGoal("clear",0,0);
		AI.PushGoal("signal",0,1,"MELEE_DONE",0);
	AI.EndGoalPipe();

	---------------------------------------------
	AI.BeginGoalPipe("fl_melee_pause");
		AI.PushGoal("timeout",1,0.2);
		AI.PushGoal("firecmd",0,0);
		AI.PushGoal("signal",0,1,"MELEE_DONE",0);
	AI.EndGoalPipe();

end



