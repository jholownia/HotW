MissionHint = {
	type = "Sound",

	Properties = {
		Hints = {
			sndHint1="",
			sndHint2="",
			sndHint3="",
			sndHint4="",
			sndHint5="",
			sndHint6="",
			sndHint7="",
			sndHint8="",
			sndHint9="",
			sndHint10="",
		},
		sndSkipAcknowledge="",
		iAllowedToSkip=3,
		fVolume=1.0,
		bLoop=0,	-- Loop sound.
		bOnce=0,
		bEnabled=1,
		bScaleDownVolumes=1,

	},
	skipped=0,
	HintCount = 1,
	SkipCount = 0,
	Editor={
		Model="Editor/Objects/Sound.cgf",
	},	
}

function MissionHint:OnSave(props)
	props.HintCount = self.HintCount
end

function MissionHint:OnLoad(props)
	self:OnReset();
	self.HintCount = props.HintCount
end

----------------------------------------------------------------------------------------
function MissionHint:OnPropertyChange()
	if (self.soundName ~= self.Properties.sndSource or self.soundid == nil or self.Properties.bLoop ~= self.loop) then
		--if (self.started==1) then
		--	self:Play();
		--end
		self.loop = self.Properties.bLoop;
	end
	self:OnReset();
	if (self.soundid ~= nil) then
		if (self.Properties.bLoop~=0) then
			Sound.SetSoundLoop(self.soundid,1);
		else
			Sound.SetSoundLoop(self.soundid,0);
		end;

		Sound.SetSoundVolume(self.soundid,self.Properties.iVolume);
		--Sound.SetSoundProperties(self.sound,self.Properties.fFadeValue);			
	end;
end

----------------------------------------------------------------------------------------
function MissionHint:OnReset()
	-- Set basic sound params.
	--System.LogToConsole("Reset SP");
	--System.LogToConsole("self.Properties.bPlay:"..self.Properties.bPlay..", self.started:"..self.started);
	
	--System.LogToConsole("Resetting now");

	self.SkipCount = 0;
	self.HintCount = 1;
	self.skipped = 0;
	self:StopSound();
	--self.sound = nil;
	self.soundid = nil;
	self:ActivateOutput( "Done",false );

end
----------------------------------------------------------------------------------------
MissionHint["Server"] = {
	OnInit= function (self)
		self:Activate(0);
		self.started = 0;
	end,
	OnShutDown= function (self)
	end,
}

----------------------------------------------------------------------------------------
MissionHint["Client"] = {
	----------------------------------------------------------------------------------------
	OnInit = function(self)
		self:Activate(0);
		--System.LogToConsole("OnInit");
		self.started = 0;
		self.loop = self.Properties.bLoop;
		self.soundName = "";
		self:ActivateOutput( "Done",false );

		if (self.Properties.bPlay==1) then
			self:Play();
		end

	end,

	----------------------------------------------------------------------------------------
	OnTimer= function(self)
		if (self.soundid) then
			if ((not Sound.IsPlaying(self.soundid)) or (g_localActor:IsDead())) then
				--System.Log("sound stopped - sound scale to normal");
				Sound.StopSound(self.soundid)
				self.soundid = nil;
			else
				-- Sound still playing.
				-- set another timer.
				self:SetTimer(0, 1000);
			end
		end
	end,
	----------------------------------------------------------------------------------------
	OnShutDown = function(self)
		self:StopSound();
	end,
	----------------------------------------------------------------------------------------
	OnSoundDone = function(self)
	  self:ActivateOutput( "Done",true );
	  --System.LogToConsole("Done sound"..self.Properties.soundName);
	end,
}

