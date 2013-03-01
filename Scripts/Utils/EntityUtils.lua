EntityCommon = {
	TempPhysParams = { mass=0,density=0 },
	TempPhysicsFlags = { flags_mask=0, flags=0 };
}

----------------------------------------------------------
-- Creates a new table that is derived class of parent entity.
----------------------------------------------------------
function MakeDerivedEntity( _DerivedClass,_Parent )
	local derivedProperties = _DerivedClass.Properties;
	_DerivedClass.Properties = {};
	mergef(_DerivedClass,_Parent,1);
	
	-- Add derived class properties.
	mergef(_DerivedClass.Properties,derivedProperties,1);
	
	_DerivedClass.__super = BasicEntity;
	return _DerivedClass;
end

function MakeDerivedEntityReplaceFunctions( _DerivedClass,_Parent )
	local derivedProperties = _DerivedClass.Properties;
	_DerivedClass.Properties = {};
	mergef(_DerivedClass,_Parent,1);
	
	-- Add derived class properties.
	mergefReplace(_DerivedClass.Properties,derivedProperties,1);
	
	_DerivedClass.__super = BasicEntity;
	return _DerivedClass;
end

function MakeDerivedEntityRename( _DerivedClass,_Parent, suffix )
	local derivedProperties = _DerivedClass.Properties;
	_DerivedClass.Properties = {};
	mergefRename(_DerivedClass,_Parent,1, suffix);
	
	-- Add derived class properties.
	mergefReplace(_DerivedClass.Properties,derivedProperties,1);
	
	_DerivedClass.__super = BasicEntity;
	return _DerivedClass;
end


----------------------------------------------------------
-- Creates a new table that is derived class of parent entity.
-- The Child's Properties will override the ones from the parent
----------------------------------------------------------
function MakeDerivedEntityOverride( _DerivedClass,_Parent )
	--local derivedProperties = _Parent.Properties;
	--_Parent.Properties = {};
	mergef(_DerivedClass,_Parent,1);
	
	-- Add derived class properties.
	--mergef(_DerivedClass.Properties,derivedProperties,1);
	
	_DerivedClass.__super = _Parent;
	return _DerivedClass;
end

----------------------------------------------------------
----------------------------------
function BroadcastEvent( sender,Event  )
	-- Check if Event Target for this input event exists.
	sender:ProcessBroadcastEvent( Event );
	if (sender.Events) then
		--System.Log( "Events found" );
		local eventTargets = sender.Events[Event];
		if (eventTargets) then
			--System.Log( "Events Targets found" );
			for i, target in pairs(eventTargets) do
				local TargetId = target[1];
				local TargetEvent = target[2];
				--System.Log( "Target: "..TargetId.."/"..TargetEvent );
				--System.Log( "Target: "..TargetEvent );
				
				if (TargetId == 0) then
					-- If TargetId refer to global Mission table.
					if Mission then
						local func = Mission["Event_"..TargetEvent];
						if (func ~= nil) then
							func( sender )
						else
							System.Log( "Mission does not support event "..TargetEvent );
						end
					end
				else
					-- If TargetId refere to Entity.
					local entity = System.GetEntity(TargetId);
					if (entity ~= nil) then
						
						local TargetName=entity:GetName();
						--System.Log( "Entity Named "..TargetName.." Found." );
						--System.Log( "Calling method: "..TargetName..":Event_"..TargetEvent );
						local func = entity["Event_"..TargetEvent];
						if (func ~= nil) then
							func( entity,sender )
--						else
--							System.Log( "Entity "..TargetName.." does not support event "..TargetEvent );
						end
--					else
--						System.Log( "Entity Named "..TargetName.." Not Found." );
					end
				end
 			end
 		end
 	end
end

