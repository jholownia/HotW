Map = {
}

---------------------------------------------------------
--
function Map:Insert(key, value)
	self[key] = value;
end

---------------------------------------------------------
--
function Map:Remove(key)
	self[key] = nil;
end

---------------------------------------------------------
--push a value at the end of the map and return the key
function Map:Push(val)
	local key=getn(self)+1;
	self[key]=val;
	return key;
end

---------------------------------------------------------
--pop a value from the end of the map and return the val
function Map:Pop()
	local key=getn(self);
	local val=self[key];
	self[key]=nil;
	return val;
end