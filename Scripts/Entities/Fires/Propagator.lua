----------------------------------------------------------------------------------------------------
--  Crytek Source File.
--  Copyright (C), Crytek Studios, 2009
----------------------------------------------------------------------------------------------------
--  $Id$
--  $DateTime$
--  Description: Propagator entity, propagates action, may be used to trigger events
--
----------------------------------------------------------------------------------------------------
--  History:
--  - 22:4:2009   15:18 : Created by Christian Helmich
--
----------------------------------------------------------------------------------------------------

Script.ReloadScript("scripts/Utils/math.lua");

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
-- table

Propagator =
{
	Client = {},
	Server = {},

	-- type for scripting
	type = "Propagator",

	-- instance member variables
	propagationTimeout = 0.0,
	activityTime = 0.0,
	pulseTimeout = 0.0,
	pulseTime = 0.0,
	initialized = false,

	-- exposed properties
	Properties =
	{
		bActive = 1,
		fStartDelayTimeout = 10.0, -- timeout before propagation
		fStartDelayRandom = 0.1, -- randomization, like in particle effects
		fPulseTimeout = 10.0, -- pulsation time, limits propagation to only propagate every x seconds
		fPulseRandom = 0.1, -- pulsation randomization as in particle effects
	},

	Editor=
	{
		Model="Editor/Objects/Particles.cgf",
		Icon="explosion.bmp",
	},

	States = { "Idle", "Active" },
}

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
-- Basic state triggers

-------------------------------------------------------
function Propagator:OnSave(table)
	--Log("Propagator:OnSave %s", self:GetName());
	table.propagationTimeout = self.propagationTimeout;
	table.activityTime = self.activityTime;
	table.pulseTimeout = self.pulseTimeout;
	table.pulseTime = self.pulseTime;
	table.initialized = self.initialized;
end

-------------------------------------------------------
function Propagator:OnLoad(table)
	--Log("Propagator:OnLoad %s", self:GetName());
	self.propagationTimeout = table.propagationTimeout;
	self.activityTime = table.activityTime;
	self.pulseTimeout = table.pulseTimeout;
	self.pulseTime = table.pulseTime;
	self.initialized = table.initialized;
end

-------------------------------------------------------
function Propagator:OnInit()
	--Log("Propagator:OnInit %s", self:GetName());
	self:OnReset();
end

-------------------------------------------------------
function Propagator:OnPropertyChange()
	--Log("Propagator:OnPropertyChange %s", self:GetName());
	self:OnReset();
end

-------------------------------------------------------
function Propagator:OnReset()
	--Log("Propagator:OnReset %s", self:GetName());
	self.propagationTimeout = self.Properties.fStartDelayTimeout;
	self.pulseTimeout = self.Properties.fPulseTimeout;
	self.pulseTime = 0.0;
	self.initialized = true;
	self:Activate(1);
	self:GotoState("Idle");
end

-------------------------------------------------------
function Propagator:OnActivate()
	--Log("Propagator:OnActivate %s", self:GetName());
	self:GotoState("Active");
end

-------------------------------------------------------
function Propagator:OnShutDown()
	--Log("Propagator:OnShutDown %s", self:GetName());
end



----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
-- Member functions

function Propagator:Propagate()
	--Log("Propagator:Propagate %s", self:GetName());
	local i = 0;
	local link	= self:GetLinkTarget("PropagatorLink", i);

	while (link) do
		--Log("Propagation  %s -> %s", self:GetName(), link:GetName());
		if( link:IsInitialized() == false) then
			link:OnReset();
		end
		if( link:GetState() == "Idle") then
			link:Activate(1);
			link:Event_Enable();
		end
		i = i+1;
		link = self:GetLinkTarget("PropagatorLink", i);
	end
	self:ActivateOutput( "Propagate", true );
end

-------------------------------------------------------

function Propagator:StartEffect()
	--Log("Propagator:StartEffect %s", self:GetName());
	self:ActivateOutput( "StartEffect", true );
