
function PipeManager:InitReusable()

	AI.CreateGoalPipe("stance_relaxed");
	AI.PushGoal("stance_relaxed", "bodypos", 0, 3);

	AI.CreateGoalPipe("look_at_lastop");
	AI.PushGoal("look_at_lastop","lookat",1,0,0,1);
	
	AI.CreateGoalPipe("short_look_at_lastop");
	AI.PushGoal("short_look_at_lastop","lookat",1,0,0,1);
	AI.PushGoal("short_look_at_lastop","+timeout",1,1.1,1.4);
	AI.PushGoal("short_look_at_lastop","+lookat",1,-500);

	
	AI.BeginGoalPipe("fire_pause");
		AI.PushGoal("firecmd",0,FIREMODE_OFF);
		AI.PushGoal("timeout",1,.2);
		AI.PushGoal("firecmd",0,FIREMODE_BURST);
	AI.EndGoalPipe();	


	AI.CreateGoalPipe("do_nothing");
	AI.PushGoal("do_nothing","firecmd",0,0);	

	AI.CreateGoalPipe("clear_all");
	AI.PushGoal("clear_all", "clear", 0,1);

	AI.CreateGoalPipe("clear_goalpipes");
	AI.PushGoal("clear_goalpipes", "clear", 0);

	AI.CreateGoalPipe("devalue_target");
	AI.PushGoal("devalue_target", "devalue", 0,1);



	AI.CreateGoalPipe("acquire_target");
	AI.PushGoal("acquire_target","acqtarget",0,""); 

	AI.CreateGoalPipe("ignore_all");
	AI.PushGoal("ignore_all","ignoreall",0,1); 

	AI.CreateGoalPipe("ignore_none");
	AI.PushGoal("ignore_none","ignoreall",0,0); 



	AI.CreateGoalPipe("look_at_player_5sec");
	AI.PushGoal("look_at_player_5sec", "locate", 0, "player");
	AI.PushGoal("look_at_player_5sec", "+lookat", 0,0,0,true);
	AI.PushGoal("look_at_player_5sec", "+timeout",1,4.6,5.3);
	AI.PushGoal("look_at_player_5sec", "+lookat", 0,-500);

	AI.CreateGoalPipe("throw_grenade");
	AI.PushGoal("throw_grenade", "firecmd", 0, 0);
	AI.PushGoal("throw_grenade", "signal", 1, 1, "SMART_THROW_GRENADE", 0);
