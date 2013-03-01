SimpleIndirectLight =
{
	Properties =
	{
		bActive = 1,
		Radius = 10,
		Style =
		{
			fCoronaScale = 1,
			fCoronaDistSizeFactor = 1,
			fCoronaDistIntensityFactor = 1,
			nLightStyle = 0,
		},
		Projector =
		{
			texture_Texture = "",
			bProjectInAllDirs = 0,
			fProjectorFov = 90,
		},
		Color = {
			clrColor = { x=1,y=1,z=1 },
			fColorMultiplier = 1,
			fSpecularPercentage = 100,
			fHDRDynamic = 0,		-- -1=darker..0=normal..1=brighter
		},
		Options = {
			bCastShadow = 1,
			bAffectsThisAreaOnly = 1,
		},
		RAM = {
			fIndirectMutiplier = 0.4,
			fRadius = 10,
			fReflectionStrength = 99.77,
			fLightFalloff = 0.4,
			fShadowSize = 10,
			nAffectSurroundingVISareas= 1,
		},
	},

	TempPos = {x=0.0,y=0.0,z=0.0},

	Editor=
	{
		--Model="Editor/Objects/Light_Omni.cgf",
		--Icon="Light.tif",
		Icon="Light.bmp",
		ShowBounds=0,
		AbsoluteRadius = 1,
	},

	_LightTable = {},
}

function SimpleIndirectLight:OnInit()
	self:SetFlags(ENTITY_FLAG_CLIENT_ONLY, 0);
	--self:NetPresent(0);
	self:OnReset();
	self:CacheResources("SimpleIndirectLight.lua");
end

function SimpleIndirectLight:CacheResources(requesterName)
	Game.CacheResource(requesterName, self.Properties.Projector.texture_Texture, eGameCacheResourceType_Texture, 0);
end

function SimpleIndirectLight:OnShutDown()
	self:FreeSlot(1);
end

function SimpleIndirectLight:OnLoad(props)
	self:OnReset()
	self:ActivateLight(props.bActive)
end

function SimpleIndirectLight:OnSave(props)
	props.bActive = self.bActive
end

function SimpleIndirectLight:OnPropertyChange()
	self:OnReset();
	self:ActivateLight( self.bActive );
end

function SimpleIndirectLight:OnReset()
	if (self.bActive ~= self.Properties.bActive) then
		self:ActivateLight( self.Properties.bActive );
	end
end

function SimpleIndirectLight:ActivateLight( enable )
	if (enable and enable ~= 0) then
		self.bActive = 1;
		self:LoadLightToSlot(1);
		self:ActivateOutput( "Active",true );
	else
		self.bActive = 0;
		self:FreeSlot(1);
		self:ActivateOutput( "Active",false );
	end
end

function SimpleIndirectLight:LoadLightToSlot( nSlot )
	local props = self.Properties;
	local Style = props.Style;
	local Projector = props.Projector;
	local Color = props.Color;
	local Options = props.Options;
	local RAE = props.RAM;

	local diffuse_mul = Color.fColorMultiplier;
	local specular_mul = Color.fSpecularPercentage*0.01;
	
	local lt = self._LightTable;
	lt.style = Style.nLightStyle;
	lt.corona_scale = Style.fCoronaScale;
	lt.corona_dist_size_factor = Style.fCoronaDistSizeFactor;
	lt.corona_dist_intensity_factor = Style.fCoronaDistIntensityFactor;
	lt.radius = props.Radius;
	lt.diffuse_color = { x=Color.clrColor.x*diffuse_mul, y=Color.clrColor.y*diffuse_mul, z=Color.clrColor.z*diffuse_mul };
        lt.specular_multiplier = specular_mul;

	lt.hdrdyn = Color.fHDRDynamic;
	lt.projector_texture = Projector.texture_Texture;
	lt.proj_fov = Projector.fProjectorFov;
	lt.cubemap = Projector.bProjectInAllDirs;
	lt.this_area_only = Options.bAffectsThisAreaOnly;
	lt.realtime = 1;
	lt.heatsource = 0;
	lt.fake = 0;
	lt.indoor_only = 0;
	lt.has_cbuffer = 0;
	lt.cast_shadow = Options.bCastShadow;

	lt.lightmap_linear_attenuation = 1;
	lt.is_rectangle_light = 0;
	lt.is_sphere_light = 0;
	lt.area_sample_number = 1;
	
	local RAE_PhotonEnergy = RAE.fIndirectMutiplier*diffuse_mul;
	lt.RAE_AmbientColor = { x = Color.clrColor.x*RAE_PhotonEnergy, y = Color.clrColor.y*RAE_PhotonEnergy, z = Color.clrColor.z*RAE_PhotonEnergy };

	lt.RAE_MaxShadow = RAE.fReflectionStrength;
	lt.RAE_DistMul = RAE.fLightFalloff;
	lt.RAE_DivShadow = RAE.fShadowSize;
	lt.RAE_Radius = RAE.fRadius;

	
	lt.RAE_ShadowHeight = RAE.fReflectionStrength;
	lt.RAE_FallOff = 2;
	lt.RAE_VisareaNumber = RAE.nAffectSurroundingVISareas;

	self:LoadLight( nSlot,lt );
end

function SimpleIndirectLight:Event_Enable()
	if (self.bActive == 0) then
		self:ActivateLight( 1 );
	end
end

function SimpleIndirectLight:Event_Disable()
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


------------------------------------------------------------------------------------------------------
-- Event Handlers
------------------------------------------------------------------------------------------------------
function SimpleIndirectLight:Event_Active( sender, bActive )
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
SimpleIndirectLight.FlowEvents =
{
	Inputs =
	{
		Active = { SimpleIndirectLight.Event_Active,"bool" },
		Enable = { SimpleIndirectLight.Event_Enable,"bool" },
		Disable = { SimpleIndirectLight.Event_Disable,"bool" },
	},
	Outputs =
	{
		Active = "bool",
	},
}
