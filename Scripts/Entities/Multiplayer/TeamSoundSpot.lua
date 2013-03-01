--------------------------------------------------------------------------
--	Crytek Source File.
-- 	Copyright (C), Crytek Studios, 2001-2006.
--------------------------------------------------------------------------
--	$Id$
--	$DateTime$
--	Description: Team specific sound spot...
--  
--------------------------------------------------------------------------
--  History:
--  - 6/ 2/2007   11:27 : Created by Márcio Martins
--
----------------------------------------------------------------------------------------------------
Script.ReloadScript("scripts/entities/sound/soundeventspot.lua");
----------------------------------------------------------------------------------------------------
TeamSoundSpot = new(SoundEventSpot);
TeamSoundSpot.Properties.soundName=nil;
TeamSoundSpot.MAX_TEAM_COUNT = 4;

for i=1,TeamSoundSpot.MAX_TEAM_COUNT do
	TeamSoundSpot.Properties["TeamSound"..i]={
		teamName="",
		soundName="",
	};
end


----------------------------------------------------------------------------------------------------
function TeamSoundSpot:OnSpawn() -- just to avoid setting CLIENT_ONLY flag
end


----------------------------------------------------------------------------------------------------
function TeamSoundSpot:OnSetTeam(teamId)
	local teamName=g_gameRules.game:GetTeamName(teamId);
	for i=1,TeamSoundSpot.MAX_TEAM_COUNT do
		local soundProps=self.Properties["TeamSound"..i];
		if (soundProps and soundProps.teamName==teamName) then
			-- stop old
			self:Stop();
			if (soundProps.soundName~="") then
				self:Play(soundProps.soundName);
			end
			break;
		end
	end

	if (self.teamId) then
		self.teamId=teamId;
	end
end


----------------------------------------------------------------------------------------------------
function TeamSoundSpot:Play(soundName)
	if (soundName) then
		-- put the correct team name where SoundEventSpot will look for it
		self.Properties.soundName=soundName;
		SoundEventSpot.Play(self);
		self.Properties.soundName=nil;
	end
end