function DumpEntities()
	local ents=System.GetEntities();
	System.Log("Entities dump");
	for idx,e in pairs(ents) do
		local pos=e:GetPos();
		local ang=e:GetAngles();
		System.Log("["..tostring(e.id).."]..name="..e:GetName().." clsid="..e.class..format(" pos=%.03f,%.03f,%.03f",pos.x,pos.y,pos.z)..format(" ang=%.03f,%.03f,%.03f",ang.x,ang.y,ang.z));
	end
end

function MakeTargetableByAI( entity )
	if (not entity.Properties) then entity.Properties = {} end
	if (not entity.Properties.esFaction) then
		entity.Properties.esFaction = "";
	end

	function entity:RegisterWithAI()
		if (self.Properties.esFaction ~= "") then
			CryAction.RegisterWithAI(self.id, AIOBJECT_TARGET);
			AI.ChangeParameter(self.id, AIPARAM_FACTION, self.Properties.esFaction);
		end
	end
	
	local _onReset = entity.OnReset;
	function entity:OnReset(...)
		if (_onReset) then
			_onReset(self, ...);
		end
		
		self:RegisterWithAI();
	end

	local _onSpawn = entity.OnSpawn;
	function entity:OnSpawn(...)
		if (_onSpawn) then
			_onSpawn(self, ...);
		end
		
		self:RegisterWithAI();
	end
end



function MakeAICoverEntity(entity)
	if (not entity.Properties) then entity.Properties = {} end
	if (not entity.Properties.bProvideAICover) then entity.Properties.bProvideAICover = 1 end

	local tbl = entity.Server and entity.Server or entity
	local _onStartGame = tbl.OnStartGame
	tbl.OnStartGame = function(self)
		if (self.PropertiesInstance.bProvideAICover ~= 0) then
			AI.AddCoverEntity(self.id)
		end

		if (_onStartGame) then
			_onStartGame(self)
		end
	end
end

