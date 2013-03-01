-----------------------------------------------------------------------------------------------
--
--	SoundMood entity - to be attached to area 
--	will set specified SoundMood settings when entering area
--  registers/updates/unregisters Presets and supports blending

SoundMoodVolume = {
	type = "SoundMoodVolume",
	Client = {},
	Server = {},	
	
	Editor={
		Model="Editor/Objects/Sound.cgf",
		Icon="SoundMoodVolume.bmp",
	},
	
	Properties = {
		--reverbpresetReverbPreset="",
		sSoundMoodName = "",
		OuterRadius=2,
		--bFullEffectWhenInside=1, --used for Reverb-Morphing
		bEnabled=1,
	},
	bstarted=0,
	
	-- states
	States = { "Inactive", "Active" },
}

function SoundMoodVolume:OnSpawn()
	self.bEnabled = self.Properties.bEnabled;
	self:SetFlags(ENTITY_FLAG_CLIENT_ONLY, 0);
end

----------------------------------------------------------------------------------------
function SoundMoodVolume:OnLoad(table)
  self.bstarted = table.bstarted;
  self.bEnabled = table.bEnabled;
  GoToCorrectState();
end

----------------------------------------------------------------------------------------
function SoundMoodVolume:OnSave(table)
  table.bstarted = self.bstarted;
  table.bEnabled = self.bEnabled;
  
end

----------------------------------------------------------------------------------------
function SoundMoodVolume:OnPropertyChange()
	self:SetSoundEffectRadius(self.Properties.OuterRadius);
	self.bEnabled = self.Properties.bEnabled;
	self.sSoundMoodName = self.Properties.sSoundMoodName;
	self:GoToCorrectState();
end

----------------------------------------------------------------------------------------
function SoundMoodVolume:CliSrv_OnInit()
	--System.LogToConsole("SoundMoodVolume:CliSrv_OnInit");
	self.bstarted = 0;
	self.sSoundMoodName = "";
	self:NetPresent(0);
	self.inside = 0;
	self.fFadeValue = 0;
	self:SetFlags(ENTITY_FLAG_VOLUME_SOUND,0);
	if (self.Initialized) then
		return
	end	
	
	self:SetSoundEffectRadius(self.Properties.OuterRadius);
	self.Initialized=1;
  self:RegisterForAreaEvents(1);
	self:GoToCorrectState();
end

function SoundMoodVolume:GoToCorrectState()
	if(self.Properties.bEnabled == 1) then
		self:GotoState("Active");
		--System.LogToConsole("ChangedProperty:Goto Active");
	else
		self:GotoState("Inactive");		
		--System.LogToConsole("ChangedProperty:Goto Inactive");
	end
end

----------------------------------------------------------------------------------------
function SoundMoodVolume:OnShutDown()
	self:RegisterForAreaEvents(0);
end

----------------------------------------------------------------------------------------
function SoundMoodVolume:RegisterSoundMood( player )
  --local Preset=ReverbPresetDB[self.Properties.reverbpresetReverbPreset];
 
  -- local test=nil + 1;  -- for testing unless lua debugger works
	--if (self.Properties.sSoundMood) then
	  --System.Log("Register SoundMood "..self.Properties.sSoundMoodName);
	  --System.Log("Preset "..Preset.nEnvironment);
	  if (self.bstarted == 0) then
	    Sound.RegisterSoundMood(self.Properties.sSoundMoodName);
    	self.bstarted=1;
    end;
  --end;
	
end

----------------------------------------------------------------------------------------
function SoundMoodVolume:UnregisterSoundMood( player )
	
	--System.Log("Unregister SoundMood "..self.Properties.sSoundMood);
	if (self.bstarted ~= 0) then
	  --System.Log("Unregister SoundMood "..self.Properties.sSoundMood);
		Sound.UnregisterSoundMood(self.Properties.sSoundMoodName);
		self.bstarted=0;
		
	end;

end

