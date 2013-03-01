InteractiveEntity = {
	Client = {},
	Server = {},
	Properties = {
		fileModel = "objects/props/misc/vending_machine/vending_machine.cgf",
		ModelSubObject = "",
		fileModelDestroyed = "",
		DestroyedSubObject = "",
		bTurnedOn = 0,
		bUsable = 1,
		bTwoState = 0,
		UseMessage = "Use",
		OnUse = {
			fUseDelay = 0,
			fCoolDownTime = 0.1,
			bEffectOnUse = 0,
			bSoundOnUse = 1,
			bSpawnOnUse = 0,
			bChangeMatOnUse = 0,
		},
		Sound = {
			soundSound = "sounds/vehicles:vehicle_accessories:light",
			soundTurnOnSound = "",
			soundTurnOffSound = "",
		},
		Effect = {
			ParticleEffect="",
			bPrime=0,
			Scale=1,
			CountScale=1,
			bCountPerUnit=0,
			AttachType="",
			AttachForm="Surface",
			PulsePeriod=0,
			SpawnPeriod=0,
			vOffset = {x=0, y=0, z=0},
			vRotation = {x=0, y=0, z=0},
		},
		fHealth = 100,
		Physics = {
			bRigidBody=1,
			bRigidBodyActive = 1,
			bResting = 1,
			Density = -1,
			Mass = 300,
		Buoyancy = {
				water_density = 1000,
				water_damping = 0,
				water_resistance = 1000,
			},
			bStaticInDX9Multiplayer = 1,
		},
		Breakage = {
			fLifeTime = 10,
			fExplodeImpulse = 0,
			bSurfaceEffects = 1,
		},
		Destruction = {
			bExplode = 1,
			Effect = "explosions.monitor.a",
			EffectScale = 1,
			Radius = 0,
			Pressure = 0,
			Damage = 0,
			Decal = "",
			Direction = {x=0, y=0.2, z=1},
			vOffset = {x=0, y=0, z=0},
		},
		Vulnerability = {
			fDamageTreshold = 0,
			bExplosion = 0,
			bCollision = 0,
			bMelee = 0,
			bBullet = 0,
			bOther = 0,
		},
		SpawnEntity = {
			iSpawnLimit = 1,
			Archetype = "Props.gas_station.can_a",
			vOffset = {x=0, y=0, z=0},
			vRotation = {x=0, y=0, z=0},
			fImpulse = 1,
			vImpulseDir= {x=0, y=0, z=1},
		},
		ChangeMaterial = {
			fileMaterial = "",
			Duration = 0,
		},
		ScreenFunctions = {
			bHasScreenFunction = 0,
			FlashMatId = -1,
			Type = {
				bProgressBar = 0,
			},
		},
	},
		Editor = {
		Icon = "Item.bmp",
		IconOnTop=1,
	},
	LastHit = {
		impulse = {x=0,y=0,z=0},
		pos = {x=0,y=0,z=0},
	},
	States = {"TurnedOn","TurnedOff","Destroyed"},
	health = 0,
	soundid = nil,
	turnoffsoundid = nil,
	FXSlot = -1,
	spawncount = 0,
	iDelayTimer = -1,
	iCoolDownTimer = -1,
	iTurnOffSoundTimer = -1,
	bCoolDown = 0,
	shooterId = 0,
	currentMat = nil,
	MatResetTimer = nil,
	progress = 0,
}

MakePickable(InteractiveEntity);
MakeInterestingToAI(InteractiveEntity, 1);

local Physics_DX9MP_Simple = {
	bPhysicalize = 1, -- True if object should be physicalized at all.
	bPushableByPlayers = 0,
	Density = -1,
	Mass = -1,
	bStaticInDX9Multiplayer = 1,
}

function InteractiveEntity:OnPropertyChange()
	self:OnReset();
end;

function InteractiveEntity:OnSave(tbl)
	tbl.health=self.health;
	tbl.FXSlot=self.FXSlot;
	tbl.spawncount=self.spawncount;
	tbl.iDelayTimer=self.iDelayTimer;
	tbl.iCoolDownTimer=self.iCoolDownTimer;
	tbl.bCoolDown=self.bCoolDown;
	tbl.currentMat=self.currentMat;
	tbl.MatResetTimer=self.MatResetTimer;
	tbl.progress=self.progress;
	tbl.bUsable=self.bUsable;
	tbl.material=self:GetMaterial(0);
