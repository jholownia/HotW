-- Coordination Utilities

function isLeader(actor)
	if (actor.AI and actor.AI.isLeader) then
		return true;
	end
	return false;
end

function getLeader(actors)
	for i,actor in ipairs(actors) do
		if (isLeader(actor)) then
			return actor.id;
		end
	end
end

function getTarget(actors)
	for i,actor in ipairs(actors) do
		local	enemy = AI.GetAttentionTargetEntity(actor.id);
		if (enemy) then
			return enemy.id;
		end
	end
end


function canThrowGrenade(actor, equipment)
	Log("hasequip");
	if (actor.inventory:GetItemByClass(equipment)) then
		--if (actor:CanThrowGrenade(true)) then
		Log("hasequip 2");
			return 1;
		--end
	end

	return 0;
end

function getTargetDistance(actor)
	local distance = AI.GetAttentionTargetDistance(actor.id)
	if not distance then
		--Log("Candidate Coordination Actor: %s had no attention target to check against for distance.", actor:GetName())
		return -1
	--Check against double float eps, for some reason small values were being returned and causing a FPE in subsequent calculations - Morgan 12/01/2010
	elseif distance > 0.000002 then
		return distance
	else
		-- A suitably small value
		return 0.1
	end
end

function getCenter(actors)
	local posSum = { x=0, y=0, z=0};
	local posCount = 0;
	local pos = g_Vectors.temp_v1;

	for i,actor in ipairs(actors) do
		actor:GetWorldPos(pos);
		posSum.x = posSum.x + pos.x;
		posSum.y = posSum.y + pos.y;
		posSum.z = posSum.z + pos.z;
		posCount = posCount + 1;
	end

	posSum.x = posSum.x / posCount;
	posSum.y = posSum.y / posCount;
	posSum.z = posSum.z / posCount;

	return posSum;
end

function getLeftScore(actor, center, targetId)
	local pos = actor:GetWorldPos(g_Vectors.temp_v1);
	local target = System.GetEntity(targetId):GetWorldPos(g_Vectors.temp_v2);
	local dir = g_Vectors.temp_v3;
	local normal = g_Vectors.temp_v4;

	SubVectors(dir, target, center);
	crossproduct3d(normal, g_Vectors.up, dir);
	NormalizeVector(normal);

	local d = -dotproduct3d(normal, center);
	return normal.x * pos.x + normal.y * pos.y + normal.z * pos.z + d;
end

function getRightScore(actor, center, targetId)
	local pos = actor:GetWorldPos(g_Vectors.temp_v1);
	local target = System.GetEntity(targetId):GetWorldPos(g_Vectors.temp_v2);
	local dir = g_Vectors.temp_v3;
	local normal = g_Vectors.temp_v4;

	SubVectors(dir, target, center);
	crossproduct3d(normal, dir, g_Vectors.up);
	NormalizeVector(normal);

	local d = -dotproduct3d(normal, center);
	return normal.x * pos.x + normal.y * pos.y + normal.z * pos.z + d;
end

function getDistanceToDeadEntityScore(actor, deadEntityPosition)
	local distSq = DistanceSqVectors(actor:GetWorldPos(), deadEntityPosition)
	local capedDistSq = 40 * 40;
	return (1 - (__min(distSq, capedDistSq) / capedDistSq));
end

function RetrieveCoordinationActors(behavior, groupId, filterFunction, prepareFunction, excludedCoordinations)
	local groupList = {}
	local groupCount = AI.GetGroupCount(groupId);
	for i=1,groupCount do
		local groupMember = AI.GetGroupMember(groupId, i);
		if( groupMember ) then
			local currentCoordination = AI.GetCurrentCoordinationName(groupMember.id)
			if( (not filterFunction or filterFunction(behavior, groupMember)) and (not excludedCoordinations or not excludedCoordinations[currentCoordination]) ) then
				if(prepareFunction) then
					prepareFunction(behavior, groupMember);
				end
				table.insert(groupList, groupMember.id);
			end
		end
	end
	return groupList
end

StartCoordinatedReadability = function(behavior, entity, coordinationName, communicationName, channel, filterCoordinations, filterFunction)

	local coordinations = {}
	coordinations[coordinationName] = true
	if(filterCoordinations ~= nil) then
		coordinations = filterCoordinations
	end
	if( coordinations[AI.GetCurrentCoordinationName(entity.id)] ) then
		return
	end	
	
	local groupId = AI.GetGroupOf(entity.id)
	-- If actor isn't already in coordination, and part of a valid group ,then try starting coordination
	if( groupId > 0 and (not filterFunction or filterFunction(behavior, entity) ) ) then
		AI.StartCoordinationWithSelectMembers(coordinationName, RetrieveCoordinationActors(behavior, groupId, behavior.CanCoordinate, nil, coordinations));					
	else
		--Fall back for non-grouped AI, just play basic communication, these shouldn't even exist so just choose 3 secs as reasonable expiration
		AI.PlayCommunication(entity.id, communicationName, channel, 4)		
	end
end

