-- AI_Utils - Common AI utility functions.
-- Created by Mikko
--------------------------


AI_Utils = {
}

function AI_Utils:CamperCheckProtectSpot(entity, range)
	if(not entity.AI.protectSpot) then
		local anchorName = AI.FindObjectOfType(entity:GetPos(), range, AIAnchorTable.COMBAT_PROTECT_THIS_POINT);
		if(anchorName) then
			local spot = System.GetEntityByName(anchorName);
			if(spot) then
				entity.AI.protectSpot = spot:GetPos();
			end
		end
		if(not entity.AI.protectSpot) then
			entity.AI.protectSpot = AI.GetNearestHidespot(entity.id, 0, range);
		end
	end
end

function AI_Utils:VerifyGroupBlackBoard(groupId)
	if (not AIBlackBoard[groupId]) then
		AIBlackBoard[groupId] = {};
	end
end

function AI_Utils:IncGroupDeadCount(entity)
	local groupId = AI.GetGroupOf(entity.id);
	AI_Utils:VerifyGroupBlackBoard(groupId);
	
	if (not AIBlackBoard[groupId].deadCount) then
		AIBlackBoard[groupId].deadCount = 0;
	end
	
	AIBlackBoard[groupId].deadCount = AIBlackBoard[groupId].deadCount + 1;
end

function AI_Utils:GetGroupDeadCount(entity)
	local groupId = AI.GetGroupOf(entity.id);
	AI_Utils:VerifyGroupBlackBoard(groupId);
	
	if (not AIBlackBoard[groupId].deadCount) then
		AIBlackBoard[groupId].deadCount = 0;
	end

	return AIBlackBoard[groupId].deadCount;
end

---------------------------------------------
function AI_Utils:CheckThreatened(entity, time)

	entity.AI.checkThreatenTime = time;
	entity:DrawWeaponNow();

	-- one guy approaches directly, others approach to a nearby cover.
	local groupId = AI.GetGroupOf(entity.id);

	AI_Utils:VerifyGroupBlackBoard(groupId);		

	if (not AIBlackBoard[groupId].lastThreatPos) then
		AIBlackBoard[groupId].lastThreatPos = {x=0, y=0, z=0};
		AIBlackBoard[groupId].lastCheckedTime = 0;
	end

	local target = AI.GetTargetType(entity.id);
	
	local	attPos = g_Vectors.temp_v1;
	if(target == AITARGET_NONE) then
		AI.GetBeaconPosition(entity.id, attPos);		
	else
		AI.GetAttentionTargetPosition(entity.id, attPos);
	end
--	AI.GetBeaconPosition(entity.id, attPos);		

	local dist = DistanceVectors(attPos, AIBlackBoard[groupId].lastThreatPos);
	local dt = _time - AIBlackBoard[groupId].lastCheckedTime;

--	if(not entity.AI.target) then
--		entity.AI.target = {x=0, y=0, z=0};
--	end

	if (AI_Utils:IsTargetOutsideStandbyRange(entity) == 0) then

		AI.SetRefPointPosition(entity.id, attPos);
		entity:SelectPipe(0,"cv_investigate_threat"); 
		CopyVector(AIBlackBoard[groupId].lastThreatPos, attPos);
		AIBlackBoard[groupId].lastCheckedTime = _time;

--		AI_Utils:CheckThreatened(entity, 15.0);

	else
		entity:SelectPipe(0,"sn_look_closer_standby");
	end


--	if(entity.AI.StandbyShape) then
--		CopyVector(attPos, AI.ConstrainPointInsideGenericShape(attPos, entity.AI.StandbyShape, 1));
--	end
--	if(entity.AI.TerritoryShape) then
--		CopyVector(attPos, AI.ConstrainPointInsideGenericShape(attPos, entity.AI.TerritoryShape, 1));
--	end
	
--	AI.SetRefPointPosition(entity.id, attPos);
--
--	CopyVector(entity.AI.target, attPos);

--	AI.LogEvent(entity:GetName().." dist="..dist.." dt="..dt);

--	if(dist > 3.0 or dt > 7.0) then
--	if (dt > 7.0) then
		-- approach directly
