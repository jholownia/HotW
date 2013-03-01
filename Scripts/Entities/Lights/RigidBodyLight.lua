Script.ReloadScript( "Scripts/Entities/Physics/BasicEntity.lua" );

-- Basic entity
RigidBodyLight = 
{
	Properties = 
	{
		Physics = 
		{
			bRigidBodyActive = 1,
			bActivateOnDamage = 0,
			bResting = 1, -- If rigid body is originally in resting state.
			bCanBreakOthers = 0,
			Simulation =
			{
				max_time_step = 0.02,
				sleep_speed = 0.04,
				damping = 0,
				bFixedDamping = 0,
				bUseSimpleSolver = 0,
			},
			Buoyancy=
			{
				water_density = 1000,
				water_damping = 0,
				water_resistance = 1000,	
			},
		},
		Sound = {
			soundTurnOn = "",
			soundTurnOff = "",
			soundDestroy = "",
			soundIdle = "",
			soundRun = "",
			vOffset	= {x=0, y=0, z=0},
		},
	},
	
	PropertiesInstance = 
	{
	  bTurnedOn = 1,
		LightProperties_Base = 
		{
			_nVersion = -1,
			bUseThisLight = 1,
			Radius = 10,
			vOffset					= {x=0, y=0, z=0},
			vDirection			= {x=0, y=1, z=0},
			Style =
			{
				nLightStyle = 0,
				Rotation = {x=0.0,y=0.0,z=0.0},
				fAnimationSpeed = 1,
				nAnimationPhase = 0,
				fCoronaScale = 1,
				fCoronaDistSizeFactor = 1,
				fCoronaDistIntensityFactor = 1,
				texture_AttenuationMap = "",
			},
			Projector =
			{
				texture_Texture = "",
				bProjectInAllDirs = 0,
				fProjectorFov = 90,
				fProjectorNearPlane = 0,
			},
			Color = 
			{
				clrDiffuse = { x=1,y=1,z=1 },
				fDiffuseMultiplier = 1,
				fSpecularMultiplier = 1,
				fHDRDynamic = 0,		-- -1=darker..0=normal..1=brighter
			},
			Options = 
			{
				bCastShadow = 0,
				nCastShadows = 0,
				fShadowBias = 1,
				fShadowSlopeBias = 1,
				bAffectsThisAreaOnly = 1,
				bIgnoresVisAreas = 0,
				--bUsedInRealTime=1,
				bDeferredLight = 1,
				bAmbientLight = 0,
				bFakeLight=0,
				bDeferredClipBounds = 0,
				bIrradianceVolumes = 0,
				texture_deferred_cubemap = "",
				file_deferred_clip_geom = "",
				nPostEffect=0, -- 0=none, 1= screen space light shaft, 2= flare, 3= volume desaturation ?			
				
				bIgnoreGeomCaster = 0,
        nViewDistRatio = 100,
        nGlowSubmatId = 0,
			},
			Test = 
			{
				bFillLight=0,
			},
		},
		
		LightProperties_Destroyed = 
		{
			_nVersion = -1,
			bUseThisLight = 0,
			Radius = 10,
			vOffset					= {x=0, y=0, z=0},
			vDirection			= {x=0, y=1, z=0},
			Style =
			{
				nLightStyle = 0,
				Rotation = {x=0.0,y=0.0,z=0.0},
				fAnimationSpeed = 1,
				nAnimationPhase = 0,
				fCoronaScale = 1,
				fCoronaDistSizeFactor = 1,
				fCoronaDistIntensityFactor = 1,
				texture_AttenuationMap = "",
			},
			Projector =
			{
				texture_Texture = "",
				bProjectInAllDirs = 0,
				fProjectorFov = 90,
				fProjectorNearPlane = 0,
			},
			Color = 
			{
				clrDiffuse = { x=1,y=1,z=1 },
				fDiffuseMultiplier = 1,
				fSpecularMultiplier = 1,
				fHDRDynamic = 0,		-- -1=darker..0=normal..1=brighter
			},
			Options = 
			{
				bCastShadow = 0,
				nCastShadows = 0,
				fShadowBias = 1,
				fShadowSlopeBias = 1,
				bAffectsThisAreaOnly = 1,
				bIgnoresVisAreas = 0,
				bDeferredLight = 1,
				bAmbientLight = 0,
				bFakeLight=0,
				bDeferredClipBounds = 0,
				bIrradianceVolumes = 0,
				bDisableX360Opto = 0,
				texture_deferred_cubemap = "",
				file_deferred_clip_geom = "",
				nPostEffect=0, -- 0=none, 1= screen space light shaft, 2= flare, 3= volume desaturation ?			
				fShadowUpdateMinRadius = 10,
				fShadowUpdateRatio = 1,		
				
				bIgnoreGeomCaster = 0,
        nViewDistRatio = 100,
        nGlowSubmatId = 0,
			},
			Test = 
			{
				bFillLight=0,
			},
		},
	},
	
	
	_LightTable = {},
	lightSlot = -1,
	materialIsCloned = false,
	
		Editor=
	{
		Icon = "Light.bmp",
		IconOnTop=1,
	},
}

