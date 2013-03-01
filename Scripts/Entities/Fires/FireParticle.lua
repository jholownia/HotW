----------------------------------------------------------------------------------------------------
--  Crytek Source File.
--  Copyright (C), Crytek Studios, 2009
----------------------------------------------------------------------------------------------------
--  $Id$
--  $DateTime$
--  Description: ParticleEffect + cgf-Bounding box, can be extinguished when shot with correct bullet
--
----------------------------------------------------------------------------------------------------
--  History:
--  - 27:5:2009   12:25 : Created by Christian Helmich
--
----------------------------------------------------------------------------------------------------
Script.ReloadScript("scripts/Utils/EntityUtils.lua")
Script.ReloadScript("scripts/entities/Particle/ParticleEffect.lua")

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
-- table

FireParticle = new(ParticleEffect);

FireParticle.type = "FireParticle";

FireParticle.Client = {};
FireParticle.Server = {};

FireParticle.Properties.object_Model = "objects/default/primitive_cylinder.cgf"; -- hitbox model, not rendered
FireParticle.Properties.bDrawDebug = 0; -- draw hitbox
FireParticle.Properties.fMaxIntensity = 10.0; -- maximum fire intensity (fire health factor)
FireParticle.Properties.fIncreaseRate = 0.2; -- fire intensity incrementation per second

FireParticle.Properties.Physics =
		{
			bRigidBody = 1, 
			bRigidBodyActive = 1,
			bRigidBodyAfterDeath = 1,
			bResting = 1,
			Density = -1,
			Mass = -1,
		};

FireParticle.Properties.HitReaction =
		{
			sProjectileName = "bullet", -- must match co2foam
			nProjectileType = 4, -- must match co2foam
			nBulletType = 2, -- must match co2foam
			bVerboseHit = 0, -- for logging on hit
		};

-- instance member variables
FireParticle.intensity = 0.0;
FireParticle.increment = 0.2;
FireParticle.model = "";
FireParticle.drawDebug = 0;

FireParticle.Editor.Icon = "explosion.bmp";

FireParticle.States = { "Active", "Idle" };


----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
-- functions

function FireParticle:CreatePhysics()
	if(self.drawDebugSlot == nil) then
		self.drawDebugSlot = self:LoadObject(-1, self.Properties.object_Model);
		--Log("loaded into: %s", tostring(self.drawDebugSlot));
	end
	
	local bDrawDebug = self.Properties.bDrawDebug;
	if (bDrawDebug == 1) then
		--Log("draw debug on %s", tostring(self.drawDebugSlot));
		self:DrawSlot(self.drawDebugSlot, 1);
	else
		--Log("draw debug off %s", tostring(self.drawDebugSlot));
		self:DrawSlot(self.drawDebugSlot, 0);
	end
	self:PhysicalizeMe();
	self:AwakePhysics(1);
end

-------------------------------------------------------
function FireParticle:PhysicalizeMe()
	--Log("FireParticle:PhysicalizeMe");
	local physics = self.Properties.Physics;
	EntityCommon.PhysicalizeRigid( self, 0, physics, 1 );
end

-------------------------------------------------------
function FireParticle:ChangeIntensity(damage)
	--Log("FireParticle:ChangeIntensity");
	self.intensity = self.intensity - damage;
	if ( self.intensity < 0.0 ) then
		----Log("%s has been successfully extinguished", self:GetName());
		self:ActivateOutput("Extinct", true);
		self:Disable();
	end
end

-------------------------------------------------------
function FireParticle:ReactToHit(hitInfo)
	--Log("FireParticle:ReactToHit %s in %s", self:GetName(), self:GetState());

	-- check if hit matches settings
	local hitReaction = self.Properties.HitReaction;
	--Log("VerboseHit %b",hitReaction.bVerboseHit);

	if (hitReaction.bVerboseHit == 1) then
		Log("hitInfo.type %s", hitInfo.type);
		Log("hitInfo.typeId %i", hitInfo.typeId);
		Log("hitInfo.damage %f", hitInfo.damage);
		if ( hitInfo.type == "bullet") then	
			Log("hitInfo.bulletType %s", hitInfo.bulletType);
		end
	end

	if (hitInfo.type ~= hitReaction.sProjectileName) then
		return false;
	end

	if ( hitInfo.typeId ~= hitReaction.nProjectileType) then
		return false;
	end

	if ( hitInfo.type == "bullet" and hitInfo.bulletType ~= hitReaction.nBulletType) then
		return false;
	end

	-- if reaches here, hit has been successful (i.e. matches settings)
	self:ActivateOutput( "Hit", true );
	self:ChangeIntensity(hitInfo.damage);
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
-- Basic state triggers

function FireParticle:IsRigidBody()
	return true;
end

-------------------------------------------------------
function FireParticle:OnInit()
	--Log("FireParticle:OnInit");
	ParticleEffect.OnInit( self );
	self:CreatePhysics();
end

-------------------------------------------------------
function FireParticle:OnPropertyChange()
	--Log("FireParticle:OnPropertyChange");
	ParticleEffect.OnPropertyChange( self );
end

-------------------------------------------------------
function FireParticle:OnReset()
	--Log("FireParticle:OnReset");
	ParticleEffect.OnReset( self );
	self:CreatePhysics();
end

-------------------------------------------------------
function FireParticle:OnLoad(table) 
	--Log("FireParticle:OnLoad");
	ParticleEffect.OnLoad(self, table);
	self.intensity = table.intensity;
	self.bRigidBodyActive = table.bRigidBodyActive;
end

