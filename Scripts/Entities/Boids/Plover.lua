Script.ReloadScript( "Scripts/Entities/Boids/Chickens.lua" );

Plover = {
	Properties = {
	},
	Sounds = 
	{
                          "Sounds/environment:random_oneshots_natural:sandpiper_idle",   -- idle
                          "Sounds/environment:random_oneshots_natural:sandpiper_scared",  -- scared
                          "Sounds/environment:random_oneshots_natural:sandpiper_scared",    -- die
                          "Sounds/environment:random_oneshots_natural:sandpiper_scared",  -- pickup
                          "Sounds/environment:random_oneshots_natural:sandpiper_scared",  -- throw
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
		Icon = "Bird.bmp"
	},
}

MakeDerivedEntity( Plover,Chickens )


function Plover:OnSpawn()
	self:SetFlags(ENTITY_FLAG_CLIENT_ONLY, 0);
end
