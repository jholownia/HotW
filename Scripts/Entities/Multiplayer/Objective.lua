--------------------------------------------------------------------------
--	Crytek Source File.
-- 	Copyright (C), Crytek Studios, 2001-2006.
--------------------------------------------------------------------------
--	$Id$
--	$DateTime$
--	Description: Objective
--  
--------------------------------------------------------------------------
--  History:
--  - 23:11:2006   14:05 : Created by Márcio Martins
--
--------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
Objective = {
	Client = {},
	Server = {},

	Editor={
		Model="Editor/Objects/Objective.cgf",
	},
	
	Properties=
	{
		teamName								= "",
		bActive									= 0,
		bSecondary							= 0,
		objectiveName						= "",

		Condition={
			szCaptureBuilding			= "",
			szDestroyBuilding			= "",
			bProduceTAC						= 0,
		},
	},
}


----------------------------------------------------------------------------------------------------
function Objective:OnSpawn()
	CryAction.CreateGameObjectForEntity(self.id);
	CryAction.BindGameObjectToNetwork(self.id);
end


----------------------------------------------------------------------------------------------------
function Objective.Server:OnInit()	
	self:OnReset();
end


----------------------------------------------------------------------------------------------------
function Objective:OnCapture(building, teamId)
	self:CheckCondition();
end


----------------------------------------------------------------------------------------------------
function Objective:OnUncapture(building, teamId)
	self:CheckCondition();
end


----------------------------------------------------------------------------------------------------
function Objective:OnHQDestroyed(hq, shooterId, teamId)
	self:CheckCondition();
end


----------------------------------------------------------------------------------------------------
function Objective:OnItemBought(itemId, itemName, playerId)
	if (itemName=="tacgun") then
		if (g_gameRules.game:GetTeam(playerId)==self.teamId) then
			self.tacproduced=true;
			
			self:CheckCondition();
		end
	end
end


----------------------------------------------------------------------------------------------------
function Objective:OnVehicleBuilt(vehicleId, vehicleName, teamId)
	if (vehicleName=="ustactank" or vehicleName=="nktactank") then
		if (teamId==self.teamId) then
			self.tacproduced=true;
			
			self:CheckCondition();
		end
	end
end


----------------------------------------------------------------------------------------------------
function Objective:OnReset()
	self.isServer = CryAction.IsServer();
	self.isClient = CryAction.IsClient();

	self.deps={};
	self.links={};
	
	self.active = tonumber(self.Properties.bActive)~=0;
	self.completed = false;
	self.dependent = false;

	self:Activate(0);
	
	if (self.Properties.objectiveName ~= "") then
		self.missionId=self.Properties.objectiveName;
	else
		self.missionId=self:GetName();
	end

	self.trackId = self.id;

	if (self.isServer) then
		self.teamId=g_gameRules.game:GetTeamId(self.Properties.teamName) or 0;
		g_gameRules.game:SetTeam(self.teamId, self.id);

		if (g_gameRules) then
			g_gameRules.game:AddObjective(self.teamId, self.missionId, self:GetStatus(), self.trackId);
		end

		self:UpdateLinks();
		self:InitCondition();
		self:UpdateStatus();
	else
		CryAction.ForceGameObjectUpdate(self.id, false);
	end
end


----------------------------------------------------------------------------------------------------
function Objective.Server:OnStartGame()
	self.active = tonumber(self.Properties.bActive)~=0;
	self.completed = false;
	self.dependent = false;

	self:UpdateLinks();
	self:InitCondition();
	self:CheckCondition();
	
	self:UpdateStatus();
end


----------------------------------------------------------------------------------------------------
function Objective:UpdateStatus()
	g_gameRules.game:SetObjectiveStatus(self.teamId, self.missionId, self:GetStatus());
end


----------------------------------------------------------------------------------------------------
function Objective:GetStatus()
	if (self.completed) then
		return MO_COMPLETED;
	elseif (self.active) then
		return MO_ACTIVATED;
	elseif (self.failed) then
		return MO_FAILED;
	else
		return MO_DEACTIVATED;
	end
end