local Physics_DX9MP_Simple = {
	bRigidBodyActive = 0,
	bActivateOnDamage = 0,
	bResting = 1, -- If rigid body is originally in resting state.
	Simulation =
	{
		max_time_step = 0.02,
		sleep_speed = 0.04,
		damping = 0,
		bFixedDamping = 0,
		bUseSimpleSolver = 0,
	},
	Buoyancy=
	{
		water_density = 1000,
		water_damping = 0,
		water_resistance = 1000,	
	},
	
}

MakeDerivedEntity( RigidBodyLight, BasicEntity )

-------------------------------------------------------
function RigidBodyLight:OnLoad(table)  
  if (self.lightSlot) then
  	self:FreeSlot( self.lightSlot );
  end

  self.bRigidBodyActive = table.bRigidBodyActive;
	self.lightSlot = table.lightSlot;
	self.origGlowValue = table.origGlowValue;
	self.destroyed = table.destroyed;
	
	-- if resuming a game (i.e. also including loading the map and creating this light instance) 
	-- and the material was cloned in the saved game
	if( not self.materialIsCloned and table.materialIsCloned) then
		self:CloneMaterial(0);
	end

	-- the "or" prevents multiple cloning when loading a game in the same current map
	self.materialIsCloned = self.materialIsCloned or table.materialIsCloned;
	self.lightOn = table.lightOn;

  self.runSoundId = 0;
  self.idleSoundId = 0;
	self:ShowCorrectLight();

end

-------------------------------------------------------
function RigidBodyLight:OnSave(table)  
	table.bRigidBodyActive = self.bRigidBodyActive
	table.lightSlot = self.lightSlot;
	table.origGlowValue = self.origGlowValue;
	table.materialIsCloned = self.materialIsCloned; 
	table.lightOn = self.lightOn;
	table.destroyed = self.destroyed;
end

------------------------------------------------------------------------------------------------------
function RigidBodyLight:OnSpawn()
	if (self.Properties.Physics.bRigidBodyActive == 1) then
		self.bRigidBodyActive = 1;
	end
	self:SetFromProperties();	
	self:SetupHealthProperties();
	self:CacheResources("RigidBodyLight.lua");
end

