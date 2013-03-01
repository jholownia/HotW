--------------------------------------------------------------------------
--	Crytek Source File.
-- 	Copyright (C), Crytek Studios, 2001-2006.
--------------------------------------------------------------------------
--	$Id$
--	$DateTime$
--	Description: To be used for kill events
--  
--------------------------------------------------------------------------
--  History:
--  - 6/2006     : Created by Sascha Gundlach
--
--------------------------------------------------------------------------

WaterKillEvent = {
	Client = {},
	Server = {},
	Properties = {
	},
	Editor={
		Model="Editor/Objects/T.cgf",
		Icon="Trigger.bmp",
	},
	CheckShark = function(self)
		if(self.Shark and self.Shark.dead==false)then
			Script.SetTimerForFunction(5000,"WaterKillEvent.CheckShark",self);
		elseif(self.Shark)then
			Script.SetTimerForFunction(10000,"WaterKillEvent.SpawnNextShark",self);
		end;
	end,
	SpawnNextShark=function(self)
		self:Event_SpawnShark();	
	end,
	Shark = nil,
}

WKE_SPAWN_SHARK_TIMER = 1;
	
function WaterKillEvent:OnPropertyChange()
	self:OnReset();
end;

function WaterKillEvent:OnSave(tbl)
	tbl.Shark = self.Shark;
	tbl.bInitialized = self.bInitialized
end

function WaterKillEvent:OnLoad(tbl)
	self.Shark = tbl.Shark;
	self.bInitialized = tbl.bInitialized;
end

function WaterKillEvent:OnReset()
	if(self.Shark) then 
		self.Shark:Event_Disable();
		self.Shark:OnReset();
		--self.Shark.AI.spawned = false;
	end
end;

----------------------------------------------------------------------------------------------------
function WaterKillEvent.Server:OnInit()
	if(not self.bInitialized)then
		self:OnReset();
		self.bInitialized=1;
	end;
end;

----------------------------------------------------------------------------------------------------
function WaterKillEvent.Client:OnInit()
	if(not self.bInitialized)then
		self:OnReset();
		self.bInitialized=1;
	end;
	self:LoadShark();
	if(self.Shark) then
		self.Shark:Event_Disable();
	end
end;
----------------------------------------------------------------------------------------------------
function WaterKillEvent:LoadShark()
	--local shark = self.Shark;
	local target;

	local spawnParams = {};
	spawnParams.class = "Shark";
	spawnParams.position = self:GetPos();
	spawnParams.name = "Shark";
	spawnParams.flags = 0;
	spawnParams.scale = nil;
	
	self.Shark=System.SpawnEntity(spawnParams)
	

end;

----------------------------------------------------------------------------------------------------
function WaterKillEvent:Event_SpawnShark()
	local shark = self.Shark;
	if(not shark) then
		return;
	end
	
	local target = g_localActor;
	if(not target) then
		System.Warning("WaterKillEvent: Cannot find local actor");
		return;
	end
--	if(not shark.dead and shark:GetDistance(target.id)<50)then
--		AI.ModifySmartObjectStates(shark.id,"-StickToPlayer");	
--	end;
	
	self.Shark:Event_Spawn();
	
	self.Shark.WaterKillEvent = self;
	
	Script.SetTimerForFunction(5000,"WaterKillEvent.CheckShark",self);
	BroadcastEvent(self, "SpawnShark");
end;

function WaterKillEvent:Event_RemoveShark()
	if(self.Shark)then
		self.Shark:Event_Remove();
		BroadcastEvent(self, "RemoveShark");
	end;
	
end;

function WaterKillEvent.Client:OnTimer(timerId)
	if(timerId == WKE_SPAWN_SHARK_TIMER) then
		self:LoadShark();
		self:Event_SpawnShark();
	end
end


WaterKillEvent.FlowEvents =
{
	Inputs =
	{
		SpawnShark = { WaterKillEvent.Event_SpawnShark, "bool" },
		RemoveShark = { WaterKillEvent.Event_RemoveShark, "bool" },
	},
	Outputs =
	{
		SpawnShark = "bool",
		RemoveShark = "bool",
	},
}