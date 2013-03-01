MusicEndTheme = {
	type = "MusicEndTheme",

	Editor = {
		Icon="Music.bmp",
	},

	Properties = {
		bIndoorOnly=0,
		bOutdoorOnly=0,
		bStopAtOnce=0,
		bFadeOut=1,
		bPlayEnd=0,
		bPlayEndAtFadePoint=0,
		nEndLimitInSec=10,
		bEndEverything=0,
	},
	InsideArea=0,
}

function MusicEndTheme:OnSave(stm)
  stm.InsideArea = self.InsideArea
end

function MusicEndTheme:OnLoad(stm)
  self.InsideArea = stm.InsideArea
end

function MusicEndTheme:CliSrv_OnInit()
	self:RegisterForAreaEvents(1);
end

function MusicEndTheme:OnShutDown()
	self:RegisterForAreaEvents(0);
end

function MusicEndTheme:Client_OnEnterArea( player,areaId )
	--System.Log("enter music theme area "..self.Properties.sTheme);
	if (g_localActorId ~= player.id) then	return end;	    

	local bActivate=1;
	local Indoor=System.IsPointIndoors(System.GetViewCameraPos());	-- player:GetPos());
	
	if ((self.Properties.bIndoorOnly==1) and (Indoor==nil)) then
		bActivate=0;
	elseif ((self.Properties.bOutdoorOnly==1) and (Indoor~=nil)) then
		bActivate=0;
	end
	
	--System.Log("bActivate "..bActivate..", InsideArea "..self.InsideArea);
	if (bActivate==1) then --and (self.InsideArea==0)) then
		self.InsideArea=1;
		
		if (self.Properties.bStopAtOnce==1) then
			Sound.EndMusicTheme(0, self.Properties.nEndLimitInSec, self.Properties.bEndEverything);
		elseif (self.Properties.bFadeOut==1) then
			Sound.EndMusicTheme(1, self.Properties.nEndLimitInSec, self.Properties.bEndEverything);
		elseif (self.Properties.bPlayEnd==1) then
			Sound.EndMusicTheme(2, self.Properties.nEndLimitInSec, self.Properties.bEndEverything);
			elseif (self.Properties.bPlayEndAtFadePoint==1) then
			Sound.EndMusicTheme(3, self.Properties.nEndLimitInSec, self.Properties.bEndEverything);
		end;
			
			
		--Sound.SetMusicTheme(self.Properties.sTheme);
		--if (self.Properties.sDefaultMood ~= "") then
			--Sound.SetDefaultMusicMood(self.Properties.sDefaultMood);
		--end
		--if (self.Properties.sMood ~= "") then
			--Sound.SetMusicMood(self.Properties.sMood);
		--end
	elseif ((bActivate==0) and (self.InsideArea==1)) then
		self.InsideArea=0;
		--Sound.EndMusicTheme();
		--Sound.SetMusicTheme("");
	end
end

function MusicEndTheme:Event_Stop(  )
		if (self.Properties.bStopAtOnce==1) then
			Sound.EndMusicTheme(0, self.Properties.nEndLimitInSec, self.Properties.bEndEverything);
		elseif (self.Properties.bFadeOut==1) then
			Sound.EndMusicTheme(1, self.Properties.nEndLimitInSec, self.Properties.bEndEverything);
		elseif (self.Properties.bPlayEnd==1) then
			Sound.EndMusicTheme(2, self.Properties.nEndLimitInSec, self.Properties.bEndEverything);
			elseif (self.Properties.bPlayEndAtFadePoint==1) then
			Sound.EndMusicTheme(3, self.Properties.nEndLimitInSec, self.Properties.bEndEverything);
		end;
end

MusicEndTheme.Server={
	OnInit=function(self)
		self:CliSrv_OnInit()
	end,
	OnShutDown=function(self)
	end,
	Inactive={
	},
	Active={
	},
}

MusicEndTheme.Client={
	OnInit=function(self)
		self:CliSrv_OnInit()
	end,
	OnShutDown=function(self)
	end,
	OnEnterArea=MusicEndTheme.Client_OnEnterArea,
	OnLeaveArea=MusicEndTheme.Client_OnLeaveArea,
	OnProceedFadeArea=MusicEndTheme.Client_OnProceedFadeArea,
}

MusicEndTheme.FlowEvents =
{
	Inputs =
	{
		Stop = { MusicEndTheme.Event_Stop, "bool" },
		--SetTheme = { MusicStinger.Event_SetTheme, "bool" },
	},
	Outputs =
	{
		--Reset = "bool",
		--SetTheme = "bool",
	},
}