-------------------------------------------------------
function RigidBodyLight:CacheResources(requesterName)
	local textureFlags = 0;
	if (self.PropertiesInstance.LightProperties_Base.Projector.bProjectInAllDirs ~= 0 and self.PropertiesInstance.LightProperties_Base.Options.bDeferredLight ~= 0) then
		textureFlags = eGameCacheResourceFlag_TextureReplicateAllSides;
	end
	Game.CacheResource(requesterName, self.PropertiesInstance.LightProperties_Base.Projector.texture_Texture, eGameCacheResourceType_Texture, textureFlags);
	
	textureFlags = 0;
	if (self.PropertiesInstance.LightProperties_Destroyed.Projector.bProjectInAllDirs ~= 0 and self.PropertiesInstance.LightProperties_Destroyed.Options.bDeferredLight ~= 0) then
		textureFlags = eGameCacheResourceFlag_TextureReplicateAllSides;
	end
	Game.CacheResource(requesterName, self.PropertiesInstance.LightProperties_Destroyed.Projector.texture_Texture, eGameCacheResourceType_Texture, textureFlags);

	Game.CacheResource(requesterName, self.PropertiesInstance.LightProperties_Base.Style.texture_AttenuationMap, eGameCacheResourceType_Texture, eGameCacheResourceFlag_TextureNoStream);
	Game.CacheResource(requesterName, self.PropertiesInstance.LightProperties_Destroyed.Style.texture_AttenuationMap, eGameCacheResourceType_Texture, eGameCacheResourceFlag_TextureNoStream);
	
	Game.CacheResource(requesterName, self.PropertiesInstance.LightProperties_Base.Options.texture_deferred_cubemap, eGameCacheResourceType_TextureDeferredCubemap, 0);
	Game.CacheResource(requesterName, self.PropertiesInstance.LightProperties_Destroyed.Options.texture_deferred_cubemap, eGameCacheResourceType_TextureDeferredCubemap, 0);
	
	Game.CacheResource(requesterName, self.PropertiesInstance.LightProperties_Base.Options.file_deferred_clip_geom, eGameCacheResourceType_StaticObject, 0);
	Game.CacheResource(requesterName, self.PropertiesInstance.LightProperties_Destroyed.Options.file_deferred_clip_geom, eGameCacheResourceType_StaticObject, 0);
end

------------------------------------------------------------------------------------------------------
function RigidBodyLight:SetFromProperties()
	local Properties = self.Properties;
  self.destroyed = false;
	
	if (Properties.object_Model ~= "") then
	
		self:LoadObject(0,Properties.object_Model);
		self:CharacterUpdateOnRender(0,1); -- If it is a character force it to update on render.
			
		-- Enabling drawing of the slot.
		self:DrawSlot(0,1);
		
		if (Properties.Physics.bPhysicalize == 1) then
			self:PhysicalizeThis();
		end
		
		-- Mark AI hideable flag.
		if (self.Properties.bAutoGenAIHidePts == 1) then
			self:SetFlags(ENTITY_FLAG_AI_HIDEABLE, 0); -- set
		else
			self:SetFlags(ENTITY_FLAG_AI_HIDEABLE, 2); -- remove
		end
	end
	
    -- this is somewhat of a hack: the "or self.lightOn" is there to cover the case when the designer is currently modifying the glow value in the editor. it is irrelevant in pure game
	if (not self.origGlowValue or self.lightOn) then
    self.origGlowValue = self:GetMaterialFloat(0, self.PropertiesInstance.LightProperties_Base.Options.nGlowSubmatId, "glow" );
  end
  
  self.lightOn = self.PropertiesInstance.bTurnedOn==1;
  if (self.idleSoundId==nil) then
  	self.idleSoundId = 0;
  end	
  if (self.runSoundId==nil) then
  	self.runSoundId = 0;
  end	
  	
  self:ShowCorrectLight();
end

------------------------------------------------------------------------------------------------------
function RigidBodyLight:PhysicalizeThis()
	-- Init physics.
	local physics = self.Properties.Physics;
	if (CryAction.IsImmersivenessEnabled() == 0) then
		physics = Physics_DX9MP_Simple;
	end
	EntityCommon.PhysicalizeRigid( self,0,physics,self.bRigidBodyActive );
end

