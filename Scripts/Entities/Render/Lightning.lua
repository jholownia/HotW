Lightning =
{
	Properties =
	{
		bActive = 1,
		fDistance = 0, -- Distance from entity position where strike occurs.
		fDistanceVariation = 0.2, --Variation of the Distance.
		bRelativeToPlayer = 0,
		Timing = {
			fDelay = 5,  -- Delay between strikes in seconds
			fDelayVariation = 0.5,  -- Variation of Delay between strikes in percents.
			fLightningDuration = 0.2,  -- in seconds
			fThunderDelay = 1,  -- Delay between lighting strike and thunder sound.
			fThunderDelayVariation = 0.5,  -- Variation of delay between lighting strike and thunder sound.
		},
		Effects = {
			LightRadius = 1000,
			LightIntensity = 1,
			ParticleEffect = "Weather.Lightning.LightningBolt1",
			ParticleScale = 1,
			ParticleScaleVariation = 0.2,
			--SkyMultiplier = 1,
			--color_SkyColor = {x=1,y=1,z=1},
			SkyHighlightVerticalOffset = 0,
			SkyHighlightMultiplier = 1,
			color_SkyHighlightColor = {x=0.8,y=0.8,z=1},
			SkyHighlightAtten = 10,
			sound_Sound = "",
		},
	},

	TempPos = {x=0.0,y=0.0,z=0.0},

	Editor={
		Model="Editor/Objects/Particles.cgf",
		Icon="Lightning.bmp",
	},

	_LightTable = {
		diffuse_color = { x=1, y=1,z=1 };
		specular_color = { x=1, y=1,z=1 };
	},
	_ParticleTable = {},
	_SkyHighlight = { size=0,color={x=0,y=0,z=0},position={x=0,y=0,z=0} },
	_StrikeCount = 0,
}

function Lightning:OnInit()
	self.bStriking = 0;
	self.light_fade = 0;
	self.light_intensity = 0;
	self.vStrikeOffset = {x=0,y=0,z=0};
	self.vSkyHighlightPos = {x=0,y=0,z=0};

	--self:NetPresent(0);
	self.bActive = self.Properties.bActive;
	self:ScheduleNextStrike();
end

function Lightning:OnShutDown()
	self:StopStrike();
end

function Lightning:OnLoad(table)
	self.bActive = table.bActive;
	self:StopStrike();
	self:ScheduleNextStrike();
end

function Lightning:OnSave(table)
	table.bActive = self.bActive;
	table.bActive = self.bActive;
end

function Lightning:OnPropertyChange()
	self.bActive = self.Properties.bActive;
	self:ScheduleNextStrike();
end

function Lightning:LoadLightToSlot( nSlot )
	local props = self.Properties;
	local Effects = props.Effects;
	
	local lt = self._LightTable;
	lt.style = 0;
	lt.corona_scale = 1;
	lt.corona_dist_size_factor = 1;
	lt.corona_dist_intensity_factor = 1;
	lt.radius = Effects.LightRadius;
	
	local clr = self.light_intensity * Effects.LightIntensity;
	lt.diffuse_color.x = clr;
	lt.diffuse_color.y = clr;
	lt.diffuse_color.z = clr;
	
	lt.specular_color.x = clr;
	lt.specular_color.y = clr;
	lt.specular_color.z = clr;
	
	--lt.diffuse_color = { x=Color.clrDiffuse.x*diffuse_mul, y=Color.clrDiffuse.y*diffuse_mul, z=Color.clrDiffuse.z*diffuse_mul };
	--lt.specular_color = { x=Color.clrSpecular.x*specular_mul, y=Color.clrSpecular.y*specular_mul, z=Color.clrSpecular.z*specular_mul };
	lt.hdrdyn = 0;
	lt.lifetime = 0;
	lt.realtime = 1;
	lt.dot3 = 1;
	lt.cast_shadow = 0;
	
	self:LoadLight( nSlot,lt );
	self:SetSlotPos( nSlot,self.vStrikeOffset );
end

