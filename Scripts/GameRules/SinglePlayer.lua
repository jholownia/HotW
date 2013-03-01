--------------------------------------------------------------------------
--	Crytek Source File.
-- 	Copyright (C), Crytek Studios, 2001-2004.
--------------------------------------------------------------------------
--	$Id$
--	$DateTime$
--	Description: GameRules implementation for Death Match
--  
--------------------------------------------------------------------------
--  History:
--  - 22/ 9/2004   16:20 : Created by Mathieu Pinard
--  - 04/10/2004   10:43 : Modified by Craig Tiller
--  - 07/10/2004   16:02 : Modified by Marcio Martins
--
--------------------------------------------------------------------------

SinglePlayer = {
	DamagePlayerToAI =
	{
		helmet		= 4.0,
		kevlar		= 0.75,

		head 			= 50.0,
		torso 		= 1.2,
		arm_left	= 0.65,
		arm_right	= 0.65,
		hand_left	= 0.3,
		hand_right= 0.3,
		leg_left	= 0.65,
		leg_right	= 0.65,
		foot_left	= 0.3,
		foot_right= 0.3,
		assist_min	=0.8,
	},
	
	DamagePlayerToPlayer=
	{
		helmet		= 4.0,
		kevlar		= 0.45,

		head 			= 20.0,
		torso 		= 1.4,
		arm_left	= 0.65,
		arm_right	= 0.65,
		hand_left	= 0.3,
		hand_right= 0.3,
		leg_left	= 0.65,
		leg_right	= 0.65,
		foot_left	= 0.3,
		foot_right= 0.3,
		assist_min	=0.8,
	},
	
	DamageAIToPlayer=
	{
		helmet		= 1.0,
		kevlar		= 0.45,

		head 			= 1.0,
		torso 		= 1.0,
		arm_left	= 0.65,
		arm_right	= 0.65,
		hand_left	= 0.3,
		hand_right= 0.3,
		leg_left	= 0.65,
		leg_right	= 0.65,
		foot_left	= 0.3,
		foot_right= 0.3,
		assist_min	=0.8,
	},
	
	DamageAIToAI=
	{
		helmet		= 4.0,
		kevlar		= 0.75,

		head 			= 20.0,
		torso 		= 1.0,
		arm_left	= 0.65,
		arm_right	= 0.65,
		hand_left	= 0.3,
		hand_right= 0.3,
		leg_left	= 0.65,
		leg_right	= 0.65,
		foot_left	= 0.3,
		foot_right= 0.3,
		assist_min	=0.8,
	},
	

	tempVec = {x=0,y=0,z=0},
	playerDeathLocations = {},
	lastSaveName = "",
	lastSaveDeathCount = 0,
	hudWhite = { x=1, y=1, z=1},
	canResurrect = false;
	hud_prefab = "Prefabs/hud.xml";

	Client = {},
	Server = {},
	
	-- this table is used to track the available entities where we can spawn the
	-- player
	spawns = {},
}


----------------------------------------------------------------------------------------------------
function SinglePlayer:IsMultiplayer()
	return false;
end


----------------------------------------------------------------------------------------------------
function SinglePlayer:OnReset(toGame)  
	AIReset();
end


----------------------------------------------------------------------------------------------------
function SinglePlayer:InitHitMaterials()
	local mats={
		"mat_head",
		"mat_torso",
		"mat_arm_left",
		"mat_arm_right",
		"mat_hand_left",
		"mat_hand_right",
		"mat_leg_left",
		"mat_leg_right",
		"mat_foot_left",
		"mat_foot_right",

	};
	
	for i,v in ipairs(mats) do
		self.game:RegisterHitMaterial(v);
	end
	
end


----------------------------------------------------------------------------------------------------
function SinglePlayer:InitHitTypes()
	local types={
		"normal",
		"melee",
		"bullet",
		"aacannon",
		"rocket",
		"frag",
		"explosion",
		"fire",
		"fall",
		"collision",
		"disableCollisions",
		"event",
		"punish",
		"repair"
	};

	for i,v in ipairs(types) do
		self.game:RegisterHitType(v);
	end
	
	-- cache
	g_collisionHitTypeId = self.game:GetHitTypeId("collision");
end


----------------------------------------------------------------------------------------------------
function SinglePlayer:IsHeadShot(hit)
	return hit.material_type and ((hit.material_type == "head") or (hit.material_type == "helmet")) or false;
end


----------------------------------------------------------------------------------------------------
function SinglePlayer:CalcDamage(material_type, damage, tbl, assist)
	if (damage and damage~=0) then
		if (material_type and tbl) then
			local mult = tbl[material_type] or 1;
			local asm = assist*tbl["assist_min"];
			if (mult < asm) then
				mult=asm;
			end
			
			--if (assist > 0) then
			--	Log(">> SinglePlayer:CalcDamage assisted mult=(%f) <<", mult);
			--else
			--	Log(">> SinglePlayer:CalcDamage non-assisted mult=(%f) <<", mult);
			--end	
			
			return damage*mult;
		end
		return damage;
	end

	return 0;
end


----------------------------------------------------------------------------------------------------
function SinglePlayer:CalcExplosionDamage(entity, explosion, obstruction)
	-- impact explosions directly damage the impact target
	if (explosion.impact and explosion.impact_targetId and explosion.impact_targetId==entity.id) then
		return explosion.damage;
	end

	local effect=1;
	if (not entity.vehicle) then
		local distance=vecLen(vecSub(entity:GetWorldPos(), explosion.pos));
		if (distance<=explosion.min_radius or explosion.min_radius==explosion.radius) then
			effect=1;
		else
			distance=math.max(0, math.min(distance, explosion.radius));
			local r=explosion.radius-explosion.min_radius;
			local d=distance-explosion.min_radius;
			effect=(r-d)/r;
			effect=math.max(math.min(1, effect*effect), 0);
		end

		effect=effect*(1-obstruction);
		
		if(entity.actor and entity.actor:GetPhysicalizationProfile() == "sleep") then
			return explosion.damage*2*effect; --sleeping targets get more damage
		end
	else
		effect=1-obstruction;
	end
	
	if (explosion.type == "emp") then
		self.game:ProcessEMPEffect(entity.id, effect);
	end
	
	return explosion.damage*effect;
end


----------------------------------------------------------------------------------------------------
function SinglePlayer:EquipActor(actor)
	--Log(">> SinglePlayer:EquipActor(%s) <<", actor:GetName());
	
	if(self.game:IsDemoMode() ~= 0) then -- don't equip actors in demo playback mode, only use existing items
		--Log("Don't Equip : DemoMode");
		return;
	end;

	actor.inventory:Destroy();

	if (actor.actor:IsPlayer()) then
		ItemSystem.GiveItemPack(actor.id, "Singleplayer", false, true);
	end

	if (not actor.actor:IsPlayer()) then
		if (actor.Properties) then		
			local equipmentPack=actor.Properties.equip_EquipmentPack;
			if (equipmentPack and equipmentPack ~= "") then
				ItemSystem.GiveItemPack(actor.id, equipmentPack, false, false);
			end

	  	if(not actor.bGunReady) then
	  		actor:HolsterItem(true);
	  	end
	  end
	end
end


----------------------------------------------------------------------------------------------------
function SinglePlayer:OnShoot(shooter)
	if (shooter and shooter.OnShoot) then
		if (not shooter:OnShoot()) then
			return false;
		end
	end
	
	return true;
end

