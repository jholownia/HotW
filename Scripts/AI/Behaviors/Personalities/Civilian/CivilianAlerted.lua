local Behavior = CreateAIBehavior("CivilianAlerted", "CivilianIdle",
{
	Destructor = function(self, entity)
		AI.RemovePersonallyHostile(entity.id, entity.AI.hostileId);
	end,

	OnEnemySeen = function(self, entity)
		entity:SelectPipe(0, "Civilian_HideFromEnemy");
	end,

	OnNoTarget = function(self, entity)
		AI.SetBehaviorVariable(entity.id, "alerted", false);
	end,
});
