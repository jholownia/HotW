--------------------------------------------------------------------------
--	Crytek Source File.
-- 	Copyright (C), Crytek Studios, 2001-2005.
--------------------------------------------------------------------------
--
--	Description: BasicAI should contain all shared AI functionality for 
--	actors 
--  
--------------------------------------------------------------------------
--  History:
--	Created by Petar
--  - 13/06/2005   15:36 : Kirill - cleanup
--
--------------------------------------------------------------------------

Script.ReloadScript( "SCRIPTS/Entities/AI/Shared/BasicAITable.lua");
Script.ReloadScript( "SCRIPTS/Entities/AI/Shared/BasicAIEvent.lua");
Script.ReloadScript("Scripts/AI/anchor.lua");


BasicAI = {
	ai=1,
------------------------------------------------------------------------------------
------------------------------------------------------------------------------------

	primaryWeapon = "FY71",
	secondaryWeapon = "SOCOM",

	Behavior = {
	},

	onAnimationStart = {},
	onAnimationEnd = {},
	onAnimationKey = {},
	
	Server = {
		OnHit = function(self, hit)
			if (self.PropertiesInstance.AI.bHostileIfAttacked and (tonumber(self.PropertiesInstance.AI.bHostileIfAttacked) ~= 0)) then
				if (hit.shooterId and not AI.Hostile(self.id, hit.shooterId)) then
					AI.AddPersonallyHostile(self.id, hit.shooterId)
				end
			end
			return BasicActor.Server.OnHit(self, hit)
		end	
	},
	Client = {},
	lastSplash = 0,
	
	Editor={
		Icon="User.bmp",
		IconOnTop=1,
	},
	
	SuitMode ={
		SUIT_OFF=0,
		SUIT_ARMOR=1,		
		SUIT_CLOAK=2,
		SUIT_POWER=3,
		SUIT_SPEED=4,				
	}
}

--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------
function BasicAI:OnPropertyChange()
	--do not rephysicalize at each property change

	local forceResetAI = System.IsEditor();
	self:RegisterAI(forceResetAI);
	self:OnReset();

end


----------------------------------------------------------------------------------------------------
function BasicAI:OnLoadAI(saved)


--	AI.RegisterWithAI(self.id, AIOBJECT_ACTOR, self.Properties, self.PropertiesInstance, self.AIMovementAbility);
--	AI.ChangeParameter(self.id,AIPARAM_COMBATCLASS,AICombatClasses.Infantry);

	self.AI = {};
	if(saved.AI) then 
		self.AI = saved.AI;
	end

	if(saved.Events) then 
--		self.Events = saved.Events;
		self.Events = {};
		local evts = self.Events;
		for name, data in pairs(saved.Events) do
			local eventTargets = saved.Events[name];
			if not evts[name] then evts[name] = {} end			
			for i, target in pairs(eventTargets) do
				local TargetId = target[1];
				local TargetEvent = target[2];			
				table.insert(evts[name], {TargetId, TargetEvent})
			end	
		end
	else
		self.Events = nil;
	end

	if(saved.spawnedEntity) then
		self.spawnedEntity = saved.spawnedEntity;
	else
		self.spawnedEntity = nil;
	end
			
	if(self.Properties and self.Properties.aicharacter_character) then 
		local characterTable = AICharacter[self.Properties.aicharacter_character];
		if(characterTable and characterTable.OnLoad) then 
			characterTable.OnLoad(self,saved);
		end
	end	

end


----------------------------------------------------------------------------------------------------
function BasicAI:OnSaveAI(save)
	if(self.AI) then 
		save.AI = self.AI;
	end
	
	if(self.Events) then 
--		self.Events = sav.Events;
		save.Events = {};
		local evtsSaved = save.Events
		for name, data in pairs(self.Events) do
			if not evtsSaved[name] then evtsSaved[name] = {} end
			for i, target in pairs(data) do
					local TargetId = target[1];
					local TargetEvent = target[2];
					table.insert(evtsSaved[name], {TargetId, TargetEvent})
				end
--			evtsSaved[name] = data[1];
		end
	end

	if(self.spawnedEntity) then
		save.spawnedEntity = self.spawnedEntity;
	end	

	if(self.Properties and self.Properties.aicharacter_character) then 
		local characterTable = AICharacter[self.Properties.aicharacter_character];
		if(characterTable and characterTable.OnSave) then 
			characterTable.OnSave(self,save);
		end
	end
end