------------------------------------------------------------------------------------------------------
-- OnPropertyChange called only by the editor.
------------------------------------------------------------------------------------------------------
function RigidBodyLight:OnPropertyChange()
  if (self.lightOn) then
    self.origGlowValue = self:GetMaterialFloat(0, self.PropertiesInstance.LightProperties_Base.Options.nGlowSubmatId, "glow" );
  end

	self:SetFromProperties();
	if (self.PropertiesInstance.LightProperties_Base.Options.bDeferredClipBounds) then
		self:UpdateLightClipBounds(self.lightSlot);
	end
	-- to avoid loop sounds playing while in editor mode
	self:StopIdleSound();  
	self:StopRunSound();
end


function RigidBodyLight.Client:OnLevelLoaded()
	if (self.PropertiesInstance.LightProperties_Base.Options.bDeferredClipBounds) then
		self:UpdateLightClipBounds(self.lightSlot);
	end
end

------------------------------------------------------------------------------------------------------
-- OnReset called only by the editor.
------------------------------------------------------------------------------------------------------
function RigidBodyLight:OnReset()
	self:ResetOnUsed();
	self.lightOn = self.PropertiesInstance.bTurnedOn==1;
	self.destroyed = false;
	self.materialIsCloned = false;
  self:ShowCorrectLight();
	
	local PhysProps = self.Properties.Physics;
	if (PhysProps.bPhysicalize == 1) then
		if (self.bRigidBodyActive ~= PhysProps.bRigidBodyActive) then
			self.bRigidBodyActive = PhysProps.bRigidBodyActive;
			self:PhysicalizeThis();
		end
		if (PhysProps.bRigidBody == 1) then
			self:AwakePhysics(1-PhysProps.bResting);
			self.bRigidBodyActive = PhysProps.bRigidBodyActive;
		end		
	end
end

------------------------------------------------------------------------------------------------------
function RigidBodyLight:GetFrozenSlot()
	if (self.frozenModelSlot) then
		return self.frozenModelSlot;
	end
	return -1;
end



------------------------------------------------------------------------------------------------------
function RigidBodyLight:Event_Hide()
	self:Hide(1);
	self:ActivateOutput( "Hidden", true );
	--self:DrawObject(0,0);
	--self:DestroyPhysics();
end

------------------------------------------------------------------------------------------------------
function RigidBodyLight:Event_UnHide()
	self:Hide(0);
	self:ActivateOutput( "UnHidden", true );
	--self:DrawObject(0,1);
	--self:SetPhysicsProperties( 1,self.bRigidBodyActive );
end


function RigidBodyLight:Event_Enable()
  if (not self.destroyed) then
    self.lightOn = true;
    self:ShowCorrectLight();
	  self:ActivateOutput( "Enabled", true );
	  self:PlaySound( self.Properties.Sound.soundTurnOn );
	end
end

function RigidBodyLight:Event_Disable()
	self:SwitchOnOff( false );
end

function RigidBodyLight:PlaySound( soundName )
	if ( soundName and soundName~="") then
		local sndFlags=SOUND_DEFAULT_3D;
		self:PlaySoundEvent( soundName, self.Properties.Sound.vOffset,g_Vectors.v010,sndFlags, 0, SOUND_SEMANTIC_MECHANIC_ENTITY);
	end
end

function RigidBodyLight:PlaySoundLoop( soundName )
	if ( soundName and soundName~="") then
		local sndFlags=SOUND_DEFAULT_3D;
		sndFlags = bor( sndFlags, FLAG_SOUND_LOOP );
		local id = self:PlaySoundEvent( soundName, self.Properties.Sound.vOffset,g_Vectors.v010,sndFlags, 0, SOUND_SEMANTIC_MECHANIC_ENTITY);
		return id;
	end
end

function RigidBodyLight:PlayIdleSound()
	if (self.idleSoundId==0) then
		self.idleSoundId = self:PlaySoundLoop( self.Properties.Sound.soundIdle );
  end
end

function RigidBodyLight:PlayRunSound()
	if (self.runSoundId==0) then
		self.runSoundId = self:PlaySoundLoop( self.Properties.Sound.soundRun );
  end