----------------------------------------------------------------------------------------------------
function SinglePlayer:IsUsable(srcId, objId)
	if not objId then return 0 end;

	local obj = System.GetEntity(objId);
	if (obj.IsUsable) then
		if (obj:IsHidden()) then
			return 0;
		end;
		local src = System.GetEntity(srcId);
		if (src and src.actor and (src:IsDead() or (src.actor:GetSpectatorMode()~=0) or src.actorStats.isFrozen)) then
			return 0;
		end
		return obj:IsUsable(src);
	end

	return 0;
end

function SinglePlayer:IsUsableMsgChanged(objId)
	local obj = System.GetEntity(objId);
	if (obj.IsUsableMsgChanged) then
		return obj:IsUsableMsgChanged();
	end
	return 0;
end
----------------------------------------------------------------------------------------------------
function SinglePlayer:OnNewUsable(srcId, objId, usableId)
	if not srcId then return end
	if objId and not System.GetEntity(objId) then objId = nil end
	
	local src = System.GetEntity(srcId)
	if src and src.SetOnUseData then
		src:SetOnUseData(objId or NULL_ENTITY, usableId)
	end

	if srcId ~= g_localActorId then return end

	if self.UsableMessage then
		HUD.SetInstructionObsolete(self.UsableMessage)
		self.UsableMessage = nil
	end
end


----------------------------------------------------------------------------------------------------
function SinglePlayer:OnUsableMessage(srcId, objId, objEntityId, usableId)
	if srcId ~= g_localActorId then return end
	
	local msg = "";
	
	if objId then
		obj = System.GetEntity(objId)
		if obj then

			if obj.GetUsableMessage then
				msg = obj:GetUsableMessage(usableId)
			else
				local state = obj:GetState()
				if state ~= "" then
					state = obj[state]
					if state.GetUsableMessage then
						msg = state.GetUsableMessage(obj, usableId)
					end
				end
			end
		end
	end
	
	
	if(UIAction) then
		UIAction.StartAction("DisplayUseText", {msg}); --this triggers the UIAction "DisplayUseText" and pass the msg as argument (see FlowGraph UIActions how to send msg to flash)
	end
end


----------------------------------------------------------------------------------------------------
function SinglePlayer:OnLongHover(srcId, objId)
end


----------------------------------------------------------------------------------------------------
function SinglePlayer:EndLevel( params )
	if (not System.IsEditor()) then		  
		if (not params.nextlevel) then		  
			Game.PauseGame(true);
			Game.ShowMainMenu();
		end
	end
end

----------------------------------------------------------------------------------------------------
function SinglePlayer:CreateExplosion(shooterId,weaponId,damage,pos,dir,radius,angle,pressure,holesize,effect,effectScale, minRadius, minPhysRadius, physRadius)
	if (not dir) then
		dir=g_Vectors.up;
	end
	
	if (not radius) then
		radius=5.5;
	end

	if (not minRadius) then
		minRadius=radius/2;
	end

	if (not physRadius) then
		physRadius=radius;
	end

	if (not minPhysRadius) then
		minPhysRadius=physRadius/2;
	end

	if (not angle) then
		angle=0;
	end
	
	if (not pressure) then
		pressure=200;
	end
	
	if (holesize==nil) then
    holesize = math.min(radius, 5.0);
	end
	
	if (radius == 0) then
		return;
	end
	self.game:ServerExplosion(shooterId or NULL_ENTITY, weaponId or NULL_ENTITY, damage, pos, dir, radius, angle, pressure, holesize, effect, effectScale, nil, minRadius, minPhysRadius, physRadius);
end

----------------------------------------------------------------------------------------------------
function SinglePlayer:CreateHit(targetId,shooterId,weaponId,dmg,radius,material,partId,type,pos,dir,normal)
	if (not radius) then
		radius=0;
	end
	
	local materialId=0;
	
	if (material) then
		materialId=self.game:GetHitMaterialId(material);
	end
	
	if (not partId) then
		partId=-1;
	end
	
	local typeId=0;
	if (type) then
		typeId=self.game:GetHitTypeId(type);
	else
		typeId=self.game:GetHitTypeId("normal");
	end
	
	self.game:ServerHit(targetId, shooterId, weaponId, dmg, radius, materialId, partId, typeId, pos, dir, normal);
end

----------------------------------------------------------------------------------------------------
function SinglePlayer:ClientViewShake(pos, distance, radiusMin, radiusMax, amount, duration, frequency, source, rnd)
	if (g_localActor and g_localActor.actor) then
		if (distance) then
			self:ViewShake(g_localActor, distance, radiusMin, radiusMax, amount, duration, frequency, source, rnd);
			return;
		end
		if (pos) then
			local delta = self.tempVec;
			CopyVector(delta,pos);
			FastDifferenceVectors(delta, delta, g_localActor:GetWorldPos());
			local dist = LengthVector(delta);
			self:ViewShake(g_localActor, dist, radiusMin, radiusMax, amount, duration, frequency, source, rnd);
			return;
		end
	end
end

----------------------------------------------------------------------------------------------------
function SinglePlayer:ViewShake(player, distance, radiusMin, radiusMax, amount, duration, frequency, source, rnd)
	local deltaDist = radiusMax - distance;
	rnd = rnd or 0.0;
	if (deltaDist > 0.0) then
		local r = math.min(1, deltaDist/(radiusMax-radiusMin));
		local amt = amount * r;
		local halfDur = duration * 0.5;
		player.actor:SetViewShake({x=2*g_Deg2Rad*amt, y=2*g_Deg2Rad*amt, z=2*g_Deg2Rad*amt}, {x=0.02*amt, y=0.02*amt, z=0.02*amt},halfDur + halfDur*r, 1/20, rnd);
		player.viewBlur = duration;
		player.viewBlurAmt = 0.5;
	end
end

----------------------------------------------------------------------------------------------------
function SinglePlayer:GetCollisionMinVelocity(entity, collider, hit)
	
	local minVel=10;
	
	if ((entity.actor and not entity.actor:IsPlayer()) or entity.advancedDoor) then
		minVel=1; --Door or character hit	
	end	
	
	if(entity.actor and collider and collider.vehicle) then
		minVel=6; -- otherwise we don't get damage at slower speeds
	end
	
	if(hit.target_velocity and vecLenSq(hit.target_velocity) == 0) then -- if collision target it not moving
		minVel = minVel * 2;
	end
	
	return minVel;
end

----------------------------------------------------------------------------------------------------
function SinglePlayer:GetCollisionDamageMult(entity, collider, hit)		
	
	local mult = 1;	
	local debugColl = self.game:DebugCollisionDamage();
	
	if (collider) then
  	if (collider.GetForeignCollisionMult) then
  	  
  	  local foreignMult = collider.GetForeignCollisionMult(collider, entity, hit);
  		mult = mult * foreignMult;
  		
  		if (debugColl>0 and foreignMult ~= 1) then  		  
  		  Log("<%s>: collider <%s> has ForeignCollisionMult %.2f", entity:GetName(), collider:GetName(), foreignMult);  		  
  		end  		
  	end  	   	
  end
  
	if (entity.GetSelfCollisionMult) then 
	  
	  local selfMult = entity.GetSelfCollisionMult(entity, collider, hit);
		mult = mult * selfMult;
		
		if (debugColl>0 and selfMult ~= 1) then		  
		  Log("<%s>: returned SelfCollisionMult %.2f", entity:GetName(), selfMult);		  
		end  	
	end		
	
	return mult;
end