--	AI.PushGoal("throw_grenade", "timeout", 1, 2);
--	AI.PushGoal("throw_grenade", "signal", 1, 1, "SHARED_THROW_GRENADE_DONE", 0);

	-------------------------------------------------------
	AI.BeginGoalPipe("throw_grenade_execute");
		AI.PushGoal("ignoreall", 0, 1);
		AI.PushGoal("firecmd", 0, 0);
		AI.PushGoal("timeout", 1, .6);
		AI.PushGoal("firecmd", 0, FIREMODE_SECONDARY);
		AI.PushGoal("timeout", 1, 3);
		AI.PushGoal("firecmd", 0, FIREMODE_OFF);
		AI.PushGoal("ignoreall", 0, 0);
		AI.PushGoal("signal", 1, 1, "THROW_GRENADE_DONE", 0);
	AI.EndGoalPipe();

	AI.BeginGoalPipe("fire_mounted_weapon");
		AI.PushGoal("signal",0,1,"SET_MOUNTED_WEAPON_PERCEPTION",0);
		AI.PushLabel("LOOP");
		AI.PushGoal("firecmd", 0, FIREMODE_BURST_DRAWFIRE);
		AI.PushGoal("timeout", 1, 2,3);
		AI.PushGoal("signal", 1, 1, "CheckTargetInRange", 0);
		AI.PushGoal("timeout", 1, 2,3);
		AI.PushGoal("signal", 1, 1, "CheckTargetInRange", 0);
		AI.PushGoal("timeout", 1, 2,3);
		AI.PushGoal("signal", 1, 1, "CheckTargetInRange", 0);
		AI.PushGoal("timeout", 1, 2,3);
		AI.PushGoal("signal", 1, 1, "CheckTargetInRange", 0);
		AI.PushGoal("firecmd", 0, 0);
		AI.PushGoal("timeout", 1, 0.3, 1);
		AI.PushGoal("signal", 1, 1, "CheckTargetInRange", 0);
		AI.PushGoal("branch",1,"LOOP",BRANCH_ALWAYS);
	AI.EndGoalPipe();	

	AI.CreateGoalPipe("mounted_weapon_blind_fire");
	AI.PushGoal("mounted_weapon_blind_fire", "firecmd", 0, FIREMODE_FORCED);
	AI.PushGoal("mounted_weapon_blind_fire", "timeout", 1, 1.3, 1.8);
	AI.PushGoal("mounted_weapon_blind_fire", "firecmd", 0, 0);
	AI.PushGoal("mounted_weapon_blind_fire", "timeout", 1, 0.2, 0.4);
	AI.PushGoal("mounted_weapon_blind_fire", "signal", 1, 1, "CheckTargetInRange", 0);

	AI.BeginGoalPipe("mounted_weapon_look_around");
		AI.PushGoal("signal",0,1,"SET_MOUNTED_WEAPON_PERCEPTION",0);
		AI.PushGoal("locate",1,"refpoint");	
		AI.PushGoal("lookaround",1,30,2.2,10005,10010,AI_BREAK_ON_LIVE_TARGET + AILASTOPRES_USE);
		--AI.PushGoal("lookat",1,30,2.2,5,10,1);
	AI.EndGoalPipe();		
	

	AI.BeginGoalPipe("use_this_mounted_weapon");
		AI.PushGoal("run", 0, 1.5);
		AI.PushGoal("+bodypos", 0, BODYPOS_STAND);
		AI.PushGoal("+ignoreall", 0, 1);
			AI.PushGoal("+locate", 0, "refpoint" );
			AI.PushGoal("+animtarget", 0, 1, "none", 0, 2, 0 );
			AI.PushGoal("locate", 0, "animtarget" );
			AI.PushGoal("+approach", 1, 0, AILASTOPRES_USE );
		AI.PushGoal("branch", 1, 2, IF_LASTOP_SUCCEED);
			AI.PushGoal("ignoreall", 0, 0);
			AI.PushGoal("signal", 1, 1, "USE_MOUNTED_FAILED", 0);
		AI.PushGoal("timeout", 1, .1); --wait for being selected
		AI.PushGoal("bodypos", 0, BODYPOS_CROUCH);
		AI.PushGoal("ignoreall", 0, 0);
		AI.PushGoal("run", 0, 0);
		--AI.PushGoal("firecmd", 0, FIREMODE_CONTINUOUS);
		AI.PushGoal("signal", 1, 1, "LOOK_AT_MOUNTED_WEAPON_DIR", 0);
	AI.EndGoalPipe();	
	


	-------------------
	----
	---- COVER
	----
	--------------------



	AI.CreateGoalPipe("acquire_beacon");
	AI.PushGoal("acquire_beacon","locate",0,"beacon");
	AI.PushGoal("acquire_beacon","acqtarget",0,"");


	-- approaching dead body (heard falling sound)
	---------------------------------------------
	AI.BeginGoalPipe("approach_dead");
		AI.PushGoal("timeout",1,0.2,0.4);
		AI.PushGoal("lookat",1,0,0,1);
		AI.PushGoal("timeout",1,0.2,0.4);
		AI.PushGoal("bodypos",0,BODYPOS_STAND);	
		AI.PushGoal("run",0,0);		
		--AI.PushGoal("locate",0,"refpoint");	
		--AI.PushGoal("approach",0,2,AILASTOPRES_USE);
		
		AI.PushGoal("locate",0,"refpoint");
		AI.PushGoal("approach",1,2,AILASTOPRES_USE,2.0);
		
--		AI.BeginGroup();
--			AI.PushGoal("locate",0,"refpoint");					
--			AI.PushGoal("approach",0,2,AILASTOPRES_USE,2.0);
--			AI.PushGoal("timeout",0,2,3);
--		AI.EndGroup();
--		AI.PushGoal("wait", 1, WAIT_ANY_2);
		AI.PushGoal("clear",0,0);
		AI.PushGoal("signal",1,1,"INVESTIGATE_DONE",0);
	AI.EndGoalPipe();	

	---------------------------------------------

	AI.CreateGoalPipe("check_dead");