end;

function InteractiveEntity:OnLoad(tbl)
	self.health=tbl.health;
	self.FXSlot=tbl.FXSlot;
	self.spawncount=tbl.spawncount;
	self.iDelayTimer=tbl.iDelayTimer;
	self.iCoolDownTimer=tbl.iCoolDownTimer;
	self.bCoolDown=tbl.bCoolDown;
	self.currentMat=tbl.currentMat;
	self.MatResetTimer=tbl.MatResetTimer
	self.progress=tbl.progress;
	self.bUsable=tbl.bUsable;
	self:SetMaterial(tbl.material);
	local props=self.Properties.ScreenFunctions;
	if((props.bHasScreenFunction==1)and (props.Type.bProgressBar==1))then
		self:MaterialFlashInvoke(0,props.FlashMatId,0,"SetProgress",self.progress)
	end;
end;

function InteractiveEntity:OnReset()
	if(self.MatResetTimer~=nil)then
		Script.KillTimer(self.MatResetTimer);
		self.MatResetTimer=nil;
	end;
	self:ResetMaterial(0);
	self:Stop(0);
	self:RemoveEffect();
	self.spawncount=0;
	local props=self.Properties;
	if(not EmptyString(props.fileModel))then
		self:LoadSubObject(0,props.fileModel,props.ModelSubObject);
	end;
	if(not EmptyString(props.fileModelDestroyed))then
		self:LoadSubObject(1, props.fileModelDestroyed,props.DestroyedSubObject);
	elseif(not EmptyString(props.DestroyedSubObject))then
		self:LoadSubObject(1,props.fileModel,props.DestroyedSubObject);
	end;
	self:SetCurrentSlot(0);
	self:PhysicalizeThis(0);
	self.health=self.Properties.fHealth;
	if(self.Properties.bTurnedOn==1)then
		self:GotoState("TurnedOn");
	else
		self:GotoState("TurnedOff");
	end;
	self.progress=0;
	self.bUsable=self.Properties.bUsable;
	local props=self.Properties.ScreenFunctions;
	if((props.bHasScreenFunction==1)and (props.Type.bProgressBar==1))then
		self:MaterialFlashInvoke(0,props.FlashMatId,0,"SetProgress",0)
	end;
end;

function InteractiveEntity:PhysicalizeThis(slot)
	local physics = self.Properties.Physics;
	if (CryAction.IsImmersivenessEnabled() == 0) then
		physics = Physics_DX9MP_Simple;
	end
	EntityCommon.PhysicalizeRigid( self,slot,physics,1 );

	if (physics.Buoyancy) then
		self:SetPhysicParams(PHYSICPARAM_BUOYANCY, physics.Buoyancy);
	end
end;

function InteractiveEntity.Server:OnHit(hit)
	local vul=self.Properties.Vulnerability;
	local pass=hit.damage >= self.Properties.Vulnerability.fDamageTreshold;
	if (pass and hit.explosion) then pass = NumberToBool(vul.bExplosion);
	elseif (pass and hit.type=="collision") then pass = NumberToBool(vul.bCollision);
	elseif (pass and hit.type=="bullet") then pass = NumberToBool(vul.bBullet);
	elseif (pass and hit.type=="melee") then pass = NumberToBool(vul.bMelee);
	elseif (pass) then pass = NumberToBool(vul.bOther); end

	if(pass)then
		local damage= hit.damage;
		self.shooterId=hit.shooterId;
		BroadcastEvent( self,"Hit" );
		self.health=self.health-damage;
		if(self.health<=0 and CryAction.IsImmersivenessEnabled()~=0)then
			self:GotoState("Destroyed");
		end;
	end;
end;

function InteractiveEntity.Client:OnHit(hit, remote)
	CopyVector(self.LastHit.pos, hit.pos);
	CopyVector(self.LastHit.impulse, hit.dir);
	self.LastHit.impulse.x = self.LastHit.impulse.x * hit.damage;
	self.LastHit.impulse.y = self.LastHit.impulse.y * hit.damage;
	self.LastHit.impulse.z = self.LastHit.impulse.z * hit.damage;
end

function InteractiveEntity:OnUsed(user, idx)
	if(self.bUsable==0)then return;end;
	local UseProps=self.Properties.OnUse;
	if(self.bCoolDown==0)then
		if(self.iDelayTimer== -1)then
			if(UseProps.fUseDelay>0)then
				self.iDelayTimer=Script.SetTimerForFunction(UseProps.fUseDelay*1000,"InteractiveEntity.Use",self);
			else
				self:Use(user, idx);
			end;
		end;
	end;
