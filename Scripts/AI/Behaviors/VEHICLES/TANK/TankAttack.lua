local Behavior = CreateAIBehavior("TankAttack",
{
	Alertness = 2,
	
	Constructor = function(self , entity )

		AI.LogComment(entity:GetName().." TankAttack:Constructor() selected the action for the frist encount ");

		-- currently never come back to tankAttak

		AI.CreateGoalPipe("tank_attack_start");
		AI.PushGoal("tank_attack_start","signal",0,1,"TO_TANK_ALERT",SIGNALFILTER_ANYONEINCOMM);
		AI.PushGoal("tank_attack_start","timeout",1,0.5);
		AI.PushGoal("tank_attack_start","signal",0,1,"TO_TANK_MOVE",SIGNALFILTER_SENDER);
		entity:SelectPipe(0,"tank_attack_start");

	end,

	---------------------------------------------
	OnGroupMemberDied = function( self,entity,sender )
	end,	
	--------------------------------------------
	OnEnemySeen = function( self, entity, fDistance )
	end,
	---------------------------------------------
	OnEnemyDamage = function ( self, entity, sender, data )
	end,
	--------------------------------------------
	OnSomethingSeen = function( self, entity )
	end,
	--------------------------------------------
	OnEnemyMemory = function( self, entity, fDistance )
	end,
	---------------------------------------------
	OnTargetTooClose = function( self, entity, sender,data )
	end,

	---------------------------------------------
	-- CUSTOM
	---------------------------------------------
	--------------------------------------------------------------------------
	TANK_PROTECT_ME = function( self, entity, sender )

		if ( AI.GetSpeciesOf(entity.id) == AI.GetSpeciesOf(sender.id) ) then

			entity.AI.protect = sender.id;

			if ( entity.id == sender.id ) then
				if (entity.AI.mindType == 3 ) then
					entity.AI.mindType = 2;
				end
			else
				if (entity.AI.mindType == 2 ) then
					entity.AI.mindType = 3;
				end
			end

		end

	end,
})