--		AI.LogEvent(entity:GetName().." cover_investigate_threat");

--		entity:SelectPipe(0,"cv_investigate_threat"); 
--		CopyVector(AIBlackBoard[groupId].lastThreatPos, attPos);
--		AIBlackBoard[groupId].lastCheckedTime = _time;
		
--	else
		-- approach at distance
--		entity:SelectPipe(0,"cv_investigate_threat_far"); 
--	end

	entity:GettingAlerted();
end


---------------------------------------------
function AI_Utils:CheckInterested(entity)

	entity:DrawWeaponNow( 1 );	-- make sure to draw primary weapon
	local groupId = AI.GetGroupOf(entity.id);
	AI_Utils:VerifyGroupBlackBoard(groupId);		

	if (not AIBlackBoard[groupId].lastCheckedPos) then
		AIBlackBoard[groupId].lastCheckedPos = {x=0, y=0, z=0};
		AIBlackBoard[groupId].lastCheckedTime = 0;
	end
	
	local	attPos = g_Vectors.temp_v1;
	
	if(AI.GetTargetType(entity.id)==AITARGET_NONE) then
		AI.GetBeaconPosition(entity.id, attPos);
	else
		AI.GetAttentionTargetPosition(entity.id, attPos);
	end
	
	local dist = DistanceVectors(attPos, AIBlackBoard[groupId].lastCheckedPos);
	local dt = _time - AIBlackBoard[groupId].lastCheckedTime;

	if(not entity.AI.target) then
		entity.AI.target = {x=0, y=0, z=0};
	end

	CopyVector(entity.AI.target, attPos);

--	if(dist > 3.0 or dt > 3.0) then
		-- The position has moved or enough time has passed.

		if(entity.AI.StandbyShape) then
			CopyVector(attPos, AI.ConstrainPointInsideGenericShape(attPos, entity.AI.StandbyShape, 1));
		end
		if(entity.AI.TerritoryShape) then
			CopyVector(attPos, AI.ConstrainPointInsideGenericShape(attPos, entity.AI.TerritoryShape, 1));
		end
		AI.SetRefPointPosition(entity.id, attPos);

		entity:SelectPipe(0,"cv_look_closer");
		CopyVector(AIBlackBoard[groupId].lastCheckedPos, attPos);
		AIBlackBoard[groupId].lastCheckedTime = _time;
		
		-- MTJ 12/10/09 - Used to always return true, now refactored out
end


---------------------------------------------
function AI_Utils:ReactToDanger(entity, dangerPos)

	entity:MakeAlerted();

	entity.AI.grenadeDist = AI.SetRefPointToGrenadeAvoidTarget(entity.id, dangerPos, 15.0);
	if (entity.AI.grenadeDist > 0.0) then
		AI.Signal(SIGNALFILTER_SENDER,1,"GO_TO_AVOIDEXPLOSIVES",entity.id);
		return true;
	end
	
	return false;
end

---------------------------------------------
function AI_Utils:CheckInterestedAlien(entity)

	entity:DrawWeaponNow();	
	local groupId = AI.GetGroupOf(entity.id);
	AI_Utils:VerifyGroupBlackBoard(groupId);

	if (not AIBlackBoard[groupId].lastCheckedPos) then
		AIBlackBoard[groupId].lastCheckedPos = {x=0, y=0, z=0};
		AIBlackBoard[groupId].lastCheckedTime = 0;
	end
	
	local	attPos = g_Vectors.temp_v1;
	
	if(AI.GetTargetType(entity.id)==AITARGET_NONE) then
		AI.GetBeaconPosition(entity.id, attPos);
	else
		AI.GetAttentionTargetPosition(entity.id, attPos);
	end
	
	local dist = DistanceVectors(attPos, AIBlackBoard[groupId].lastCheckedPos);
	local dt = _time - AIBlackBoard[groupId].lastCheckedTime;

	if(not entity.AI.target) then
		entity.AI.target = {x=0, y=0, z=0};
	end

	CopyVector(entity.AI.target, attPos);

	if(dist > 10.0 or dt > 5.0) then
		-- The position has moved or enough time has passed.
		entity:SelectPipe(0,"gr_investigate_interested");
		CopyVector(AIBlackBoard[groupId].lastCheckedPos, attPos);
		AIBlackBoard[groupId].lastCheckedTime = _time;
		return true;
	else
		entity:SelectPipe(0,"gr_lookat_interested");
		return false;
	end
