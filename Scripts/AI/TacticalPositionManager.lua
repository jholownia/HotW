----------------------------------------------------------------------------------------
--  Description: Loads and initialises Tactical Position specifications
--  Created by: Matthew Jack
----------------------------------------------------------------------------------------

AI.TacticalPositionManager = AI.TacticalPositionManager or {};

Script.ReloadScript("Scripts/AI/TPS/FogOfWarQueries.lua");
Script.ReloadScript("Scripts/AI/TPS/QueriesTest.lua");
Script.ReloadScript("Scripts/AI/TPS/CivilianQueries.lua");

function AI.TacticalPositionManager:OnInit() 
	
	-- Initialise all tables that have been loaded
	for i,v in pairs(self) do
		if (type(v) == "table" and v.OnInit) then
			v:OnInit();
			System.Log("[AI] Initialising TPS queries for "..i);
		end
	end
end