end

function RigidBodyLight:StopIdleSound()
	if (self.idleSoundId~=0) then
		Sound.StopSound(self.idleSoundId);
		self.idleSoundId = 0;
	end
end

function RigidBodyLight:StopRunSound()
	if (self.runSoundId~=0) then
		Sound.StopSound(self.runSoundId);
		self.runSoundId = 0;
	end
end


function RigidBodyLight:OnEditorSetGameMode(gameMode)
	if (gameMode~=true) then
		self:StopIdleSound();
		self:StopRunSound();
	end
end



------------------------------------------------------------------------------------------------------
function RigidBodyLight:ShowLightOn()
  -- light source --
	if (self.lightSlot ~= (-1)) then
		self:FreeSlot(self.lightSlot);
		self.lightSlot = -1;
	end
	if (self.PropertiesInstance.LightProperties_Base.bUseThisLight ~= 0) then
		self:UseLight(1);
	end

  -- glow effect --
  local glowVal = self:GetMaterialFloat(0, self.PropertiesInstance.LightProperties_Base.Options.nGlowSubmatId, "glow" );
  if (self.origGlowValue and glowVal~=self.origGlowValue ) then
    self:SetMaterialFloat(0, self.PropertiesInstance.LightProperties_Base.Options.nGlowSubmatId, "glow", self.origGlowValue );
  end
end

------------------------------------------------------------------------------------------------------
function RigidBodyLight:ShowLightOff()

  -- light source --
	if (self.lightSlot ~= (-1)) then
		self:FreeSlot(self.lightSlot);
		self.lightSlot = -1;
	end
	if (self.PropertiesInstance.LightProperties_Destroyed.bUseThisLight ~= 0) then
		self:UseLight(0);
	end

  -- glow effect --
  local glowVal = self:GetMaterialFloat(0, self.PropertiesInstance.LightProperties_Base.Options.nGlowSubmatId, "glow" );
  if (glowVal~=0 ) then
		if (not self.materialIsCloned) then
			self:CloneMaterial(0);
			self.materialIsCloned = true;
		end
    self:SetMaterialFloat(0, self.PropertiesInstance.LightProperties_Base.Options.nGlowSubmatId, "glow", 0 );
  end
end

------------------------------------------------------------------------------------------------------
function RigidBodyLight.Client:OnPhysicsBreak( vPos,nPartId,nOtherPartId )
	self:ActivateOutput("Break",nPartId+1 );
	self.destroyed = true;
  self:ShowCorrectLight();
  self:StopRunSound();
  self:StopIdleSound();
  self:PlaySound( self.Properties.Sound.soundDestroy );
  self:SwitchOnOffChildren( false );
end


------------------------------------------------------------------------------
function RigidBodyLight:SwitchOnOffChildren( wantOn )
	local numChildren = self:GetChildCount();
	for i=0,numChildren do
		local child = self:GetChild(i);
		if (child and child.NotifySwitchOnOffFromParent) then
			child:NotifySwitchOnOffFromParent( wantOn )
		end
	end
end

function RigidBodyLight:NotifySwitchOnOffFromParent( wantOn )
  self:SwitchOnOff( wantOn );
end

function RigidBodyLight:SwitchOnOff( wantOn )
	if (not self.destroyed) then
	  local wantOff = wantOn~=true;
	  if (self.lightOn and wantOff ) then
		  self.lightOn = false;
			self:PlaySound( self.Properties.Sound.soundTurnOff );
		  BroadcastEvent( self, "Disabled" );
		  self:ShowCorrectLight();
		  self:SwitchOnOffChildren( wantOn );
		elseif (self.lightOn~=true and wantOn) then
      self.lightOn = true;
			self:PlaySound( self.Properties.Sound.soundTurnOn );
  	  BroadcastEvent( self, "Enabled" );
		  self:ShowCorrectLight();
		  self:SwitchOnOffChildren( wantOn );
		end
	end
end
    


