----------------------------------------------------------------------------------------------------
--  Crytek Source File.
--  Copyright (C), Crytek Studios, 2001-2006.
----------------------------------------------------------------------------------------------------
--  $Id$
--  $DateTime$
--  Description: Buy Zone Entity for Power Struggle
--
----------------------------------------------------------------------------------------------------
--  History:
--  - 13:6:2006   12:12 : Created by Márcio Martins
--
----------------------------------------------------------------------------------------------------
Perimeter=
{
	Server={},
	Client={},

	Editor={
		Model="Editor/Objects/ForbiddenArea.cgf",
	},
	
	type = "Perimeter",

	Properties=
	{
		teamName="",
	},
}


----------------------------------------------------------------------------------------------------
function Perimeter:OnPropertyChange()
	self:OnReset();
end


----------------------------------------------------------------------------------------------------
function Perimeter.Server:OnInit()
	self:OnReset();
end


----------------------------------------------------------------------------------------------------
function Perimeter:OnReset()
	self.isServer = CryAction.IsServer();

	if (self.isServer) then
		local teamId=g_gameRules.game:GetTeamId(self.Properties.teamName);
		if (teamId and teamId~=0) then
			self:SetTeamId(teamId);
		else
			self:SetTeamId(0);
		end
	end
	
	self:Activate(0);
end


----------------------------------------------------------------------------------------------------
function Perimeter:GetTeamId()
	return g_gameRules.game:GetTeam(self.id) or 0;
end


----------------------------------------------------------------------------------------------------
function Perimeter:SetTeamId(teamId)
	g_gameRules.game:SetTeam(teamId, self.id);
end


----------------------------------------------------------------------------------------------------
function Perimeter.Server:OnEnterArea(entity, areaId)
	if (entity.actor) then
		if (g_gameRules.Server.OnPerimeterBreached) then
			local teamId=self:GetTeamId();
			local playerTeamId=g_gameRules.game:GetTeam(entity.id);
			
			if (teamId==0 or teamId~=playerTeamId) then
				g_gameRules.Server.OnPerimeterBreached(g_gameRules, self, entity);
			end
		end
	end
end