----------------------------------------------------------------------------------------------------
function SinglePlayer:OnCollision(entity, hit)
	local collider = hit.target;
	local colliderMass = hit.target_mass; -- beware, collider can be null (e.g. entity-less rigid entities)
	local contactVelocitySq;
	local contactMass;

	-- check if frozen
	if (self.game:IsFrozen(entity.id)) then
		if ((not entity.CanShatter) or (tonumber(entity:CanShatter())~=0)) then
			local energy = self:GetCollisionEnergy(entity, hit);
	
			local minEnergy = 1000;
			
			if (energy >= minEnergy) then
				if (not collider) then
					collider=entity;
				end
	
		    local colHit = self.collisionHit;
				colHit.pos = hit.pos;
				colHit.dir = hit.dir or hit.normal;
				colHit.radius = 0;	
				colHit.partId = -1;
				colHit.target = entity;
				colHit.targetId = entity.id;
				colHit.weapon = collider;
				colHit.weaponId = collider.id
				colHit.shooter = collider;
				colHit.shooterId = collider.id
				colHit.materialId = 0;
				colHit.damage = 0;
				colHit.typeId = g_collisionHitTypeId;
				colHit.type = "collision";
				
				if (collider.vehicle and collider.GetDriverId) then
				  local driverId = collider:GetDriverId();
				  if (driverId) then
					  colHit.shooterId = driverId;
					  colHit.shooter=System.GetEntity(colHit.shooterId);
					end
				end
	
				self:ShatterEntity(entity.id, colHit);
			end
	
			return;
		end
	end
	
	if (not (entity.Server and entity.Server.OnHit)) then
	  return;
	end
	
	if (entity.IsDead and entity:IsDead()) then
	  return;
	end
		
	local minVelocity;
	
	-- collision with another entity
	if (collider or colliderMass>0) then
		FastDifferenceVectors(self.tempVec, hit.velocity, hit.target_velocity);
		contactVelocitySq = vecLenSq(self.tempVec);
		contactMass = colliderMass;		
		minVelocity = self:GetCollisionMinVelocity(entity, collider, hit);
	else	-- collision with world		
		contactVelocitySq = vecLenSq(hit.velocity);
		contactMass = entity:GetMass();
		minVelocity = 7.5;
	end
	
	-- marcok: avoid fp exceptions, not nice but I don't want to mess up any damage calculations below at this stage
	if (contactVelocitySq < 0.01) then
		contactVelocitySq = 0.01;
	end
	
	local damage = 0;
	
	-- make sure we're colliding with something worthy
	if (contactMass > 0.01) then 		
		local minVelocitySq = minVelocity*minVelocity;
		local bigObject = false;
		--this should handle falling trees/rocks (vehicles are more heavy usually)
		if(contactMass > 200.0 and contactMass < 10000 and contactVelocitySq > 2.25) then
			if(hit.target_velocity and vecLenSq(hit.target_velocity) > (contactVelocitySq * 0.3)) then
				bigObject = true;
				--vehicles and doors shouldn't be 'bigObject'-ified
				if(collider and (collider.vehicle or collider.advancedDoor)) then
					bigObject = false;
				end
			end
		end
		
		local collideBarbWire = false;
		if(hit.materialId == g_barbWireMaterial and entity and entity.actor) then
			collideBarbWire = true;
		end
			
		--Log("velo : %f, mass : %f", contactVelocitySq, contactMass);
		if (contactVelocitySq >= minVelocitySq or bigObject or collideBarbWire) then		
			-- tell AIs about collision
			if(AI and entity and entity.AI and not entity.AI.Colliding) then 
				g_SignalData.id = hit.target_id;
				g_SignalData.fValue = contactVelocitySq;
				AI.Signal(SIGNALFILTER_SENDER,1,"OnCollision",entity.id,g_SignalData);
				entity.AI.Colliding = true;
				entity:SetTimer(COLLISION_TIMER,4000);
			end			
			--
			
			-- marcok: Uncomment this stuff when you need it
		  --local debugColl = self.game:DebugCollisionDamage();
		  
		  --if (debugColl>0) then
		  -- Log("------------------------- collision -------------------------");	
		  --end
			
			local contactVelocity = math.sqrt(contactVelocitySq)-minVelocity;
			if (contactVelocity < 0.0) then
				contactVelocitySq = minVelocitySq;
				contactVelocity = 0.0;
			end
 			  			
			-- damage
			if(entity.vehicle) then
				if(not self:IsMultiplayer()) then
					damage = 0.0005*self:GetCollisionEnergy(entity, hit); -- vehicles get less damage SINGLEPLAYER ONLY.
				else
					damage = 0.0002*self:GetCollisionEnergy(entity, hit);	-- keeping the original values for MP.
				end
			else
				damage = 0.0025*self:GetCollisionEnergy(entity, hit);
			end
			
			-- apply damage multipliers 
			damage = damage * self:GetCollisionDamageMult(entity, collider, hit);  
			
			if(collideBarbWire and entity.id == g_localActorId) then
				damage = damage * (contactMass * 0.15) * (30.0 / contactVelocitySq);
			end
			
      if(bigObject) then
        if (damage > 0.5) then 
				  damage = damage * (contactMass / 10.0) * (10.0 / contactVelocitySq);
				  if(entity.id ~= g_localActorId) then
					 damage = damage * 3;
				  end
				else
				  return;
				end
			end	
			
			-- subtract collision damage threshold, if available
			if (entity.GetCollisionDamageThreshold) then
			  local old = damage;
			  damage = __max(0, damage - entity:GetCollisionDamageThreshold());		
			end
			
			if (entity.actor) then
				if(entity.actor:IsPlayer()) then 
					if(hit.target_velocity and vecLen(hit.target_velocity) == 0) then --limit damage from running agains static objects
						damage = damage * 0.2;
					end
				end
			
				if(collider and collider.class=="AdvancedDoor")then
					if(collider:GetState()=="Opened")then
						entity:KnockedOutByDoor(hit,contactMass,contactVelocity);
					end
				end;
				
				if (collider and not collider.actor) then
				  local contactVelocityCollider = __max(0, vecLen(hit.target_velocity)-minVelocity);  				  
				  local killVelocity = (entity.collisionKillVelocity or 20.0);
				    				  
				  if(contactVelocity > killVelocity and contactVelocityCollider > killVelocity and colliderMass > 50 and not entity.actor:IsPlayer()) then  				  	
				  	local bNoDeath = entity.Properties.Damage.bNoDeath;
				  	local bFall = bNoDeath and bNoDeath~=0;
				  	
				  	-- don't allow killing friendly AIs by collisions
						if (self:Friendly(entity.id, g_localActorId)) then
							return;
						end
				  	
				  	
				  	--if (debugColl~=0) then
				  	--  Log("%s for <%s>, collider <%s>, contactVel %.1f, contactVelCollider %.1f, colliderMass %.1f", bFall and "FALL" or "KILL", entity:GetName(), collider:GetName(), contactVelocity, contactVelocityCollider, colliderMass);
				  	--end  				  	
				  	
				  	if(bFall) then
				  	  entity.actor:Fall(hit.pos);
				  	else  				  	
							entity:Kill(true, NULL_ENTITY, NULL_ENTITY);  								
						end
					else
						if (g_localActorId and (not self:Friendly(entity.id, g_localActorId))) then
							if(not entity.isAlien and contactVelocity > 5.0 and contactMass > 10.0 and not entity.actor:IsPlayer()) then
								if(damage < 50) then
									damage = 50;
									entity.actor:Fall(hit.pos);
								end
							else
							 if(not entity.isAlien and contactMass > 2.0 and contactVelocity > 15.0 and not entity.actor:IsPlayer()) then
								if(damage < 50) then
									damage = 50;
									entity.actor:Fall(hit.pos);
								end
							 end 
							end
						end
					end
				end
			end
  		
			
			if (damage >= 0.01) then				  				
				if (not collider) then collider = entity; end;		
				
				--prevent deadly collision damage (old system somehow failed)
				if (entity.actor and self:Friendly(entity.id, g_localActorId)) then
					if(entity.id ~= g_localActorId) then
						if(entity.actor:GetHealth() <= damage) then
							entity.actor:Fall(hit.pos);
							return;
						end
					end
				end

			  local curtime = System.GetCurrTime();
			  if (entity.lastCollDamagerId and entity.lastCollDamagerId==collider.id and 
					  entity.lastCollDamageTime+0.3>curtime and damage<entity.lastCollDamage*2) then
					return
				end
				entity.lastCollDamagerId = collider.id;
				entity.lastCollDamageTime = curtime;
				entity.lastCollDamage = damage;
				
				--if (debugColl>0) then
				--  Log("[SinglePlayer] <%s>: sending coll damage %.1f", entity:GetName(), damage);
				--end
			
		    local colHit = self.collisionHit;
				colHit.pos = hit.pos;
				colHit.dir = hit.dir or hit.normal;
				colHit.radius = 0;	
				colHit.partId = -1;
				colHit.target = entity;
				colHit.targetId = entity.id;
				colHit.weapon = collider;
				colHit.weaponId = collider.id
				colHit.shooter = collider;
				colHit.shooterId = collider.id
				colHit.materialId = 0;
				colHit.damage = damage;
				colHit.typeId = g_collisionHitTypeId;
				colHit.type = "collision";
				colHit.impulse=hit.impulse;
				
				if (collider.vehicle and collider.GetDriverId) then
				  local driverId = collider:GetDriverId();
				  if (driverId) then
					  colHit.shooterId = driverId;
					  colHit.shooter=System.GetEntity(colHit.shooterId);
					end
				end
				
				local deadly=false;
			
				if (entity.Server.OnHit(entity, colHit)) then
					-- special case for actors
					-- if more special cases come up, lets move this into the entity
						if (entity.actor and self.ProcessDeath) then
							self:ProcessDeath(colHit);
						elseif (entity.vehicle and self.ProcessVehicleDeath) then
							self:ProcessVehicleDeath(colHit);
						end
					
					deadly=true;
				else
					-- [*DavidR | 28/Apr/2010] Warning: This is to notify the hit reaction system, but it has 
					-- several problems:
					-- * Server only
					-- * Slow (context change due to bind function invocation and the construction 
					--   of a HitInfo object from the argument hitInfo table)
					-- ToDo: Work on a C++ side version of this (by using a SP GameRules DamageHandling module?)
					-- Fix minimum damage hardcoded value
					local hitReactionProcessed = false;
					if (entity.NotifyHitReaction) then
						hitReactionProcessed = entity:NotifyHitReaction(colHit, damage);
					end

					-- If the hit reaction hasn't been processed, we may want to enable fall n play here				
					if (not hitReactionProcessed) then
						if (bFall) then
							entity.actor:Fall(hit.pos);
						end
					
						if (bFallCollider) then
							collisionInfo.collider.actor:Fall(hit.pos);					
						end
					end
				end
				
				local debugHits = self.game:DebugHits();
				
				if (debugHits>0) then
					self:LogHit(colHit, debugHits>1, deadly);
				end				
			end
		end
	end
