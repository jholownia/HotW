-- #Script.ReloadScript("scripts/default/entities/player/basicplayer.lua")

DeadBody = {
 	type = "DeadBody",
	temp_ModelName = "",
		
	DeadBodyParams = {
		max_time_step = 0.025,
		gravityz = -7.5,
		sleep_speed = 0.025,
		damping = 0.3,
		freefall_gravityz = -9.81,
		freefall_damping = 0.1,

		lying_mode_ncolls = 4,
		lying_gravityz = -5.0,
		lying_sleep_speed = 0.065,
		lying_damping = 1.5,
		sim_type = 1,
		lying_simtype = 1,
	},

	PhysParams = {
		mass = 80,
		height = 1.8,
		eyeheight = 1.7,
		sphereheight = 1.2,
		radius = 0.45,
		lod = 1,
	},

	BulletImpactParams = {
		stiffness_scale = 73,
		max_time_step = 0.01
	},

	Properties = {
		soclasses_SmartObjectClass = "",
		bResting = 0,
		
		object_Model = "Objects/Characters/sdk_player/sdk_player.cdf",	
		lying_gravityz = -5.0,
		lying_damping = 1.5,
		bCollidesWithPlayers = 0,
		bPushableByPlayers = 0,
		Mass = 80,
		bNoFriendlyFire = 0,
		
		Buoyancy=
		{
			water_density = 1000,
			water_damping = 0,
			water_resistance = 1000,	
		},
	},
  	
	Editor = {
		Icon = "DeadBody.bmp",
		IconOnTop=1,
	},
}

-------------------------------------------------------
function DeadBody:OnLoad(table)
	self.temp_ModelName = table.temp_ModelName
	self.PhysParams = table.PhysParams
	self.DeadBodyParams = table.DeadBodyParams
end

-------------------------------------------------------
function DeadBody:OnSave(table)
	table.temp_ModelName = self.temp_ModelName
	table.PhysParams = self.PhysParams
	table.DeadBodyParams = self.DeadBodyParams
end


-----------------------------------------------------------------------------------------------------------
function DeadBody:OnReset()
	--self.temp_ModelName ="";
	--self:OnPropertyChange();
	
	self:LoadCharacter(0,self.Properties.object_Model);
	--self:StartAnimation( 0,"cidle" );
	self:PhysicalizeThis();
end


-----------------------------------------------------------------------------------------------------------
function DeadBody:Server_OnInit()
	if (not CryAction.IsServer()) then
		DeadBody.OnPropertyChange( self );
	end
end


-----------------------------------------------------------------------------------------------------------
function DeadBody:Client_OnInit()
	DeadBody.OnPropertyChange( self );

	self:SetUpdatePolicy( ENTITY_UPDATE_PHYSICS_VISIBLE );
	--self:Activate(1);

--	self:RenderShadow( 1 ); -- enable rendering of player shadow
--  self:SetShaderFloat("HeatIntensity",0,0,0);
end


-----------------------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------------------
function DeadBody:Server_OnDamageDead( hit )
--printf("server on Damage DEAD %.2f %.2f",hit.impact_force_mul_final,hit.impact_force_mul);
  --System.Log("DeadBody hit part "..hit.ipart);
	if( hit.ipart ) then
		self:AddImpulse( hit.ipart, hit.pos, hit.dir, hit.impact_force_mul );
	else	
		self:AddImpulse( -1, hit.pos, hit.dir, hit.impact_force_mul );
	end	
end

-----------------------------------------------------------------------------------------------------------

function DeadBody:OnHit()
	BroadcastEvent( self,"Hit" );
end

-----------------------------------------------------------------------------------------------------------

function DeadBody:OnPropertyChange()
	--System.LogToConsole("prev:"..self.temp_ModelName.." new:"..self.Properties.object_Model);
	
	self.PhysParams.mass = self.Properties.Mass;

	if (self.Properties.object_Model ~= self.temp_ModelName) then
		self.temp_ModelName = self.Properties.object_Model;
		self:LoadCharacter(0,self.Properties.object_Model);
	end
	self:PhysicalizeThis();
end

--------------------------------------------------------------------------------------------------------
function DeadBody:PhysicalizeThis()
	local Properties = self.Properties;
	self.PhysParams.mass = Properties.Mass;
	
	self:Physicalize( 0, PE_ARTICULATED, self.PhysParams );

	self:SetPhysicParams(PHYSICPARAM_SIMULATION, self.Properties );
	self:SetPhysicParams(PHYSICPARAM_BUOYANCY, self.Properties.Buoyancy );
	
	if (Properties.lying_damping) then
		self.DeadBodyParams.lying_damping = Properties.lying_damping;
	end	
	if (Properties.lying_gravityz) then
		self.DeadBodyParams.lying_gravityz = Properties.lying_gravityz;
	end	
	self:SetPhysicParams(PHYSICPARAM_SIMULATION, self.DeadBodyParams);
	self:SetPhysicParams(PHYSICPARAM_ARTICULATED, self.DeadBodyParams);
	
	local flagstab = { flags_mask=geom_colltype_player, flags=geom_colltype_player*Properties.bCollidesWithPlayers };
	flagstab.flags_mask = geom_colltype_explosion + geom_colltype_ray + geom_colltype_foliage_proxy + geom_colltype_player;
	self:SetPhysicParams(PHYSICPARAM_PART_FLAGS, flagstab);
	flagstab.flags_mask = pef_pushable_by_players;
	flagstab.flags = pef_pushable_by_players*Properties.bPushableByPlayers;
	self:SetPhysicParams(PHYSICPARAM_FLAGS, flagstab);
	if (Properties.bResting == 1) then
		self:AwakePhysics(0);
	else
		self:AwakePhysics(1);
	end
	self:EnableProceduralFacialAnimation(false);
	self:PlayFacialAnimation("death_pose_0"..random(1,5), true);
	-- small hack: we need one update to sync physics and animation, so here it is after physicalization
	-- (our OnUpdate function should just deactivate immediately.)
	--self:Activate(1);
end

--function DeadBody:OnUpdate()
	--self:Activate(0);
--end

function DeadBody:Event_Hide()
	self:Hide(1);
end;

------------------------------------------------------------------------------------------------------
function DeadBody:Event_UnHide()
	self:Hide(0);
end;

--------------------------------------------------------------------------------------------------------
function DeadBody:Event_Awake()
	self:AwakePhysics(1);
end

--------------------------------------------------------------------------------------------------------
function DeadBody:Event_Hit(sender)
	BroadcastEvent(self, "Hit");
end

--------------------------------------------------------------------------------------------------------
DeadBody.Server =
{
	OnInit = DeadBody.Server_OnInit,
--	OnShutDown = function( self ) end,
	OnDamage = DeadBody.Server_OnDamageDead,
	OnHit = DeadBody.OnHit,
	OnUpdate=DeadBody.OnUpdate,
}

--------------------------------------------------------------------------------------------------------
DeadBody.Client =
{
	OnInit = DeadBody.Client_OnInit,
--	OnShutDown = DeadBody.Client_OnShutDown,
	OnDamage=DeadBody.Client_OnDamage,
	OnUpdate=DeadBody.OnUpdate,
}

--------------------------------------------------------------------

DeadBody.FlowEvents =
{
	Inputs =
	{
		Awake = { DeadBody.Event_Awake, "bool" },
		Hide = { DeadBody.Event_Hide, "bool" },
		UnHide = { DeadBody.Event_UnHide, "bool" },
	},
	Outputs =
	{
		Awake = "bool",
		Hit = "bool",
	},
}

MakeInterestingToAI(DeadBody, 0);