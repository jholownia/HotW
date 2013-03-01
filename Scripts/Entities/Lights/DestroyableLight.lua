----------------------------------------------------------------------------------------------------
--  Crytek Source File.
--  Copyright (C), Crytek Studios, 2001-2008.
----------------------------------------------------------------------------------------------------
--  $Id$
--  $DateTime$
--  Description: Destroyable Light Entity (Mix of destroyable object and light entity)
--
----------------------------------------------------------------------------------------------------
--  History:
--  - 24:04:2008   Created by Benito G.R. 
--
----------------------------------------------------------------------------------------------------
DestroyableLight =
{
	Client = {},
	Server = {},
	States = {"Alive","Dead" },
	
	Properties =
	{
		-- All destroyable object properties -----------------------------------------------
		Model =
		{
				object_Model 				= "Objects/props/mine/mining_lamp_a.cgf",							-- Pre-destroyed model/submodel.
				SubObject_Name				= "",
				object_ModelDestroyed		= "",-- Post-destroyed model/submodel (same as Model if blank).
				SubObject_NameDestroyed		= "",
		},

		Damage =
		{
				-- bPlayerOnly 			= 1,																	-- Damaged only by player.
				fHealth						= 100,
				fDamageTreshold		= 0,																	-- Only accept damage higher than this value.
				bExplode					= 0,																	-- Create explosion, using Explosion props
		},
		
		DamageMultipliers = 
		{
		  fCollision = 1.0,
		  fBullet    = 1.0,		  
		},

		Vulnerability	=
		{
			bExplosion = 1,
			bCollision = 1,
			bMelee		 = 1,
			bBullet		 = 1,
			bOther	   = 1,
		},

		Breakage =																							-- => BreakToPieces
		{
			fLifeTime = 10,																					-- Average lifetime of particle pieces
			fExplodeImpulse = 0,																		-- Applies central impulse to pieces, in addition to hit impulse
			bSurfaceEffects = 1,																		-- Generate secondary particle effects from surface type
		},
		
		Explosion =																							-- => Explosion
		{
			Delay 					= 0,																		
			Effect					= "explosions.mine.claymore",
			EffectScale			= 1,
			MinRadius				= 5,
			Radius					= 10,
			MinPhysRadius		= 2.5,
			PhysRadius			= 5,
			Pressure				= 1000,
			Damage					= 1000,
			Decal						= "textures/decal/explo_decal.dds",
			HoleSize				= 10,
			TerrainHoleSize	= 5,
			Direction				= {x=0, y=0, z=1},
			vOffset 				= {x=0, y=0, z=0},
			DelayEffect	=
			{
				bHasDelayEffect = 0,
				Effect					= "",
				vOffset					= {x=0, y=0, z=0},
				vRotation				= {x=0, y=0, z=0},
				Params ={
					SpawnPeriod			= 0,
					Scale						= 1,
					CountScale			= 1,
					bCountPerUnit		= 0,
					bSizePerUnit		= 0,
					AttachType			= "none",
					AttachForm			= "none",
					bPrime					= 0,
				},
			},
		},

		Sound = {
			soundTurnOn = "",
			soundTurnOff = "",
			soundDestroy = "",
			soundIdle = "",
			soundRun = "",
			vOffset	= {x=0, y=0, z=0},
			fAISoundRadius = 30,
		},
				
		Physics = {																							-- Particle pieces always physicalised as rigid bodies
			bRigidBody=1,																						-- True if rigid body.
			bRigidBodyActive = 1,																		-- If rigid body is originally created (1) OR will be created only on OnActivate (0).
			bRigidBodyAfterDeath = 1,																-- True if rigid body after death too.
			bActivateOnDamage = 0,																	-- Activate when a rocket hit the entity.
			Density = -1,
			Mass = -1,
			bPushableByPlayers = 0,
			bCanBreakOthers = 0,
			Simulation =
			{
				max_time_step = 0.02,
				sleep_speed = 0.04,
				damping = 0,
			},
			MP =
			{
				bHackDontSyncPos=0,		-- hack this wont work properly, but for MP last minute, we need to turn off sycning for some props
			},
		},
	},

	PropertiesInstance = 
	{
		bTurnedOn = 1,
		-- End of destroyable object properties
		
		-- Light properties ----------------------------------------------------
		
		LightProperties_Base = 
		{
			_nVersion = -1,
			bUseThisLight = 1,
			Radius = 10,
			vOffset				= {x=0, y=0, z=0},
			vDirection			= {x=0, y=1, z=0},
			Style =
			{
				nLightStyle = 0,
				Rotation = {x=0.0,y=0.0,z=0.0},
				fAnimationSpeed = 1,
				nAnimationPhase = 0,
				fCoronaScale = 1,
				fCoronaDistSizeFactor = 1,
				fCoronaDistIntensityFactor = 1,
				texture_AttenuationMap = "",
			},
			Projector =
			{
				texture_Texture = "",
				bProjectInAllDirs = 0,
				fProjectorFov = 90,
				fProjectorNearPlane = 0,
			},
			Color = {
				clrDiffuse = { x=1,y=1,z=1 },
				fDiffuseMultiplier = 1,
				fSpecularMultiplier = 1,
				fHDRDynamic = 0,		-- -1=darker..0=normal..1=brighter
			},
			Options = {
				nCastShadows = 0,
				fShadowBias = 1,
				fShadowSlopeBias = 1,
				bAffectsThisAreaOnly = 1,
				bIgnoresVisAreas = 0,
				--bUsedInRealTime=1,
				bDeferredLight = 1,
				bAmbientLight = 0,
				bFakeLight=0,
				bDeferredClipBounds = 0,
				bIrradianceVolumes = 0,
				texture_deferred_cubemap = "",
				file_deferred_clip_geom = "",
				nPostEffect=0, -- 0=none, 1= screen space light shaft, 2= flare, 3= volume desaturation ?		
				fShadowUpdateMinRadius = 10,
				fShadowUpdateRatio = 1,				
				
				bIgnoreGeomCaster = 0,
        nViewDistRatio = 100,
        nGlowSubmatId = 0,
 			},
			Test = {
				bFillLight=0,
			},
		},
		
		LightProperties_Destroyed = 
		{
			_nVersion = -1,
			bUseThisLight = 0,
			Radius = 10,
			vOffset					= {x=0, y=0, z=0},
			vDirection			= {x=0, y=1, z=0},
			Style =
			{
				nLightStyle = 0,
				Rotation = {x=0.0,y=0.0,z=0.0},
				fAnimationSpeed = 1,
				nAnimationPhase = 0,
				fCoronaScale = 1,
				fCoronaDistSizeFactor = 1,
				fCoronaDistIntensityFactor = 1,
				texture_AttenuationMap = "",
			},
			Projector =
			{
				texture_Texture = "",
				bProjectInAllDirs = 0,
				fProjectorFov = 90,
				fProjectorNearPlane = 0,
			},
			Color = {
				clrDiffuse = { x=1,y=1,z=1 },
				fDiffuseMultiplier = 1,
				fSpecularMultiplier = 1,
				fHDRDynamic = 0,		-- -1=darker..0=normal..1=brighter
			},
			Options = {
				nCastShadows = 0,
				fShadowBias = 1,
				fShadowSlopeBias = 1,
				bAffectsThisAreaOnly = 1,
				bIgnoresVisAreas = 0,
				--bUsedInRealTime=1,
				bDeferredLight = 1,
				bAmbientLight = 0,
				bFakeLight=0,
				bDeferredClipBounds = 0,
				bIrradianceVolumes = 0,
				bDisableX360Opto = 0,
				texture_deferred_cubemap = "",
				file_deferred_clip_geom = "",
				nPostEffect=0, -- 0=none, 1= screen space light shaft, 2= flare, 3= volume desaturation ?			
				
				bIgnoreGeomCaster = 0,
        nViewDistRatio = 100,
        nGlowSubmatId = 0,
 			},
			Test = {
				bFillLight=0,
			},
		},
		-- End of light properties ----------------------------------------------------
	},

	Editor=
	{
		IsScalable = false;
	},

	
	_LightTable = {},
	
	lightSlot = -1,
	lightOn = true,
	materialIsCloned = false,
	
	Editor=
	{
		Icon="Light.bmp",
	},
	
}

