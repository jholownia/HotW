----------------------------------------------------------------------------
--
-- Description :		triggers when becomes empty/occupied
--
--
-- Create by Kirill :	16 May 2006
--
----------------------------------------------------------------------------
AICheckInBox = {
	type = "Trigger",

	Properties = {
		DimX = 5,
		DimY = 5,
		DimZ = 5,
		bTriggerOnce=0,		
		esFaction = "",
	},
	Editor={
		Model="Editor/Objects/T.cgf",
		Icon="Trigger.bmp",
		ShowBounds = 1,
	},
	updateRate = 2000,
--	PopulationTable = {},
}

-------------------------------------------------------------------------------
function AICheckInBox:OnPropertyChange()
--System.Log( "AICheckInBox:OnPropertychange");
--	self:OnReset();
--	self:KillTimer(0);
	
	local Min = { x=-self.Properties.DimX/2, y=-self.Properties.DimY/2, z=-self.Properties.DimZ/2 };
	local Max = { x=self.Properties.DimX/2, y=self.Properties.DimY/2, z=self.Properties.DimZ/2 };
	self:SetTriggerBBox( Min, Max );
	--self:Log( "BBox:"..Min.x..","..Min.y..","..Min.z.."  "..Max.x..","..Max.y..","..Max.z );

end

-------------------------------------------------------------------------------
function AICheckInBox:OnInit()
--	self:SetUpdatePolicy( ENTITY_UPDATE_PHYSICS );
--	self:OnReset();
--	self:KillTimer(0);

	self:OnPropertyChange();
	self:OnReset();
--	self.PopulationTable = {};
--	self.bTriggered = nil;
end

-------------------------------------------------------------------------------
function AICheckInBox:OnShutDown()
end

-------------------------------------------------------------------------------
function AICheckInBox:OnSave(tbl)
--	tbl.PopulationTable = self.PopulationTable
	tbl.bTriggered = self.bTriggered
end


-------------------------------------------------------------------------------
function AICheckInBox:OnLoad(tbl)
--	self.PopulationTable = {}
--	self.PopulationTable = tbl.PopulationTable
	self.bTriggered = tbl.bTriggered
end

-------------------------------------------------------------------------------
function AICheckInBox:OnReset()
	self.PopulationTable = {};
	self.bTriggered = nil;
end


-------------------------------------------------------------------------------
function AICheckInBox:Event_Occupied( sender )
	if (self.Properties.bTriggerOnce == 1 and self.bTriggered == 1) then
		return
	end
	self.bTriggered = 1;
	BroadcastEvent( self,"Occupied" );
end

-------------------------------------------------------------------------------
function AICheckInBox:Event_Empty( sender )
--	self:ActivateOutput("IsInside",self.Entered );

	if (self.Properties.bTriggerOnce == 1 and self.bTriggered == 1) then
		return
	end
	self.bTriggered = 1;
	BroadcastEvent( self,"Empty" );
end

-------------------------------------------------------------------------------
function AICheckInBox:OnTimer( )
		self:CheckThePopulation( );
end


-------------------------------------------------------------------------------
function AICheckInBox:CheckThePopulation( )

	if(self:IsSomebodyInside()==nil) then
		self:KillTimer(0);
		self:Event_Empty();
--System.Log( "AICheckInBox: >>>>>> going empty ");
		do return end
	end
--System.Log( "AICheckInBox:CheckThePopulation "..self:GetName().." >> "..numUnits );	
	self:SetTimer( 0,self.updateRate );
end

-------------------------------------------------------------------------------
function AICheckInBox:IsSomebodyInside( )

	local numUnits = count(self.PopulationTable);
--System.Log( "CheckThePopulation:>>>>>> nmb "..numUnits);
	for entityId,theId in pairs(self.PopulationTable) do
--System.Log( "CheckThePopulation:loop >>>>>> the ID "..tostring(entityId).." >> "..tostring(theId));
		local unit = System.GetEntity(theId);
		if(unit==nil or unit:IsDead()) then
			numUnits = numUnits - 1;
--System.Log( "AICheckInBox:dead unit found");			
		end
	end
	if(numUnits<1) then
		return nil
	end
	return 1
end


-------------------------------------------------------------------------------
function AICheckInBox:OnEnterArea( entity,areaId )

--local numUnits = count(self.PopulationTable);
	if (not self:IsValidSource(entity) ) then
		return
	end
	if(self:IsSomebodyInside()==nil) then
		self:Event_Occupied();
--System.Log( "AICheckInBox:OnEnterArea  --->>>> occupied");		
		self:SetTimer( 0,self.updateRate );
	end
	self.PopulationTable[entity.id] = entity.id;

--local unit = System.GetEntity(entity.id, entity.id);
--System.Log("AICheckInBox:OnEnterArea>>>> "..tostring(entity.id)..";  name "..entity:GetName());
--numUnits = count(self.PopulationTable);
--System.Log( "AICheckInBox:OnEnterArea  --->>>> "..numUnits );
end


-------------------------------------------------------------------------------
function AICheckInBox:OnLeaveArea( entity,areaId )

--local numUnits = count(self.PopulationTable);
	if(self.PopulationTable[entity.id] == nil) then 
		return 
	end
	self.PopulationTable[entity.id] = nil;

	self:CheckThePopulation( );
end

-------------------------------------------------------------------------------
-- Check if source entity is valid for triggering.
function AICheckInBox:IsValidSource( entity )

	if (entity.type == "Player") then
		return false;
	end

	if (entity.ai ~= nil and (AI.GetFactionOf(entity.id) == self.Properties.esFaction)) then 
		return true;
	end

	do return false end
end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
AICheckInBox.FlowEvents =
{
	Inputs =
	{
--		Disable = { AICheckInBox.Event_Disable, "bool" },
--		Enable = { AICheckInBox.Event_Enable, "bool" },
	},
	Outputs =
	{
		Empty = "bool",
		Occupied = "bool",
	},
}

-------------------------------------------------------------------------------