end


----------------------------------------------------------------------------------------------------
function SinglePlayer:OnSpawn()
	self:InitHitMaterials();
	self:InitHitTypes();
end


----------------------------------------------------------------------------------------------------
function SinglePlayer.Server:OnInit()
	self.fallHit={};
	self.explosionHit={};
	self.collisionHit={};
	
	AI:ResetAI();
end


----------------------------------------------------------------------------------------------------
function SinglePlayer.Client:OnInit()
	self.fadeFrames = 0;
	self.curFadeTime = 0;
	self.fadeTime = 2;	-- fade time in seconds
	self.fading = true;
	self.fadingToBlack = false;
	self.canResurrect = false;
	
	self.collisionHit={};

	if (not System.IsEditor()) then	
		Sound.SetMasterVolumeScale(0);
	else
	  -- full volume when starting the Editor
		Sound.SetMasterVolumeScale(1);
	end
	
end


----------------------------------------------------------------------------------------------------
function SinglePlayer.Server:OnClientConnect( channelId )
	local params =
	{
		name     = "Dude",
		class    = "Player",
		position = {x=0, y=0, z=0},
		rotation = {x=0, y=0, z=0},
		scale    = {x=1, y=1, z=1},
	};

	player = Actor.CreateActor(channelId, params);
	
	if (not player) then
	  Log("OnClientConnect: Failed to spawn the player!");
	  return;
	end
	
	local spawnId = self.game:GetFirstSpawnLocation(0);
	if (spawnId) then
		local spawn=System.GetEntity(spawnId);
		if (spawn) then
			--set pos
			player:SetWorldPos(spawn:GetWorldPos(g_Vectors.temp_v1));
			--set angles
			player:SetWorldAngles(spawn:GetAngles(g_Vectors.temp_v1));
			spawn:Spawned(player);
			
			return;
		end
	end

	System.Log("$1warning: No spawn points; using default spawn location!")
end


----------------------------------------------------------------------------------------------------
function SinglePlayer.Server:OnClientEnteredGame( channelId, player, loadingSaveGame )
end

--------------------------------------------------------------------------
function SinglePlayer:ProcessFallDamage(actor, fallspeed, freefall)--distance)

	do return end;

	local dead = (actor.IsDead and actor:IsDead());
	if (dead) then
		return;
	end

	local fataldamage = 105;--the damage applied for fatal distance. The more the distance is, the more the damage.
	
--	local safe 	= 2;				--a fall less than this distance(meters) is safe
--	local fatal = 12;				--a fall bigger than this distance(meters) is fatal
--			
--	if (distance <= safe) then
--		return;
--	end
			
--	local delta 		= fatal - safe;
--	local excursion = distance - safe;
--	
--	local damage = (1.0 - ((delta - excursion) / delta)) * fataldamage;
--	local dead = (actor.IsDead and actor:IsDead());

	local safeZVel = 5;
	
	if (fallspeed < 8) then
		return;
	end
	
	local fatalZVel = 17;	
	
	-- in strength mode you jump higher and get less/later damage from falling
	if(actor.actorStats.nanoSuitStrength > 50) then
		if(fallspeed < 10) then
			return;
		end
		fatalZVel = 20;
	end
	
	local deltaZVel = fatalZVel - safeZVel;
	local excursionZVel = fallspeed - safeZVel;
	local damage = (1.0 - ((deltaZVel - excursionZVel) / deltaZVel)) * fataldamage;
	
	if (actor.actorStats.inFreeFall==1) then
		damage=1000;
	end
	
	--Log("falldamage to "..actor:GetName()..":"..damage);

	self.fallHit.partId = -1;
	self.fallHit.pos = actor:GetWorldPos();
	self.fallHit.dir = g_Vectors.v001;
	self.fallHit.radius = 0;	
	self.fallHit.target = actor;
	self.fallHit.targetId = actor.id;
	self.fallHit.weapon = actor;
	self.fallHit.weaponId = actor.id
	self.fallHit.shooter = actor;
	self.fallHit.shooterId = actor.id
	self.fallHit.materialId = 0;
	self.fallHit.damage = damage;
	self.fallHit.typeId = self.game:GetHitTypeId("fall");
	self.fallHit.type = "fall";
	
	local deadly=false;
	
	if ((not dead) and actor.Server.OnHit(actor, self.fallHit)) then	
		self:ProcessDeath(self.fallHit);
		
		deadly=true;
	end
	
	local debugHits = self.game:DebugHits();
	
	if (debugHits>0) then
		self:LogHit(self.fallHit, debugHits>1, deadly);
	end	
