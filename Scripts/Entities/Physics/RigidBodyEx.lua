Script.ReloadScript( "Scripts/Entities/Physics/BasicEntity.lua" );

-- Basic entity
RigidBodyEx = {
	Properties = {
		bSerialize = 0, --by default rigid bodies are not being serialized (save/load)	
		bDamagesPlayerOnCollisionSP = 0,
	
		Physics = {
			bRigidBodyActive = 1,
			bActivateOnDamage = 0,
			bResting = 1, -- If rigid body is originally in resting state.
			bCanBreakOthers = 0,	
			
			Simulation =
			{
				max_time_step = 0.02,
				sleep_speed = 0.04,
				damping = 0,
				bFixedDamping = 0,
				bUseSimpleSolver = 0,
			},
			Buoyancy=
			{
				water_density = 1000,
				water_damping = 0,
				water_resistance = 1000,	
			},
			CGFPropsOverride = 
			{
				Joint = 
				{
					limit = "",
					twist = "",
					bend = "",
					push = "",
					pull = "",
					shift = "",
				},
				Constraint = 
				{
					constraint_limit = "",
					constraint_minang = "",
					constraint_maxang = "",
					constraint_damping = "",
					constraint_collides = "",
				},
				Deformable = 
				{
					stiffness = "",
					thickness = "",
					max_stretch = "",
					max_impulse = "",
					skin_dist = "",
					hardness = "",
					explosion_scale = "",
				},
				player_can_break = "",
			},
			MP =
			{
				bClientOnly = 0,
			},
		},
	},
	
			Editor={
		Icon = "physicsobject.bmp",
		IconOnTop=1,
	},
	States = {"Default","Activated"},
	bRigidBodyActive = 1,
}

local Physics_DX9MP_Simple = {
	bRigidBodyActive = 0,
	bActivateOnDamage = 0,
	bResting = 1, -- If rigid body is originally in resting state.
	Simulation =
	{
		max_time_step = 0.02,
		sleep_speed = 0.04,
		damping = 0,
		bFixedDamping = 0,
		bUseSimpleSolver = 0,
	},
	Buoyancy=
	{
		water_density = 1000,
		water_damping = 0,
		water_resistance = 1000,	
	},
	
}

MakeDerivedEntity( RigidBodyEx,BasicEntity )

-------------------------------------------------------
function RigidBodyEx:OnLoad(table)  
  self.bRigidBodyActive = table.bRigidBodyActive;
end

-------------------------------------------------------
function RigidBodyEx:OnSave(table)  
	table.bRigidBodyActive = self.bRigidBodyActive
end

------------------------------------------------------------------------------------------------------
function RigidBodyEx:OnSpawn()
	if (self.Properties.Physics.bRigidBodyActive == 1) then
		self.bRigidBodyActive = 1;
	end
	self:SetFromProperties();
	self:SetupHealthProperties();

	if (self.Properties.Physics.MP.bClientOnly == 1) then
		self:SetFlags(ENTITY_FLAG_CLIENT_ONLY, 0);
	end
	
end
------------------------------------------------------------------------------------------------------
function RigidBodyEx:SetFromProperties()
	local Properties = self.Properties;

	if (Properties.object_Model == "") then
		do return end;
	end
	
	self:LoadObject(0,Properties.object_Model);
	self:CharacterUpdateOnRender(0,1); -- If it is a character force it to update on render.
		
	-- Enabling drawing of the slot.
	self:DrawSlot(0,1);
	
	self.bRigidBodyActive = Properties.Physics.bRigidBodyActive;
	if (Properties.Physics.bPhysicalize == 1) then
		self:PhysicalizeThis();
	end
	self:GotoState("Default");
	
	-- Mark AI hideable flag.
	if (self.Properties.bAutoGenAIHidePts == 1) then
		self:SetFlags(ENTITY_FLAG_AI_HIDEABLE, 0); -- set
	else
		self:SetFlags(ENTITY_FLAG_AI_HIDEABLE, 2); -- remove
	end
	
	if (self.Properties.bCanTriggerAreas == 1) then
		self:SetFlags(ENTITY_FLAG_TRIGGER_AREAS, 0); -- set
	else
		self:SetFlags(ENTITY_FLAG_TRIGGER_AREAS, 2); -- remove
	end
	
	
