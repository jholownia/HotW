
Script.ReloadScript("Scripts/Entities/Vehicles/VehicleBase.lua");
Script.ReloadScript("Scripts/Entities/Vehicles/VehicleBaseAI.lua");

Log("Executing Vehiclepool..");

VEHICLE_SCRIPT_TIMER = 100;

--define constant timer id
AISOUND_TIMER = VEHICLE_SCRIPT_TIMER + 2
--define timeout for ai sound
AISOUND_TIMEOUT = 250

-- create table for each vehicle impl
for i,vehicle in pairs(VehicleSystem.VehicleImpls) do
  
  local gVehicle =     
  {      	
  	Properties = 
  	{		
  		bDisableEngine = 0,
  		Paint = "",
  		bDamageOnFlipped = 1,
  		bFrozen = 0,    	
  		FrozenModel = "",
  		Modification = "",
  		soclasses_SmartObjectClass = "",
  		bAutoGenAIHidePts = 0,
  		teamName = "",
  	},

 	PropertiesInstance =
 	{
 		AITerritoryAndWave =
 		{
			aiterritory_Territory = "<None>",
			aiwave_Wave           = "<None>",
		},
	}, 

  	Editor = 
		{
			Icon="Vehicle.bmp",
			IconOnTop=1,
		},
  		
  	Client = {},
  	
  	Server =
  	{
		OnStartGame = function(self)
		  self:SetupTerritoryAndWave();
		end,
  	},
  };
  
    AddHeavyObjectProperty(gVehicle);
  MakeInterestingToAI(gVehicle, 1);
	MakeAICoverEntity(gVehicle);
	MakeSpawnable(gVehicle)
--------------------------------------------------------------------------		

  -- execute optional lua script 
  local scriptName = Vehicle.GetOptionalScript(vehicle);
  
  if (scriptName) then    
    Script.ReloadScript(scriptName);
    
    if (_G[vehicle]) then
    	mergef(gVehicle, _G[vehicle], 1);
    end        
  end
  
  gVehicle.OnSpawn = function(self)    
	  mergef(self, VehicleBase, 1);	  
	  self:SpawnVehicleBase();
	end;
	
	gVehicle.Server.OnShutDown = function(self)
		if (g_gameRules) then
			g_gameRules.game:RemoveSpawnGroup(self.id);
		end
	end;
 	
	gVehicle.OnReset = function(self)	  
	  self:ResetVehicleBase();
	  
		if (CryAction.IsServer() and g_gameRules) then
			local teamId=g_gameRules.game:GetTeamId(self.Properties.teamName);
			if (teamId and teamId~=0) then
				g_gameRules.game:SetTeam(teamId, self.id);
			else
				g_gameRules.game:SetTeam(0, self.id);
			end
		end
	end;
	
	gVehicle.OnFrost = function(self, shooterId, weaponId, frost)
		local f=self.vehicle:GetFrozenAmount() + frost;
		self.vehicle:SetFrozenAmount(f);
	end;
	
	gVehicle.OnUnlocked = function(self, playerId)
		if (g_gameRules and g_gameRules.OnVehicleUnlocked) then
			g_gameRules.OnVehicleUnlocked(g_gameRules, self.id, playerId);
		end
	end;
	
--------------------------------------------------------------------------
	gVehicle.Client.OnTimer = function(self, timerId, mSec)
		if (timerId == AISOUND_TIMER) then
			if(self.AISoundRadius and self:HasDriver()) then
				self:SetTimer(AISOUND_TIMER, mSec);
				AI.SoundEvent(self:GetWorldPos(self.State.pos), self.AISoundRadius, AISOUND_MOVEMENT_LOUD, self.id);
--				--System.Log(">>> gVehicle.Client.OnTimer sound "..mSec);
			end
		end		
	end	
	
	gVehicle.Server.OnEnterArea=function(self,entity, areaId)
		if (self.OnEnterArea) then	
			self.OnEnterArea(self, entity, areaId);
		end
	end

	gVehicle.Server.OnLeaveArea = function(self, entity, areaId)
		if (self.OnLeaveArea) then	
			self.OnLeaveArea(self, entity, areaId);
		end
	end	

	gVehicle.Event_Enable = function(self)
		self:Hide(0);
		BroadcastEvent(self, "Enable");
	end
	
	gVehicle.Event_Disable = function(self)
		self:Hide(1);
		BroadcastEvent(self, "Disable");
	end
	
	gVehicle.Event_EnableEngine = function(self)
		self.vehicle:DisableEngine(0);
		BroadcastEvent(self, "EnableEngine");
  end
  
  gVehicle.Event_DisableEngine = function(self)
		self.vehicle:DisableEngine(1);
		BroadcastEvent(self, "DisableEngine");
  end

	gVehicle.Event_EnableMovement = function(self)
		self.vehicle:EnableMovement(1);
		BroadcastEvent(self, "EnableMovement");
  end
  
  gVehicle.Event_DisableMovement = function(self)
		self.vehicle:EnableMovement(0);
		BroadcastEvent(self, "DisableMovement");
  end
  
  gVehicle.Event_Destroy = function(self)
		self.vehicle:Destroy();
		BroadcastEvent(self, "Destroy");
  end
  
  function MakeRespawnable(entity)
	if (entity.Properties) then
		entity.Properties.Respawn={
			nTimer=30,
			bUnique=0,
			bRespawn=0,
		};
	end
  end
  
  MakeRespawnable(gVehicle);
  gVehicle.Properties.Respawn.bAbandon=1;
  gVehicle.Properties.Respawn.nAbandonTimer=90;
	
	local FlowEvents =
	{
		Inputs =
		{
			Enable  = { gVehicle.Event_Enable, "bool" },
			Disable = { gVehicle.Event_Disable, "bool" },		
			EnableEngine = { gVehicle.Event_EnableEngine, "bool" },
			DisableEngine = { gVehicle.Event_DisableEngine, "bool" },
			EnableMovement  = { gVehicle.Event_EnableMovement, "bool" },		
			DisableMovement = { gVehicle.Event_DisableMovement, "bool" },
			Destroy = { gVehicle.Event_Destroy, "bool" },
		},
		Outputs =
		{
			Enable  = "bool",
			Disable = "bool",
			EnableEngine = "bool",
			DisableEngine = "bool",
			EnableMovement = "bool",
			DisableMovement = "bool",
			Destroy = "bool",
			Dead = "bool",
		},
	};
	
	if (not gVehicle.FlowEvents) then
		gVehicle.FlowEvents = FlowEvents;
	else	
		mergef(gVehicle.FlowEvents, FlowEvents, 1);
	end
	
  _G[vehicle] = gVehicle;
  
  if (_G[vehicle].AIProperties) then       
    CreateVehicleAI(_G[vehicle]);
   end
  
  ExposeVehicleToNetwork( _G[vehicle] );      
end





