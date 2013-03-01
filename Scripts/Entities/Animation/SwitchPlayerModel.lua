----------------------------------------------------------------------------------------------------
--  Crytek Source File.
--  Copyright (C), Crytek Studios, 2009
----------------------------------------------------------------------------------------------------
--  $Id$
--  $DateTime$
--  Description: Switch player model
--
----------------------------------------------------------------------------------------------------
--  History:
--  - 13/07/2009   15:12 : Created by Christian Helmich
--
----------------------------------------------------------------------------------------------------

Script.ReloadScript("scripts/Utils/math.lua");

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
-- table

SwitchPlayerModel =
{		
	-- type for scripting
	type = "SwitchPlayerModel",
	
	-- instance member variables	
	object_PlayerModel	= "",
	object_ClientModel	= "",
	object_ArmsModel	= "",
	object_FrozenModel	= "",
	-- entityId			= -1;
	
	-- exposed properties
	Properties =
	{	
		bActive					= 1,
		object_PlayerModel		= "Objects/Characters/sdk_player/sdk_player.cdf",		-- player model
		object_ClientModel		= "Objects/Characters/sdk_player/sdk_player.cdf",		-- client player model
		object_ArmsModel		= "Objects/Weapons/arms_fp/arms_fp.cdf",						-- 1st person arms model
		object_FrozenModel		= "Objects/Characters/sdk_player/sdk_player.cdf",		-- 3rd person frozen model		
	},
	
	-- editor 
	Editor=
	{
		Icon="spawngroup.bmp",
	},
	
	-- states
	States = { "Inactive", "Active" },
}

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
-- Basic state triggers

-------------------------------------------------------
function SwitchPlayerModel:OnSave(table)		
	table.object_PlayerModel	= self.object_PlayerModel;
	table.object_ClientModel	= self.object_ClientModel;
	table.object_ArmsModel		= self.object_ArmsModel;
	table.object_FrozenModel	= self.object_FrozenModel;
end

-------------------------------------------------------
function SwitchPlayerModel:OnLoad(table)	
	self.object_PlayerModel		= table.object_PlayerModel;	
	self.object_ClientModel		= table.object_ClientModel;
	self.object_ArmsModel		= table.object_ArmsModel;
	self.object_FrozenModel		= table.object_FrozenModel;
end

-------------------------------------------------------
function SwitchPlayerModel:OnInit()	
	self:OnReset();	
end

-------------------------------------------------------
function SwitchPlayerModel:OnPropertyChange()	
	self:OnReset();	
end

-------------------------------------------------------
function SwitchPlayerModel:OnReset()
	Log("SwitchPlayerModel:OnReset %s", self:GetName());	
	self.object_PlayerModel		= self.Properties.object_PlayerModel;	
	self.object_ClientModel		= self.Properties.object_ClientModel;
	self.object_ArmsModel		= self.Properties.object_ArmsModel;	
	self.object_FrozenModel		= self.Properties.object_FrozenModel;
	
	self:Activate(0);	
	self:GotoState("Inactive");
end

-------------------------------------------------------
function SwitchPlayerModel:OnActivate()
	Log("SwitchPlayerModel:OnActivate %s", self:GetName());	
	self:GotoState("Active");
end

-------------------------------------------------------
function SwitchPlayerModel:OnShutDown()
	--Log("Propagator:OnShutDown");
end

-------------------------------------------------------


----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
-- Member functions

function SwitchPlayerModel:SwitchModel()
	-- switch model
	Log("SwitchPlayerModel:SwitchModel %s", self:GetName());
	Log("player model %s", self.object_PlayerModel);
	Log("client model %s", self.object_ClientModel);
	Log("arms model %s", self.object_ArmsModel);
	Log("frozen model %s", self.object_FrozenModel);
	
	-- entity = System.GetEntity(entityId);
	actor = g_localActor;	
	
	Log("actor.actor:IsLocalClient() %i", actor.actor:IsLocalClient() );
	actor:SetModel(self.object_PlayerModel, self.object_ArmsModel, self.object_FrozenModel, self.object_ClientModel);	
	actor:OnReset();	--use only instead of the function below if it behaves strangely
	-- BasicActor.SetActorModel(actor, actor.actor:IsLocalClient() );
	self:ActivateOutput("Done", true);
end

-------------------------------------------------------


----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
-- State machine

-------------------------------------------------------
-- state machine - client side

SwitchPlayerModel.Inactive = 
{
	OnBeginState = function( self )		
		Log("SwitchPlayerModel.Inactive:OnBeginState %s", self:GetName());
		self:ActivateOutput("Disable", true);
	end,
	
	OnEndState = function( self )
		Log("SwitchPlayerModel.Inactive:OnEndState %s", self:GetName());
	end,
}


SwitchPlayerModel.Active = 
{
	OnBeginState = function( self )		
		Log("SwitchPlayerModel.Active:OnBeginState %s", self:GetName());
		self:ActivateOutput("Enable", true);
	end,
	
	OnEndState = function( self )
		Log("SwitchPlayerModel.Active:OnEndState %s", self:GetName());		
	end,
}


----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
-- Flow graph

function SwitchPlayerModel:Event_Enable()
	Log("SwitchPlayerModel:Event_Enable %s", self:GetName());
	if(self:GetState() ~= "Active") then
		self:GotoState("Active");		
	end
end

function SwitchPlayerModel:Event_Disable()
	Log("SwitchPlayerModel:Event_Disable %s", self:GetName());
	if(self:GetState() ~= "Inactive") then
		self:GotoState("Inactive");		
	end
end

function SwitchPlayerModel:Event_Switch()
	Log("SwitchPlayerModel:Event_Switch %s", self:GetName());
	Log("state: %s", self:GetState());
	if(self:GetState() == "Active") then
		self:SwitchModel();
	end
end

SwitchPlayerModel.FlowEvents =
{
	Inputs =
	{
		Enable	= { SwitchPlayerModel.Event_Enable, "bool" },
		Disable	= { SwitchPlayerModel.Event_Disable, "bool" },
		Switch	= { SwitchPlayerModel.Event_Switch, "bool" },		
	},
	
	Outputs =
	{
		Enable		= "bool",
		Disable		= "bool",	
		Done		= "bool",
	},
}

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
-- <eof>