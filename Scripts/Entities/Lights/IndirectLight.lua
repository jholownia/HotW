IndirectLight =
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
			clrDiffuse = { x=1,y=1,z=1 },
			fDiffuseMultiplier = 1,
			clrSpecular = { x=1,y=1,z=1},
			fSpecularMultiplier = 1,
			fHDRDynamic = 0,		-- -1=darker..0=normal..1=brighter
		},
		Options = {
			bCastShadow = 1,
			bAffectsThisAreaOnly = 1,
			bUsedInRealTime=1,
			bFakeLight=0,
			object_RenderGeometry="",
		},
		RAM = {
			clrIndirectColor = { x=1,y=1,z=1 },
			fIndirectMutiplier = 0.4,
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

function IndirectLight:OnInit()
	self:SetFlags(ENTITY_FLAG_CLIENT_ONLY, 0);
	--self:NetPresent(0);
	self:OnReset();
	self:CacheResources("IndirectLight.lua");
end

function IndirectLight:CacheResources(requesterName)
	Game.CacheResource(requesterName, self.Properties.Projector.texture_Texture, eGameCacheResourceType_Texture, 0);
end

function IndirectLight:OnShutDown()
	self:FreeSlot(1);
end

function IndirectLight:OnLoad(props)
	self:OnReset()
	self:ActivateLight(props.bActive)
end

function IndirectLight:OnSave(props)
	props.bActive = self.bActive
end

function IndirectLight:OnPropertyChange()
	self:OnReset();
	self:ActivateLight( self.bActive );
end

function IndirectLight:OnReset()
	if (self.Properties.Options.object_RenderGeometry ~= "") then
		self:LoadGeometry( 0,self.Properties.Options.object_RenderGeometry );
		self:DrawSlot( 0,1 );
	end
	if (self.bActive ~= self.Properties.bActive) then
		self:ActivateLight( self.Properties.bActive );
	end
end

function IndirectLight:ActivateLight( enable )
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

function IndirectLight:LoadLightToSlot( nSlot )
	local props = self.Properties;
	local Style = props.Style;
	local Projector = props.Projector;
	local Color = props.Color;
	local Options = props.Options;
	local RAE = props.RAM;

	local diffuse_mul = Color.fDiffuseMultiplier;
	local specular_mul = Color.fSpecularMultiplier;
	
	local lt = self._LightTable;
	lt.style = Style.nLightStyle;
	lt.corona_scale = Style.fCoronaScale;
	lt.corona_dist_size_factor = Style.fCoronaDistSizeFactor;
	lt.corona_dist_intensity_factor = Style.fCoronaDistIntensityFactor;
	lt.radius = props.Radius;
	lt.diffuse_color = { x=Color.clrDiffuse.x*diffuse_mul, y=Color.clrDiffuse.y*diffuse_mul, z=Color.clrDiffuse.z*diffuse_mul };
	lt.specular_color = { x=Color.clrSpecular.x*specular_mul, y=Color.clrSpecular.y*specular_mul, z=Color.clrSpecular.z*specular_mul };

	lt.hdrdyn = Color.fHDRDynamic;
	lt.projector_texture = Projector.texture_Texture;
	lt.proj_fov = Projector.fProjectorFov;
	lt.cubemap = Projector.bProjectInAllDirs;
	lt.this_area_only = Options.bAffectsThisAreaOnly;
	lt.realtime = Options.bUsedInRealTime;
	lt.heatsource = 0;
	lt.fake = Options.bFakeLight;
	lt.indoor_only = 0;
	lt.has_cbuffer = 0;
	lt.cast_shadow = Options.bCastShadow;

	lt.lightmap_linear_attenuation = 1;
	lt.is_rectangle_light = 0;
	lt.is_sphere_light = 0;
	lt.area_sample_number = 1;
	
	local RAE_PhotonEnergy = RAE.fIndirectMutiplier;
	lt.RAE_AmbientColor = { x = RAE.clrIndirectColor.x*RAE_PhotonEnergy, y = RAE.clrIndirectColor.y*RAE_PhotonEnergy, z = RAE.clrIndirectColor.z*RAE_PhotonEnergy };

	
	self:LoadLight( nSlot,lt );
end

function IndirectLight:Event_Enable()
	if (self.bActive == 0) then
		self:ActivateLight( 1 );
	end
end

function IndirectLight:Event_Disable()
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
function IndirectLight:Event_Active( sender, bActive )
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
IndirectLight.FlowEvents =
{
	Inputs =
	{
		Active = { IndirectLight.Event_Active,"bool" },
		Enable = { IndirectLight.Event_Enable,"bool" },
		Disable = { IndirectLight.Event_Disable,"bool" },
	},
	Outputs =
	{
		Active = "bool",
	},
}
