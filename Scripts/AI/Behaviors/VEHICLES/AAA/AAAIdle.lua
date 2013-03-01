local Behavior = CreateAIBehavior("AAAIdle", "TankIdle",
{
	Constructor = function( self , entity )		
		self.parent:Constructor( entity );
		AI.ChangeParameter(entity.id,AIPARAM_COMBATCLASS,AICombatClasses.AAA);		
		
		entity.AI.isAAA = true; -- temporary
	end,
})