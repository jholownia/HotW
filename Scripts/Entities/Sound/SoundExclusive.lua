--	exclusive areas
--	areas have to be nested - the next area copmlitly inside the parent
--	tha first (outside) area has to have AreaID 1
--	there might be up to 10 exclusive nested areas for one entity
SoundExclusive = {
	type = "SoundExclusive",

	Editor = {
		Model="Objects/Editor/S.cgf",
	},

	Properties = {
		Sound1 = {
			sndSound = "",
			Sound = nil,
			iChanceOfOccuring = 0,
			bCentered = 0,
			bDoNotOverlap = 0,
			iVolume = 128,
			iAreaID = 0,
		},

		Sound2 = {
			sndSound = "",
			Sound = nil,
			iChanceOfOccuring = 0,
			bCentered = 0,
			bDoNotOverlap = 0,
			iVolume = 128,
			iAreaID = 0,
		},
		
		Sound3 = {
			sndSound = "",
			Sound = nil,
			iChanceOfOccuring = 0,
			bCentered = 0,
			bDoNotOverlap = 0,
			iVolume = 128,
			iAreaID = 0,
		},
		
		Sound4 = {
			sndSound = "",
			Sound = nil,
			iChanceOfOccuring = 0,
			bCentered = 0,
			bDoNotOverlap = 0,
			iVolume = 128,
			iAreaID = 0,
		},
		
		Sound5 = {
			sndSound = "",
			Sound = nil,
			iChanceOfOccuring = 0,
			bCentered = 0,
			bDoNotOverlap = 0,
			iVolume = 128,
			iAreaID = 0,
		},
		
		Sound6 = {
			sndSound = "",
			Sound = nil,
			iChanceOfOccuring = 0,
			bCentered = 0,
			bDoNotOverlap = 0,
			iVolume = 128,
			iAreaID = 0,
		},
		
		Sound7 = {
			sndSound = "",
			Sound = nil,
			iChanceOfOccuring = 0,
			bCentered = 0,
			bDoNotOverlap = 0,
			iVolume = 128,
			iAreaID = 0,
		},
		Sound8 = {
			sndSound = "",
			Sound = nil,
			iChanceOfOccuring = 0,
			bCentered = 0,
			bDoNotOverlap = 0,
			iVolume = 128,
			iAreaID = 0,
		},
		Sound9 = {
			sndSound = "",
			Sound = nil,
			iChanceOfOccuring = 0,
			bCentered = 0,
			bDoNotOverlap = 0,
			iVolume = 128,
			iAreaID = 0,
		},
		Sound10 = {
			sndSound = "",
			Sound = nil,
			iChanceOfOccuring = 0,
			bCentered = 0,
			bDoNotOverlap = 0,
			iVolume = 128,
			iAreaID = 0,
		},
		Sound11 = {
			sndSound = "",
			Sound = nil,
			iChanceOfOccuring = 0,
			bCentered = 0,
			bDoNotOverlap = 0,
			iVolume = 128,
			iAreaID = 0,
		},
		Sound12 = {
			sndSound = "",
			Sound = nil,
			iChanceOfOccuring = 0,
			bCentered = 0,
			bDoNotOverlap = 0,
			iVolume = 128,
			iAreaID = 0,
		},
		Sound13 = {
			sndSound = "",
			Sound = nil,
			iChanceOfOccuring = 0,
			bCentered = 0,
			bDoNotOverlap = 0,
			iVolume = 128,
			iAreaID = 0,
		},
		Sound14 = {
			sndSound = "",
			Sound = nil,
			iChanceOfOccuring = 0,
			bCentered = 0,
			bDoNotOverlap = 0,
			iVolume = 128,
			iAreaID = 0,
		},
		bWeatherEffected=0,
		bPerception=0,
	},

	fLastFadeCoeff = 0.0,
	ABox = 8,
	maxChance = 1000,
	
	
	InsideArray = 	{0,0,0,0,0,0,0,0,0,0},
	fadeCoeffArea = {0,0,0,0,0,0,0,0,0,0},
}

function SoundExclusive:OnPropertyChange()

	self:LoadSounds( );
end

---------------------------------------------------------
--
function SoundExclusive:CliSrv_OnInit()

	self:Activate(0);
	--System.LogToConsole("--> EX init ");		
	
	if(self.Initialized)then
		return
	end
	
	self:RegisterState("Inactive");
	self:RegisterState("Active");
	self:GotoState("Inactive");
	self["Initialized"]=1;
end


function SoundExclusive:OnSave(props)
	props.Properties = self.Properties
end

function SoundExclusive:OnLoad(stm)
	self.Properties = props.Properties
end


---------------------------------------------------------
--
function SoundExclusive:FlashSounds()
	--System.LogToConsole("FlashSounds");
	for i, Element in pairs(self.Properties) do
		if (type(Element) == "table") then
			Element.Sound=nil;
		end
	end
end

---------------------------------------------------------
--
function SoundExclusive:LoadSounds()
	for i, Element in pairs(self.Properties) do
		if (type(Element) == "table") then
			if (Element.iChanceOfOccuring == self.maxChance) then
				Element.bDoNotOverlap = 1;
			end	
			--System.LogToConsole("doing Sound "..Element.sndSound);

				if (Element.bCentered == 1) then
					if (Element.sndSound ~= "") then
						Element.Sound = Sound.LoadSound(Element.sndSound);
					end
					if(Element.Sound) then
						if (Element.iChanceOfOccuring == self.maxChance) then
							Sound.SetSoundLoop(Element.Sound, 1);
						else
							Sound.SetSoundLoop(Element.Sound, 0);	
						end	
--						Sound.PlaySound(Element.Sound);
					end	
				else
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

---------------------------------------------------------
--


