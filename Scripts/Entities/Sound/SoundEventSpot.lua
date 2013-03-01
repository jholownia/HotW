SoundEventSpot = {
    type = "Sound",

    Properties = {
        soundName = "",
        bPlay = 0,	-- Immidiatly start playing on spawn.
        bOnce = 0,
        bEnabled = 1,
        bIgnoreCulling = 0,
        bIgnoreObstruction = 0,
        bPlayRandom = 0,	-- Plays its event randomly according to the min and max wait time.
        bPlayOnX = 1,
        bPlayOnY = 1,
        bPlayOnZ = 1,
        nRadius = 10,
        nMinWaitTime = 2,
        nMaxWaitTime = 5,
    },
    
    bBlockNow=0,
    Editor={
        Model="Editor/Objects/Sound.cgf",
        Icon="Sound.bmp",
    },
}


function SoundEventSpot:OnSpawn()
    self:SetFlags(ENTITY_FLAG_CLIENT_ONLY, 0);
    
    if (System.IsEditor()) then
        Sound.Precache(self.Properties.soundName, SOUND_PRECACHE_LOAD_SOUND);
    end;
    
end


function SoundEventSpot:OnSave(save)
    --WriteToStream(stm,self.Properties);
    --System.LogToConsole("SES: OnSave:");
    save.bBlockNow          = self.bBlockNow;
    save.bEnabled           = self.Properties.bEnabled;
    save.bOnce              = self.Properties.bOnce;
    save.bIgnoreCulling     = self.Properties.bIgnoreCulling;
    save.bIgnoreObstruction = self.Properties.bIgnoreObstruction;
    save.bPlayRandom        = self.Properties.bPlayRandom;
    save.bPlayOnX           = self.Properties.bPlayOnX;
    save.bPlayOnY           = self.Properties.bPlayOnY;
    save.bPlayOnZ           = self.Properties.bPlayOnZ;
    save.nRadius            = self.Properties.nRadius;
    save.nMinWaitTime       = self.Properties.nMinWaitTime;
    save.nMaxWaitTime       = self.Properties.nMaxWaitTime;
    
    --System.LogToConsole("bBlockNow:"..tostring(self.bBlockNow));
    --System.LogToConsole("Once:"..tostring(self.Properties.bOnce));
end

function SoundEventSpot:OnLoad(load)
    --System.LogToConsole("SES: OnLoad:");
    --self.Properties=ReadFromStream(stm);
    --self:OnReset();
    self.bBlockNow                     = load.bBlockNow;
    self.Properties.bEnabled           = load.bEnabled;
    self.Properties.bOnce              = load.bOnce;
    self.Properties.bIgnoreCulling     = load.bIgnoreCulling;
    self.Properties.bIgnoreObstruction = load.bIgnoreObstruction;
    self.Properties.bPlayRandom        = load.bPlayRandom;
    self.Properties.bPlayOnX           = load.bPlayOnX;
    self.Properties.bPlayOnY           = load.bPlayOnY;
    self.Properties.bPlayOnZ           = load.bPlayOnZ;
    self.Properties.nRadius            = load.nRadius;
    self.Properties.nMinWaitTime       = load.nMinWaitTime;
    self.Properties.nMaxWaitTime       = load.nMaxWaitTime;
    
    --System.LogToConsole("bBlockNow:"..tostring(self.bBlockNow));
    --System.LogToConsole("Once:"..tostring(self.Properties.bOnce));

    if (self.Properties.bPlay ~= 0) then
        if (self.Properties.bPlayRandom ~= 0) then
            self:SetTimer(0, self.Properties.nMinWaitTime*1000);
        else
            self:Play();
        end
    end
end

function SoundEventSpot:OnPostLoad()
--	System.LogToConsole("SES: OnPostLoad:");
    self:OnReset()
end

----------------------------------------------------------------------------------------
function SoundEventSpot:OnPropertyChange()
    -- all changes need a complete reset
    self:OnReset();
        
end
----------------------------------------------------------------------------------------
function SoundEventSpot:OnReset()
    
    -- Set basic sound params.
    --System.LogToConsole("Reset SES");
    --System.LogToConsole("self.Properties.bPlay:"..self.Properties.bPlay..", self.bBlockNow:"..self.bBlockNow);
    self.bBlockNow = 0; -- [marco] fix playonce on reset for switch editor/game mode
    self:Stop();
    
    if (self.Properties.bPlay ~= 0) then
        if (self.Properties.bPlayRandom ~= 0) then
            self:SetTimer(0, self.Properties.nMinWaitTime*1000);
        else
            self:Play();
        end
    end
end

----------------------------------------------------------------------------------------
SoundEventSpot["Server"] = {
    OnInit= function (self)
        self.bBlockNow = 0;
        self:NetPresent(0);
    end,
    OnShutDown= function (self)
    end,
}

----------------------------------------------------------------------------------------
SoundEventSpot["Client"] = {
    ----------------------------------------------------------------------------------------
    OnInit = function(self)
        --System.LogToConsole("OnInit");
        self.bBlockNow = 0;
        --self.loop = self.Properties.bLoop;
        self.soundName = "";
        self.soundid = nil;
        self:NetPresent(0);

        if (self.Properties.bPlay ~= 0) then
            if (self.Properties.bPlayRandom ~= 0) then
                self:SetTimer(0, self.Properties.nMinWaitTime*1000);
            else
                --System.LogToConsole("Play sound"..self.Properties.soundName);
                self:Play();
            end
        end
    end,
    
    ----------------------------------------------------------------------------------------
    OnShutDown = function(self)
        self:Stop();
    end,
    
    ----------------------------------------------------------------------------------------
    OnSoundDone = function(self)
      self:ActivateOutput( "Done",true );
      self.soundid = nil;
      --System.LogToConsole("Done sound "..self.Properties.soundName);
    end,
    
    ----------------------------------------------------------------------------------------
    OnTimer = function(self, timerid, msec)
    
        if (timerid == 0) then
            self:Play();
        end
    end,
}

