----------------------------------------------------------------------------
--
-- Description :		Delayed proxymity trigger
--
-- Gravity trigger Create by Filippo : Jun 2004
----------------------------------------------------------------------------
GravitySphere = {

	name = "GravitySphere",
	
	Properties = {
		
		fGravityOutside = -9.81,
		fGravityInside = 0.0,	
		
		--sInsideRadiusTag = "",
		--sOutsideRadiusTag = "",
		
		fInsideRadius = 0,
		fOutsideRadius = 0,
		
		bStartEnabled = 1,
	},
	
	Editor={
		Model="Objects/default.cgf",
	},	
	
	temp_v1 = {x=0,y=0,z=0},
	
	bEnabled = 0,
}

function GravitySphere:OnPropertyChange()

	self:OnReset();
end

function GravitySphere:OnInit()

	--self:EnableUpdate(0);
	self:OnReset();
end

function GravitySphere:OnShutDown()
end

function GravitySphere:OnSave(props)
end


function GravitySphere:OnLoad(props)
end

function GravitySphere:GetPosGravity(vec)

	if (self.bEnabled == 0) then
		return nil;
	end
	
	local tempVec = self.temp_v1;
	
	CopyVector(tempVec,vec);	
	SubVectors(tempVec,tempVec,self:GetPos());
	
	local deltaDist = LengthSqVector(tempVec);--sqrt(LengthSqVector(tempVec));
	
	local maxDist = self.OutRadius * self.OutRadius;
	local minDist = self.InRadius * self.InRadius;
	
	--inside the radius?
	if (deltaDist < maxDist) then
		
		if (deltaDist < minDist) then 
			return self.Properties.fGravityInside; 
		end
		
		local mul = (deltaDist - minDist) / (maxDist - minDist);
		local gravity = self.Properties.fGravityInside + ((self.Properties.fGravityOutside - self.Properties.fGravityInside)*mul);
		
		return gravity;
	else
		return nil;
	end
end

function GravitySphere:SetRadius(inradius,outradius)
	
	self.InRadius = inradius;
	self.OutRadius = outradius;
		
	--if outer radius is smaller than the inner make them same
	if (self.InRadius > self.OutRadius) then self.OutRadius = self.InRadius; end
end

function GravitySphere:OnReset()

	self:KillTimer();
	
	local tempTagPos = self.temp_v1;
	
	local inRadius = self.Properties.fInsideRadius;
	local outRadius = self.Properties.fOutsideRadius;
	
	--FIXME:restore the tagpoint thing, if really necessary, ask designers
--	--inner radius
--	local temp = Game.GetTagPoint(self.Properties.sInsideRadiusTag);
--	
--	if (temp) then
--	
--		CopyVector(tempTagPos,temp);
--		FastDifferenceVectors(tempTagPos,tempTagPos,self:GetPos());
--		
--		inRadius = sqrt(LengthSqVector(tempTagPos));
--	end	
--	
--	--outer radius
--	temp = Game.GetTagPoint(self.Properties.sOutsideRadiusTag);
--	
--	if (temp) then
--	
--		CopyVector(tempTagPos,temp);
--		FastDifferenceVectors(tempTagPos,tempTagPos,self:GetPos());
--		
--		outRadius = sqrt(LengthSqVector(tempTagPos));
--	end	
	
	self:SetRadius(inRadius,outRadius);
	
	if (GravityGlobals) then
		
		GravityGlobals:RemoveGravityArea(self);
		GravityGlobals:AddGravityArea(self);
	end
	
--	System.Log(self:GetName().." inner:"..self.InRadius);
--	System.Log(self:GetName().." outer:"..self.OutRadius);
	
	if (self.Properties.bStartEnabled==1) then
		self.bEnabled = 1;
	else
		self.bEnabled = 0;
	end
end

function GravitySphere:Event_Enable( sender )
	
	self.bEnabled = 1;
	
	self:SendStatus(1);
	
	BroadcastEvent( self,"Enable" );
end

function GravitySphere:Event_Disable( sender )
	
	self.bEnabled = 0;
	
	self:SendStatus(0);
	
	BroadcastEvent( self,"Disable" );
end

function GravitySphere:SendStatus(enabled)
	
	if (Server) then
		
		Server:BroadcastCommand("GR "..self.id.." "..enabled);
		
--		local serverSlot = Server:GetServerSlotByEntityId(self.id);
--		
--		if (serverSlot) then
--			serverSlot:SendCommand("GR "..self.id.." "..enabled);
--		end
	end
end

GravitySphere.Events =
{
	Inputs =
	{
		Disable = { GravitySphere.Event_Disable, "bool" },
		Enable = { GravitySphere.Event_Enable, "bool" },
	},
	Outputs =
	{
		Disable = "bool",
		Enable = "bool",
	},
}
