----------------------------------------------------------------------------------------------------
--  Crytek Source File.
--  Copyright (C), Crytek Studios, 2001-2006.
----------------------------------------------------------------------------------------------------
--  $Id$
--  $DateTime$
--  Description: Flag for Power Struggle
--
----------------------------------------------------------------------------------------------------
--  History:
--  - 18:1:2007   18:49 : Created by Márcio Martins
--
----------------------------------------------------------------------------------------------------
Flag =
{	
	Properties =
	{
		objModel = "objects/props/maritime/windsock/windsock.cga",
		teamName = "";
		animationTemplate = "flags_%s_%s";
	},

	Editor=
	{
		Icon = "Checkpoint.bmp",
		IconOnTop=1,
	},
};



----------------------------------------------------------------------------------------------------
function Flag:OnPreFreeze(freeze, vapor)
	if (freeze) then
		return false; -- don't allow freezing
	end
end


----------------------------------------------------------------------------------------------------
function Flag:CanShatter()
	return 0;
end



----------------------------------------------------------------------------------------------------
function Flag:LoadGeometry(slot, model)
	if (string.len(model) > 0) then
		local ext = string.lower(string.sub(model, -4));

		if ((ext == ".chr") or (ext == ".cdf") or (ext == ".cga")) then
			self:LoadCharacter(slot, model);
		else
			self:LoadObject(slot, model);
		end
	end
end


-------------------------------------------------------------------------
function Flag:OnSpawn()
	CryAction.CreateGameObjectForEntity(self.id);
	CryAction.BindGameObjectToNetwork(self.id);
	CryAction.ForceGameObjectUpdate(self.id, true);

	self:LoadGeometry(0, self.Properties.objModel);
	self:Physicalize(0, PE_RIGID, { mass=0 });
	self:RedirectAnimationToLayer0(0, true);
	self:Activate(1);
end


----------------------------------------------------------------------------------------------------
function Flag:SetTeam(teamName)
	if (self.teamName~=teamName) then
		local action= "";
		local team = "";
		local speed = 1;

		if (self.teamName and self.teamName~="") then
			if (teamName~="") then
				action="up";
				team=teamName;
				speed=500;
			else
				action="down";
				team=self.teamName;
			end
		else
			if (teamName~="") then
				action="up";
				team=teamName;
			end
		end

		if (action~="") then
			local animation=string.format(self.Properties.animationTemplate, team, action);
			self:StartAnimation(0, animation, 0, 0.250, speed, false, false, true);
			self:ForceCharacterUpdate(0, true);
			local time=self:GetAnimationLength(0, animation)*1000/speed;
			time=math.max(0, time-125);
			self:SetTimer(0, time);
		end
		self.teamName=teamName;
	end
end


----------------------------------------------------------------------------------------------------
function Flag:OnTimer(timerId, msec)
	local animation=string.format(self.Properties.animationTemplate, self.teamName, "loop");
	self:StartAnimation(0, animation, 0, 0.250, 1, true, false, true);
end


----------------------------------------------------------------------------------------------------
function Flag:OnReset()
	CryAction.DontSyncPhysics(self.id);
	self.teamName="";
	self:SetTeam(self.Properties.teamName);
end

function Flag:OnInit() self:OnReset() end

----------------------------------------------------------------------------------------------------
function Flag:OnPropertyChange()
	self:OnReset();
end
