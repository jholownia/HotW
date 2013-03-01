local Behavior = CreateAIBehavior("CivilianIdle",
{
	OnBulletRain = function(self, entity, sender, data)
		AI.SetBehaviorVariable(entity.id, "alerted", true);

		entity.AI.hostileId = data.id;
		AI.AddPersonallyHostile(entity.id, entity.AI.hostileId);

		entity:SelectPipe(0, "Civilian_HideFromEnemy");
	end,

	OnTPSDestReached = function(self, entity)
		entity:SelectPipe(0, "_first_");
	end,
});
