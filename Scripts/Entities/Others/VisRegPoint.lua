----------------------------------------------------------------------------------------------------
--  Crytek Source File.
--  Copyright (C), Crytek Studios, 2010
----------------------------------------------------------------------------------------------------
--  $Id$
--  $DateTime$
--  Description: Visual Regression Point - used for visual regression tests, extends TagPoint
--
----------------------------------------------------------------------------------------------------
--  History:
--  - 11:6:2010   12:00 : Created by Christian Helmich
--
----------------------------------------------------------------------------------------------------

Script.ReloadScript("scripts/entities/AI/TagPoint.lua")

VisRegPoint = new(TagPoint);
VisRegPoint.type = "VisRegPoint";
VisRegPoint.Editor = {
		Icon = "VisRegPoint.bmp",
		Model= "Editor/Objects/Particles.cgf",
	};

-------------------------------------------------------
function VisRegPoint:OnInit()
end


function VisRegPoint:OnMove()
	TagPoint.OnMove(self);
end


function VisRegPoint:OnReset()
	TagPoint.OnReset(self);
end


function VisRegPoint:Input_pos(params, pos)
	TagPoint.Input_pos(self, params, pos);
end


function VisRegPoint:Input_rotate(params, rotation)
	TagPoint.Input_rotate(self, params, rotation);
end


function VisRegPoint:Input_scale(params, scale)
	TagPoint.Input_scale(self, params, scale);
end


function VisRegPoint:Output_pos()
	TagPoint.Output_pos(self);
end


function VisRegPoint:Output_rotate()
	TagPoint.Output_rotate(self);
end


function VisRegPoint:Output_scale()
	TagPoint.Output_scale(self);
end


function VisRegPoint:Output_Directions()
	TagPoint.Output_Directions(self);
end



VisRegPoint.FlowEvents =
{
	Inputs =
	{
		pos     = { VisRegPoint.Input_pos,    "vec3" },
		rotate  = { VisRegPoint.Input_rotate, "vec3" },
		scale   = { VisRegPoint.Input_scale,  "vec3" },
	},

	Outputs =
	{
		pos      = "vec3",
		rotate   = "vec3",
		scale    = "vec3",
		
		fwdDir   = "vec3",
		rightDir = "vec3",
		upDir    = "vec3",
	},
}
