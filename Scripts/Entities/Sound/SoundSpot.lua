SoundSpot = {
	type = "Sound",

	Properties = {
		sndSource="",
		fVolume=1.0,
		InnerRadius=2,
		OuterRadius=10,
		bLoop=1,	-- Loop sound.
		bPlay=0,	-- Immidiatly start playing on spawn.
		bOnce=0,
		bEnabled=1,
		--bOcclusion=1,
		--bDirectional=0,
	},
	 
	bBlockNow=0,
	Editor={
		Model="Editor/Objects/Sound.cgf",
		Icon="Sound.bmp",
	},
	bEnabled=1,

	Client = {},
	Server = {},
}

Net.Expose {
	Class = SoundSpot,
	ClientMethods = {
		ClEvent_Stop = { RELIABLE_ORDERED, POST_ATTACH},
		ClEvent_Enable = { RELIABLE_ORDERED, POST_ATTACH, BOOL },
		ClEvent_Play = { RELIABLE_ORDERED, POST_ATTACH},
	},
	ServerMethods = {
	},
	ServerProperties = {
	},
};

function SoundSpot:OnSpawn()
--	self:SetFlags(ENTITY_FLAG_CLIENT_ONLY, 0);
	
	if (System.IsEditor()) then
		Sound.Precache(self.Properties.sndSource, 0);
	end;
	
end

----------------------------------------------------------------------------------------
function SoundSpot:OnSoundDone()
  self:ActivateOutput( "Done",true );
	--System.LogToConsole("Done sound "..self.Properties.sndSource);
end

----------------------------------------------------------------------------------------
function SoundSpot:OnSave(props)
	--WriteToStream(stm,self.Properties);
	props.bBlockNow = self.bBlockNow
	props.bEnabled = self.bEnabled
end

----------------------------------------------------------------------------------------
function SoundSpot:OnLoad(props)
	--self.Properties=ReadFromStream(stm);
	--self:OnReset();
	self.bBlockNow = props.bBlockNow
	self.bEnabled = props.bEnabled
	if ((self.bPlay==1) and (self.Properties.bOnce~=1)) then
 	  self:Play();
	end	
end

----------------------------------------------------------------------------------------
function SoundSpot:OnPropertyChange()
	if (self.soundName ~= self.Properties.sndSource or 
	    self.Properties.bLoop ~= self.loop or
	    self.Properties.bPlay ~= self.bPlay or
	    self.Properties.bEnable ~= self.bEnable) then
		--System.LogToConsole("Reset sound"..self.Properties.sndSource);
	  self:OnReset();		
	end
	
	if (self.volume ~= self.Properties.fVolume) then
	  Sound.SetSoundVolume(self.soundid, self.Properties.fVolume);
	  self.volume = self.Properties.fVolume;
	end
	
	if (self.InnerRadius ~= self.Properties.InnerRadius or
	    self.OuterRadius ~= self.Properties.OuterRadius) then
	  Sound.SetMinMaxDistance(self.soundid, self.Properties.InnerRadius, self.Properties.OuterRadius);
	  self.InnerRadius = self.Properties.InnerRadius;
	  self.OuterRadius = self.Properties.OuterRadius;
	end
	


end
----------------------------------------------------------------------------------------
function SoundSpot:OnReset()
	
	-- Set basic sound params.
	--System.LogToConsole("Reset SP");
	--System.LogToConsole("self.Properties.bPlay:"..self.Properties.bPlay..", self.bBlockNow:"..self.bBlocknow);
  	
  self.bBlockNow = 0; -- [marco] fix playonce on reset for switch editor/game mode
	self.bEnabled = self.Properties.bEnabled;

	--if (self.Properties.bPlay == 0 and self.soundid ~= nil) then
		self:Stop();
	--end

	if (self.Properties.bPlay ~= 0) then 
		self:Play();
	end
	--self.Client:OnMove();

end

----------------------------------------------------------------------------------------
SoundSpot["Server"] = {
	OnInit= function (self)
		self.bBlockNow = 0;
		self:NetPresent(0);
	end,
	OnShutDown= function (self)
	end,
}

----------------------------------------------------------------------------------------
SoundSpot["Client"] = {
	----------------------------------------------------------------------------------------
	OnInit = function(self)
		--System.LogToConsole("OnInit");
		self.bBlockNow = 0;
		self.loop = self.Properties.bLoop;
		self.soundName = "";
		self.soundid = nil;
		self:NetPresent(0);

		if (self.Properties.bPlay==1) then
			self:Play();
			--System.LogToConsole("Play sound"..self.Properties.sndSource);
		end
		--self.Client.OnMove(self);
	end,
	----------------------------------------------------------------------------------------
	OnShutDown = function(self)
		self:Stop();
	end,
	OnSoundDone = function(self)
	end,
	  --self:ActivateOutput( "Done",true );
	  --System.LogToConsole("Done sound"..self.Properties.soundName);
	--end,

}

