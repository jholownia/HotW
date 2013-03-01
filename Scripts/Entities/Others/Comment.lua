----------------------------------------------------------------------------------------------------
--  Crytek Source File.
--  Copyright (C), Crytek Studios, 2001-2004.
----------------------------------------------------------------------------------------------------
--  $Id$
--  $DateTime$
--  Description: Item System Main File
--
----------------------------------------------------------------------------------------------------
--  History:
--  - 23:11:2005   12:00 : Created by Marco Koegler
--
----------------------------------------------------------------------------------------------------
Script.ReloadScript("scripts/entities/items/itemsystemmath.lua");


Comment =
{
	Properties =
	{
		Text = "",
		fSize = 1.2,
		bHidden = 0,
		fMaxDist = 100,
		nCharsPerLine = 30,
		bFixed = 0,
	},

	Editor={
		Model="Editor/Objects/comment.cgf",
		Icon="Comment.bmp",
	},
	
	hidden = 0,
	lines = {},
	lineCount = 0,
}

g_cl_comment = 0;

System.AddCCommand("cl_comment", "g_cl_comment=tonumber(%1)", "Hide/Unhide comments");


-------------------------------------------------------
function Comment:OnLoad(table)
  self.hidden = table.hidden;  
end

-------------------------------------------------------
function Comment:OnSave(table)
  table.hidden = self.hidden;
end


function Comment:OnInit()	
	if (System.IsEditor()) then
		-- this entity is updated every frame even in pure game and is used only by the editor.
		self:SetUpdatePolicy( ENTITY_UPDATE_VISIBLE );
		self:Activate(1);
	else	
		self:Activate(0);
	end	
	
	self:OnReset();
end

function Comment:OnSpawn()
end

function Comment:OnPropertyChange()
	self:OnReset();
end

function Comment:OnReset()
	self.hidden = self.Properties.bHidden;
	self.lines = {};
	
	-- process the text and line-break it
	local maxLength = self.Properties.nCharsPerLine;
	local curLength = 0;
	local curText = "";
	local curLine = 1;
	
	for char in string.gfind(self.Properties.Text, ".") do
		if (char == " ") then
			-- word finished ... see if we are over the limit
			if (curLength > maxLength) then
				-- commit line
				self.lines[curLine] = curText;
				curLine = curLine + 1;
				curText = "";
				curLength = 0;
				-- "consume" the whitespace
				char = "";
			end
		end
		if (char ~= "") then
			-- append char
			curText = curText..char;
			curLength = curLength + 1;
		end
	end
	
	self.lines[curLine] = curText;
	self.lineCount = curLine;
end

function Comment:OnUpdate(delta)
	
	if (self.hidden ~= 0 or self:IsHidden()) then
		return;
	end
	
	local text = self.Properties.Text;
	
	if (text ~= "" and g_cl_comment == 1) then
		
		local alpha = 1;
		local maxdist = self.Properties.fMaxDist;
		local factor = 0;
		
		if (g_localActor and maxdist>0) then
			
			local mypos = g_Vectors.temp_v1;
			local ppos = g_Vectors.temp_v2;
			
			self:GetWorldPos(mypos);
			g_localActor:GetWorldPos(ppos);
			SubVectors(mypos,mypos,ppos);
			
			local dist = LengthSqVector(mypos);
			factor = dist;
						
			if (dist<maxdist*maxdist) then
				alpha = dist/(maxdist*maxdist);
				alpha = 1.0 - alpha*alpha;
			else
				alpha = 0;
			end
		end
		
		local increment = g_Vectors.temp_v3;
		g_localActor:GetDirectionVector(2, increment);
		
		if (alpha>0.001) then
			local pos = self:GetWorldPos( g_Vectors.temp_v1 );
			factor = math.sqrt(factor);
			factor = (self.Properties.fSize/60) * factor;			
			
       		local incrementAll = g_Vectors.temp_v4;
       		FastScaleVector(increment, increment, factor);
       		FastScaleVector(incrementAll, increment, (self.lineCount - 1));
       		
       		-- start all the way at the top
		    FastSumVectors(pos, pos, incrementAll);
						
			for i,val in ipairs(self.lines) do
				if (self.Properties.bFixed == 1) then
					System.DrawLabel( pos, self.Properties.fSize, val, 0, 1, 0, alpha);
				else
					System.DrawLabel( pos, self.Properties.fSize, val, 1, 0.5, 0, alpha );
				end
				-- decrement the increment
				FastDifferenceVectors(pos, pos, increment);
			end
		end
	end
end

function Comment:Event_UnHide(sender)	
	BroadcastEvent(self, "UnHide");
	self.hidden = 0;
end

function Comment:Event_Hide(sender)	
	BroadcastEvent(self, "Hide");
	self.hidden = 1;
end

Comment.FlowEvents =
{
	Inputs =
	{
		Hide = { Comment.Event_Hide, "bool" },
		UnHide = { Comment.Event_UnHide, "bool" },
	},
	Outputs =
	{
		Hide = "bool",
		UnHide = "bool",
	},
}
