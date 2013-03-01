--------------------------------------------------
--   Created By: Matthew Jack
--   Description: 
--		Idle test behavior
--    Tests AI building blocks in Idle state


local Behavior = CreateAIBehavior("TestIdle",
{
	Alertness = 0,

	-----------------------------------------------
	go_combat = function (self, entity)
		-- To transistion back to the combat test behavior
	end,
	
	OnNoTargetVisible = function (self, entity, sender, data)
	end,

	OnNoTargetAwareness = function (self, entity, sender, data)
	end,

	-----------------------------------------------
	-- Standard signals, for detection
	-----------------------------------------------
	Constructor = function (self, entity)
		System.Log("FOO");
		entity:InitAIRelaxed();		
		entity:SelectPipe(0,"do_nothing");
		
		self:DoPipeSelection(entity);
		
	end,

	---------------------------------------------
	Destructor = function(self, entity)

	end,
	
	---------------------------------------------
	
	DoPipeSelection = function(self,entity)
	
		entity:SelectPipe(0,"do_nothing");
		--entity:MakeAlerted();

 			-- Hack in pipes here for easy testing
		if ( TPSTestVar and TPSTestVar == 1 ) then
			entity:SelectPipe(0,"test_visibilityTest");
		elseif ( TPSTestVar and TPSTestVar == 2 ) then
			entity:SelectPipe(0,"test_lineOfFireTest");
		elseif ( TPSTestVar and TPSTestVar == 3 ) then
			entity:SelectPipe(0,"test_hostilesTest");
		elseif ( TPSTestVar and TPSTestVar == 4 ) then
			entity:SelectPipe(0,"test_simpleHide");
		elseif ( TPSTestVar and TPSTestVar == 5 ) then
			entity:SelectPipe(0,"test_simpleSquadmate");
		elseif ( TPSTestVar and TPSTestVar == 6 ) then
			entity:SelectPipe(0,"test_randomTest");
		elseif ( TPSTestVar and TPSTestVar == 7 ) then
			entity:SelectPipe(0,"test_reachableGridTest");
		end
	end,
 
	---------------------------------------------
	
 	OnQueryUseObject = function ( self, entity, sender, extraData )
 	end,
 	---------------------------------------------
 	
 	BT_GRAB_GIRL = function(self,entity)
 	end,
 	
 	OnAtGirl = function(self,entity)
 	end,
 	
 	GoingForGirl = function(self,entity)
 	end,
 	 	
 	OnNoPathFound = function(self,entity)
 		AI.LogEvent("TestIdle:NoPathFound:"..entity:GetName());
 	end,
 	
	START_VEHICLE = function(self,entity,sender)
	end,
	---------------------------------------------
--	VEHICLE_REFPOINT_REACHED = function( self,entity, sender )
--		-- called by vehicle when it reaches the reference Point 
--		--entity.theVehicle:SignalCrew("exited_vehicle");
--		AI.Signal(SIGNALFILTER_SENDER,1,"STOP_AND_EXIT",entity.theVehicle.id);
--	end,

	---------------------------------------------
	OnSelected = function( self, entity )	
	end,
	---------------------------------------------
	OnActivate = function( self, entity )
		-- called when enemy receives an activate event (from a trigger, for example)
	end,
	---------------------------------------------
	OnNoTarget = function( self, entity )
		-- caLled when the enemy stops having an attention target
	end,
	---------------------------------------------
	OnEnemySeen = function( self, entity, fDistance )
	
		-- Called when the enemy sees a living AI which doesn't belong to his group ID.
		-- In the enemy's properties list, Hostile should be set to true otherwise this function won't be called.
		-- This should really be called OnEnemySeen.
				
	end,
	---------------------------------------------
	OnSeenByEnemy = function( self, entity )
	end,
	---------------------------------------------
	OnFriendSeen = function( self, entity )
		-- called when the enemy sees a friendly target
	end,
	---------------------------------------------
	OnDeadBodySeen = function( self, entity )
		-- called when the enemy a dead body
	end,
	---------------------------------------------
	OnEnemyMemory = function( self, entity )
		-- called when the enemy can no longer see its foe, but remembers where it saw it last
	end,
	---------------------------------------------
	OnEnemyDamage = function ( self, entity, sender)
		-- called when the enemy is damaged
		entity:InsertSubpipe(0,"test_DensityTest");
	end,
	---------------------------------------------
	OnInterestingSoundHeard = function( self, entity )
		-- called when the enemy hears an interesting sound
	end,
	---------------------------------------------
	OnThreateningSoundHeard = function( self, entity )
		-- called when the enemy hears a scary sound
	end,
	---------------------------------------------
	OnReload = function( self, entity )
	end,
	---------------------------------------------
	OnClipNearlyEmpty = function( self, entity )
	end,
	---------------------------------------------
	OnReloadDone = function( self, entity )
	end,
	---------------------------------------------
	OnOutOfAmmo = function (self,entity, sender)
	  entity:Reload();
	end,
	---------------------------------------------
	HANDLE_RELOAD = function(self,entity,sender)
		-- called when the enemy goes into automatic reload after its clip is empty
	end,
	---------------------------------------------
	OnGroupMemberDied = function( self, entity )
		-- called when a member of the group dies
	end,
	---------------------------------------------
	OnGroupMemberDiedNearest = function ( self, entity, sender)
	end,
	---------------------------------------------
	OnNoHidingPlace = function( self, entity, sender )
		-- called when no hiding place can be found with the specified parameters
	end,	
	--------------------------------------------------
	OnNoFormationPoint = function ( self, entity, sender)
		-- called when the enemy found no formation point
	end,
	---------------------------------------------
	OnReceivingDamage = function ( self, entity, sender)
		-- called when the enemy is damaged
	end,
	---------------------------------------------
	OnCoverRequested = function ( self, entity, sender)
		-- called when the enemy is damaged
	end,
	--------------------------------------------------
	OnBulletRain = function ( self, entity, sender, data)
			self:DoPipeSelection(entity);
	end,
	--------------------------------------------------
	OnDeath = function( self,entity )

	end,
	
	SHARED_ENTER_ME_VEHICLE = function( self,entity, sender )
	end,

	SHARED_LEAVE_ME_VEHICLE = function( self,entity, sender )
	end,

	exited_vehicle = function( self,entity, sender )
	end,
	
	exited_vehicle_investigate = function( self,entity, sender )
	end,

	do_exit_vehicle = function( self,entity, sender )
	end,

  OnVehicleDanger = function(self,entity,sender)
	end,

	EXIT_VEHICLE_STAND = function(self,entity,sender)
	end,
	
	
	ORDER_EXIT_VEHICLE = function(self,entity,sender)
	end,

	ORDER_FOLLOW = function(self,entity,sender)
	end,
	
	ORDER_HIDE = function(self,entity,sender)
	end,
	
	ORDER_FIRE = function(self,entity,sender)
	end,

	OnDamage = function(self,entity,sender)
	end,

	OnCloseContact = 	function(self,entity,sender)
	end,

	OnCollision = function(self,entity,sender)
	end,

	OnGrenadeSeen = 	function(self,entity,sender)
	end,
	
	OnSomebodyDied = 	function(self,entity,sender)
	end,
	
	ORDER_HOLD = function ( self, entity, sender, data )
	end,
	
	ORDER_FORM = function ( self, entity, sender)		
	end,
	
	OnSomethingSeen = function( self, entity, fDistance )
	end,
	
	OnClearIgnoreEnemy = function(self,entity,sender)
	end,
	
	ACT_ANIM = function( self, entity, sender, data )			-- \AI\Behaviors\DEFAULT.lua(1098)
	end,

	ACT_DROP_OBJECT = function( self, entity, sender, data )			-- \AI\Behaviors\DEFAULT.lua(1146)
	end,

	ACT_EXECUTE = function( self, entity, sender, data )			-- \AI\Behaviors\DEFAULT.lua(1012)
	end,

	ACT_GOTO = function( self, entity, sender, data )			-- \AI\Behaviors\DEFAULT.lua(1017)
	end,

	ACT_GRAB_OBJECT = function( self, entity, sender, data )			-- \AI\Behaviors\DEFAULT.lua(1138)
	end,

	ACT_LOOKATPOINT = function( self, entity, sender, data )			-- \AI\Behaviors\DEFAULT.lua(1033)
	end,

	ACT_SHOOTAT = function( self, entity, sender, data )			-- \AI\Behaviors\DEFAULT.lua(1044)
	end,

	ACT_SPEED = function( self, entity,sender,data )			-- \AI\Behaviors\DEFAULT.lua(1069)
	end,

	ACT_STANCE = function( self, entity,sender,data )			-- \AI\Behaviors\DEFAULT.lua(1086)
	end,

	ACT_USEOBJECT = function( self, entity, sender, data )			-- \AI\Behaviors\DEFAULT.lua(1166)
	end,

	ACT_WEAPONDRAW = function( self, entity, sender, data )			-- \AI\Behaviors\DEFAULT.lua(1154)
	end,

	ACT_WEAPONHOLSTER = function( self, entity, sender, data )			-- \AI\Behaviors\DEFAULT.lua(1160)
	end,

	AISF_CallForHelp = function ( self, entity, sender)			-- \AI\Behaviors\DEFAULT.lua(278)
	end,

	AISF_GoOn = function (self, entity, sender)			-- \AI\Behaviors\Personalities\GoonCover\GoonCoverIdle.lua(401)
	end,

	APPLY_IMPULSE_TO_ENVIRONMENT = function(self,entity,sender)			-- \AI\Behaviors\DEFAULT.lua(294)
	end,

	ASSAULT_PHASE = function (self, entity, sender)			-- \AI\Behaviors\Personalities\GoonCover\GoonCoverIdle.lua(505)
	end,

	BREAK_TEAM = function ( self, entity, sender)			-- \AI\Behaviors\DEFAULT.lua(945)
	end,

	CANNOT_RESUME_SPECIAL_BEHAVIOUR = function(self,entity,sender)			-- \AI\Behaviors\DEFAULT.lua(263)
	end,

	CHECK_CONVOY = function(self,entity,sender)			-- \AI\Behaviors\DEFAULT.lua(957)
	end,

	CLOSE_IN_PHASE = function (self, entity, sender)			-- \AI\Behaviors\Personalities\GoonCover\GoonCoverIdle.lua(501)
	end,

	CONVERSATION_REQUEST = function (self,entity, sender, data)			-- \AI\Behaviors\DEFAULT.lua(501)
	end,

	COVER_NORMALATTACK = function (self, entity, sender)			-- \AI\Behaviors\Personalities\GoonCover\GoonCoverIdle.lua(393)
	end,

	COVER_RELAX = function (self, entity, sender)			-- \AI\Behaviors\Personalities\GoonCover\GoonCoverIdle.lua(397)
	end,

	DEFAULT_CURRENT_TO_CROUCH = function( self, entity, sender)			-- \AI\Behaviors\DEFAULT.lua(771)
	end,

	DEFAULT_CURRENT_TO_PRONE = function( self, entity, sender)			-- \AI\Behaviors\DEFAULT.lua(775)
	end,

	DEFAULT_CURRENT_TO_STAND = function( self, entity, sender)			-- \AI\Behaviors\DEFAULT.lua(783)
	end,

	DESTROY_THE_BEACON = function ( self, entity, sender)			-- \AI\Behaviors\DEFAULT.lua(129)
	end,

	DO_SOMETHING_IDLE = function( self,entity , sender)			-- \AI\Behaviors\DEFAULT.lua(835)
	end,

	DO_THREATENED_ANIMATION = function(self,entity,sender)			-- \AI\Behaviors\DEFAULT.lua(816)
	end,

	DRAW_GUN = function( self, entity )			-- \AI\Behaviors\Personalities\GoonCover\GoonCoverIdle.lua(171)
	end,

	FLASHBANG_GRENADE_EFFECT = function (self, entity, sender)			-- \AI\Behaviors\DEFAULT.lua(892)
	end,

	FOLLOW_LEADER = function(self,entity,sender,data)			-- \AI\Behaviors\DEFAULT.lua(974)
	end,

	FORMATION_REACHED = function (self, entity, sender)			-- \AI\Behaviors\Personalities\GoonCover\GoonCoverIdle.lua(565)
	end,

	GET_ALERTED = function( self, entity )			-- \AI\Behaviors\Personalities\GoonCover\GoonCoverIdle.lua(159)
	end,
	
	GET_ALERTED_RESPONSE = function( self, entity )			
	end,
	
	GOING_TO_TRIGGER = function (self, entity, sender)			-- \AI\Behaviors\DEFAULT.lua(856)
	end,

	GO_INTO_WAIT_STATE = function ( self, entity, sender)			-- \AI\Behaviors\DEFAULT.lua(217)
	end,

	GO_TO_DESTINATION = function(self, entity, sender, data)			-- \AI\Behaviors\Personalities\GoonCover\GoonCoverIdle.lua(514)
	end,

	GROUP_COVER = function (self, entity, sender)			-- \AI\Behaviors\Personalities\GoonCover\GoonCoverIdle.lua(480)
	end,

	GROUP_MERGE = function (self, entity, sender)			-- \AI\Behaviors\Personalities\GoonCover\GoonCoverIdle.lua(497)
	end,

	GROUP_NEUTRALISED = function (self, entity, sender)			-- \AI\Behaviors\Personalities\GoonCover\GoonCoverIdle.lua(509)
	end,

	HEADS_UP_GUYS = function (self, entity, sender)			-- \AI\Behaviors\Personalities\GoonCover\GoonCoverIdle.lua(412)
	end,

	HIDE_END_EFFECT = function(self,entity,sender)			-- \AI\Behaviors\DEFAULT.lua(370)
	end,

	HIDE_FROM_BEACON = function ( self, entity, sender)			-- \AI\Behaviors\DEFAULT.lua(125)
	end,

	HIDE_GUN = function (self,entity)			-- \AI\Behaviors\DEFAULT.lua(806)
	end,

	HOLSTERITEM_FALSE = function( self, entity, sender )			-- \AI\Behaviors\DEFAULT.lua(1000)
	end,

	HOLSTERITEM_TRUE = function( self, entity, sender )			-- \AI\Behaviors\DEFAULT.lua(996)
	end,

	INCOMING_FIRE = function (self, entity, sender)			-- \AI\Behaviors\Personalities\GoonCover\GoonCoverIdle.lua(432)
	end,

	INVESTIGATE_TARGET = function (self, entity, sender)			-- \AI\Behaviors\Personalities\GoonCover\GoonCoverIdle.lua(406)
	end,

	IN_POSITION = function (self, entity, sender)			-- \AI\Behaviors\Personalities\GoonCover\GoonCoverIdle.lua(484)
	end,

	JOIN_TEAM = function ( self, entity, sender)			-- \AI\Behaviors\DEFAULT.lua(940)
	end,

	JoinGroup = function (self, entity, sender)			-- \AI\Behaviors\DEFAULT.lua(490)
	end,

	LEFT_LEAN_ENTER = function(self,entity,sender)			-- \AI\Behaviors\DEFAULT.lua(383)
	end,

	LIGHTS_OFF  = function(self,entity,sender)			-- \AI\Behaviors\DEFAULT.lua(796)
	end,

	LIGHTS_ON  = function(self,entity,sender)			-- \AI\Behaviors\DEFAULT.lua(800)
	end,

	MAKE_ME_IGNORANT = function ( self, entity, sender)			-- \AI\Behaviors\DEFAULT.lua(153)
	end,

	MAKE_ME_UNIGNORANT = function ( self, entity, sender)			-- \AI\Behaviors\DEFAULT.lua(157)
	end,

	MAKE_STUNNED_ANIMATION = function (self, entity, sender)			-- \AI\Behaviors\DEFAULT.lua(873)
	end,

	OFFER_JOIN_TEAM  = function (self,entity, sender)			-- \AI\Behaviors\DEFAULT.lua(544)
	end,

	ORDER_ENTER_VEHICLE	= function (self, entity, sender,data)			-- \AI\Behaviors\Personalities\GoonCover\GoonCoverIdle.lua(579)
	end,

	ORDER_SEARCH = function( self, entity, sender, data )			-- \AI\Behaviors\DEFAULT.lua(118)
	end,

	OnBackOffFailed = function(self,entity,sender)			-- \AI\Behaviors\Personalities\GoonCover\GoonCoverIdle.lua(153)
	end,

	OnDeathCreateCorpse = function ( self, entity, sender)			-- \AI\Behaviors\DEFAULT.lua(443)
	end,

	OnDeathCreateCorpseDelay = function ( self, entity, sender)			-- \AI\Behaviors\DEFAULT.lua(435)
	end,

	OnFriendInWay = function ( self, entity, sender)			-- \AI\Behaviors\DEFAULT.lua(142)
	end,

	OnLeaderDead = function ( self, entity, sender)			-- \AI\Behaviors\DEFAULT.lua(73)
	end,

	OnNoAmmo = function( self, entity, sender)			-- \AI\Behaviors\DEFAULT.lua(761)
	end,

	OnObjectSeen = function( self, entity, fDistance, signalData )			-- \AI\Behaviors\Personalities\GoonCover\GoonCoverIdle.lua(312)
	end,

	OnRestoreVehicleDanger = function(self, entity)			-- \AI\Behaviors\DEFAULT.lua(302)
	end,

	OnStartPanicking = function( self, entity, sender)			-- \AI\Behaviors\Personalities\GoonCover\GoonCoverIdle.lua(32)
	end,

	OnStopPanicking = function( self, entity, sender)			-- \AI\Behaviors\Personalities\GoonCover\GoonCoverIdle.lua(37)
	end,

	OnTargetDead = function( self, entity )			-- \AI\Behaviors\Personalities\GoonCover\GoonCoverIdle.lua(103)
	end,

	OnUseSmartObject = function ( self, entity, sender, extraData )			-- \AI\Behaviors\DEFAULT.lua(10)
	end,

	PHASE_BLACK_ATTACK = function (self, entity, sender)			-- \AI\Behaviors\Personalities\GoonCover\GoonCoverIdle.lua(493)
	end,

	PHASE_RED_ATTACK = function (self, entity, sender)			-- \AI\Behaviors\Personalities\GoonCover\GoonCoverIdle.lua(489)
	end,

	PLAY_LISTEN_ANIMATION = function (self,entity,sender)			-- \AI\Behaviors\DEFAULT.lua(968)
	end,

	PLAY_TALK_ANIMATION = function (self,entity,sender)			-- \AI\Behaviors\DEFAULT.lua(963)
	end,

	PROVIDE_COVERING_FIRE = function ( self, entity, sender)			-- \AI\Behaviors\DEFAULT.lua(185)
	end,

	PlayRollLeftAnim = function (self, entity, sender)			-- \AI\Behaviors\DEFAULT.lua(726)
	end,

	PlayRollRightAnim = function (self, entity, sender)			-- \AI\Behaviors\DEFAULT.lua(730)
	end,

	RESUME_SPECIAL_BEHAVIOUR = function(self,entity,sender)			-- \AI\Behaviors\DEFAULT.lua(269)
	end,

	RETREAT_NOW = function ( self, entity, sender)			-- \AI\Behaviors\DEFAULT.lua(162)
	end,

	RETREAT_NOW_PHASE2 = function ( self, entity, sender)			-- \AI\Behaviors\DEFAULT.lua(173)
	end,

	RETURN_TO_FIRST = function( self, entity, sender )			-- \AI\Behaviors\DEFAULT.lua(402)
	end,

	RIGHT_LEAN_ENTER = function(self,entity,sender)			-- \AI\Behaviors\DEFAULT.lua(387)
	end,

	RUSH_TARGET = function ( self, entity, sender)			-- \AI\Behaviors\DEFAULT.lua(191)
	end,

	SEARCH_AROUND = function(self,entity,sender)			-- \AI\Behaviors\Personalities\GoonCover\GoonCoverIdle.lua(572)
	end,

	SELECT_BLACK = function (self, entity, sender)			-- \AI\Behaviors\DEFAULT.lua(563)
	end,

	SELECT_RED = function (self, entity, sender)			-- \AI\Behaviors\DEFAULT.lua(553)
	end,

	SET_REFPOINT_BEHIND_ME = function(self,entity,sender)			-- \AI\Behaviors\DEFAULT.lua(950)
	end,

	SHARED_BLINDED = function (self, entity, sender)			-- \AI\Behaviors\DEFAULT.lua(901)
	end,

	SHARED_DROP = function( self, entity, sender, data )			-- \AI\Behaviors\DEFAULT.lua(991)
	end,

	SHARED_FIND_USE_MOUNTED_WEAPON = function( self, entity )			-- \AI\Behaviors\DEFAULT.lua(77)
	end,

	SHARED_GRANATE_THROW_ANIM = function(self,entity,sender)			-- \AI\Behaviors\DEFAULT.lua(694)
	end,

	SHARED_GRENADE_THROW_OR_NOT = function(self,entity,sender)			-- \AI\Behaviors\DEFAULT.lua(689)
	end,

	SHARED_PICK_UP = function( self, entity, sender, data )			-- \AI\Behaviors\DEFAULT.lua(984)
	end,

	SHARED_PLAYLEFTROLL = function(self,entity,sender)			-- \AI\Behaviors\DEFAULT.lua(700)
	end,

	SHARED_PLAYRIGHTROLL = function(self,entity,sender)			-- \AI\Behaviors\DEFAULT.lua(705)
	end,

	SHARED_PLAY_CURIOUS_ANIMATION = function(self,entity,sender)			-- \AI\Behaviors\DEFAULT.lua(828)
	end,

	SHARED_PLAY_DAMAGEAREA_ANIM = function (self, entity, sender)			-- \AI\Behaviors\DEFAULT.lua(920)
	end,

	SHARED_PLAY_GETDOWN_ANIM = function (self, entity, sender)			-- \AI\Behaviors\DEFAULT.lua(910)
	end,

	SHARED_PLAY_GETUP_ANIM = function (self, entity, sender)			-- \AI\Behaviors\DEFAULT.lua(915)
	end,

	SHARED_RELOAD = function (self,entity, sender)			-- \AI\Behaviors\DEFAULT.lua(575)
	end,

	SHARED_STOP_ANIMATION = function( self, entity, sender )			-- \AI\Behaviors\DEFAULT.lua(980)
	end,

	SHARED_TAKEOUTPIN = function(self,entity,sender)			-- \AI\Behaviors\DEFAULT.lua(710)
	end,

	SHARED_THROW_GRENADE = function(self, entity, sender)			-- \AI\Behaviors\DEFAULT.lua(602)
	end,

	SHARED_UNBLINDED = function (self, entity, sender)			-- \AI\Behaviors\DEFAULT.lua(905)
	end,

	SHARED_USE_THIS_MOUNTED_WEAPON = function( self, entity )			-- \AI\Behaviors\DEFAULT.lua(108)
	end,

	SINGLE_GO = function (self, entity, sender)			-- \AI\Behaviors\Personalities\GoonCover\GoonCoverIdle.lua(476)
	end,

	SMART_THROW_GRENADE = function( self, entity, sender )			-- \AI\Behaviors\DEFAULT.lua(622)
	end,

	SPECIAL_FOLLOW = function (self, entity, sender)			-- \AI\Behaviors\DEFAULT.lua(221)
	end,

	SPECIAL_GODUMB = function (self, entity, sender)			-- \AI\Behaviors\DEFAULT.lua(228)
	end,

	SPECIAL_HOLD = function (self, entity, sender)			-- \AI\Behaviors\DEFAULT.lua(250)
	end,

	SPECIAL_LEAD = function (self, entity, sender)			-- \AI\Behaviors\DEFAULT.lua(241)
	end,

	SPECIAL_STOPALL = function (self, entity, sender)			-- \AI\Behaviors\DEFAULT.lua(234)
	end,

	START_CONVERSATION = function (self,entity, sender)			-- \AI\Behaviors\DEFAULT.lua(525)
	end,

	START_SWIMMING = function ( self, entity, sender)			-- \AI\Behaviors\DEFAULT.lua(202)
	end,

	STOP_RUSH = function ( self, entity, sender)			-- \AI\Behaviors\DEFAULT.lua(197)
	end,

	SWITCH_TO_MORTARGUY = function(self,entity,sender)			-- \AI\Behaviors\DEFAULT.lua(392)
	end,

	SignalToNearestDirectional = function ( self, entity, signal )			-- \AI\Behaviors\DEFAULT.lua(18)
	end,

	SignalToNearest_InPosition = function ( self, entity, sender )			-- \AI\Behaviors\DEFAULT.lua(42)
	end,

	Smoking = function(self,entity,sender)			-- \AI\Behaviors\DEFAULT.lua(374)
	end,

	TARGET_DISTANCE_REACHED = function(self,entity,sender)			-- \AI\Behaviors\Personalities\GoonCover\GoonCoverIdle.lua(551)
	end,

	THREAT_TOO_CLOSE = function (self, entity, sender)			-- \AI\Behaviors\Personalities\GoonCover\GoonCoverIdle.lua(461)
	end,

	THROW_FLARE = function (self, entity, sender)			-- \AI\Behaviors\DEFAULT.lua(865)
	end,

	UNCONDITIONAL_JOIN = function (self, entity, sender)			-- \AI\Behaviors\DEFAULT.lua(495)
	end,

	UNHIDE_GUN = function (self,entity)			-- \AI\Behaviors\DEFAULT.lua(810)
	end,

	YOU_ARE_BEING_WATCHED = function(self,entity,sender)			-- \AI\Behaviors\DEFAULT.lua(378)
	end,

	death_recognition = function (self, entity, sender)			-- \AI\Behaviors\DEFAULT.lua(715)
	end,

	select_gunner_pipe = function ( self, entity, sender)			-- \AI\Behaviors\DEFAULT.lua(934)
	end,
	
	taking_fire = function ( self, entity, sender)
	end,
	
	bulletrain = function ( self, entity, sender)
		self:DoPipeSelection(entity);
	end,
	
	OnNearMiss = function ( self, entity, sender)
	end,
	
	HIDE_AVAILABLE = function ( self, entity, sender)
	end,
	
	first_contact_response = function ( self, entity, sender)
	end,
	
	SUPPRESSED = function ( self, entity, sender)
	end,		
	---------------------------------------------
	GA_APPROACH = function( self, entity )
	end,
	
	---------------------------------------------
	PROD = function ( self, entity )
	end,
	
	---------------------------------------------
	CHANGED_TACTIC = function ( self, entity )
	end,		
	---------------------------------------------
	-- Signals to display progress through test_all_run_modes pipe
	---------------------------------------------
	RUN_NEG_0 = function ( self, entity )
	end,		
	RUN_NEG_1 = function ( self, entity )
	end,		
	RUN_NEG_2 = function ( self, entity )
	end,		
	RUN_NEG_3 = function ( self, entity )
	end,		
	RUN_NEG_4 = function ( self, entity )
	end,		
	RUN_NEG_5 = function ( self, entity )
	end,		
	
	
	RS_SHORT_DIST_TO_GIRL = function ( self, entity )
	end,

	
	-------------------------------------------------------
	-- TestIdle approach signals
	-------------------------------------------------------
	
	
	OnApproachedToCover = function ( self, entity )
	end,
	
	OnPassedCover = function ( self, entity )
		--entity:InsertSubpipe(0,"just_shoot_one");
	end,
	
	OnApproachedToOpen = function ( self, entity )
	end,
	
	OnStuck = function ( self, entity )
		entity:SelectPipe(0,"do_nothing");
	end,
	
	-------------------------------------------------------
	-- Special signals, for causing actions to be performed
	-------------------------------------------------------
	
	test_fall = function (self,entity)
	 entity.actor:Fall();
	end,
	test_stand = function (self,entity)
	 entity.actor:StandUp();
	end,
	test_falldeath = function (self,entity)
	 entity.actor:GoLimp();
	end,
	
	test_lookat_entity = function (self, entity)
		entity:SelectPipe(0,"ga_lookat_entity", "Goon15");
	end,
	
	test_lookat_ref = function (self, entity)
		local myPos = System.GetEntityByName("Goon15"):GetPos();
		local pos = { x=myPos.x, y=myPos.y, z=myPos.z };
		AI.SetRefPointPosition(entity.id,pos);
		pos = AI.GetRefPointPosition(entity.id);
		LogTable(pos);
		--entity:InsertSubpipe(0,"ga_lookat_entity","refpoint");
		entity:InsertSubpipe(0,"ga_lookat_refpoint");
	end,

	test_lookat_sequence = function (self, entity)
		local myPos = entity:GetPos();
		local pos = { x=myPos.x, y=myPos.y - 25, z=myPos.z };
		AI.SetRefPointPosition(entity.id,pos);
		entity:InsertSubpipe(0,"test_lookat_sequence","Goon15");
	end,



	test_stances_slow = function (self, entity)
		entity:SelectPipe(0,"test_stances");	
		entity:InsertSubpipe(0,"go_somewhere");
		entity:InsertSubpipe(0,"go_runmode_slow");
	end,


	test_stances_walk = function (self, entity)
		entity:SelectPipe(0,"test_stances");	
		entity:InsertSubpipe(0,"go_somewhere");
		entity:InsertSubpipe(0,"go_runmode_walk");
	end,
	
	test_stances_run = function (self, entity)
		entity:SelectPipe(0,"test_stances");	
		entity:InsertSubpipe(0,"go_somewhere");
		entity:InsertSubpipe(0,"go_runmode_run");
	end,
	
	test_stances_sprint = function (self, entity)
		entity:SelectPipe(0,"test_stances");	
		entity:InsertSubpipe(0,"go_somewhere");
		entity:InsertSubpipe(0,"go_runmode_sprint");
	end,
	
	go_stance_prone = function (self, entity)
		entity:InsertSubpipe(0,"go_stance_prone");
	end,	
	
	do_nothing = function(self, entity)
		entity:SelectPipe(0,"do_nothing");
		entity:InsertSubpipe(0,"clear_goalpipes");
	end,
	
	test_look = function(self, entity)
		entity:InsertSubpipe(0,"test_look");
	end,	
})


-------------------------------------------------------
-- Special signals, for causing actions to be performed
-------------------------------------------------------
local TestSignals = {
	"test_hide_nearest",
	"test_hide_nearest_min",
	"test_hide_nearest_crouch",
	"test_approach_direct",
	"test_approach_staged",
	"test_run_modes",
	"test_all_run_modes",
	"test_stances",
	"test_cover_under_fire",
	"test_squaredance",
	"test_dally",
	"test_dally_neg",
	"test_dally_looking_forward",
	"test_backoff",
	"test_backoff2",
	"test_move",
	"test_hide_strafe",
	"test_near_cover",
	"ignoreall",
	"run",
	"test_tactical",
	"test_DirectnessTest",
	"test_RefPointHideTest",
	"test_DensityTest",
	"test_lean",
	"test_stick",
}

for i,v in pairs(TestSignals) do
	if (not Behavior[v]) then
		Behavior[v] = function (self, entity)
			entity:SelectPipe(0,v);	
		end
	end
end