----------------------------------------------------------------------------------------
function SoundSpot:Play()

	if (self.bEnabled == 0 ) then 
		do return end;
	end

  if (self.soundid ~= nil) then
		self:Stop(); -- entity proxy
	end

  if (self.bBlockNow==1) then
	do return end; -- this should only play once
  end


  local sndFlags = bor(SOUND_DEFAULT_3D,SOUND_RADIUS);

	sndFlags = bor(sndFlags, SOUND_START_PAUSED);

	if (self.Properties.bLoop ~=0 ) then
		sndFlags = bor(sndFlags, SOUND_LOOP);
	end;  
	self.loop = self.Properties.bLoop;
  
	self.soundid = self:PlaySoundEventEx(self.Properties.sndSource, sndFlags, 0, self.Properties.fVolume, g_Vectors.v000, self.Properties.InnerRadius, self.Properties.OuterRadius, SOUND_SEMANTIC_SOUNDSPOT );
	self.soundName = self.Properties.sndSource;
	self.volume = self.Properties.fVolume;
	self.InnerRadius = self.Properties.InnerRadius;
	self.OuterRadius = self.Properties.OuterRadius;

  --check if sound was created, already culled, or did not succeeded
  if (self.soundid ~= nil) then
	  
	local bIsEventOrVoice = (Sound.IsEvent(self.soundid) or Sound.IsVoice(self.soundid));

	--System.LogToConsole( "EventOrVoice="..tostring(bIsEventOrVoice));

	if (bIsEventOrVoice) then
	    System.LogToConsole( "<Sound> SoundSpot: ("..self:GetName()..") trys to play " ..self.soundName..". Cannot play Event or Voice on a SoundSpot!" );
	    self:Stop();
	  else

	    --System.LogToConsole( "Play Sound" );

	  -- start the sound as because it was created paused
	  Sound.SetSoundPaused(self.soundid, 0);
	  end;
  end;
 
	if (self.Properties.bOnce==1) then
		self.bBlockNow = 1;
	end
end

----------------------------------------------------------------------------------------
function SoundSpot:Stop()

	--if (self.bEnabled == 0 ) then 
		--do return end;
	--end

	if (self.soundid ~= nil) then
		self:StopSound(self.soundid); -- stopping through entity proxy
		--System.LogToConsole( "Stop Sound" );
		self.soundid = nil;
	end
end

----------------------------------------------------------------------------------------
function SoundSpot:Event_Play( sender )
	
	if (self.soundid ~= nil) then
		self:Stop();
	end
	--Log("Event_Play %d %d",self.Properties.bOnce, self.bBlockNow)
	self:Play();
	--BroadcastEvent( self,"Play" );
	-- net
	if( CryAction.IsServer() ) then
		self.allClients:ClEvent_Play();
	end
end

-------------------------------------------------------------------------------
-- Stop Event
-------------------------------------------------------------------------------
function SoundSpot:Event_Stop( sender )
 	self:Stop();
	--BroadcastEvent( self,"Stop" );

	-- net
	if( CryAction.IsServer() ) then
		self.allClients:ClEvent_Stop();
	end

end

function SoundSpot:Event_Enable( sender)
	self.bEnabled = 1;
	--BroadcastEvent( self,"Stop" );

	-- net
	if( CryAction.IsServer() ) then
		self.allClients:ClEvent_Enable(true);
	end
end

function SoundSpot:Event_Disable( sender )
	self.bEnabled = false;
	--BroadcastEvent( self,"Disable" );
	if( CryAction.IsServer() ) then
		self.allClients:ClEvent_Enable(false);
	end
end

SoundSpot.FlowEvents =
{
	Inputs =
	{
		Play = { SoundSpot.Event_Play, "bool" },
		Stop = { SoundSpot.Event_Stop, "bool" },
		Enable = { SoundSpot.Event_Enable, "bool" },
		Disable = { SoundSpot.Event_Disable, "bool" },
	},
	Outputs =
	{
	  Done = "bool",
	},
}



-- client functions
function SoundSpot.Client:ClEvent_Stop( )
	if( not CryAction.IsServer() ) then
		self:Event_Stop(nil);
	end
end
function SoundSpot.Client:ClEvent_Enable( bEnable )
	if( not CryAction.IsServer() ) then
		if(bEnable) then
			self:Event_Enable(nil);
		else
			self:Event_Disable(nil);
		end
	end
end
function SoundSpot.Client:ClEvent_Play( )
	if( not CryAction.IsServer() ) then
		self:Event_Play(nil);
	end
end