----------------------------------------------------------------------------------------
function SoundEventSpot:Play()

    if (self.Properties.bEnabled == 0) then 
        do return end;
    end
    
    if (self.soundid ~= nil) then
        self:Stop(); -- entity proxy
    end
    
    if (self.bBlockNow == 1) then
        do return end; -- this should only play once
    end
    
    local sndFlags = SOUND_EVENT;
    sndFlags = bor(sndFlags, SOUND_START_PAUSED);
    
    if (self.Properties.bIgnoreCulling == 0) then
      sndFlags = bor(sndFlags, SOUND_CULLING);
    end
    
    if (self.Properties.bIgnoreObstruction == 0) then
      sndFlags = bor(sndFlags, SOUND_OBSTRUCTION);
    end
    
    if (self.Properties.bPlayRandom ~= 0) then
        
        local nTimeToWait;
        
        if (self.Properties.nMinWaitTime > self.Properties.nMaxWaitTime) then
            Log("nMinWaitTime > nMaxWaitTime for Entity '"..self:GetName().."'. Please correct values!");
            nTimeToWait = self.Properties.nMinWaitTime;
        else
            nTimeToWait = randomF(self.Properties.nMinWaitTime, self.Properties.nMaxWaitTime);
        end
    
        self:SetTimer(0, nTimeToWait * 1000);
        
        -- This is an offset to the entitie's current position.
        local v3Offset = {x = 0,y = 0,z = 0};
        local v3Temp   = {x = 0,y = 0,z = 0};
        
        if (self.Properties.bPlayOnX ~= 0) then
            RotateVectorAroundR(v3Temp, g_Vectors.v100, g_Vectors.v010, randomF(0, 360));
            v3Offset.x = v3Temp.x;
        else
            v3Offset.x = 0;
        end
        
        if (self.Properties.bPlayOnY ~= 0) then
            RotateVectorAroundR(v3Temp, g_Vectors.v010, g_Vectors.v100, randomF(0, 360));
            v3Offset.y = v3Temp.y;
        else
            v3Offset.y = 0;
        end
        
        if (self.Properties.bPlayOnZ ~= 0) then
            RotateVectorAroundR(v3Temp, g_Vectors.v001, g_Vectors.v100, randomF(0, 360));
            v3Offset.z = v3Temp.z;
        else
            v3Offset.z = 0;
        end
        
        v3Offset = ScaleVector(v3Offset, self.Properties.nRadius);		
        self.soundid = self:PlaySoundEvent(self.Properties.soundName, v3Offset, g_Vectors.v010, sndFlags, 0, SOUND_SEMANTIC_SOUNDSPOT);
    else
        self.soundid = self:PlaySoundEvent(self.Properties.soundName, g_Vectors.v000, g_Vectors.v010, sndFlags, 0, SOUND_SEMANTIC_SOUNDSPOT);
    end
    
    self.soundName = self.Properties.soundName;
    
    if (self.soundid ~= nil) then
        local bIsEvent = (Sound.IsEvent(self.soundid));
        
        if (not bIsEvent) then
            System.LogToConsole( "<Sound> SoundEventSpot: ("..self:GetName()..") trys to play " ..self.soundName..". Cannot play non Events on SoundEventSpot!" );
            self:Stop();
        else
            -- start the sound as because it was created paused
            Sound.SetSoundPaused(self.soundid, 0);
        end
    --System.LogToConsole( "Play Sound ID: "..tostring(self.soundid));
    end
    
    if (self.Properties.bOnce==1) then
        self.bBlockNow = 1;
    end
end

----------------------------------------------------------------------------------------
function SoundEventSpot:Stop()


    --System.LogToConsole( "Stop Sound ID: "..tostring(self.soundid));
        
    if (self.soundid ~= nil) then
        self:StopSound(self.soundid); -- stopping through entity proxy
        --System.LogToConsole( "Stop Sound" );

        self.soundid = nil;
        --System.LogToConsole( "Stop Sound ID: "..tostring(self.soundid));
    end

end

----------------------------------------------------------------------------------------
function SoundEventSpot:Event_Play( sender )
    
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

function SoundEventSpot:Event_Enable( sender )
  self.Properties.bEnabled = true;
  --BroadcastEvent( self,"Enable" );
  self:OnPropertyChange();
end

function SoundEventSpot:Event_Disable( sender )
  self.Properties.bEnabled = false;
  --BroadcastEvent( self,"Disable" );
  self:OnPropertyChange();
end

function SoundEventSpot:Event_Stop( sender )
        self:Stop();
    --BroadcastEvent( self,"Stop" );
end

function SoundEventSpot:Event_Once( sender, bOnce )
    if (bOnce == true) then
        self.Properties.bOnce = 1;
    else
      self.Properties.bOnce = 0;
    end
    --BroadcastEvent( self,"Once" );
end


SoundEventSpot.FlowEvents =
{
    Inputs =
    {
        Enable = { SoundEventSpot.Event_Enable, "bool" },
        Disable = { SoundEventSpot.Event_Disable, "bool" },
        Play = { SoundEventSpot.Event_Play, "bool" },
        Stop = { SoundEventSpot.Event_Stop, "bool" },
        Once = { SoundEventSpot.Event_Once, "bool" },
    },
    Outputs =
    {
      Done = "bool",
    },
}