-----------------------------------------------------------------------------------------------------
function BasicAI:RegisterAI(bForce)

	-- (KEVIN) Don't re-register if already has an AI and not forced
	-- This is so an entity container reused doesn't create a new AI object
	if (not bForce or bForce == false) then
		if (CryAction.HasAI(self.id)) then
			return;
		end
	end

	if ((self ~= g_localActor) and AI) then
		if ( self.AIType == nil ) then
			CryAction.RegisterWithAI(self.id, AIOBJECT_ACTOR, self.Properties, self.PropertiesInstance, self.AIMovementAbility,self.melee);
		else
			CryAction.RegisterWithAI(self.id, self.AIType, self.Properties, self.PropertiesInstance, self.AIMovementAbility,self.melee);
		end
		AI.ChangeParameter(self.id,AIPARAM_COMBATCLASS,AICombatClasses.Infantry);
		AI.ChangeParameter(self.id,AIPARAM_FORGETTIME_TARGET,self.forgetTimeTarget);
		AI.ChangeParameter(self.id,AIPARAM_FORGETTIME_SEEK,self.forgetTimeSeek);
		AI.ChangeParameter(self.id,AIPARAM_FORGETTIME_MEMORY,self.forgetTimeMemory);
	
		self._enabled=true;

		-- If the entity is hidden during 
		if (self:IsHidden()) then
			AI.LogEvent(self:GetName()..": The entity is hidden during init -> disable AI.");
			self:TriggerEvent(AIEVENT_DISABLE);
			self._enabled=false;
		end
	end
end

-----------------------------------------------------------------------------------------------------
function BasicAI:OnReset(bFromInit, bIsReload)
	if (self.ResetOnUsed) then
		self:ResetOnUsed();
	end

	self.ignorant = nil;
	self.isFallen = nil;

	local Properties = self.Properties;
	
	if AI then
		-- Reset all properties to editor set values.
		AI.ResetParameters(self.id, false, Properties, self.PropertiesInstance);
		
		AI.ChangeParameter(self.id,AIPARAM_COMBATCLASS,AICombatClasses.Infantry);
		AI.ChangeParameter(self.id,AIPARAM_FORGETTIME_TARGET,self.forgetTimeTarget);
		AI.ChangeParameter(self.id,AIPARAM_FORGETTIME_SEEK,self.forgetTimeSeek);
		AI.ChangeParameter(self.id,AIPARAM_FORGETTIME_MEMORY,self.forgetTimeMemory);

		-- free mounted weapon
		if (self.AI.current_mounted_weapon) then
			self.AI.current_mounted_weapon.reserved = nil;
			self.AI.current_mounted_weapon.listPotentialUsers = nil;
			self.AI.current_mounted_weapon = nil;
		end	
	end
	if( self.OnInitCustom ) then
	 self:OnInitCustom();
	end 

	self:SetActorModel();
	
	self.UpdateTime = 0.05;

	self:NetPresent(1);
	self:SetScriptUpdateRate(self.UpdateTime);

	self.useAction = AIUSEOP_NONE;

	if (Properties.ImpulseParameters) then 
		for name,value in pairs(Properties.ImpulseParameters) do
			self.ImpulseParameters[name] = value;
		end
	end

--	BasicPlayer.OnReset(self);
	
	if(Properties.bNanoSuit==1) then 
		--self.actor:ActivateNanoSuit(1);
	else
		if (self.actor.ActivateNanoSuit) then
			self.actor:ActivateNanoSuit(0);
		end
	end

	self.groupid = self.PropertiesInstance.groupid;

	-- now the same for special fire animations

	if (self.isAlien) then
		BasicAlien.Reset(self, bFromInit, bIsReload);
	else
		BasicActor.Reset(self, bFromInit, bIsReload);
	end
	
	if( self.OnResetCustom ) then
		self:OnResetCustom();
	end 

	self.AI.theVehicle = nil;
	
--	if (self.currentItemId) then
--		local item = System.GetEntity(self.currentItemId);
--	end

	if (self.instructionId) then
		HUD:SetInstructionObsolete(self.instructionId);
	end
	self.instructionId = nil;
	
	self:HideAttachment(0,"Animated LAW",true,true);

	if(self.bSquadMate) then 
		AICharacter.Player:InitItems(self);
	end
	self.AI.NextWeaponAccessory = nil;
	self.AI.WeaponAccessoryMountType = nil;
	self.AI.MountingAccessory = nil;

	self:AssignPrimaryWeapon();
	--self:CheckWeaponAttachments();
--	self:EnableLAM("Laser",true);

	-- Register with target tracks
	local Perception = self.Properties.Perception;
	if (Perception.config and Perception.config ~= "") then
		local TargetTracks = Perception.TargetTracks;
		AI.RegisterTargetTrack(self.id, Perception.config, TargetTracks.targetLimit, TargetTracks.classThreat);
	end
	
	if(not self.bGunReady) then
		ItemSystem.SetActorItem(self.id,NULL_ENTITY,false);
    --self:HolsterItem(true);
	end
		
	if (self.isAlien) then
	  self:DrawWeaponNow();
	end
	
	self.AI.invulnerable = self.Properties.bInvulnerable ~= 0;
	
	self:CheckWeaponAttachments();
	if AI then
		AI.EnableWeaponAccessory(self.id, AIWEPA_LASER, true);
	end
	
	self:SetColliderMode(Properties.eiColliderMode);

	-- To support spawn at the initial (rather than current) position
	self.InitialPosition = self:GetPos();
end


