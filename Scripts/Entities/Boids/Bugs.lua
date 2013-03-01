Bugs = {
  type = "Bugs",
  MapVisMask = 0,
	ENTITY_DETAIL_ID=1,
	
	Properties = {
		Movement =
		{
			HeightMin = 0,
			HeightMax = 1,
			SpeedMin = 1,
			SpeedMax = 2,
			FactorOrigin = 1,
			--FactorHeight = 0.4,
			--FactorAvoidLand = 10,
			MaxAnimSpeed = 1,
			RandomMovement = 1,
		},
		Boid = 
		{
			nCount = 10,
			object_Model1 = "Objects/characters/animals/Spider/spider.cgf",
			object_Model2 = "",
			object_Model3 = "",
			object_Model4 = "",
			object_Model5 = "",
			--object_Character = "",
			Animation = "",
			Size = 1,
			SizeRandom = 0,
			nBehaviour = 0,
		},
		Options = 
		{
			bFollowPlayer = 0,
			bNoLanding = 0,
			--bObstacleAvoidance = 0,
			VisibilityDist = 100,
			bActivate = 1,
			Radius = 20,
		},
	},

	Properties1 = {
		object_Model1 = "Objects\\Characters\\Animals\\Spider\\Spider.cgf",
		object_Model2 = "",
		object_Model3 = "",
		object_Model4 = "",
		object_Model5 = "",
		object_Character = "",
		
		nNumBugs = 10,
		nBehaviour = 0, -- 0 = BUG, 1 = Dragonfly, 2 = Frog 
		
		Scale = 1,
		
		HeightMin = 1,
		HeightMax = 5,
		
		SpeedMin = 5,
		SpeedMax = 15,
		
		FactorOrigin = 1,
		--FactorHeight = 0.4,
		--FactorAvoidLand = 10,
		RandomMovement = 1,
		
		bFollowPlayer = 0,

		Radius = 10,
		
		--boid_mass = 10,

		bActivateOnStart = 1,
		bNoLanding = 0,
		
		AnimationSpeed = 1,
		Animation = "",
		
		VisibilityDist = 100,
	},
	Animations = 
	{
		"walk_loop",   -- walking
		"idle01",      -- idle1
		"idle01",      -- idle2
		"idle01",      -- idle3
		"idle01",      -- pickup
		"idle01",      -- throw
	},
	Editor = {
		Icon = "Bug.bmp"
	},
	params={},
}

-------------------------------------------------------
--function Birds:OnLoad(table)
--end

-------------------------------------------------------
--function Birds:OnSave(table)
--end

-------------------------------------------------------
function Bugs:OnInit()

	self:NetPresent(0);
	--self:EnableSave(1);		

	self.flock = 0;
	self:CreateFlock();
	if (self.Properties.Options.bActivate ~= 1 and self.flock ~= 0) then
		Boids.EnableFlock( self,0 );
	end
end


function Bugs:OnSpawn()
	self:SetFlags(ENTITY_FLAG_CLIENT_ONLY, 0);
end

-------------------------------------------------------
function Bugs:OnShutDown()
end

-------------------------------------------------------
function Bugs:CreateFlock()
	--local Flocking = self.Properties.Flocking;
	local Movement = self.Properties.Movement;
	local Boid = self.Properties.Boid;
	local Options = self.Properties.Options;

  local params = self.params;
	params.count = Boid.nCount;
	
	params.behavior = Boid.nBehaviour;
	
	params.model = Boid.object_Model;
	params.model = Boid.object_Model1;
	params.model1 = Boid.object_Model2;
	params.model2 = Boid.object_Model3;
	params.model3 = Boid.object_Model4;
	params.model4 = Boid.object_Model5;
	--params.character = Boid.object_Character;

	params.boid_size = Boid.Size;
	params.boid_size_random = Boid.SizeRandom;
	params.min_height = Movement.HeightMin;
	params.max_height = Movement.HeightMax;
	--params.min_attract_distance = Flocking.AttractDistMin;
	--params.max_attract_distance = Flocking.AttractDistMax;
	params.min_speed = Movement.SpeedMin;
	params.max_speed = Movement.SpeedMax;
	
	--if (Flocking.bEnableFlocking == 1) then
		--params.factor_align = Flocking.FactorAlign;
	--else
		--params.factor_align = 0;
	--end
	--params.fov_angle = Flocking.FieldOfViewAngle;
	--params.factor_cohesion = Flocking.FactorCohesion;
	--params.factor_separation = Flocking.FactorSeparation;
	params.factor_origin = Movement.FactorOrigin;
	params.factor_keep_height = Movement.FactorHeight;
	params.factor_avoid_land = Movement.FactorAvoidLand;
	
	params.spawn_radius = Options.Radius;
	--params.boid_radius = Boid.boid_radius;
	params.gravity_at_death = Boid.gravity_at_death;
	params.boid_mass = Boid.Mass;

	params.max_anim_speed = Movement.MaxAnimSpeed;
	params.follow_player = Options.bFollowPlayer;
	params.no_landing = Options.bNoLanding;
	params.avoid_obstacles = Options.bObstacleAvoidance;
	params.max_view_distance = Options.VisibilityDist;
	
	if (self.flock == 0) then
		self.flock = 1;
		Boids.CreateFlock( self, Boids.FLOCK_BUGS, params );
	end
	if (self.flock ~= 0) then
		Boids.SetFlockParams( self, params );
	end
end

-------------------------------------------------------
function Bugs:OnPropertyChange()
	if (self.Properties.Options.bActivate == 1) then
		self:CreateFlock();
	end
end

-------------------------------------------------------
function Bugs:Event_Activate( sender )
	if (self.Properties.Options.bActivate == 0) then
		if (self.flock==0) then
			self:CreateFlock();
		end
	end

	if (self.flock ~= 0) then
		Boids.EnableFlock( self,1 );
	end
end

-------------------------------------------------------
function Bugs:Event_Deactivate( sender )
	if (self.flock ~= 0) then
		Boids.EnableFlock( self,0 );
	end
end

function Bugs:OnProceedFadeArea( player,areaId,fadeCoeff )
	if (self.flock ~= 0) then
		Boids.SetFlockPercentEnabled( self,fadeCoeff*100 );
	end
end

Bugs.FlowEvents =
{
	Inputs =
	{
		Activate = { Bugs.Event_Activate, "bool" },
		Deactivate = { Bugs.Event_Deactivate, "bool" },
	},
	Outputs =
	{
		Activate = "bool",
		Deactivate = "bool",
	},
}
