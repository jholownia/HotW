
function PipeManager:OnInitExamples()

	local block=1;
	local noblock=0;
	
	AI.CreateGoalPipe("hide_from_beacon");
	AI.PushGoal("hide_from_beacon","locate",0,"beacon");
	AI.PushGoal("hide_from_beacon","acqtarget",0,"");
	AI.PushGoal("hide_from_beacon","bodypos",0,BODYPOS_STAND);	
	AI.PushGoal("hide_from_beacon","run",0,1);
	AI.PushGoal("hide_from_beacon","hide",1,20,HM_NEAREST);

	AI.CreateGoalPipe("rush_player");
	AI.PushGoal("rush_player","locate",0,"player");
	AI.PushGoal("rush_player","acqtarget",1,"");
	AI.PushGoal("rush_player","run",0,2);
	AI.PushGoal("rush_player","timeout",1,0.2,0.8);
	AI.PushGoal("rush_player","firecmd",1,1);
	AI.PushGoal("rush_player","approach",1,5);
	AI.PushGoal("rush_player","firecmd",1,0);
	AI.PushGoal("rush_player","signal",1,1,"STOP_RUSH",0);


	AI.CreateGoalPipe("look_at_lastop");
	AI.PushGoal("look_at_lastop","lookat",1,0,0);

	AI.CreateGoalPipe("backoff_from");
	AI.PushGoal("backoff_from","run",0,1);
	AI.PushGoal("backoff_from","bodypos",0,BODYPOS_STAND);
	AI.PushGoal("backoff_from","backoff",1,5,2);
--	AI.PushGoal("backoff_from","branch",1,"END",IF_ACTIVE_GOALS);
--	AI.PushLabel("backoff_from","END");
--	AI.PushGoal("backoff_from","clear",0,0);

	AI.CreateGoalPipe("backoff_from_explosion");
	AI.PushGoal("backoff_from_explosion","run",0,1.5);
	AI.PushGoal("backoff_from_explosion","+bodypos",0,BODYPOS_STAND);
	AI.PushGoal("backoff_from_explosion","+backoff",1,12,0,AILASTOPRES_USE+AI_LOOK_FORWARD);
	AI.PushGoal("backoff_from_explosion","+timeout",1,5);
	AI.PushGoal("backoff_from_explosion","signal",1,1,"END_BACKOFF",0);

	AI.CreateGoalPipe("setup_idle");	
	AI.PushGoal("setup_idle","firecmd",0,0);	
	AI.PushGoal("setup_idle","bodypos",0,BODYPOS_RELAX);	
	AI.PushGoal("setup_idle","run",0,0);	
	--AI.PushGoal("setup_idle","firecmd",0,0);	

	AI.CreateGoalPipe("setup_combat");	
--	AI.PushGoal("setup_combat","bodypos",0,BODYPOS_STAND);
	AI.PushGoal("setup_combat","run",0,1);

	AI.CreateGoalPipe("do_it_crouched");
	AI.PushGoal("do_it_crouched","bodypos",1,BODYPOS_CROUCH);	

	AI.CreateGoalPipe("do_it_prone");
	AI.PushGoal("do_it_prone","bodypos",1,BODYPOS_PRONE);	

	AI.CreateGoalPipe("do_it_standing");
	AI.PushGoal("do_it_standing","bodypos",1,BODYPOS_STAND);	

	AI.CreateGoalPipe("do_it_relaxed");
	AI.PushGoal("do_it_relaxed","bodypos",0,BODYPOS_RELAX);	

	AI.CreateGoalPipe("do_it_running");
	AI.PushGoal("do_it_running","run",0,1);
	
	AI.CreateGoalPipe("do_it_sprinting");
	AI.PushGoal("do_it_sprinting","run",0,2);


	AI.CreateGoalPipe("do_it_walking");
	AI.PushGoal("do_it_walking","run",0,0);

	
	AI.CreateGoalPipe("do_it_very_slow");
	AI.PushGoal("do_it_very_slow","run",0,-0.2);

	AI.CreateGoalPipe("do_it_super_slow");
	AI.PushGoal("do_it_super_slow","run",0,-0.3);

	----------------------------------------------------

	AI.CreateGoalPipe("take_cover");
	AI.PushGoal("take_cover","run",0,1);
	AI.PushGoal("take_cover","+hide",1,10,HM_NEAREST,1);
	AI.PushGoal("take_cover","run",0,0);
	
	AI.CreateGoalPipe("short_timeout");
	AI.PushGoal("short_timeout","timeout",1,1,1.2);
	AI.PushGoal("short_timeout","signal",0,1,"END_TIMEOUT",SIGNALFILTER_SENDER);


	AI.CreateGoalPipe("just_shoot");