------------------------------------------------------------------------------------------------------
function RigidBodyLight:OnDamage( hit )
	if( hit.ipart and hit.ipart>=0 ) then
		self:AddImpulse( hit.ipart, hit.pos, hit.dir, hit.impact_force_mul );
	end
end

----------------------------------------------------------------------------------------------------
function RigidBodyLight:ShowCorrectLight()
  if (self.lightOn and not self.destroyed) then
  	self:StopIdleSound();
  	self:PlayRunSound();
    self:ShowLightOn();
  else
    self:ShowLightOff();
  	self:StopRunSound();
    if (not self.destroyed) then
      self:PlayIdleSound();
    end
  end
end



------------------------------------------------------------------------------------------------------
-- Input events
------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------



----------------------------------------------------------------------------
function RigidBodyLight:UseLight( lightIdx )
	local props;
	if( lightIdx == 0) then 
	 props = self.PropertiesInstance.LightProperties_Destroyed;
	else
	 props = self.PropertiesInstance.LightProperties_Base;
	end
	local Style = props.Style;
	local Projector = props.Projector;
	local Color = props.Color;
	local Options = props.Options;

	local diffuse_mul = Color.fDiffuseMultiplier;
	local specular_mul = Color.fSpecularMultiplier;
	
	local lt = self._LightTable;
	lt.style = Style.nLightStyle;
	lt.corona_scale = Style.fCoronaScale;
	lt.corona_dist_size_factor = Style.fCoronaDistSizeFactor;
	lt.corona_dist_intensity_factor = Style.fCoronaDistIntensityFactor;
	lt.rotation = Style.Rotation;
	lt.anim_speed = Style.fAnimationSpeed;
	lt.anim_phase = Style.nAnimationPhase;
	lt.attenuation_map = Style.texture_AttenuationMap;
	
	lt.radius = props.Radius;
	lt.diffuse_color = { x=Color.clrDiffuse.x*diffuse_mul, y=Color.clrDiffuse.y*diffuse_mul, z=Color.clrDiffuse.z*diffuse_mul };
	if (diffuse_mul ~= 0) then
		lt.specular_multiplier = specular_mul / diffuse_mul;
	else
		lt.specular_multiplier = 1;
	end
	
	lt.hdrdyn = Color.fHDRDynamic;
	lt.projector_texture = Projector.texture_Texture;
	lt.proj_fov = Projector.fProjectorFov;
	lt.proj_nearplane = Projector.fProjectorNearPlane;
	lt.cubemap = Projector.bProjectInAllDirs;
	lt.this_area_only = Options.bAffectsThisAreaOnly;
	lt.hasclipbound = Options.bDeferredClipBounds;
	lt.ignore_visareas = Options.bIgnoresVisAreas;
	lt.disable_x360_opto = Options.bDisableX360Opto;
	lt.realtime = Options.bUsedInRealTime;
	lt.ambient_light = Options.bAmbientLight;		
	lt.irradiance_volumes = Options.bIrradianceVolumes;
	lt.deferred_cubemap = Options.texture_deferred_cubemap;
	lt.deferred_geom = Options.file_deferred_clip_geom;
	lt.heatsource = 0;
	lt.fake = Options.bFakeLight;
	lt.deferred_light = Options.bDeferredLight;
	lt.fill_light = props.Test.bFillLight;		
	lt.indoor_only = 0;
	lt.has_cbuffer = 0;
	lt.cast_shadow = Options.nCastShadows;
	lt.shadow_bias = Options.fShadowBias;
	lt.shadow_slope_bias = Options.fShadowSlopeBias;
	lt.post_effect = Options.nPostEffect;

	lt.shadowUpdate_MinRadius = Options.fShadowUpdateMinRadius;
	lt.shadowUpdate_ratio = Options.fShadowUpdateRatio;

	
	lt.lightmap_linear_attenuation = 1;
	lt.is_rectangle_light = 0;
	lt.is_sphere_light = 0;
	lt.area_sample_number = 1;
	
	lt.RAE_AmbientColor = { x = 0, y = 0, z = 0 };
	lt.RAE_MaxShadow = 1;
	lt.RAE_DistMul = 1;
	lt.RAE_DivShadow = 1;
	lt.RAE_ShadowHeight = 1;
	lt.RAE_FallOff = 2;
	lt.RAE_VisareaNumber = 0;

  lt.viewDistRatio = Options.nViewDistRatio;
	self.lightSlot = self:LoadLight( -1 ,lt );
  local angles = g_Vectors.temp_v1;
  angles.x = 0;
  local xyVectorLen = math.sqrt( props.vDirection.x*props.vDirection.x + props.vDirection.y*props.vDirection.y );
  angles.y = math.atan2( -props.vDirection.z, xyVectorLen );
  angles.z = math.atan2( props.vDirection.y, props.vDirection.x );
	self:SetSlotAngles(self.lightSlot, angles );
	local vec3offset = g_Vectors.temp_v1;
	vec3offset.x = props.vOffset.x;
	vec3offset.y = props.vOffset.y;
	vec3offset.z = props.vOffset.z;
	self:SetSlotPos(self.lightSlot, vec3offset );
	
	if ((Options.nCastShadows ~= 0) and (Options.bIgnoreGeomCaster ~= 0)) then
		self:SetSelfAsLightCasterException( self.lightSlot );
	end
