NavVolumeSeed = {
  type = "NavVolumeSeed",

	Editor={
		--Model="Editor/Objects/T.cgf",
		Icon="TagPoint.bmp",
	},
}

-------------------------------------------------------
function NavVolumeSeed:OnInit()
	CryAction.RegisterWithAI(self.id, AIOBJECT_WAYPOINT);
end