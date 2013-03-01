local Behavior = CreateAIBehavior("APCIdle", "TankIdle",	
{
	Constructor = function( self , entity )
		self.parent:Constructor( entity );
		AI.ChangeParameter(entity.id,AIPARAM_COMBATCLASS,AICombatClasses.APC);		
		
		entity.AI.isAPC = true; -- temporary
	end,
})