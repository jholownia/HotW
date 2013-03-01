Frogs = {
  type = "Boids",

	Properties = {
		Movement =
		{
			SpeedMin = 2,
			SpeedMax = 4,
			MaxAnimSpeed = 1,
		},
		Boid = 
		{
			nCount = 10,
			object_Model = "objects/characters/animals/amphibians/toad/toad.chr",
			Size = 1,
			SizeRandom = 0,
			Mass = 1,
		},
		Options = 
		{
			bFollowPlayer = 0,
			bObstacleAvoidance = 1,
			VisibilityDist = 100,
			bActivate = 1,
			Radius = 10,
		},
	},
	
	Sounds = 
	
	{
                          "Sounds/environment:boids:idle_frog",   -- idle
                          "Sounds/environment:boids:scared_frog",  -- scared
                          "Sounds/environment:boids:death_frog",    -- die
                          "Sounds/environment:boids:idle_frog",  -- pickup
                          "Sounds/environment:boids:scared_frog",  -- throw
	},
	Animations = 
	{
	    "walk_loop",  -- if distance to the player is less than 3m
		"idle01_loop",
		"",
		"",
		"pickup",
		"throw",
	},
	Editor = {
		Icon = "Bug.bmp"
	},
	params={x=0,y=0,z=0},
}


function Frogs:OnSpawn()
	self:SetFlags(ENTITY_FLAG_CLIENT_ONLY, 0);
end

-------------------------------------------------------
function Frogs:OnInit()

	--self:NetPresent(0);
	--self:EnableSave(1);

	self.flock = 0;
	self.currpos = {x=0,y=0,z=0};
	if (self.Properties.Options.bActivate == 1) then
		self:CreateFlock();
	end
end

-------------------------------------------------------
function Frogs:OnShutDown()
end

-------------------------------------------------------
--function Frogs:OnLoad(table)
--end

-------------------------------------------------------
--function Frogs:OnSave(table)
--end

-------------------------------------------------------
function Frogs:CreateFlock()

	local Movement = self.Properties.Movement;
	local Boid = self.Properties.Boid;
	local Options = self.Properties.Options;
	
	local params = self.params;

	params.count = Boid.nCount;
	params.model = Boid.object_Model;

	params.boid_size = Boid.Size;
	params.boid_size_random = Boid.SizeRandom;
	params.min_speed = Movement.SpeedMin;
	params.max_speed = Movement.SpeedMax;
	
	params.factor_align = 0;

	params.spawn_radius = Options.Radius;
	--params.boid_radius = Boid.boid_radius;
	params.gravity_at_death = -9.81;
	params.boid_mass = Boid.Mass;

	params.max_anim_speed = Movement.MaxAnimSpeed;
	params.follow_player = Options.bFollowPlayer;
	params.avoid_obstacles = Options.bObstacleAvoidance;
	params.max_view_distance = Options.VisibilityDist;
	
	params.Sounds = self.Sounds;
	params.Animations = self.Animations;
	
	if (self.flock == 0) then
		self.flock = 1;
		Boids.CreateFlock( self, Boids.FLOCK_FROGS, params );
	end
	if (self.flock ~= 0) then
		Boids.SetFlockParams( self, params );
	end
end

-------------------------------------------------------
function Frogs:OnPropertyChange()
	self:OnShutDown();
	if (self.Properties.Options.bActivate == 1) then
		self:CreateFlock();
	end
end

-------------------------------------------------------
function Frogs:Event_Activate()

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
function Frogs:Event_Deactivate()
	if (self.flock ~= 0) then
		Boids.EnableFlock( self,0 );
	end
end

function Frogs:OnProceedFadeArea( player,areaId,fadeCoeff )
	if (self.flock ~= 0) then
		Boids.SetFlockPercentEnabled( self,fadeCoeff*100 );
	end
end

Frogs.FlowEvents =
{
	Inputs =
	{
		Activate = { Frogs.Event_Activate, "bool" },
		Deactivate = { Frogs.Event_Deactivate, "bool" },
	},
	Outputs =
	{
		Activate = "bool",
		Deactivate = "bool",
	},
}
