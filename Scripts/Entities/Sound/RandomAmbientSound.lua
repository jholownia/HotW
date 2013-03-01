RandomAmbientSound = {
	type = "RandomAmbientSound",

	Editor = {
		Model="Objects/Editor/S.cgf",
	},
	
	States = { "Inactive","Active" },

	Properties = {
	
		fScale = 1,

		Sound1 = {
			sndSound = "",
			Sound = nil,
			iChanceOfOccuring = 0,
			bCentered = 0,
			bDoNotOverlap = 1,
			iVolume = 0,
		},

		Sound2 = {
			sndSound = "",
			Sound = nil,
			iChanceOfOccuring = 0,
			bCentered = 0,
			bDoNotOverlap = 1,
			iVolume = 0,
		},
		
		Sound3 = {
			sndSound = "",
			Sound = nil,
			iChanceOfOccuring = 0,
			bCentered = 0,
			bDoNotOverlap = 1,
			iVolume = 0,
		},
		
		Sound4 = {
			sndSound = "",
			Sound = nil,
			iChanceOfOccuring = 0,
			bCentered = 0,
			bDoNotOverlap = 1,
			iVolume = 0,
		},
		
		Sound5 = {
			sndSound = "",
			Sound = nil,
			iChanceOfOccuring = 0,
			bCentered = 0,
			bDoNotOverlap = 1,
			iVolume = 0,
		},
		
		Sound6 = {
			sndSound = "",
			Sound = nil,
			iChanceOfOccuring = 0,
			bCentered = 0,
			bDoNotOverlap = 1,
			iVolume = 0,
		},
		
		Sound7 = {
			sndSound = "",
			Sound = nil,
			iChanceOfOccuring = 0,
			bCentered = 0,
			bDoNotOverlap = 1,
			iVolume = 0,
		},

		EaxReverbProperties= {	
	    nEnvironment=0,		--sets all listener properties (win32/ps2 only) 
	    fEnvSize=1.0,		--environment size in meters (win32 only) 
	    fEnvDiffusion=0.0,		--environment diffusion (win32/xbox) 
	    nRoom=-10000,		--room effect level (at mid frequencies) (win32/xbox/ps2) 
	    nRoomHF=-10000,		--relative room effect level at high frequencies (win32/xbox) 
	    nRoomLF=-10000,		--relative room effect level at low frequencies (win32 only) 
	    fDecayTime=0.1,		--reverberation decay time at mid frequencies (win32/xbox) 
	    fDecayHFRatio=0.1,		--high-frequency to mid-frequency decay time ratio (win32/xbox) 
	    fDecayLFRatio=0.1,		--low-frequency to mid-frequency decay time ratio (win32 only) 
	    nReflections=-10000,	--early reflections level relative to room effect (win32/xbox) 
	    fReflectionsDelay=0.0,	--initial reflection delay time (win32/xbox) 
	    fReflectionsPan={x=0,y=0,z=0},	--early reflections panning vector (win32 only) 
	    nReverb=-10000,		--late reverberation level relative to room effect (win32/xbox) 
	    fReverbDelay=0.0,		--late reverberation delay time relative to initial reflection (win32/xbox) 
	    fReverbPan={x=0,y=0,z=0},		--late reverberation panning vector (win32 only) 
	    fEchoTime=0.075,		--echo time (win32 only) 
	    fEchoDepth=0.0,		--echo depth (win32 only) 
	    fModulationTime=0.04,	--modulation time (win32 only) 
	    fModulationDepth=0.0,	--modulation depth (win32 only) 
	    fAirAbsorptionHF=0.0,	--change in level per meter at high frequencies (win32 only) 
	    fHFReference=1000.0,	--reference high frequency (hz) (win32/xbox) 
	    fLFReference=20.0,		--reference low frequency (hz) (win32 only) 
	    fRoomRolloffFactor=0.0,	--like CS_3D_Listener_SetRolloffFactor but for room effect (win32/xbox) 
	    fDiffusion=0.0,		--Value that controls the echo density in the late reverberation decay. (xbox only) 
	    fDensity=0.0,		--Value that controls the modal density in the late reverberation decay (xbox only) 
	    nFlags=0,			--CS_REVERB_FLAGS - modifies the behavior of above properties (win32 only) 
    },

		nEAXEnvironment=0, 
		--a value bigger than 0 will use the pre-defined presets. 
		--if the value -1 is specified, the above pre-defined table will be used.
		--if the value 0 is specified, no EAX environment will be used
	
		bWeatherEffected=0,
		bPerception=0,
	},

--	nBuilding = -1,
--	nSector = -1,
	fLastFadeCoeff = 0.0,
	ABox = 8,
	maxChance = 1000,
}