---------------------------------------------------------------------
function BasicAI:OnSpawn(bIsReload)
	-- System.Log("BasicAI.Server:OnSpawn()"..self:GetName());

	-- Register with AI
	self:RegisterAI(not bIsReload);
end


--------------------------------------------------------------------------------------------------------
function BasicAI.Server:OnInit(bIsReload)
	--Log("%s.Server:OnInit(%s)", self:GetName(), tostring(bIsReload));

	if (not self.AI) then
		self.AI = {};
	end

	self:OnReset(true, bIsReload);

	-- Go back to wave if being reloaded
	if (bIsReload and self.SetupTerritoryAndWave) then
		self:SetupTerritoryAndWave();
	end

	-- Output via FG node that I'm enabled if I was reloaded and not in a wave
	if (bIsReload and not self.AI.Wave) then
		self:Event_Enabled(self);
	end
end


--------------------------------------------------------------------------------------------------------
function BasicAI.Client:OnInit()
end


function BasicAI.Server:OnInitClient( channelId )
	if (self._enabled) then
		self.onClient:ClAIEnable(channelId);
	else
		self.onClient:ClAIDisable(channelId);
	end
end


function BasicAI.Client:ClAIEnable()
	if (not CryAction.IsServer()) then
		self:Hide(0)
		self:Event_Enabled(self);
		if(self.voiceTable and self.PlayIdleSound) then 
			if (self.cloaked == 1 and self.voiceTable.idleCloak) then
				self:PlayIdleSound(self.voiceTable.idleCloak);
			elseif(self.voiceTable.idle) then 
				self:PlayIdleSound(self.voiceTable.idle);
			end
		end
	end
end


function BasicAI.Client:ClAIDisable()
	if (not CryAction.IsServer()) then
		self:Hide(1)
		self:TriggerEvent(AIEVENT_DISABLE);	
	end
end



--------------------------------------------------------------------------------------------------------
function BasicAI.Client:OnShutDown()

	if (self.isAlien) then
		BasicAlien.ShutDown(self);
	else
		BasicActor.ShutDown(self);
	end
end


--------------------------------------------------------------------------------------------------------
function BasicAI:MakeAlerted( noDrawWeapon )

	if(noDrawWeapon~=nil) then return end
	
	self:DrawWeaponNow( );

end

--------------------------------------------------------------------------------------------------------
function BasicAI:MakeIdle()
	-- Make this guy idle
	AI.ChangeParameter(self.id,AIPARAM_SIGHTRANGE,self.Properties.Perception.sightrange);
	AI.ChangeParameter(self.id,AIPARAM_FOVPRIMARY,self.Properties.Perception.FOVPrimary);
end

--------------------------------------------------------------------------------------------------------
function BasicAI:InitAIRelaxed()
	
	self:MakeIdle();
	self:InsertSubpipe(0,"stance_relaxed");
end

--------------------------------------------------------------------------------------------------------
function BasicAI:GettingAlerted()

	if (self.Properties.special == 1) then 
		do return end
	end

	self:DrawWeaponNow( );
end

--------------------------------------------------------------------------------------------------------
function BasicAI:ReadibilityContact()

	local targetFwd = g_Vectors.temp_v2;
	local self2target = g_Vectors.temp_v1;

	AI.GetAttentionTargetDirection(self.id, targetFwd);
	AI.GetAttentionTargetPosition(self.id, self2target);
	FastDifferenceVectors(self2target, self2target, self:GetWorldPos());	

	local dot=dotproduct3d(self2target, targetFwd);
	
	if(dot<0) then
		self:Readibility("first_contact_group");--,0,100);
	else
		self:Readibility("first_contact_group_back");--,0,100);	
	end

end

--------------------------------------------------------------------------------------------------------
function BasicAI:Readibility(signal,bSkipGroupCheck,priority,delayMin,delayMax)

--	AI.LogEvent(" >>>> Readibility "..signal);

	g_SignalData.iValue = 0;
	g_SignalData.fValue = 0;

	if( priority ) then
		g_SignalData.iValue = priority;
	end
	
	if( delayMin ) then
		if( not delayMax ) then
			g_SignalData.fValue = delayMin;
		else
			local range = delayMax - delayMin;
			g_SignalData.fValue = delayMin + (random(1000)/1000.0)*range;
		end
	end

		AI.Signal(SIGNALID_READIBILITY, 1, signal,self.id,g_SignalData);	

end

--------------------------------------------------------------------------------------------------------
function BasicAI:GetNearestInGroup()
	local groupCount = AI.GetGroupCount( self.id, GROUP_ENABLED );
	local nearest = nil;
	local pos = self:GetWorldPos();
	local minDistance = 1000.0;
	if (groupCount > 1) then	
		local i = 1;
		while (i <= groupCount) do
			local member = AI.GetGroupMember( self.id, i, GROUP_ENABLED, AIOBJECT_ACTOR );
			if ( member.id ~= self.id ) then
				local distance = DistanceSqVectors( pos, member:GetWorldPos() );
				if ( distance < minDistance ) then
					minDistance = distance;
					nearest = member;
				end
			end
			i = i+1;
		end
	end
	return nearest;
