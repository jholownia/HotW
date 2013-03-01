--------------------------------------------------------------------------
MatchMakingSearchResult =
{
	SessionId = nil,
	SearchId = 0,
	TimeFound = 0,
	Parameters =
	{
		ActiveStatus = 0,
		ServerAvSkill = 0,
		Region = 0,
		Language = 0,
		BadServer = 0,
		Ping = 0,
		FilledSlots = 0,
		Score = 0,
	},
}

Filters = 
{
	Initial = 
	{
		IdealPlayerCount = 6,
		MaxPing = 100,
		MaxSkillDiff = 100
	},
	Max = 
	{
		IdealPlayerCount = 6,
		MaxPing = 300,
		MaxSkillDiff = 1000
	},
}

--------------------------------------------------------------------------
MatchMaking =
{
	SearchResults = {},
	bIsSearching = false,
	bInitialSearch = false,
	MostRecentSearch = 0, --Stores the most recent search id that we know has returned usable results
	bFindingBetterHost = false,
}


--[[
Matchmaking Design

When we enter matchmaking : If we are alone, start searching; If we are a squad leader, create a sesession; If we are a squad member, remain passive.
If we find a session we want to join, attempt to join it and start another search (preparing for failure)
If we're a lobby host, search for game to merge to
If we're in a lobby, not a lobby host and not in a squad, if our ping degrades search for alternative games, only move after user prompt
If we become the host after host migration, start searching
If we stop being the host after host migration, don't so any further searches

]]--

--------------------------------------------------------------------------
-- Functions called from C++
--------------------------------------------------------------------------
function MatchMaking:OnInit()
end

--------------------------------------------------------------------------
function MatchMaking:OnEnterMatchMaking()
	System.Log("MMLua: Enter Matchmaking");

	self.bInitialSearch = true;
	if ( (self.bindings:IsSquadLeaderOrSolo() == 1) and (self.bIsSearching == false) ) then
		if( self.bindings:GetNumPlayersInSquad() > 1 ) then
			--we're actually squadded up
			self:CreateServer();
		else
			self:StartSearching();
		end
	end
	--Not squad leader means we're a squad member
	--Leader will search for us, we can just be passive
end

--------------------------------------------------------------------------
function MatchMaking:OnLeaveMatchMaking()
	self.SearchResults = {};
	if (self.bIsSearching) then
		self.bindings:CancelSearch();
		self.bIsSearching = false;
	end
	-- Delete this lua object at this point.
	-- If we get into a bad state leaving matchmaking and re-entering will allow players to fix it
	self = nil
end

--------------------------------------------------------------------------
function MatchMaking:OnSearchResult( result )
	-- Use rules to determine what we think of this result
	
	local filterTable
	if( self.bInitialSearch ) then
		filterTable = Filters.Initial
	else
		filterTable = Filters.Max
	end
	
	Log("MMLua: Filtertable figs ".. filterTable.IdealPlayerCount .." ".. filterTable.MaxPing .." ".. filterTable.MaxSkillDiff ) 
		
	local discard = false
	local secondary = false
	--make this whatever we think is a reasonable ping
	if( result.Parameters.Ping > filterTable.MaxPing ) then
		Log("MMLua: discarding server because ping is too high");
		discard = true
	end
	
	local ownSkill = self.bindings:GetAverageSkillScore()
	if( result.Parameters.ServerAvSkill ~= 0 and ownSkill ~= 0 ) then
		local skillDiff = ownSkill - result.Parameters.ServerAvSkill
		
		if( skillDiff < 0 ) then
			skillDiff = -skillDiff
		end
	
		if( skillDiff > filterTable.MaxSkillDiff ) then
			Log("MMLua: discarding server because skill diff is too high");
			discard = true
		end
	end
	
	if( discard == false ) then
		--order based on num players and random score
		local playersScore = clamp( result.Parameters.FilledSlots / filterTable.IdealPlayerCount, 0, 1 )
		
		result.Parameters.Score = playersScore + randomF( 0, 0.3 )
		
		table.insert( self.SearchResults, result );
		
		if( result.SearchId > self.MostRecentSearch ) then
			self.MostRecentSearch = result.SearchId
		end
		
	end
	
	-- we have not considered language or region in this check
end