-------------------------------------------------------
function DestroyableLight:OnLoad(table)	
  if (self.lightSlot) then
  	self:FreeSlot( self.lightSlot );
  end
	self.bUsable = table.bUsable;
	self.shooterId = table.shooterId;
	self.health = table.health;
	self.dead = table.dead;
	self.FXSlot = table.FXSlot;
	self.exploded = table.exploded;
	self.rigidBodySlot = table.rigidBodySlot;
	self.isRigidBody = table.isRigidBody;
	self.currentSlot = table.currentSlot;
	self.LastHit = table.LastHit;
	self.lightSlot = table.lightSlot;
	self.lightOn = table.lightOn;
	self.origGlowValue = table.origGlowValue;
	self.materialIsCloned = table.materialIsCloned; 
		
	self:SetCurrentSlot(self.currentSlot);

	
	if (self.dead) then	
		if (self.Properties.Physics.bRigidBodyAfterDeath == 1) then
			-- temprarolly set bRigidBody to 1, because EntityCommon checks it!
			local aux = self.Properties.Physics.bRigidBody;
			self.Properties.Physics.bRigidBody = 1;
			self:PhysicalizeThis(self.currentSlot);
			self.Properties.Physics.bRigidBody = aux;
		end
	else
		self:PhysicalizeThis(self.currentSlot);
	end
	
	if (self:GetState() ~= table.state) then
	  self:GotoState(table.state)
	end

  self.runSoundId = 0;
  self.idleSoundId = 0;
	self:ShowCorrectLight();
end

-------------------------------------------------------
function DestroyableLight:OnSave(table)  	
	table.bUsable = self.bUsable;
	table.shooterId = self.shooterId;
	table.health = self.health;
	table.FXSlot = self.FXSlot;
	table.dead = self.dead;
	table.exploded = self.exploded;
	table.rigidBodySlot = self.rigidBodySlot;
	table.isRigidBody = self.isRigidBody;
	table.currentSlot = self.currentSlot;
	table.LastHit = self.LastHit;
	table.state = self:GetState();
	table.lightSlot = self.lightSlot;
	table.lightOn = self.lightOn;
	table.origGlowValue = self.origGlowValue;
	table.materialIsCloned = self.materialIsCloned; 