end

----------------------------------------------------------------------------------------------------
-- how much damage does 1 point of energy absorbs?
function SinglePlayer:GetEnergyAbsorption(player)
	local suitMaxEnergy = 200.0; --keep in mind to change this if the suit max energy is altered
	return tonumber(System.GetCVar("g_suitArmorHealthValue"))/suitMaxEnergy;
end



----------------------------------------------------------------------------------------------------
function SinglePlayer:GetDamageAbsorption(actor, hit)
	if(hit.damage == 0 or hit.type=="punish") then
		return 0;
	end

	if (actor.actor.GetNanoSuitMode) then
		local nanoSuitMode = actor.actor:GetNanoSuitMode();
		if(nanoSuitMode == 3) then -- armor mode
			local suitMaxEnergy = 200.0; --keep in mind to change this if the suit max energy is altered
			local armorHealthVal = tonumber(System.GetCVar("g_suitArmorHealthValue"));
			local currentSuitEnergy = actor.actor:GetNanoSuitEnergy();
			local currentSuitArmor = (currentSuitEnergy / suitMaxEnergy) * armorHealthVal; -- Convert energy to health points
			-- Reduce energy based on damage. The left over will be reduced from the health.
			local suitArmorLeft = currentSuitArmor - hit.damage;
			local absorption = 0.0;
			if (suitArmorLeft < 0.0) then
				-- Only part of the hit was absorbted by the armor, no energy left anymore and return the remaining fraction.
				actor.actor:SetNanoSuitEnergy(0);
				absorption = 1 + suitArmorLeft/hit.damage;
			else
				-- Convert remaining health points back to energy
				actor.actor:SetNanoSuitEnergy((suitArmorLeft / armorHealthVal) * suitMaxEnergy);
				absorption = 1;
			end
		end
		
		-- When in armor mode, absorb at least 30% of the damage.
		return math.max(0.3, absorption);
	end
	
	return 0;
end


----------------------------------------------------------------------------------------------------
function SinglePlayer:ProcessActorDamage(hit)

	local target=hit.target;
	local shooter=hit.shooter;
	local weapon=hit.weapon;
	local health = target.actor:GetHealth();
	
	if (target.IsInvulnerable and target:IsInvulnerable())then
		return (health <= 0);
	end;
	
	if(hit.target.actor:IsPlayer()) then
		if(hit.type == "fire" and HUD~=nil) then
			HUD.HitIndicator();
		end
		if(hit.explosion and hit.target.actor.id == g_localActorId) then
			HUD.DamageIndicator(hit.weaponId or NULL_ENTITY, hit.shooterId or NULL_ENTITY, hit.dir, false);
		end
	end
	
	local dmgMult = 1.0;
	--if (target and target.actor and target.actor:IsPlayer()) then
	--	dmgMult = g_dmgMult;
	--end

	local totalDamage = 0;
	
	local splayer=source and shooter.actor and shooter.actor:IsPlayer();
	local sai=(not splayer) and shooter and shooter.actor;
	local tplayer=target and target.actor and target.actor:IsPlayer();
	local tai=(not tplayer) and target and target.actor;
	
	if (not self:IsMultiplayer() and AI) then
		if (sai and not tai) then
			-- AI vs. player
			totalDamage = AI.ProcessBalancedDamage(shooter.id, target.id, dmgMult*hit.damage, hit.type);
			totalDamage = totalDamage*(1-self:GetDamageAbsorption(target, hit));
				--totalDamage = dmgMult*hit.damage*(1-target:GetDamageAbsorption(hit.type, hit.damage));
		elseif (sai and tai) then
			-- AI vs. AI
			totalDamage = AI.ProcessBalancedDamage(shooter.id, target.id, dmgMult*hit.damage, hit.type);
			totalDamage = totalDamage*(1-self:GetDamageAbsorption(target, hit));
		else
			totalDamage = dmgMult*hit.damage*(1-self:GetDamageAbsorption(target, hit));
		end
	else
		totalDamage = dmgMult*hit.damage*(1-self:GetDamageAbsorption(target, hit));
	end

	--update the health
	health = math.floor(health - totalDamage);

	if (self.game:DebugCollisionDamage()>0) then	
	  Log("<%s> hit damage: %d // absorbed: %d // health: %d", target:GetName(), hit.damage, hit.damage*self:GetDamageAbsorption(target, hit), health);
	end
	
	if (health<=0) then --prevent death out of some reason
		if(target.Properties.Damage.bNoDeath and target.Properties.Damage.bNoDeath==1) then
			target.actor:Fall(hit.pos);
			return false;
		else
			if(target.id == g_localActorId) then
				if(System.GetCVar("g_PlayerFallAndPlay") == 1) then
					HUD.StartPlayerFallAndPlay();
					return false;
				--else
				--	if(System.GetCVar("g_difficultyLevel") < 2 or System.GetCVar("g_godMode") == 3) then --System.GetCVar("g_playerRespawns")
				--		if(hit.type == "bullet" or hit.type == "gaussbullet" or hit.type == "melee" or hit.type == "frag" or hit.type == "C4") then --
				--			HUD.FakeDeath();
				--			return false;
				--		end
				--	end
				end;
			else	--prevent friendly AIs from dying by player action //from grenade explosions (Bernds call)
				--if(hit.type == "frag") then
				if(hit.shooterId == g_localActorId) then
					if (self:Friendly(hit.target.id, g_localActorId)) then
						target.actor:Fall(hit.pos);
						return false;
					end
				end
				--end
			end;
		end;
	end
	
	--if the actor is god do some counts and reset the hp if necessary
	local isGod = target.actorStats.godMode;
	if (isGod and isGod > 0) then
	 	if (health <=0) then
	 		target.actor:SetHealth(0);  --is only called to count deaths in GOD mode within C++
			health = target.Properties.Damage.health;	
		end
	end
	
	target.actor:SetHealth(health);	
	
	if(health>0 and target.Properties.Damage.FallPercentage and not target.isFallen) then --target.actor:IsFallen()) then
		local healthPercentage = target:GetHealthPercentage( );
		if(target.Properties.Damage.FallPercentage>healthPercentage and 
			totalDamage > tonumber(System.GetCVar("g_fallAndPlayThreshold"))) then
				target.actor:Fall(hit.pos);
				return false;
		end
	end	
	
	-- when in vehicle or have suit armor mode on - don't apply hit impulse
	-- when actor is dead, BasicActor:ApplyDeathImpulse is taking over
	if (health>0 and not target:IsOnVehicle()) then
		if(hit.type == "gaussbullet") then
			target:AddImpulse(hit.partId or -1,hit.pos,hit.dir, math.min(1000, hit.damage*2.5),1);
		else
			target:AddImpulse(hit.partId or -1,hit.pos,hit.dir,math.min(200, hit.damage*0.75),1);
		end
	end
	
	local shooterId = (shooter and shooter.id) or NULL_ENTITY;
	local weaponId = (weapon and weapon.id) or NULL_ENTITY;	
	target.actor:DamageInfo(shooterId, target.id, weaponId, totalDamage, hit.type);
	
	-- feedback the information about the hit to the AI system.
	if AI then
		if(hit.material_type) then
			AI.DebugReportHitDamage(target.id, shooterId, totalDamage, hit.material_type);
		else
			AI.DebugReportHitDamage(target.id, shooterId, totalDamage, "");
		end
	end

	return (health <= 0);
end