function MakeKillable( entity )
	if (not entity.Properties) then entity.Properties = {} end
	if (not entity.Properties.Health) then entity.Properties.Health = {} end

	local Health = entity.Properties.Health;
	Health.MaxHealth = 500;
	Health.bInvulnerable = 1;
	Health.bOnlyEnemyFire = 1;
	
	function entity:IsDead()
		return self.dead;
	end
	
	function entity:SetupHealthProperties()
		self.dead = nil;
		self.health = self.Properties.Health.MaxHealth;
		self.invulnerable = self.Properties.Health.bInvulnerable ~= 0;
		self.friendlyFire = self.Properties.Health.bOnlyEnemyFire  == 0;
	end
	
	if (not entity.Server) then entity.Server = {} end
	if (not entity.Client) then entity.Client = {} end
		
	function entity:GetHealthRatio()
		local healthR = 1;
		local maxHealth = self.Properties.Health.MaxHealth;
		if (maxHealth > 0) then
			healthR = self.health / maxHealth;
		end
	
		return healthR;
	end
	
	function entity:IsInvulnerable()
		return self.invulnerable
	end

	local _onHit = entity.Server.OnHit;
	function entity.Server:OnHit(hit)
		if ((not self.health) or (self.IsInvulnerable == nil)) then
			Log("$4%s:%s Health not initialized!", self.class, self:GetName());

			self:SetupHealthProperties();
		end

		local result = false;
		if (_onHit) then
			result = _onHit(self, hit);
		end
		
		if (not result) then
			if (self:IsInvulnerable()) then
				self:ActivateOutput("Health", self:GetHealthRatio() * 100);
				self:Event_Hit();

				return false;
			end
			
			if (not self.friendlyFire) then
				local reaction = AI.GetReactionOf(self.id, hit.shooterId);
				
				if (reaction == Friendly) then
					self:ActivateOutput("Health", self:GetHealthRatio() * 100);
					self:Event_Hit();

					return false;
				end
			end
			
			self.health = self.health - hit.damage;
		end
		
		self:ActivateOutput("Health", self:GetHealthRatio() * 100);
		self:Event_Hit();
		
		if (self.health <= 0) then
			self.dead = true;
			
			self:Event_Dead();

			return true;
		end
	end

	
	local _onReset = entity.OnReset;
	function entity:OnReset(...)
		if (_onReset) then
			_onReset(self, ...);
		end

		self:SetupHealthProperties();
	end
	
	local _onSpawn = entity.OnSpawn;
	function entity:OnSpawn(...)
		if (_onSpawn) then
			_onSpawn(self, ...);
		end
		
		self:SetupHealthProperties();
	end
	
	function entity:Event_ResetHealth()
		self.dead = nil;
		self.health = self.Properties.Health.MaxHealth;
	end
	
	function entity:SetInvulnerability(invulnerable)
		self.invulnerable = invulnerable;
		
		if(not self.overrode_saveload) then
			local _onSave = self.OnSave;
			function self:OnSave(table)
				if(_onSave) then
					_onSave(self, table);
				end
				
				if(self.invulnerable) then
					table.invulnerable = self.invulnerable;
				end
				
				if(self.dead) then
					table.dead = self.dead;
				end
				
				if(self.health) then
					table.health = self.health;
				end
			end
			
			local _onLoad = self.OnLoad;
			function self:OnLoad(table)
				if(_onLoad) then
					_onLoad(self, table);
				end
				
				if(table.invulnerable) then
					self.invulnerable = table.invulnerable;
				else
					self.invulnerable = false;
				end
				
				if(table.dead) then
					self.dead = table.dead;
				else
					self.dead = false;
				end
				
				if(table.health) then
					self.health = table.health;
				else
					self.health = self.Properties.Health.MaxHealth;
				end
			end		
			
			self.overrode_saveload = true;	
		end
	end
	
	function entity:Event_MakeVulnerable()
		self:SetInvulnerability(false);
	end

	function entity:Event_MakeInvulnerable()
		self:SetInvulnerability(true);
	end

	function entity:Event_Dead()
		self:TriggerEvent(AIEVENT_DISABLE);
		
		BroadcastEvent(self, "Dead");
	end
	
	function entity:Event_Hit()
		BroadcastEvent(self, "Hit");
	end
	
	if not entity.FlowEvents then entity.FlowEvents = {} end
	local fe = entity.FlowEvents
	fe.Inputs = fe.Inputs or {}
	fe.Outputs = fe.Outputs or {}

	fe.Inputs["ResetHealth"] = { entity.Event_ResetHealth, "any" };
	fe.Inputs["MakeVulnerable"] = { entity.Event_MakeVulnerable, "any" };
	fe.Inputs["MakeInvulnerable"] = { entity.Event_MakeInvulnerable, "any" };
	
	fe.Outputs["Dead"] = "bool";
	fe.Outputs["Hit"] = "bool";
	fe.Outputs["Health"] = "float";
end

function MakeInterestingToAI( entity, per_instance )
	
	if (not entity.Properties) then entity.Properties = {} end
	entity.Properties.Interest=
	{
		bInteresting=0,
		InterestLevel=1,
		Radius=20,
		soaction_Action="",
		vOffset={x=0, y=0, z=0 },
		Pause=15,
		bShared=0,
	}
	
	if (per_instance == 1) then
		if (not entity.PropertiesInstance) then entity.PropertiesInstance = {} end
		entity.PropertiesInstance.Interest=
		{
			bOverrideArchetype=0,
			bInteresting=0,
			InterestLevel=-1,
			Radius=-1,
			soaction_Action="",
			Pause=-1,
			bShared=0,
		}
	end
end

