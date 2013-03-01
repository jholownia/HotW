Script.ReloadScript("scripts/Utils/EntityUtils.lua")

RopeEntity =
{
}

------------------------------------------------------------------------------------------------------
function RopeEntity:OnPhysicsBreak( vPos,nPartId,nOtherPartId )
	self:ActivateOutput("Break",nPartId+1 );
end

------------------------------------------------------------------------------------------------------
function RopeEntity:Event_Remove()
	self:DrawSlot(0,0);
	self:DestroyPhysics();
	self:ActivateOutput( "Remove", true );
end

------------------------------------------------------------------------------------------------------
function RopeEntity:Event_Hide()
	self:Hide(1);
	self:ActivateOutput( "Hide", true );
end

------------------------------------------------------------------------------------------------------
function RopeEntity:Event_UnHide()
	self:Hide(0);
	self:ActivateOutput( "UnHide", true );
end

------------------------------------------------------------------------------------------------------
function RopeEntity:Event_BreakStart( vPos,nPartId,nOtherPartId )
	local RopeParams = {}
	RopeParams.entity_name_1 = "#unattached";

	self:SetPhysicParams(PHYSICPARAM_ROPE,RopeParams);
end
function RopeEntity:Event_BreakEnd( vPos,nPartId,nOtherPartId )
	local RopeParams = {}
	RopeParams.entity_name_2 = "#unattached";

	self:SetPhysicParams(PHYSICPARAM_ROPE,RopeParams);
end


RopeEntity.FlowEvents =
{
	Inputs =
	{
		Hide = { RopeEntity.Event_Hide, "bool" },
		UnHide = { RopeEntity.Event_UnHide, "bool" },
		Remove = { RopeEntity.Event_Remove, "bool" },
		BreakStart = { RopeEntity.Event_BreakStart, "bool" },
    BreakEnd = { RopeEntity.Event_BreakEnd, "bool" },
	},
	Outputs =
	{
		Hide = "bool",
		UnHide = "bool",
		Remove = "bool",
		Break = "int",
	},
}

