MusicPlayPattern = {
	type = "MusicPlayPattern",

	Editor = {
		Icon="Music.bmp",
	},

	Properties = {
		sPattern = "",
		bStopPrevious = 0,
		bPlaySynched = 0,
		bPlayOnTop = 0,
	},
	InsideArea=0,
	InsideAreaRefCount=0,
}

function MusicPlayPattern:OnSave(stm)
	stm.bStopPrevious = self.Properties.bStopPrevious
	stm.bPlaySynched = self.Properties.bPlaySynched
	stm.bPlayOnTop = self.Properties.bPlayOnTop
end

function MusicPlayPattern:OnLoad(stm)
	self.Properties.bStopPrevious = stm.bStopPrevious
	self.Properties.bPlaySynched = stm.bPlaySynched
	self.Properties.bPlayOnTop = stm.bPlayOnTop
end

function MusicPlayPattern:OnPropertyChange()
	if (self.InsideArea==1) then
		Sound.PlayPattern(self.Properties.sPattern, self.Properties.bStopPrevious, self.Properties.bPlaySynched, self.Properties.bPlayOnTop);
	end
end

function MusicPlayPattern:CliSrv_OnInit()
end

function MusicPlayPattern:OnShutDown()
end

function MusicPlayPattern:Client_OnEnterArea( player,areaId )
	self.InsideArea=1;
	Sound.PlayPattern(self.Properties.sPattern, self.Properties.bStopPrevious, self.Properties.bPlaySynched, self.Properties.bPlayOnTop);
end


function MusicPlayPattern:Event_PlayPattern(  )
	Sound.PlayPattern(self.Properties.sPattern, self.Properties.bStopPrevious, self.Properties.bPlaySynched, self.Properties.bPlayOnTop);
end


MusicPlayPattern.Server={
	OnInit=function(self)
		self:CliSrv_OnInit()
	end,
	OnShutDown=function(self)
	end,
	Inactive={
	},
	Active={
	},
}

MusicPlayPattern.Client={
	OnInit=function(self)
		self:CliSrv_OnInit()
	end,
	OnShutDown=function(self)
	end,
	OnEnterArea = MusicPlayPattern.Client_OnEnterArea,

}

MusicPlayPattern.FlowEvents =
{
	Inputs =
	{
		PlayPattern = { MusicPlayPattern.Event_PlayPattern, "bool" },
	},
	Outputs =
	{

	},
}
