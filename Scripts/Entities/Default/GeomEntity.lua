Script.ReloadScript("scripts/Utils/EntityUtils.lua")

GeomEntity =
{
}

------------------------------------------------------------------------------------------------------
function GeomEntity:OnPhysicsBreak( vPos,nPartId,nOtherPartId )
	self:ActivateOutput("Break",nPartId+1 );
end

------------------------------------------------------------------------------------------------------
function GeomEntity:Event_Remove()
	self:DrawSlot(0,0);
	self:DestroyPhysics();
	self:ActivateOutput( "Remove", true );
end

------------------------------------------------------------------------------------------------------
function GeomEntity:Event_Hide()
	self:Hide(1);
	self:ActivateOutput( "Hide", true );
end

------------------------------------------------------------------------------------------------------
function GeomEntity:Event_UnHide()
	self:Hide(0);
	self:ActivateOutput( "UnHide", true );
end

GeomEntity.FlowEvents =
{
	Inputs =
	{
		Hide = { GeomEntity.Event_Hide, "bool" },
		UnHide = { GeomEntity.Event_UnHide, "bool" },
		Remove = { GeomEntity.Event_Remove, "bool" },
	},
	Outputs =
	{
		Hide = "bool",
		UnHide = "bool",
		Remove = "bool",
		Break = "int",
	},
}

MakeTargetableByAI(GeomEntity);
MakeKillable(GeomEntity);
MakeInterestingToAI(GeomEntity, 0);