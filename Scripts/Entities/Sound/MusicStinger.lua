MusicStinger = {
	type = "MusicStinger",

	Editor = {
		Icon="Music.bmp",
	},

	Properties = {
		bIndoorOnly=0,
		bOutdoorOnly=0,
	},
	InsideArea=0,
}

function MusicStinger:OnSave(stm)
  stm.InsideArea = self.InsideArea
end

function MusicStinger:OnLoad(stm)
  self.InsideArea = stm.InsideArea
end

function MusicStinger:CliSrv_OnInit()
	self:RegisterForAreaEvents(1);
end

function MusicStinger:OnShutDown()
	self:RegisterForAreaEvents(0);
end

function MusicStinger:Client_OnEnterArea( player,areaId )
	if (g_localActorId ~= player.id) then	return end;	    

	--System.Log("enter music theme area "..self.Properties.sTheme);
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
		Sound.PlayStinger();
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

function MusicStinger:Event_Play(  )
	Sound.PlayStinger();
end

MusicStinger.Server={
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

MusicStinger.Client={
	OnInit=function(self)
		self:CliSrv_OnInit()
	end,
	OnShutDown=function(self)
	end,
	OnEnterArea=MusicStinger.Client_OnEnterArea,
	OnLeaveArea=MusicStinger.Client_OnLeaveArea,
	OnProceedFadeArea=MusicStinger.Client_OnProceedFadeArea,
}

MusicStinger.FlowEvents =
{
	Inputs =
	{
		Play = { MusicStinger.Event_Play, "bool" },
		--SetTheme = { MusicStinger.Event_SetTheme, "bool" },
	},
	Outputs =
	{
		--Reset = "bool",
		--SetTheme = "bool",
	},
}
