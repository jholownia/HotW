AIWave = {
	type = "AIWave",

	Editor =
	{
		Icon = "wave.bmp",
	},
	
	
	-- at any moment, liveAIs.size() + deadAIs.size() should be = total number of AIs in the wave. 
	-- (this actually is not true at *ANY* moment: AIs can be removed/added to one of the lists "now", and then added/removed from the other one in the next frame)	
	
	liveAIs = {}, -- liveAIs and deadAIs now store in the "value", the ID of the static entity that originated the spawn chain that created the current entity at the end.
	deadAIs = {}, -- 
	bookmarkAIs = {},  -- is set on level startup, and never modified after that. 
	toSpawnFromDeadBookmarks = {},
	
	nActiveCount = 0,
	nBodyCount   = 0,
	nPoolQueueCount = 0,
	bEnableOnAdd = false,
	bIsEnabling = false,
	bIsPreparingBookmarks = false,
	bBookmarsHaveBeenPrepared = false,  -- the first time, we need to prepare all bookmarks, not just the ones in the live list
}


AIWaveBookmarkCache = {};


--################# global functions ##################################

function ExecuteAIWaveBookmarkCache(myName)
	for entityId,waveName in pairs(AIWaveBookmarkCache) do
		local wave = GetAIWaveFromName(waveName);
		if (wave and wave:GetName() == myName) then
			wave:AddBookmarked(entityId);
			AIWaveBookmarkCache[entityId] = nil;
		end
	end
end


-------------------------------------------------------------------------
-- this function is called only on level init. this, with ExecuteAIWaveBookmarkCache(), solves the problem of entity AIs created before the entity Wave.
function AddBookmarkedToWave(entityId, wave)
	local waveTbl = GetAIWaveFromName(wave);
	if (waveTbl) then
		waveTbl:AddBookmarked(entityId);
	else
		AIWaveBookmarkCache[entityId] = wave;
	end
end


-----
function GetAIWave(entity)
	local waveName = entity.AI.Wave;
	return GetAIWaveFromName(waveName);
end

-----
function GetAIWaveFromName(waveName)
	if (waveName) then
		return System.GetEntityByName(waveName);
	end
	return nil;
end


-- ########  bookmark helpers ######################################

------------------------------------------------------------------------------
-- restores into the active pool all bookmarked alive AIs  (or all of them if it is the first time)
function AIWave:PrepareBookmarkedAI()
	self.bIsPreparingBookmarks = true;

	local isFirstTime = not self.bBookmarsHaveBeenPrepared;

	if (self:GetPoolQueueCount() <= 0) then
		for entityId,v in pairs(self.bookmarkAIs) do
			local entity = System.GetEntity(entityId);
			local isInLiveList = Set.Get( self.liveAIs, entityId );
			if (not entity and (isInLiveList or isFirstTime) ) then
				if (System.PrepareEntityFromPool(entityId)) then -- If prepared immediatly, will call Add() during this call which will decrement pool queue count by 1
					self.nPoolQueueCount = self.nPoolQueueCount + 1;
				else
					local name = self:GetName();
					System.Warning("Input Enable of AI Wave " .. name .. " failed to prepare pooled entity");
				end
			end
		end
	end

	self.bBookmarsHaveBeenPrepared = true;
	self.bIsPreparingBookmarks = false;
end


--------------------------------------------------------------------------------
function AIWave:ResetBookmarkedAI()
	if (System.GetCVar("es_ClearPoolBookmarksOnLayerUnload") > 0) then
		for entityId,v in pairs(self.bookmarkAIs) do
			System.ResetPoolEntity(entityId);
		end
	end
end



--###########- AI Wave FG events -#####################################

---------------------------------------------------------------------------------
function AIWave:Event_Disable()
	local name = self:GetName();
	if (ActiveWaves[name]) then
		local affectedTerritories = Set.New();
		
		-- disable all alive non-bookmarked entities
		for entityId,v in pairs(self.liveAIs) do
			local entity = System.GetEntity(entityId)
			if (entity) then
				if (self:CheckAlive(entity) and IsEntityEnabled(entity)) then

					if (not Set.Get( self.bookmarkAIs, entityId )) then -- if is not bookmarked, disable. 
						entity:Event_Disable();
					end
					local territory = entity.AI.TerritoryShape;
					if (territory) then  
						Set.Add(affectedTerritories, territory);
					end
				end
			end
		end
		
		self:ReturnBookmarkedAI();
		
		ActiveWaves[name] = false;
		BroadcastEvent(self, "Disabled");
		
		self:UpdateActiveCount();
		UpdateTerritoriesActiveCounts(affectedTerritories);
	end

