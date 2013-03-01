Script.ReloadScript( "Scripts/Entities/Boids/Chickens.lua" );

Turtles = {
	Properties = {
		Boid = 
		{
			object_Model = "Objects/Characters/Animals/turtles/red_eared_slider/red_eared_slider.chr",
		},
		Movement =
		{
			SpeedMin = 0.2,
			SpeedMax = 0.5,
			MaxAnimSpeed = 2,
		},
	},
	Sounds = 
	{
                          "Sounds/environment:boids:idle_turtle",   -- idle
                          "Sounds/environment:boids:scared_turtle",  -- scared
                          "Sounds/environment:boids:scared_turtle",    -- die
                          "Sounds/environment:boids:scared_turtle",  -- pickup
                          "Sounds/environment:boids:scared_turtle",  -- throw
	},
	Animations = 
	{
		"walk_loop",   -- walking
		"idle_loop",      -- idle1
		"idle3",      -- idle2/scared
		"idle3",      -- idle3
		"pickup",      -- pickup
		"throw",      -- throw
	},
	Editor = {
		Icon = "Bird.bmp"
	},
}

MakeDerivedEntityOverride( Turtles,Chickens )


function Turtles:OnSpawn()
	self:SetFlags(ENTITY_FLAG_CLIENT_ONLY, 0);
end

function Turtles:GetFlockType()
	return Boids.FLOCK_TURTLES;
end