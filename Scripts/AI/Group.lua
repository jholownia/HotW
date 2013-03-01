AIGroup =
{
	defendPressureThreshold = 0.75,
	
	OnSaveAI = function(self, save)
		save.deathContext = self.deathContext
	end,
	
	OnLoadAI = function(self, saved)
		self.deathContext = saved.deathContext
	end,
}