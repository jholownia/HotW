AIAnchorTable = {
	-- combat anchors
	COMBAT_PROTECT_THIS_POINT	= 314,
	COMBAT_HIDESPOT = 320,
	COMBAT_HIDESPOT_SECONDARY = 330,
	COMBAT_ATTACK_DIRECTION = 321,
	COMBAT_TERRITORY = 342,

	SEARCH_SPOT = 343,
	
	-- alert anchors
	ALERT_STANDBY_IN_RANGE = 340,
	ALERT_STANDBY_SPOT = 341,
	
	--- sniper
	SNIPER_SPOT	= 324,
	--- RPG
	RPG_SPOT	= 319,

	-- suit advanve point - for boss/super jump
	SUIT_SPOT	= 325,
	
	--- tank combat
	TANK_SPOT	= 326,
	TANK_HIDE_SPOT	= 327,
	HELI_HIDE_SPOT	= 328,
	
	-- actions anchors
--	ACTION_LOOK_AROUND = 353,
--	ACTION_RECOG_CORPSE = 354,
	
	-- alien indoor related	
	ALIEN_HIDESPOT = 504,
	ALIEN_SCOUT_ATTACKSPOT = 507,
	ALIEN_SCOUT_JAMMERSPHERE = 508,

	ALIEN_COMBAT_AMBIENT_PATH = 509,
	ALIEN_COMBAT_DEATH_PATH = 510,
	ALIEN_AMBUSH_AREA = 322,
	ALIEN_AMBUSH_HIDESPOT = 323,
	
	-- Shark
	SHARK_ESCAPE_SPOT = 350,
	
	-- civilian
	CIVILIAN_COWER_POINT = 800,

	-- for anchors used as smart objects with group id
	SMART_OBJECT = 700,

	-- Light condition related anchors.
	LIGHTSPOT_LIGHT = 401,
	LIGHTSPOT_MEDIUM = 402,
	LIGHTSPOT_DARK = 403,

	-- ai will not throw grenades near this anchor (not to damage it)
	-- the anchor radius used for distance check
	NOGRENADE_SPOT = 405,	-- used in C++ code too!
	
	FOLLOW_AREA = 801,
	FOLLOW_PATH = 802,

	RACE_ROAD = 900,
}