end

------------------------------------------------------------------------------------------------------
function RigidBodyEx:PhysicalizeThis()
	-- Init physics.
	local physics = self.Properties.Physics;
	if (CryAction.IsImmersivenessEnabled() == 0) then
		physics = Physics_DX9MP_Simple;
	end
	EntityCommon.PhysicalizeRigid( self,0,physics,self.bRigidBodyActive );
end

------------------------------------------------------------------------------------------------------
-- OnPropertyChange called only by the editor.
------------------------------------------------------------------------------------------------------
function RigidBodyEx:OnPropertyChange()
	self:SetFromProperties();
end

------------------------------------------------------------------------------------------------------
-- OnReset called only by the editor.
------------------------------------------------------------------------------------------------------
function RigidBodyEx:OnReset()
	self:ResetOnUsed()
	
	local PhysProps = self.Properties.Physics;
	if (PhysProps.bPhysicalize == 1) then
		self:GotoState("Default");
--		if (self.bRigidBodyActive ~= PhysProps.bRigidBodyActive) then
--			self.bRigidBodyActive = PhysProps.bRigidBodyActive;
--			self:PhysicalizeThis();
--		end
--		if (PhysProps.bRigidBody == 1) then
--			self:AwakePhysics(1-PhysProps.bResting);
--			self.bRigidBodyActive = PhysProps.bRigidBodyActive;
--		end		
	end
	
	self:SetupHealthProperties();

end

-- Called by gamerules --- resets entity if initial transform is available -------------------------
function RigidBodyEx:Event_Reset()
	self:OnReset();
	BroadcastEvent(self, "Reset");
	
	if (self.InitialPosition) then
		self:SetPos(self.InitialPosition);
	end

	if (self.InitialAngles) then
		self:SetWorldAngles(self.InitialAngles);
	end

	if (self.InitialScale) then
		self:SetScale(self.InitialScale);
	end
end

-- Called by gamerules ------------------------------------------------------------------------------
-- set initial transform so you can use Event_Reset to return objects to their positions ------------
------------------------------------------------------------------------------------------------------
function RigidBodyEx:StoreInitialTransform()
	self.InitialScale = self:GetScale();
	self.InitialAngles = self:GetWorldAngles();
	self.InitialPosition = self:GetPos();
end

------------------------------------------------------------------------------------------------------
function RigidBodyEx:GetFrozenSlot()
	if (self.frozenModelSlot) then
		return self.frozenModelSlot;
	end
	return -1;
end

------------------------------------------------------------------------------------------------------
function RigidBodyEx:Event_Remove()
--	self:Hide(1);
	self:DrawSlot(0,0);
	self:DestroyPhysics();
	self:ActivateOutput( "Remove", true );
end


------------------------------------------------------------------------------------------------------
function RigidBodyEx:Event_Hide()
	self:Hide(1);
	self:ActivateOutput( "Hide", true );
	--self:DrawObject(0,0);
	--self:DestroyPhysics();
end

------------------------------------------------------------------------------------------------------
function RigidBodyEx:Event_UnHide()
	self:Hide(0);
	self:ActivateOutput( "UnHide", true );
	--self:DrawObject(0,1);
	--self:SetPhysicsProperties( 1,self.bRigidBodyActive );
end

------------------------------------------------------------------------------------------------------
function RigidBodyEx:Event_Ragdollize()  
	self:RagDollize(0);
	self:ActivateOutput( "Ragdollized", true );
end

------------------------------------------------------------------------------------------------------
function RigidBodyEx.Client:OnPhysicsBreak( vPos,nPartId,nOtherPartId )
	self:ActivateOutput("Break",nPartId+1 );
end

------------------------------------------------------------------------------------------------------
function RigidBodyEx:OnDamage( hit )

	if (self:IsARigidBody() == 1) then
				
		if (self.Properties.Physics.bActivateOnDamage == 1) then
      if (hit.explosion and self:GetState()~="Activated") then
        BroadcastEvent(self, "Activate");
        self:GotoState("AcTivated");
      end
		end
	end

	if( hit.ipart and hit.ipart>=0 ) then
		self:AddImpulse( hit.ipart, hit.pos, hit.dir, hit.impact_force_mul );
	end
end



