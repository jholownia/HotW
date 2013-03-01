Light =
{
	Properties =
	{
		_nVersion = -1,
		bActive = 1,
		Radius = 10,
		Style =
		{
			nLightStyle = 0,
			Rotation = {x=0.0,y=0.0,z=0.0},
			fAnimationSpeed = 1,
			nAnimationPhase = 0,
			fCoronaScale = 1,
			fCoronaIntensity = 1;
			fCoronaDistSizeFactor = 1,
			fCoronaDistIntensityFactor = 1,
			fShaftSrcSize = 19.0,
			fShaftLength = 95.0, 
			fShaftBrightness = 10.0, 
			fShaftBlendFactor = 10.0,
			fShaftDecayFactor = 88.0,
			nCoronaShaftsMinSpec = 3,  -- 0-low   1-med   2-high   3-v.high
			nLensGhostsMinSpec = 3,   -- 0-low   1-med   2-high   3-v.high
			texture_AttenuationMap = "",
			lightanimation_LightAnimation = "",
			bTimeScrubbingInTrackView = 0,
			_fTimeScrubbed = 0,
		},
		Projector =
		{
			texture_Texture = "",
			bProjectInAllDirs = 0,
			fProjectorFov = 90,
			fProjectorNearPlane = 0,
		},
		Color = {
			clrDiffuse = { x=1,y=1,z=1 },
			fDiffuseMultiplier = 1,
			fSpecularMultiplier = 1,
			fHDRDynamic = 0,		-- -1=darker..0=normal..1=brighter
		},
		Options = {
			bCastShadow = 0,
			nCastShadows = 0,
			fShadowBias = 1,
			fShadowSlopeBias = 1,
			bAffectsThisAreaOnly = 1,
			bIgnoresVisAreas = 0,
			--bUsedInRealTime = 1,
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
		},
	},

	Editor=
	{
		--Model="Editor/Objects/Light_Omni.cgf",
		--Icon="Light.tif",
		Icon="Light.bmp",
		ShowBounds=0,
		AbsoluteRadius = 1,
		IsScalable = false;
	},

	_LightTable = {},
}

LightSlot = 1

function Light:OnInit()
	--self:NetPresent(0);
	self:SetFlags(ENTITY_FLAG_CLIENT_ONLY, 0);
	self:OnReset();
	self:CacheResources("Light.lua");
end

function Light:CacheResources(requesterName)

end

function Light:OnShutDown()
	self:FreeSlot(LightSlot);
end

function Light:OnLoad(props)
	self:OnReset()
	self:ActivateLight(props.bActive)
end

function Light:OnSave(props)
	props.bActive = self.bActive
end

function Light:OnPropertyChange()
	self:OnReset();
	self:ActivateLight( self.bActive );
	if (self.Properties.Options.bDeferredClipBounds) then
		self:UpdateLightClipBounds(LightSlot);
	end
end

function Light:OnLevelLoaded()
	if (self.Properties.Options.bDeferredClipBounds) then
		self:UpdateLightClipBounds(LightSlot);
	end
end

function Light:OnReset()
	if (self.bActive ~= self.Properties.bActive) then
		self:ActivateLight( self.Properties.bActive );
	end
end

function Light:ActivateLight( enable )
	if (enable and enable ~= 0) then
		self.bActive = 1;
		self:LoadLightToSlot(LightSlot);
		self:ActivateOutput( "Active",true );
	else
		self.bActive = 0;
		self:FreeSlot(LightSlot);
		self:ActivateOutput( "Active",false );
	end
end