end

----------------------------------------------------------------------------------------------------
function DestroyableLight:CommonInit()
	self.bReloadGeoms = 1;
	self.bUsable = self.Properties.bUsable;
	self.lightOn = self.PropertiesInstance.bTurnedOn==1;
	if (not self.bInitialized) then
		self.LastHit = {
			impulse = {x=0,y=0,z=0},
			pos = {x=0,y=0,z=0},
		};
		self:Reload();
		self.bInitialized = 1;
		self:GotoState( "Alive" );
	end
end


----------------------------------------------------------------------------------------------------
function DestroyableLight.Server:OnInit()
	self:CommonInit();
end

----------------------------------------------------------------------------------------------------
function DestroyableLight.Client:OnInit()
	self:CommonInit();
	self:ShowCorrectLight();
	self:CacheResources("DestroyableLight.lua");
end

-------------------------------------------------------
function DestroyableLight:CacheResources(requesterName)
	local textureFlags = 0;
	if (self.PropertiesInstance.LightProperties_Base.Projector.bProjectInAllDirs ~= 0 and self.PropertiesInstance.LightProperties_Base.Options.bDeferredLight ~= 0) then
		textureFlags = eGameCacheResourceFlag_TextureReplicateAllSides;
	end
	Game.CacheResource(requesterName, self.PropertiesInstance.LightProperties_Base.Projector.texture_Texture, eGameCacheResourceType_Texture, textureFlags);
	
	textureFlags = 0;
	if (self.PropertiesInstance.LightProperties_Destroyed.Projector.bProjectInAllDirs ~= 0 and self.PropertiesInstance.LightProperties_Destroyed.Options.bDeferredLight ~= 0) then
		textureFlags = eGameCacheResourceFlag_TextureReplicateAllSides;
	end
	Game.CacheResource(requesterName, self.PropertiesInstance.LightProperties_Destroyed.Projector.texture_Texture, eGameCacheResourceType_Texture, textureFlags);
	
	self:PreLoadParticleEffect( self.Properties.Explosion.Effect );
	self:PreLoadParticleEffect( self.Properties.Explosion.DelayEffect.Effect );
	
	Game.CacheResource(requesterName, self.PropertiesInstance.LightProperties_Base.Style.texture_AttenuationMap, eGameCacheResourceType_Texture, eGameCacheResourceFlag_TextureNoStream);
	Game.CacheResource(requesterName, self.PropertiesInstance.LightProperties_Destroyed.Style.texture_AttenuationMap, eGameCacheResourceType_Texture, eGameCacheResourceFlag_TextureNoStream);
	
	Game.CacheResource(requesterName, self.PropertiesInstance.LightProperties_Base.Options.texture_deferred_cubemap, eGameCacheResourceType_TextureDeferredCubemap, 0);
	Game.CacheResource(requesterName, self.PropertiesInstance.LightProperties_Destroyed.Options.texture_deferred_cubemap, eGameCacheResourceType_TextureDeferredCubemap, 0);
	
	Game.CacheResource(requesterName, self.PropertiesInstance.LightProperties_Base.Options.file_deferred_clip_geom, eGameCacheResourceType_StaticObject, 0);
	Game.CacheResource(requesterName, self.PropertiesInstance.LightProperties_Destroyed.Options.file_deferred_clip_geom, eGameCacheResourceType_StaticObject, 0);
end

----------------------------------------------------------------------------------------------------
function DestroyableLight:OnPropertyChange()
	self.bReloadGeoms = 1;
	self:Reload();
	if (self.PropertiesInstance.LightProperties_Base.Options.bDeferredClipBounds) then
		self:UpdateLightClipBounds(self.lightSlot);
	end
	-- to avoid loop sounds playing while in editor mode
	self:StopIdleSound();  
	self:StopRunSound();
end


----------------------------------------------------------------------------------------------------
function DestroyableLight:OnShutDown()
end

----------------------------------------------------------------------------------------------------
function DestroyableLight:OnReset()
	self:RemoveEffect();

	if (self:GetState() ~= "Alive") then
		self:Reload();
	else
		self.lightOn = self.PropertiesInstance.bTurnedOn==1;
		self:ShowCorrectLight();
	end

	self:AwakePhysics(0);
end

----------------------------------------------------------------------------------------------------
function DestroyableLight:RemoveEffect()
	if(self.FXSlot)then
		self:FreeSlot(self.FXSlot);
		self.FXSlot= -1;
	end;
end;

