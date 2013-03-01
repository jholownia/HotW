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

}

void TopDownCamera::Init(CPlayer const& player, SViewParams& viewParams)
{
	m_lastPosition = player.GetEntity()->GetWorldPos();
	m_rotation = player.GetEntity()->GetWorldRotation();

	// Initial height offset
	m_lastPosition.z += m_groundDistance;

	// Set top down angle
	m_rotation.SetRotationY(gf_cameraAngle);

	// Scrolling speed
	m_scrollSpeed = 5.0f;

	// Solve for getting the player in the middle
}

void TopDownCamera::Update( SViewParams& viewParams )
{
	IRenderer* renderer = gEnv->pRenderer;	
	static float color[] = {1,1,1,1};	

	int posX, posY, width, height;
	gEnv->pRenderer->GetViewport(&posX, &posY, &width, &height);
	// renderer->Draw2dLabel(100,50,1.5,color,false,"Viewport position: %i, %i; widht x height: %i x %i", posX, posY, width, height);
	// hotw::CDebug(1)("Viewport position: %i, %i; widht x height: %i x %i", posX, posY, width, height);

	RECT rect;
	GetWindowRect((HWND)renderer->GetHWND(), &rect);
	// renderer->Draw2dLabel(100,150,1.5,color,false,"Window rectangle: %i, %i - %i, %i", rect.left, rect.top, rect.right, rect.bottom);
	// hotw::CDebug(2)("Window rectangle: %i, %i - %i, %i", rect.left, rect.top, rect.right, rect.bottom);

	float mouseX, mouseY;
	gEnv->pHardwareMouse->GetHardwareMousePosition(&mouseX, &mouseY);
	//gEnv->pHardwareMouse->GetHardwareMousePosition(&mouseX, &mouseY);
	//renderer->Draw2dLabel(100,200,1.5,color,false,"MouseClientPosition: X: %f, Y: %f, %s", mouseX, mouseY, "bang!");
	// hotw::CDebug(3)("MouseClientPosition: X: %f, Y: %f, %s", mouseX, mouseY);

	// (jh) this logs to the console
	// CryLogAlways("MouseClientPosition: X: %f, Y: %f, %s", mouseX, mouseY);

	// (jh) put that somewhere else
	gEnv->pGame->GetIGameFramework()->GetIActionMapManager()->EnableFilter("no_mouse", true);

	// hotw::CDebug(4)("viewParams.rotation.Z: %f", viewParams.rotation.GetRotZ());
	
	static float scrollDelta = m_scrollSpeed * gEnv->pTimer->GetFrameTime();


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


	m_lastPosition = viewParams.position;
	viewParams.position = m_position;
	viewParams.rotation = m_rotation;
}

void TopDownCamera::OnHardwareMouseEvent( int iX,int iY,EHARDWAREMOUSEEVENT eHardwareMouseEvent, int wheelDelta )
{
	static float delta = 0.0;
	delta += static_cast<float>(wheelDelta) * gEnv->pTimer->GetFrameTime();
	if (-5 < delta < 5)
		m_zOffset = delta;
}

bool TopDownCamera::getGroundLevel(float& z)
{
	IRenderer* pRenderer = gEnv->pRenderer;

	if(!gEnv->pHardwareMouse || !pRenderer || !gEnv->p3DEngine || !gEnv->pSystem || !gEnv->pEntitySystem || !g_pGame->GetIGameFramework())
		return 0;

	IActor *pClientActor = g_pGame->GetIGameFramework()->GetClientActor();

	if (!pClientActor)
		return 0;
		
	int xPos = gEnv->pRenderer->GetWidth() / 2;
	int yPos = gEnv->pRenderer->GetHeight() / 2;
	
	Vec3 vPos0(0,0,0);
	pRenderer->UnProjectFromScreen((float)xPos, (float)yPos, 0, &vPos0.x, &vPos0.y, &vPos0.z);

	Vec3 vPos1(0,0,0);
	pRenderer->UnProjectFromScreen((float)xPos, (float)yPos, 1, &vPos1.x, &vPos1.y, &vPos1.z);

	const Vec3 vDir = (vPos1-vPos0).GetNormalized();
	
	IPhysicalEntity *pPhysicalEnt = pClientActor->GetEntity() ? pClientActor->GetEntity()->GetPhysics() : NULL;

	if(!pPhysicalEnt)
		return 0;

	static IPhysicalEntity* pSkipEnts[2];
	pSkipEnts[0] = pPhysicalEnt;
	int numSkipped = 1;
		
	entity_query_flags queryFlags = ent_terrain; // see physinterface.h for details	
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
