----------------------------------------------------------------------------------------------------
--  Crytek Source File.
--  Copyright (C), Crytek GmbH 2010.
----------------------------------------------------------------------------------------------------
--  Description: IK Entity for a turning wheel that is derived from a basic IK Object
----------------------------------------------------------------------------------------------------
--  History:
--  10:11:2010 : Created by Michelle Martin
----------------------------------------------------------------------------------------------------

-- eiIKObjectType:  --> defined in GlobalEnums.xml in Game/Libs/
--		<entry enum="Standard=0" />
--		<entry enum="Wheel_big=1" />
--		<entry enum="Wheel_small=2" />
--		<entry enum="Handle=3" />
--		<entry enum="Lever=4" />
--		<entry enum="Button=5" />

IKTurnWheel = {

	Properties = {
	
		object_Model = "Objects/box.cgf",
		fTurnSpeed = 120.0,
		fTurnTime  = 3.0,
		fDelay     = 1.0,
		iAxis			 = 3,

		InteractionParameters = {
		
			sHandleLimb1 = "RgtArm01",
			sHandleLimb2 = "LftArm01",
			
			eiIKObjectType = 1,
		},

	},

	Editor = {
		Icon = "animobject.bmp",
		IconOnTop=1,
	},
	
	States = { "Opened", "Closing", "Closed", "Opening" },

}


------------------------------------------------------
------------------------------------------------------
--           make this an IK Object
------------------------------------------------------
Script.ReloadScript( "SCRIPTS/Entities/IKObjects/BasicIKObject.lua");
MakeDerivedEntityOverride( IKTurnWheel, BasicIKObject )
------------------------------------------------------
------------------------------------------------------

function IKTurnWheel:PauseAnimations(pause)
	
	
	-- Since the wheel "animations" are really only this script playing with the rotation
	-- around the z-axis, it is enough to stop the updates until the animations can be unpaused again.
	
	if (pause) then
		System.Log("PauseAnimations called - pausing");
		--// pause ongoing animations
		self:Activate(0);
	else
		System.Log("PauseAnimations called - resuming");
		--// continue animations
		self:Activate(1);
	end
end

function IKTurnWheel:CharacterIsFollowingObject(user, ikIsBlendedIn)
	
	-- user.id gives more information about which character
	-- this information might be interesting if an object can 
	-- be used by more than one
	
	-- let the basic ik object know what happening (this will update the FG node)
	self:OnCharacterIsFollowingObject(user, ikIsBlendedIn);
	
	self:PauseAnimations(not ikIsBlendedIn);
	
	if (ikIsBlendedIn) then
		System.Log("Character is holding on to the object.");
	else
		System.Log("Character is NOT holding on to this object.");
	end
end

-------------------------------------------------------
-------------------------------------------------------


function IKTurnWheel:IsUsable(user)
	--System.Log("IsUsable was called");
	if (not user) then
		return 0;
	end
	
	return 1;
end


function IKTurnWheel:OnUsed(user)	

--	System.Log("OnUsed(user) was called");
	if (self:GetState()=="Opened") then
		self:StartIK(self, user);
		self:Close();
	elseif (self:GetState()=="Closed") then
		--self:StopIK(self, user);
		self:Open();
	end

end


-------------------------------------------------------
-------------------------------------------------------

IKTurnWheel.Opened =
{
	OnBeginState = function( self )
		self:ActivateOutput( "Opened", true);
		self:StopIK(self, user);
	end,
	OnUpdate = function(self, dt)
	end,
	OnEndState = function( self )
	end,
}