--	AI.PushGoal("just_shoot","firecmd",0,FIREMODE_CONTINUOUS);
	AI.PushGoal("just_shoot","firecmd",0,FIREMODE_BURST);	
	AI.PushGoal("just_shoot","timeout",1,1,2);

	AI.CreateGoalPipe("just_shoot_kill");
	AI.PushGoal("just_shoot_kill","firecmd",0,FIREMODE_KILL);	
	AI.PushGoal("just_shoot_kill","timeout",1,1);
	
	AI.BeginGoalPipe("just_shoot_advance");
		AI.PushGoal("approach",1,1);	-- advance to target
	AI.EndGoalPipe();
	
	AI.CreateGoalPipe("just_shoot_done");
	AI.PushGoal("just_shoot_done","firecmd",0,FIREMODE_OFF);	
	AI.PushGoal("just_shoot_done", "signal", 1, 1, "FASTKILL_EXIT", 0);	

	AI.CreateGoalPipe("dumb_shoot");
	AI.PushGoal("dumb_shoot","locate",0,"beacon");
	AI.PushGoal("dumb_shoot","acqtarget",0,"");
	AI.PushGoal("dumb_shoot","firecmd",0,FIREMODE_FORCED, AILASTOPRES_USE);
	AI.PushGoal("dumb_shoot","timeout",1,1);
	AI.PushGoal("dumb_shoot","firecmd",0,FIREMODE_OFF);	

	AI.CreateGoalPipe("look_around");
	AI.PushGoal("look_around","lookat",1,-180,180);
	AI.PushGoal("look_around","timeout",1,3,5);
	
	AI.CreateGoalPipe("pause_shooting");
	AI.PushGoal("pause_shooting","firecmd",0,0);
	AI.PushGoal("pause_shooting","timeout",1,0.5,1.5);
	AI.PushGoal("pause_shooting","firecmd",0,1);

	AI.CreateGoalPipe("stop_fire");
	AI.PushGoal("stop_fire","firecmd",1,0);

	AI.CreateGoalPipe("start_fire");
	AI.PushGoal("start_fire","firecmd",1,1);

	-----------------------------------------------------
	AI.CreateGoalPipe("stand_only");
	--AI.PushGoal("stand_only","timeout",1,2,4);
	--AI.PushGoal("stand_only","signal",0,1,"DO_SOMETHING_IDLE",0);	-- do something (or not)

	
	---------------------------------------------
	AI.BeginGoalPipe("test_hide_nearest");
		AI.PushGoal("bodypos",0,BODYPOS_STAND);
		AI.PushGoal("run",0,1);
		AI.PushGoal("hide",1,15,HM_NEAREST);
		AI.PushGoal("timeout",1,1,1);
	AI.EndGoalPipe();
	
	---------------------------------------------
	AI.BeginGoalPipe("test_hide_nearest_min");
		AI.PushGoal("bodypos",0,BODYPOS_STAND);
		AI.PushGoal("run",0,1);
		AI.PushGoal("hide",1,15,HM_NEAREST,false,5);
		AI.PushGoal("timeout",1,1,1);
	AI.EndGoalPipe();

	---------------------------------------------
	AI.BeginGoalPipe("test_hide_nearest_crouch");
		AI.PushGoal("bodypos",0,BODYPOS_STAND);
		AI.PushGoal("run",0,1);
		AI.PushGoal("hide",1,15,HM_NEAREST);
		AI.PushGoal("timeout",1,1,1);
		AI.PushGoal("bodypos",0,BODYPOS_CROUCH);
		AI.PushGoal("timeout",1,2,8);
	AI.EndGoalPipe();
	
	---------------------------------------------
	AI.BeginGoalPipe("test_approach_direct");
		AI.PushGoal("bodypos",0,BODYPOS_STAND);
		AI.PushGoal("run",0,1);
		AI.PushGoal("locate",0,"Goon15",1000);
		AI.PushGoal("acqtarget",1,"");
		AI.PushGoal("run",0,1);
		AI.PushGoal("timeout",1,0.2,0.8);
		AI.PushGoal("stick",1,8,AI_REQUEST_PARTIAL_PATH,1);	-- get to within 8 metre of a moving target
	AI.EndGoalPipe();

	---------------------------------------------
	AI.BeginGoalPipe("test_approach_staged");
		AI.PushGoal("bodypos",0,BODYPOS_STAND);
		AI.PushGoal("run",0,1);
		AI.PushGoal("locate",0,"Goon15",1000);
		AI.PushGoal("acqtarget",1,"");
		AI.PushGoal("run",0,1);
		AI.PushGoal("approach",1,15,AILASTOPRES_USE+AILASTOPRES_LOOKAT,15.0);
		AI.PushGoal("bodypos",1,BODYPOS_CROUCH);
		AI.PushGoal("timeout",1,2,2);
		AI.PushGoal("bodypos",1,BODYPOS_STAND);
		AI.PushGoal("approach",1,10,AILASTOPRES_USE+AILASTOPRES_LOOKAT,10.0);
		AI.PushGoal("bodypos",1,BODYPOS_CROUCH);
		AI.PushGoal("timeout",1,2,2);
		AI.PushGoal("bodypos",1,BODYPOS_STAND);
		AI.PushGoal("approach",1,5,AILASTOPRES_USE+AILASTOPRES_LOOKAT,5.0);
		AI.PushGoal("bodypos",1,BODYPOS_CROUCH);
		AI.PushGoal("timeout",1,2,2);
	AI.EndGoalPipe();

	-----------------------------------------------------------
	-- test all run modes, including the bizarre backwards ones
	-----------------------------------------------------------
	AI.BeginGoalPipe("test_all_run_modes");
		AI.PushGoal("bodypos",0,BODYPOS_STAND);
		AI.PushGoal("firecmd",0,0);		
		AI.PushGoal("locate",0,"Goon15",1000);
		AI.PushGoal("acqtarget",1,"");		
		AI.PushGoal("stick",0,1,AILASTOPRES_USE+AI_REQUEST_PARTIAL_PATH,1);	-- get to within 1 metre of a moving target
		AI.PushGoal("run",0,0);
		AI.PushGoal("timeout",1,1.5,1.5);
		AI.PushGoal("run",0,1);
		AI.PushGoal("timeout",1,1.5,1.5);
		AI.PushGoal("run",0,2);
		AI.PushGoal("timeout",1,1.5,1.5);
		AI.PushGoal("run",0,0);
		AI.PushGoal("signal",0,1,"RUN_NEG_0",0);
		AI.PushGoal("timeout",1,1.5,1.5);
		AI.PushGoal("run",0,-1);
		AI.PushGoal("signal",0,1,"RUN_NEG_1",0);
		AI.PushGoal("timeout",1,4,4);
		AI.PushGoal("run",0,-2);
		AI.PushGoal("signal",0,1,"RUN_NEG_2",0);
		AI.PushGoal("timeout",1,4,4);
		AI.PushGoal("run",0,-3);
		AI.PushGoal("signal",0,1,"RUN_NEG_3",0);
		AI.PushGoal("timeout",1,4,4);
		AI.PushGoal("run",0,-4);
		AI.PushGoal("signal",0,1,"RUN_NEG_4",0);
		AI.PushGoal("timeout",1,4,4);
		AI.PushGoal("run",0,-5);
		AI.PushGoal("signal",0,1,"RUN_NEG_5",0);
		AI.PushGoal("timeout",1,4,4);
		AI.PushGoal("run",0,0);
		AI.PushGoal("signal",0,1,"RUN_NEG_0",0);
		AI.PushGoal("timeout",1,4,4);	
	AI.EndGoalPipe();


	---------------------------------------------
  -- Test all the useful run modes
	---------------------------------------------
	AI.BeginGoalPipe("test_run_modes");
		AI.PushGoal("bodypos",0,BODYPOS_STAND);
		AI.PushGoal("firecmd",0,0);		
		AI.PushGoal("locate",0,"Goon15",1000);
		AI.PushGoal("acqtarget",1,"");		
		AI.PushGoal("stick",0,1,AILASTOPRES_USE+AI_REQUEST_PARTIAL_PATH,1);	-- get to within 1 metre of a moving target
		AI.PushGoal("run",0,-1);
		AI.PushGoal("timeout",1,3,3);
		AI.PushGoal("run",0,0);
		AI.PushGoal("timeout",1,3,3);
		AI.PushGoal("run",0,1);
		AI.PushGoal("timeout",1,1.5,1.5);
		AI.PushGoal("run",0,2);
		AI.PushGoal("timeout",1,1.5,1.5);
		AI.PushGoal("run",0,1);
		AI.PushGoal("timeout",1,1.5,1.5);
		AI.PushGoal("run",0,0);
		AI.PushGoal("timeout",1,3,3);
		AI.PushGoal("run",0,-1);
		AI.PushGoal("timeout",1,3,3);
	AI.EndGoalPipe();



	AI.BeginGoalPipe("go_stance_prone");
		AI.PushGoal("bodypos",0,BODYPOS_PRONE);
	AI.EndGoalPipe();
	
	AI.BeginGoalPipe("go_stance_crouch");
		AI.PushGoal("bodypos",0,BODYPOS_CROUCH);
	AI.EndGoalPipe();

	AI.BeginGoalPipe("go_stance_stealth");
		AI.PushGoal("bodypos",0,BODYPOS_STEALTH);
	AI.EndGoalPipe();

	AI.BeginGoalPipe("go_stance_relax");
		AI.PushGoal("bodypos",0,BODYPOS_RELAX);
	AI.EndGoalPipe();

	AI.BeginGoalPipe("go_stance_stand");
		AI.PushGoal("bodypos",0,BODYPOS_STAND);
	AI.EndGoalPipe();

	AI.BeginGoalPipe("go_runmode_slow");
		AI.PushGoal("run",0,-1);
	AI.EndGoalPipe();

	AI.BeginGoalPipe("go_runmode_walk");
		AI.PushGoal("run",0,0);
	AI.EndGoalPipe();

	AI.BeginGoalPipe("go_runmode_run");
		AI.PushGoal("run",0,1);
	AI.EndGoalPipe();

	AI.BeginGoalPipe("go_runmode_sprint");
		AI.PushGoal("run",0,1);
	AI.EndGoalPipe();


	---------------------------------------------
	AI.BeginGoalPipe("go_somewhere");
		AI.PushGoal("locate",0,"Goon15",1000);
		AI.PushGoal("acqtarget",1,"");
		AI.PushGoal("stick",0,1,AILASTOPRES_USE+AI_REQUEST_PARTIAL_PATH,1);	-- get to within 1 metre of a moving target
	AI.EndGoalPipe();


	---------------------------------------------
  -- Test all stances
	---------------------------------------------
	AI.BeginGoalPipe("test_stances");
		AI.PushGoal("firecmd",0,0);		
		AI.PushGoal("bodypos",0,BODYPOS_PRONE);
		AI.PushGoal("timeout",1,4,4);
		AI.PushGoal("bodypos",0,BODYPOS_CROUCH);
		AI.PushGoal("timeout",1,4,4);
		AI.PushGoal("bodypos",0,BODYPOS_STEALTH);
		AI.PushGoal("timeout",1,4,4);
		AI.PushGoal("bodypos",0,BODYPOS_RELAX);
		AI.PushGoal("timeout",1,4,4);
		AI.PushGoal("bodypos",0,BODYPOS_STAND);
		AI.PushGoal("timeout",1,4,4);
	AI.EndGoalPipe();
	
	
		---------------------------------------------
	AI.BeginGoalPipe("test_firing");
		AI.PushGoal("locate",0,"Goon15",1000);
		AI.PushGoal("acqtarget",1,"");
		AI.PushGoal("bodypos",0,BODYPOS_STAND);
		AI.PushGoal("firecmd",0,FIREMODE_AIM);		
		AI.PushGoal("timeout",1,2,2);
		AI.PushGoal("firecmd",0,FIREMODE_BURST);		
		AI.PushGoal("timeout",1,2,2);
		AI.PushGoal("firecmd",0,FIREMODE_CONTINUOUS);		
		AI.PushGoal("firecmd",0,0);		
		AI.PushGoal("timeout",1,2,2);
	AI.EndGoalPipe();

		---------------------------------------------
	AI.BeginGoalPipe("test_just_shoot");
		AI.PushGoal("locate",0,"Goon15",1000);
		AI.PushGoal("acqtarget",1,"");
		AI.PushGoal("bodypos",0,BODYPOS_STAND);
		AI.PushGoal("firecmd",0,FIREMODE_BURST);		
		AI.PushGoal("timeout",1,10,20);
	AI.EndGoalPipe();



		---------------------------------------------
	AI.BeginGoalPipe("test_shoot_one");
		AI.PushGoal("locate",0,"Goon15",1000);
		AI.PushGoal("acqtarget",1,"");
		AI.PushGoal("bodypos",0,BODYPOS_STAND);
		AI.PushGoal("firecmd",0,FIREMODE_BURST_ONCE);		
		AI.PushGoal("timeout",1,5,5);
	AI.EndGoalPipe();


		---------------------------------------------
	AI.BeginGoalPipe("just_shoot_one");
		AI.PushGoal("firecmd",0,FIREMODE_BURST_ONCE);		
	AI.EndGoalPipe();

	---------------------------------------------
	AI.BeginGoalPipe("test_close_run_firing");
		AI.PushGoal("bodypos",0,BODYPOS_STAND);
		AI.PushGoal("firecmd",0,FIREMODE_BURST);		
		AI.PushGoal("run",0,1);
		AI.PushGoal("locate",0,"Goon15",1000);
		AI.PushGoal("acqtarget",1,"");		
		AI.PushGoal("stick",1,1,AILASTOPRES_USE+AI_REQUEST_PARTIAL_PATH,1);	-- get to within 1 metre of a moving target
		AI.PushGoal("timeout",1,0.2,0.8);
	AI.EndGoalPipe();


	---------------------------------------------
	AI.BeginGoalPipe("test_close_lateral_firing");
		AI.PushGoal("bodypos",0,BODYPOS_STAND);
		AI.PushGoal("firecmd",0,FIREMODE_BURST);		
		AI.PushGoal("run",0,1);
		AI.PushGoal("locate",0,"Goon15",1000);
		AI.PushGoal("acqtarget",1,"");		
		AI.PushGoal("stick",0,1,AILASTOPRES_USE+AI_REQUEST_PARTIAL_PATH,1);	-- get to within 1 metre of a moving target
		AI.PushGoal("timeout",1,2,2);
		AI.PushGoal("run",0,2);
		AI.PushGoal("bodypos",0,BODYPOS_CROUCH);		
		AI.PushGoal("timeout",1,2,2);
	AI.EndGoalPipe();


	---------------------------------------------
  -- Moving just near cover
	---------------------------------------------
	AI.BeginGoalPipe("test_near_cover");
		AI.PushGoal("locate",0,"Goon15",1000);
		AI.PushGoal("acqtarget",1,"");
		AI.PushGoal("bodypos",0,BODYPOS_STAND);
		AI.PushGoal("run",0,1);
		AI.PushGoal("hide",1,40,HM_NEAREST_PREFER_SIDES,0,2);
		AI.PushGoal("timeout",1,3,3);
		AI.PushGoal("hide",1,40,HM_NEAREST);
		AI.PushGoal("timeout",1,3,3);
	AI.EndGoalPipe();



	---------------------------------------------
  -- Moving under increasing fire
	---------------------------------------------
	AI.BeginGoalPipe("test_cover_under_fire");
		AI.PushGoal("locate",0,"Goon15",1000);
		AI.PushGoal("acqtarget",1,"");
		AI.PushGoal("bodypos",0,BODYPOS_STAND);
		AI.PushGoal("stick",0,1,AILASTOPRES_USE,2);	-- get to within 1 metre of a moving target
		AI.PushGoal("run",0,1);
		AI.PushGoal("timeout",1,2,2);
		AI.PushGoal("run",0,2);
		AI.PushGoal("timeout",1,1.5,1.5);
		AI.PushGoal("bodypos",0,BODYPOS_PRONE);
		AI.PushGoal("timeout",1,2,2);
		AI.PushGoal("bodypos",0,BODYPOS_CROUCH);
		AI.PushGoal("lookat",0,-90,90);
		AI.PushGoal("timeout",1,1,2);
		AI.PushGoal("bodypos",0,BODYPOS_STAND);
	AI.EndGoalPipe();


	---------------------------------------------
  -- Moving under increasing fire
	---------------------------------------------
	AI.BeginGoalPipe("test_sprint");
		AI.PushGoal("locate",0,"Goon15",1000);
		AI.PushGoal("acqtarget",1,"");
		AI.PushGoal("bodypos",0,BODYPOS_STAND);
		AI.PushGoal("stick",0,1,AILASTOPRES_USE,2);	-- get to within 1 metre of a moving target
		AI.PushGoal("run",0,2);
		AI.PushGoal("bodypos",0,BODYPOS_STAND);
	AI.EndGoalPipe();

	---------------------------------------------
  -- Squaredance - which _doesn't_ because it's dependant on the attention target
	---------------------------------------------
	AI.BeginGoalPipe("test_squaredance");
		AI.PushGoal("backoff",1,-4,0,AI_MOVE_FORWARD);
		AI.PushGoal("backoff",1,-4,0,AI_MOVE_RIGHT);
		AI.PushGoal("backoff",1,-4,0,AI_MOVE_BACKWARD);
		AI.PushGoal("backoff",1,-4,0,AI_MOVE_LEFT);
	AI.EndGoalPipe();