--------------------------------------------------------------------------
function MatchMaking:OnSearchFinished()
	System.Log("MMLua: On Search Finished");
	self.bIsSearching = false;
	self.bInitialSearch = false;
	
	--remove expired results
	self:RemoveExpiredSessions();

	local bIsJoiningSession = self.bindings:IsJoiningSession();
	local bIsSessionHost = self.bindings:IsSessionHost();
	local bIsInSession = self.bindings:IsInSession();
	
	--[[
	if( bIsJoiningSession == 0 ) then
		Log("MMLua: bIsJoiningSession is false");
	else
		Log("MMLua: bIsJoiningSession is not false");
	end
	
	if( bIsSessionHost == 1 ) then
		Log("MMLua: bIsSessionHost is true");
	else
		Log("MMLua: bIsSessionHost is not true");
	end
	
	if( bIsInSession == 0 ) then
		Log("MMLua: bIsInSession is false");
	else
		Log("MMLua: bIsInSession is not false");
	end
	]]
	
	if ( bIsJoiningSession == 0 ) then 
		if ( ( bIsSessionHost == 1 ) or ( bIsInSession == 0 ) ) then
			self:HandleServerList();
		elseif( self.bFindingBetterHost == true ) then
			self:HandleServerListClientQuality();
		end
	end
	
end

--------------------------------------------------------------------------
function MatchMaking:OnJoinFinished(bSuccess)
	Log("MMLua: Join Finished");
	if (bSuccess == false) then
		self.bFindingBetterHost = false
		self:HandleServerList();
	else
		--setup to poll ping every so often
		self.bindings:RequestUpdateCall( 10.0 )	
		
		--temp - expire all search results
		self.MostRecentSearch = self.MostRecentSearch + 1;
	end
end

--------------------------------------------------------------------------
function MatchMaking:OnMergeFinished(bSuccess)
	Log("MMLua: Merge Finished");
	if (bSuccess == false) then
		self.bFindingBetterHost = false
		self:HandleServerList();
	else
		--check if we're the host after the merge
		if( self.bindings:IsSessionHost() == 1 ) then
			Log("MMLua: we are now the host");
			if ( self.bindings:HasGameStarted() == 0 ) then
				self:StartSearching();
			end
		elseif( self.bindings:GetNumPlayersInSquad() < 2 ) then		
			--setup to poll ping every so often
			self.bindings:RequestUpdateCall( 10.0 )
			--temp - expire all search results
			self.MostRecentSearch = self.MostRecentSearch + 1;
		end
	end
end

--------------------------------------------------------------------------
function MatchMaking:OnCreateFinished(bSuccess)
	--always the host after creating
	self:HandleServerList();
	self.bFindingBetterHost = false
end

--------------------------------------------------------------------------
function MatchMaking:OnHostMigrationFinished(bSuccess, bIsNewHost)
	Log("MMLua: Host Migration finished")
	
	if (bSuccess) then
		if (bIsNewHost) then
			Log("MMLua: we are now the host");
			self.bFindingBetterHost = false
			if ( self.bindings:HasGameStarted() == 0 ) then
				self:StartSearching();
			end
		else
			if (self.bIsSearching) then
				self.bindings:CancelSearch();
				self.bIsSearching = false;
			end
			
			if( self.bindings:GetNumPlayersInSquad() < 2 ) then
				--setup to poll ping every so often
				self.bindings:RequestUpdateCall( 10.0 )
			end
		end
	else
		--fail on host migrate means we're not in a session anymore I think
		self.bFindingBetterHost = false
		if (self.bIsSearching == false) then
			self:StartSearching();
		end
	end
end

function MatchMaking:Update()
	--only do ping to host checking if we're not the host and not in a squad
	--Log( "MMLua: Subscribed Update" );
	
	if( self.bindings:IsSessionHost() == 0 and self.bindings:GetNumPlayersInSquad() < 2 ) then
		local ping = self.bindings:GetCurrentPing()
		
		Log( "MMLua: Current Ping is "..ping );
		
		if( ping > 400 ) then
			self.bFindingBetterHost = true
			self:StartSearching();
		else
			self.bindings:RequestUpdateCall( 10.0 )
		end
	end
end