end

-- re-bookmark the bookmarked entities
function AIWave:ReturnBookmarkedAI()
	for entityId,v in pairs(self.bookmarkAIs) do
		System.ReturnEntityToPool(entityId);
	end
end


---------------------------------------------------------------------------------
function AIWave:Event_Enable()
	self.bIsEnabling = true;

	local name = self:GetName();
	if (not ActiveWaves[name]) then
		
		self:PrepareBookmarkedAI();

		local foundLiveAI = false
		for entityID,v in pairs(self.liveAIs) do
			foundLiveAI = true
			local entity = System.GetEntity(entityID)
			if (entity) then
				if (self:CheckAlive(entity)) then
					local territory = entity.AI.TerritoryShape;
					if ((not territory) or (ActiveTerritories[territory])) then
						self:TryBecomeActive(name);
		
						if (not IsEntityEnabled(entity)) then
							entity:Event_Enable();
						end
					else
						if (not territory) then
							System.Warning("Input Enable of AI Wave " .. name .. " about to fail : nil territory!");
						else
							System.Warning("Input Enable of AI Wave " .. name .. " about to fail : territory " .. territory .. " is not active!");
						end
					end
				end
			end
		end
	
		self.bIsEnabling = false;
	
		if (ActiveWaves[name]) then
			self:UpdateActiveCount();
		elseif (not foundLiveAI) then
			System.Warning("Couldn't find any live AI in AI wave " .. name .. ". It will be enabled as soon as an AI is added to it.");
			self.bEnableOnAdd = true;
		end
	end
	
	self.bIsEnabling = false;
	
end


---------------------------------------------------------------------------------
function AIWave:Event_Spawn()
	self.bIsEnabling = true;
	
	local enabled = false;
	local spawned = false;

	local name = self:GetName();
	if (not ActiveWaves[name]) then
		
		self:PrepareBookmarkedAI();
		
		for entityID,v in pairs(self.liveAIs) do
			local entity = System.GetEntity(entityID)
			if (entity) then
				local territory = entity.AI.TerritoryShape;
				if ((not territory) or ActiveTerritories[entity.AI.TerritoryShape]) then
					self:TryBecomeActive(name);

					if (self:CheckAlive(entity)) then
						enabled = true;
						if (not IsEntityEnabled(entity)) then
							entity:Event_Enable();
						end
					end
				end
			end
		end
		
	end
	

	-- restore the bookmarked ones from the deadlist. we need to do this because we cant spawn a new AI when the initial static AI is bookmarked
	self.bIsPreparingBookmarks = true;
	for entityId,staticId in pairs(self.deadAIs) do
		local entity = System.GetEntity(staticId);
		if (not entity) then
		  Set.Set( self.toSpawnFromDeadBookmarks, staticId, entityId );  -- to know which AI is the one that was actually dead, corresponding to the staticAI. we will need that info when going to spawn the new AI when Add() is called
			if ( not System.PrepareEntityFromPool(staticId)) then
				local name = self:GetName();
				System.Warning("AIWave " .. name .. " failed to prepare pooled entity: %s", tostring(staticId));
			end
			if ( not Set.Get(self.toSpawnFromDeadBookmarks, staticId)) then  -- if is already not in the list, is because System.PrepareEntityFromPool recovered the entity instantly, and a new entity has been already spawned
				spawned = true;
			end
			
		end
	end
	self.bIsPreparingBookmarks = false;

	
  -- normal respawn from dead entities	
	for entityId,staticId in pairs(self.deadAIs) do
		local entity = System.GetEntity(entityId);
		local staticEntity = System.GetEntity(staticId);