-------------------------------------------------------
function FireParticle:OnSave(table)  
	--Log("FireParticle:OnSave");
	ParticleEffect.OnSave(self, table);
	table.intensity = self.intensity;
	table.bRigidBodyActive = self.bRigidBodyActive;
end

-------------------------------------------------------
function FireParticle:OnSpawn()
	--Log("FireParticle:OnSpawn");
	self:OnReset();
end

-------------------------------------------------------
function FireParticle:OnShutDown()
	--Log("FireParticle:OnShutDown %s", self:GetName());
	ParticleEffect.OnShutDown( self );
end


----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
-- Collision/hit detection

function FireParticle.Server:OnHit(hitInfo)
	--Log("FireParticle.Server:OnHit %s in %s", self:GetName(), self:GetState());
	if (self:GetState() == "Active") then
		self:ReactToHit(hitInfo);
	end
end

-------------------------------------------------------
function FireParticle.Client:OnCollision(hit)
	--Log("FireParticle.Client:OnCollision");
end

-------------------------------------------------------
function FireParticle:OnDamage( hit )
	--Log("FireParticle:OnDamage");
end

-------------------------------------------------------
function FireParticle:OnUpdate( frameTime )
	--if(self:GetState() ~= "Active") then return end

	--Log("s%:OnUpdate(%f)", self:GetName(), self.intensity);
	--Log("%s self.intensity= %f", self:GetName(), self.intensity);
end

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
-- States

FireParticle.Server.Active =
{
	OnBeginState = function( self )
		--Log("FireParticle.Server.Active.OnBeginState %s", self:GetName());
		--self:CreatePhysics();
		self.intensity = self.Properties.fMaxIntensity;
		self:ActivateOutput( "Relit", true );
	end,

	OnEndState = function( self )
		--Log("FireParticle.Server.Active.OnEndState %s", self:GetName());
	end,
}

-------------------------------------------------------
FireParticle.Server.Idle =
{
	OnBeginState = function( self )
		--Log("FireParticle.Server.Idle.OnBeginState %s", self:GetName());
	end,

	OnEndState = function( self )
		--Log("FireParticle.Server.Idle.OnEndState %s", self:GetName());
	end,
}

-------------------------------------------------------
-------------------------------------------------------
FireParticle.Client.Active =
{
	OnBeginState = function( self )
		--Log("FireParticle.Client.Active.OnBeginState %s", self:GetName());
		ParticleEffect.Active.OnBeginState(self);
	end,

	OnEndState = function( self )
		--Log("FireParticle.Client.Active.OnEndState %s", self:GetName());
		--ParticleEffect.Active.OnEndState(self);
	end,
}

-------------------------------------------------------
FireParticle.Client.Idle =
{
	OnBeginState = function( self )
		----Log("FireParticle.Client.Idle.OnBeginState %s", self:GetName());
		ParticleEffect.Idle.OnBeginState(self);
	end,

	OnEndState = function( self )
		--Log("FireParticle.Client.Idle.OnEndState %s", self:GetName());
	--	ParticleEffect.Idle.OnEndState(self);	--does not exist in ParticleEffect.lua
	end,
}

-------------------------------------------------------
-------------------------------------------------------
-- particle start/stop

function FireParticle:Enable()
	--Log("FireParticle:Enable %s", self:GetName());
	ParticleEffect.Enable( self );
end

function FireParticle:Disable()
	--Log("FireParticle:Disable %s", self:GetName());
	ParticleEffect.Disable( self );
end
-------------------------------------------------------

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
-- Flow graph

function FireParticle:Event_Enable()
	--Log("FireParticle:Event_Enable %s", self:GetName());
	ParticleEffect.Event_Enable( self );
end

-------------------------------------------------------
function FireParticle:Event_Disable()
	--Log("FireParticle:Event_Disable %s", self:GetName());
	ParticleEffect.Event_Disable( self );
end

-------------------------------------------------------
function FireParticle:Event_Restart()
	--Log("FireParticle:Event_Restart %s", self:GetName());
	ParticleEffect.Event_Restart( self );
end

-------------------------------------------------------
function FireParticle:Event_Spawn()
	--Log("FireParticle:Event_Spawn %s", self:GetName());
	ParticleEffect.Event_Spawn( self );
end

-------------------------------------------------------
FireParticle.FlowEvents =
{
	Inputs =
	{
		Disable	= { FireParticle.Event_Disable,	"bool" },
		Enable 	= { FireParticle.Event_Enable,	"bool" },
		Restart	= { FireParticle.Event_Restart,	"bool" },
		Spawn	= { FireParticle.Event_Spawn,	"bool" },
	},
	Outputs =
	{
		Disable	= "bool",
		Enable	= "bool",
		Restart	= "bool",
		Spawn	= "bool",
		Hit		= "bool",
		Extinct = "bool",
		Relit	= "bool",
	},
}

----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
-- client functions

function FireParticle.Client:OnInit()
	ParticleEffect.Client.OnInit(self);
end

-------------------------------------------------------
function FireParticle.Client:ClEvent_Spawn()
	ParticleEffect.Client.ClEvent_Spawn(self);
end

-------------------------------------------------------
function FireParticle.Client:ClEvent_Enable()
	ParticleEffect.Client.ClEvent_Enable(self);
end

-------------------------------------------------------
function FireParticle.Client:ClEvent_Disable()
	ParticleEffect.Client.ClEvent_Disable(self);
end

-------------------------------------------------------
function FireParticle.Client:ClEvent_Restart()
	ParticleEffect.Client.ClEvent_Restart(self);
end

-------------------------------------------------------
function FireParticle.Client:ClEvent_Kill()
	ParticleEffect.Client.ClEvent_Kill(self);
end