end


function Propagator:StopEffect()
	--Log("Propagator:StopEffect %s", self:GetName());
	self:ActivateOutput( "StopEffect", true );
end

-------------------------------------------------------

function Propagator:ResetPropagationTimeouts()
	self.propagationTimeout = self.Properties.fStartDelayTimeout - (self.Properties.fStartDelayTimeout * randomF(0.0, self.Properties.fStartDelayRandom));
	self.pulseTimeout = self.Properties.fPulseTimeout - (self.Properties.fPulseTimeout * randomF(0.0, self.Properties.fPulseRandom));
	--Log("%s propagation: %f, pulse %f", self:GetName(), self.propagationTimeout, self.pulseTimeout);
end

-------------------------------------------------------

function Propagator:IsInitialized()
	return self.initialized;
end



----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
-- State machine

-------------------------------------------------------
-- state machine - client side

Propagator.Client.Idle = 
{
	OnBeginState = function( self )
		--Log("Propagator.Client.Idle:OnBeginState %s", self:GetName());
	end,

	OnEndState = function( self )
		--Log("Propagator.Client.Idle:OnEndState %s", self:GetName());
	end,
}


Propagator.Client.Active = 
{
	OnBeginState = function( self )
		--Log("Propagator.Client.Active:OnBeginState %s", self:GetName());
		self:StartEffect();
	end,

	OnEndState = function( self )
		--Log("Propagator.Client.Active:OnEndState %s", self:GetName());
		self:StopEffect();
	end,
}

-------------------------------------------------------
-- state machine - server side

Propagator.Server.Idle = 
{
	OnBeginState = function( self )
		--Log("Propagator.Server.Idle:OnBeginState %s", self:GetName());
		BroadcastEvent(self, "Idle %s", self:GetName());
		self:ActivateOutput( "Disable", true );
	end,

	OnEndState = function( self )
		--Log("Propagator.Server.Idle:OnEndState %s", self:GetName());
	end,
}


Propagator.Server.Active = 
{
	OnBeginState = function( self )
		--Log("Propagator.Server.Active:OnBeginState %s", self:GetName());
		BroadcastEvent(self, "Active %s", self:GetName());
		self:ActivateOutput( "Enable", true );
		self.activityTime = 0.0;
		self.pulseTime = 0.0;
		self:ResetPropagationTimeouts();
	end,

	OnEndState = function( self )
		--Log("Propagator.Server.Active:OnEndState %s", self:GetName());
	end,
	
	OnUpdate = function( self, frameTime )
		--Log("Propagator.Server.Active:OnUpdate %s, %f", self:GetName(), frameTime);
		self.activityTime = self.activityTime + frameTime;
		if ( self.activityTime > self.propagationTimeout) then
			self.pulseTime = self.pulseTime + frameTime;
			if ( self.pulseTime > self.pulseTimeout ) then
				--Log("%s pulsed at: %f/%f", self:GetName(), self.pulseTime, self.pulseTimeout);
				self.pulseTime = 0.0;
				self:ResetPropagationTimeouts();
				self:Propagate();
			end
		end
	end
}

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
-- Flow graph

function Propagator:Event_Enable()
	--Log("Propagator:Event_Enable %s", self:GetName());
	if( self:IsInitialized() == false) then
		self:OnReset();
	end
	if(self:GetState() == "Idle") then
		self:GotoState("Active");
	end
end

function Propagator:Event_Disable()
	--Log("Propagator:Event_Disable %s", self:GetName());
	if(self:GetState() == "Active") then
		self:GotoState("Idle");
	end
end

Propagator.FlowEvents =
{
	Inputs =
	{
		Enable = { Propagator.Event_Enable, "bool" },
		Disable = { Propagator.Event_Disable, "bool" },
	},
	
	Outputs =
	{
		Enable = "bool",
		Disable = "bool",
		Propagate = "bool",
		StartEffect = "bool",
		StopEffect = "bool",
		StopEffect = "bool",
	},
}