----------------------------------------------------------------------------------------------------
function SinglePlayer:ReleaseCorpseItem(actor)
	--FIXME:temporary hack until this will move to c++
	--we dont want aliens to drop weapons for now, but we may want later.
	if (actor.isAlien) then
		return;
	end

	local item = actor.inventory:GetCurrentItem();
	if (item) then
		if (item.item:IsMounted()) then
			item.item:StopUse(actor.id);
		else
			local boneName = actor:GetAttachmentBone(0, "right_item_attachment");
			local time = 200+math.random()*550;
			local strenght = (1250-time)/1250;
			local proc;
	
			if (boneName) then
				proc = function()
					actor.actor:DropItem(item.id);
					self.drop_p = item:GetWorldPos(self.drop_p);
					self.drop_a = item:GetWorldAngles(self.drop_a);
	
					item:SetWorldPos(self.drop_p);
					item:SetWorldAngles(self.drop_a);
	
					--self.drop_d = actor:GetBoneDir(boneName, self.drop_d);
					--if (not self.__dropparams) then	self.__dropparams = {}; end;
					--params = self.__dropparams;
					--params.v = vecScale(self.drop_d, strenght*5);
					--item:SetPhysicParams(PHYSICPARAM_VELOCITY, params);
				end;
			else
				proc = function()
					actor.actor:DropItem(item.id);
				end;
			end
	
			Script.SetTimer(time, proc);
		end
	end	
end


----------------------------------------------------------------------------------------------------
function SinglePlayer:ProcessDeath(hit)
	hit.target:Kill(false, hit.shooterId, hit.weaponId);
	
	local bRagdoll = not hit.target:IsOnVehicle(); 
	self.game:KillPlayer(hit.targetId, true, bRagdoll, hit.shooterId, hit.weaponId, hit.damage, hit.partId, hit.typeId, hit.dir, hit.projectileId or NULL_ENTITY, hit.weaponClassId, hit.projectileClassId);

	local isHeadShot = self:IsHeadShot(hit);
	
	if(hit.target.id == g_localActorId) then
		
		-- add to death locations
		local g_difficultyHintSystem = System.GetCVar("g_difficultyHintSystem");
		local g_difficultyLevel = System.GetCVar("g_difficultyLevel");

		if (not self:IsMultiplayer() and g_difficultyHintSystem>0 and g_difficultyLevel ~= 1 and g_difficultyLevel ~= 4 and
				hit.shooter and hit.shooter.actor and not hit.shooter.actor:IsPlayer()) then
			local displayHint = false;
			
			if (g_difficultyHintSystem == 1) then
				local g_difficultyRadius = System.GetCVar("g_difficultyRadius");
				local g_difficultyRadiusThreshold = System.GetCVar("g_difficultyRadiusThreshold");

				local newLoc = { x=0, y=0, z=0 };
				g_localActor:GetWorldPos(newLoc);
				
				local inRadiusCount = 0;
				local radiusSq = g_difficultyRadius*g_difficultyRadius;
				for i,loc in pairs(self.playerDeathLocations) do
					local distance=vecLenSq(vecSub(loc, newLoc));
					if (distance < radiusSq) then
						inRadiusCount = inRadiusCount + 1;
					end
				end
				
				if (inRadiusCount >= (g_difficultyRadiusThreshold-1)) then
					displayHint = true;
				else
					table.insert(self.playerDeathLocations, newLoc);
				end
			elseif (g_difficultyHintSystem == 2) then
				local g_difficultySaveThreshold = System.GetCVar("g_difficultySaveThreshold");
				--local curSaveName = HUD.GetLastInGameSave();
				
				--if (curSaveName == self.lastSaveName) then
				--	self.lastSaveDeathCount = self.lastSaveDeathCount + 1;
				--else
					self.lastSaveName = curSaveName;
					self.lastSaveDeathCount = 1;
				--end

				if (self.lastSaveDeathCount>=g_difficultySaveThreshold) then
					displayHint = true;
					self.lastSaveDeathCount = 0;
				end
			end
					
			if (displayHint == true) then
				HUD.DisplayBigOverlayFlashMessage("@HintDifficulty", 5.0, 400, 375, self.hudWhite);
			end
		end
	else
		if(hit.shooterId == g_localActorId) then 
			if (self:Friendly(hit.target.id, g_localActorId)) then -- should never happen atm, because we prevent death when player shot friend
			 local g_punishFriendlyDeaths = tonumber(System.GetCVar("g_punishFriendlyDeaths"));
			 if (g_punishFriendlyDeaths ~= 0) then
  				--hit.shooter:Kill(true, hit.shooterId, 0);
  				self:CreateHit(g_localActorId,g_localActorId,g_localActorId,1000,nil,nil,nil,"punish");
  				HUD.ShowWarningMessage(5, "@killed_friend");
  			end
			end
			self.game:SPNotifyPlayerKill(hit.target.id, hit.weaponId, isHeadShot, hit.projectileId, hit.type);
		end;
	end;
	
	self:ReleaseCorpseItem(hit.target);	
end


----------------------------------------------------------------------------------------------------
function SinglePlayer:GetDamageTable(source, target)
	local splayer=source and source.actor and source.actor:IsPlayer();
	local sai=(not splayer) and source and source.actor;
	local tplayer=target and target.actor and target.actor:IsPlayer();
	local tai=(not tplayer) and target and target.actor;

	if (splayer) then
		if (tplayer) then
			return self.DamagePlayerToPlayer;
		elseif (tai) then
			return self.DamagePlayerToAI;
		end
	elseif(sai) then
		if (tplayer) then
			return self.DamageAIToPlayer;
		elseif (tai) then
			return self.DamageAIToAI;
		end
	end
	return;
end


----------------------------------------------------------------------------------------------------
function SinglePlayer:LogHit(hit, extended, dead)
	if (dead) then
		Log("'%s' hit '%s' for %d with '%s'... *DEADLY*", EntityName(hit.shooter), EntityName(hit.target), hit.damage or 0, (hit.weapon and hit.weapon:GetName()) or "");
	else
		Log("'%s' hit '%s' for %d with '%s'...", EntityName(hit.shooter), EntityName(hit.target), hit.damage or 0, (hit.weapon and hit.weapon:GetName()) or "");
	end

	if (extended) then	
		Log("  shooterId..: %s", tostring(hit.shooterId));
		Log("  targetId...: %s", tostring(hit.targetId));
		Log("  weaponId...: %s", tostring(hit.weaponId));
		Log("  type.......: %s [%d]", hit.type, hit.typeId or 0);
		Log("  material...: %s [%d]", tostring(hit.material), hit.materialId or 0);
		Log("  damage.....: %d", hit.damage or 0);
		Log("  partId.....: %d", hit.partId or -1);
		Log("  pos........: %s", Vec2Str(hit.pos));
		Log("  dir........: %s", Vec2Str(hit.dir));
		Log("  radius.....: %.3f", hit.radius or 0);
		Log("  explosion..: %s", tostring(hit.explosion or false));
		Log("  remote.....: %s", tostring(hit.remote or false));
	end
end


