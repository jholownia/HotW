local file = "SCRIPTS/AI/pathfindProperties.xml";
AI.LoadPathfindProperties(file);
if (System.IsEditor() and EditorAI) then
	EditorAI.LoadPathfindProperties(file);
end


--[[
function AssignPFPropertiesToPathType(...)
	AI.AssignPFPropertiesToPathType(...);
	if (System.IsEditor() and EditorAI) then
		EditorAI.AssignPFPropertiesToPathType(...);
	end
end

-- character that travels on the surface but has no preferences
AssignPFPropertiesToPathType(
	"AIPATH_DEFAULT",
	NAV_TRIANGULAR + NAV_WAYPOINT_HUMAN + NAV_SMARTOBJECT,
	0.0, 0.0, 0.0, 0.0, 0.0, 
	5.0, 0.5, -10000.0, 0.0, 20.0, 7.0,
	0, 0.3, 2.0, 45.0, 1, true);

AssignPFPropertiesToPathType(
	"AIPATH_HUMAN",
	NAV_TRIANGULAR + NAV_WAYPOINT_HUMAN + NAV_SMARTOBJECT,
	0.0, 0.0, 0.0, 0.0, 0.0, 
	5.0, 0.5, -10000.0, 0.0, 20.0, 7.0,
	0, 0.3, 2.0, 45.0, 1, true);

-- Default properties for car/vehicle agents
AssignPFPropertiesToPathType(
	"AIPATH_CAR",
	NAVMASK_SURFACE, 
	18.0, 18.0, 0.0, 0.0, 0.0, 
	0.0, 1.5, -10000.0, 0.0, 0.0, 7.0,
	0, 0.3, 2.0, 0.0, 4, true);

AssignPFPropertiesToPathType(
	"AIPATH_TANK",
	NAVMASK_SURFACE, 
	18.0, 18.0, 0.0, 0.0, 0.0, 
	0.0, 1.5, -10000.0, 0.0, 0.0, 7.0,
	0, 0.3, 2.0, 0.0, 5, true);
	
--- character that travels on the surface but has no preferences - except it prefers to walk around
--- hills rather than over them
AssignPFPropertiesToPathType(
	"AIPATH_DEFAULT",
	NAV_TRIANGULAR + NAV_WAYPOINT_HUMAN + NAV_SMARTOBJECT,
	0.0, 0.0, 0.0, 0.0, 0.0, 
	5.0, 0.5, -10000.0, 0.0, 20.0, 3.5,
	0, 0.4, 2, 45, 7, true);

-- Default properties for boat agents
AssignPFPropertiesToPathType(
	"AIPATH_BOAT",
	NAV_TRIANGULAR + NAV_ROAD, 
	0.0, 0.0, 0.0, 0.0, 0.0,
	0.0, 10000.0, 1.5, 0.0, 0.0, 0.0,
	0, 0.3, 2.0, 0.0, 6, true);

-- Default properties for flight (heli, scout etc) agents
AssignPFPropertiesToPathType(
	"AIPATH_HELI",
	NAV_FLIGHT + NAV_SMARTOBJECT, 
	0.0, 0.0, 0.0, 0.0, 0.0,
	0.0, 0.0, 0.0, 0.0, 0.0, 1.0,
	0, 0.3, 2.0, 0.0, 7, true);

-- Default properties for 3D agents
AssignPFPropertiesToPathType(
	"AIPATH_3D",
	NAV_VOLUME + NAV_SMARTOBJECT + NAV_ROAD, 
	0.0, 0.0, 0.0, 0.0, 0.0,
	0.0, 0.0, 0.0, 0.0, 0.0, 1.0,
	0, 0.3, 2.0, 0.0, 10, true);

-- Default properties for hunter agents
AssignPFPropertiesToPathType(
	"AIPATH_HUNTER",
	NAV_FREE_2D,
	0.0, 0.0, 0.0, 0.0, 0.0,
	0.0, 0.0, 0.0, 0.0, 0.0, 1.0,
	0, 0.3, 2.0, 0.0, 11, true);
]]