----------------------------------------------------------------------------------------
function SoundMoodVolume:UpdateSoundMood( player, fDistSq, fExternalFade )
  if (self.Properties.OuterRadius ~= 0) then
  
    --if (self.bstarted == 0) then
      --OnEnterNearArea(player, areaId);
    --end;
    
    --System.Log("Update SoundMood "..self.Properties.sSoundMoodName);
    
    if (fExternalFade == 0) then
    	if (fDistSq == 0) then
    		SoundMoodVolume.UnregisterSoundMood(self, player);
      elseif (self.inside == 1 and self.fFadeValue ~= 1) then
      	Sound.UpdateSoundMood(self.Properties.sSoundMoodName, 1, 0);
    	  self.fFadeValue = 1;
    	  --System.Log("FADE proceed self fade"..self.fFadeValue);
	  	else
  			local fFade = 1 - (math.sqrt(fDistSq) / self.Properties.OuterRadius);
  	 		--System.Log("FADE proceed "..fFade);
  	 		if (fFade > 0) then
  	 			Sound.UpdateSoundMood(self.Properties.sSoundMoodName, fFade, 0);
    	  	self.fFadeValue = fFade;
     		end
    	end
    else
      Sound.UpdateSoundMood(self.Properties.sSoundMoodName, fExternalFade, 0);
      self.fFadeValue = fExternalFade;
    end
  end
  
end

----------------------------------------------------------------------------------------
function SoundMoodVolume:OnMove()
--	local newInsidePos = self:UpdateInSector(self.nBuilding,	self.nSector );
--	self.nBuilding = newInsidePos.x;
--	self.nSector = newInsidePos.y;
end

function SoundMoodVolume.Server:OnInit()
	--System.LogToConsole("SoundMoodVolume.Server:OnInit");
	self:CliSrv_OnInit()
end;

function SoundMoodVolume.Client:OnInit()
	--System.LogToConsole("SoundMoodVolume.Client:OnInit");
	self.bEnabled = self.Properties.bEnabled;
	self:CliSrv_OnInit()
	self:OnMove();
end;

----------------------------------------------------------------------------------------
SoundMoodVolume.Server.Active={
	OnShutDown=function(self)
	end,
}

SoundMoodVolume.Server.Inactive={
	OnShutDown=function(self)
	end,
}

----------------------------------------------------------------------------------------
SoundMoodVolume.Client.Active = {
	OnShutDown=function(self)
	end,
	
	-- OnEnterNearArea = ReverbVolume.OnEnterNearArea,
	--OnEnterArea=ReverbVolume.Client_Inactive_OnEnterArea,
	--OnMove=ReverbVolume.OnMove,
	
	OnBeginState=function(self)
		--System.LogToConsole("Active");	
		if(self.inside == 1) then
			--System.LogToConsole("Active and is Inside");
			SoundMoodVolume.RegisterSoundMood(self);
			Sound.UpdateSoundMood(self.Properties.sSoundMoodName, self.fFadeValue, 0);
		else
			--System.LogToConsole("Active but is not inside");
		end
		--	System.Log("SetTimer");
--			self:SetTimer(200);
	end,
		--OnMove = function(self)
		--end,
	
	OnMoveNearArea = function(self,player, nAreaID,fFade,fDistsq )
	   if (g_localActorId ~= player.id and player.class~="CameraSource") then	return end;    
	   SoundMoodVolume.RegisterSoundMood(self,player);
	   SoundMoodVolume.UpdateSoundMood(self, player, fDistsq, 0);
	end,	
	
	OnEnterArea = function(self,player, nAreaID, fFade )
		--System.LogToConsole("OnEnterArea-Client");
		if (g_localActorId ~= player.id and player.class~="CameraSource") then	return end;	    
	  SoundMoodVolume.RegisterSoundMood(self,player);

	  self.inside = 1;
	  self.fFadeValue = 0; -- fake current value to make sure to enforce updating of fade value
	  SoundMoodVolume.UpdateSoundMood(self, player, 1, 0); 
	end,
	
	OnSoundEnterArea = function(self,player,areaId,fFade )
		--System.LogToConsole("OnEnterArea-Client");
		if (g_localActorId ~= player.id and player.class~="CameraSource") then	return end; 
	  --self.inside = 1;
	  --self.fFadeValue = 0;
--	  if (self.bEnabled ~= 0) then
--	    System.LogToConsole("OnSoundEnterArea-Client");
--	  end;
	end,
	
	
	OnProceedFadeArea = function(self, player, nAreaID, fExternalFade)
		if (g_localActorId ~= player.id and player.class~="CameraSource") then	return end;
	  
	  -- fExternalFade holds the fade value which was calculated by an inner, higher priority area
	  -- in the AreaManager to fade out the outer sound dependant on the biggest effect radius of all attached entities
	  
	  if (fExternalFade > 0) then
	  	self.inside = 1;
	  	SoundMoodVolume.RegisterSoundMood(self,player);
	  	SoundMoodVolume.UpdateSoundMood(self, player, 0, fExternalFade);
	  else
	  	SoundMoodVolume.UpdateSoundMood(self, player, 0, 0); -- this forces an un-register of this mood
	  end
	  
	  self.fFadeValue = fExternalFade;
	end,
	
	OnLeaveArea = function(self)
		if (g_localActorId ~= player.id and player.class~="CameraSource") then	return end;

		--System.LogToConsole("OnLeaveNearArea-Client");
		self.inside = 0;
	end,	
	
	OnLeaveNearArea = function(self,player,areaId,fFade )
		if (g_localActorId ~= player.id and player.class~="CameraSource") then	return end;    

	  SoundMoodVolume.UnregisterSoundMood(self,player);
	  self.inside = 0;
	end,
	
		--OnMoveNearArea = function(self)
		--end,
		--OnLeaveNearArea = function(self)
		--end,
		OnEndState=function(self)
--			System.Log("KillTimer");
--			self:KillTimer();
		end,
}


