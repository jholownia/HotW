// (jh) topdowncamera.cpp

#include "StdAfx.h"
#include "TopDownCamera.h"

#ifdef WIN32
#define WIN32_LEAN_AND_MEAN
#include <windows.h>
// get rid of (really) annoying MS defines
#undef min
#undef max
#endif

#include <IViewSystem.h>
#include "IHardwareMouse.h"


namespace hotw
{

TopDownCamera::TopDownCamera()
{
	
}


TopDownCamera::~TopDownCamera(void)
{
	if(gEnv->pHardwareMouse)
		gEnv->pHardwareMouse->RemoveListener(this);
}

// viewParams not used here
void TopDownCamera::Init(CPlayer* player, SViewParams& viewParams)
{
	m_groundDistance = 18.0f;
	m_zOffset = 0.0f;
	
	m_position = player->GetEntity()->GetWorldPos();

	// Set top down angle
	Ang3 viewAngle = player->GetEntity()->GetWorldAngles();	
	viewAngle.x -= gf_cameraAngle;
	m_rotation = Quat(viewAngle);


	// Initial height offset
	m_position.z += m_groundDistance;
	
	// playerOffset (so that the player is in the center)
	Vec3 dirVector = player->GetEntity()->GetForwardDir();
	m_position -= dirVector * 18;
	
	// Direction
	m_forwardVector = dirVector.GetNormalized();	
	m_leftVector = dirVector.GetRotated(Vec3(0,0,1), gf_PIHalf);
	
	// Scrolling speed
	m_scrollSpeed = 25.0f;

	// Unlink mouse input from the player (FIXME)
	gEnv->pGame->GetIGameFramework()->GetIActionMapManager()->EnableFilter("no_mouse", true);


	// Add mouse event listener
	if(gEnv->pHardwareMouse)
		gEnv->pHardwareMouse->AddListener(this);

	m_lastPosition = m_position;
}

void TopDownCamera::Update( SViewParams& viewParams )
{
	IRenderer* renderer = gEnv->pRenderer;
		
	int posX, posY, width, height;
	gEnv->pRenderer->GetViewport(&posX, &posY, &width, &height);	
		
	RECT rect;
	GetWindowRect((HWND)renderer->GetHWND(), &rect);
	
	// Absolute mouse position
	float mouseX, mouseY;
	gEnv->pHardwareMouse->GetHardwareMousePosition(&mouseX, &mouseY);
		
	// static
	static float scrollDelta = m_scrollSpeed * gEnv->pTimer->GetFrameTime();
	
	// Use enum here, e.g. Mouse::TOP_LEFT etc.
	if (mouseX <= rect.left)
	{			
		m_position += m_leftVector * scrollDelta;
	}
	else if (mouseX > rect.left && mouseX < rect.right)
	{			
		// m_position.x = m_lastPosition.x;
	}
	else if (mouseX >= rect.right)
	{		
		m_position -= m_leftVector * scrollDelta;
	}
	
	if (mouseY >= rect.bottom)
	{		
		m_position -= m_forwardVector * scrollDelta;		
	}
	else if (mouseY > rect.top && mouseY < rect.bottom)
	{			
		// m_position.y = m_lastPosition.y;
	}
	else if (mouseY <= rect.top)
	{		
		m_position += m_forwardVector * scrollDelta;		
	}

	// Now set the height
	float groundZ;
	if (getGroundLevel(groundZ))
		m_position.z = groundZ + m_groundDistance + m_zOffset;
		
	viewParams.position = m_position;
	viewParams.rotation = Quat(m_rotation);
	m_lastPosition = viewParams.position;
}

// Move this to mouse class, jut check wheel delta from there (store single float "delta" in mouse class)
void TopDownCamera::OnHardwareMouseEvent( int iX,int iY,EHARDWAREMOUSEEVENT eHardwareMouseEvent, int wheelDelta )
{
	m_zOffset -= static_cast<float>(wheelDelta) * gEnv->pTimer->GetFrameTime();
	if (m_zOffset > 0)
		m_zOffset = 0;
	else if (m_zOffset < -10)
		m_zOffset = -10;	
}

// better to cast the ray from the bottom of the screen? or maybe cast 5 rays (center + corners)?
bool TopDownCamera::getGroundLevel(float& z)
{
	IRenderer* pRenderer = gEnv->pRenderer;

	if(!gEnv->pHardwareMouse || !pRenderer || !gEnv->p3DEngine || !gEnv->pSystem || !gEnv->pEntitySystem || !g_pGame->GetIGameFramework())
		return false;

	IActor *pClientActor = g_pGame->GetIGameFramework()->GetClientActor();

	if (!pClientActor)
		return false;
		
	int xPos = gEnv->pRenderer->GetWidth() * 0.5;
	int yPos = gEnv->pRenderer->GetHeight() * 0.5;
	
	Vec3 vPos0(0,0,0);
	pRenderer->UnProjectFromScreen((float)xPos, (float)yPos, 0, &vPos0.x, &vPos0.y, &vPos0.z);

	Vec3 vPos1(0,0,0);
	pRenderer->UnProjectFromScreen((float)xPos, (float)yPos, 1, &vPos1.x, &vPos1.y, &vPos1.z);

	const Vec3 vDir = (vPos1-vPos0).GetNormalized();
	
	IPhysicalEntity *pPhysicalEnt = pClientActor->GetEntity() ? pClientActor->GetEntity()->GetPhysics() : NULL;

	if(!pPhysicalEnt)
		return false;

	static IPhysicalEntity* pSkipEnts[2];
	pSkipEnts[0] = pPhysicalEnt;
	int numSkipped = 1;
		
	entity_query_flags queryFlags = ent_terrain; // see physicsnterface.h for details	
	static const unsigned int flags = rwi_stop_at_pierceable|rwi_colltype_any;
	float  fRange = gEnv->p3DEngine->GetMaxViewDistance();

	static ray_hit hit;

	if (gEnv->pPhysicalWorld && gEnv->pPhysicalWorld->RayWorldIntersection(vPos0, vDir * fRange, queryFlags, flags, &hit, 1, pSkipEnts, numSkipped))
	{
		z = hit.pt.z; // also check hit.pTerrain and hit.distance
		return true;
	}

	return false;
}

} // namespace hotw
