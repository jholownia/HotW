ForbiddenArea=
{
	Server={},
	Client={},
	
	Editor={
		--Model="Editor/Objects/ForbiddenArea.cgf",
		Icon="forbiddenarea.bmp",
	},
		
	type = "ForbiddenArea",

	Properties=
	{
		bEnabled=1,
		bReversed=1,
		DamagePerSecond=35,
		Delay=5,
		bShowWarning=1,
		teamName="",
	},
}


----------------------------------------------------------------------------------------------------
function ForbiddenArea:OnPropertyChange()
	self:OnReset();
end


----------------------------------------------------------------------------------------------------
function ForbiddenArea.Server:OnInit()
	self.inside={};
	self.warning={};

	self:OnReset();
end


----------------------------------------------------------------------------------------------------
function ForbiddenArea.Server:OnTimer(timerId, msec)
	self:SetTimer(timerId, msec);

	if (not self.reverse) then
		for i,id in pairs(self.inside) do
			local player=System.GetEntity(id);
			if (player and player.actor and (not player:IsDead()) and g_gameRules.game:IsPlayerInGame(id)) then
				if ((not self.teamId) or (self.teamId~=g_gameRules.game:GetTeam(id))) then
					self:PunishPlayer(player, msec);
				end
			end
		end
	else
		local players=g_gameRules.game:GetPlayers();
		if (players) then
			for i,player in pairs(players) do
				if ((not self:IsPlayerInside(player.id)) and g_gameRules.game:IsPlayerInGame(player.id)) then
					if ((not self.teamId) or (self.teamId~=g_gameRules.game:GetTeam(player.id))) then
						self:PunishPlayer(player, msec);
					end
				end
			end
		end
	end
end


----------------------------------------------------------------------------------------------------
function ForbiddenArea:PunishPlayer(player, time)
	if ((player.actor:GetSpectatorMode()~=0) or player:IsDead()) then
		return;
	end

	local warning=self.warning[player.id];
	if (warning and warning>0) then
		warning=warning-(time/1000);
		self.warning[player.id]=warning;
	elseif (not warning) then
		warning=self.delay;
		self.warning[player.id]=warning;
	end
	
	if (self.showWarning) then	
		g_gameRules.game:ForbiddenAreaWarning(true, warning, player.id);
	end
	
	if (warning<=0) then
		g_gameRules:CreateHit(player.id,player.id,player.id,self.dps*(time/1000),nil,nil,nil,"punish");
	end
end


----------------------------------------------------------------------------------------------------
function ForbiddenArea.Server:OnEnterArea(entity, areaId)
	if (entity.actor) then
		local inside=false;
		for i,v in ipairs(self.inside) do
			if (v==entity.id) then
				inside=true;
				break;
			end
		end	
		
		if (inside) then
			return;
		end
		
		table.insert(self.inside, entity.id);
		
		if ((not self.teamId) or (self.teamId~=g_gameRules.game:GetTeam(entity.id))) then
			if (not self.reverse) then
				self.warning[entity.id]=self.delay;
				
				if (self.showWarning) then
					if ((entity.actor:GetSpectatorMode()==0) and (not entity:IsDead())) then
						g_gameRules.game:ForbiddenAreaWarning(true, self.delay, entity.id);
					end
				end
			else
				self.warning[entity.id]=nil;
				
				if (self.showWarning) then
					g_gameRules.game:ForbiddenAreaWarning(false, 0, entity.id);
				end
			end
		end
	end
end


----------------------------------------------------------------------------------------------------
function ForbiddenArea.Server:OnLeaveArea(entity, areaId)
	if (entity.actor) then
		local inside=false;
		for i,v in ipairs(self.inside) do
			if (v==entity.id) then
				inside=true;
				table.remove(self.inside, i);
				break;
			end
		end	
		
		if ((not self.teamId) or (self.teamId~=g_gameRules.game:GetTeam(entity.id))) then
			if (self.reverse) then
				if (inside) then
					self.warning[entity.id]=self.delay;
				
					if (self.showWarning) then
						if ((entity.actor:GetSpectatorMode()==0) and (not entity:IsDead())) then
							g_gameRules.game:ForbiddenAreaWarning(true, self.delay, entity.id);
						end
					end
				end
			else
				self.warning[entity.id]=nil;
				
				if (self.showWarning) then
					g_gameRules.game:ForbiddenAreaWarning(false, 0, entity.id);
				end
			end
		end
	end
end

----------------------------------------------------------------------------------------------------
function ForbiddenArea:OnSave(svTbl)
	svTbl.inside = self.inside;
end

----------------------------------------------------------------------------------------------------
function ForbiddenArea:OnLoad(svTbl)
	self:OnReset();
	self.inside = svTbl.inside;
end

----------------------------------------------------------------------------------------------------
function ForbiddenArea:OnReset()
	self:Enable(tonumber(self.Properties.bEnabled)~=0);
	self.reverse=tonumber(self.Properties.bReversed)~=0;
	self.delay=tonumber(self.Properties.Delay);
	self.dps=tonumber(self.Properties.DamagePerSecond);
	self.showWarning=tonumber(self.Properties.bShowWarning)~=0;
	self.warning={};
	
	if (CryAction.IsServer()) then
		if (self.Properties.teamName ~= "") then
			self.teamId=g_gameRules.game:GetTeamId(self.Properties.teamName);
			if (self.teamId==0) then
				self.teamId=nil;
			end
		end
	end	
end


----------------------------------------------------------------------------------------------------
function ForbiddenArea:Enable(enable)
	if (enable) then
		self:SetTimer(0, 1000);
	else
		self:KillTimer(0);
	end
end


----------------------------------------------------------------------------------------------------
function ForbiddenArea:IsPlayerInside(playerId)
	for i,id in pairs(self.inside) do
		if (id==playerId) then
			return true;
		end
	end
	
	return false;
end

-----------------------------------------------------------------------------------------------------

function ForbiddenArea:Event_Enable( sender )
	self.Properties.bEnabled = 1;
	self:Enable(true);
	BroadcastEvent( self,"Enable" );
end

function ForbiddenArea:Event_Disable( sender )
	self.Properties.bEnabled = 0;
	self:Enable(false);
	BroadcastEvent( self,"Disable" );
end

ForbiddenArea.FlowEvents =
{
	Inputs =
	{
		Disable = { ForbiddenArea.Event_Disable, "bool" },
		Enable = { ForbiddenArea.Event_Enable, "bool" },
	},
	Outputs =
	{
		Disable = "bool",
		Enable = "bool",
	},
}