-- makes an OnUsed event for designers on an entity...
-- usage:
-- MyEntity = { ... whatever you usually put here ... }
-- MakeUsable(MyEntity)
-- function MyEntity:OnSpawn() ...
-- function MyEntity:OnReset()
--   self:ResetOnUsed()
--   ...
-- end
function MakeUsable( entity )
	if not entity.Properties then entity.Properties = {} end
	entity.Properties.UseText = "";
	entity.Properties.bUsable = 0;
	function entity:IsUsable()
		if not self.__usable then self.__usable = self.Properties.bUsable end;
		return self.__usable;
	end
	function entity:ResetOnUsed()
		self.__usable = nil;
	end
	function entity:GetUsableMessage()
		return self.Properties.UseText;
	end
	function entity:OnUsed(user, idx)
		BroadcastEvent(self, "Used");
	end
	function entity:Event_Used()
		BroadcastEvent(self, "Used");
	end
	function entity:Event_EnableUsable()
		self.__usable = 1;
		BroadcastEvent(self, "EnableUsable");
	end
	function entity:Event_DisableUsable()
		self.__usable = 0;
		BroadcastEvent(self, "DisableUsable");
	end
end

function MakeDefaultFunctions( entity )
	function entity:OnInit()
	end;
	function entity:OnPropertyChange()
	end;
	function entity:OnReset()
	end;
	function entity:OnShutDown()
	end;
	function entity:OnUpdate()
	end;
	function entity:OnHit()
	end;
	function entity:OnSave()
	end;
	function entity:OnLoad()
	end;
end

function MakePickable( entity )
	if not entity.Properties then entity.Properties = {} end;
	entity.Properties.bPickable = 0;
end

function AddHeavyObjectProperty(entity)
	if (not entity.Properties) then
		entity.Properties = {};
	end;
	entity.Properties.bHeavyObject = 0;
end;

function MakeThrownObjectTargetable( entity )
	-- Add property
	if not entity.Properties then 
		entity.Properties = {};
	end
	if not entity.Properties.AutoAimTarget then
		entity.Properties.AutoAimTarget = {};
	end
	entity.Properties.AutoAimTarget.bMakeTargetableOnThrown = 0;
	entity.Properties.AutoAimTarget.InnerRadiusVolumeFactor = 0.35;
	entity.Properties.AutoAimTarget.OuterRadiusVolumeFactor = 0.6;
	entity.Properties.AutoAimTarget.SnapRadiusVolumeFactor = 1.25;
	entity.Properties.AutoAimTarget.AfterThrownTargetableTime = 3.0;
	
	-- Add callback functions
	function entity:OnThrown()
		if ((self.Properties.AutoAimTarget.bMakeTargetableOnThrown ~= 0) and (self:CanBeMadeTargetable())) then
			Game.RegisterWithAutoAimManager(self.id, self.Properties.AutoAimTarget.InnerRadiusVolumeFactor, self.Properties.AutoAimTarget.OuterRadiusVolumeFactor, self.Properties.AutoAimTarget.SnapRadiusVolumeFactor);
			Script.SetTimer(self.Properties.AutoAimTarget.AfterThrownTargetableTime * 1000, function() self:AfterThrownTimer(); end)
			self.isTargetable = 1;
		end
	end
	
	function entity:AfterThrownTimer()
		if (self.isTargetable) then
			Game.UnregisterFromAutoAimManager(self.id);
			self.isTargetable = nil;
		end
	end
	
	local _CanBeMadeTargetable = entity.CanBeMadeTargetable;
	function entity:CanBeMadeTargetable(...) 
		if (_CanBeMadeTargetable) then
			return _CanBeMadeTargetable(self, ...);
		end
		return true;
	end
	
	-- Override shutdown/reset
	local _OnShutDown = entity.OnShutDown;
	function entity:OnShutDown(...)
		if _OnShutDown then
			_OnShutDown(self, ...);
 		end

		if (self.isTargetable) then
			Game.UnregisterFromAutoAimManager(self.id);
			self.isTargetable = nil;
		end
	end	

	local _OnReset = entity.OnReset;
	function entity:OnReset(...)
		if _OnReset then
			_OnReset(self, ...);
 		end

		if (self.isTargetable) then
			Game.UnregisterFromAutoAimManager(self.id);
			self.isTargetable = nil;
		end
	end	
