-- FormationManager: Defines all the formations descriptors Basic Formation creation 
--                  (Only the first 32 formations are used by the flownode AI:AIFormation)
-- Created by Luciano Morpurgo - 2005
-- refactored by Sascha Hoba   - 2010

FormationManager = {

}

function FormationManager:OnInit()

	local nForm = 0;
	
	--Leader-
	---------
	----1----
	----2----
	----3----
	---------
	AI.CreateFormation("line_column_of_3");
	--Parameters: 1) name of the formation this formation point belongs to
	--            2) sight (rotation around z-axis)
	--            3) follow distance
	--            4) follow offset (+X (left) / -X (right))
	--            5) [optional] unit class (default: UNIT_CLASS_UNDEFINED) - NOT ACTUALLY USED IN THE CODE
	--               (UNIT_CLASS_UNDEFINED, UNIT_CLASS_INFANTRY, UNIT_CLASS_ENGINEER, UNIT_CLASS_MEDIC, UNIT_CLASS_LEADER, UNIT_CLASS_SCOUT,UNIT_CLASS_CIVILIAN))
	AI.AddFormationPoint("line_column_of_3", -45, 6, 0);
	AI.AddFormationPoint("line_column_of_3", 45, 9, 0);
	AI.AddFormationPoint("line_column_of_3", 0, 12, 0);
	nForm = nForm + 1;
	
	---Leader--
	-----------
	-----1-----
	-----2-----
	-----3-----
	-----4-----
	-----5-----
	-----------
	AI.CreateFormation("line_column_of_5");
	AI.AddFormationPoint("line_column_of_5", -45, 6, 0);
	AI.AddFormationPoint("line_column_of_5", 45, 9, 0);
	AI.AddFormationPoint("line_column_of_5", -45, 12, 0);
	AI.AddFormationPoint("line_column_of_5", 45, 15, 0);
	AI.AddFormationPoint("line_column_of_5", 0, 18, 0);
	nForm = nForm + 1;
	
	-----Leader----
	---------------
	---1---2---3---
	---------------
	AI.CreateFormation("line_row_of_3");
	AI.AddFormationPoint("line_row_of_3", 45, 6, 3);
	AI.AddFormationPoint("line_row_of_3", 0, 6, 0);
	AI.AddFormationPoint("line_row_of_3", -45, 6, -3);
	nForm = nForm + 1;
	
	---------Leader--------
	-----------------------
	---1---2---3---4---5---
	-----------------------
	AI.CreateFormation("line_row_of_5");
	AI.AddFormationPoint("line_row_of_5", 45, 6, 6);
	AI.AddFormationPoint("line_row_of_5", 0, 6, 3);
	AI.AddFormationPoint("line_row_of_5", 0, 6, 0);
	AI.AddFormationPoint("line_row_of_5", 0, 6, -3);
	AI.AddFormationPoint("line_row_of_5", -45, 6, -6);
	nForm = nForm + 1;
	
	------Leader-----
	-----------------
	--------1--------
	-----------------
	---2---------3---
	-----------------
	AI.CreateFormation("triangle_of_3");
	AI.AddFormationPoint("triangle_of_3", 0, 6, 0);
	AI.AddFormationPoint("triangle_of_3", 45, 12, 6);
	AI.AddFormationPoint("triangle_of_3", -45, 12, -6);
	nForm = nForm + 1;
	
	------Leader-----
	-----------------
	---1---------2---
	-----------------
	---3---------4---
	-----------------
	AI.CreateFormation("square_of_4");
	AI.AddFormationPoint("square_of_4", 45, 6, 6);
	AI.AddFormationPoint("square_of_4", -45, 6, -6);
	AI.AddFormationPoint("square_of_4", 45, 12, 6);
	AI.AddFormationPoint("square_of_4", -45, 12, -6);
	nForm = nForm + 1;
		
	Log("[AI] %d Formations loaded...", nForm);
end