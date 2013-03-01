----------------------------------------------------------------------------------------------------
--  Crytek Source File.
--  Copyright (C), Crytek Studios, 2009
----------------------------------------------------------------------------------------------------
--  $Id$
--  $DateTime$
--  Description: RandomPropagator entity, propagates action, may be used to trigger events (extends Propagator to propagate randomly)
--
----------------------------------------------------------------------------------------------------
--  History:
--  - 22:4:2009   15:18 : Created by Christian Helmich
--
----------------------------------------------------------------------------------------------------

Script.ReloadScript("scripts/Entities/Fires/Propagator.lua");

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
-- table

RandomPropagator = new(Propagator);
RandomPropagator.Properties.nMaxSynchronPropagation = 1;

-------------------------------------------------------



-------------------------------------------------------

function RandomPropagator:Propagate()
	-- propagate
	-- Log("RandomPropagator:Propagate %s", self:GetName());	
	local count	= 0;
	local link	= self:GetLinkTarget("PropagatorLink", count);
	
	while (link) do
		count	= count+1;
		link	= self:GetLinkTarget("PropagatorLink", count);
	end
	
	local i = 0;
	while (i < self.Properties.nMaxSynchronPropagation ) do
		local rnd = math.random(0, count-1);
		-- Log("%s : selected link %i out of %i links", self:GetName(), rnd, count);
	
		local prop = self:GetLinkTarget("PropagatorLink", rnd);
		if( prop ~= nil) then
			if( prop:IsInitialized() == false) then
				prop:OnReset();
			end
			if( prop:GetState() == "Idle") then
				prop:Activate(1);
				prop:Event_Enable();
			end
		end
	i = i + 1;
	end	
	
	self:ActivateOutput( "Propagate", true );
end

-------------------------------------------------------

function RandomPropagator:Event_Enable()
	return Propagator.Event_Enable(self);
end

-------------------------------------------------------

function RandomPropagator:Event_Disable()
	return Propagator.Event_Disable(self);
end

-------------------------------------------------------

RandomPropagator.FlowEvents =
{
	Inputs =
	{
		Enable	= { RandomPropagator.Event_Enable, "bool" },
		Disable	= { RandomPropagator.Event_Disable, "bool" },
	},
	
	Outputs =
	{
		Enable		= "bool",
		Disable		= "bool",	
		Propagate	= "bool",
		StartEffect	= "bool",
		StopEffect	= "bool",
		StopEffect	= "bool",
	},
}

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
-- <eof>