end

function AddInteractLargeObjectProperty(entity)
	if (not entity.Properties) then
		entity.Properties = {};
	end;
	entity.Properties.bInteractLargeObject = 0;
end;

function MakeSpawnable( entity )
	entity.spawnedEntity = nil
	-- setup some basic properties
	if not entity.Properties then entity.Properties = {} end
	local p = entity.Properties;
	p.bSpawner = false;
	p.SpawnedEntityName = "";
	
	local _OnDestroy = entity.OnDestroy;
	
	function entity:OnDestroy(...)
		-- System.Log("OnDestroy"..tostring(self.id));
		if self.whoSpawnedMe then
			-- inform that I'm dead
			self.whoSpawnedMe:NotifyRemoval(self.id);
		end
		if _OnDestroy then
			_OnDestroy(self, ...);
 		end
	end

	function entity:NotifyRemoval(spawnedEntityId)
		-- System.Log("NotifyRemoval"..tostring(self.id).." spawned="..tostring(spawnedEntityId));
		-- clear spawnedEntity on original
		if (self.spawnedEntity and self.spawnedEntity == spawnedEntityId) then
 			--System.Log("...Cleared");
			self.spawnedEntity = nil;
			self.lastSpawnedEntity = nil;
		end
	end		
		
	-- override some functions to have our code called also
	local _OnReset = entity.OnReset;
	function entity:OnReset(...)
		--System.Log("reset");
		self.lastSpawnedEntity = nil;
		if self.spawnedEntity then
			System.RemoveEntity(self.spawnedEntity);
			self.spawnedEntity = nil;
		end
		if self.whoSpawnedMe then
			System.RemoveEntity( self.id );
			return
		end
		_OnReset(self, ...);
	end
	
	local _OnEditorSetGameMode = entity.OnEditorSetGameMode;
	function entity:OnEditorSetGameMode(...)
	  self.lastSpawnedEntity = nil;
		if self.spawnedEntity then
			self.spawnedEntity = nil;
		end
		
		if (_OnEditorSetGameMode) then
			_OnEditorSetGameMode(self, ...);
		end
	end
	
	-- allow flowgraph forwarding
	function entity:GetFlowgraphForwardingEntity()
		if (self.spawnedEntity) then
			return self.spawnedEntity;
		else
		  return self.lastSpawnedEntity;
		end
	end
	-- OnSpawned event
	function entity:Event_Spawned()
		BroadcastEvent(self, "Spawned")
	end

	if not entity.FlowEvents then entity.FlowEvents = {} end
	local fe = entity.FlowEvents
	-- normalize events
	fe.Inputs = fe.Inputs or {}
	fe.Outputs = fe.Outputs or {}

	-- collate events
	local allEvents = {}
	local name, data
	for name, data in pairs(fe.Outputs) do
		allEvents[name] = data
	end
	for name, data in pairs(fe.Inputs) do
		allEvents[name] = data
	end

	-- event rebinding
	for name, data in pairs(allEvents) do
		local isInput = fe.Inputs[name]
		local isOutput = fe.Outputs[name]
		local isDeath = (name=="Dead")
		local _event = data
		if type(_event) == "table" then
			_event = _event[1]
		else
			_event = nil
		end
		entity["Event_"..name] = function(self, sender, param)
			-- auto broadcast received things for outputs
			if isOutput and (sender and sender.id == self.spawnedEntity or sender==self) then