----------------------------------------------------------------------------------------------------
function Objective:UpdateLinks()
	local linkName="next";
	local i=0;
	local link=self:GetLinkTarget(linkName, i);
	while (link) do
		if (link) then
			link:AddDep(self.id);
			self:AddLink(link.id);
		end
		i=i+1;
		link=self:GetLinkTarget(linkName, i);
	end
	
	linkName="next_notdep";
	i=0;
	local link=self:GetLinkTarget(linkName, i);
	while (link) do
		if (link) then
			self:AddLink(link.id);
		end
		i=i+1;
		link=self:GetLinkTarget(linkName, i);
	end
end


----------------------------------------------------------------------------------------------------
function Objective:AddLink(linkId)
	for i,id in ipairs(self.links) do
		if (id==linkId) then
			return;
		end
	end
	
	table.insert(self.links, linkId);
end


----------------------------------------------------------------------------------------------------
function Objective:AddDep(depId)
	for i,id in ipairs(self.deps) do
		if (id==depId) then
			return;
		end
	end
	
	table.insert(self.deps, depId);	
end


----------------------------------------------------------------------------------------------------
function Objective:AddCondition(cond)
	table.insert(self.conditions, cond);
end


----------------------------------------------------------------------------------------------------
function Objective:InitCondition()
	self.conditions={};
	
	self.tacproduced=false;

	local condition=self.Properties.Condition;
	if (condition.szCaptureBuilding and condition.szCaptureBuilding~="") then
		local buildingClass=condition.szCaptureBuilding;
		local building=System.GetNearestEntityByClass(self:GetWorldPos(), 50, buildingClass, self.id);
		if (building) then
			local buildingId=building.id;
			self:AddCondition(function(self)
				if (self.teamId == g_gameRules.game:GetTeam(buildingId)) then
					return true;
				end
				return false;
			end);
		end
	end
	
	if (condition.szDestroyBuilding and condition.szDestroyBuilding~="") then
		local buildingClass=condition.szDestroyBuilding;
		local building=System.GetNearestEntityByClass(self:GetWorldPos(), 100, buildingClass, self.id);
		if (building) then
			local buildingId=building.id;	
			self:AddCondition(function(self)
				local building=System.GetEntity(buildingId);
				local destroyed=building.IsDestroyed and building:IsDestroyed();
				destroyed=destroyed or (building.GetHealth and ((building:GetHealth() or 100)<=0));
				return destroyed;
			end);
		end
	end

	if (condition.bProduceTAC and condition.bProduceTAC~=0) then
		local vehicleClass=condition.szProduceVehicle;
		self:AddCondition(function(self)
			return self.tacproduced;
		end);
	end
end


----------------------------------------------------------------------------------------------------
function Objective:CheckCondition()
	local complete=true;
	for i,b in ipairs(self.conditions) do
		complete=complete and b(self);
	end
	
	if (complete ~= self.completed) then
		self:SetComplete(complete);
	end
end


----------------------------------------------------------------------------------------------------
function Objective:SetTrackId(trackId)
	self.trackId=trackId;
	g_gameRules.game:SetObjectiveEntity(self.teamId, self.missionId, trackId);
end


----------------------------------------------------------------------------------------------------
function Objective:SetComplete(complete)
	if(self.completed~=complete) then
		self.completed=complete;
		self:UpdateStatus();
	end

	for i,id in ipairs(self.links) do
		local obj=System.GetEntity(id);
		if (obj) then
			obj:DepCompleted(complete, self.id);
		end
	end
end


----------------------------------------------------------------------------------------------------
function Objective:Completed()
	return self.completed;
end


----------------------------------------------------------------------------------------------------
function Objective:Dependent()
	return self.dependent;
end


----------------------------------------------------------------------------------------------------
-- FIXME: it's considering every call to this as beeing from a dependency
function Objective:DepCompleted(complete, depId)
	if (not complete) then
		self.dependent=true;
	else
		self.dependent=false;
		if (table.getn(self.deps)>0) then
			for i,id in ipairs(self.deps) do
				local obj=System.GetEntity(id);
				if (obj) then
					if (not obj:Completed()) then
						self.dependent=true;
						break;
					end
				end
			end
		end
	end
	
	if (self.dependent~=(not self.active)) then
		self.active=not self.dependent;
		self:UpdateStatus();
	end	
end