--	AI.PushGoal("check_dead","acqtarget",0,"");
--	AI.PushGoal("check_dead","timeout",1,0.2,0.4);
--	AI.PushGoal("check_dead","lookat",1,0,0,1);
--	AI.PushGoal("check_dead","timeout",1,0.2,0.4);
	AI.PushGoal("check_dead","bodypos",0,BODYPOS_STAND);	
	AI.PushGoal("check_dead","run",0,2);		
	AI.PushGoal("check_dead","locate",0,"refpoint");	
	AI.PushGoal("check_dead","approach",0,2,AILASTOPRES_USE);
	-- loop until the target is visible
	AI.PushLabel("check_dead", "VISIBLE_LOOP");
		AI.PushGoal("check_dead","locate",0,"refpoint");	
		AI.PushGoal("check_dead","branch", 1, "TARGET_VISIBLE", IF_SEES_LASTOP, 50.0);
		AI.PushGoal("check_dead","branch", 1, "VISIBLE_LOOP", IF_ACTIVE_GOALS);	
	-- If the following gets executed the approach finished already while approaching fast.	
	AI.PushGoal("check_dead","branch", 1, "APPROACH_DONE", BRANCH_ALWAYS);
	-- approach more cautiously	
	AI.PushLabel("check_dead", "TARGET_VISIBLE");
	AI.PushGoal("check_dead","bodypos",0,BODYPOS_STEALTH);	
	AI.PushGoal("check_dead","run",0,1);
