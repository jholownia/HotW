// (jh) topdowncamera.h

#ifndef TOPDOWN_CAMERA_H
#define TOPDOWN_CAMERA_H

#if _MSC_VER > 1000
# pragma once
#endif

#include "Player.h"
#include "IHardwareMouse.h"

namespace hotw
{
	
const static float gf_cameraAngle = gf_PIHalf * 0.5;

class TopDownCamera : IHardwareMouseEventListener // , IEntity?
{
public:
	TopDownCamera();
	~TopDownCamera(void);

	void Init(CPlayer* player, SViewParams& viewParams);
		
	void Update(SViewParams& viewParams);

	// void setHeightOffset(int delta);

	virtual void OnHardwareMouseEvent(int iX,int iY,EHARDWAREMOUSEEVENT eHardwareMouseEvent, int wheelDelta);
		
protected:
		
	// Position
	Vec3 m_position;
	Vec3 m_lastPosition;

	// Rotation
	Quat m_rotation;
	
	// Direction (to not calculate it each frame)
	Vec3 m_forwardVector;
	Vec3 m_leftVector;

	// add a vector toward center for changing height

	// Other
	float m_scrollSpeed;
	float m_groundDistance;
	float m_zOffset;
	
	bool getGroundLevel(float& z);
};

} // namespace hotw

#endif // TOPDOWN_CAMERA_H