IKTurnWheel.Closing =
{
	OnBeginState = function( self )
	  self.Closing.closingTimer = self.Properties.fTurnTime;
	  self:Activate(1);
	  self.Closing.delayTime = self.Properties.fDelay;
	end,
	OnUpdate = function(self, dt)
		 self.Closing.delayTime = self.Closing.delayTime - dt;
		 if (self.Closing.delayTime >= 0.0) then
		 		return;
		 end
	   self.Closing.closingTimer = self.Closing.closingTimer - dt;
	   
	   -- update rotation around the z axis by turnSpeed * dt
	   local angles = self:GetSlotAngles(0);
	   
	   if (self.Properties.iAxis == 1) then
	   		angles.x = angles.x + (self.Properties.fTurnSpeed * (3.14 / 180.0) * dt);
	   elseif (self.Properties.iAxis == 2) then
	   		angles.y = angles.y + (self.Properties.fTurnSpeed * (3.14 / 180.0) * dt);
	   else
	   		angles.z = angles.z + (self.Properties.fTurnSpeed * (3.14 / 180.0) * dt);
	   end
	   
	   self:SetSlotAngles(0, angles);
	   
	   if (self.Closing.closingTimer <= 0) then
	        self:GotoState("Closed");
	   end
	end,
	OnEndState = function( self )
	  self:Activate(0);
	end,
}

IKTurnWheel.Closed =
{
	OnBeginState = function( self )
		self:ActivateOutput( "Closed", true);
	end,
	OnUpdate = function(self, dt)
	end,
	OnEndState = function( self )
	end,
}

IKTurnWheel.Opening =
{
	OnBeginState = function( self )
	  self.Opening.openingTimer = self.Properties.fTurnTime;
	  self:Activate(1);
	  self.Opening.delayTime = self.Properties.fDelay;
	end,
	OnUpdate = function(self, dt)
		 if (self.Opening.openingTimer > 0) then
		   self.Opening.openingTimer = self.Opening.openingTimer - dt;
		   
		   -- update rotation around the z axis by turnSpeed * dt
		   local angles = self:GetSlotAngles(0);
	
		   if (self.Properties.iAxis == 1) then
		   		angles.x = angles.x - (self.Properties.fTurnSpeed * (3.14 / 180.0) * dt);
		   elseif (self.Properties.iAxis == 2) then
		   		angles.y = angles.y - (self.Properties.fTurnSpeed * (3.14 / 180.0) * dt);
		   else
		   		angles.z = angles.z - (self.Properties.fTurnSpeed * (3.14 / 180.0) * dt);
		   end
	
		   self:SetSlotAngles(0, angles);
		end
	   
		if (self.Opening.openingTimer <= 0) then
			self.Opening.delayTime = self.Opening.delayTime - dt;
			if (self.Opening.delayTime >= 0.0) then
				return;
			end
			self:GotoState("Opened");       
		end
	end,
	OnEndState = function( self )
	  self:Activate(0);
	end,
}

-------------------------------------------------------
-------------------------------------------------------

function IKTurnWheel:Close()
  if (self:GetState()=="Closed" or self:GetState()=="Closing") then
  	return;
  end
  
  self:GotoState("Closing");
end

function IKTurnWheel:Open()
  if (self:GetState()=="Opened" or self:GetState()=="Opening") then
  	return;
  end
  
  self:GotoState("Opening");
end

-------------------------------------------------------
-------------------------------------------------------

function IKTurnWheel:OnInit()
	self:LoadObject(0,self.Properties.object_Model);
	self:GotoState("Opened");
end

function IKTurnWheel:OnPropertyChange()
	self:OnInit();
	self:UpdateOffsets();
end

function IKTurnWheel:OnReset()	
	self:OnInit();
end

---------------------------------------------------------
---------------------------------------------------------
----                Flowgraph Node                    ---
---------------------------------------------------------

function IKTurnWheel:Event_Open( sender )
	self:Open();
end

function IKTurnWheel:Event_Close( sender )
	self:Close();
end

IKTurnWheel.FlowEvents.Inputs.Open =  { IKTurnWheel.Event_Open, "bool" };
IKTurnWheel.FlowEvents.Inputs.Close = { IKTurnWheel.Event_Close, "bool" };
IKTurnWheel.FlowEvents.Outputs.Opened = "bool";
IKTurnWheel.FlowEvents.Outputs.Closed = "bool";