-- if staticEntity is not there, is because it was bookmarked, and is in queue to be restored from bookmark. The spawn will happens when the entity is actually restored. ( Add() will be called, and e spawn will be done there)
		if (entity and staticEntity) then 
			local territory = entity.AI.TerritoryShape;
			if ((not territory) or (ActiveTerritories[entity.AI.TerritoryShape])) then
				self:TryBecomeActive(name);
			
				entity:Event_Spawn();
				spawned = true;
				Set.Remove(self.deadAIs, entity.id);
				
				if (entity.vehicle) then
					-- Vehicles reset, not re-spawn, so SetupTerritory would operate on a dead vehicle, without any effect
					Set.Add(self.liveAIs, entity.id);
				end
			end
		end
	end
	
	self.bIsEnabling = false;

	if (not ActiveWaves[name]) then
		System.Warning("Input Spawn of AI Wave " .. name .. " was activated but it was not enabled");
	end

	if (enabled or spawned) then
		self:UpdateActiveCount();

		-- Give AIs some time to really spawn
		Script.SetTimerForFunction(500, "DelayedBroadcastEventSpawned", self);
	end
	
end
function DelayedBroadcastEventSpawned(entity)
	if (entity and (type(entity) == "table")) then
		BroadcastEvent(entity, "Spawned")
	end
end

--------------------------------------------------------------------------------
function AIWave:TryBecomeActive(name)
	if (self.bIsPreparingBookmarks) then
		return;
	end
	
	if (not ActiveWaves[name]) then
		if (not self.nPoolQueueCount or self.nPoolQueueCount <= 0) then
			ActiveWaves[name] = true;
			BroadcastEvent(self, "Enabled");
		end
	end
end


---------------------------------------------------------------------------------
function AIWave:Event_Kill()
	local name = self:GetName();
	if (ActiveWaves[name]) then
		for entityID,v in pairs(self.liveAIs) do
			local entity = System.GetEntity(entityID)
			if (entity) then
				if (self:CheckAlive(entity)) then
					local territory = entity.AI.TerritoryShape;
					if ((not territory) or ActiveTerritories[entity.AI.TerritoryShape]) then
						if (IsEntityEnabled(entity)) then
							entity:Event_Kill();
						end
					end
				end
			end
		end
	end
end


---------------------------------------------------------------------------------------
function AIWave:Event_DisableAndClear()
	self:Event_Disable();
	self:ResetBookmarkedAI();
end



--########### ################################---------------------

function AIWave:AllowActorRemoval(entity)
	local name = self:GetName();
	if (not ActiveWaves[name]) then
	  return true;
	end

	if (Set.Get( self.deadAIs, entity.id ) ) then -- if the corpse entity is one of the last spawned entities, dont remove. we need it for next respawn.	
    return false;
	end
	
	return true;
end


---------------------------------------------------------------------------------------
function AIWave:OnInit()
	self.bookmarkAIs = Set.New();
	self:OnReset();
end


---------------------------------------------------------------------------------------
function AIWave:OnLoad(tbl)
	local name = self:GetName();
	ActiveWaves[name] = tbl.bIsActive;
	
	self.liveAIs = Set.DeserializeEntities(tbl.liveAIs);
	self.deadAIs = Set.DeserializeEntities(tbl.deadAIs);
	self.toSpawnFromDeadBookmarks = Set.DeserializeEntities(tbl.toSpawnFromDeadBookmarks);
	
	self.bookmarkAIs = Set.New();
	self.bookmarkAIs = Set.DeserializeItems(tbl.bookmarkAIs);
	
	self.nActiveCount = tbl.nActiveCount;
	self.nBodyCount   = tbl.nBodyCount;
	self.nPoolQueueCount = tbl.nPoolQueueCount;
	self.bEnableOnAdd = tbl.bEnableOnAdd;
	self.bIsEnabling = tbl.bIsEnabling;
	self.bIsPreparingBookmarks = tbl.bIsPreparingBookmarks;
	self.bBookmarsHaveBeenPrepared = tbl.bBookmarsHaveBeenPrepared;
end


---------------------------------------------------------------------------------------
-- OnReset() is usually called only from the Editor, so we also need OnInit()
function AIWave:OnReset()
	local name = self:GetName();
	ActiveWaves[name] = false;
	
	self.liveAIs = Set.New();
	self.deadAIs = Set.New();
	self.toSpawnFromDeadBookmarks = Set.New();
	
	ExecuteAIWaveBookmarkCache(name);
	
	self.nActiveCount = 0;
	self.nBodyCount   = 0;
	self.nPoolQueueCount = 0;
	self.bEnableOnAdd = false;
	self.bIsEnabling = false;
	self.bIsPreparingBookmarks = false;
	self.bBookmarsHaveBeenPrepared = false;