----------------------------------------------------------------------------------------------------
function DestroyableLight:Reload()
	self:ResetOnUsed();
	local props = self.Properties;
	self.bUsable=self.Properties.bUsable;
	self.shooterId = NULL_ENTITY;
	self.health = props.Damage.fHealth;
	self.dead = nil;
	self.exploded = nil;
	self.rigidBodySlot = nil;
	self.isRigidBody = nil;

	if (self.bReloadGeoms == 1) then
		if (not EmptyString(props.Model.object_Model)) then
			self:LoadObject(3,props.Model.object_Model); -- First load whole object in slot 3.
			self:DrawSlot(3,0); -- Make it invisible
			self:LoadSubObject(0,props.Model.object_Model, props.Model.SubObject_Name);
		end
	
		if (not EmptyString(props.Model.object_ModelDestroyed)) then
			self:LoadSubObject(1, props.Model.object_ModelDestroyed, props.Model.SubObject_NameDestroyed);
		elseif (not EmptyString(props.Model.SubObject_NameDestroyed)) then
			self:LoadSubObject(1, props.Model.object_Model, props.Model.SubObject_NameDestroyed);
		end
		
		self:SetCurrentSlot(0);
		self:PhysicalizeThis(0);
		
		-- this is somewhat of a hack: the "or self.lightOn" is there to cover the case when the designer is currently modifying the glow value in the editor. it is irrelevant in pure game
		if (not self.origGlowValue or self.lightOn) then
			self.origGlowValue = self:GetMaterialFloat(0, self.PropertiesInstance.LightProperties_Base.Options.nGlowSubmatId, "glow" );
		end
	end

	
	self.bReloadGeoms = 0;
	self:GotoState( "Alive" );
	self.lightOn = self.PropertiesInstance.bTurnedOn==1;
  if (self.idleSoundId==nil) then
  	self.idleSoundId = 0;
  end	
  if (self.runSoundId==nil) then
  	self.runSoundId = 0;
  end	
	self:ShowCorrectLight();
end

------------------------------------------------------------------------------------------------------
function DestroyableLight:PhysicalizeThis( nSlot )
	if (self.Properties.Physics.MP.bHackDontSyncPos==1) then
		CryAction.DontSyncPhysics(self.id);
	end

	local Physics = self.Properties.Physics;
	-- Init physics.
	EntityCommon.PhysicalizeRigid( self,nSlot,Physics,self.bRigidBodyActive );
end

----------------------------------------------------------------------------------------------------
function DestroyableLight:SetCurrentSlot(slot)
	if (slot == 0) then
		self:DrawSlot(0, 1);
		self:DrawSlot(1, 0);
	else
		self:DrawSlot(0, 0);
		self:DrawSlot(1, 1);
	end
	self.currentSlot = slot;
end

----------------------------------------------------------------------------------------------------
function DestroyableLight:Explode()

	local Properties = self.Properties;
	self.bUsable=0;
	self.bReloadGeoms = 1;
	self.lightOn = false;
	
	local hitPos = self.LastHit.pos;
	local hitImp = self.LastHit.impulse;
		
	self:BreakToPieces( 
		0, 0,
		Properties.Breakage.fExplodeImpulse,
		hitPos,
		hitImp,
		Properties.Breakage.fLifeTime, 
		Properties.Breakage.bSurfaceEffects
	);
	
	self:RemoveDecals();
	local bDeleteEntity = false;
		
	self:SetCurrentSlot(1);
	
	if (Properties.Model.object_ModelDestroyed ~="" or Properties.Model.SubObject_NameDestroyed ~="") then
		if (Properties.Physics.bRigidBodyAfterDeath == 1) then
			-- temprarolly set bRigidBody to 1, because EntityCommon checks it!
			local aux = Properties.Physics.bRigidBody;
			Properties.Physics.bRigidBody = 1;
			self:PhysicalizeThis(1);
			Properties.Physics.bRigidBody = aux;
			self:AwakePhysics(1);
		else
			self:PhysicalizeThis(1);
			self:AwakePhysics(1);
		end	
	else
		-- if No destroyed model, this entity must be killed.
		bDeleteEntity = true;
	end

	
	if (NumberToBool(self.Properties.Damage.bExplode)) then
		local expl = self.Properties.Explosion;
		
		local pos = self:GetWorldPos();
		local dirX = self:GetDirectionVector(0);
		local dirY = self:GetDirectionVector(1);
		local dirZ = self:GetDirectionVector(2);
		local offset={x=0,y=0,z=0};
		CopyVector(offset,expl.vOffset);
		
		pos.x = pos.x + dirX.x * offset.x + dirY.x * offset.y + dirZ.x * offset.z;
		pos.y = pos.y + dirX.y * offset.x + dirY.y * offset.y + dirZ.y * offset.z;
		pos.z = pos.z + dirX.z * offset.x + dirY.z * offset.y + dirZ.z * offset.z;
		local explo_pos=pos;
		
		-- calculate final explosion orientation
		local finalExploDir = g_Vectors.temp_v1;
		local exploDir = g_Vectors.temp_v2;
		CopyVector( exploDir, expl.Direction );
		if (exploDir.x==0 and exploDir.y==0 and exploDir.z==0) then
		  exploDir.y = 1;  --neutral direction
		end;
		finalExploDir.x = dirX.x * exploDir.x + dirY.x * exploDir.y + dirZ.x * exploDir.z;
		finalExploDir.y = dirX.y * exploDir.x + dirY.y * exploDir.y + dirZ.y * exploDir.z;
		finalExploDir.z = dirX.z * exploDir.x + dirY.z * exploDir.y + dirZ.z * exploDir.z;
		
		-- we create the effect independently from the actual explosion, to keep it attached to the object. That way, if the object moves after the explosion, the effect will move with it.
  	if(not EmptyString(expl.Effect))then
  	  local effectProps = 
  	  { 
  			Scale = expl.EffectScale,
  		};

  		local FXExplosionSlot = self:LoadParticleEffect( -1, expl.Effect, effectProps );
  		self:SetSlotPosAndDir( FXExplosionSlot, expl.vOffset, exploDir);
    end;
		
		g_gameRules:CreateExplosion(self.shooterId,self.id,expl.Damage,explo_pos,finalExploDir,expl.Radius,nil,expl.Pressure,expl.HoleSize, nil, nil, expl.MinRadius, expl.MinPhysRadius, expl.PhysRadius);
	end
	
	self.exploded = true;
	
	self:PlaySound( self.Properties.Sound.soundDestroy );
	
	-- ai sound event	
	local aiRadius = self.Properties.Sound.fAISoundRadius;
	if (aiRadius > 0) then
		if(self.shooterId) then
			AI.SoundEvent(self:GetWorldPos(), aiRadius, AISOUND_EXPLOSION, self.shooterId);
		else
			Log("AI.SoundEvent invalid parameter self.shooterId");
		end
	end
	BroadcastEvent( self,"Explode" );
	
	-- Must be in the last line.
	if (bDeleteEntity == true) then
		--self:DeleteThis();
		self:Hide(1);
	end