--------------------------------------------------------------------------
-- Internal functions
--------------------------------------------------------------------------
function MatchMaking:StartSearching()
	System.Log("MMLua: Starting a Search");
	local requiredFreeSlots = self.bindings:GetNumPlayersInCurrentSession();
	local squadMembers = self.bindings:GetNumPlayersInSquad();
	
	if( squadMembers > requiredFreeSlots ) then
		requiredFreeSlots = squadMembers;
	end
	
	local maxResults = 20;
	local parameters = {
		playlist = { val = self.bindings:GetCurrentPlaylist(), operator = eCSSO_Equal, },
		variant = { val = self.bindings:GetCurrentVariant(), operator = eCSSO_Equal, },
		required_dlcs = { val = self.bindings:GetAvailableDLCs(), operator = eCSSO_LessThanEqual, },
	};
	self.bIsSearching = self.bindings:StartSearch( requiredFreeSlots, maxResults, parameters );
end

--------------------------------------------------------------------------
function MatchMaking:RemoveExpiredSessions()
	--iterate backwards so we don't trample on data we're about to visit
	Log("MMLua: Removing expired sessions, MostRecentSearch is "..self.MostRecentSearch )
	
	for i = #self.SearchResults, 1, -1 do	
		if( self.SearchResults[i].SearchId < self.MostRecentSearch ) then
			table.remove( self.SearchResults, i )
		end
	end
end

--------------------------------------------------------------------------
function MatchMaking:HandleServerList()
	System.Log("MMLua: Handle Server List");
	local bInSession = self.bindings:IsInSession();
	
	local serverToJoin = self:FindBestServer();
	if (bInSession==1) then
		-- possibly merge?
		if (serverToJoin) then
			Log("MMLua: Merge");
			self.bindings:MergeWithServer(serverToJoin.SessionId);
		end
	else
		if (serverToJoin) then
			Log("MMLua: Join");
			self.bindings:JoinServer(serverToJoin.SessionId);
		else
			Log("MMLua: Create");
			self:CreateServer();
		end
	end

	if (self.bIsSearching == false) then
		self:StartSearching();
	end
end

--------------------------------------------------------------------------
function MatchMaking:HandleServerListClientQuality()
	
	Log("MMLua: Handle server list looking for better");
	self.bFindingBetterHost = false
	
	if( self.bindings:GetNumPlayersInSquad() < 2 ) then
		--Find how many servers are good enough to warrant moving
		local halfCurrentPing = self.bindings:GetCurrentPing() / 2
		local count = 0
		
		for i, entry in ipairs(self.SearchResults) do
			if( entry ) then
				if( entry.Parameters.Ping < halfCurrentPing ) then
					count = count + 1
				end
			end
		end
		
		--If more than 2, prompt user to move
		if( count > 2 ) then
			--tricky to bind, for now lets assume they said yes
			local serverToJoin = self:FindBestServer();
			Log("MMLua: Join");
			self.bindings:JoinServer(serverToJoin.SessionId);
		else
			--no servers atm, check quality again later
			self.bindings:RequestUpdateCall( 20.0 )
		end
	end
end

--------------------------------------------------------------------------
function MatchMaking:FindBestServer()
	local serverToJoin = nil;
	local index = nil;
	local bestScore = 0;
	local isInGame = 1;
	
	Log( "MMLua: Finding Best Server" )

	for i, entry in ipairs(self.SearchResults) do
		if( entry ) then
			Log( "MMLua: Have a server index "..i.." score "..entry.Parameters.Score )
			if( entry.Parameters.Score > bestScore ) then
				--prefer servers which are still on lobby screen if possible
				if( (isInGame == 1) or (entry.Parameters.ActiveStatus == 0) ) then
					Log( "MMLua: This server has better score than "..bestScore )
					serverToJoin = entry;
					index = i;
					bestScore = entry.Parameters.Score;
					isInGame = entry.Parameters.ActiveStatus;
				end
			end
		end
	end

	if (index) then
		table.remove( self.SearchResults, index );
	end		
	
	return serverToJoin;
end


--------------------------------------------------------------------------
function MatchMaking:CreateServer()
	--Set whatever extra/modified parameters we want on our created server
	local parameters = 	{
		playlist = self.bindings:GetCurrentPlaylist(),
	};

	self.bindings:CreateServer( parameters );
end