--	AI.PushGoal("check_dead","lookat",0,0,0,1);
--	AI.PushGoal("check_dead","timeout",1,0.3,0.8);
	AI.PushLabel("check_dead", "SEEK_LOOP");
		AI.PushGoal("check_dead","lookat",0,-90,90,0,1);
		AI.PushGoal("check_dead","timeout",1,.61,.73);
		AI.PushGoal("check_dead","lookat",1,-790);	
	AI.PushGoal("check_dead","branch", 0, "SEEK_LOOP", IF_ACTIVE_GOALS);	
	AI.PushLabel("check_dead", "APPROACH_DONE");
	-- At the target, check it.	
	AI.PushGoal("check_dead","bodypos",0,BODYPOS_CROUCH);	
	AI.PushGoal("check_dead","signal",1,1,"CHECKING_DEAD",0);
	AI.PushGoal("check_dead","locate",0,"beacon");	
	AI.PushGoal("check_dead","lookat",1,0,0,1);
	AI.PushGoal("check_dead","timeout",1,1,2);	
	AI.PushGoal("check_dead","lookat",0,-90,90);
	AI.PushGoal("check_dead","timeout",1,0.6,0.8);	
	AI.PushGoal("check_dead","lookat",0,-90,90);
	AI.PushGoal("check_dead","timeout",1,0.6,0.8);
	AI.PushGoal("check_dead","signal",1,1,"BE_ALERTED",0);

	---------------------------------------------
	AI.BeginGoalPipe("check_sleeping");
		AI.PushGoal("bodypos",0,BODYPOS_STAND);	
		AI.PushGoal("run",0,2);		
		AI.PushGoal("locate",0,"refpoint");	
		AI.PushGoal("approach",0,2,AILASTOPRES_USE);
		-- loop until the target is visible
		AI.PushLabel("VISIBLE_LOOP");
			AI.PushGoal("locate",0,"refpoint");	
			AI.PushGoal("branch", 1, "TARGET_VISIBLE", IF_SEES_LASTOP, 50.0);
			AI.PushGoal("branch", 1, "VISIBLE_LOOP", IF_ACTIVE_GOALS);	
		-- If the following gets executed the approach finished already while approaching fast.	
		AI.PushGoal("branch", 1, "APPROACH_DONE", BRANCH_ALWAYS);
		-- approach more cautiously	
		AI.PushLabel("TARGET_VISIBLE");
		AI.PushGoal("bodypos",0,BODYPOS_STEALTH);	
		AI.PushGoal("run",0,1);
		AI.PushLabel( "SEEK_LOOP");
			AI.PushGoal("lookat",0,-90,90,0,1);
			AI.PushGoal("timeout",1,.61,.73);
			AI.PushGoal("lookat",1,-790);	
		AI.PushGoal("branch", 0, "SEEK_LOOP", IF_ACTIVE_GOALS);	
		AI.PushLabel("APPROACH_DONE");
		-- At the target, check it.	
		AI.PushGoal("bodypos",0,BODYPOS_CROUCH);	
		AI.PushGoal("signal",1,1,"CHECKING_DEAD",0);
		AI.PushGoal("locate",0,"beacon");	
		AI.PushGoal("lookat",1,0,0,1);
		AI.PushGoal("timeout",1,1,2);	
		AI.PushGoal("lookat",0,-90,90);
		AI.PushGoal("timeout",1,0.6,0.8);	
		AI.PushGoal("lookat",0,-90,90);
		AI.PushGoal("timeout",1,0.6,0.8);
		AI.PushGoal("signal",1,1,"CHECK_DONE",0);
	AI.EndGoalPipe();

	-- go to tag 


	---------------------------------------
	---
	--- orders goalpipes
	---
	--------------------------------------

	AI.CreateGoalPipe("random_reacting_timeout");
	AI.PushGoal("random_reacting_timeout", "timeout", 1, 0.1, 0.4);


	AI.CreateGoalPipe("order_timeout");
	AI.PushGoal("order_timeout", "signal", 0, 10, "order_timeout_begin", SIGNALFILTER_SENDER);
	AI.PushGoal("order_timeout", "timeout", 1, 0.3, 1.0);
	AI.PushGoal("order_timeout", "signal", 0, 10, "ORD_DONE", SIGNALFILTER_LEADER);
	AI.PushGoal("order_timeout", "signal", 0, 10, "order_timeout_end", SIGNALFILTER_SENDER);

	
	AI.CreateGoalPipe("bridge_destroyed_init");
	AI.PushGoal("bridge_destroyed_init", "clear", 1, 1);
	AI.PushGoal("bridge_destroyed_init", "locate", 0, "LeaderA_P21");
	AI.PushGoal("bridge_destroyed_init", "acqtarget", 0, "");
	AI.PushGoal("bridge_destroyed_init", "bodypos", 0, BODYPOS_CROUCH);
	AI.PushGoal("bridge_destroyed_init", "timeout", 1, 0.1, 0.4);
	AI.PushGoal("bridge_destroyed_init", "devalue", 0);
	AI.PushGoal("bridge_destroyed_init", "lookaround", 1, 60);
	AI.PushGoal("bridge_destroyed_init", "timeout", 1, 0.1, 0.2);
	AI.PushGoal("bridge_destroyed_init", "random", 0, -2, 60);
	AI.PushGoal("bridge_destroyed_init", "run", 0, 1.5);

	AI.CreateGoalPipe("bridge_destroyed");
	AI.PushGoal("bridge_destroyed", "locate", 0, "LeaderA_P15");
	AI.PushGoal("bridge_destroyed", "acqtarget", 0, "");
	AI.PushGoal("bridge_destroyed", "approach", 0, 15);
	AI.PushGoal("bridge_destroyed", "bodypos", 0, BODYPOS_STAND);
	AI.PushGoal("bridge_destroyed", "timeout", 1, 0.1, 0.2);
	AI.PushGoal("bridge_destroyed", "devalue", 0);
	AI.PushGoal("bridge_destroyed", "lookaround", 1, 90);
	AI.PushGoal("bridge_destroyed", "timeout", 1, 0.1, 0.2);
	AI.PushGoal("bridge_destroyed", "branch", 0, 1);
	AI.PushGoal("bridge_destroyed", "signal", 1, 1, "OnStopPanicking", SIGNALFILTER_SENDER);
	AI.PushGoal("bridge_destroyed", "random", 0, -4, 95);
	AI.PushGoal("bridge_destroyed", "run", 0, 0);
	AI.PushGoal("bridge_destroyed", "random", 0, -6, 100);
	AI.PushGoal("bridge_destroyed", "branch", 0, 1);
	AI.PushGoal("bridge_destroyed", "clear", 1, 1);
	AI.PushGoal("bridge_destroyed", "signal", 1, 1, "OnStopPanicking", SIGNALFILTER_SENDER);
	AI.PushGoal("bridge_destroyed", "clear", 0, 1);

	AI.CreateGoalPipe("bridge_destroyed_wait");
	AI.PushGoal("bridge_destroyed_wait", "bodypos", 0, BODYPOS_CROUCH);
	AI.PushGoal("bridge_destroyed_wait", "timeout", 1, 0.1, 0.4);
	AI.PushGoal("bridge_destroyed_wait", "lookaround", 1, 60);
	AI.PushGoal("bridge_destroyed_wait", "timeout", 1, 0.5, 1);
	AI.PushGoal("bridge_destroyed_wait", "random", 0, -2, 90);
	AI.PushGoal("bridge_destroyed_wait", "bodypos", 0, BODYPOS_STAND);
	AI.PushGoal("bridge_destroyed_wait", "timeout", 1, 0.1, 0.4);

	AI.CreateGoalPipe("action_lookatpoint");
	AI.PushGoal("action_lookatpoint","locate",0,"refpoint");
	AI.PushGoal("action_lookatpoint","+lookat",1,0,0,true);
	AI.PushGoal("action_lookatpoint","timeout",1,0.2);
