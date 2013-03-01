Rain = {
	type = "Rain",
	Properties = {
		bEnabled = 1,
		fRadius = 50.0,
		fAmount = 1.0,
		fReflectionAmount = 1.0,
		fFakeGlossiness = 1.0,
		fPuddlesAmount = 3.0,
		bRainDrops = 1,
		fRainDropsSpeed = 1,
		clrColor = {x=1,y=1,z=1},
		fUmbrellaRadius = 0.0,
	},
	Editor={
		Icon="shake.bmp",
	},
}


function Rain:OnInit()
	self:OnReset();
end

function Rain:OnPropertyChange()
	self:OnReset();
end

function Rain:OnReset()
end

function Rain:OnSave(tbl)
end

function Rain:OnLoad(tbl)
end

function Rain:OnShutDown()
end

function Rain:Event_Enable( sender )
	self.Properties.bEnabled = 1;
	self:ActivateOutput("Enable", true);
end

function Rain:Event_Disable( sender )
	self.Properties.bEnabled = 0;
	self:ActivateOutput("Disable", true);
end

function Rain:Event_SetUmbrella( i, val )
	self.Properties.fUmbrellaRadius = val;
end

function Rain:Event_SetAmount( i, val )
	self.Properties.fAmount = val;
end

function Rain:Event_SetReflectionAmount( i, val )
	self.Properties.fReflectionAmount = val;
end

function Rain:Event_SetRadius( i, val )
	self.Properties.fRadius = val;
end

function Rain:Event_SetFakeGlossiness( i, val )
	self.Properties.fFakeGlossiness = val;
end

function Rain:Event_SetPuddlesAmount( i, val )
	self.Properties.fPuddlesAmount = val;
end

function Rain:Event_SetRainDrops( i, val )
	self.Properties.bRainDrops = val;
end

function Rain:Event_SetRainDropsSpeed( i, val )
	self.Properties.fRainDropsSpeed = val;	
end

function Rain:Event_SetColor( i, val )
	self.Properties.clrColor = val;
end


Rain.FlowEvents =
{
	Inputs =
	{
		Disable = { Rain.Event_Disable, "bool" },
		Enable = { Rain.Event_Enable, "bool" },
		Amount = { Rain.Event_SetAmount, "float" },
		Color = { Rain.Event_SetColor, "vec3" },
		ReflectionAmount = { Rain.Event_SetReflectionAmount, "float" },
		Radius = { Rain.Event_SetRadius, "float" },
		FakeGlossiness = { Rain.Event_SetFakeGlossiness, "float" },
		PuddlesAmount = { Rain.Event_SetPuddlesAmount, "float" },
		RainDrops = { Rain.Event_SetRainDrops, "bool" },
		RainDropsSpeed = { Rain.Event_SetRainDropsSpeed, "float" },
		UmbrellaRadius = { Rain.Event_SetUmbrella, "float" },
	},
	Outputs =
	{
		Disable = "bool",
		Enable = "bool",
	},
}
