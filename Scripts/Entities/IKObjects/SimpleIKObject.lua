----------------------------------------------------------------------------------------------------
--  Crytek Source File.
--  Copyright (C), Crytek GmbH 2010.
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------

-- eiIKObjectType:  --> defined in GlobalEnums.xml in Game/Libs/
--		<entry enum="Standard=0" />
--		<entry enum="Wheel_big=1" />
--		<entry enum="Wheel_small=2" />
--		<entry enum="Handle=3" />
--		<entry enum="Lever=4" />
--		<entry enum="Button=5" />

SimpleIKObject = {

	Properties = {
	
		object_Model = "Objects/box.cgf",

		InteractionParameters = {
			bAllowRegrip = 0,
		},

	},

	Editor = {
		Icon = "animobject.bmp",
		IconOnTop=1,
	},
	
}


------------------------------------------------------
------------------------------------------------------
--           make this an IK Object
------------------------------------------------------
Script.ReloadScript( "SCRIPTS/Entities/IKObjects/BasicIKObject.lua");
MakeDerivedEntityOverride( SimpleIKObject, BasicIKObject )
------------------------------------------------------
------------------------------------------------------


-------------------------------------------------------
-------------------------------------------------------

function SimpleIKObject:OnInit()
	self:LoadObject(0,self.Properties.object_Model);
end

function SimpleIKObject:OnPropertyChange()
	self:OnInit();
	self:UpdateOffsets();
end