--				AI.LogEvent( ">>broadcasting output event "..name );
				BroadcastEvent(self, name)
			end
			-- forward events where necessary
			if isInput and (self.spawnedEntity and ((not sender) or (self.spawnedEntity ~= sender.id))) then
				local ent = System.GetEntity(self.spawnedEntity)
				if _event and ent and ent ~= sender then
					_event(ent, sender, param)
				end
			elseif _event and not self.spawnedEntity then
				-- and pass through where not
				_event(self, sender, param)
			end
			-- handle death events
			if isDeath and (sender and sender.id == self.spawnedEntity) then
				self.spawnedEntity = nil
			end
		end
	end

	-- spawn event
	function entity:Event_Spawn()
	
		local entityIdDone = self:Event_Spawn_Internal();
		
		-- the entity needs the output being activated, is not enough to just activate the output on the entity that spawnedMe, because the flowgraph could be already forwarded to the newly spawned entity (if the entity does not have the flowgraph asociated, the output event will be just ignored)
		if (entityIdDone ~= self.id) then
				self:ActivateOutput("Spawned", self.id);
		end
		
	end
	
	
	function entity:Event_Spawn_Internal()
		if self.whoSpawnedMe then
			-- we were spawned (and not placed on a level)...
			-- GetForwardingEntity will make sure that this event
			-- is sent here first, but this event *MUST* be handled
			-- by our spawner
			return self.whoSpawnedMe:Event_Spawn_Internal()
		else
			if self.spawnedEntity then
				return nil
			end
			local params = {
				class = self.class;
				position = self:GetPos(),
				orientation = self:GetDirectionVector(1),
				scale = self:GetScale(),
				archetype = self:GetArchetype(),
				properties = self.Properties,
				propertiesInstance = self.PropertiesInstance,
			}
			if (self.InitialPosition) then
				params.position = self.InitialPosition;
			end
			if self.Properties.SpawnedEntityName ~= "" then
				params.name = self.Properties.SpawnedEntityName
			else
				params.name = self:GetName().."_s"
				
			end
			local ent = System.SpawnEntity(params, self.id)
			if ent then
				self.spawnedEntity = ent.id
				self.lastSpawnedEntity = ent.id;
				if not ent.Events then ent.Events = {} end
				local evts = ent.Events
				for name, data in pairs(self.FlowEvents.Outputs) do
					if not evts[name] then evts[name] = {} end
					table.insert(evts[name], {self.id, name})
				end
				ent.whoSpawnedMe = self;
				
				ent:SetupTerritoryAndWave();
		
				--self:Event_Spawned();
				self:ActivateOutput("Spawned", ent.id);
				return self.id;
			end
		end
	end

	-- spawn event keep
	function entity:Event_SpawnKeep()
		local params = {
			class = self.class;
			position = self:GetPos(),
			orientation = self:GetDirectionVector(1),
			scale = self:GetScale(),
			archetype = self:GetArchetype(),
			properties = self.Properties,
			propertiesInstance = self.PropertiesInstance,
		}
		local rndOffset = 1;
		params.position.x = params.position.x + random(0,rndOffset*2)-rndOffset;
		params.position.y = params.position.y + random(0,rndOffset*2)-rndOffset;
		params.name = self:GetName()
		local ent = System.SpawnEntity(params, self.id)
		if ent then
			self.spawnedEntity = ent.id
			self.lastSpawnedEntity = ent.id;
			if not ent.Events then ent.Events = {} end
			local evts = ent.Events
			for name, data in pairs(self.FlowEvents.Outputs) do
				if not evts[name] then evts[name] = {} end
				table.insert(evts[name], {self.id, name})
			end
--			ent.whoSpawnedMe = self;
			--self:Event_Spawned();
			self:ActivateOutput("Spawned", ent.id);
		end
	end
	
--hidhing/unhiding should be done inside desable/enable	
--	function entity:Event_Hide()
--		self:Hide(1)
--	end

	fe.Inputs["Spawn"] = {entity.Event_Spawn, "bool"}
--	fe.Inputs["Hide"] = {entity.Event_Hide, "bool"}
	fe.Outputs["Spawned"] = "entity";
end

---------------------------------------------------------------------------------------------------
-- Physicalize rigid body.
---------------------------------------------------------------------------------------------------
--GlobalPhysicsSimParams = { max_logged_collisions = 1 };


