VehiclePartDetached = {
	Client = {},
	Server = {},
	Properties = {
		bPickable = 1,
	},
		Editor={
		Icon = "Item.bmp",
		IconOnTop=1,
	},
}


function VehiclePartDetached:IsUsable(user)
	return 1;
	
end;

function VehiclePartDetached:GetUsableMessage(idx)
	return "@grab_object";
end;

function VehiclePartDetached:OnInit()
	self:OnReset();
end

function VehiclePartDetached:OnPropertyChange()
	self:OnReset();
end

function VehiclePartDetached:OnReset()
end

function VehiclePartDetached:SetObjectModel(model)
end

function VehiclePartDetached:OnSave(tbl)
end

function VehiclePartDetached:OnLoad(tbl)
end

function VehiclePartDetached:OnShutDown()
end

function VehiclePartDetached:Event_TargetReached( sender )
end

function VehiclePartDetached:Event_Enable( sender )
end

function VehiclePartDetached:Event_Disable( sender )
end

VehiclePartDetached.FlowEvents =
{
	Inputs =
	{
	},
	Outputs =
	{
	},
}
