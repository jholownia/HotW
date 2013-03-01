MusicLogicTrigger = {
	type = "MusicLogicTrigger",

	Editor = {
		Icon="Music.bmp",
	},

	Properties = {
		bEnable = 1,
		bIndoorOnly=0,
		bOutdoorOnly=0,
	},
	InsideArea=0,
}

function MusicLogicTrigger:OnSave(stm)
  stm.InsideArea = self.InsideArea
end

function MusicLogicTrigger:OnLoad(stm)
  self.InsideArea = stm.InsideArea
end

function MusicLogicTrigger:CliSrv_OnInit()
end

function MusicLogicTrigger:OnShutDown()
end

function MusicLogicTrigger:Client_OnEnterArea( player,areaId )
	if (g_localActorId ~= player.id) then	return end;	    

	--System.Log("enter music logic area "..self.Properties.sTheme);
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
		if (self.Properties.bEnable == 1) then
			MusicLogic.StartLogic();
		else
			MusicLogic.StopLogic();
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

function MusicLogicTrigger:Client_OnLeaveArea( player,areaId )
	if (g_localActorId ~= player.id) then	return end;	    

	--System.Log("leave music logic area "..self.Properties.sTheme);
	local bActivate=1;
	local Indoor=System.IsPointIndoors(System.GetViewCameraPos());	-- player:GetPos());
	if ((self.Properties.bIndoorOnly==1) and (Indoor==nil)) then
		bActivate=0;
	elseif ((self.Properties.bOutdoorOnly==1) and (Indoor~=nil)) then
		bActivate=0;
	end
	--System.Log("bActivate "..bActivate..", InsideArea "..self.InsideArea);
	if (bActivate==1) then --and (self.InsideArea==0)) then
		self.InsideArea=0;
				
	  if (self.Properties.bEnable == 1) then
			MusicLogic.StopLogic();
		else
			MusicLogic.StartLogic();
		end;
		--Sound.SetMusicTheme(self.Properties.sTheme);
		--if (self.Properties.sDefaultMood ~= "") then
			--Sound.SetDefaultMusicMood(self.Properties.sDefaultMood);
		--end
		--if (self.Properties.sMood ~= "") then
			--Sound.SetMusicMood(self.Properties.sMood);
		--end
	elseif ((bActivate==0) and (self.InsideArea==0)) then
		self.InsideArea=1;
		--Sound.EndMusicTheme();
		--Sound.SetMusicTheme("");
	end
end

function MusicLogicTrigger:Event_Enable(  )
	MusicLogic.StartLogic();
end

function MusicLogicTrigger:Event_Disable(  )
	MusicLogic.StopLogic();
end

--function MusicLogicTrigger:Event_Play(  )
	--Sound.PlayStinger();
--end

MusicLogicTrigger.Server={
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

MusicLogicTrigger.Client={
	OnInit=function(self)
		self:CliSrv_OnInit()
	end,
	OnShutDown=function(self)
	end,
	OnEnterArea=MusicLogicTrigger.Client_OnEnterArea,
	OnLeaveArea=MusicLogicTrigger.Client_OnLeaveArea,
}

MusicLogicTrigger.FlowEvents =
{
	Inputs =
	{
		Enable = { MusicLogicTrigger.Event_Enable, "bool" },
		Disable = { MusicLogicTrigger.Event_Disable, "bool" },
		--SetTheme = { MusicLogicTrigger.Event_SetTheme, "bool" },
	},
	Outputs =
	{
		--Reset = "bool",
		--SetTheme = "bool",
	},
}