EntityCommon.PhysicalizeRigid = function( entity,nSlot,Properties,bActive )
  local Mass = Properties.Mass; 
  local Density = Properties.Density;
  
  local physType;
  
  if (Properties.bArticulated == 1) then
		physType = PE_ARTICULATED;
	else
		if (Properties.bRigidBody == 1) then
			physType = PE_RIGID;
		else
			physType = PE_STATIC;
		end
		
	end
	
	local TempPhysParams = EntityCommon.TempPhysParams;

	TempPhysParams.density = Density;
	TempPhysParams.mass = Mass;
	TempPhysParams.flags = 0;
		
	entity:Physicalize( nSlot, physType, TempPhysParams );
	
	--entity:SetPhysicParams(PHYSICPARAM_SIMULATION, GlobalPhysicsSimParams );
	
	
	local Simulation = Properties.Simulation;
	if (Simulation) then
		entity:SetPhysicParams(PHYSICPARAM_SIMULATION, Simulation);
	end
	
	local Buoyancy = Properties.Buoyancy;
	if (Buoyancy) then
		entity:SetPhysicParams(PHYSICPARAM_BUOYANCY, Buoyancy);
	end
	
	-----------------------------------------------------------------------------
	-- Set physical flags.
	-----------------------------------------------------------------------------
	local PhysFlags = EntityCommon.TempPhysicsFlags;
	PhysFlags.flags =  0;
	if (Properties.bPushableByPlayers == 1) then
	  PhysFlags.flags = pef_pushable_by_players;
	end
	if (Simulation and Simulation.bFixedDamping and Simulation.bFixedDamping==1) then
		PhysFlags.flags = PhysFlags.flags+pef_fixed_damping;
	end
	if (Simulation and Simulation.bUseSimpleSolver and Simulation.bUseSimpleSolver==1) then
		PhysFlags.flags = PhysFlags.flags+ref_use_simple_solver;
	end
	if (Properties.bCanBreakOthers==nil or Properties.bCanBreakOthers==0) then
		PhysFlags.flags = PhysFlags.flags+pef_never_break;
	end
	PhysFlags.flags_mask = pef_fixed_damping + ref_use_simple_solver + pef_pushable_by_players + pef_never_break;
	entity:SetPhysicParams( PHYSICPARAM_FLAGS,PhysFlags );
	-----------------------------------------------------------------------------

	if (Properties.bResting == 0) then
		entity:AwakePhysics(1);
	else
		entity:AwakePhysics(0);
	end
end

-------------------------------------------------------------------------------
-- Compare entities by name (for table.sort)
-------------------------------------------------------------------------------

function CompareEntitiesByName( ent1, ent2 )
	return ent1:GetName() < ent2:GetName()
end

function MakeCompareEntitiesByDistanceFromPoint( point )
	function CompareEntitiesByDistanceFromPoint( ent1, ent2 )
		distance1 = DistanceSqVectors( ent1:GetWorldPos(), point )
		distance2 = DistanceSqVectors( ent2:GetWorldPos(), point )
		return distance1 > distance2
	end
	return CompareEntitiesByDistanceFromPoint
end

-------------------------------------------------------------------------------
-- Called by Pool System when an Entity is bookmarked for pool usage
--  - Gives us its EntityId and PropertiesInstance tables for logic-driven utilities
-------------------------------------------------------------------------------

function OnEntityBookmarkCreated( entityId, propertiesInstance )

	local waveName = nil;
	if (propertiesInstance and propertiesInstance.AITerritoryAndWave) then
		waveName = propertiesInstance.AITerritoryAndWave.aiwave_Wave;
	end
	
	if (waveName and waveName ~= "<None>") then
		
		-- Notify territory and wave
		AddBookmarkedToWave(entityId, waveName);
		return false;
		
	end
	
	return true;

end
