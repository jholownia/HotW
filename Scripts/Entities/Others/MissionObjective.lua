--------------------------------------------------------------------------
--	Crytek Source File.
-- 	Copyright (C), Crytek Studios, 2001-2005.
--------------------------------------------------------------------------
--	$Id$
--	$DateTime$
--	Description: Mission Objective
--  
--------------------------------------------------------------------------
--  History:
--  - 19:4:2005   12:00 : Created by Filippo De Luca
--  - 13:2:2006   12:00 : Refactoring by AlexL
--  - 19:1:2011   12:00 : Refactoring by PaulR
--------------------------------------------------------------------------

MissionObjective =
{
	Properties =
	{
		mission_MissionID	 = "",    -- Mission objective ID
		sTrackedEntityName =  "",    -- Track this entity instead of the MissionObjective entity itself
	},
	
	Editor =
	{
		Model="Editor/Objects/T.cgf",
		Icon="Target.bmp",
	},	
	
	States = { "Deactivated", "Activated", "Failed", "Completed" },
}

-------------------------------------------------------
function MissionObjective:OnLoad(table)
end

-------------------------------------------------------
function MissionObjective:OnSave(table)
end

----------------------------------------------------------------------------------------------------
function MissionObjective:OnPropertyChange()
	self:Reset();
end

----------------------------------------------------------------------------------------------------
function MissionObjective:OnReset()
	self:Reset();
end


----------------------------------------------------------------------------------------------------
function MissionObjective:OnSpawn()
	self:Reset();
end


----------------------------------------------------------------------------------------------------
function MissionObjective:OnDestroy()
end


----------------------------------------------------------------------------------------------------
function MissionObjective:Reset()
	if (self.Properties.mission_MissionID ~= "") then
		self.missionID = self.Properties.mission_MissionID;
	else
		self.missionID = self:GetName();
	end
	self.noFG = true; -- prevent output on Deactivate
	self:GotoState("Deactivated");
	self.noFG = false;
	self.trackId = self.id;
  -- self:ActivateOutput( "Deactivated", true );

	if (g_gameRules) then
		Log( "Add %s", self.missionID);
		g_gameRules.game:AddObjective(0, self.missionID, MO_DEACTIVATED, self.trackId);
	end
  
end

-------------------------------------------------------------------------------
-- Deactivated State
-------------------------------------------------------------------------------
MissionObjective.Deactivated = 
{
	OnBeginState = function( self )
		System.Log("MissionObjective "..self.missionID.." Deactivated");
		if (g_gameRules) then
			g_gameRules.game:SetObjectiveStatus(0, self.missionID, MO_DEACTIVATED);
		end
		if (self.noFG == false) then
			self:ActivateOutput( "Deactivated", true );
		end
	end
}

-------------------------------------------------------------------------------
-- Activated State
-------------------------------------------------------------------------------
MissionObjective.Activated = 
{
	OnBeginState = function( self ) 
		System.Log("MissionObjective "..self.missionID.." Activated");
		if (g_gameRules) then
			g_gameRules.game:SetObjectiveStatus(0, self.missionID, MO_ACTIVATED);
			
			local target = self;
			if (self.Properties.sTrackedEntityName ~= "") then
				target = System.GetEntityByName(self.Properties.sTrackedEntityName);
			end
			if (target) then
				g_gameRules.game:SetObjectiveEntity(0, self.missionID, target.id);
			end
		end

		if (self.noFG == false) then
			self:ActivateOutput( "Activated", true );
		end
	end,
	
	OnEndState = function ( self )
	end
}

-------------------------------------------------------------------------------
-- Failed State
-------------------------------------------------------------------------------
MissionObjective.Failed = 
{
	OnBeginState = function( self )
		System.Log("MissionObjective "..self.missionID.." Failed");
		if (g_gameRules) then
			g_gameRules.game:SetObjectiveStatus(0, self.missionID, MO_FAILED);
		end
		if (self.noFG == false) then
			self:ActivateOutput( "Failed", true );
		end
	end
}

-------------------------------------------------------------------------------
-- Completed State
-------------------------------------------------------------------------------
MissionObjective.Completed = 
{
	OnBeginState = function( self )
		System.Log("MissionObjective "..self.missionID.." Completed");
		if (g_gameRules) then
			g_gameRules.game:SetObjectiveStatus(0, self.missionID, MO_COMPLETED);
		end
		if (self.noFG == false) then
			self:ActivateOutput( "Completed", true );
		end
	end
}

----------------------------------------------------------------------------------------------------
function MissionObjective:Event_Deactivate(sender)
	self:GotoState( "Deactivated" );
end

----------------------------------------------------------------------------------------------------
function MissionObjective:Event_Activate(sender)
	self:GotoState( "Activated" );
end

----------------------------------------------------------------------------------------------------
function MissionObjective:Event_Failed(sender)
	self:GotoState( "Failed" );
end

----------------------------------------------------------------------------------------------------
function MissionObjective:Event_Completed(sender)
	if (self:IsInState( "Activated" ) ~= 0)  then
		self:GotoState( "Completed" );
	end
end

----------------------------------------------------------------------------------------------------

MissionObjective.FlowEvents =
{
	Inputs =
	{
		Deactivate = { MissionObjective.Event_Deactivate, "bool" },
		Activate   = { MissionObjective.Event_Activate, "bool" },
		Failed     = { MissionObjective.Event_Failed, "bool" },
		Completed  = { MissionObjective.Event_Completed, "bool" },
	},

	Outputs =
	{
	  Deactivated = "bool",
	  Activated   = "bool",
	  Failed      = "bool",
	  Completed   = "bool",
	},
}
