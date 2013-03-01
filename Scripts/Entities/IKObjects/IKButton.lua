----------------------------------------------------------------------------------------------------
--  Crytek Source File.
--  Copyright (C), Crytek GmbH 2010.
----------------------------------------------------------------------------------------------------
--  Description: IK Entity for a turning wheel that is derived from a basic IK Object
----------------------------------------------------------------------------------------------------
--  History:
--  February 2011 : Created by Michelle Martin
----------------------------------------------------------------------------------------------------

-- eiIKObjectType:  --> defined in GlobalEnums.xml in Game/Libs/
--		<entry enum="Standard=0" />
--		<entry enum="Wheel_big=1" />
--		<entry enum="Wheel_small=2" />
--		<entry enum="Handle=3" />
--		<entry enum="Lever=4" />
--		<entry enum="Button=5" />

IKButton = {

	Properties = {
	
		object_Model = "Objects/box.cgf",
		fMoveSpeed = -0.2,
		fMoveTime  = 0.1,
		fDelay     = 0.0,
		iAxis	   = 2,

		InteractionParameters = {
		
			sHandleLimb1 = "RgtArm01",
			sHandleLimb2 = "",
			
			bAllowRegrip = 0,
			eiIKObjectType = 5,	
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
MakeDerivedEntityOverride( IKButton, BasicIKObject )
------------------------------------------------------
------------------------------------------------------

function IKButton:PauseAnimations(pause)
	
	
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

function IKButton:CharacterIsFollowingObject(user, ikIsBlendedIn)
	
	-- user.id gives more information about which character
	-- this information might be interesting if an object can 
	-- be used by more than one
	
	self:PauseAnimations(not ikIsBlendedIn);
	
	if (ikIsBlendedIn) then
		System.Log("Character is holding on to the object.");
	else
		System.Log("Character is NOT holding on to this object.");
	end
end

-------------------------------------------------------
-------------------------------------------------------


function IKButton:IsUsable(user)
	--System.Log("IsUsable was called");
	if (not user) then
		return 0;
	end
	
	return 1;
end


function IKButton:OnUsed(user)	

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

IKButton.Opened =
{
	OnBeginState = function( self )
		self:StopIK(self, user);
	end,
	OnUpdate = function(self, dt)
	end,
	OnEndState = function( self )
	end,
}

IKButton.Closing =
{
	OnBeginState = function( self )
	  self.Closing.closingTimer = self.Properties.fMoveTime;
	  self:Activate(1);
	  self.Closing.delayTime = self.Properties.fDelay;
	end,
	OnUpdate = function(self, dt)
		 self.Closing.delayTime = self.Closing.delayTime - dt;
		 if (self.Closing.delayTime >= 0.0) then
		 		return;
		 end
	   self.Closing.closingTimer = self.Closing.closingTimer - dt;
	   
	   -- update rotation around the z axis by fMoveSpeed * dt
	   local slotPos = self:GetSlotPos(0);
	   
	   if (self.Properties.iAxis == 1) then
	   		slotPos.x = slotPos.x + (self.Properties.fMoveSpeed * dt);
	   elseif (self.Properties.iAxis == 2) then
	   		slotPos.y = slotPos.y + (self.Properties.fMoveSpeed * dt);
	   else
	   		slotPos.z = slotPos.z + (self.Properties.fMoveSpeed * dt);
	   end
	   
	   self:SetSlotPos(0, slotPos);
	   
	   if (self.Closing.closingTimer <= 0) then
	        self:GotoState("Closed");
	   end
	end,
	OnEndState = function( self )
	  self:Activate(0);
	end,
}

IKButton.Closed =
{
	OnBeginState = function( self )
	end,
	OnUpdate = function(self, dt)
	end,
	OnEndState = function( self )
	end,
}

IKButton.Opening =
{
	OnBeginState = function( self )
	  self.Opening.openingTimer = self.Properties.fMoveTime;
	  self:Activate(1);
	  self.Opening.delayTime = self.Properties.fDelay;
	end,
	OnUpdate = function(self, dt)
		 if (self.Opening.openingTimer > 0) then
		   self.Opening.openingTimer = self.Opening.openingTimer - dt;
		   
		   -- update rotation around the z axis by fMoveSpeed * dt
		   local slotPos = self:GetSlotPos(0);
	
		   if (self.Properties.iAxis == 1) then
		   		slotPos.x = slotPos.x - (self.Properties.fMoveSpeed * dt);
		   elseif (self.Properties.iAxis == 2) then
		   		slotPos.y = slotPos.y - (self.Properties.fMoveSpeed * dt);
		   else
		   		slotPos.z = slotPos.z - (self.Properties.fMoveSpeed * dt);
		   end
	
		   self:SetSlotPos(0, slotPos);
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

function IKButton:Close()
  if (self:GetState()=="Closed" or self:GetState()=="Closing") then
  	return;
  end
  
  self:GotoState("Closing");
end

function IKButton:Open()
  if (self:GetState()=="Opened" or self:GetState()=="Opening") then
  	return;
  end
  
  self:GotoState("Opening");
end

-------------------------------------------------------
-------------------------------------------------------

function IKButton:OnInit()
	self:LoadObject(0,self.Properties.object_Model);
	self:GotoState("Opened");
end

function IKButton:OnPropertyChange()
	self:OnInit();
	self:UpdateOffsets();
end

function IKButton:OnReset()	
	self:OnInit();
end