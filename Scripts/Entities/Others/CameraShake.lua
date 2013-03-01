--------------------------------------------------------------------------
--	Crytek Source File.
-- 	Copyright (C), Crytek Studios, 2001-2005.
--------------------------------------------------------------------------
--	$Id$
--	$DateTime$
--	Description: Camera Shake helper entity
--  
--------------------------------------------------------------------------
--  History:
--  - 06:12:2005   19:00 : Created by alexl
--
--------------------------------------------------------------------------

CameraShake = {
	Properties = {
		vector_Position = {x=0, y=0, z=0 },
		Radius = 10.0,
		fStrength = 1.0,
		fDuration = 2.0,
		fFrequency = 0.5		
	},
	Editor={
 	 		Icon="shake.bmp",
			AbsoluteRadius=1,
	},
}

function CameraShake:OnPropertyChange()
end

function CameraShake:Event_Shake(sender)
	
	if(IsNullVector(self.Properties.vector_Position))then
		self.Properties.vector_Position = self:GetPos();
	end
	
	g_gameRules:ClientViewShake(self.Properties.vector_Position, nil, 0.0, self.Properties.Radius,self.Properties.fStrength,self.Properties.fDuration,self.Properties.fFrequency);
end

function CameraShake:Event_Position(sender, data)
	self.Properties.vector_Position = data;
end

CameraShake.FlowEvents =
{
	Inputs =
	{
		Shake = { CameraShake.Event_Shake, "bool" },
		Position = {CameraShake.Event_Position, "Vec3" },
	},
	Outputs =
	{
	},
}