function Light:LoadLightToSlot( nSlot )
	local props = self.Properties;
	local Style = props.Style;
	local Projector = props.Projector;
	local Color = props.Color;
	local Options = props.Options;

	local diffuse_mul = Color.fDiffuseMultiplier;
	local specular_mul = Color.fSpecularMultiplier;
	
	local lt = self._LightTable;
	lt.style = Style.nLightStyle;
	lt.corona_scale = Style.fCoronaScale;
	lt.corona_intensity = Style.fCoronaIntensity;
	lt.corona_dist_size_factor = Style.fCoronaDistSizeFactor;
	lt.corona_dist_intensity_factor = Style.fCoronaDistIntensityFactor;
	lt.shaft_src_size = Style.fShaftSrcSize;
	lt.shaft_length = Style.fShaftLength;
	lt.shaft_brightness = Style.fShaftBrightness;
	lt.shaft_blend_factor = Style.fShaftBlendFactor;
	lt.shaft_decay_factor = Style.fShaftDecayFactor;
	lt.corona_shafts_min_spec = Style.nCoronaShaftsMinSpec;
	lt.lens_ghosts_min_spec = Style.nLensGhostsMinSpec;
	lt.rotation = Style.Rotation;
	lt.anim_speed = Style.fAnimationSpeed;
	lt.anim_phase = Style.nAnimationPhase;
	lt.attenuation_map = Style.texture_AttenuationMap;
	lt.light_animation = Style.lightanimation_LightAnimation;
	lt.time_scrubbing_in_trackview = Style.bTimeScrubbingInTrackView;
	lt.time_scrubbed = Style._fTimeScrubbed;
	
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
	lt.fake = Options.bFakeLight;
	lt.deferred_light = Options.bDeferredLight;
	lt.post_effect = Options.nPostEffect;
	lt.irradiance_volumes = Options.bIrradianceVolumes;
	lt.ambient_light = props.Options.bAmbientLight;		
	lt.indoor_only = 0;
	lt.has_cbuffer = 0;
	lt.cast_shadow = Options.nCastShadows;
	lt.shadow_bias = Options.fShadowBias;
	lt.shadow_slope_bias = Options.fShadowSlopeBias;
	lt.deferred_cubemap = Options.texture_deferred_cubemap;
	lt.deferred_geom = Options.file_deferred_clip_geom;
	lt.shadowUpdate_MinRadius = Options.fShadowUpdateMinRadius;
	lt.shadowUpdate_ratio = Options.fShadowUpdateRatio;
		
	lt.lightmap_linear_attenuation = 1;
	lt.is_rectangle_light = 0;
	lt.is_sphere_light = 0;
	lt.area_sample_number = 1;

	self:LoadLight( nSlot,lt );
end

function Light:Event_Enable()
	if (self.bActive == 0) then
		self:ActivateLight( 1 );
	end
end

function Light:Event_Disable()
	if (self.bActive == 1) then
		self:ActivateLight( 0 );
	end
end

function Light:NotifySwitchOnOffFromParent(wantOn)
  local wantOff = wantOn~=true;
	if (self.bActive == 1 and wantOff) then
		self:ActivateLight( 0 );
	elseif (self.bActive == 0 and wantOn) then
		self:ActivateLight( 1 );
	end
end


-----------------------------------------------------
function Light:OnNanoSuitDischarge()
	self:Event_Disable();
end

----------------------------------------------------
function Light:OnTouchedByNanoWeapon()
	self:Event_Enable();
end

------------------------------------------------------------------------------------------------------
-- Event Handlers
------------------------------------------------------------------------------------------------------
function Light:Event_Active( sender, bActive )
	if (self.bActive == 0 and bActive == true) then
		self:ActivateLight( 1 );
	else 
		if (self.bActive == 1 and bActive == false) then
			self:ActivateLight( 0 );
		end
	end
end


------------------------------------------------------------------------------------------------------
-- Event descriptions.
------------------------------------------------------------------------------------------------------
Light.FlowEvents =
{
	Inputs =
	{
		Active = { Light.Event_Active,"bool" },
		Enable = { Light.Event_Enable,"bool" },
		Disable = { Light.Event_Disable,"bool" },
	},
	Outputs =
	{
		Active = "bool",
	},
}