end


----------------------------------------------------------------------------------------------------
function DestroyableLight:Die(shooterId)
	self.shooterId = shooterId;
	self.dead = true;
	if (self.health > 0) then
		self.health = 0;
	end
	

	-- if we didn't explode yet
	if (not self.exploded) then
		local explosion=self.Properties.Explosion;
		if(explosion.Delay>0 and not explosion.DelayEffect.bHasDelayEffect==1)then
			self:SetTimer(0,explosion.Delay*1000);
		else
			self:GotoState("Dead");
		end
	end
end

----------------------------------------------------------------------------------------------------
function DestroyableLight:IsDead()
	return (self.health <= 0) or self.dead == true;
end

----------------------------------------------------------------------------------------------------
function DestroyableLight:GetHealth()
  return self.health;
end

----------------------------------------------------------------------------------------------------
function DestroyableLight.Server:OnHit(hit)
	if (hit.dir) then
		self:AddImpulse(hit.partId or -1,hit.pos,hit.dir, hit.damage, 1);
	end
		
	CopyVector(self.LastHit.pos, hit.pos);
	CopyVector(self.LastHit.impulse, hit.dir or g_Vectors.v000);
	self.LastHit.impulse.x = self.LastHit.impulse.x * hit.damage;
	self.LastHit.impulse.y = self.LastHit.impulse.y * hit.damage;
	self.LastHit.impulse.z = self.LastHit.impulse.z * hit.damage;
	
	local damage = hit.damage;	
	local vul = self.Properties.Vulnerability;
	local mult = self.Properties.DamageMultipliers;
	
	local pass = true;
	if (hit.explosion) then pass = NumberToBool(vul.bExplosion);
	elseif (hit.type=="collision") then pass = NumberToBool(vul.bCollision); damage = damage * mult.fCollision;
	elseif (hit.type=="bullet") then pass = NumberToBool(vul.bBullet); damage = damage * mult.fBullet;
	elseif (hit.type=="melee") then pass = NumberToBool(vul.bMelee); 
	else pass = NumberToBool(vul.bOther); end	
	
	pass = pass and damage > self.Properties.Damage.fDamageTreshold;	-- damage needs to be higher than treshold
	--Log("%s != %s", tostring(hit.shooterId), tostring(g_localActorId));

	-- damage must come from a player	---------------
	-- if (pass and NumberToBool(self.Properties.Damage.bPlayerOnly) and (not g_gameRules.game:IsPlayer(hit.shooterId)) ) then     
	-- 	 pass=false;
	-- end
	
	BroadcastEvent( self,"Hit" );

	if (pass) then
		self.health = self.health - damage;
	
		if (self.health <= 0) then
			self:Die(hit.shooterId);
		end
		
		if (NumberToBool(self.Properties.bActivateOnDamage)) then
			self:AwakePhysics(1);
		end		
		local explosion=self.Properties.Explosion;
		if(explosion.DelayEffect.bHasDelayEffect==1)then
			if(not self.FXSlot or self.FXSlot==(-1))then
				local rnd=randomF(0,1.5)
				--Log("Setting Delay on "..self:GetName()..": "..explosion.Delay+rnd);
				self:SetTimer(0,(explosion.Delay+rnd)*1000);
				if(not EmptyString(explosion.DelayEffect.Effect))then
					self.FXSlot=self:LoadParticleEffect( -1,explosion.DelayEffect.Effect,explosion.DelayEffect.Params);
					self:SetSlotPos(self.FXSlot,explosion.DelayEffect.vOffset);
					self:SetSlotAngles(self.FXSlot,explosion.DelayEffect.vRotation);
				end;
			end;
		end;
	end
	
	return (self.health <= 0);
