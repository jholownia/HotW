Birds = {
  type = "Birds",
  MapVisMask = 0,
	ENTITY_DETAIL_ID=1,

	Properties = {
		Flocking =
		{
			bEnableFlocking = 0,
			FieldOfViewAngle = 250,
			FactorAlign = 1,
			FactorCohesion = 1,
			FactorSeparation = 10,
			AttractDistMin = 5,
			AttractDistMax = 20,
		},
		Movement =
		{
			HeightMin = 5,
			HeightMax = 40,
			SpeedMin = 2.5,
			SpeedMax = 15,
			FactorOrigin = 0.1,
			FactorHeight = 0.4,
			FactorAvoidLand = 10,
			MaxAnimSpeed = 1.7,
		},
		Boid = 
		{
			nCount = 10,
			object_Model = "Objects/Characters/Animals/Birds/Pigeon/Pigeon_lf.chr",
			Size = 1,
			SizeRandom = 0,
			gravity_at_death = -9.81,
			Mass = 10,
		},
		Options = 
		{
			bFollowPlayer = 0,
			bNoLanding = 0,
			bObstacleAvoidance = 0,
			VisibilityDist = 200,
			bActivate = 1,
			Radius = 20,
			bSpawnFromPoint = 0,
		},
	},
	
	Animations = 
	{ 
		"fly_loop", -- flying 
		"landing", 
		"walk_loop", -- walk
		"idle_loop", -- idle
	},
	
	Editor = {
		Icon = "Bird.bmp"
	},
	
	params={x=0,y=0,z=0},
}


function Birds:OnSpawn()
	self:SetFlags(ENTITY_FLAG_CLIENT_ONLY, 0);
end

-------------------------------------------------------
function Birds:OnInit()
	self.flock = 0;
	self.currpos = {x=0,y=0,z=0};
	if (self.Properties.Options.bActivate == 1) then
		self:CreateFlock();
	end
end

-------------------------------------------------------
function Birds:OnShutDown()
end

-------------------------------------------------------
function Birds:CreateFlock()

	local Flocking = self.Properties.Flocking;
	local Movement = self.Properties.Movement;
	local Boid = self.Properties.Boid;
	local Options = self.Properties.Options;
	
	local params = self.params;

	params.count = Boid.nCount;
	params.model = Boid.object_Model;

	params.boid_size = Boid.Size;
	params.boid_size_random = Boid.SizeRandom;
	params.min_height = Movement.HeightMin;
	params.max_height = Movement.HeightMax;
	params.min_attract_distance = Flocking.AttractDistMin;
	params.max_attract_distance = Flocking.AttractDistMax;
	params.min_speed = Movement.SpeedMin;
	params.max_speed = Movement.SpeedMax;
	
	if (Flocking.bEnableFlocking == 1) then
		params.factor_align = Flocking.FactorAlign;
	else
		params.factor_align = 0;
	end
	params.factor_cohesion = Flocking.FactorCohesion;
	params.factor_separation = Flocking.FactorSeparation;
	params.factor_origin = Movement.FactorOrigin;
	params.factor_keep_height = Movement.FactorHeight;
	params.factor_avoid_land = Movement.FactorAvoidLand;
	
	params.spawn_radius = Options.Radius;
	params.gravity_at_death = Boid.gravity_at_death;
	params.boid_mass = Boid.Mass;

	params.fov_angle = Flocking.FieldOfViewAngle;

	params.max_anim_speed = Movement.MaxAnimSpeed;
	params.follow_player = Options.bFollowPlayer;
	params.no_landing = Options.bNoLanding;
	params.avoid_obstacles = Options.bObstacleAvoidance;
	params.max_view_distance = Options.VisibilityDist;
	params.spawn_from_point = Options.bSpawnFromPoint;
	params.Animations = self.Animations;
	
	if (self.flock == 0) then
		self.flock = 1;
		Boids.CreateFlock( self, Boids.FLOCK_BIRDS, params );
	end
	if (self.flock ~= 0) then
		Boids.SetFlockParams( self, params );
	end
end

-------------------------------------------------------
function Birds:OnPropertyChange()
	self:OnShutDown();
	if (self.Properties.Options.bActivate == 1) then
		self:CreateFlock();
	end
end

-------------------------------------------------------
function Birds:Event_Activate()

	if (self.Properties.Options.bActivate == 0) then
		if (self.flock==0) then
			self:CreateFlock();
		end
	end

	if (self.flock ~= 0) then
		Boids.EnableFlock( self,1 );
	end
	
	self:ActivateOutput("Activate", true);
end

-------------------------------------------------------
function Birds:Event_Deactivate()
	if (self.flock ~= 0) then
		Boids.EnableFlock( self,0 );
	end
	self:ActivateOutput("Deactivate", true);
end
-------------------------------------------------------
function Birds:Event_AttractTo(sender, point)
	Boids.SetAttractionPoint(self, point);
end

-------------------------------------------------------
function Birds:OnAttractPointReached()
	self:ActivateOutput("AttractEnd", true);
end

-------------------------------------------------------
function Birds:OnProceedFadeArea( player,areaId,fadeCoeff )
	if (self.flock ~= 0) then
		Boids.SetFlockPercentEnabled( self,fadeCoeff*100 );
	end
end

Birds.FlowEvents =
{
	Inputs =
	{
		Activate = { Birds.Event_Activate, "bool" },
		Deactivate = { Birds.Event_Deactivate, "bool" },
		AttractTo = { Birds.Event_AttractTo, "Vec3" },
	},
	Outputs =
	{
		Activate = "bool",
		Deactivate = "bool",
		AttractEnd = "bool",
	},
}
