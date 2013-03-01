TagPoint = {
  type = "TagPoint",

	Editor = {
		Icon = "TagPoint.bmp",
	},
}

-------------------------------------------------------
function TagPoint:OnInit()
	CryAction.RegisterWithAI(self.id, AIOBJECT_WAYPOINT);
end