---------------------------------------------
  -- Dally about without losing the target
	---------------------------------------------
	AI.BeginGoalPipe("test_dally");
		AI.PushGoal("strafe",1,1,0); 
		AI.PushGoal("backoff",1,3,0,AI_MOVE_LEFT);
		AI.PushGoal("backoff",1,3,0,AI_MOVE_RIGHT);
		AI.PushGoal("backoff",1,3,0,AI_MOVE_BACKWARD);
		AI.PushGoal("strafe",0,0,0); 
		AI.PushGoal("backoff",1,3,0,AI_MOVE_FORWARD);
		AI.PushGoal("backoff",1,3,0,AI_MOVE_RIGHT);
		AI.PushGoal("backoff",1,3,0,AI_MOVE_LEFT);
	AI.EndGoalPipe();

  ---------------------------------------------
  -- Dally about without losing the target
	---------------------------------------------
	AI.BeginGoalPipe("test_dally_looking_forward");
		AI.PushGoal("backoff",1,3,0,AI_MOVE_LEFT + AI_LOOK_FORWARD);
		AI.PushGoal("backoff",1,3,0,AI_MOVE_RIGHT + AI_LOOK_FORWARD);
		AI.PushGoal("backoff",1,3,0,AI_MOVE_BACKWARD + AI_LOOK_FORWARD);
		AI.PushGoal("backoff",1,3,0,AI_MOVE_FORWARD + AI_LOOK_FORWARD);
		AI.PushGoal("backoff",1,3,0,AI_MOVE_RIGHT + AI_LOOK_FORWARD);
		AI.PushGoal("backoff",1,3,0,AI_MOVE_LEFT + AI_LOOK_FORWARD);
	AI.EndGoalPipe();


  ---------------------------------------------
  -- Dally about without losing the target
	---------------------------------------------
	AI.BeginGoalPipe("test_backoff");
		AI.PushGoal("firecmd",0,1);
		AI.PushGoal("strafe",0,10);
		AI.PushGoal("run",0,1);
		AI.PushGoal("+bodypos",0,BODYPOS_STAND);
		AI.PushGoal("+backoff",1,10,0,AI_BACKOFF_FROM_TARGET+AI_MOVE_BACKWARD);
	AI.EndGoalPipe();


	AI.BeginGoalPipe("test_backoff2"); AI.PushGoal("firecmd",0,1); 
	AI.PushGoal("strafe",0,5,0); AI.PushGoal("run",0,1); 
	AI.PushGoal("+bodypos",0,BODYPOS_STAND); AI.PushGoal("+backoff",1,5,0); 
	AI.EndGoalPipe();


  AI.BeginGoalPipe("test_hide_strafe");
		AI.PushGoal("strafe",0,5,0);
		AI.PushGoal("hide",1,15,HM_NEAREST + HM_BACK);
		AI.PushGoal("timeout",1,1,1);
	AI.EndGoalPipe();
	
	
	AI.BeginGoalPipe("test_hide_strafe_run_strafe");
		AI.PushGoal("run",0,1);
		AI.PushGoal("strafe",1,4,1,0);
		AI.PushGoal("hide",1,50,HM_NEAREST);
		AI.PushGoal("timeout",1,1,1);
	AI.EndGoalPipe();
	
	AI.BeginGoalPipe("test_goto_refpoint");
		AI.PushGoal("bodypos",0,BODYPOS_STAND);
		AI.PushGoal("run",0,1);
		AI.PushGoal("locate", 1, "refpoint");
		AI.PushGoal("approach",1,0.1,AILASTOPRES_USE+AILASTOPRES_LOOKAT,0.1);
		AI.PushGoal("run",0,0);
	AI.EndGoalPipe();
	
	AI.BeginGoalPipe("test_hide_helper");
		AI.PushGoal("signal",1,1,"start",0);
		AI.PushGoal("hide",1,10,HM_NEAREST_TOWARDS_TARGET,0,2);
		AI.PushGoal("branch",0,"END", IF_CANNOT_HIDE);
		AI.PushGoal("bodypos",1,BODYPOS_CROUCH);
		AI.PushGoal("signal",1,1,"HideSucceeded",0);
		AI.PushGoal("timeout",1,1,1);
		AI.PushGoal("bodypos",1,BODYPOS_STAND);
		AI.PushLabel("END");
		AI.PushGoal("timeout",1,1,1);
		AI.PushGoal("signal",1,1,"finish",0);
	AI.EndGoalPipe();
		
		
	-- Look at the refpoint
	AI.BeginGoalPipe("test_lookat_sequence");
		AI.PushGoal("acqtarget",0,"");
		AI.PushGoal("timeout",1,1.5,1.5);
		AI.PushGoal("locate",0,"refpoint");
		AI.PushGoal("lookat",0,0,0,true,1);
		AI.PushGoal("timeout",1,5,5);
		AI.PushGoal("lookat",0,-500,0,true,1);   --- AHAR!
		AI.PushGoal("locate",0,"atttarget");
		AI.PushGoal("+lookat",1,0,0,true);
		AI.PushGoal("+timeout",1,0.5,0.5);
		AI.PushGoal("animation", 1, AIANIM_SIGNAL, "pointLeft");
		AI.PushGoal("locate",0,"refpoint");
		AI.PushGoal("+lookat",1,0,0,true);
		AI.PushGoal("+timeout",1,0.5,1.0);	
		AI.PushGoal("locate",0,"atttarget");
		AI.PushGoal("acqtarget",0,"");
	AI.EndGoalPipe();
	
	AI.BeginGoalPipe("test_tactical");
		AI.PushGoal("tacticalpos", 1, "DirectnessTest"); 
	AI.EndGoalPipe();
	
	
	AI.BeginGoalPipe("test_DirectnessTest");
		AI.PushGoal("run",0,1);
		AI.PushGoal("tacticalpos",1, "DirectnessTest");
		AI.PushGoal("timeout",1,0.5,0.5);
	AI.EndGoalPipe();

	AI.BeginGoalPipe("test_RefPointHideTest");
		AI.PushGoal("run",0,1);
		AI.PushGoal("tacticalpos",1,"RefPointHideTest");
		AI.PushGoal("timeout",1,2,2);
	AI.EndGoalPipe();
	
	AI.BeginGoalPipe("test_DensityTest");
		AI.PushGoal("run",0,1);
		AI.PushGoal("tacticalpos",1,"DensityTest");
		AI.PushGoal("timeout",1,2,2);
	AI.EndGoalPipe();
	
	AI.BeginGoalPipe("test_randomTest");
		AI.PushGoal("run",0,1);
		AI.PushGoal("tacticalpos",1,"RandomTest");
		AI.PushGoal("timeout",1,2,2);
	AI.EndGoalPipe();

	AI.BeginGoalPipe("test_visibilityTest");
		AI.PushGoal("run",0,1);
		AI.PushGoal("tacticalpos",1,"VisibilityTest");
		AI.PushGoal("timeout",1,2,2);
	AI.EndGoalPipe();
	
	AI.BeginGoalPipe("test_hostilesTest");
		AI.PushGoal("run",0,1);
		AI.PushGoal("tacticalpos",1,"HostilesTest");
		AI.PushGoal("timeout",1,2,2);
	AI.EndGoalPipe();
	
	AI.BeginGoalPipe("test_lineOfFireTest");
		AI.PushGoal("run",0,1);
		AI.PushGoal("tacticalpos",1,"LineOfFireTest");
		AI.PushGoal("timeout",1,2,2);
	AI.EndGoalPipe();
	
	AI.BeginGoalPipe("test_simpleHide");
		AI.PushGoal("run",0,1);
		AI.PushGoal("tacticalpos",1,"SimpleHide");
		AI.PushGoal("timeout",1,2,2);
	AI.EndGoalPipe();

	AI.BeginGoalPipe("test_reachableGridTest");
		AI.PushGoal("run",0,1);
		AI.PushGoal("tacticalpos",1,"ReachableGridTest");
		AI.PushGoal("timeout",1,2,2);
	AI.EndGoalPipe();

	AI.BeginGoalPipe("test_simpleSquadmate");
		AI.PushGoal("run",0,1);
	  --AI.PushGoal("strafe",0,99,99,99);
		AI.PushGoal("tacticalpos",1,"SimpleSquadmate");
		AI.PushGoal("timeout",1,2,2);
		--AI.PushGoal("firecmd",0,1);
	AI.EndGoalPipe();
	
	AI.BeginGoalPipe("test_look");
		AI.PushGoal("tacticalpos",1,"DirectnessTest",AI_REG_REFPOINT);
		AI.PushGoal("look",1,AILOOKMOTIVATION_GLANCE,true,AI_REG_REFPOINT);
		AI.PushGoal("timeout",1,2,2);
	AI.EndGoalPipe();
	
	AI.BeginGoalPipe("test_look_ref");
		AI.PushGoal("look",1,AILOOKMOTIVATION_GLANCE,true,AI_REG_REFPOINT);
	AI.EndGoalPipe();
	
	AI.BeginGoalPipe("test_lookEntity");
		AI.PushGoal("locate", 0, "AIAnchor1", 1000);
		AI.PushGoal("look",1,AILOOKMOTIVATION_GLANCE,false,AI_REG_LASTOP);
		AI.PushGoal("timeout",1,3,3);
	AI.EndGoalPipe();
	
	AI.BeginGoalPipe("test_stick");
		AI.PushGoal("stick",1,1,0,2);	-- get to within 1 metre of a moving target
	AI.EndGoalPipe();

	AI.CreateGoalPipe("do_nothing");
	AI.PushGoal("do_nothing","firecmd",0,0);

	AI.CreateGoalPipe("stance_relaxed");
	AI.PushGoal("stance_relaxed", "bodypos", 0, 3);

	AI.CreateGoalPipe("clear_all");
	AI.PushGoal("clear_all", "clear", 0,1);

	AI.CreateGoalPipe("action_weaponholster");
	AI.PushGoal("action_weaponholster", "signal", 1, 10, "HOLSTERITEM_TRUE", SIGNALFILTER_SENDER);
	
	AI.CreateGoalPipe("action_weapondraw");
	AI.PushGoal("action_weapondraw", "signal", 1, 10, "HOLSTERITEM_FALSE", SIGNALFILTER_SENDER);

	-- use this goal pipe to insert it as a dummy pipe in actions which are executed inside their signal handler
	AI.CreateGoalPipe("action_dummy");
	AI.PushGoal("action_dummy","timeout",1,0.1);

	AI.CreateGoalPipe("stand_only");
	--AI.PushGoal("stand_only","timeout",1,2,4);
	--AI.PushGoal("stand_only","signal",0,1,"DO_SOMETHING_IDLE",0);	-- do something (or not)

	AI.CreateGoalPipe("pause_shooting");
	AI.PushGoal("pause_shooting","firecmd",0,0);
	AI.PushGoal("pause_shooting","timeout",1,0.5,1.5);
	AI.PushGoal("pause_shooting","firecmd",0,1);

	AI.CreateGoalPipe("stop_fire");
	AI.PushGoal("stop_fire","firecmd",1,0);

	AI.CreateGoalPipe("start_fire");
	AI.PushGoal("start_fire","firecmd",1,1);

	AI.CreateGoalPipe("setup_idle");	
	AI.PushGoal("setup_idle","firecmd",0,0);	
	AI.PushGoal("setup_idle","bodypos",0,BODYPOS_RELAX);	
	AI.PushGoal("setup_idle","run",0,0);	
	--AI.PushGoal("setup_idle","firecmd",0,0);	

	AI.CreateGoalPipe("setup_combat");	
