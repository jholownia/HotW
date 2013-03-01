Ladder = {
  type = "Ladder",
  climbspeed = 1.8,

	Properties = {
		fileLadderCGF = "Objects/Outdoor/towers/sniper_tower_ladder.cgf",
		bPhysicalize = 1,
		fHAngleLimit = -1,
		fAngleOffset = 0,
		LockDist = 1,
		bSingleSided = 0,
	},

	lastFileName = "",
	lastSound=nil,
	limitBase = {x=0,y=0,z=0},
}

-------------------------------------------------
function Ladder:OnSave(props)
end

-------------------------------------------------
function Ladder:OnLoad(props)
	self:OnReset();
end

-------------------------------------------------
function Ladder:OnPropertyChange()
	self:OnReset();
end
-------------------------------------------------
function Ladder:OnReset()

	--self:SetName( "Ladder" );

	if (self.lastFileName ~= self.Properties.fileLadderCGF) then
		
		self:DestroyPhysics(); 		
		self:LoadObject( self.Properties.fileLadderCGF, 0, 0 );
		self.lastFileName = self.Properties.fileLadderCGF;
		if (self.Properties.bPhysicalize==1) then		
			self:CreateStaticEntity(100,-1);
			
			-- get bbox from physics
			local bbox = self:GetBBox(1);
	
			local minSz = bbox.max.x;
			
			if( minSz > bbox.max.y ) then
				minSz = bbox.max.y;
			end

			minSz = minSz*1.1;
			
			if(minSz > .01) then
				bbox.min.x = -minSz;
				bbox.min.y = -minSz;
				bbox.max.x = minSz;
				bbox.max.y = minSz;

--			-- set bbox to physics				
--				self:SetBBox(bbox.min, bbox.max, 1);
				self:SetBBox(bbox.min, bbox.max);
				
			end
				
	
			-- make bphys bbox little bigger
	--		-- scale it up
--	--		local bboxScale = 1.5;	
--			
--	--		bbox.min.x = bbox.min.x-.12;
--			bbox.min.x = -.1;
----			bbox.min.y = bbox.min.y-.12;
--			bbox.min.y = -.1;			
--	--		bbox.min.z = bbox.min.z-.2;
--	--		bbox.max.x = bbox.max.x+.12;
--			bbox.max.x = .1;
----			bbox.max.y = bbox.max.y+.12;
--			bbox.max.y = .1;
--	--		bbox.max.z = bbox.max.z+.2;
			
			
	--		bbox.min.x = bbox.min.x*bboxScale;
	--		bbox.min.y = bbox.min.y*bboxScale;
	--		bbox.min.z = bbox.min.z*bboxScale;
	--		bbox.max.x = bbox.max.x*bboxScale;
	--		bbox.max.y = bbox.max.y*bboxScale;
	--		bbox.max.z = bbox.max.z*bboxScale;
--			-- get bbox to physics
--			self:SetBBox(bbox.min, bbox.max, 1);
--			self:SetBBox(bbox.min, bbox.max);
			
		end	
		
	end

	self:DrawObject( 0, 1 );
	
	self.ladder_sound = {
		Sound.Load3DSound("sounds/player/footsteps/ladder/step1.wav",0,160,1,100),
		Sound.Load3DSound("sounds/player/footsteps/ladder/step2.wav",0,160,1,100),
		Sound.Load3DSound("sounds/player/footsteps/ladder/step3.wav",0,160,1,100),
		Sound.Load3DSound("sounds/player/footsteps/ladder/step4.wav",0,160,1,100),
	};
	self.lastSound=nil;
end
-------------------------------------------------------
function Ladder:OnInit()
	self:Activate(0);
	self:TrackColliders(1);
	
	self:OnReset();	
end

-------------------------------------------------------
function Ladder:UpdatePlayerSound( player )

	if (player.cnt.vel>1) then
		local Snd=self.ladder_sound[random(1, 4)];
		if (self.lastSound==nil) then
			self.lastSound=Snd;
		end
		
		if (not Sound.IsPlaying(self.lastSound)) then
			Sound.SetSoundPosition(Snd,player:GetPos()); -- must be played at player's position
			Sound.PlaySound(Snd);
			self.lastSound=Snd;
		end
	end
end

-------------------------------------------------------
function Ladder:OrientPlayer( player )

	player.cnt:SetAngleLimitBase( self.limitBase );
	player.cnt:SetMinAngleLimitH( -self.Properties.fHAngleLimit );
	player.cnt:SetMaxAngleLimitH( self.Properties.fHAngleLimit );
	player.cnt:EnableAngleLimitH( 1 );
end


