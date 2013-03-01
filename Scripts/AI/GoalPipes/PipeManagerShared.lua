
function PipeManager:OnInitShared()
	AI.LogEvent("ON INIT SHARED");
		
	AI.CreateGoalPipe("standingthere");
	AI.PushGoal("standingthere","bodypos",0,0);
	AI.PushGoal("standingthere","firecmd",0,0);

	AI.CreateGoalPipe("DropBeaconAt");
	AI.PushGoal("DropBeaconAt","form",1,"beacon");
	
	AI.CreateGoalPipe("DropBeaconTarget");
	AI.PushGoal("DropBeaconTarget","form",0,"beacon");
	AI.PushGoal("DropBeaconTarget","locate",0,"beacon");
	AI.PushGoal("DropBeaconTarget","acqtarget",0,"");
		
end