end

---------------------------------------------
function AI_Utils:AlienMeleePush(entity, enemy, amount)
	local hitDir = entity:GetDirectionVector(0);
	local dirToEnemy = g_Vectors.temp_v1;
	SubVectors(dirToEnemy, enemy:GetPos(), entity:GetPos());

	local	ang = math.pi*0.1;

	if (dotproduct3d(hitDir, dirToEnemy) < 0) then
		NegVector(hitDir);
		ang = -ang;
	end

	local damage = 130;
	local shakeAmount = 80;
	if (AI.IsAgentInTargetFOV(entity.id, 50.0) == 1) then
		damage = 50;
		shakeAmount = 40;
	end

	g_gameRules:CreateHit(enemy.id,entity.id,entity.id,damage,nil,nil,nil,"melee");
	BasicActor.DoPainSounds(enemy);

	if (enemy.actor) then
		enemy.actor:CameraShake(shakeAmount, 0.5, 0.1, g_Vectors.v000);
		enemy.actor:AddAngularImpulse({x=randomF(-math.pi*0.0021,math.pi*0.0021),y=0,z=ang},0.0,2.5);
	end
end

---------------------------------------------
function AI_Utils:AlienScareSound(entity)
	local dist = AI.GetAttentionTargetDistance(entity.id);
	if(AI.IsAgentInTargetFOV(entity.id, 50.0)) then
		if(dist and dist < 7) then
			entity:Readibility("scare_close", 1,2, 0.1,0.3);
		else
			entity:Readibility("scare", 1,2, 0.1,0.3);
		end
	else
		if(dist and dist < 7) then
			entity:Readibility("hiss",1);
		else
			entity:Readibility("taunt", 1,2, 0.1,0.3);
		end
	end
end

---------------------------------------------
function AI_Utils:HasRPGAttackSlot(entity)
	local groupId = AI.GetGroupOf(entity.id);
	AI_Utils:VerifyGroupBlackBoard(groupId);

	if (not AIBlackBoard[groupId].RPGAttackCount) then
		AIBlackBoard[groupId].RPGAttackCount = 0;
	end

	if(AIBlackBoard[groupId].RPGAttackCount < 2) then
		return true;
	else
		return false;
	end
end

---------------------------------------------
function AI_Utils:ChangeRPGAttackSlot(entity, amount)
	local groupId = AI.GetGroupOf(entity.id);
	AI_Utils:VerifyGroupBlackBoard(groupId);

	if (not AIBlackBoard[groupId].RPGAttackCount) then
		AIBlackBoard[groupId].RPGAttackCount = 0;
	end

	AIBlackBoard[groupId].RPGAttackCount = AIBlackBoard[groupId].RPGAttackCount + amount;
end

---------------------------------------------
function AI_Utils:IsTargetOutsideStandbyRange(entity)
	-- check if should not stand by at all.
--	if(not entity.AI.StandbyValid) then
--		return 0;
--	end;

	local	attPos = g_Vectors.temp_v1;
	if(AI.GetTargetType(entity.id)==AITARGET_NONE) then
		if(not AI.GetBeaconPosition(entity.id, attPos)) then
			return 0;
		end
	else
		AI.GetAttentionTargetPosition(entity.id, attPos);
	end

	if(entity.AI.StandbyShape) then
		if(AI.IsPointInsideGenericShape(attPos, entity.AI.StandbyShape, 0) == 0) then
			return 1;
		end
	end

	if(entity.AI.TerritoryShape) then
		if(AI.IsPointInsideGenericShape(attPos, entity.AI.TerritoryShape, 0) == 0) then
			return 1;
		end
	end

	return 0;
end