end


----------------------------------------------------------------------------------------------------
function DestroyableLight.Server:OnTimer(timerId, msec)
	if (timerId == 0) then
		self:GotoState("Dead");
	end
end

----------------------------------------------------------------------------
function DestroyableLight:UseLight( lightIdx )
	local props;
	if( lightIdx == 0) then 
	 props = self.PropertiesInstance.LightProperties_Destroyed;
	else
	 props = self.PropertiesInstance.LightProperties_Base;
	end
	local Style = props.Style;
	local Projector = props.Projector;
	local Color = props.Color;
	local Options = props.Options;

	local diffuse_mul = Color.fDiffuseMultiplier;
	local specular_mul = Color.fSpecularMultiplier;
	
	local lt = self._LightTable;
	lt.style = Style.nLightStyle;
	lt.corona_scale = Style.fCoronaScale;
	lt.corona_dist_size_factor = Style.fCoronaDistSizeFactor;
	lt.corona_dist_intensity_factor = Style.fCoronaDistIntensityFactor;
	lt.rotation = Style.Rotation;
	lt.anim_speed = Style.fAnimationSpeed;
	lt.anim_phase = Style.nAnimationPhase;
	lt.attenuation_map = Style.texture_AttenuationMap;
	
	lt.radius = props.Radius;
	lt.diffuse_color = { x=Color.clrDiffuse.x*diffuse_mul, y=Color.clrDiffuse.y*diffuse_mul, z=Color.clrDiffuse.z*diffuse_mul };
	if (diffuse_mul ~= 0) then
		lt.specular_multiplier = specular_mul / diffuse_mul;
	else
		lt.specular_multiplier = 1;
	end
	
	lt.hdrdyn = Color.fHDRDynamic;
	lt.projector_texture = Projector.texture_Texture;
	lt.proj_fov = Projector.fProjectorFov;
	lt.proj_nearplane = Projector.fProjectorNearPlane;
	lt.cubemap = Projector.bProjectInAllDirs;
	lt.this_area_only = Options.bAffectsThisAreaOnly;
	lt.hasclipbound = Options.bDeferredClipBounds;
	lt.ignore_visareas = Options.bIgnoresVisAreas;
	lt.disable_x360_opto = Options.bDisableX360Opto;
	lt.realtime = Options.bUsedInRealTime;
	lt.ambient_light = Options.bAmbientLight;		
	lt.irradiance_volumes = Options.bIrradianceVolumes;
	lt.deferred_cubemap = Options.texture_deferred_cubemap;
	lt.deferred_geom = Options.file_deferred_clip_geom;
	lt.heatsource = 0;
	lt.fake = Options.bFakeLight;
	lt.deferred_light = Options.bDeferredLight;
	lt.fill_light = props.Test.bFillLight;		
	lt.indoor_only = 0;
	lt.has_cbuffer = 0;
	lt.cast_shadow = Options.nCastShadows;
	lt.shadow_bias = Options.fShadowBias;
	lt.shadow_slope_bias = Options.fShadowSlopeBias;
	lt.post_effect = Options.nPostEffect;

	lt.shadowUpdate_MinRadius = Options.fShadowUpdateMinRadius;
	lt.shadowUpdate_ratio = Options.fShadowUpdateRatio;

	lt.lightmap_linear_attenuation = 1;
	lt.is_rectangle_light = 0;
	lt.is_sphere_light = 0;
	lt.area_sample_number = 1;
	
	lt.RAE_AmbientColor = { x = 0, y = 0, z = 0 };
	lt.RAE_MaxShadow = 1;
	lt.RAE_DistMul = 1;
	lt.RAE_DivShadow = 1;
	lt.RAE_ShadowHeight = 1;
	lt.RAE_FallOff = 2;
	lt.RAE_VisareaNumber = 0;

  	lt.viewDistRatio = Options.nViewDistRatio;
	self.lightSlot = self:LoadLight( -1 ,lt );
	local angles = g_Vectors.temp_v1;
  	angles.x = 0;
  	local xyVectorLen = math.sqrt( props.vDirection.x*props.vDirection.x + props.vDirection.y*props.vDirection.y );
  	angles.y = math.atan2( -props.vDirection.z, xyVectorLen );
  	angles.z = math.atan2( props.vDirection.y, props.vDirection.x );
	self:SetSlotAngles(self.lightSlot, angles );
	local vec3offset = g_Vectors.temp_v1;
	vec3offset.x = props.vOffset.x;
	vec3offset.y = props.vOffset.y;
	vec3offset.z = props.vOffset.z;
	self:SetSlotPos(self.lightSlot, vec3offset );
	
	if ((Options.nCastShadows ~= 0) and (Options.bIgnoreGeomCaster ~= 0)) then
		self:SetSelfAsLightCasterException( self.lightSlot );
	end
end

------------------------------------------------------------------------------
function DestroyableLight:SwitchOnOffChildren( wantOn )
	local numChildren = self:GetChildCount();
	for i=0,numChildren do
		local child = self:GetChild(i);
		if (child and child.NotifySwitchOnOffFromParent) then
			child:NotifySwitchOnOffFromParent( wantOn )
		end
	end
