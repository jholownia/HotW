--------------------------------------------------------------------------
--	Crytek Source File.
-- 	Copyright (C), Crytek Studios, 1999-2010.
--------------------------------------------------------------------------
--	File Name        : AnimatedCharacterSample.lua
--	Version          : v1.00
--	Created          : 9/11/2010 by Pau Novau
--  Description      : Sample entity implemented as a Game Object Extension
--                     that shows how to get started with Animated Character
--                     from a code point of view.
--                     See also AnimatedCharacter.h/.cpp, as that's where
--                     most of the implementation for this entity is.
--------------------------------------------------------------------------

AnimatedCharacterSample =
{
	AnimationGraph = "HumanMaleFullBody.xml",
	
	Properties =
	{
		objModel = "Objects/Characters/sdk_player/sdk_player.cdf",
	},

	Editor = 
	{
		Icon = "user.bmp",
		IconOnTop = 1,
	},
}


function AnimatedCharacterSample:OnPropertyChange()
	-- The OnPropertyChange callback is forwarded to script directly by the editor.
	-- As most of this entity is written in C++, we just want to send a notification
	-- that a property has changed, and deal with it there.
	self:ProcessBroadcastEvent( "OnPropertyChange" );
end