function RandomAmbientSound:OnSpawn()
	self:SetFlags(ENTITY_FLAG_CLIENT_ONLY, 0);
end


function RandomAmbientSound.FlashSounds()
	--System.LogToConsole("FlashSounds");
	for i, Element in pairs(self.Properties) do
		if (type(Element) == "table" and Element.Sound) then
			Element.Sound=nil;
			end
	end
end

function RandomAmbientSound.LoadSounds()
	for i, Element in pairs(self.Properties) do
		if (type(Element) == "table" and Element.sndSound~=nil) then
			if (Element.iChanceOfOccuring == self.maxChance) then
				Element.bDoNotOverlap = 1;
			end	
--			System.LogToConsole("doing Sound "..Element.sndSound);

				if (Element.bCentered == 1) then
					if (Element.sndSound ~= "") then
						Element.Sound = Sound.LoadSound(Element.sndSound);
					end
					if(Element.Sound) then
						if (Element.iChanceOfOccuring == self.maxChance) then
							--play and stop to force loading
							Sound.PlaySound(Element.Sound);
							Sound.StopSound(Element.Sound);
							Sound.SetSoundLoop(Element.Sound, 1);
						else
							--play and stop to force loading
							Sound.PlaySound(Element.Sound);
							Sound.StopSound(Element.Sound);
							Sound.SetSoundLoop(Element.Sound, 0);	
						end	
						Sound.PlaySound(Element.Sound);
					end	
				else
					--if(Element.sndSound==nil)then
					--	System.LogToConsole(tostring(i)..".sndSound=nil")
					--end
					if (Element.sndSound ~= "") then
						Element.Sound = Sound.Load3DSound(Element.sndSound);
					end
				end
			
			if(Element.Sound) then
				Sound.SetWeatherAndPerceptionFlags(Element.Sound,self.Properties.bWeatherEffected,self.Properties.bPerception);
				Sound.SetSoundVolume(Element.Sound, Element.iVolume * self.fLastFadeCoeff);
			
			end	
		end--if table
	end --for

end

function RandomAmbientSound.OnSave(props)
	props.Properties = self.Properties
end

function RandomAmbientSound.OnLoad(stm)
	self.Properties = props.Properties
end

function RandomAmbientSound.OnPropertyChange()
	self:LoadSounds();
end

function RandomAmbientSound.CliSrv_OnInit()
	if(self.Initialized)then
		return
	end
	
	self:GotoState("Inactive");
	self["Initialized"]=1;
end

function RandomAmbientSound.Client_Active_OnTimer()
	local Player = g_localActor;
	
	if (Player == nil) then
			return
	end
	local ListenerPosition = Player:GetPos();
	local SoundPos = ListenerPosition;

	--set the next iteration
	self:SetTimer(0,1000);
	--System.Log("OnTimer");
	for i, Element in pairs(self.Properties) do
		if (type(Element) == "table" and Element.Sound~=nil) then
			if (Element.Sound) then
				local bSkip = 0;
				if (Element.iChanceOfOccuring == self.maxChance) then
					bSkip = 1;

				elseif(Element.bDoNotOverlap == 1 and Sound.IsPlaying(Element.Sound)) then
					bSkip = 1;
				end
			
				if (bSkip == 0) then
					local CurSnd = Element.Sound;
					if (random(0, self.maxChance) < Element.iChanceOfOccuring) then
						if (Element.bCentered == 0) then
							SoundPos.x = ListenerPosition.x + random(0, self.ABox) - self.ABox*0.5;
							SoundPos.y = ListenerPosition.y + random(0, self.ABox) - self.ABox*0.5;
							SoundPos.z = ListenerPosition.z + random(0, self.ABox) - self.ABox*0.5;
							Sound.SetSoundPosition(CurSnd, SoundPos);
							Sound.SetMinMaxDistance(CurSnd, .2, 200);
							Sound.PlaySound(CurSnd);						
	
						else
							Sound.PlaySound(CurSnd);
						end
						Sound.SetSoundVolume(CurSnd, Element.iVolume * self.fLastFadeCoeff);						
					end
				end
			end
		end
	end
