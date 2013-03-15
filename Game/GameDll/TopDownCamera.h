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
	// Move the whole camera to on client enter game?

const static float gf_cameraAngle = gf_PIHalf * 0.5;

class Mouse;

class TopDownCamera // , IEntity?
{
public:
	TopDownCamera();
	~TopDownCamera(void);

	void Init(CPlayer* player, SViewParams& viewParams);
		
	void Update(SViewParams& viewParams);
		
protected:
	// Mouse
	Mouse* m_mouse;

	// Position
	Vec3 m_position;
	Vec3 m_lastPosition;

	// Rotation
	Quat m_rotation;
	
	// Direction (to not calculate it each frame)
	Vec3 m_forwardVector;
	Vec3 m_leftVector;
	Vec3 m_centerVector;

	// add a vector toward center for changing height

	// Other
	float m_scrollSpeed;
	float m_groundDistance;	
	
	bool getGroundLevel(float& z);
};

} // namespace hotw

#endif // TOPDOWN_CAMERA_H