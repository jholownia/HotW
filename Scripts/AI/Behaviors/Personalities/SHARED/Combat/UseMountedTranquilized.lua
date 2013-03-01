--------------------------------------------------------------------------
--	Crytek Source File.
-- 	Copyright (C), Crytek Studios, 2001-2004.
--------------------------------------------------------------------------
--   Description: Guy falls asleep while using a MG
--  Same as HBaseTranquilized, except that he goes back to use MG after
--------------------------------------------------------------------------
--  History:
--  - Aug 2006   : Created by Luciano Morpurgo
--------------------------------------------------------------------------



local Behavior = CreateAIBehavior("UseMountedTranquilized", "HBaseTranquilized",
{
	Alertness = 0,
	exclusive = 1,
})