--	AI.PushGoal("action_lookatpoint","signal",0,10,"ACTION_DONE",SIGNALFILTER_SENDER);
	
	AI.CreateGoalPipe("action_resetlookat");
	AI.PushGoal("action_resetlookat","lookat",1,0,0);
--	AI.PushGoal("action_resetlookat","signal",0,10,"ACTION_DONE",SIGNALFILTER_SENDER);
	
	AI.CreateGoalPipe("action_weaponholster");
	AI.PushGoal("action_weaponholster", "signal", 1, 10, "HOLSTERITEM_TRUE", SIGNALFILTER_SENDER);
	
	AI.CreateGoalPipe("action_weapondraw");
	AI.PushGoal("action_weapondraw", "signal", 1, 10, "HOLSTERITEM_FALSE", SIGNALFILTER_SENDER);

	-- use this goal pipe to insert it as a dummy pipe in actions which are executed inside their signal handler
	AI.CreateGoalPipe("action_dummy");
	AI.PushGoal("action_dummy","timeout",1,0.1);

	AI.CreateGoalPipe("action_enter");
	AI.PushGoal("action_enter", "waitsignal", 0, "ENTERING_END");
	AI.PushGoal("action_enter", "signal", 1, 10, "SETUP_ENTERING", SIGNALFILTER_SENDER);
	AI.PushGoal("action_enter", "locate", 0, "animtarget");	-- the anim target is set by the vehicle code
	AI.PushGoal("action_enter", "run", 0, 1);
	AI.PushGoal("action_enter", "bodypos", 0, BODYPOS_STAND);
	AI.PushGoal("action_enter", "+approach", 1, 0, AILASTOPRES_USE + AI_STOP_ON_ANIMATION_START, 2);
	AI.PushGoal("action_enter", "branch", 1, "PATH_FOUND", NOT + IF_LASTOP_FAILED );
		AI.PushGoal("action_enter", "signal", 1, 1, "CANCEL_CURRENT", 0);
	AI.PushLabel("action_enter", "PATH_FOUND" );
	AI.PushGoal("action_enter", "timeout", 1, 0.1);
	AI.PushGoal("action_enter", "branch", 1, -1, IF_ACTIVE_GOALS);
	--AI.PushGoal("action_enter", "signal", 1, 10, "CHECK_INVEHICLE", SIGNALFILTER_SENDER);

	AI.CreateGoalPipe("action_enter_fast");
	AI.PushGoal("action_enter_fast", "waitsignal", 0, "ENTERING_END" );
	AI.PushGoal("action_enter_fast", "signal", 1, 10, "SETUP_ENTERING_FAST", SIGNALFILTER_SENDER);
	AI.PushGoal("action_enter_fast", "timeout", 1, 0.1);
	AI.PushGoal("action_enter_fast", "branch", 1, -1, IF_ACTIVE_GOALS);

	AI.CreateGoalPipe("action_exit");
	AI.PushGoal("action_exit", "waitsignal", 1, "EXITING_END", nil, 10.0 );

	AI.CreateGoalPipe("check_driver");
	AI.PushGoal("check_driver", "signal", 1, 1, "CHECK_DRIVER", SIGNALFILTER_SENDER);

	AI.CreateGoalPipe("action_unload");
	AI.PushGoal("action_unload", "waitsignal", 0, "UNLOAD_DONE", nil, 10.0);
	AI.PushGoal("action_unload", "signal", 1, 10, "DO_UNLOAD", SIGNALFILTER_SENDER);
	AI.PushGoal("action_unload", "timeout", 1, 0.1);
	AI.PushGoal("action_unload", "branch", 1, -1, IF_ACTIVE_GOALS);

	AI.CreateGoalPipe("stay_in_formation_moving");
	AI.PushGoal("stay_in_formation_moving","locate",0,"formation",1000);
	AI.PushGoal("stay_in_formation_moving","+acqtarget",0,"");
	AI.PushGoal("stay_in_formation_moving","+stick",1,0.0,AILASTOPRES_LOOKAT+AI_REQUEST_PARTIAL_PATH,STICK_SHORTCUTNAV);	

	AI.CreateGoalPipe("squad_form");
	--AI.PushGoal("squad_form","ignoreall",0,1);
	AI.PushGoal("squad_form","firecmd",0,0);
	AI.PushGoal("squad_form", "+bodypos", 0, BODYPOS_STAND);
	AI.PushGoal("squad_form","+locate",0,"formation");
	--AI.PushGoal("squad_form","+acqtarget",0,"");
	AI.PushGoal("squad_form","+stick",1,0,AI_REQUEST_PARTIAL_PATH+AILASTOPRES_USE,1);
	AI.PushGoal("squad_form","+ignoreall",0,0);
	AI.PushGoal("squad_form","+signal",1,1,"FORMATION_REACHED",SIGNALFILTER_SENDER);

	AI.BeginGoalPipe("vehicle_danger");
		AI.PushGoal("run",0,1);
		AI.PushGoal("bodypos",0,BODYPOS_STAND,1);
		AI.PushGoal("strafe",0,4,4);
		AI.PushGoal("firecmd",0,1);
		AI.PushGoal("locate",0,"vehicle_avoid");
		AI.PushGoal("+stick",0,0,AILASTOPRES_USE+AI_CONSTANT_SPEED,STICK_SHORTCUTNAV,10.0);--refpoint can be moved by another vehicle danger
		AI.PushGoal("waitsignal",1,"OnEndVehicleDanger",nil,6);		
		AI.PushGoal("clear",1,0);		
		AI.PushGoal("signal",0,1,"END_VEHICLE_DANGER",SIGNALFILTER_SENDER);
	AI.EndGoalPipe();

	AI.CreateGoalPipe("reset_lookat");
	AI.PushGoal("reset_lookat","lookat",1,-500); --reset look at 

	AI.CreateGoalPipe("vehicle_gunner_cover_fire");
	AI.PushGoal("vehicle_gunner_cover_fire","firecmd",1,FIREMODE_BURST);
	AI.PushGoal("vehicle_gunner_cover_fire","timeout",1,2,3);
	AI.PushGoal("vehicle_gunner_cover_fire","firecmd",1,0);
	AI.PushGoal("vehicle_gunner_cover_fire", "signal",0,1,"EXIT_VEHICLE_DONE",SIGNALFILTER_SENDER);

	AI.BeginGoalPipe("vehicle_gunner_shoot");
		AI.PushGoal("firecmd",1,FIREMODE_BURST_DRAWFIRE);
		AI.PushGoal("timeout",1,1);
		AI.PushGoal("signal",1,1,"INVEHICLEGUNNER_CHECKGETOFF",SIGNALFILTER_SENDER);
		AI.PushGoal("timeout",1,1);
		AI.PushGoal("signal",1,1,"INVEHICLEGUNNER_CHECKGETOFF",SIGNALFILTER_SENDER);
		AI.PushGoal("timeout",1,1);
		AI.PushGoal("signal",1,1,"INVEHICLEGUNNER_CHECKGETOFF",SIGNALFILTER_SENDER);
		AI.PushGoal("timeout",1,1);
		AI.PushGoal("signal",1,1,"INVEHICLEGUNNER_CHECKGETOFF",SIGNALFILTER_SENDER);
		AI.PushGoal("timeout",1,1);
		AI.PushGoal("signal",1,1,"INVEHICLEGUNNER_CHECKGETOFF",SIGNALFILTER_SENDER);
		AI.PushGoal("timeout",1,1);
		AI.PushGoal("signal",1,1,"INVEHICLEGUNNER_CHECKGETOFF",SIGNALFILTER_SENDER);
		AI.PushGoal("firecmd",1,0);
		AI.PushGoal("timeout",1,0.3,0.5);
	AI.EndGoalPipe();

	for direction=-110,110,10 do
		self:CreateLookAroundPipe("LookAround",direction,0.6,1.2);
		self:CreateLookAroundPipe("LookAroundFast",direction,0.3,0.6);
	end	

	AI.LogEvent("REUSABLE PIPES LOADED");
	
end


function PipeManager:CreateLookAroundPipe(pipename,direction,tmin,tmax)
	
	g_StringTemp1 = pipename..direction;
	
	AI.CreateGoalPipe(g_StringTemp1);			
	AI.PushGoal(g_StringTemp1,"lookat",1,direction);
	AI.PushGoal(g_StringTemp1,"timeout",1,tmin,tmax);
	AI.PushGoal(g_StringTemp1,"lookat",1,-20);
	AI.PushGoal(g_StringTemp1,"timeout",1,tmin,tmax);
	AI.PushGoal(g_StringTemp1,"lookat",1,40);
	AI.PushGoal(g_StringTemp1,"timeout",1,tmin,tmax);
	AI.PushGoal(g_StringTemp1,"signal",0,1,"LOOKING_DONE",SIGNALFILTER_SENDER);		
end

