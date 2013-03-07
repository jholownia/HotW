#pragma once

namespace hotw
{

class Mouse
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

private:


	void setCursor();

};

} // namespace hotw