----------------------------------------------------------------------------------------
function MissionHint:Play()

	--System.LogToConsole("\005 Now playing with "..self.SkipCount.." skip and "..self.HintCount.." hint");

	System.Log("Now playing with "..self.SkipCount.." skip and "..self.HintCount.." hint");

	if ((self.Properties.bEnabled == 0 ) or (self.skipped == 1) ) then 
		do return end;
	end

	if(self.soundid~=nil and Sound.IsPlaying(self.soundid) )then
		Sound.StopSound(self.soundid);
		self.SkipCount = self.SkipCount+1;
	end

  --System.Log("Now playing 2 ");

	self.soundid = nil;

	if (self.SkipCount > self.Properties.iAllowedToSkip) then 
		if (sndSkipAcknowledge ~= "") then
			self.skipped = 1;
			--self.soundid = Sound.LoadSound(self.Properties.sndSkipAcknowledge);
			self.soundName = self.Properties.sndSkipAcknowledge;
			--System.Log("Now playing 3 "..self.soundName);
		end
	else
		if (self.soundid == nil) then
			self:LoadSnd();
			--if (self.soundid == nil) then
				--return;
			--end;
		end
	end

  local sndFlags = SOUND_2D;
	--sndFlags = bor(sndFlags, SOUND_LOOP);

	if (self.Properties.bLoop~=0) then
		sndFlags = bor(sndFlags, SOUND_LOOP);
		--Sound.SetSoundLoop(self.soundid,1);
	--else
		--Sound.SetSoundLoop(self.soundid,0);
	end;

	--Sound.SetSoundVolume(self.soundid,self.Properties.iVolume);

	self:SetTimer(0, 1000);

	--Game:PlaySubtitle(self.soundid);
	--System.Log("Try to play 4 "..self.soundName);
	self.soundid = self:PlaySoundEvent(self.soundName, g_Vectors.v000, g_Vectors.v010, sndFlags, 0, SOUND_SEMANTIC_DIALOG);
	--System.Log("Now playing 4 "..self.soundid);
	--Sound.PlaySound(self.sound);

	--Sound.PlaySoundFadeUnderwater(self.sound);
	--System.LogToConsole( "Play Sound" );

	if (self.Properties.bScaleDownVolumes==1) then
	end
end

----------------------------------------------------------------------------------------
function MissionHint:StopSound()

	if (self.Properties.bEnabled == 0 ) then 
		do return end;
	end

--	if (self.soundid ~= nil and Sound.IsPlaying(self.soundid) ) then
	if (self.soundid ~= nil ) then
		Sound.StopSound(self.soundid);
		--System.LogToConsole( "Stop Sound" );
		self.soundid = nil;
	end
	self.started = 0;
end

----------------------------------------------------------------------------------------
function MissionHint:LoadSnd()

	if (self.Properties.Hints["sndHint"..self.HintCount] ~= "") then
		--self.sound = Sound.LoadSound(self.Properties.Hints["sndHint"..self.HintCount]);
		self.soundName = self.Properties.Hints["sndHint"..self.HintCount];
		self.HintCount = self.HintCount + 1;
	end

	--self.soundName = self.Properties.Hints["sndHint"..self.HintCount];
	--System.Log("Now playing Count: "..self.soundName );
end

-------------------------------------------------------------------------------
-- Stop Event
-------------------------------------------------------------------------------
function MissionHint:Event_Stop( sender )
		self:StopSound();
	--BroadcastEvent( self,"Stop" );
end

function MissionHint:Event_Play( sender )
		self:Play();
	--BroadcastEvent( self,"bPlay" );
end

function MissionHint:Event_Enable( sender )
  self.Properties.bEnabled = true;
  --BroadcastEvent( self,"Enable" );
  self:OnPropertyChange();
end

function MissionHint:Event_Disable( sender )
  self.Properties.bEnabled = false;
  --BroadcastEvent( self,"Disable" );
  self:OnPropertyChange();
end

MissionHint.FlowEvents =
{
	Inputs =
	{
		Play = { MissionHint.Event_Play, "bool" },
		Stop = { MissionHint.Event_Stop, "bool" },
		Enable = { MissionHint.Event_Enable, "bool" },
		Disable = { MissionHint.Event_Disable, "bool" },
	},
	Outputs =
	{
	  Done = "bool",
	},
}
