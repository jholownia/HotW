--------------------------------------------------------------------------
--	Crytek Source File.
-- 	Copyright (C), Crytek Studios, 2001-2007.
--------------------------------------------------------------------------
--	$Id$
--	$DateTime$
--	Description: Elevator Switch Button
--  
--------------------------------------------------------------------------
--  History:
--  - 28:1:2007 : Created by Marcio Martins
--
--------------------------------------------------------------------------

ElevatorSwitch = 
{
	Properties = 
	{
		soclasses_SmartObjectClass = "ElevatorSwitch",

		objModel 			= "objects/default.cgf",
		nFloor	 			= 0,
		fDelay	 			= 3,

		Sounds = 
		{
			soundSoundOnPress = "",
		},
	},
		
	Server = {},
	Client = {},
	
		Editor={
		Icon = "elevator.bmp",
		IconOnTop=1,
	},
	
}


Net.Expose {
	Class = ElevatorSwitch,
	ClientMethods = {
		ClUsed = { RELIABLE_UNORDERED, POST_ATTACH, },
	},
	ServerMethods = {
		SvRequestUse = { RELIABLE_UNORDERED, POST_ATTACH, ENTITYID, },
	},
	ServerProperties = {
	},
};


----------------------------------------------------------------------------------------------------
function ElevatorSwitch:OnPreFreeze(freeze, vapor)
	if (freeze) then
		return false; -- don't allow freezing
	end
end


function ElevatorSwitch:OnPropertyChange()
	self:Reset();
end


function ElevatorSwitch:OnReset()
	self:Reset();
end


function ElevatorSwitch:OnSpawn()	
	CryAction.CreateGameObjectForEntity(self.id);
	CryAction.BindGameObjectToNetwork(self.id);
	CryAction.ForceGameObjectUpdate(self.id, true);	
	
	self.isServer=CryAction.IsServer();
	self.isClient=CryAction.IsClient();

	self:Reset(1);
end


function ElevatorSwitch:OnDestroy()
end


function ElevatorSwitch:DoPhysicalize()
	if (self.currModel ~= self.Properties.objModel) then
		self:LoadObject( 0,self.Properties.objModel );
		self:Physicalize(0,PE_RIGID, {mass=0});
	end
	
	self.currModel = self.Properties.objModel;
	
	-- Safety setting to prevent any entities with hidden object properities being pickable as this conflicts with the useable flag and as such breaks the elevator switch entity 
	self.Properties.bPickable = 0;
end


function ElevatorSwitch:Reset(onSpawn)
	self:Activate(0);
	self:DoPhysicalize();
end


function ElevatorSwitch:IsUsable(user)
	if (not user) then
		return 0;
	end
	
	return 1;
end


function ElevatorSwitch:OnUsed(user)	
	self.server:SvRequestUse(user.id);
end


function ElevatorSwitch:GetUsableMessage()
	return self.Properties.szUseMessage;
end



function ElevatorSwitch.Server:SvRequestUse(userId)
	if (self.Properties.fDelay>0) then
		self:SetTimer(0, 1000*self.Properties.fDelay);
	else
		self:Used();
	end
end


function ElevatorSwitch.Server:OnTimer(timerId, msec)
	self:Used();
end


function ElevatorSwitch:Used()
	local i=0;
	local link=self:GetLinkTarget("up", i);
	while (link) do
		link:Up(self.Properties.nFloor);
		i=i+1;
		link=self:GetLinkTarget("up", i);
	end
	
	i=0;
	link=self:GetLinkTarget("down", i);
	while (link) do
		link:Down(self.Properties.nFloor);
		i=i+1;
		link=self:GetLinkTarget("down", i);
	end
	
	self.allClients:ClUsed();
end


function ElevatorSwitch.Client:ClUsed()
	local sound=self.Properties.Sounds.soundSoundOnPress;
	if (sound and sound~="") then
		self:PlaySoundEvent(self.Properties.Sounds.soundSoundOnPress, g_Vectors.v000, g_Vectors.v010, SOUND_DEFAULT_3D, 0, SOUND_SEMANTIC_MECHANIC_ENTITY);
	end
end