end;

InteractiveEntity.ResetMat = function(self)
	self:SetMaterial(self.currentMat);
	self.MatResetTimer=nil;
end;

InteractiveEntity.EndCoolDown = function(self)
	self.bCoolDown=0;
end;

InteractiveEntity.Use = function(self)
	local UseProps=self.Properties.OnUse;
	self.iDelayTimer= -1;
	self.iCoolDownTimer= -1;
	if(UseProps.fCoolDownTime~=0)then
		self.bCoolDown=1;
		self.iCoolDownTimer=Script.SetTimerForFunction(UseProps.fCoolDownTime*1000,"InteractiveEntity.EndCoolDown",self);
	end;
	self:ActivateOutput("Used",true);
	if(self.Properties.bTwoState~=0)then
		if(self:GetState()=="TurnedOn")then
			self:Stop(1);
			self:GotoState("TurnedOff");
		elseif(self:GetState()=="TurnedOff")then
			self:GotoState("TurnedOn");
		elseif(self:GetState()=="Destroyed")then
			return
		end;
	else
		self:Play();
		self:DoEffect();
		self:DoSpawn();
		self:DoMaterialChange();
	end;
end;


function InteractiveEntity:IsUsable(user)
	local mp = System.IsMultiplayer();
	if(mp and mp~=0) then
		return 0;
	end

	if((self.bUsable==1) and (self:GetState()~="Destroyed"))then
		return 2;
	else
		return 0;
	end;
	
end;

function InteractiveEntity:GetUsableMessage(idx)
	if(self.bUsable==1)then
		return self.Properties.UseMessage;
	else
		return "@grab_object";
	end;
end;

function InteractiveEntity:DoSpawn()
	if(not CryAction.IsGameStarted()) then return; end
	if(self.Properties.OnUse.bSpawnOnUse~=1)then return;end
	--Better limit to 20, who knows what designers will do.
	if((self.spawncount>=self.Properties.SpawnEntity.iSpawnLimit) or (self.spawncount>=20))then return;end;
	local props=self.Properties.SpawnEntity;
	local spawnParams = {};
	spawnParams.class = "BasicEntity";
	spawnParams.archetype=props.Archetype;
	spawnParams.name = self:GetName().."_spawnedentity_"..self.spawncount;
	spawnParams.flags = 0;
	spawnParams.orientation = {x=0,y=0,z=0};
	spawnParams.position=self:GetPos();
	spawnParams.scale = nil;
	local spawnedEntity = System.SpawnEntity(spawnParams);
	self.spawncount=self.spawncount+1;
	if(spawnedEntity~=nil)then
		spawnedEntity.health=5;

		local pos = self:GetWorldPos();
		local dirX = self:GetDirectionVector(0);
		local dirY = self:GetDirectionVector(1);
		local dirZ = self:GetDirectionVector(2);
		local offset= g_Vectors.temp_v1;

		CopyVector(offset,self.Properties.SpawnEntity.vOffset);

		pos.x = pos.x + dirX.x * offset.x + dirY.x * offset.y + dirZ.x * offset.z;
		pos.y = pos.y + dirX.y * offset.x + dirY.y * offset.y + dirZ.y * offset.z;
		pos.z = pos.z + dirX.z * offset.x + dirY.z * offset.y + dirZ.z * offset.z;

		spawnedEntity:SetWorldPos(pos);
		spawnedEntity:SetAngles(self.Properties.SpawnEntity.vRotation);
		if(props.fImpulse>0)then
			spawnedEntity:AddImpulse(-1,spawnedEntity:GetPos(),props.vImpulseDir,props.fImpulse,1);
		end;
	end;
end;

function InteractiveEntity:DoMaterialChange()
	if(self.Properties.OnUse.bChangeMatOnUse~=1)then return;end;
	local mat=self.Properties.ChangeMaterial.fileMaterial;
	if(not EmptyString(mat))then
		self.currentMat=self:GetMaterial(0);
		self:SetMaterial(mat);
		--If not TwoState check and set timer
		if(self.Properties.bTwoState~=1)then
			if(self.Properties.ChangeMaterial.Duration~=0)then
				if(self.MatResetTimer==nil)then
					self.MatResetTimer=Script.SetTimerForFunction(self.Properties.ChangeMaterial.Duration*1000,"InteractiveEntity.ResetMat",self);
				end;
			end;
		end;
	end;
