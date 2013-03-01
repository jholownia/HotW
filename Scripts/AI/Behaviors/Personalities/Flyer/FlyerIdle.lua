local fMinUpdateTime = 0.4;

FlyerIdleBehavior = CreateAIBehavior("FlyerIdle",
{
	--------------------------------------------------------------------------
	Constructor = function(self, entity)
		entity.AI.vZero = { x = 0, y = 0, z = 0 };
		AI.SetForcedNavigation(entity.id, entity.AI.vZero);

		entity.AI.vUp = { x = 0, y = 0, z = 1 };

		entity.AI.vLastEnemyPos = {};
		entity.AI.vTargetPos = {};

		AI.CreateGoalPipe("Flyer_LookAtAttTarget");
		AI.PushGoal("Flyer_LookAtAttTarget", "locate",  0, "atttarget");
		AI.PushGoal("Flyer_LookAtAttTarget", "+lookat", 0, 0, 0, true, 1);
		AI.PushGoal("Flyer_LookAtAttTarget", "timeout", 1, 60);

		AI.CreateGoalPipe("Flyer_LookAtRefPoint");
		AI.PushGoal("Flyer_LookAtRefPoint", "locate",  0, "refpoint");
		AI.PushGoal("Flyer_LookAtRefPoint", "+lookat", 0, 0, 0, true, 1);
		AI.PushGoal("Flyer_LookAtRefPoint", "timeout", 1, 60);

		entity.AI.state = 1;
		self:PATROL_START(entity);

		entity.AI.bUpdate = true;
		Script.SetTimerForFunction(fMinUpdateTime * 1000, "FlyerIdleBehavior.UPDATE", entity);
	end,

	--------------------------------------------------------------------------
	OnEnemyHeard = function(self, entity, distance)
		self:PATROL_START(entity);
	end,
	
	--------------------------------------------------------------------------
	OnEnemySeen = function(self, entity, distance)
		self:PATROL_START(entity);
	end,
	
	--------------------------------------------------------------------------
	OnNoTarget = function(self, entity)
		self:PATROL_START(entity);
	end,
	
	--------------------------------------------------------------------------
	UPDATE = function(entity)
		if (not entity.id) then
			return;
		end
		
		local myEntity = System.GetEntity(entity.id);
		if (not myEntity) then
			return;
		end
		
		if ((entity.AI == nil) or (not entity.AI.bUpdate) or (entity:GetSpeed() == nil) or (not entity:IsActive())) then
			local vZero = { x = 0, y = 0, z = 0 };
			AI.SetForcedNavigation(myEntity.id, vZero);
			return;
		end

		entity.AI.bUpdate = true;
		Script.SetTimerForFunction(fMinUpdateTime * 1000, "FlyerIdleBehavior.UPDATE", entity);

		FlyerIdleBehavior:PATROL(entity);
	end,

	--------------------------------------------------------------------------
	-- Fly around entity.AI.vLastEnemyPos, 15 meters away
	--------------------------------------------------------------------------
	PATROL_START = function(self, entity)
		local attTarget = AI.GetAttentionTargetEntity(entity.id);
		if (attTarget) then
			CopyVector(entity.AI.vLastEnemyPos, attTarget:GetPos());		
		else
			CopyVector(entity.AI.vLastEnemyPos, entity:GetPos());		
		end		
		
		-- Calculate "from me to target" 2D vector (length = 15)
		local vTmp = {};
		CopyVector(vTmp, entity.AI.vLastEnemyPos);
		SubVectors(vTmp, vTmp, entity:GetPos());
		if (LengthSqVector(vTmp) < 1) then
			CopyVector(vTmp, entity:GetDirectionVector(1));
		end
		vTmp.z = 0;
		NormalizeVector(vTmp);
		if (entity.AI.state == 1) then
			FastScaleVector(vTmp, vTmp, 15);
		else
			FastScaleVector(vTmp, vTmp, -15);
		end

		-- Fly past the enemy
		FastSumVectors(entity.AI.vTargetPos, vTmp, entity.AI.vLastEnemyPos);

		entity.AI.stateEntryTime = System.GetCurrTime();
	
		entity:SelectPipe(0, "do_nothing");
		if (attTarget) then
			entity:SelectPipe(0, "Flyer_LookAtAttTarget");
		else
			-- Descrease my height by 3 meters
			CopyVector(vTmp, entity:GetPos());
			vTmp.x = entity.AI.vTargetPos.x;
			vTmp.y = entity.AI.vTargetPos.y;
			vTmp.z = vTmp.z - 3;
			AI.SetRefPointPosition(entity.id, vTmp);
			entity:SelectPipe(0, "Flyer_LookAtRefPoint");
		end
	end,

	--------------------------------------------------------------------------
	PATROL = function(self, entity)
		-- Calculate "from target to me" 2D vector (length = 15)
		local dir15 = {};
		local pos = {};
		CopyVector(pos, entity:GetPos());
		SubVectors(dir15, pos, entity.AI.vTargetPos);
		if (LengthSqVector(dir15) < 1) then
			CopyVector(dir15, entity:GetDirectionVector(1));
		end
		dir15.z = 0;
		NormalizeVector(dir15);
		FastScaleVector(dir15, dir15, 15);

		-- Rotate the "from target to me" 2D vector by 10 degrees
		local vForcedNav = {};
		local actionAngle = 10 * 3.1416 / 180;
		RotateVectorAroundR(vForcedNav, dir15, entity.AI.vUp, actionAngle * fMinUpdateTime * -1);

		-- Go to the end of the rotated vector
		FastSumVectors(vForcedNav, vForcedNav, entity.AI.vTargetPos);
		SubVectors(vForcedNav, vForcedNav, pos);
		vForcedNav.z = 0;
		NormalizeVector(vForcedNav);
		FastScaleVector(vForcedNav, vForcedNav, 5);

		-- Fly 15-30 meters about the target
		if (pos.z > entity.AI.vLastEnemyPos.z + 30) then
			vForcedNav.z = -5;
		end
		if (pos.z < entity.AI.vLastEnemyPos.z + 15) then
			vForcedNav.z = 3;
		end

		self:AvoidObstacles(entity, vForcedNav);
		
		AI.SetForcedNavigation(entity.id, vForcedNav);

		if (System.GetCurrTime() - entity.AI.stateEntryTime > 20) then
			entity.AI.state = 3 - entity.AI.state;
			self:PATROL_START(entity);
		end
	end,

	--------------------------------------------------------------------------
	AvoidObstacles = function(self, entity, vForcedNav)
		-- Calculate prospective velocity
		local vel = {};
		entity:GetVelocity(vel);
		FastSumVectors(vel, vel, vForcedNav);

		local vPeak = {};
		local pos = {};
		CopyVector(pos, entity:GetPos());
		CopyVector(vPeak, AI.IsFlightSpaceVoidByRadius(pos, vel, 2.5));	-- Here, Flight Navigation data are used

		if (LengthVector(vPeak) < 0.001) then
			return;
		end

		-- Fly over peaks

		if (vPeak.z > pos.z) then
			if (vPeak.z - pos.z < 100.0) then
				vForcedNav.x = (vPeak.x - pos.x) * 0.5;
				vForcedNav.y = (vPeak.y - pos.y) * 0.5;
				vForcedNav.z = 0;
				
				local length2d = LengthVector(vForcedNav);
				if (length2d > 16) then
					length2d = 16
				end
				NormalizeVector(vForcedNav);
				FastScaleVector(vForcedNav, vForcedNav, length2d);
				vForcedNav.z = (vPeak.z - pos.z) * 3.5;
			end
		end

		if (vPeak.z < pos.z) then
			if ((pos.z - vPeak.z) < 5) then
				vForcedNav.z = 5 - (pos.z - vPeak.z);
			else
				vForcedNav.z = 0;
			end
		end
		
		vForcedNav.z = clamp(vForcedNav.z, -30, 30);
	end,
})
