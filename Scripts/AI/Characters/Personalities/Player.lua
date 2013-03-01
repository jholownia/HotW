-- AICharacter: Player INTERNAL



-- PLAYER CHARACTER SCRIPT

AICharacter.Player = {

	Class = UNIT_CLASS_LEADER,
	
	InitItems = function(self,entity)
--		entity.AI.WeaponAccessoryTable = {};
--		entity.AI.WeaponAccessoryTable["SCARIncendiaryAmmo"] = 0;
--		entity.AI.WeaponAccessoryTable["SCARNormalAmmo"] = 2;
--		entity.AI.WeaponAccessoryTable["Silencer"] = 0;
		entity.AI.NanoSuitCloak = false;
		entity.AI.NanoSuitMode = 0;
		--entity.AI.WeaponAccessoryTable["Flashlight"] = 0;
	end,
	
	Constructor = function(self,entity)
		self:InitItems(entity);
		AI.ChangeParameter( entity.id, AIPARAM_COMBATCLASS, AICombatClasses.Infantry );
	end,
	
	AnyBehavior = {
	
		-----------------------------------
		-- Vehicles related - player should not be AI-enabling vehicle
		entered_vehicle = "",
		entered_vehicle_gunner = "",
	},
	
	PlayerIdle = {
		-----------------------------------
		-- Vehicles related - player should not be AI-enabling vehicle
		entered_vehicle = "",
		entered_vehicle_gunner = "",
		START_ATTACK = "PlayerAttack",
	},

	PlayerAttack = {
		entered_vehicle = "",
		entered_vehicle_gunner = "",
		OnLeaderActionCompleted = "PlayerIdle",
		OnLeaderActionFailed = "PlayerIdle",
	},
}
