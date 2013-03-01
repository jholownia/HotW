CharacterAttachHelper = {
	Editor={
		Icon="Magnet.bmp",
	},
	Properties =
	{
		BoneName = "Bip01 Head",
		bUsePlayer = 0,
	},
}

--------------------------------------------------------------------------
function CharacterAttachHelper:OnInit()
  -- Make sure the entity ignores transformation of the parent.
	self:EnableInheritXForm(0);
	self:MakeAttachment();
end

--------------------------------------------------------------------------
function CharacterAttachHelper:OnStartGame()
  self:MakeAttachment();
end

--------------------------------------------------------------------------
function CharacterAttachHelper:OnShutDown()
	local parent = self:GetParent();
	if (self.Properties.bUsePlayer ~= 0) then
		parent = g_localActor;
	end
	if (parent) then
	  -- Attach this entity to the parent.
		parent:DestroyAttachment( 0,self:GetName() );
	end
end

--------------------------------------------------------------------------
function CharacterAttachHelper:OnPropertyChange()
	local parent = self:GetParent();
	if (self.Properties.bUsePlayer ~= 0) then
		parent = g_localActor;
	end
	if (parent) then
		parent:DestroyAttachment( 0,self:GetName() );
		-- Attach this entity to the parent.
		self:MakeAttachment();
	end
end

--------------------------------------------------------------------------
function CharacterAttachHelper:MakeAttachment()
	local parent = self:GetParent();
	if (self.Properties.bUsePlayer ~= 0) then
		parent = g_localActor;
	end
	if (parent) then
		parent:DestroyAttachment( 0,self:GetName() );
		parent:CreateBoneAttachment( 0,self.Properties.BoneName,self:GetName() );
		-- Attach this entity to the parent.
		parent:SetAttachmentObject( 0,self:GetName(),self.id,-1,0 );
	end
end