end

--------------------------------------------------------------------------------------------------------
function BasicAI:AssignPrimaryWeapon()
  -- this is the new way of equiping actors
	local equipmentPack = self.Properties.equip_EquipmentPack;
	if (equipmentPack and equipmentPack ~= "") then
		self.primaryWeapon = ItemSystem.GetPackPrimaryItem(equipmentPack) or "";
		
    -- get secondary weapon
    if (ItemSystem.GetPackNumItems(equipmentPack)>1) then
	    self.secondaryWeapon = ItemSystem.GetPackItemByIndex(equipmentPack, 1) or "";
			-- make sure any kind of grenades are not considered as secondary weapon
	    if( self.secondaryWeapon == "AIFlashbangs" or
			    self.secondaryWeapon == "AISmokeGrenades" or
	  		  self.secondaryWeapon == "AIGrenades" ) then
		    		self.secondaryWeapon = "";
	    end		
	    --Log("%s has secondary weapon %s", self:GetName(), self.secondaryWeapon);
    end		
	end
end

--------------------------------------------------------------------------------------------------------
function BasicAI:DrawWeaponNow( skipCheck )
	if ( skipCheck~=1 and self.inventory:GetCurrentItem() ) then
		-- there is something in his hands - don't change weapon, just make sure it's out
		return
	end

	--	self:HolsterItem(false);
	local weapon = self.inventory:GetCurrentItem();
	-- make sure we select primary weapon
	if (weapon==nil or weapon.class~=self.primaryWeapon) then
		self.actor:SelectItemByName(self.primaryWeapon);
	end
		
	-- lets set burst fire mode - only Kuang has it currently
	weapon = self.inventory:GetCurrentItem();
	if(weapon~=nil and weapon.weapon~=nil and weapon.class==self.primaryWeapon) then
		weapon.weapon:SetCurrentFireMode("Burst");
	end	
	
--	self:UseLAM("FlashLight",true);
--	self:UseLAM("Laser",true);
end

--
--------------------------------------------------------------------------------------------------------
-- check selected weapon
-- returns nil if no weapon selected, 0 if primary weapon selected, 1 if secondary
-- 
function BasicAI:CheckCurWeapon( checkDistance )

	if(checkDistance~=nil) then
		local targetDist = AI.GetAttentionTargetDistance(self.id);
		if(targetDist and targetDist>10.5) then return nil end
	end
	
	local currentWeapon = self.inventory:GetCurrentItem();
	if(currentWeapon==nil) then return nil end
	if(currentWeapon.class==self.primaryWeapon) then return 0 end	
	if(currentWeapon.class==self.secondaryWeapon) then return 1 end
	
end

--------------------------------------------------------------------------------------------------------
function BasicAI:HasSecondaryWeapon()
	local secondaryWeaponId=self.inventory:GetItemByClass(self.secondaryWeapon);
	-- see if secondary weapon is awailable
	if(secondaryWeaponId==nil) then		return nil	end		
	do return 1 end
end

--------------------------------------------------------------------------------------------------------
function BasicAI:SelectSecondaryWeapon()

	local secondaryWeaponId=self.inventory:GetItemByClass(self.secondaryWeapon);
	-- see if secondary weapon is awailable
	if(secondaryWeaponId==nil) then		return nil	end		
	-- see if it is already selected
	local currentWeapon = self.inventory:GetCurrentItem();
	--AI.LogComment(entity:GetName().." ScoutIdle:Constructor weapon = "..weapon.class);
	if(currentWeapon~=nil and currentWeapon.class==self.secondaryWeapon) then return nil end
	
	self.actor:SelectItemByName( self.secondaryWeapon );
	
	do return 1 end
end

--------------------------------------------------------------------------------------------------------
function BasicAI:SelectPrimaryWeapon()
	self.actor:SelectItemByName(self.primaryWeapon);
end

--------------------------------------------------------------------------------------------------------
function BasicAI:Reload()
	local weapon = self.inventory:GetCurrentItem();
	if(weapon~=nil and weapon.weapon~=nil) then
		weapon.weapon:Reload();
	else
		AI.LogEvent(">>>>"..self:GetName().." FAILED TO RELOAD WEAPON!");
	end	
end

-----------------------------------------------------------------------------------
function BasicAI:DropItem()
	local item = self.inventory:GetCurrentItem();
	if (item) then
		item:Drop();
	end
end

-----------------------------------------------------------------------------------
function BasicAI:IsOnVehicle()
if (self.vehicleId) then
		return true;
	end
	
	return false;
end

-----------------------------------------------------------------------------------
function BasicAI:OnItemPicked(what)
	if (what.weapon) then
		ItemSystem:SetActorItem(self, what.id);
	end
end

-----------------------------------------------------------------------------------
function BasicAI:OnItemDropped(what)
end