----------------------------------------------------------------------------------------------------
function SinglePlayer.Server:OnHit(hit)
	
	local target = hit.target;
	
	if (not target) then
		return;
	end
	
	if (target.actor and target.actor:IsPlayer()) then
		if (self.game:IsInvulnerable(target.id)) then
			hit.damage=0;
		end
	end

	local headshot = self:IsHeadShot(hit);
	
	-- remove headshot penalty for squadmates using vehicle (especially MG)
	if(headshot) then 
		if(AI and (AI.GetGroupOf(target.id)==0 and target.AI and target.AI.theVehicle) 
				) then
			headshot = false;
			hit.material_type = "torso";
		end
	end
	
	if (self:IsMultiplayer() or ((not hit.target.actor) or (not hit.target.actor:IsPlayer()))) then
		local material_type=hit.material_type;
		if(headshot and hit.type == "melee") then
			material_type="torso";
		end
		
		hit.damage = math.floor(0.5+self:CalcDamage(material_type, hit.damage, self:GetDamageTable(hit.shooter, hit.target), hit.assistance));
	end
	
	if (self.game:IsFrozen(target.id)) then
		if ((not target.CanShatter) or (tonumber(target:CanShatter())~=0)) then
			if (hit.damage>0 and hit.type~="frost") then
				self:ShatterEntity(hit.target.id, hit);
			end
		
			return;
		end
	end
	
	local dead = (target.IsDead and target:IsDead());

	if (dead) then
		if (target.Server) then
			if (target.Server.OnDeadHit) then
				if (g_gameRules.game:PerformDeadHit()) then
					target.Server.OnDeadHit(target, hit);
				end
			end
		end
	end

	if ((not dead) and target.Server and target.Server.OnHit) then
		if(headshot) then -- helmet can prevent headshot
			if(target.actor and target.actor:LooseHelmet(hit.dir, hit.pos)) then -- helmet takes shot
				if(not (hit.weapon.class == "DSG1")) then -- sniper rifle ignores helmets
					local health = target.actor:GetHealth();
					if(health > 2) then
						target.actor:SetHealth(health - 1);
					end
					target:HealthChanged();
					return;
				end
			end
		end
		
		local deadly=false;
		  
		if (hit.type == "event" and target.actor) then
			target.actor:SetHealth(0);
			target:HealthChanged();
			self:ProcessDeath(hit);
		elseif (target.Server.OnHit(target, hit)) then		  									
			-- special case for actors
			-- if more special cases come up, lets move this into the entity
			if (target.actor and self.ProcessDeath) then
				self:ProcessDeath(hit);
			elseif (target.vehicle and self.ProcessVehicleDeath) then
				self:ProcessVehicleDeath(hit);
			end
			deadly=true;
		end
		
		local debugHits = self.game:DebugHits();
		
		if (debugHits>0) then
			self:LogHit(hit, debugHits>1, deadly);
		end
	end
end


----------------------------------------------------------------------------------------------------
function SinglePlayer.Client:OnUpdate(deltaTime)
	self.fading = nil;
	self.fadeAlpha = 0;
	
	-- before we start fading, we give the engine some time to settle ... this takes a few frames
	if (self.fadeFrames > 0) then
		self.fadeFrames = self.fadeFrames - 1;
		-- full black
		self.curFadeTime = self.fadeTime + deltaTime;
	end
	
	if (self.curFadeTime > 0) then
		self.curFadeTime = self.curFadeTime - deltaTime;
		
		if (self.fadingToBlack) then
			self.fadeAlpha = 255*(1.0-(self.curFadeTime/self.fadeTime));
		else
			self.fadeAlpha = 255*(self.curFadeTime/self.fadeTime);
		end
		
		local dt = (1-(self.fadeAlpha/255));
		
		if (not self.fadingToBlack) then
			Sound.SetMasterVolumeScale(dt);
		end

		self.fading = true;
	end
end


----------------------------------------------------------------------------------------------------
function SinglePlayer.Server:OnStartLevel()
	self.playerDeathLocations = {};
	self.lastSaveName = "";
	self.lastSaveDeathCount = 0;
	CryAction.SendGameplayEvent(NULL_ENTITY, eGE_GameStarted);
end


----------------------------------------------------------------------------------------------------
function SinglePlayer.Client:OnStartLevel()
	if (not self.faded) then
		self.fadeFrames = 8;

--		if (not System.IsEditor()) then
--			HUD.Hide(true);
--		end
		self.faded=true;
	end
end


----------------------------------------------------------------------------------------------------
function SinglePlayer.Client:OnHit(hit)
	if ((not hit.target) or (not self.game:IsFrozen(hit.target.id))) then
	
		local trg = hit.target;

		-- send hit to target
		if (trg and (not hit.backface) and trg.Client and trg.Client.OnHit) then
			trg.Client.OnHit(trg, hit);
			
		--if nothing, humbly apply an impulse.
		--elseif (trg) then
			--trg:AddImpulse(hit.partId,hit.pos,hit.dir,hit.damage*0.5,1);
		end
	end	
end

----------------------------------------------------------------------------------------------------
function SinglePlayer.Client:OnExplosion(explosion)
	self:ClientViewShake(explosion.pos, nil, explosion.shakeMinR, explosion.shakeMaxR, math.min(explosion.shakeScale * explosion.pressure/1500, 10), 2, 0.02, "explosion", explosion.shakeRnd);	
end

----------------------------------------------------------------------------------------------------
function SinglePlayer.Server:OnExplosion(explosion)
	
	local entities = explosion.AffectedEntities;
	local entitiesObstruction = explosion.AffectedEntitiesObstruction;

	if (entities) then
		-- calculate damage for each entity
		for i,entity in ipairs(entities) do
		  			
			local incone=true;
			if (explosion.angle>0 and explosion.angle<2*math.pi) then				
				self.explosion_entity_pos = entity:GetWorldPos(self.explosion_entity_pos);
				local entitypos = self.explosion_entity_pos;
				local ha = explosion.angle*0.5;
				local edir = vecNormalize(vecSub(entitypos, explosion.pos));
				local dot = 1;

				if (edir) then
					dot = vecDot(edir, explosion.dir);
				end
				
				local angle = math.abs(math.acos(dot));
				if (angle>ha) then
					incone=false;
				end
			end

			local frozen = self.game:IsFrozen(entity.id);
			if (incone and (frozen or (entity.Server and entity.Server.OnHit))) then
				local obstruction=entitiesObstruction[i];
				local damage=explosion.damage;
				
				damage = math.floor(0.5+self:CalcExplosionDamage(entity, explosion, obstruction));		

				local dead = (entity.IsDead and entity:IsDead());
					
				local explHit=self.explosionHit;
				explHit.pos = explosion.pos;
				explHit.dir = vecNormalize(vecSub(entity:GetWorldPos(), explosion.pos));
				explHit.radius = explosion.radius;
				explHit.partId = -1;
				explHit.target = entity;
				explHit.targetId = entity.id;
				explHit.weapon = explosion.weapon;
				explHit.weaponId = explosion.weaponId;
				explHit.shooter = explosion.shooter;
				explHit.shooterId = explosion.shooterId;
				explHit.projectileId = explosion.projectileId;
				explHit.materialId = 0;
				explHit.damage = damage;
				explHit.typeId = explosion.typeId or 0;
				explHit.type = explosion.type or "";
				explHit.explosion = true;
				explHit.impact = explosion.impact;
				explHit.impact_targetId = explosion.impact_targetId;
			
				local deadly=false;
				local canShatter = ((not entity.CanShatter) or (tonumber(entity:CanShatter())~=0));

				if (self.game:IsFrozen(entity.id) and canShatter) then
					if (damage>15) then				
					  local hitpos = entity:GetWorldPos();
				    local hitdir = vecNormalize(vecSub(hitpos, explosion.pos));
				    
						self:ShatterEntity(entity.id, explHit);
					end
				else				
					if (entity.actor and entity.actor:IsPlayer()) then
						if (self.game:IsInvulnerable(entity.id)) then
							explHit.damage=0;
						end
					end

					if ((not dead) and entity.Server and entity.Server.OnHit and entity.Server.OnHit(entity, explHit)) then
						-- special case for actors
						-- if more special cases come up, lets move this into the entity
						if (entity.actor and self.ProcessDeath) then
							self:ProcessDeath(explHit);
						elseif (entity.vehicle and self.ProcessVehicleDeath) then
							self:ProcessVehicleDeath(explHit);
						end
						
						deadly=true;
					else
						if (entity.NotifyHitReaction and (explHit.damage > 15)) then
							entity:NotifyHitReaction(explHit, explHit.damage);
						end
					end
				end
				
				local debugHits = self.game:DebugHits();
				
				if (debugHits>0) then
					self:LogHit(explHit, debugHits>1, deadly);
				end
			end
		end
	end
