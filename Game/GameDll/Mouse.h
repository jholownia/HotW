#pragma once

#include "IHardwareMouse.h"

namespace hotw
{

class Mouse : IHardwareMouseEventListener
{
public:
	Mouse(void);
	virtual ~Mouse(void);

	bool isMovingUp();
	bool isMovingDown();
	bool isMovingLeft();
	bool isMovingRight();
	
	void getScreenPosition(int& x, int& y);
	bool getWorldCoords(float& x, float& y, float& z);
	bool getEnityUnderCursor(EntityId& entityId);

	virtual void OnHardwareMouseEvent(int iX, int iY, EHARDWAREMOUSEEVENT eHardwareMouseEvent, int wheelDelta);

private:


	void setCursor();

};

} // namespace hotw