-----------------------------------------------------------------------------------
function BasicAI:AnimationEvent(event,value)
	--Log("BasicAI:AnimationEvent "..event.." "..value);
	if ( event == "setIdleAction" ) then
		self.actor:SetAnimationInput( "Action", "idle" );
	elseif ( event == "useObject" ) then
		local navObject = AI.GetLastUsedSmartObject( self.id );
		if ( navObject and navObject.OnUsed ) then
			navObject:OnUsed( self, 2 );
			AI.SmartObjectEvent( "OnUsed", navObject.id, self.id );
		end
	elseif ( event == "grabObject" ) then
		local grabObject = AI.GetLastUsedSmartObject( self.id );
		if ( grabObject ) then
			self:GrabObject( grabObject );
			self.actor:SetAnimationInput( "Action", "carryBox" );
		end
	elseif ( event == "dropObject" ) then
		self.actor:SetAnimationInput( "Action", "idle" );
		self:DropObject( false );
	elseif ( event == "dropItem" ) then
		self:DropItem();
	elseif ( event == "kickObject" ) then
		local navObject = AI.GetLastUsedSmartObject( self.id );
		if ( navObject ) then
			if ( navObject.BreachDoor ) then
				navObject:BreachDoor();
			else
				navObject:AddImpulse( -1, nil, self:GetDirectionVector(1), self:GetMass(), 1 );
			end
		end
--	elseif ( event == "ThrowGrenade" ) then
	elseif ( BasicActor.AnimationEvent ) then
		BasicActor.AnimationEvent(self,event,value);
	end
end

-----------------------------------------------------------------------------------
function BasicAI:ScriptEvent(event,value,str)
	if (event == "splash") then
		if(_time - self.lastSplash > 1.0) then
			self.lastSplash = _time;
			PlayRandomSound(self,ActorShared.splash_sounds);
		end
	else	
		BasicActor.ScriptEvent(self,event,value,str);
	end
end


--------------------------------------------------------------------------------
function BasicAI:CreateFormation(otherLeader, bPersistent )
	local target;
	if(g_StringTemp1) then
		target = System.GetEntityByName(g_StringTemp1);
	end
	g_SignalData.point = g_SignalData_point;
	if(target~=nil) then
		CopyVector(g_SignalData.point, target:GetWorldPos());
		g_SignalData.point.z = self:GetWorldPos().z;
	else
		CopyVector(g_SignalData.point, g_Vectors.v000);
	end
	if(otherLeader and not otherLeader:IsDead()) then
		g_SignalData.id = otherLeader.id;
	else
		g_SignalData.id = self.id;
	end
	if(bPersistent) then
		g_SignalData.fValue = 1;
	else
		g_SignalData.fValue = 0;
	end
	g_SignalData.iValue = AI.GetGroupOf(self.id);
	self.AI.Follow = true;		
	AI.Signal(SIGNALFILTER_LEADER,0,"ORD_FOLLOW",self.id,g_SignalData);
 	g_StringTemp1 = ""; -- safer for further calls, since it's an optional parameter
end


--------------------------------------------------------------------------------
function BasicAI:JoinFormation(groupid)
	g_SignalData.iValue = groupid;
	self.AI.Follow = true;		
	AI.Signal(SIGNALFILTER_LEADER,0,"ORD_FOLLOW",self.id,g_SignalData);
end

----------------------------------------------------------------------------------------------------
function BasicAI:SetAnimationStartEndEvents(slot, animation, funcStart,funcEnd)
	if (animation and animation ~="") then
		self.onAnimationStart[animation] = funcStart;
		self.onAnimationEnd[animation] = funcEnd;
		self:SetAnimationEvent(slot, animation);
	end
end

----------------------------------------------------------------------------------------------------
function BasicAI.Client:OnStartAnimation(animation)
	local func = self.onAnimationStart[animation];
	
	if (func) then
		func(self, animation);
--		self.onAnimationStart[animation] = nil;
	end
end


----------------------------------------------------------------------------------------------------
function BasicAI.Client:OnEndAnimation(animation)
	local func = self.onAnimationEnd[animation];
	if (func) then
		func(self, animation);
--		self.onAnimationEnd[animation] = nil;
	end
end

----------------------------------------------------------------------------------------------------
--function BasicAI.Client:OnTimer(timerId)
----------------------------------------------------------------------------------------------------
function BasicAI.OnDeath( entity )
	AI.SetSmartObjectState( entity.id, "Dead" );

	-- notify spawner - so it counts down and updates
	if(entity.AI.spawnerListenerId) then
		local spawnerEnt = System.GetEntity(entity.AI.spawnerListenerId);
		if(spawnerEnt) then
			spawnerEnt:UnitDown();
		end
	end

	
--	AI.LogEvent(" >>>> BasicAI.OnDeath "..entity:GetName());
	--the guy is dead	

