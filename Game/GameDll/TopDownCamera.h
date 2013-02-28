#pragma once

#include "Player.h"

namespace hotw
{

const static float gf_cameraAngle = gf_PIHalf * 0.75;

class TopDownCamera
{
public:
	TopDownCamera();
	~TopDownCamera(void);

	void Init(CPlayer const& player, SViewParams& viewParams);
		
	void Update(SViewParams& viewParams);

protected:
		
	// Position
	Vec3 m_position;
	Vec3 m_lastPosition;

	// Rotation
	Quat m_rotation;

	// Fov ?

	// Other ?
	float m_scrollSpeed;
	float m_groundDistance;

	// Constants

};

} // namespace hotw