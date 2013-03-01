Dialog = {
	type = "Dialog",

	Properties = {
		dialogLine="",
		bPlay=0,	-- Immidiatly start playing on spawn.
		bOnce=0,
		bEnabled=1,
		bAllowRadioOverDistance=0,
		bIgnoreCulling=0,
		bIgnoreObstruction=0,
	},
	
	bBlockNow=0,
	Editor={
		Model="Editor/Objects/Sound.cgf",
		Icon="Dialog.bmp",
	},
	bEnabled=1,
}

function Dialog:OnSpawn()
	--self:SetFlags(ENTITY_FLAG_CLIENT_ONLY, 0);
	
	if (System.IsEditor()) then
		Sound.Precache(self.Properties.dialogLine, SOUND_PRECACHE_LOAD_UNLOAD_AFTER_PLAY);
	end;
	
end

function Dialog:OnSave(save)
	--WriteToStream(stm,self.Properties);
	save.bBlockNow = self.bBlockNow
	save.bEnabled = self.bEnabled
	save.bIgnoreCulling = self.Properties.bIgnoreCulling;
	save.bIgnoreObstruction = self.Properties.bIgnoreObstruction;
end

function Dialog:OnLoad(load)
	--self.Properties=ReadFromStream(stm);
	--self:OnReset();
	self.bBlockNow = load.bBlockNow
	self.bEnabled = load.bEnabled
	self.Properties.bIgnoreCulling = load.bIgnoreCulling;
	self.Properties.bIgnoreObstruction = load.bIgnoreObstruction;
	
	if (self.bPlay) then
    	self:Play();
	end	
end

----------------------------------------------------------------------------------------
function Dialog:OnPropertyChange()
	-- all changes need a complete reset
	self:OnReset();
		
end
----------------------------------------------------------------------------------------
function Dialog:OnReset()
	
	-- Set basic sound params.
	--System.LogToConsole("Reset SP");
	--System.LogToConsole("self.Properties.bPlay:"..self.Properties.bPlay..", self.bBlockNow:"..self.bBlockNow);
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
Dialog["Server"] = {
	OnInit= function (self)
		self.bBlockNow = 0;
		self:NetPresent(0);
	end,
	OnShutDown= function (self)
	end,
}

----------------------------------------------------------------------------------------
Dialog["Client"] = {
	----------------------------------------------------------------------------------------
	OnInit = function(self)
		--System.LogToConsole("OnInit");
		self.bBlockNow = 0;
		--self.loop = self.Properties.bLoop;
		self.dialogLine = "";
		self.soundid = nil;
		self:NetPresent(0);

		if (self.Properties.bPlay==1) then
			self:Play();
			--System.LogToConsole("Play sound"..self.Properties.dialogLine);
		end
		--self.Client.OnMove(self);
	end,
	----------------------------------------------------------------------------------------
	OnShutDown = function(self)
		self:Stop();
	end,
	OnSoundDone = function(self)
	  self:ActivateOutput( "Done",true );
	  --System.LogToConsole("Done sound "..self.Properties.dialogLine);
	end,
}

----------------------------------------------------------------------------------------
function Dialog:Play()

	if (self.bEnabled == 0 ) then 
		do return end;
	end

  if (self.soundid ~= nil) then
		self:Stop(); -- entity proxy
	end

  if (self.bBlockNow==1) then
	do return end; -- this should only play once
  end

	local sndFlags = bor(SOUND_EVENT, SOUND_VOICE);

	sndFlags = bor(sndFlags, SOUND_START_PAUSED);
  
  	if (self.Properties.bIgnoreCulling == 0) then
	  sndFlags = bor(sndFlags, SOUND_CULLING);
	end;  

	if (self.Properties.bIgnoreObstruction == 0) then
	  sndFlags = bor(sndFlags, SOUND_OBSTRUCTION);
	end;  
	
  
	self.soundid = self:PlaySoundEvent(self.Properties.dialogLine, g_Vectors.v000, g_Vectors.v010, sndFlags, 0, SOUND_SEMANTIC_DIALOG);
	self.dialogLine = self.Properties.dialogLine;

  if (self.soundid ~= nil) then

	local bIsVoice = (Sound.IsVoice(self.soundid));

	if (not bIsVoice) then
		System.LogToConsole( "<Sound> Dialog: ("..self:GetName()..") trys to play " ..self.dialogLine..". Cannot play non Voices on Dialog Entity!" );
	    	self:Stop();
	  else
		-- start the sound as because it was created paused
		Sound.SetSoundPaused(self.soundid, 0);
	  end;


	--System.LogToConsole( "Play Sound ID: "..tostring(self.soundid));
end

	--System.LogToConsole( "Play Sound" );

	if (self.Properties.bOnce==1) then
		self.bBlockNow = 1;
	end
	
end

----------------------------------------------------------------------------------------
function Dialog:Stop()

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
function Dialog:Event_Play( sender )
	
	if (self.soundid ~= nil) then
		self:Stop();
	end
	--Log("Event_Play %d %d",self.Properties.bOnce, self.bBlockNow)

	self:Play();
	--BroadcastEvent( self,"Play" );
end

------------------------------------------------------------------------------------------------------
-- Event Handlers
------------------------------------------------------------------------------------------------------

function Dialog:Event_DialogLine( sender, sDialogLine )
  self.Properties.dialogLine = sDialogLine;
  --BroadcastEvent( self,"DialogLine" );
  self:OnPropertyChange();
end

function Dialog:Event_Enable( sender )
  self.Properties.bEnabled = true;
  --BroadcastEvent( self,"Enable" );
  self:OnPropertyChange();
end

function Dialog:Event_Disable( sender )
  self.Properties.bEnabled = false;
  --BroadcastEvent( self,"Disable" );
  self:OnPropertyChange();
end

function Dialog:Event_Stop( sender )
		self:Stop();
	--BroadcastEvent( self,"Stop" );
end

function Dialog:Event_Once( sender, bOnce )
	if (bOnce == true) then
		self.Properties.bOnce = 1;
	else
	  self.Properties.bOnce = 0;
	end
	--BroadcastEvent( self,"Once" );
end


Dialog.FlowEvents =
{
	Inputs =
	{
	  dialog_DialogLine = { Dialog.Event_DialogLine, "string" },
		Enable = { Dialog.Event_Enable, "bool" },
		Disable = { Dialog.Event_Disable, "bool" },
		Play = { Dialog.Event_Play, "bool" },
		Stop = { Dialog.Event_Stop, "bool" },
		Once = { Dialog.Event_Once, "bool" },
	},
	Outputs =
	{
	  Done = "bool",
	},
}


