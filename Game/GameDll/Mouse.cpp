#include "StdAfx.h"
#include "Mouse.h"

namespace hotw
{

Mouse::Mouse(void)
{
	if(gEnv->pHardwareMouse)
		gEnv->pHardwareMouse->AddListener(this);
}


Mouse::~Mouse(void)
{
	if(gEnv->pHardwareMouse)
		gEnv->pHardwareMouse->RemoveListener(this);
}

// Replace all this with getMousePos(enum MousePos) or sth similar
bool Mouse::isMovingUp()
{
	return true;
}

bool Mouse::isMovingDown()
{
	return true;
}

bool Mouse::isMovingLeft()
{
	return true;
}

bool Mouse::isMovingRight()
{
	return true;
}

void Mouse::getScreenPosition( int& x, int& y )
{

}

bool Mouse::getWorldCoords( float& x, float& y, float& z )
{
	return false;
}

bool Mouse::getEnityUnderCursor( EntityId& entityId )
{
	return false;
}

void Mouse::OnHardwareMouseEvent( int iX, int iY, EHARDWAREMOUSEEVENT eHardwareMouseEvent, int wheelDelta )
{

}

} // namespace hotw