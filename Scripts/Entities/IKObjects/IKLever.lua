----------------------------------------------------------------------------------------------------
--  Crytek Source File.
--  Copyright (C), Crytek GmbH 2010.
----------------------------------------------------------------------------------------------------
--  Description: IK Entity for a Lever that is derived from a basic IK Object
----------------------------------------------------------------------------------------------------
--  History:
--  21:09:2010 : Created by Michelle Martin
----------------------------------------------------------------------------------------------------

IKLever = {

	Properties = {
		InteractionParameters = {
			fTriggerDistance = 2.5,
			sHandleArm2 = "fff",
			bTwoArmAction = 1,
			szUseMessage = "Use ME!",
		},
	},
}


------------------------------------------------------
------------------------------------------------------
--           make this an IK Object
------------------------------------------------------
Script.ReloadScript( "SCRIPTS/Entities/IKObjects/BasicIKObject.lua");
MakeDerivedEntityOverride( IKLever, BasicIKObject )
------------------------------------------------------
------------------------------------------------------


function IKLever:IsUsable(user)
	--System.Log("IsUsable was called");
	if (not user) then
		return 0;
	end
	
	return 1;
end


function IKLever:OnUsed(user)	
	System.Log("OnUsed(user) was called");
--	self.server:SvRequestUse(user.id);
	self:StartIK(self, 0);
end


function IKLever:GetUsableMessage()
	System.Log("GetUsableMessage was called");
	return "@pick_object";
end


function IKLever:PauseAnimations(pause)
	
	System.Log("PauseAnimations called");
	self:StartIK(self, 0);
	--__super.StartIK(self, 0);
	
	if (pause) then
		--// pause ongoing animations
	else
		--// continue animations
	end
end