end

function RandomAmbientSound.OnShutDown()
end

function RandomAmbientSound.Client_Inactive_OnEnterArea( player,areaId )

--System.Log("Entering Sound Area "..areaId);

--load the sounds
	self:LoadSounds();
	for i, Element in pairs(self.Properties) do
		if (type(Element) == "table" and Element.Sound~=nil) then
			if (Element.iChanceOfOccuring == self.maxChance) then
				if (Element.Sound) then
--					Sound.SetSoundVolume(Element.Sound, 0);
					Sound.PlaySound(Element.Sound);
				end
			end
		end
	end

	--System.Log("Set EAX Environment "..self.Properties.nEAXEnvironment);
	--if (self.Properties.nEAXEnvironment>0) then
		--Sound.SetEaxEnvironment(self.Properties.nEAXEnvironment);
	--else	
		--Sound.SetEaxEnvironment(self.Properties.EaxReverbProperties);
	--end

	self:GotoState("Active");
	
end

function RandomAmbientSound.Client_Active_OnLeaveArea( player,areaId )
--System.Log("Leaving Sound Area "..areaId);
	for i, Element in pairs(self.Properties) do
		if (type(Element) == "table" and Element.Sound~=nil) then
			--if(Element.Sound) then
			Sound.StopSound(Element.Sound);
			--end
		end
	end
	self:GotoState("Inactive");
	self:FlashSounds();

	-- disable eax, choosing OFF preset	
	--System.Log("Set EAX Environment 0");
	--if( self.Properties.EaxReverbProperties~=0 ) then
		--Sound.SetEaxEnvironment(0);
	--end		
end

function RandomAmbientSound.Client_Active_OnProceedFadeArea( player,areaId,fadeCoeff )

--System.Log("FADE proceed "..fadeCoeff);

	self.fLastFadeCoeff = fadeCoeff;
	for i, Element in pairs(self.Properties) do
		if (type(Element) == "table" and Element.Sound~=nil) then
			--if (Element.Sound) then
			Sound.SetSoundVolume(Element.Sound, Element.iVolume * self.fLastFadeCoeff*self.Properties.fScale);
			--end
		end
	end
end

	----------------------------------------------------------------------------------------
function RandomAmbientSound.OnMove()
--	local newInsidePos = self:UpdateInSector(self.nBuilding,	self.nSector );
--	self.nBuilding = newInsidePos.x;
--	self.nSector = newInsidePos.y;
end


RandomAmbientSound.Server={
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

RandomAmbientSound.Client={
	OnInit=function(self)
		self:RegisterForAreaEvents(1);
		self:CliSrv_OnInit()
		self:OnMove();
	end,
	OnShutDown=function(self)
	end,
	Inactive={
		OnBeginState=function(self)
--System.Log("Entering INACTIVE");		
		end,
	
		OnEnterArea=RandomAmbientSound.Client_Inactive_OnEnterArea,
		OnMove=RandomAmbientSound.OnMove,
--		OnMove=RandomAmbientSound.Client.OnMove,		
	},
	Active={
		OnBeginState=function(self)
--System.Log("Entering ACTIVE");		
		--	System.Log("SetTimer");
			self:SetTimer(0,200);
		end,
		OnTimer=RandomAmbientSound.Client_Active_OnTimer,
		OnMove=RandomAmbientSound.OnMove,
		OnProceedFadeArea=RandomAmbientSound.Client_Active_OnProceedFadeArea,
		OnLeaveArea=RandomAmbientSound.Client_Active_OnLeaveArea,
		OnEndState=function(self)
--			System.Log("KillTimer");
			self:KillTimer(0);
		end,
	},
}