--	BasicAIEvent.Event_Dead(entity);

 	if(entity.AI.theVehicle and entity.AI.theVehicle:IsDriver(entity.id)) then
 			-- disable vehicle's AI
 		if (entity.AI.theVehicle.AIDriver) then
 		  entity.AI.theVehicle:AIDriver(0);
 		end
 		entity.AI.theVehicle=nil;
 	end
	
	AI.UnregisterTargetTrack(entity.id);

	if(entity.Event_Dead) then
		entity:Event_Dead(entity);	
	end	
	
	-- Notify AI system about this	
	--AI.Signal(SIGNALFILTER_GROUPONLY_EXCEPT, 10, "OnGroupMemberDied", entity.id);

--	entity:TriggerEvent(AIEVENT_AGENTDIED);
	-- re-register actor with Action_R
--	AI.RegisterWithAI( entity.id, AIAnchorTable.ACTION_RECOG_CORPSE );
	entity.bUseOrderEnabled = false;

	-- free mounted weapon
	if (entity.AI.current_mounted_weapon) then
		if (entity.AI.current_mounted_weapon.item:GetOwnerId() == entity.id) then
			entity.AI.current_mounted_weapon.item:Use( entity.id );--Stop using
			entity.AI.current_mounted_weapon.reserved = nil;
			AI.ModifySmartObjectStates(entity.AI.current_mounted_weapon.id,"Idle,-Busy");				
		end
		entity.AI.current_mounted_weapon.listPotentialUsers = nil;
		entity.AI.current_mounted_weapon = nil;
		AI.ModifySmartObjectStates(entity.id,"-Busy");			
	end	
	-- check ammo count modifier
	if(entity.AI.AmmoCountModifier and entity.AI.AmmoCountModifier>0) then 
		entity:ModifyAmmo();
	end
	
	AI.Signal(SIGNALFILTER_NEARESTINCOMM, 1, "MAN_DOWN", entity.id);
	
end

----------------------------------------------------------------------------------
function BasicAI:ModifyAmmo(multiplier)
	
	local item = self.inventory:GetCurrentItem();
	if(item) then 
		local currWeapon = item.weapon;
		if(currWeapon ) then 
			if(multiplier) then
				local ammoCount = currWeapon:GetClipSize();
				currWeapon:SetAmmoCount(nil, ammoCount*multiplier)
			elseif(self.AI.AmmoCountModifier) then 
				if( self.AI.AmmoCountModifier==0) then 
					self.AI.AmmoCountModifier=1;
				end
				local ammoCount = currWeapon:GetAmmoCount();
				currWeapon:SetAmmoCount(nil, ammoCount/self.AI.AmmoCountModifier);
			end
			self.AI.AmmoCountModifier = multiplier;
		end
	end
end

----------------------------------------------------------------------------------
function BasicAI:GetAmmoLeftPercent()
	-- returns how much of the clip is still left in percent.
	local item = self.inventory:GetCurrentItem();
	if(item) then 
		local currWeapon = item.weapon;
		if(currWeapon ) then 
			local clipSize = currWeapon:GetClipSize();
			local ammoCount = currWeapon:GetAmmoCount();
			return ammoCount / clipSize;
		end
	end
	return 1;
end

----------------------------------------------------------------------------------
function BasicAI:UpdateRadar(radarContact)
	if (not self:IsDead()) then
		
		if (radarContact) then
			if (self:IsSquadMate()) then
				radarContact.color[1] = 64;
				radarContact.color[2] = 64;
				radarContact.color[3] = 255;
				radarContact.img = "textures/gui/hud/radar/enemy_grey.dds";
				radarContact.radius = 4;
				
				if (self.hit) then
					radarContact.blinking = 1.0;
					radarContact.blinkColor[1] = 255;
					radarContact.blinkColor[2] = 0;
					radarContact.blinkColor[3] = 0;
					self.hit = nil;
				end			
			else
				
				local alertness = self.Behavior.alertness;
				
				if (g_localActor) then
					local targetName = AI.GetAttentionTargetOf(self.id);
	              	--Log(tostring(targetName));
	                if (targetName and targetName == g_localActor:GetName()) then
	                	alertness = 2;
	                	
	                	radarContact.blinking = 1.0;
						radarContact.blinkColor[1] = 255;
						radarContact.blinkColor[2] = 255;
						radarContact.blinkColor[3] = 255;
	                end
	            end
				
				--idle
				if (not alertness or alertness == 0) then
					radarContact.color[1] = 26;
					radarContact.color[2] = 255;
					radarContact.color[3] = 26;
				--alerted
				elseif (alertness == 1) then
					radarContact.color[1] = 255;
					radarContact.color[2] = 128;
					radarContact.color[3] = 26;
				--combat
				else
					radarContact.color[1] = 255;
					radarContact.color[2] = 26;
					radarContact.color[3] = 26;
				end
				
				radarContact.img = "textures/gui/hud/radar/enemy_grey.dds";
			end
			
			if (self.speakingTime and self.speakingTime > 0) then
				AI.LogEvent(self:GetName() .."speaking for ".. self.speakingTime * 0.001 .." seconds");
				radarContact.blinking = 1.0+self.speakingTime * 0.001;
				radarContact.blinkColor[1] = 255;
				radarContact.blinkColor[2] = 255;
				radarContact.blinkColor[3] = 255;

				self.speakingTime = 0;
			end	
		end
		
		return true;
	else	
		return false;
	end