---------------------------------------------
function AI_Utils:IsTargetOutsideTerritory(entity)
	-- check if should not stand by at all.
	if(not entity.AI.TerritoryShape) then
		return 0;
	end;

	local	attPos = g_Vectors.temp_v1;
	if(AI.GetTargetType(entity.id)==AITARGET_NONE) then
		if(not AI.GetBeaconPosition(entity.id, attPos)) then
			return 0;
		end
	else
		AI.GetAttentionTargetPosition(entity.id, attPos);
	end

	if(entity.AI.TerritoryShape) then
		if(AI.IsPointInsideGenericShape(attPos, entity.AI.TerritoryShape, 0) == 0) then
			return 1;
		end
	end

	return 0;
end

---------------------------------------------
function AI_Utils:SetupTerritory(entity)
	-- (evgeny 25 Sep 2009) Setup Wave as a bonus (but let's keep the original function name)

	local territory = entity.PropertiesInstance.AITerritoryAndWave.aiterritory_Territory;
	if (territory == "<None>") then
		AI.SetTerritoryShapeName(entity.id, "<None>");
		entity.AI.TerritoryShape = nil;
		entity.AI.Wave           = nil;
		return;
	end
	
	if ((not territory) or (territory == "") or (territory == "<Auto>")) then
		territory = AI.GetEnclosingGenericShapeOfType(entity:GetPos(), AIAnchorTable.COMBAT_TERRITORY, 1);
	end
	
	if (territory and (territory ~= "")) then
		AI.SetTerritoryShapeName(entity.id, territory);
	else
		AI.SetTerritoryShapeName(entity.id, "<None>");
		entity.AI.TerritoryShape = nil;
		entity.AI.Wave           = nil;
		return;
	end
	entity.AI.TerritoryShape = territory;

	local wave = entity.PropertiesInstance.AITerritoryAndWave.aiwave_Wave;
	if ((wave == "<None>") or (wave == "")) then
		wave = nil;
	end
	entity.AI.Wave = wave;

	AddToTerritoryAndWave(entity);
end

---------------------------------------------
function AI_Utils:SetupStandby(entity, force)
	-- Setup standby.
	entity.AI.StandbyShape = AI.GetEnclosingGenericShapeOfType(entity:GetPos(), AIAnchorTable.ALERT_STANDBY_IN_RANGE, 0);

	if(force and force == true and not entity.AI.StandbyShape) then
		entity.AI.StandbyShape = AI.CreateTempGenericShapeBox(entity:GetPos(), 15, 0, AIAnchorTable.ALERT_STANDBY_IN_RANGE);
	end

	if(entity.AI.StandbyShape) then
		AI.SetRefShapeName(entity.id, entity.AI.StandbyShape);
	else
		AI.SetRefShapeName(entity.id, "");
	end
end

---------------------------------------------
function AI_Utils:IsTargetFound(entity)
	local groupId = AI.GetGroupOf(entity.id);
	AI_Utils:VerifyGroupBlackBoard(groupId);
	
	if (not AIBlackBoard[groupId].targetFound) then
		AIBlackBoard[groupId].targetFound = 0;
	end
	
	return AIBlackBoard[groupId].targetFound;
end

---------------------------------------------
function AI_Utils:SetTargetFound(entity, val)
	local groupId = AI.GetGroupOf(entity.id);
	AI_Utils:VerifyGroupBlackBoard(groupId);
	AIBlackBoard[groupId].targetFound = val;
end


---------------------------------------------
function AI_Utils:GetLastSignalTime(entity)
	local groupId = AI.GetGroupOf(entity.id);
	AI_Utils:VerifyGroupBlackBoard(groupId);
	
	if (not AIBlackBoard[groupId].lastSignalTime) then
		AIBlackBoard[groupId].lastSignalTime = _time-100;
	end
	
	return AIBlackBoard[groupId].lastSignalTime;
end

---------------------------------------------
function AI_Utils:SetLastSignalTime(entity, val)
	local groupId = AI.GetGroupOf(entity.id);
	AI_Utils:VerifyGroupBlackBoard(groupId);
	AIBlackBoard[groupId].lastSignalTime = val;
end


---------------------------------------------
function AI_Utils:CanThrowGrenade(entity, smokeOnly)

	if (not AIBlackBoard.lastGrenadeTime) then
		AIBlackBoard.lastGrenadeTime = _time - 20;
	end

	local dt = _time - AIBlackBoard.lastGrenadeTime;
	if (dt < 9) then
--		System.Log(">>TIME! "..dt);
		return 0;
	end

	-- no need for distance/target checks if throwing smoke grenade (should be controlled by level setup)
	if(smokeOnly == nil)then
		local targetType = AI.GetTargetType(entity.id);
		if (targetType ~= AITARGET_MEMORY and targetType ~= AITARGET_ENEMY) then
	--		System.Log(">>BAD TARGET ");
			return 0;
		end
	
		local targetDist = AI.GetAttentionTargetDistance(entity.id);
		if (targetDist < 10.0 or targetDist > 45.0) then
	--		System.Log(">>BAD DISTANCE "..targetDist);
			return 0;
		end
	end
	local genadesWeaponId = entity.inventory:GetGrenadeWeaponByClass("AIGrenades");
	
	if(smokeOnly) then
		genadesWeaponId = entity.inventory:GetGrenadeWeaponByClass("AISmokeGrenades");
		if (genadesWeaponId==nil) then
--			System.Log(">>NO GRENADES!");
			return 0;
		end
	else
		if (genadesWeaponId==nil) then
			genadesWeaponId = entity.inventory:GetGrenadeWeaponByClass("AIFlashbangs");
			if (genadesWeaponId==nil) then
				return 0;
--				genadesWeaponId = entity.inventory:GetGrenadeWeaponByClass("AISmokeGrenades");
--				if (genadesWeaponId==nil) then
		--			System.Log(">>NO GRENADES!");
--					return 0;
--				end
			end
		end	
	end
		
	local genadesWeapon = System.GetEntity(genadesWeaponId);
	if (genadesWeapon==nil) then
--		System.Log(">>NO WEAPON!");
		return 0;
	end
	if (genadesWeapon.weapon:GetAmmoCount() <= 0) then
--		System.Log(">>NO AMMO!");
		return 0;
	end

	AIBlackBoard.lastGrenadeTime = _time;

	return 1;

end

---------------------------------------------
function AI_Utils:CanThrowSmokeGrenade(entity)

	if (not AIBlackBoard.lastSmokeGrenadeTime) then
		AIBlackBoard.lastSmokeGrenadeTime = _time - 40;
	end

	local dt = _time - AIBlackBoard.lastSmokeGrenadeTime;
	if (dt < 30) then
--		System.Log(">>TIME! "..dt);
		return 0;
	end

	-- no need for distance/target checks if throwing smoke grenade (should be controlled by level setup)
	local targetType = AI.GetTargetType(entity.id);
	if (targetType ~= AITARGET_MEMORY and targetType ~= AITARGET_ENEMY) then
--		System.Log(">>BAD TARGET ");
		return 0;
	end

	local targetDist = AI.GetAttentionTargetDistance(entity.id);
	if (targetDist < 20.0 or targetDist > 60.0) then
--		System.Log(">>BAD DISTANCE "..targetDist);
		return 0;
	end

	local genadesWeaponId = entity.inventory:GetGrenadeWeaponByClass("AISmokeGrenades");
	if (genadesWeaponId==nil) then
		return 0;
	end
	local genadesWeapon = System.GetEntity(genadesWeaponId);
	if (genadesWeapon==nil) then
--		System.Log(">>NO WEAPON!");
		return 0;
	end
	if (genadesWeapon.weapon:GetAmmoCount() <= 0) then
--		System.Log(">>NO AMMO!");
		return 0;
	end

	AIBlackBoard.lastSmokeGrenadeTime = _time;

	return 1;

end

---------------------------------------------
function AI_Utils:ChooseStuntReaction(entity)
	local	attPos = g_Vectors.temp_v1;
	AI.GetAttentionTargetPosition(entity.id, attPos);

	local dir = AI.GetDirLabelToPoint(entity.id, attPos);
	if (not dir or dir == 0) then
		entity:SelectPipe(0,"sn_panic_front");
--		System.Log(" -->FRONT");
	elseif (dir == 1) then
		entity:SelectPipe(0,"sn_panic_front");
--		System.Log(" -->BACK");
	elseif (dir == 2) then
		entity:SelectPipe(0,"sn_panic_left");
--		System.Log(" -->LEFT");
	elseif (dir == 3) then
		entity:SelectPipe(0,"sn_panic_right");
--		System.Log(" -->RIGHT");
	else
		if (AI.GetAttentionTargetDistance(entity.id) < 10.0) then
			entity:SelectPipe(0,"sn_panic_aboveFire");
		else
			entity:SelectPipe(0,"sn_panic_above");
		end
--		System.Log(" -->UP");
	end
end


---------------------------------------------
function AI_Utils:ChooseFlinchReaction(entity, pos)
	local dir = AI.GetDirLabelToPoint(entity.id, pos);
	if (not dir or dir == 0) then
		entity:SelectPipe(0,"sn_flinch_front");
--		System.Log(" -->FRONT");
	elseif (dir == 1) then
		entity:SelectPipe(0,"sn_flinch_front");
--		System.Log(" -->BACK");
	elseif (dir == 2) then
		entity:SelectPipe(0,"sn_flinch_left");
--		System.Log(" -->LEFT");
	elseif (dir == 3) then
		entity:SelectPipe(0,"sn_flinch_right");
--		System.Log(" -->RIGHT");
	else
		entity:SelectPipe(0,"sn_flinch_above");
--		System.Log(" -->UP");
	end
end

---------------------------------------------
function AI_Utils:CommonContinueAfterReaction(entity)
	local target = AI.GetTargetType(entity.id);
	if (target == AITARGET_ENEMY) then
		AI.Signal(SIGNALFILTER_SENDER, 1, "TO_ATTACK",entity.id);
	elseif (target == AITARGET_MEMORY) then
		AI.Signal(SIGNALFILTER_SENDER, 1, "TO_SEEK",entity.id);
	else
		if(AI_Utils:IsTargetOutsideStandbyRange(entity) == 1) then
			entity.AI.hurryInStandby = 0;
			AI.Signal(SIGNALFILTER_SENDER, 1, "TO_THREATENED_STANDBY",entity.id);
		else
			AI.Signal(SIGNALFILTER_SENDER, 1, "TO_THREATENED",entity.id);
		end
	end
end

---------------------------------------------
function AI_Utils:CommonEnemySeen(entity, data)
	if (data.iValue == AITSR_SEE_STUNT_ACTION) then
		AI_Utils:ChooseStuntReaction(entity);
	elseif (data.iValue == AITSR_SEE_CLOAKED) then
		entity:SelectPipe(0,"sn_target_cloak_reaction");
	else
		local dist = AI.GetAttentionTargetDistance(entity.id);

		if (entity.AI.firstContact) then
			entity:Readibility("first_contact",1,3, 0.1,0.4);
			AI.Signal(SIGNALFILTER_GROUPONLY_EXCEPT, 1, "ENEMYSEEN_FIRST_CONTACT",entity.id);
		else
			entity:Readibility("during_combat",1,3, 0.1,0.4);
			AI.Signal(SIGNALFILTER_GROUPONLY_EXCEPT, 1, "ENEMYSEEN_DURING_COMBAT",entity.id);
		end
			-- BT-based behaviours such as Cover3 will ignore this
		AI.Signal(SIGNALFILTER_SENDER, 1, "TO_ATTACK",entity.id);
	end
end

---------------------------------------------
function AI_Utils:IsUnitStuntAllowed(entity)
	local groupId = AI.GetGroupOf(entity.id);
	AI_Utils:VerifyGroupBlackBoard(groupId);
	
	if (not AIBlackBoard[groupId].lastStuntTime) then
		AIBlackBoard[groupId].lastStuntTime = _time - 20;
	end
	
	local dt = _time - AIBlackBoard[groupId].lastStuntTime;

	if (dt > 15.0) then
		AIBlackBoard[groupId].lastStuntTime = _time;
		return 1;
	end
	return 0;
end
