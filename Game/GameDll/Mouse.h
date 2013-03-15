#pragma once

#include "IHardwareMouse.h"
#include "Player.h"
#include "Anim2D.h"


namespace hotw
{


class Mouse : IHardwareMouseEventListener
{
public:
	enum MouseVPosition
	{
		VCENTER,
		TOP,
		BOTTOM	
	};

	enum MouseHPosition
	{
		HCENTER,
		LEFT,
		RIGHT
	};

	Mouse(void);
	virtual ~Mouse(void);

	void Update();

	int getMouseVPosition();
	int getMouseHPosition();
	float getWheelDelta();
	
	void getScreenPosition(int& x, int& y);
	bool getWorldCoords(float& x, float& y, float& z);
	EntityId getEntityUnderCursor();

	virtual void OnHardwareMouseEvent(int iX, int iY, EHARDWAREMOUSEEVENT eHardwareMouseEvent, int wheelDelta);

	CPlayer* getPlayer(EntityId id);

private:
	MouseVPosition m_vPosition;
	MouseHPosition m_hPosition;	
	float m_wheelDelta;
	int m_x;
	int m_y;
	Anim2D m_clickFeedback;

	void setCursor();
};

} // namespace hotw