end


---------------------------------------------------------------------------------------
function AIWave:OnSave(tbl)
	local name = self:GetName();
	tbl.bIsActive = ActiveWaves[name];
	
	tbl.liveAIs = Set.SerializeEntities(self.liveAIs);
	tbl.deadAIs = Set.SerializeEntities(self.deadAIs);
	tbl.toSpawnFromDeadBookmarks = Set.SerializeEntities(self.toSpawnFromDeadBookmarks);
	tbl.bookmarkAIs = Set.SerializeItems(self.bookmarkAIs);
	
	tbl.nActiveCount = self.nActiveCount;
	tbl.nBodyCount   = self.nBodyCount;
	tbl.nPoolQueueCount = self.nPoolQueueCount;
	tbl.bEnableOnAdd = self.bEnableOnAdd;
	tbl.bIsEnabling = self.bIsEnabling;
	tbl.bIsPreparingBookmarks = self.bIsPreparingBookmarks;
	tbl.bBookmarsHaveBeenPrepared = self.bBookmarsHaveBeenPrepared;
end;


--[[
function AIWave:LogAIsTables( place )
  Log( "-@@@@@@-loging AIsTables from: %s --@@@@@@@@", place );
	for entityId,staticId in pairs(self.liveAIs) do
		Log( "-@@@@@@-live AI: %s %s", tostring(entityId), tostring(staticId) );
	end
	for entityId,staticId in pairs(self.deadAIs) do
		Log( "-@@@@@@@-dead AI: %s %s", tostring(entityId), tostring(staticId) );
	end
  Log( "------@@@----------END----------@@@--------", place );
  Log( " " );
end
--]]

-------------------------------------------------------------------------------------
function AIWave:OnHidden()
	self:ResetBookmarkedAI();
end


--######### AI Wave private methods ############################


------------------------------------------------------------------
-- returns the ID of the static entity that spawned this one
function AIWave:GetStaticEntityID( entity )
	if (entity.whoSpawnedMe) then
		return entity.whoSpawnedMe.id;
  else
  	return entity.id;
  end
end
	
			

------------------------------------------------------------------------
-- this function is called when a new AI is spawned
function AIWave:Add(entity)
	local name = self:GetName();
	if (name == entity.AI.Wave) then
		local staticID = self:GetStaticEntityID( entity );
	
		if (Set.Get(self.bookmarkAIs, entity.id)) then
			if ( not Set.Get(self.toSpawnFromDeadBookmarks, entity.id )) then -- this should always be true (as not being in the list) anyway, adding just for extra precaution
				Set.Add( self.liveAIs, entity.id, staticID );
				self:AddFromBookmark(entity);
			end
		else
			Set.Add( self.liveAIs, entity.id, staticID );
			self:AddNormal(entity);
		end
	end
end

------------------------------------------------------------------------
function AIWave:AddNormal(entity)
	-- evgeny: I don't remember why IsEntityEnabled(entity) is important here
	--if (IsEntityEnabled(entity)) then
	if (true) then
		local name = self:GetName();
		local territory = entity.AI.TerritoryShape;
		local AICanBeActivated = ((not territory) or ActiveTerritories[territory]);
		
		if (AICanBeActivated) then
			if (not ActiveWaves[name]) then
				if (self.bEnableOnAdd) then
					self:Event_Enable();
				end
			end
			self.bEnableOnAdd = false;
			
			if (ActiveWaves[name]) then
				self:UpdateActiveCount();
				return;
			end
	  end
	end
	entity:Event_Disable(); -- this only happens when the AIWave was not active and for some reason could not be enabled
end

------------------------------------------------------------------------
function AIWave:AddFromBookmark(entity)
	self.nPoolQueueCount = self.nPoolQueueCount - 1;
	local name = self:GetName();
	local territory = entity.AI.TerritoryShape;
	if ((not territory) or (ActiveTerritories[territory])) then
		entity:Activate(1);
		entity:Event_Enable();

		self:TryBecomeActive(name);
		self:UpdateActiveCount();
	end
end

------------------------------------------------------------------------
-- called only on level start, when bookmarks are created
function AIWave:AddBookmarked(entityId)
	Set.Add(self.bookmarkAIs, entityId);
end