------------------------------------------------------------------------------------------------------
-- Lightning effcet stopped in OnTimer
------------------------------------------------------------------------------------------------------
function Lightning:OnTimer( nTimerId )
	if (nTimerId == 1) then
		self.bStopStrike = 1;
	end
	if (nTimerId == 0) then
		self:Event_Strike();
	end
	
	if (nTimerId == 2) then
		-- Play Thunder sound.
		local Effects = self.Properties.Effects;
		if (Effects.sound_Sound ~= "") then
			local sndFlags = bor(SOUND_2D,SOUND_RELATIVE);
			self.soundid = self:PlaySoundEvent(Effects.sound_Sound, self.vStrikeOffset, g_Vectors.v010, sndFlags, 0, SOUND_SEMANTIC_AMBIENCE_ONESHOT);
		end
	end
end

function Lightning:StopStrike()
	if (self.bStriking == 0) then
		self:ScheduleNextStrike();
		return;
	end
	-- Stop lightning effect.
	self:FreeSlot(0); -- Free light slot.
	self:FreeSlot(1); -- Free particle slot.
	-- Stop particle effects.
	self:Activate(0);
	self.bStriking = 0;
	self.bStopStrike = 0;
	
	self:ScheduleNextStrike();
	
	-- Restore zero sky highlight.
	self._SkyHighlight.size = 0;
	self._SkyHighlight.color.x = 0;
	self._SkyHighlight.color.y = 0;
	self._SkyHighlight.color.z = 0;
	self._SkyHighlight.position.x = 0;
	self._SkyHighlight.position.y = 0;
	self._SkyHighlight.position.z = 0;
	System.SetSkyHighlight( self._SkyHighlight );
	
	-- Restore original sky color.
	--if (self.vPrevSkyColor) then
		--System.SetSkyColor( self.vPrevSkyColor );
		--self.vPrevSkyColor = nil;
	--end
	
	self._StrikeCount = self._StrikeCount - 1;
end

function Lightning:OnUpdate( dt )
	self.light_intensity = self.light_intensity - self.light_fade*dt;
	if (self.light_intensity <= 0) then
		if (self.bStopStrike == 1) then
		  self:StopStrike();
		  do return end;
		end
		self.light_intensity = 1 - math.random()*0.5;
		self.light_fade = 3 + math.random()*5;
	end
	
	self:UpdateLightningParams();
end

function Lightning:UpdateLightningParams()
	self:LoadLightToSlot( 0 );
	
	local Effects = self.Properties.Effects;
	
	local highlight = self.light_intensity * Effects.SkyHighlightMultiplier;
	self._SkyHighlight.color.x = highlight * Effects.color_SkyHighlightColor.x;
	self._SkyHighlight.color.y = highlight * Effects.color_SkyHighlightColor.y;
	self._SkyHighlight.color.z = highlight * Effects.color_SkyHighlightColor.z;
	
	self._SkyHighlight.size = Effects.SkyHighlightAtten;
	
	self._SkyHighlight.position.x = self.vSkyHighlightPos.x;
	self._SkyHighlight.position.y = self.vSkyHighlightPos.y;
	self._SkyHighlight.position.z = self.vSkyHighlightPos.z + Effects.SkyHighlightVerticalOffset;
	
	System.SetSkyHighlight( self._SkyHighlight );
	
	--local skylight = self.light_intensity * Effects.SkyMultiplier;
	--self._SkyHighlight.color.x = skylight * Effects.color_SkyColor.x;
	--self._SkyHighlight.color.y = skylight * Effects.color_SkyColor.y;
	--self._SkyHighlight.color.z = skylight * Effects.color_SkyColor.z;
	--System.SetSkyColor( self._SkyHighlight.color );
end

function Lightning:GetValueWithVariation( v,variation )
	return v + (math.random()*2 - 1)*v*variation;
end

function Lightning:ScheduleNextStrike()
	if (self.bActive == 1) then
		local delay = self.Properties.Timing.fDelay;
		delay = self.Properties.Timing.fLightningDuration + self:GetValueWithVariation(delay,self.Properties.Timing.fDelayVariation);
		self:SetTimer( 0,delay*1000 );
	end
end

