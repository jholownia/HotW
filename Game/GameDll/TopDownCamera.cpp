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

void TopDownCamera::Init(CPlayer* player, SViewParams& viewParams)
{
	m_groundDistance = 15.0f;
	m_zOffset = 0.0f;
	
	m_position = m_lastPosition = player->GetEntity()->GetWorldPos();
	m_rotation = player->GetEntity()->GetWorldRotation();
	
	// Initial height offset
	m_position.z += m_groundDistance;

	// Set top down angle
	m_rotation.SetRotationX(gf_cameraAngle);
	
	// Scrolling speed
	m_scrollSpeed = 25.0f;

	// Unlink mouse input from the player (FIXME)
	gEnv->pGame->GetIGameFramework()->GetIActionMapManager()->EnableFilter("no_mouse", true);

	// Solve for getting the player in the middle


	// Add mouse event listener
	if(gEnv->pHardwareMouse)
		gEnv->pHardwareMouse->AddListener(this);
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
	float scrollDelta = m_scrollSpeed * gEnv->pTimer->GetFrameTime();
		
	if (mouseX <= rect.left)
	{		
		m_position.x = m_lastPosition.x - scrollDelta;
	}
	else if (mouseX > rect.left && mouseX < rect.right)
	{	
		m_position.x = m_lastPosition.x;
	}
	else if (mouseX >= rect.right)
	{
		m_position.x = m_lastPosition.x + scrollDelta;		
	}
	
	if (mouseY >= rect.bottom)
	{
		m_position.y = m_lastPosition.y - scrollDelta;		
	}
	else if (mouseY > rect.top && mouseY < rect.bottom)
	{	
		m_position = m_lastPosition;
	}
	else if (mouseY <= rect.top)
	{
		m_position.y = m_lastPosition.y + scrollDelta;		
	}

	// Now set the height
	float groundZ;
	if (getGroundLevel(groundZ))
		m_position.z = groundZ + m_groundDistance + m_zOffset;

	
	
	viewParams.position = m_position;
	viewParams.rotation = m_rotation;
	m_lastPosition = viewParams.position;
}

void TopDownCamera::OnHardwareMouseEvent( int iX,int iY,EHARDWAREMOUSEEVENT eHardwareMouseEvent, int wheelDelta )
{
	m_zOffset -= static_cast<float>(wheelDelta) * gEnv->pTimer->GetFrameTime();
	if (m_zOffset > 0)
		m_zOffset = 0;
	else if (m_zOffset < -10)
		m_zOffset = -10;

	CryLogAlways("z offset: %f", m_zOffset);
}

bool TopDownCamera::getGroundLevel(float& z)
{
	IRenderer* pRenderer = gEnv->pRenderer;

	if(!gEnv->pHardwareMouse || !pRenderer || !gEnv->p3DEngine || !gEnv->pSystem || !gEnv->pEntitySystem || !g_pGame->GetIGameFramework())
		return false;

	IActor *pClientActor = g_pGame->GetIGameFramework()->GetClientActor();

	if (!pClientActor)
		return false;
		
	int xPos = gEnv->pRenderer->GetWidth() / 2;
	int yPos = gEnv->pRenderer->GetHeight() / 2;
	
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
