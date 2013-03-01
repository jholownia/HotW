-----------------------------------------------------------
-- Cover3 Fallen Behavior
-----------------------------------------------------------
-- Created: Matthew Jack 12-10-2009
-- Description: Based on the HBaseTranquilized behavior,
--              reapplied to use behavior trees
-----------------------------------------------------------

local Behavior = CreateAIBehavior("Cover3Fallen", "Dumb",
{
	Alertness = 1,
	exclusive = 1,

	Constructor = function(self,entity,data)
		AI.ModifySmartObjectStates(entity.id,"Busy");
		entity:InsertSubpipe( AIGOALPIPE_HIGHPRIORITY, "cv_tranquilized", nil, -190 );
		entity:TriggerEvent(AIEVENT_SLEEP);
	end,	
	---------------------------------------------
	Destructor = function(self,entity)
		AI.ModifySmartObjectStates(entity.id,"-Busy");
		entity:CancelSubpipe( -190 );
	end,
	---------------------------------------------
	OnSeenByEnemy = function( self, entity, sender )
	end,
	---------------------------------------------
	OnQueryUseObject = function ( self, entity, sender, extraData )
	end,
	---------------------------------------------
	OnEnemySeen = function( self, entity, fDistance )
	end,
	---------------------------------------------
	OnTargetDead = function( self, entity )
	end,
	--------------------------------------------------
	OnBulletHit = function( self, entity, sender,data )
	end,
	---------------------------------------------
	OnSomethingSeen = function( self, entity )
	end,
	---------------------------------------------
	OnThreateningSeen = function( self, entity )
	end,
	--------------------------------------------------
	OnNoHidingPlace = function( self, entity, sender,data )
	end,	
	---------------------------------------------
	OnBackOffFailed = function(self,entity,sender)
	end,
	---------------------------------------------
	GET_ALERTED = function( self, entity )
	end,
	---------------------------------------------
	DRAW_GUN = function( self, entity )
	end,
	---------------------------------------------
	OnEnemyMemory = function( self, entity )
	end,
	---------------------------------------------
	OnInterestingSoundHeard = function( self, entity )
	end,
	---------------------------------------------
	OnThreateningSoundHeard = function( self, entity, fDistance )
	end,
	--------------------------------------------------
	OnCoverRequested = function ( self, entity, sender)
	end,
	---------------------------------------------
	OnDamage = function ( self, entity, sender)
	end,
	---------------------------------------------
	OnEnemyDamage = function ( self, entity, sender,data)
	end,
	---------------------------------------------
	OnReload = function( self, entity )
	end,
	--------------------------------------------------
	OnBulletRain = function ( self, entity, sender,data)
	end,
	--------------------------------------------------
	OnObjectSeen = function( self, entity, fDistance, signalData )
	end,
	---------------------------------------------
	OnCloseContact = function(self,entity,sender)
	end,
	---------------------------------------------
	OnPathFound = function(self,entity,sender)
	end,
	---------------------------------------------
	OnNoTarget = function(self,entity,sender)
	end,
	--------------------------------------------------
	-- CUSTOM SIGNALS
	--------------------------------------------------

	--------------------------------------------------
	OnSomebodyDied = function( self, entity, sender)
	end,
	--------------------------------------------------
	OnGroupMemberDiedNearest = function ( self, entity, sender,data)
	end,
	--------------------------------------------------
	INVESTIGATE_TARGET = function (self, entity, sender)
	end,
	---------------------------------------------
	-- GROUP SIGNALS
	--------------------------------------------------
	HEADS_UP_GUYS = function (self, entity, sender)
	end,
	---------------------------------------------
	INCOMING_FIRE = function (self, entity, sender)
	end,
	---------------------------------------------
	OnHideSpotReached = function ( self, entity, sender,data)
	end,
	-------------------------------------------------
})