function SoundExclusive:Client_Active_OnTimer()
	local Player = g_localActor;
	
	if (Player == nil) then
			return
	end

	local ListenerPosition = Player:GetPos();
	local SoundPos = ListenerPosition;
	
	local hostIdx=-1;
	local nextIdx=-1;
	
	for i, Element in pairs(self.InsideArray) do
		if(Element==1) then
			nextIdx = hostIdx;
			hostIdx = i;
		end	
	end	

	if (hostIdx == -1) then
		return
	end

	self.fLastFadeCoeff = self.fadeCoeffArea[hostIdx];


	for i, Element in pairs(self.Properties) do
		if (type(Element) == "table") then
			if (Element.Sound) then
				local CurSnd = Element.Sound;
				if( Element.iAreaID == hostIdx ) then
				--System.LogToConsole("FadeOff: "..self.fLastFadeCoeff);
					Sound.SetSoundVolume(CurSnd, Element.iVolume * self.fadeCoeffArea[hostIdx]);
				elseif( Element.iAreaID == nextIdx ) then
					Sound.SetSoundVolume(CurSnd, Element.iVolume * (1-self.fadeCoeffArea[hostIdx]));
				end	
			end
		end
	end
	

	--set the next iteration
	self:SetTimer(0,1000);
	--System.Log("OnTimer");
	for i, Element in pairs(self.Properties) do
		if (type(Element) == "table") then
			if (Element.Sound) then
				if( Element.iAreaID == hostIdx ) then
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
end



---------------------------------------------------------
--
function SoundExclusive:OnShutDown()
end


---------------------------------------------------------
--
function SoundExclusive:Client_Inactive_OnEnterArea( player,areaId )

	--System.Log("Entering Sound Area "..areaId);

--load the sounds
--	self:LoadSounds();
	self:LoadSounds();	
	
--	SoundExclusive:Client_Active_OnEnterArea( player,areaId );
	
	
	
	self.InsideArray[areaId] = 1;
	for i, Element in pairs(self.Properties) do
		if (type(Element) == "table") then
			if(Element.iAreaID == areaId) then
				if (Element.iChanceOfOccuring == self.maxChance) then
					if (Element.Sound) then
						Sound.PlaySound(Element.Sound);
						--System.LogToConsole("--> OnEnterArea() Starting Loop Snd");
					end
				end
			end
		end
	end	
		
	self:GotoState("Active");

end

---------------------------------------------------------
--
function SoundExclusive:Client_Active_OnEnterArea( player,areaId )

	--System.LogToConsole("--> Entering Area"..areaId);
	
	self.InsideArray[areaId] = 1;

	for i, Element in pairs(self.Properties) do
		
--System.LogToConsole("#### "..i);
		
		if (type(Element) == "table") then
			
--System.LogToConsole("**** "..i);			
			
--if (Element.sndSound ~= "") then
--System.LogToConsole("--> OnEnterArea() ++ "..Element.sndSound.." "..Element.iAreaID);
--end
			
			
			if(Element.iAreaID == areaId) then
				

--if (Element.sndSound ~= "") then
--System.LogToConsole("--> OnEnterArea() trying ++ "..Element.sndSound);
--else
--System.LogToConsole("--> OnEnterArea() trying -- "..Element.iAreaID.." "..Element.iVolume.." "..Element.bCentered);
--end

				if (Element.iChanceOfOccuring == self.maxChance) then
					if (Element.Sound) then
						Sound.PlaySound(Element.Sound);
						--System.LogToConsole("--> OnEnterArea() Starting Loop Snd");
					end
				end
			end
		end
	end
end


---------------------------------------------------------
--
function SoundExclusive:Client_Active_OnLeaveArea( player,areaId )
	--System.LogToConsole("EX--> Leaving Area");

	self.InsideArray[areaId] = 0;

	for i, Element in pairs(self.Properties) do
		if (type(Element) == "table") then
			if(Element.iAreaID == areaId) then
				if (Element.iChanceOfOccuring == self.maxChance) then
					if (Element.Sound) then
						Sound.StopSound(Element.Sound);
					end
				end
			end
		end
	end
	
	if( areaId == 1 )	then	-- got out of outside area
		self:GotoState("Inactive");
		self:FlashSounds( );	
	end	
	
end


---------------------------------------------------------
--
function SoundExclusive:Client_Active_OnProceedFadeArea( player,areaId,fadeCoeff )

--System.LogToConsole("--> Fade Proceed ");
	self.fLastFadeCoeff = fadeCoeff;	
	self.fadeCoeffArea[areaId] = fadeCoeff;
end


----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------

SoundExclusive.Server={
	OnInit=function(self)
		self:CliSrv_OnInit()
--		self:CliSrv_OnInit()
	end,
	OnShutDown=function(self)
	end,
	Inactive={
	},
	Active={
	},
}

SoundExclusive.Client={
	OnInit=function(self)
	
--System.LogToConsole("--> EX init ");	
		self:CliSrv_OnInit()
		self:RegisterForAreaEvents(1);
--		self:CliSrv_OnInit()
	end,
	OnShutDown=function(self)
	end,
	Inactive={
		OnEnterArea=SoundExclusive.Client_Inactive_OnEnterArea,
	},
	Active={
		OnBeginState=function(self)
		--	System.Log("SetTimer");
			self:SetTimer(0,200);
		end,
		OnTimer=SoundExclusive.Client_Active_OnTimer,
		OnProceedFadeArea=SoundExclusive.Client_Active_OnProceedFadeArea,
		OnEnterArea=SoundExclusive.Client_Active_OnEnterArea,		
		OnLeaveArea=SoundExclusive.Client_Active_OnLeaveArea,
		OnEndState=function(self)
--			System.Log("KillTimer");
			self:KillTimer(0);
		end,
	},
}