end;

function InteractiveEntity:DoEffect()
	if(self.Properties.OnUse.bEffectOnUse~=1)then return;end;
	local fx=self.Properties.Effect.ParticleEffect;
	if(not EmptyString(fx))then
		self.FXSlot=self:LoadParticleEffect( -1, self.Properties.Effect.ParticleEffect,self.Properties.Effect);
		self:SetSlotPos(self.FXSlot,self.Properties.Effect.vOffset);
		self:SetSlotAngles(self.FXSlot,self.Properties.Effect.vRotation);
	end;
end;

function InteractiveEntity:RemoveEffect()
	self:FreeSlot(self.FXSlot);
	self.FXSlot= -1;
end;

function InteractiveEntity:Play()
	if(self.Properties.OnUse.bSoundOnUse~=1)then return;end
	self:Stop(0);
	local snd=self.Properties.Sound.soundSound;
	local on=self.Properties.Sound.soundTurnOnSound;
	local sndFlags=bor(SOUND_DEFAULT_3D, 0);
	if(on~="")then
			self.soundid=self:PlaySoundEvent(on,g_Vectors.v000,g_Vectors.v010,sndFlags, 0, SOUND_SEMANTIC_MECHANIC_ENTITY);
	end;
	if(snd~="")then
			self.soundid=self:PlaySoundEvent(snd,g_Vectors.v000,g_Vectors.v010,sndFlags, 0, SOUND_SEMANTIC_MECHANIC_ENTITY);
	end;
end;

function InteractiveEntity:Stop(stopsound)
	if(self.soundid~=nil)then
		Sound.StopSound(self.soundid);
		self.soundid=nil;
	end;
	if(stopsound==1)then
		local snd=self.Properties.Sound.soundTurnOffSound;
		local sndFlags=bor(SOUND_DEFAULT_3D,0);
		self.turnoffsoundid=self:PlaySoundEvent(snd,g_Vectors.v000,g_Vectors.v010,sndFlags, 0, SOUND_SEMANTIC_MECHANIC_ENTITY);
	end;
end;

function InteractiveEntity:Explode()
	local props=self.Properties;
	local hitPos = self.LastHit.pos;
	local hitImp = self.LastHit.impulse;

	self:BreakToPieces( 
		0, 0,
		props.Breakage.fExplodeImpulse,
		hitPos,
		hitImp,
		props.Breakage.fLifeTime, 
		props.Breakage.bSurfaceEffects
	);
	self:Stop(0);
	if(NumberToBool(self.Properties.Destruction.bExplode))then
		local explosion=self.Properties.Destruction;

		local pos = self:GetWorldPos();
		local dirX = self:GetDirectionVector(0);
		local dirY = self:GetDirectionVector(1);
		local dirZ = self:GetDirectionVector(2);
		local offset={x=0,y=0,z=0};
		CopyVector(offset,explosion.vOffset);

		pos.x = pos.x + dirX.x * offset.x + dirY.x * offset.y + dirZ.x * offset.z;
		pos.y = pos.y + dirX.y * offset.x + dirY.y * offset.y + dirZ.y * offset.z;
		pos.z = pos.z + dirX.z * offset.x + dirY.z * offset.y + dirZ.z * offset.z;
		local explo_pos=pos;

		g_gameRules:CreateExplosion(self.shooterId,self.id,explosion.Damage,explo_pos,explosion.Direction,explosion.Radius,nil,explosion.Pressure,explosion.HoleSize,explosion.Effect,explosion.EffectScale);
	end;
	self:RemoveDecals();
	self:SetCurrentSlot(1);
	self:PhysicalizeThis(1);
	self:AwakePhysics(1);
end;

----------------------------------------------------------------------------------------------------
function InteractiveEntity:SetProgress()
	if(self:GetState()~="Destroyed")then
		local props=self.Properties.ScreenFunctions;
		if((props.bHasScreenFunction==1)and (props.Type.bProgressBar==1))then
			if(self.progress<=100)then
				if(self:MaterialFlashInvoke(0,props.FlashMatId,0,"SetProgress",self.progress)=="")then
					Log("Invalid Material ID! ID"..props.FlashMatId.."on Entity "..self:GetName().." is not a flash material.");
				end;
				self.progress=self.progress+1;
				self:ActivateOutput("Progress",self.progress);
			end;
		else
			Log("No Progressbar Type!");
		end;
	end;
