----------------------------------------------------------------------------------------------------
--  Crytek Source File.
--  Copyright (C), Crytek GmbH 2010.
----------------------------------------------------------------------------------------------------
--  Description: Base Entity for Interactive Object using IK (Procedural Object Interaction System)
----------------------------------------------------------------------------------------------------
--  History:
--  21:09:2010 : Created by Michelle Martin
----------------------------------------------------------------------------------------------------

-- eiIKObjectType:  --> defined in GlobalEnums.xml in Game/Libs/
--		<entry enum="Standard=0" />
--		<entry enum="Wheel_big=1" />
--		<entry enum="Wheel_small=2" />
--		<entry enum="Handle=3" />
--		<entry enum="Lever=4" />
--		<entry enum="Button=5" />




BasicIKObject = {

	Properties = {
		InteractionParameters = {
		
			sHandleLimb1 = "RgtArm01",
			sHandleLimb2 = "",
			
			eiIKObjectType = 0,
			bAllowRegrip = 1,

			AdditionalOffsetPos = { x = 0.0, y = 0.0, z = 0.0, },
			AdditionalOffsetRot = { x = 0.0, y = 0.0, z = 0.0, },
			
			Animations =
			{
				sAnimName = "",
				bAnimPausesGraph = 1,
				iAnimLayer = 0,
				fAnimBlendTime = 0.4,

				sGraphInput = "",
				sGraphValue = "",

				sLimb1Animation = "";
				sLimb2Animation = "";
			},
		},
	},

	Editor = {
		Icon = "TagPoint.bmp",
	},

}


---------------------------------------------------------
---------------------------------------------------------
--       IK / INTERACTION FUNCTIONS
---------------------------------------------------------

function BasicIKObject:StartIK(self, user)
	if (self) then
		-- the StartInteraction script bind function can take an arbitrary amount of limb handles
		-- extend the function call here as you need it
		--System.Log("StartIK");
		
		self.InteractionId = IKInteractionSystem.StartInteraction(user.id, self.id, self.Properties.InteractionParameters.eiIKObjectType, self.Properties.InteractionParameters.bAllowRegrip, self.Properties.InteractionParameters.sHandleLimb1, self.Properties.InteractionParameters.sHandleLimb2);
	end
end

function BasicIKObject:StopIK(self, user)
	if (self and self.InteractionId) then
		--System.Log("StopIK");
		IKInteractionSystem.StopInteraction(self.InteractionId);
		self.InteractionId = -1;
	end
end


---------------------------------------------------------



---------------------------------------------------------
---------------------------------------------------------
--    These are function that are called from outside
--    to notify the object that something is happening
---------------------------------------------------------

function BasicIKObject:InteractionTrigger(user, isStarting)
	if (isStarting) then
		--System.Log("Character started an interaction with this object.");
		self:ActivateOutput( "InteractionStarted", true);
	else
		--System.Log("Character has stopped interacting with this object.");
		self:ActivateOutput( "InteractionFinished", true);
	end

end

function BasicIKObject:OnInteractionTrigger(user, isStarting)
	self:InteractionTrigger(user, isStarting);
end

---------------------------------------------------------

function BasicIKObject:OnCharacterIsFollowingObject(user, ikIsBlendedIn)
	
	-- user.id gives more information about which character
	-- this information might be interesting if an object can 
	-- be used by more than one
	
	if (ikIsBlendedIn) then
		--System.Log("Character is holding on to the object.");
		self:ActivateOutput("CharacterHoldingOn", true);
	else 
		--System.Log("Character is NOT holding on to this object.");
		self:ActivateOutput("CharacterHoldingOn", false);
	end
end

function BasicIKObject:CharacterIsFollowingObject(user, ikIsBlendedIn)
	self:OnCharacterIsFollowingObject(user, ikIsBlendedIn);
end
---------------------------------------------------------

function BasicIKObject:UpdateOffsets()
	if (self.InteractionId and self.InteractionId > -1) then
		IKInteractionSystem.SetInteractionOffset(self.InteractionId, self.Properties.InteractionParameters.AdditionalOffsetPos, self.Properties.InteractionParameters.AdditionalOffsetRot);
	end
end
---------------------------------------------------------



---------------------------------------------------------
---------------------------------------------------------
--      COMMON ENTITY FUNCTIONS
---------------------------------------------------------




function BasicIKObject:Reset()
end


function BasicIKObject:OnPropertyChange()
	self:Reset();
	self:UpdateOffsets();
end

function BasicIKObject:OnReset()
	self:Reset();
end

function BasicIKObject:OnSpawn()	
	self:Reset();
end

function BasicIKObject:OnDestroy()
end

---------------------------------------------------------
---------------------------------------------------------
----                Flowgraph Node                    ---
---------------------------------------------------------

function BasicIKObject:Event_StopIK( sender )
	self:StopIK(self, 0);
end

function BasicIKObject:Event_SetUserID( sender, iUserEntity )
	System.Log("SetUserID called");
	self:StartIK(self, iUserEntity);
end

---------------------------------------------------------
-----  Inputs and Outputs Definition of the FG node -----
---------------------------------------------------------

BasicIKObject.FlowEvents =
{
	Inputs =
	{
		StartWithCharacter = { BasicIKObject.Event_SetUserID, "entity" },
		StopIK	= { BasicIKObject.Event_StopIK, "bool" },
	},
	
	Outputs =
	{
		InteractionStarted	= "bool",
		InteractionFinished	= "bool",
		CharacterHoldingOn	= "bool",	
	},
}