end

function DestroyableLight:NotifySwitchOnOffFromParent( wantOn )
  self:SwitchOnOff( wantOn );
end


function DestroyableLight:SwitchOnOff( wantOn )
	if (not self.dead) then
	  local wantOff = wantOn~=true;
	  if (self.lightOn and wantOff ) then
		  self.lightOn = false;
			self:PlaySound( self.Properties.Sound.soundTurnOff );
		  BroadcastEvent( self, "LightOff" );
		  self:ShowCorrectLight();
		  self:SwitchOnOffChildren( wantOn );
		elseif (self.lightOn~=true and wantOn) then
      self.lightOn = true;
			self:PlaySound( self.Properties.Sound.soundTurnOn );
  	  BroadcastEvent( self, "LightOn" );
		  self:ShowCorrectLight();
		  self:SwitchOnOffChildren( wantOn );
		end
  end
end

----------------------------------------------------------------------------------------------------
-- Alive State
----------------------------------------------------------------------------------------------------
DestroyableLight.Client.Alive =
{
	OnBeginState=function(self)
		self:ShowCorrectLight();
	end,
	
	OnLevelLoaded=function(self)
  	if (self.PropertiesInstance.LightProperties_Base.Options.bDeferredClipBounds) then
		  self:UpdateLightClipBounds(self.lightSlot);
		 end
	end,
	
}
DestroyableLight.Server.Alive =
{
	OnTimer = function(self,timerId,msec)
		if (timerId == 0) then
			self:GotoState( "Dead" );
		end
	end,
	
	OnLevelLoaded=function(self)
  	if (self.PropertiesInstance.LightProperties_Base.Options.bDeferredClipBounds) then
		  self:UpdateLightClipBounds(self.lightSlot);
		 end
	end,
}


----------------------------------------------------------------------------------------------------
-- Dead State
----------------------------------------------------------------------------------------------------
DestroyableLight.Client.Dead =
{
	OnBeginState=function(self)
		self:SwitchOnOff(false);
		self:ShowCorrectLight();
		if (not CryAction.IsServer()) then
			self:RemoveEffect();
			self:Explode();
			self.dead = true;	
		end
	end,
}
DestroyableLight.Server.Dead =
{
	OnBeginState=function(self)
		self:RemoveEffect();
		self:Explode();
		self.dead = true;
	end,
}

----------------------------------------------------------------------------------------------------
function DestroyableLight:Event_Reset( sender )
	self:OnReset();
	BroadcastEvent( self,"Reset" );
end

----------------------------------------------------------------------------------------------------
function DestroyableLight:Event_Hit( sender )
	BroadcastEvent( self,"Hit" );
end

----------------------------------------------------------------------------------------------------
function DestroyableLight:Event_Explode( sender )
	if self:GetState()=="Dead" then return end
	if self.exploded then return end

	BroadcastEvent( self,"Explode" );
	BroadcastEvent( self, "Break" )

	self:Die(NULL_ENTITY);
end

------------------------------------------------------------------------------------------------------
function DestroyableLight.Client:OnPhysicsBreak( vPos,nPartId,nOtherPartId )
	self:ActivateOutput("Break",nPartId+1 );
end


------------------------------------------------------------------------------------------------------
function DestroyableLight:Event_Hide()
	self:Hide(1);
	BroadcastEvent( self, "Hide" );
	--self:DrawObject(0,0);
	--self:DestroyPhysics();
end

------------------------------------------------------------------------------------------------------
function DestroyableLight:Event_UnHide()
	self:Hide(0);
	BroadcastEvent( self, "UnHide" );
	--self:DrawObject(0,1);
	--self:SetPhysicsProperties( 1,self.bRigidBodyActive );
end


------------------------------------------------------------------------------------------------------
function DestroyableLight:Event_LightOn()
  self:SwitchOnOff( true );
end


------------------------------------------------------------------------------------------------------
function DestroyableLight:Event_LightOff()
  self:SwitchOnOff( false );
end


------------------------------------------------------------------------------------------------------
function DestroyableLight:ShowLightOn()
	-- light source --
	if (self.lightSlot ~= (-1)) then
		self:FreeSlot(self.lightSlot);
		self.lightSlot = -1;
	end
	if (self.PropertiesInstance.LightProperties_Base.bUseThisLight ~= 0) then
		self:UseLight(1);
	end

	-- glow effect --
	local glowVal = self:GetMaterialFloat(0, self.PropertiesInstance.LightProperties_Base.Options.nGlowSubmatId, "glow" );
	if (glowVal~=self.origGlowValue and self.origGlowValue and self.materialIsCloned) then
		self:SetMaterialFloat(0, self.PropertiesInstance.LightProperties_Base.Options.nGlowSubmatId, "glow", self.origGlowValue );
	end
end


