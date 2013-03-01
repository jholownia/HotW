SimpleLight =
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
			bCastShadow = 0,
			bAffectsThisAreaOnly = 1,
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

function SimpleLight:OnInit()
	self:SetFlags(ENTITY_FLAG_CLIENT_ONLY, 0);
	--self:NetPresent(0);
	self:OnReset();
	self:CacheResources("SimpleLight.lua");
end

function SimpleLight:CacheResources(requesterName)
	Game.CacheResource(requesterName, self.Properties.Projector.texture_Texture, eGameCacheResourceType_Texture, 0);
end

function SimpleLight:OnShutDown()
	self:FreeSlot(1);
end

function SimpleLight:OnLoad(props)
	self:OnReset()
	self:ActivateLight(props.bActive)
end

function SimpleLight:OnSave(props)
	props.bActive = self.bActive
end

function SimpleLight:OnPropertyChange()
	self:OnReset();
	self:ActivateLight( self.bActive );
end

function SimpleLight:OnReset()
	if (self.bActive ~= self.Properties.bActive) then
		self:ActivateLight( self.Properties.bActive );
	end
end

function SimpleLight:ActivateLight( enable )
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

function SimpleLight:LoadLightToSlot( nSlot )
	local props = self.Properties;
	local Style = props.Style;
	local Projector = props.Projector;
	local Color = props.Color;
	local Options = props.Options;

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
	
	lt.RAE_AmbientColor = { x = 0, y = 0, z = 0 };
	lt.RAE_MaxShadow = 1;
	lt.RAE_DistMul = 1;
	lt.RAE_DivShadow = 1;
	lt.RAE_ShadowHeight = 1;
	lt.RAE_FallOff = 2;
	lt.RAE_VisareaNumber = 0;

	self:LoadLight( nSlot,lt );
end

function SimpleLight:Event_Enable()
	if (self.bActive == 0) then
		self:ActivateLight( 1 );
	end
end

function SimpleLight:Event_Disable()
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
function SimpleLight:Event_Active( sender, bActive )
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
SimpleLight.FlowEvents =
{
	Inputs =
	{
		Active = { SimpleLight.Event_Active,"bool" },
		Enable = { SimpleLight.Event_Enable,"bool" },
		Disable = { SimpleLight.Event_Disable,"bool" },
	},
	Outputs =
	{
		Active = "bool",
	},
}