end;

function InteractiveEntity:SetCurrentSlot(slot)
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
function InteractiveEntity.Server:OnInit()
	if(not self.bInitialized)then
		self:OnReset();
		self.bInitialized=1;
	end;
	
end;

----------------------------------------------------------------------------------------------------
function InteractiveEntity.Client:OnInit()
	if(not self.bInitialized)then
		self:OnReset();
		self.bInitialized=1;
	end;
end;


----------------------------------------------------------------------------------
------------------------------------Events----------------------------------------
----------------------------------------------------------------------------------
function InteractiveEntity:Event_TurnedOn()
	BroadcastEvent(self, "TurnedOn");
	self:GotoState("TurnedOn");
end;

function InteractiveEntity:Event_TurnedOff()
	BroadcastEvent(self, "TurnedOff");
	self:GotoState("TurnedOff");
end;

function InteractiveEntity:Event_Destroyed()
	BroadcastEvent(self, "Destroyed");
	self:GotoState("Destroyed");
end;

function InteractiveEntity:Event_Hit(sender)
	BroadcastEvent( self,"Hit" );
end;

function InteractiveEntity:Event_SetProgress()
	--Fix
	self:SetProgress();
end;

function InteractiveEntity:Event_ResetProgress()
	self.progress=0;
	local props=self.Properties.ScreenFunctions;
	if((props.bHasScreenFunction==1)and (props.Type.bProgressBar==1))then
		self:MaterialFlashInvoke(0,props.FlashMatId,0,"SetProgress",0)
	end;
end;

function InteractiveEntity:Event_Use(sender)
	self:OnUsed(self,0);
end;

function InteractiveEntity:Event_Hide()
	self:Hide(1);
end;

function InteractiveEntity:Event_UnHide()
	self:Hide(0);
end;

function InteractiveEntity:Event_EnableUsable()
	self.bUsable=1;
	--self.Properties.bUsable=1;
end;

function InteractiveEntity:Event_DisableUsable()
	self.bUsable=0;
	--self.Properties.bUsable=0;
end;

----------------------------------------------------------------------------------
------------------------------------States----------------------------------------
----------------------------------------------------------------------------------

InteractiveEntity.Server.TurnedOn =
{
	OnBeginState = function( self )
		self:Play();
		self:DoEffect();
		self:DoSpawn();
		self:DoMaterialChange();
		BroadcastEvent(self, "TurnedOn")
	end,
	OnEndState = function( self )

	end,
}

InteractiveEntity.Server.TurnedOff =
{
	OnBeginState = function( self )
		self:RemoveEffect();
		if(self.currentMat~=nil)then
			self:SetMaterial(self.currentMat);
		end;
		BroadcastEvent(self, "TurnedOff")
	end,
	OnEndState = function( self )

	end,
}

InteractiveEntity.Server.Destroyed=
{
	OnBeginState = function( self )
		self:RemoveEffect();
		self:Explode();
		self:ActivateOutput("Destroyed",1);
	end,
	OnEndState = function( self )

	end,
}

----------------------------------------------------------------------------------
-------------------------------Flow-Graph Ports-----------------------------------
----------------------------------------------------------------------------------

InteractiveEntity.FlowEvents =
{
	Inputs =
	{
		TurnedOn = { InteractiveEntity.Event_TurnedOn, "bool" },
		TurnedOff = { InteractiveEntity.Event_TurnedOff, "bool" },
		Destroyed = { InteractiveEntity.Event_Destroyed, "bool" },
		Hit = { InteractiveEntity.Event_Hit, "bool" },
		SetProgress = { InteractiveEntity.Event_SetProgress, "bool" },
		ResetProgress = { InteractiveEntity.Event_ResetProgress, "bool" },
		Use = { InteractiveEntity.Event_Use, "bool" },
		Hide = { InteractiveEntity.Event_Hide, "bool" },
		UnHide = { InteractiveEntity.Event_UnHide, "bool" },
		EnableUsable = { InteractiveEntity.Event_EnableUsable, "bool" },
		DisableUsable = { InteractiveEntity.Event_DisableUsable, "bool" },
	},
	Outputs =
	{
		TurnedOn = "bool",
		TurnedOff = "bool",
		Destroyed = "bool",
		Hit = "bool",
		Progress = "float",
		Used = "bool",
	},
}