------------------------------------------------------------------------------------------------------
function DestroyableLight:ShowLightOff()

	-- light source --
	if (self.lightSlot ~= (-1)) then
		self:FreeSlot(self.lightSlot);
		self.lightSlot = -1;
	end
	if (self.PropertiesInstance.LightProperties_Destroyed.bUseThisLight ~= 0) then
		self:UseLight(0);
	end


	-- glow effect --
	local currentGlow = self:GetMaterialFloat(0, self.PropertiesInstance.LightProperties_Base.Options.nGlowSubmatId, "glow" );

	if (currentGlow>0) then  
		if (not self.materialIsCloned) then
			self:CloneMaterial(0);
			self.materialIsCloned = true;
		end
  
		self:SetMaterialFloat(0, self.PropertiesInstance.LightProperties_Base.Options.nGlowSubmatId, "glow", 0.0001 );  -- if we use 0 and we clone the material, the glow is forever lost. Not sure if this is intended.
	end
end


function DestroyableLight:PlaySound( soundName )
	if ( soundName and soundName~="") then
		local sndFlags=SOUND_DEFAULT_3D;
		self:PlaySoundEvent( soundName, self.Properties.Sound.vOffset,g_Vectors.v010,sndFlags, 0, SOUND_SEMANTIC_MECHANIC_ENTITY);
	end
end

function DestroyableLight:PlaySoundLoop( soundName )
	if ( soundName and soundName~="") then
		local sndFlags=SOUND_DEFAULT_3D;
		sndFlags = bor( sndFlags, FLAG_SOUND_LOOP );
		local id = self:PlaySoundEvent( soundName, self.Properties.Sound.vOffset,g_Vectors.v010,sndFlags, 0, SOUND_SEMANTIC_MECHANIC_ENTITY);
		return id;
	end
end

function DestroyableLight:PlayIdleSound()
	if (self.idleSoundId==0) then
		self.idleSoundId = self:PlaySoundLoop( self.Properties.Sound.soundIdle );
  end
end

function DestroyableLight:PlayRunSound()
	if (self.runSoundId==0) then
		self.runSoundId = self:PlaySoundLoop( self.Properties.Sound.soundRun );
  end
end

function DestroyableLight:StopIdleSound()
	if (self.idleSoundId~=0) then
		Sound.StopSound(self.idleSoundId);
		self.idleSoundId = 0;
	end
end

function DestroyableLight:StopRunSound()
	if (self.runSoundId~=0) then
		Sound.StopSound(self.runSoundId);
		self.runSoundId = 0;
	end
end


function DestroyableLight:OnEditorSetGameMode(gameMode)
	if (gameMode~=true) then
		self:StopIdleSound();
		self:StopRunSound();
	end
end



----------------------------------------------------------------------------------------------------
function DestroyableLight:ShowCorrectLight()
  if (self.lightOn and not self.dead) then
  	self:StopIdleSound();
  	self:PlayRunSound();
    self:ShowLightOn();
  else
    self:ShowLightOff();
  	self:StopRunSound();
    if (self.dead) then
      self:StopIdleSound();
    else
    	self:PlayIdleSound();
    end
  end
end



DestroyableLight.FlowEvents =
{
	Inputs =
	{
		Explode = { DestroyableLight.Event_Explode, "bool" },
		Reset = { DestroyableLight.Event_Reset, "bool" },
		Used = { DestroyableLight.Event_Used, "bool" },
		EnableUsable = { DestroyableLight.Event_EnableUsable, "bool" },
		DisableUsable = { DestroyableLight.Event_DisableUsable, "bool" },
		Hit = { DestroyableLight.Event_Hit, "bool" },
		Hide = { DestroyableLight.Event_Hide, "bool" },
		UnHide = { DestroyableLight.Event_UnHide, "bool" },
		LightOn = { DestroyableLight.Event_LightOn, "bool" },
		LightOff = { DestroyableLight.Event_LightOff, "bool" },
	},
	Outputs =
	{
		Explode = "bool",
		Reset = "bool",
		Used = "bool",
		EnableUsable = "bool",
		DisableUsable = "bool",
		Hit = "bool",
		Hide = "bool",
		UnHide = "bool",
		Break = "int",
		LightOn = "bool",
		LightOff = "bool",
	},
}

MakeUsable(DestroyableLight);

----------------------------------------------------------------------------------------------------
function DestroyableLight:IsUsable(user)

	local ret = nil
	if (not self.bUsable) then
	  self.bUsable = self.Properties.bUsable;
	end
	
	if (self.bUsable == 1) then
		ret = 2
	else
		local PhysProps = self.Properties.Physics;
		if (PhysProps.bRigidBody == 1 and PhysProps.bRigidBodyActive == 1 and user.CanGrabObject) then
			ret = user:CanGrabObject(self);
		end
	end
		
	return ret or 0
end

function DestroyableLight:OnUsed(user, idx)
	BroadcastEvent(self, "Used")
	if (not self.dead) then
	  local wantOn = self.lightOn==false;
	  self:SwitchOnOff( wantOn );
	end
end



MakePickable(DestroyableLight);
--MakeInterestingToAI(DestroyableLight, 1);
--MakeTargetableByAI(DestroyableLight);
--MakeKillable(DestroyableLight);


function DestroyableLight:Event_Dead()
  self:Die();
	self:TriggerEvent(AIEVENT_DISABLE);
	BroadcastEvent(self, "Dead");
end