end

----------------------------------------------------------------------------------
function BasicAI:MotionTrackable(radarContact)
	--enable the readability check for every motion tracked AI
	self.bCheckReadabilityLength = true;
	return (not self:IsDead()) and (not self:IsOnVehicle());
end

----------------------------------------------------------------------------------
function BasicAI:SetRefPointAtDistanceFromTarget(distance)
	local targetPos = g_Vectors.temp;
	local targetDir = g_Vectors.temp_v1;

	if(AI.GetNavigationType(self.id) ~= NAV_TRIANGULAR) then 
		return false;
	end

	AI.GetAttentionTargetDirection(self.id, targetDir);
--	AI.LogEvent("TARGET DIR: "..Vec2Str(targetDir));
	if(LengthSqVector(targetDir)<0.05) then 
		-- target is still, no direction to approach
		return false; 
	end
	AI.GetAttentionTargetPosition(self.id, targetPos);
--	FastSumVectors(targetPos,targetPos,targetDir);
	ScaleVectorInPlace(targetDir, -distance);

	local	hits = Physics.RayWorldIntersection(targetPos,targetDir,2,ent_terrain+ent_static+ent_rigid+ent_sleeping_rigid ,self.id,nil,g_HitTable);
	local actualDistance = distance;
	if(hits>0) then
		local firstHit = g_HitTable[1];
		AI.SetRefPointPosition(self.id, firstHit.pos);
		actualDistance = firstHit.dist;
	else
		FastSumVectors(targetPos,targetPos,targetDir);
		AI.SetRefPointPosition(self.id, targetPos);
	end
	return actualDistance;
end

----------------------------------------------------------------------------------
function BasicAI:GetWeaponDir(weapon)
	return self.fireDir;
end

----------------------------------------------------------------------------------
function BasicAI:DrawWeaponDelay(time)
	Script.SetTimerForFunction(random(100,time*1000),"BasicAI.OnDelayedDrawWeapon",self);
end

----------------------------------------------------------------------------------
function BasicAI:OnDelayedDrawWeapon(timerid)
	if(not self.inventory:GetCurrentItemId()) then
		self:HolsterItem(false);
	end
end


----------------------------------------------------------------------------------

function BasicAI:Expose()
	Net.Expose{
		Class = self,
		ClientMethods = {
			ClAIEnable={ RELIABLE_ORDERED, PRE_ATTACH },
			ClAIDisable={ RELIABLE_ORDERED, PRE_ATTACH },
		},
		ServerMethods = {
		},
		ServerProperties = {
		}
	};
end

----------------------------------------------------------------------------------
function BasicAI:DropObjectAtPoint(point)
	-- TO DO: only horizontal impulse by now; so it assumes that the thrown object
	-- is at a higher place than the point.
  if ( self.grabParams and self.grabParams.entityId) then
		local grab = System.GetEntity( self.grabParams.entityId );
		self:DropObject( false );

		if ( grab ) then
			local mass = grab:GetMass();
			local dir = g_Vectors.temp;
			FastDifferenceVectors(dir, point, grab:GetPos());

			if(dir.z <0) then -- temporary: consider only target at lower height
				local z = math.abs(dir.z);
				
				local dispXY = math.sqrt(dir.x*dir.x+dir.y*dir.y);
				local gravity = 9.8;
				if (z<0.05) then 
					-- avoid degenerated situations ( z of grabbed object and target is almost the same)
					z = 0.05;
				end
				local Vxy = dispXY*math.sqrt(gravity/(z*2));
				-- consider accuracy
				if(self.Properties.accuracy) then 
					local acc = 1 - self.Properties.accuracy;
					if(acc>0) then
						acc = clamp(acc,0,1);
						local  err = dispXY/4;
						dir.x= dir.x + random(-err,err)*acc;
						dir.y= dir.y + random(-err,err)*acc;
					end
				end
				dir.z = 0;
				NormalizeVector(dir);
				local impulse = g_Vectors.temp_v1;
				FastScaleVector(impulse,dir,Vxy);
				FastDifferenceVectors(impulse,impulse,self:GetVelocity());
				local V = LengthVector(impulse);
				ScaleVectorInPlace(impulse, 1/V);
				local tempVelTable = {v={x=0,y=0,z=0}};
				grab:SetPhysicParams(PHYSICPARAM_VELOCITY, tempVelTable);
--				local spinpoint = g_Vectors.temp_v2;
--				spinpoint.x = random(-100,100)/200;
--				spinpoint.y = random(-100,100)/200;
--				spinpoint.z = 0;
--				local spinimpulse = g_Vectors.temp_v3;
--				spinimpulse.x = 0;
--				spinimpulse.y = 0;
--				spinimpulse.z = random(-100,100);
				grab:AddImpulse( -1, g_Vectors.v000, impulse, mass*V, 1 );