------------------------------------------------------------------------------------------------------
-- Input events
------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------
function RigidBodyEx:Event_Activate(sender)	
  self:GotoState("Activated");
end

------------------------------------------------------------------------------------------------------
-- Events to switch material Applied to object.
------------------------------------------------------------------------------------------------------
function RigidBodyEx:CommonSwitchToMaterial( numStr )
	if (not self.sOriginalMaterial) then
		self.sOriginalMaterial = self:GetMaterial();
	end
	
	if (self.sOriginalMaterial) then
		--System.Log( "Material: "..self.sOriginalMaterial..numStr );
		self:SetMaterial( self.sOriginalMaterial..numStr );
	end
end

------------------------------------------------------------------------------------------------------
function RigidBodyEx:Event_SwitchToMaterialOriginal(sender)
	self:CommonSwitchToMaterial( "" );
end

------------------------------------------------------------------------------------------------------
function RigidBodyEx:Event_SwitchToMaterial1(sender)
	self:CommonSwitchToMaterial( "1" );
end
------------------------------------------------------------------------------------------------------
function RigidBodyEx:Event_SwitchToMaterial2(sender)
	self:CommonSwitchToMaterial( "2" );
end

------------------------------------------------------------------------------------------------------
-- Defaul state.
------------------------------------------------------------------------------------------------------
RigidBodyEx.Server.Default = 
{
  OnBeginState = function(self)
    if (self.Properties.Physics.bRigidBody==1) then
      if (self.bRigidBodyActive~=self.Properties.Physics.bRigidBodyActive) then
				self.bRigidBodyActive = self.Properties.Physics.bRigidBodyActive;
				self:PhysicalizeThis();
      else
			  self:AwakePhysics(1-self.Properties.Physics.bResting);
		  end  
		end
	end,
	OnDamage = RigidBodyEx.OnDamage,
	OnPhysicsBreak = RigidBodyEx.OnPhysicsBreak,
}

------------------------------------------------------------------------------------------------------
-- Activated state.
------------------------------------------------------------------------------------------------------
RigidBodyEx.Server.Activated =
{
	OnBeginState = function(self)
	  if (self.Properties.Physics.bRigidBody==1 and self.bRigidBodyActive==0) then
      self.bRigidBodyActive = 1;
      self:PhysicalizeThis();
		  self:AwakePhysics(1);
	  end
	end,
	OnDamage = RigidBodyEx.OnDamage,
	OnPhysicsBreak = RigidBodyEx.OnPhysicsBreak,
}

RigidBodyEx.FlowEvents =
{
	Inputs =
	{
		Reset = { RigidBodyEx.Event_Reset, "bool" },
		Used = { RigidBodyEx.Event_Used, "bool" },
		EnableUsable = { RigidBodyEx.Event_EnableUsable, "bool" },
		DisableUsable = { RigidBodyEx.Event_DisableUsable, "bool" },
		Activate = { RigidBodyEx.Event_Activate, "bool" },
		Hide = { RigidBodyEx.Event_Hide, "bool" },
		UnHide = { RigidBodyEx.Event_UnHide, "bool" },
		Remove = { RigidBodyEx.Event_Remove, "bool" },
		Ragdollize = { RigidBodyEx.Event_Ragdollize, "bool" },		
		SwitchToMaterial1 = { RigidBodyEx.Event_SwitchToMaterial1, "bool" },
		SwitchToMaterial2 = { RigidBodyEx.Event_SwitchToMaterial2, "bool" },
		SwitchToMaterialOriginal = { RigidBodyEx.Event_SwitchToMaterialOriginal, "bool" },
		
		ResetHealth = { RigidBodyEx.Event_ResetHealth, "any" },
		MakeVulnerable = { RigidBodyEx.Event_MakeVulnerable, "any" },
		MakeInvulnerable = { RigidBodyEx.Event_MakeInvulnerable, "any" },
	},
	Outputs =
	{
		Reset = "bool",
		Used = "bool",
		EnableUsable = "bool",
		DisableUsable = "bool",
		Activate = "bool",
		Hide = "bool",
		UnHide = "bool",
		Remove = "bool",
		Ragdollized = "bool",		
		Break = "int",
		
		Dead = "bool",
		Hit = "bool",
		Health = "float",
	},
}
