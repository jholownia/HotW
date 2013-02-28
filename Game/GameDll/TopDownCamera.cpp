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

	// Solve an equation to get the player in the middle
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
	/*
	{
		static ray_hit hit;
		IPhysicalEntity* pSkipEntities[10];
		int nSkip = 0;
		
		Vec3 start = m_rotation * Vec3(0,0,0) + m_position; // The vec would be offset, not needed here?
		if (gEnv->pPhysicalWorld.RayWorldIntersection(start, ))

	}
	*/
	

	m_lastPosition = viewParams.position;
	viewParams.position = m_position;
	viewParams.rotation = m_rotation;
}

} // namespace hotw