--				grab:AddImpulse( -1, spinpoint, spinimpulse, mass/100, 1 );
--
--				spinimpulse.z = -spinimpulse.z;
--
--				spinpoint.x = -spinpoint.x;
--				spinpoint.x = -spinpoint.y;
--				grab:AddImpulse( -1, spinpoint, spinimpulse, mass/100, 1 );
			end
		end
	end
end


----------------------------------------------------------------------------------
function BasicAI:ExecuteAttachWeaponAccessory(singleItem)
	local item = self.inventory:GetCurrentItem();
	if(item) then 
		local currWeapon = item.weapon;
		--System.Log("ATTACHING WEAPON ACCESSORY:"..self.AI.NextWeaponAccessory.." ON="..tostring(self.AI.NextWeaponAccessoryMount));
		if(currWeapon) then 
			if(self.AI.WeaponAccessoryMountType==0) then 
				currWeapon:AttachAccessory(self.AI.NextWeaponAccessory,false);
			elseif(self.AI.WeaponAccessoryMountType==1) then 
				currWeapon:AttachAccessory(self.AI.NextWeaponAccessory,true);
			elseif(self.AI.WeaponAccessoryMountType==2) then 
				currWeapon:SwitchAccessory(self.AI.NextWeaponAccessory);
			end
		end
		if(not singleItem) then
			AI.Signal(SIGNALFILTER_SENDER,0,"CheckNextWeaponAccessory",self.id);
		end
	end
	self.AI.MountingAccessory = false;
end

----------------------------------------------------------------------------------
function BasicAI:CheckWeaponAttachments()
	self:CheckSingleWeaponAttachment(self.primaryWeapon,"Silencer",true);
	self:CheckSingleWeaponAttachment(self.primaryWeapon,"LAMRifle",true);
	self:CheckSingleWeaponAttachment(self.primaryWeapon,"AssaultScope",true);
	self:CheckSingleWeaponAttachment(self.primaryWeapon,"SniperScope",true);
	self:CheckSingleWeaponAttachment("SOCOM","LAM",true);
	self:CheckSingleWeaponAttachment("SOCOM","SOCOMSilencer",true);
	self:CheckSingleWeaponAttachment("SOCOM","LAMFlashLight",true);
	self:CheckSingleWeaponAttachment(self.primaryWeapon,"LAMRifleFlashLight",true);
end

----------------------------------------------------------------------------------
function BasicAI:CheckSingleWeaponAttachment(weaponClass,attachmentClass,attach)
  local itemId = self.inventory:GetItemByClass(weaponClass);
	if (itemId) then
  	local item = System.GetEntity(itemId);
  	local att = self.inventory:HasAccessory(attachmentClass);
  	if(item and att) then 
  		local currWeapon = item.weapon;
  		if(currWeapon and currWeapon:SupportsAccessory(attachmentClass)) then 
  			currWeapon:AttachAccessory(attachmentClass,attach,true);	-- force attach
  		end
  	end
  end
end

----------------------------------------------------------------------------------
function BasicAI:SetStealth(stealth)
	self.AI.Stealth = stealth;
	if(stealth) then 
--		System.Log(self:GetName().." GOIN' STEALTH");
		AI.ChangeParameter(self.id,AIPARAM_CAMOSCALE,0.8);
	else
--		System.Log(self:GetName().." GOIN' UNCOVERED");
		AI.ChangeParameter(self.id,AIPARAM_CAMOSCALE,1);
	end
end

----------------------------------------------------------------------------------
function BasicAI:GetHealthPercentage( )

	local percent = 100 * self.actor:GetHealth() / self.actor:GetMaxHealth();
	return percent;
	
end

---------------------------------------------------------------------
function BasicAI:NanoSuitMode( mode )

	AI.LogEvent(self:GetName()..": Setting SUIT mode to "..mode);

	if(mode == self.AI.curSuitMode) then return end

	if(mode == BasicAI.SuitMode.SUIT_OFF) then
		if (self.actor.ActivateNanoSuit) then
			self.actor:ActivateNanoSuit(0);
		end
	elseif(mode == BasicAI.SuitMode.SUIT_ARMOR) then
		self.actor:SetNanoSuitMode(NANOMODE_DEFENSE);
	elseif(mode == BasicAI.SuitMode.SUIT_CLOAK) then
		self:SetCloakType(2);
		self.actor:SetNanoSuitMode(NANOMODE_CLOAK);
	elseif(mode == BasicAI.SuitMode.SUIT_POWER) then
		self.actor:SetNanoSuitMode(NANOMODE_STRENGTH);
	end	
	
	self.AI.curSuitMode = mode;	
end

function BasicAI:IsInvulnerable()
	return self.AI.invulnerable
end
	
----------------------------------------------------------------------------------
function CreateAI(child)

	local newt={}
	mergef(newt,child,1);
	mergef(newt,BasicAI,1);
	mergef(newt,BasicAIEvent,1);
	mergef(newt,BasicAITable,1);

	MakeSpawnable(newt)

	return newt;
end

----------------------------------------------------------------------------------