------------------------------------------------------------------------------------------------------
-- Start lightning effect stopped in OnTimer
------------------------------------------------------------------------------------------------------
function Lightning:Event_Strike()
	if (self.bStriking == 0) then
		self.bStriking = 1;
		
		--self.vPrevSkyColor = nil;
		--if (self._StrikeCount == 0) then
			--self.vPrevSkyColor = new(System.GetSkyColor());
		--end
		
		self._StrikeCount = self._StrikeCount+1;
		
		local props = self.Properties;
		local Effects = props.Effects;
		
		self.light_intensity = 1 - math.random()*0.5;
		self.light_fade = 3 + math.random()*5;
		
		local vEntityPos = self:GetPos();
		
		local vCamDir = System.GetViewCameraDir();
		local vCamPos = System.GetViewCameraPos();
		local vStrikePos = vEntityPos;
				
		local fDistance = self:GetValueWithVariation(props.fDistance,props.fDistanceVariation);
		
		local minAngle = 0;
		local maxAngle = 360;
		
		if (props.bRelativeToPlayer == 1) then
			if (vCamDir.x > 0 and vCamDir.y > 0) then
				minAngle = -90; maxAngle = 180;
			end
			if (vCamDir.x > 0 and vCamDir.y < 0) then
				minAngle = 0; maxAngle = 270;
			end
			if (vCamDir.x < 0 and vCamDir.y < 0) then
				minAngle = 90; maxAngle = 360;
			end
			if (vCamDir.x < 0 and vCamDir.y > 0) then
				minAngle = 180; maxAngle = 360+90;
			end
			minAngle = minAngle+100;
			maxAngle = maxAngle-100;
		end
		
		-- Generate random position at radius fDstance from entity center.
		local phi = (minAngle + math.random()*(maxAngle-minAngle))*3.14/180;
		--local phi = (minAngle + maxAngle)/2*3.14/180;
		self.vStrikeOffset.x = fDistance*math.sin(phi);
		self.vStrikeOffset.y = fDistance*math.cos(phi);
		
		if (props.bRelativeToPlayer == 1) then
			local vCamDir = System.GetViewCameraDir();
			self.vStrikeOffset.x = self.vStrikeOffset.x + (vCamPos.x - vEntityPos.x);
			self.vStrikeOffset.y = self.vStrikeOffset.y + (vCamPos.y - vEntityPos.y);
		end
		
		-- Find Distance to the camera from the light strike (in XY plane only).
		local dx = vCamPos.x-(vEntityPos.x+self.vStrikeOffset.x);
		local dy = vCamPos.y-(vEntityPos.y+self.vStrikeOffset.y);
		local toCameraDistance = math.sqrt( dx*dx + dy*dy);
		
		self.vSkyHighlightPos.x = vEntityPos.x + self.vStrikeOffset.x;
		self.vSkyHighlightPos.y = vEntityPos.y + self.vStrikeOffset.y;
		self.vSkyHighlightPos.z = vEntityPos.z;
			
		-- Spawn Particle effect.
		if (Effects.ParticleEffect ~= "") then
		  -- Scale effect to keep the same size regardless of the distance to the lightning.
			self._ParticleTable.Scale = self:GetValueWithVariation(Effects.ParticleScale,Effects.ParticleScaleVariation)*toCameraDistance;
			self:LoadParticleEffect( 1, Effects.ParticleEffect, self._ParticleTable );
			self:SetSlotPos( 1,self.vStrikeOffset );
		end
		
		self:UpdateLightningParams();
		
		local Timing = self.Properties.Timing;
		
		-- Play Thunder sound.
		if (Effects.sound_Sound ~= "") then
			-- Set Timer for thunder sound.
			self:SetTimer( 2,self:GetValueWithVariation(Timing.fThunderDelay,Timing.fThunderDelayVariation)*1000 );
			
			--local sndFlags = bor(SOUND_2D,SOUND_RELATIVE);
			--self.soundid = self:PlaySoundEvent(Effects.sound_Sound, self.vStrikeOffset, g_Vectors.v010, sndFlags, 0, SOUND_SEMANTIC_AMBIENCE_ONESHOT);
		end
						
		self:SetTimer( 1,self:GetValueWithVariation(Timing.fLightningDuration,0.5)*1000 );
		self:Activate(1);
	end
	BroadcastEvent( self,"Strike" );
end

function Lightning:Event_Enable()
	if (self.bActive == 0) then
		self.bActive = 1;
		self:ScheduleNextStrike();
	end
end

function Lightning:Event_Disable()
	self.bActive = 0;
end

------------------------------------------------------------------------------------------------------
-- Event descriptions.
------------------------------------------------------------------------------------------------------
Lightning.FlowEvents =
{
	Inputs =
	{
		Strike = { Lightning.Event_Strike,"bool" },
		Enable = { Lightning.Event_Enable,"bool" },
		Disable = { Lightning.Event_Disable,"bool" },
	},
	Outputs =
	{
		Strike = "bool",
	},
}