-------------------------------------------------------
function Ladder:CheckDirection( player )

	local diff = new(player:GetPos());
	local diffDir = new(self:GetPos());
	diff.z=0;
	diffDir.z=0;
	
	diff.x = diffDir.x - diff.x;
	diff.y = diffDir.y - diff.y;
	
	ConvertVectorToCameraAngles( diffDir, diff );
	
	local playerZ = diffDir.z;
--			local playerZ = player:GetAngles().z;
	local selfAng = self:GetAngles(1);

	selfAng.z = selfAng.z + self.Properties.fAngleOffset;

	if( selfAng.z > 360 ) then
		selfAng.z = selfAng.z - 360;
	elseif( selfAng.z < 0 ) then
		selfAng.z = 360 + selfAng.z;
	end

	local selfZ = selfAng.z;
	local diffZ = playerZ - selfZ;

	if(diffZ>180) then
		diffZ = 360 - diffZ;
	elseif(diffZ<-180) then
		diffZ = 360 + diffZ;
	end	

--System.Log( "\001 Ladder on >>>>  "..diffZ.." "..selfZ.." "..playerZ );
--System.Log( "\001 Ladder on >>>>  "..self:GetAngles(1).z);
	
	if( diffZ < -90 or diffZ > 90 ) then
		if(self.Properties.bSingleSided == 1) then return nil end
		selfAng.z = selfAng.z + 180;
	end
	CopyVector( self.limitBase, selfAng);
	return 1
end


-------------------------------------------------------
function Ladder:OnEnterArea( player )

	if ( player.type ~= "Player") then return end

	if ( player.AI.theVehicle ) then return end -- this player is in some vehicle - can't use ladder

	if ( player.ai) then return end -- we don't want AIs to use ladders anymore
--	if ( player.ai) then 
--		AI:Signal(0,1,"START_CLIMBING",player.id);
--	end

-- can't do this coz there are many "double" ladders om levels
--	-- can't use ladder if was on ladder less then 1.5 sec ago
--	if ( player.ladderTime and _time-player.ladderTime<1.5 ) then return end

	--System.Log( "\001 Ladder on >>>>  " );
	

	if(not player.ladder and self:CheckDirection(player) ) then
--		player.cnt:SetMoveParams(self.climb_move_params);
--		player.cnt:OverrideMoveParams(self.climb_move_params);
		player.cnt:UseLadder(1, self.climbspeed, self:GetPos());

		local lockPt=Game:GetTagPoint( self:GetName().."_enter1" );
		if(lockPt) then
		local zDist = lockPt.z - player:GetPos().z;
			if( zDist>-self.Properties.LockDist and zDist<self.Properties.LockDist ) then
--				lockPt.z = player:GetPos().z;
				player:SetPos( lockPt );
			end	
		end	

                --angle limit disabled, since the player model is oriented to the ladder its not needed anymore,
                --and also it usually caused problems.
		--if(self.Properties.fHAngleLimit > 0 ) then
		--	self:OrientPlayer(player);
		--end
	end	

	player.ladder = self;
end


-------------------------------------------------------
function Ladder:OnLeaveArea( player )

	if ( player.type ~= "Player") then return end
	if ( player.ai) then return end	-- we don't want AIs to use ladders anymore
--	if ( player.ai) then 
--		AI:Signal(0,-1,"STOP_CLIMBING",player.id);
--	end

   --System.Log( "\001 Ladder off <<<<  " );


	if(player.ladder ~= self) then return end
	player.ladder = nil;
	player.ladderTime = _time;
	
--	player.cnt:SetMoveParams(player.move_params);
--	player.cnt:RestoreMoveParams( );	
	player.cnt:UseLadder(0);
--	if(self.Properties.bLockDirection == 1 ) then
		player.cnt:EnableAngleLimitH( 0 );
--	end	
end





-------------------------------------------------------
function Ladder:OnShutDown()
end

-------------------------------------------------------
function Ladder:OnActivate()
end

-------------------------------------------------------
function Ladder:Event_Unhide()

--	self:DrawObject(0,1);	
	self:Hide(0);
	
end	


-------------------------------------------------------
--
--function Ladder:DoSound()
--
--	--System.LogToConsole("speed="..player.cnt.vel);
--	if (player.cnt.vel>1) then
--		local Snd=self.ladder_sound[random(1, 4)];
--		if (self.lastSound==nil) then		
--			self.lastSound=Snd;
--		end
--		
--		if (not Sound.IsPlaying(self.lastSound)) then
--			Sound.SetSoundPosition(Snd,player:GetPos()); -- must be played at player's position
--			Sound.PlaySound(Snd);
--			self.lastSound=Snd;
--		end
--	end
--end

Ladder.FlowEvents =
{
	Inputs =
	{
		Unhide = { Ladder.Event_Unhide, "bool" },
	},
	Outputs =
	{
		Unhide = "bool",
	},
}