-----------------------------------------------------------------------
function AIWave:OnEntityPreparedFromPool( entity )
	local entityIdToSpawnFrom = Set.Get(self.toSpawnFromDeadBookmarks, entity.id );
	
	-- we were waiting for this static entity (entityId) to come back from bookmarked state, to spawn a new entity from the dead one (which is not the static one, but the last one spawned from it)
	if (entityIdToSpawnFrom) then 
		local deadEntity = System.GetEntity(entityIdToSpawnFrom)
		if (deadEntity) then -- this should always be true
			if (deadEntity.whoSpawnedMe) then
				deadEntity.whoSpawnedMe = entity;  -- while the static entity was bookmarked, the dynamic entity kept the table, but now it needs to use the new one
			end
			entity.spawnedEntity = nil;
			deadEntity:Event_Spawn();
			
			if (deadEntity.vehicle) then
				-- Vehicles reset, not re-spawn, so SetupTerritory would operate on a dead vehicle, without any effect
				Set.Add(self.liveAIs, deadEntity.id);
			end
		end
		Set.Remove(self.deadAIs, entityIdToSpawnFrom);
		Set.Remove(self.toSpawnFromDeadBookmarks, entity.id );
	end
end


------------------------------------------------------------------------
-- called from CheckAlive, and also from the territory when the AI dies.
function AIWave:NotifyDeath(entity)
	if (Set.Get(self.liveAIs, entity.id)) then
	  local staticID = self:GetStaticEntityID( entity );
		Set.Remove(self.liveAIs, entity.id);
		Set.Add(self.deadAIs, entity.id, staticID);
		
		self:UpdateActiveCount(true);	-- Check if the wave is dead
		self.nBodyCount = self.nBodyCount + 1;
		self:ActivateOutput("BodyCount", self.nBodyCount);
	end
end

------------------------------------------------------------------------
function AIWave:IsEnabling()
	return self.bIsEnabling;
end

------------------------------------------------------------------------
function AIWave:GetPoolQueueCount()
	if (self.nPoolQueueCount >= 0) then
		return self.nPoolQueueCount;
	end
	
	return 0;
end

------------------------------------------------------------------------
function AIWave:GetActiveCount()
	return self.nActiveCount;
end

------------------------------------------------------------------------
function AIWave:UpdateActiveCount(bCheckIfDead)
	-- Only output the active count when we're doing becomming enabled
	if (self:IsEnabling()) then
		return;
	end

	local name = self:GetName();
	local activeCount = self:GetPoolQueueCount();
	local affectedTerritories = Set.New();


	if (ActiveWaves[name]) then
		for entityID,v in pairs(self.liveAIs) do
			local entity = System.GetEntity(entityID)
			if (entity) then
				if ((not entity:IsDead()) and IsEntityEnabled(entity)) then
					activeCount = activeCount + 1;
				end
				local territory = entity.AI.TerritoryShape;
				if (territory) then  
					Set.Add(affectedTerritories, territory);
				end
			end
		end
	end

	    
	if (activeCount ~= self.nActiveCount) then
		self.nActiveCount = activeCount;
		if (self:GetPoolQueueCount()==0) then  -- we dont activate the output if there are entities waiting to be retrieved from the pool, to avoid many activations of the output in consecutive frames.
			self:ActivateOutput("ActiveCount", self.nActiveCount);
			UpdateTerritoriesActiveCounts(affectedTerritories);
		end
		
		--System.Log("Wave " .. activeCount);
		
		if (bCheckIfDead and (self.nActiveCount == 0)) then
			BroadcastEvent(self, "Dead");
		end
	end
end

------------------------------------------------------------------------
function AIWave:CheckAlive(entity)
	if (entity:IsDead()) then
		self:NotifyDeath(entity);
		return false;
	end
	return true;
end






------------ AI Wave FG node ------------------------------------

AIWave.FlowEvents =
{
	Inputs =
	{
		Disable = { AIWave.Event_Disable, "bool" },
		Enable  = { AIWave.Event_Enable,  "bool" },
		Kill    = { AIWave.Event_Kill,    "bool" },
		Spawn   = { AIWave.Event_Spawn,   "bool" },
		
		DisableAndClear = { AIWave.Event_DisableAndClear, "bool" },
	},

	Outputs =
	{
		ActiveCount = "int",
		BodyCount   = "int",
		Dead        = "bool",
		Disabled    = "bool",
		Enabled     = "bool",
		Spawned     = "bool",
	},
}