SoundMoodVolume.Client.Inactive = {
	OnBeginState=function(self)
		--System.LogToConsole("Inactive");	
		--System.LogToConsole("Inactive and is Inside");
		SoundMoodVolume.UnregisterSoundMood(self);
	end,

	OnEnterArea = function(self,player, nAreaID, fFade )
	  --System.LogToConsole("OnEnterArea-Client");
	  if (g_localActorId ~= player.id and player.class~="CameraSource") then	return end;	 
	  self.fFadeValue = 0;
	  self.inside = 1;
	  SoundMoodVolume.UpdateSoundMood(self, player, 1, 0); 
	end,	
	
	OnLeaveNearArea = function(self,player,areaId,fFade )
	  if (g_localActorId ~= player.id and player.class~="CameraSource") then	return end;    
	  self.inside = 0;
	end,	
	
	OnEndState=function(self)
	end,	
}

----------------------------------------------------------------------------------------------------
function SoundMoodVolume:Event_Deactivate(sender)
  --System.Log( "Ambient Volume :Enable active");
  self.bEnabled = 0;
  SoundMoodVolume.UnregisterSoundMood(self);
  self:GotoState("Inactive");		
  --self:OnReset();
end
----------------------------------------------------------------------------------------------------
function SoundMoodVolume:Event_Activate(sender)
  --System.Log( "SoundMoodVolume :Event_Activate");
  self.bEnabled = 1;
  SoundMoodVolume.RegisterSoundMood(self);
  self:GotoState("Active");		
  --self:OnReset();
end
----------------------------------------------------------------------------------------------------
function SoundMoodVolume:Event_Fade(sender, fFade)
  --System.Log( "ASoundMoodVolume :Event_Fade"..tostring(fFade));
  self.fFadeValue = fFade;
  Sound.UpdateSoundMood(self.Properties.sSoundMoodName, self.fFadeValue, 0);
  --self:OnReset();
end


SoundMoodVolume.FlowEvents =
{
	Inputs =
	{
	  --SoundName = { SoundMoodVolume.Event_SoundName, "string" },
		--Enable = { SoundMoodVolume.Event_Enable, "bool" },
		Deactivate 	= { SoundMoodVolume.Event_Deactivate, "bool" },
		Activate   	= { SoundMoodVolume.Event_Activate, "bool" },
		Fade 				= { SoundMoodVolume.Event_Fade, "float" },
		--Volume = { SoundMoodVolume.Event_Volume, "float" },
	},
	Outputs =
	{
	},
}