end



------------------------------------------------------------------------------------------------------
-- Defaul state.
------------------------------------------------------------------------------------------------------
RigidBodyLight.Default = 
{
  OnBeginState = function(self)
    if (self:IsARigidBody()==1) then
      if (self.bRigidBodyActive~=self.Properties.Physics.bRigidBodyActive) then
        self:SetPhysicsProperties( 0,self.Properties.Physics.bRigidBodyActive );
      else
			  self:AwakePhysics(1-self.Properties.Physics.bResting);
		  end  
		end
	end,
	
	OnDamage = RigidBodyLight.OnDamage,
	OnCollision = RigidBodyLight.OnCollision,
	OnPhysicsBreak = RigidBodyLight.OnPhysicsBreak,
}

------------------------------------------------------------------------------------------------------
-- Activated state.
------------------------------------------------------------------------------------------------------
RigidBodyLight.Activated =
{
	OnBeginState = function(self)
	  if (self:IsARigidBody()==1 and self.bRigidBodyActive==0) then
      self:SetPhysicsProperties( 0,1 );
		  self:AwakePhysics(1);
	  end
	end,	
	
	OnDamage = RigidBodyLight.OnDamage,
	OnCollision = RigidBodyLight.OnCollision,
	OnPhysicsBreak = RigidBodyLight.OnPhysicsBreak,
}

RigidBodyLight.FlowEvents =
{
	Inputs =
	{
		Disable = { RigidBodyLight.Event_Disable, "bool" },
		Enable = { RigidBodyLight.Event_Enable, "bool" },
		Hide = { RigidBodyLight.Event_Hide, "bool" },
		UnHide = { RigidBodyLight.Event_UnHide, "bool" },
		DisableUsable = { RigidBodyLight.Event_DisableUsable, "bool" },
		EnableUsable = { RigidBodyLight.Event_EnableUsable, "bool" },
		Use = { RigidBodyLight.Event_Use, "bool" },
	},
	Outputs =
	{
	  Disabled = "bool",
	  Enabled = "bool",
		Hidden = "bool",
		UnHidden = "bool",
		Used = "bool",
		DisableUsable = "bool",
		EnableUsable = "bool",
		Break = "bool",
		Used = "bool",
		Health = "float",
	},
}


MakeUsable(RigidBodyLight);

function RigidBodyLight:OnUsed(user, idx)
	BroadcastEvent(self, "Used")
	if (not self.destroyed) then
	  local wantOn = self.lightOn==false;
	  self:SwitchOnOff( wantOn );
	end
end
