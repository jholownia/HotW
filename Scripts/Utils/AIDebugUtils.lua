----------------------------------------------------------------------------
--- AI Debug Utils
----------------------------------------------------------------------------
-- Debugging aids for AI
--
----------------------------------------------------------------------------
-- 26/10/2006			Created		Matthew Jack
----------------------------------------------------------------------------
-- Reload with: #Script.ReloadScript("Scripts/Utils/AIDebugUtils.lua");
----------------------------------------------------------------------------

AIDebugUtils = AIDebugUtils or {};


----------------------------------------------------------------------------
-- Logging of signals
----------------------------------------------------------------------------

-- Decode the varying format of parameters that come with signals
-- into a human-readable logging message
AIDebugUtils.DecodeSignalValues = function(arg,argc)
	local i = 0;
	local argc = argc or 0;
	local s = "";
	while ( i< argc ) do
		i = i + 1;
		local value = arg[i];
		
		if (type(value) == "table") then
			-- Is the table an AI?
			if (value.GetPos and value.GetName) then
			  local AiName = value:GetName() or "None";
				if (not value:GetPos()) then
					AiName = AiName.."(DEAD)";
				end
				value = AiName;
			-- Is it the player?
			elseif (value.class == "Player") then
				value = "Player";
			-- Is it a reference to the signaldata table?
			elseif (value.iValue or value.fValue or value.point) then
				local i = value.iValue;
				local i2 = value.iValue2;
				local f = value.fValue;
				local o = value.ObjectName
				local id = value.id;
				local p = value.point;
				local p2 = value.point2;

				local strData = "{<SignalData> ";
				if (value ~= g_SignalData) then
					--strData = strData.."!! Not global !!";
				end
				
				if (i and i ~= 0) then
					strData = strData.."iValue="..tostring(i)..", ";
				end
				if (i2 and i2 ~= 0) then
					strData = strData.."iValue2="..tostring(i2)..", ";
				end
				if (f and f ~= 0) then
					strData = strData.."fValue="..tostring(f);
					if (type(f) == "number" and f%1 < 0.00001) then
						-- Integer, so this might be an id...
						local entity = System.GetEntity(math.floor(f));
						if (entity) then 
							strData = strData.."(id? "..tostring( entity:GetName() or "DEAD" )..")";
						end
					end
					strData = strData..", ";
					value = strData;
				end
				if (o and o ~= "") then
					strData = strData.."ObjectName="..tostring(o)..", ";
				end
				if (id and id ~= NULL_ENTITY) then
					local entity = System.GetEntity(id);
					local entityName = entity and entity:GetName() or "?";
					
					strData = strData.."id="..tostring(id).."("..entityName.."), ";
				end
				if (p and not IsNullVector(p)) then
					strData = strData.."point={"..tostring(p.x)..","..tostring(p.y)..","..tostring(p.z).."}, ";
				end
				if (p2 and not IsNullVector(p2)) then
					strData = strData.."point2={"..tostring(p2.x)..","..tostring(p2.y)..","..tostring(p2.z).."}, ";
				end
				value = strData.."}";
			else
				local strTab = "{ ";
				for i,v in pairs(value) do
					strTab = strTab..tostring(i).."="..tostring(v)..", ";
				end
				value = strTab.."}";
			end
		elseif (type(value)=="number") then
			if (value%1 < 0.00001) then
				-- Integer, so this might be an id...
				local entity = System.GetEntity(math.floor(value));
				if (entity) then 
					value = tostring(value).."(id? "..tostring( entity:GetName() or "DEAD" )..")";
				end
			end
		end
		
		s = s..tostring(value)..",\t";		
	end

	return s;
end


-- Install hooks on a certain behavior, optionally for certain AIs
-- Hooks report decoded paramters and signal data for every signal, straight to console
-- Can be installed, removed, and entities specified all at runtime
function AIDebugUtils.InstallSignalHooks( behavior, ... )
	-- Get the list of entities to include, nil means "all"
	local entityList = Set.New();
	for i,name in ipairs(arg) do
		Set.Add(entityList,name);
	end

	AIDebugUtils.RemoveSignalHooks( behavior );

	behavior.oldHandlers = {};
	-- Insert a logging hook into all the above functions
	for name,fun in pairs(behavior) do
		-- Store the original handler for later recovery
		behavior.oldHandlers[name] = fun;		
		-- Install new handler that eventually calls the old one
		if (type(fun) == "function") then
			behavior[name] = function(behavior, entity, ... )
				local entityName = ( entity and entity.GetName and entity:GetName() ) or "None";
	
				-- Optionally, only print debugging info for given entities
				if (Set.Size(entityList) == 0 or Set.Get(entityList,entityName)) then 
					-- How many arguments were passed in?
					local argc = 0;
					for i = 1, 10 do
						if (arg[i]~=nil) then
							argc = i;
						end
					end
					
					-- Print out those arguments
					local s = "AI \""..entityName.."\", Signal \""..name.."\",\t";
					System.Log( s .. AIDebugUtils.DecodeSignalValues(arg,argc) );
				end
				
				fun(behavior, entity, unpack(arg));
			end
		end
	end