end

----------------------------------------------------------------------------------------------------
function SinglePlayer:ShatterEntity(entityId, hit)
	local entity=System.GetEntity(entityId);
	local isPlayer=entity and entity.actor and entity.actor:IsPlayer();
	if (isPlayer) then
		local isGod = entity.actorStats.godMode;
		if (isGod and (isGod > 0)) then
			self.game:FreezeEntity(entityId, false, false);
			entity.actor:SetHealth(0);  --is only called to count deaths in GOD mode within C++
			entity.actor:SetHealth(entity.actor:GetMaxHealth());
			
			return;
		end
	end

	local damage=math.min(100, hit.damage or 0);
	damage=math.max(20, damage);
	
	local dir=hit.dir;
	if (not dir) then dir=g_Vectors.up; end
	
	self.game:ShatterEntity(entityId, hit.pos, vecScale(dir, damage));

	if (isPlayer) then
		entity:Kill(false, hit.shooterId, hit.weaponId);
		self:ReleaseCorpseItem(entity);	

		HUD.ShowDeathFX(4);
	end
end


----------------------------------------------------------------------------------------------------
function SinglePlayer.Client:OnPlayerKilled(player)
	if (player.actor and player.actor:IsPlayer()) then
		Script.SetTimer(4000, function() 
			if (not System.IsEditor()) then
				--Game.PauseGame(true);
				--Game.ShowInGameMenu(); --it's automatically reloading now by default
			end
		end);
		
		Script.SetTimer(3000, function() 
			self.canResurrect = true;
			end);
		 
		if(g_gameRules) then
			Script.SetTimer(3000, function() 
				g_gameRules.curFadeTime = 1;
				g_gameRules.fadeTime = 1;	-- fade time in seconds
				g_gameRules.fading = true;
				g_gameRules.fadingToBlack = true;
			end);
		end
	end
end


----------------------------------------------------------------------------------------------------
function SinglePlayer:GetCollisionEnergy(entity, hit)
	local m0 = entity:GetMass();
	local m1 = hit.target_mass;	
	local bCollider = hit.target or m1>0.001;
	
	local debugColl = self.game:DebugCollisionDamage();	
	if (debugColl>0) then
	  local targetName = hit.target and hit.target:GetName() or "[no entity]";	  
	  Log("GetCollisionEnergy %s (%.1f) <-> %s (%.1f)", entity:GetName(), m0, targetName, m1);
	end
	
	local v0Sq = 0;
	local v1Sq = 0;	
	
	if (bCollider) then -- non-static
	
  	m0 = __min(m0, m1); -- take at most the colliders mass into accout 
	  
		-- use normal velocities and their difference
		local v0normal = g_Vectors.temp_v1;		
		local v1normal = g_Vectors.temp_v2;				
		local vrel     = g_Vectors.temp_v3;
				
		local v0dotN = dotproduct3d(hit.velocity, hit.normal);		
		FastScaleVector(v0normal, hit.normal, v0dotN);
		
		local v1dotN = dotproduct3d(hit.target_velocity, hit.normal);		
		FastScaleVector(v1normal, hit.normal, v1dotN);	
		
		FastDifferenceVectors(vrel, v0normal, v1normal);
		local vrelSq = vecLenSq(vrel);
		
		v0Sq = __min(sqr(v0dotN), vrelSq);
		v1Sq = __min(sqr(v1dotN), vrelSq);
		
	  if (debugColl>0) then				  
	    CryAction.PersistantSphere(hit.pos, 0.15, g_Vectors.v100, "CollDamage", 5.0);
		  CryAction.PersistantArrow(hit.pos, 1.5, ScaleVector(hit.normal, sgn(v0dotN)), g_Vectors.v010, "CollDamage", 5.0); 		  
		  CryAction.PersistantArrow(hit.pos, 1.3, ScaleVector(hit.normal, sgn(v1dotN)), g_Vectors.v100, "CollDamage", 5.0); 
		
		  if (v0Sq > 2*2 or v1Sq > 2*2) then
		    Log("normal velocities: rel %.1f, <%s> %.1f / <%s> %.1f", math.sqrt(vrelSq), entity:GetName(), v0dotN, hit.target and hit.target:GetName() or "none", v1dotN); 
		    Log("target_type: %i, target_velocity: %s", hit.target_type, Vec2Str(hit.target_velocity));
		  end
		end
			
	else	  
	  v0Sq = sqr(dotproduct3d(hit.velocity, hit.normal)); 
	  
	  if (debugColl>0 and v0Sq>5*5) then
	    CryAction.PersistantArrow(hit.pos, 1.5, hit.normal, g_Vectors.v010, "CollDamage", 5.0); 	    	    
	    CryAction.Persistant2DText("z: "..hit.velocity.z, 1.5, g_Vectors.v111, "CollDamage", 5.0);
	  end
	end
	
	-- colliderEnergyScale can be used to simulate special vulnerability 
	-- against being hit by objects (e.g. objects thrown against humans)
	local colliderEnergyScale = 1;
	if (hit.target and entity.GetColliderEnergyScale) then
	  colliderEnergyScale = entity:GetColliderEnergyScale(hit.target);
	  if (debugColl~=0) then
	    Log("colliderEnergyScale: %.1f", colliderEnergyScale);
	  end
	end
	
	local energy0=0.5*m0*v0Sq;
	local energy1=0.5*m1*v1Sq*colliderEnergyScale;

	return energy0+energy1;
end


----------------------------------------------------------------------------------------------------
function SinglePlayer:PrecacheLevel()
end

function SinglePlayer.Client:OnActorAction( player, action, activation, value )
	if ( ( action == "revive" ) and ( activation == "press" ) ) then
		if ( player:IsDead() ) then
			self:RevivePlayer( player );
			return false;
		end
	end

	return true;
end

function SinglePlayer:RevivePlayer(player)
	if (player.actor and player.actor:IsPlayer() and (not self.IsMultiplayer()) and self.canResurrect ) then 	
  	local pos = player:GetWorldPos(g_Vectors.temp_v1);
  	local angles = player:GetWorldAngles(g_Vectors.temp_v2);

  	local spawnId;
  	local zOffset;
  	spawnId, zOffset = self.game:GetSpawnLocation( player.id, true, true, NULL_ENTITY, 50, player.death_pos );
  	
  	if ( spawnId ) then
  		local spawn = System.GetEntity( spawnId )
  		if ( spawn ) then
  			spawn:Spawned( player );
  
  			pos = spawn:GetWorldPos( g_Vectors.temp_v1 );
  			pos.z = pos.z + zOffset;
    		angles = spawn:GetWorldAngles(g_Vectors.temp_v2);
    	end
  	end
  	
  	self.game:RevivePlayer( player.id, pos, angles, 0, false );
  	ItemSystem.GiveItemPack(player.id, "Singleplayer", false, true);
  	self.canResurrect = false;

  end
end


----------------------------------------------------------------------------------------------------
function SinglePlayer:Friendly(entityId1, entityId2)
	return AI and AI.Friendly(entityId1, entityId2, false);
end
