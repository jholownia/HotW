--------------------------------------------------------------------------
--	Crytek Source File.
-- 	Copyright (C), Crytek Studios, 2001-2005.
--------------------------------------------------------------------------
--	$Id$
--	$DateTime$
--	Description: FlowGraph node which performs a camera shake
--  
--------------------------------------------------------------------------
--  History:
--  - 30/09/2005   : Created by Sascha Gundlach
--
--------------------------------------------------------------------------

CameraShake = {
	Category = "obsolete",
	Inputs = {{"t_Activate","bool"}, {"Position", "vec3"}, {"Distance","float"}, {"Radius","float"}, {"Strength","float"}, {"Duration","float"}, {"Frequency","float"}, {"RangeMin","float"}, {"RangeMax","float"}},
	Outputs = {{"Done","bool"}},
	Implementation=function(bActivate,vPosition,fDistance,fRadius,fStrength,fDuration,fFrequency,fRangeMin,fRangeMax)
		g_gameRules:ClientViewShake(nil,fDistance,fRangeMin,fRangeMax,fStrength,fDuration,fFrequency);
		Script.SetTimer(fDuration*1000,function() return 1;end);
	end;
} 