end


-- Remove all hooks on a certain behavior
function AIDebugUtils.RemoveSignalHooks( behavior, name )
	-- Looks up original handlers from previously stored table
	if (behavior.oldHandlers) then
		for name, fun in pairs (behavior.oldHandlers) do
			behavior[name] = fun;
		end
	end
	behavior.oldHandlers = nil;
end


-- Make sure originals are captured and ones hooked
function AIDebugUtils.CheckHookedFunctions()
	if (not AIDebugUtils.originalGoalPipeFunctions) then
		-- In case this is called too early
		if (AI) then
			-- Check if we've integrated already :-)
			if (AI.BeginGoalPipe) then
				System.Log("[AIDebugUtils] Error: (warning) New goalpipe scriptbinds exist now -  Lua versions ignored and should be dropped"); 
				return;
			end
		
			AIDebugUtils.originalGoalPipeFunctions = {
				PushGoal = AI.PushGoal,
				PushLabel = AI.PushLabel,
			}
		end
	end
	
	-- Add the new wrapper functions
	AI.BeginGoalPipe = BeginGoalPipe;
	AI.EndGoalPipe = EndGoalPipe;

	-- Hook these in
	AI.PushGoal = PushGoal;
	AI.PushLabel = PushLabel;
end
		
		
		
----------------------------------------------------------------------------
-- Sending signals by hand more conveniently
-- Uses AI.Signal(0,1,...) and no signal data
----------------------------------------------------------------------------

AIDebugUtils.defaultEntityName = nil;

-- Private helper function
function AIDebugUtils.GetEntityID(entityName)
	if (entityName==nil) then
		System.Log("[AIDebugUtils] Error: No entity given");
		return nil;
	end
	local entity = System.GetEntityByName(entityName)
	if (entity) then
		return entity.id;
	else
		System.Log("[AIDebugUtils] Error: Entity not found");
		return nil;
	end
end

-- Set a default entity to send signals to
function AIDebugUtils.SignalEntityDefault(entityName)
	if (AIDebugUtils.GetEntityID(entityName)) then
		AIDebugUtils.defaultEntityName = entityName;
	else
		System.Log("[AIDebugUtils] Error: Entity not found");
	end
end

-- Send a signal to one or more entities, ignoring default
function AIDebugUtils.SignalEntity(signalName,...)
	local id = AIDebugUtils.GetEntityID(arg[1]);
	if (not id or id==0) then
		System.Log("[AIDebugUtils] Arguments changed: now (signalName, entity1, (entity2)...)");
	end
	if (not signalName or type(signalName)~="string") then
		System.Log("[AIDebugUtils] Error: No signal given");
	else
		for i,entityName in ipairs(arg) do
			AI.Signal(0,1,signalName,AIDebugUtils.GetEntityID(entityName));
		end
	end
end

-- Send signal to the default entity
function AIDebugUtils.Signal(signalName,...)
	if (arg and arg[1]) then 
		System.Log("[AIDebugUtils] Error: Ignored extra arguments: "..tostring(arg[1]).."...");
	end
	local entityID = AIDebugUtils.GetEntityID(AIDebugUtils.defaultEntityName);
	if (entityID) then 
		AI.Signal(0,1,signalName,entityID);
	end
end

function AIDebugUtils.SignalRadius(signalName,radius)
	if (not signalName or type(signalName)~="string") then
		System.Log("[AIDebugUtils] Error: No signal given");
	else
		AI.FreeSignal(0,signalName,System.GetViewCameraPos(),radius);
	end
end


-- Make global shortcuts
SignalEntityDefault = AIDebugUtils.SignalEntityDefault;
SignalEntity = AIDebugUtils.SignalEntity;
Signal = AIDebugUtils.Signal;
SignalRadius = AIDebugUtils.SignalRadius;