--	AI.PushGoal("setup_combat","bodypos",0,BODYPOS_STAND);
	AI.PushGoal("setup_combat","run",0,1);
	
	AI.BeginGoalPipe("fn_just_shoot");
		AI.PushGoal("locate", 0, "probtarget");
		AI.PushGoal("+adjustaim",0,0,1);
		AI.PushGoal("firecmd",0,FIREMODE_BURST);
		AI.PushGoal("timeout",1,2.0,4.0);
		AI.PushGoal("firecmd",0,0);
		AI.PushGoal("timeout",1,0.4,0.6);
		AI.PushGoal("+signal",0,1,"COMBAT_READABILITY",0);
	AI.EndGoalPipe();

	---------------------------------------------
	AI.BeginGoalPipe("fn_simple_bulletreaction");
		AI.PushGoal("firecmd",0,FIREMODE_BURST);
		AI.PushGoal("run", 0, 2,1,6);
		AI.PushGoal("bodypos",1,BODYPOS_STAND, 1);
		AI.PushGoal("strafe",0,4,2);
		AI.PushGoal("locate",0,"probtarget");
		AI.PushGoal("+seekcover", 1, COVER_HIDE, 2.5, 2, 1);
		AI.PushGoal("signal",0,1,"FLASHBANG_GONE",0);
	AI.EndGoalPipe();

	---------------------------------------------
	AI.BeginGoalPipe("fn_melee");
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
	AI.BeginGoalPipe("fn_melee_pause");
		AI.PushGoal("timeout",1,0.2);
		AI.PushGoal("firecmd",0,0);
		AI.PushGoal("signal",0,1,"MELEE_DONE",0);
	AI.EndGoalPipe();



	---------------------------------------------
	-- Friendly NPC Idle
	---------------------------------------------

	AI.BeginGoalPipe("fn_simple_flinch");
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
	AI.BeginGoalPipe("fn_protect_path");
		AI.PushGoal("firecmd",0,1);
		AI.PushGoal("run",0,2,1,7);
		AI.PushGoal("signal",0,1,"CHOOSE_DEFEND_POS",0);
		AI.PushGoal("+locate",0,"refpoint");
		AI.PushGoal("+approach",1,1.5,AILASTOPRES_USE+AI_REQUEST_PARTIAL_PATH,15);
		AI.PushGoal("locate", 0, "probtarget");
		AI.PushGoal("+adjustaim",0,0,1);
		AI.PushGoal("firecmd",0,FIREMODE_BURST);
		AI.PushGoal("timeout",1,1.0,2.0);
		AI.PushGoal("firecmd",0,0);
		AI.PushGoal("timeout",1,0.3,0.5);
		AI.PushGoal("+signal",0,1,"DEFEND_CYCLE",0);
	AI.EndGoalPipe();




	---------------------------------------------
	-- Suit Attack
	---------------------------------------------

	---------------------------------------------
	AI.BeginGoalPipe("su_fast_close_range");
		AI.PushGoal("signal",0,1,"SETUP_CQB",0);
		AI.PushGoal("bodypos",0,BODYPOS_STAND,1);
		AI.PushGoal("strafe",0,10,10);
		AI.PushGoal("run",0,0);--1);
		AI.PushGoal("firecmd",0,1);

		AI.PushGoal("signal",0,1,"SET_REFPOINT_CQB",0);
		
		AI.PushGoal("branch", 1, "HIDE", IF_SEES_TARGET, 20.0, BODYPOS_CROUCH);
		AI.PushGoal( "branch", 1, "MOVE", BRANCH_ALWAYS);

		AI.PushLabel("HIDE");
			AI.PushGoal("locate",0,"probtarget");
			AI.PushGoal("+seekcover", 1, COVER_HIDE, 6.0, 3, 1+2);

		AI.PushLabel("MOVE");
			-- still not exposed to target, try to move a bit.
			AI.PushGoal("branch", 1, "OTHER_DIST", IF_RANDOM, 0.5);
				AI.PushGoal("locate",0,"refpoint");
				AI.PushGoal("+approach",1,-3,AILASTOPRES_USE,15.0);
				AI.PushGoal( "branch", 1, "DONE", BRANCH_ALWAYS);
			AI.PushLabel("OTHER_DIST");
				AI.PushGoal("branch", 1, "OTHER_DIST2", IF_RANDOM, 0.5);
				AI.PushGoal("locate",0,"refpoint");
				AI.PushGoal("+approach",1,-5,AILASTOPRES_USE,15.0);
				AI.PushGoal( "branch", 1, "DONE", BRANCH_ALWAYS);
			AI.PushLabel("OTHER_DIST2");
				AI.PushGoal("locate",0,"refpoint");
				AI.PushGoal("+approach",1,-7,AILASTOPRES_USE,15.0);

		AI.PushLabel("DONE");
		AI.PushGoal("signal",0,1,"COVER_NORMALATTACK",0);
	AI.EndGoalPipe();

	---------------------------------------------
	AI.BeginGoalPipe("su_fast_close_range_dodge");
		AI.PushGoal("signal",0,1,"SETUP_CQB",0);
		AI.PushGoal("bodypos",0,BODYPOS_STAND,1);
		AI.PushGoal("strafe",0,10,10);
		AI.PushGoal("run",0,1);
		AI.PushGoal("firecmd",0,1);

		AI.PushGoal("signal",0,1,"SET_REFPOINT_CQB",0);
		AI.PushGoal("locate",0,"refpoint");
		AI.PushGoal("+approach",1,-5,AILASTOPRES_USE,15.0);
		AI.PushGoal( "branch", 1, "DONE", BRANCH_ALWAYS);

		AI.PushGoal("signal",0,1,"COVER_NORMALATTACK",0);
	AI.EndGoalPipe();

	---------------------------------------------
	AI.BeginGoalPipe("su_fast_seek");
		AI.PushGoal("signal",0,1,"SETUP_CQB",0);
		AI.PushGoal("bodypos",0,BODYPOS_STAND,1);
		AI.PushGoal("strafe",0,2,2);
		AI.PushGoal("run",0,1);
		AI.PushGoal("locate", 0,"probtarget_in_territory");
		AI.PushGoal("+approach",1,15,AILASTOPRES_USE,15.0);

		AI.PushGoal("run",0,0);
		AI.PushGoal("firecmd",0,FIREMODE_AIM);
		AI.PushGoal("strafe",0,10,10);
		AI.PushGoal("bodypos",0,BODYPOS_STEALTH,1);
		AI.PushGoal("locate", 0,"probtarget_in_territory");
		AI.PushGoal("+approach",1,1,AILASTOPRES_USE,15.0);

		AI.PushGoal("signal",0,1,"SET_REFPOINT_CQB",0);
		AI.PushGoal("locate",0,"refpoint");
		AI.PushGoal("+approach",1,-7,AILASTOPRES_USE,15.0);

		AI.PushGoal("signal",0,1,"COVER_NORMALATTACK",0);
	AI.EndGoalPipe();

	---------------------------------------------
	AI.BeginGoalPipe("su_sniper");
		AI.PushGoal("signal",0,1,"SETUP_SNIPER",0);
		AI.PushGoal("firecmd",0,FIREMODE_BURST_DRAWFIRE);
		AI.PushGoal("locate",0,"probtarget");
		AI.PushGoal("+adjustaim",0,0,1);
		AI.PushGoal("timeout",1,5,7);
		AI.PushGoal("clear",0,0);
		AI.PushGoal("signal",0,1,"UNDO_SNIPER",0);
		AI.PushGoal("firecmd",0,0);

		AI.PushGoal("signal",0,1,"SET_REFPOINT_SNIPER",0);
		AI.PushGoal("bodypos",0,BODYPOS_STAND,1);
		AI.PushGoal("strafe",0,2,2);
		AI.PushGoal("run",0,1);
		AI.PushGoal("locate",0,"refpoint");
		AI.PushGoal("+approach",1,-10,AILASTOPRES_USE,15.0);
		AI.PushGoal("locate",0,"probtarget");
		AI.PushGoal("+seekcover", 1, COVER_UNHIDE, 4.0, 3, 1+2);
		
		AI.PushGoal("signal",0,1,"COVER_NORMALATTACK",0);
	AI.EndGoalPipe();

	---------------------------------------------
	AI.BeginGoalPipe("su_sniper_move");
		AI.PushGoal("signal",0,1,"UNDO_SNIPER",0);
		AI.PushGoal("firecmd",0,0);
		AI.PushGoal("signal",0,1,"SET_REFPOINT_SNIPER",0);
		AI.PushGoal("bodypos",0,BODYPOS_STEALTH,1);
		AI.PushGoal("strafe",0,2,2);
		AI.PushGoal("run",0,1);
		AI.PushGoal("locate",0,"refpoint");
		AI.PushGoal("+approach",1,-10,AILASTOPRES_USE,15.0);
		AI.PushGoal("locate",0,"probtarget");
		AI.PushGoal("+seekcover", 1, COVER_UNHIDE, 4.0, 3, 1+2);

		AI.PushGoal("signal",0,1,"COVER_NORMALATTACK",0);
	AI.EndGoalPipe();

	---------------------------------------------
	AI.BeginGoalPipe("su_sniper_seek");
		AI.PushGoal("signal",0,1,"UNDO_SNIPER",0);
		AI.PushGoal("firecmd",0,0);
		AI.PushGoal("bodypos",0,BODYPOS_STAND,1);
		AI.PushGoal("strafe",0,2,2);
		AI.PushGoal("run",0,1);
		AI.PushGoal("approach",1,-15,AILASTOPRES_USE,15.0);
		AI.PushGoal("locate",0,"probtarget");
		AI.PushGoal("+seekcover", 1, COVER_UNHIDE, 4.0, 3, 1+2);

		AI.PushGoal("signal",0,1,"SETUP_SNIPER",0);
		AI.PushGoal("firecmd",0,FIREMODE_AIM);
		AI.PushGoal("locate",0,"probtarget");
		AI.PushGoal("+adjustaim",0,0,1);
		AI.PushGoal("timeout",1,2,3);
		AI.PushGoal("signal",0,1,"UNDO_SNIPER",0);
		AI.PushGoal("firecmd",0,0);

		AI.PushGoal("signal",0,1,"COVER_NORMALATTACK",0);
	AI.EndGoalPipe();



	---------------------------------------------
	-- Suit Idle
	---------------------------------------------

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
	-- Suit Threatened
	---------------------------------------------

	AI.BeginGoalPipe("su_fast_threatened");
		AI.PushGoal("strafe",0,100,100);
		AI.PushGoal("bodypos",0,BODYPOS_STAND,1);
		AI.PushGoal("run",0,0);
		AI.PushGoal("firecmd",0,FIREMODE_AIM);
		AI.PushGoal("locate", 0,"probtarget_in_territory");
		AI.PushGoal("+approach",1,-20,AILASTOPRES_USE,15.0);
		AI.PushGoal("firecmd",0,FIREMODE_AIM);
		AI.PushGoal("signal",0,1,"INVESTIGATE_READABILITY",0);
		AI.PushGoal("lookaround",1,60,2,4,2,AI_BREAK_ON_LIVE_TARGET);
		AI.PushGoal("signal",0,1,"INVESTIGATE_READABILITY",0);
	AI.EndGoalPipe();

	---------------------------------------------
	AI.BeginGoalPipe("su_fast_threatened_sniper");
		AI.PushGoal("locate",0,"probtarget");
		AI.PushGoal("+adjustaim",0,0,1);
		AI.PushGoal("timeout",1,1,2);
		AI.PushGoal("strafe",0,100,100);
		AI.PushGoal("bodypos",0,BODYPOS_STAND,1);
		AI.PushGoal("run",0,0);
		AI.PushGoal("firecmd",0,FIREMODE_AIM);
		AI.PushGoal("locate", 0,"probtarget_in_territory");
		AI.PushGoal("+approach",1,-10,AILASTOPRES_USE,15.0);
	AI.EndGoalPipe();



	---------------------------------------------
	-- Watch Tower Guard
	---------------------------------------------

	AI.BeginGoalPipe("wtg_watch");
		-- approach the watch pos anchor
		AI.PushGoal("bodypos",0,BODYPOS_STAND);
		AI.PushGoal("approach",1,0,AILASTOPRES_USE);
		-- look at the direction of the anchor (set as refpoint)
		AI.PushGoal("signal",0,1,"SET_LOOKAT",0);
		AI.PushGoal("locate",0,"refpoint");
		AI.PushGoal("lookat",0,0,0,1);
		AI.PushGoal("timeout",1,1,2);
		AI.PushGoal("clear",0,0);
		AI.PushGoal("lookaround",1,45,3,4,7,AI_BREAK_ON_LIVE_TARGET);
		AI.PushGoal("signal",0,1,"CHOOSE_WATCH_SPOT",0);
	AI.EndGoalPipe();

	---------------------------------------------
	AI.BeginGoalPipe("wtg_duck_and_hide");
		AI.PushGoal("bodypos",0,BODYPOS_CROUCH);
		AI.PushGoal("firecmd",0,0);
		AI.PushGoal("timeout",1,2,6);
		AI.PushGoal("signal",0,1,"DUCK_AND_HIDE_DONE",0);
	AI.EndGoalPipe();


	---------------------------------------
	--- SuperDumbIdle
	--------------------------------------

	AI.BeginGoalPipe("testAdvance");
		AI.PushGoal("bodypos",1,BODYPOS_STAND);
		AI.PushGoal("run", 0, 1);
		AI.PushGoal("firecmd",0,0);
		AI.PushGoal("locate", 0, "refpoint");
		AI.PushGoal("approach", 1, 1.0, AILASTOPRES_USE);
		AI.PushGoal("adjustaim",0,0,1);
		AI.PushGoal("firecmd",0,1);
		AI.PushGoal("timeout", 1, 10);
	AI.EndGoalPipe();

end