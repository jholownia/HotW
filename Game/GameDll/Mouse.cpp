#include "StdAfx.h"
#include "Mouse.h"


#ifdef WIN32
#define WIN32_LEAN_AND_MEAN
#include <windows.h>
// get rid of (really) annoying MS defines
#undef min
#undef max
#endif

namespace hotw
{

Mouse::Mouse(void) :
	m_hPosition(HCENTER),
	m_vPosition(VCENTER),
	m_wheelDelta(0),
	m_clickFeedback(1)
{
	if(gEnv->pHardwareMouse)
		gEnv->pHardwareMouse->AddListener(this);	
}

Mouse::~Mouse(void)
{
	if(gEnv->pHardwareMouse)
		gEnv->pHardwareMouse->RemoveListener(this);
}

void Mouse::Update()
{
	IRenderer* renderer = gEnv->pRenderer;
		
	int width = renderer->GetWidth();
	int height = renderer->GetHeight();

	RECT rect;
	GetWindowRect((HWND)renderer->GetHWND(), &rect);

	// Absolute mouse position
	float mouseX, mouseY;
	gEnv->pHardwareMouse->GetHardwareMousePosition(&mouseX, &mouseY);
	
	if (mouseX <= rect.left)
	{			
		m_hPosition = LEFT;
	}
	else if (mouseX > rect.left && mouseX < rect.right)
	{			
		m_hPosition = HCENTER;
	}
	else if (mouseX >= rect.right)
	{	
		m_hPosition = RIGHT;
	}

	if (mouseY >= rect.bottom)
	{		
		m_vPosition = BOTTOM;
	}
	else if (mouseY > rect.top && mouseY < rect.bottom)
	{			
		m_vPosition = VCENTER;
	}
	else if (mouseY <= rect.top)
	{		
		m_vPosition = TOP;
	}
		
	m_clickFeedback.Update();
}

void Mouse::OnHardwareMouseEvent( int iX,int iY,EHARDWAREMOUSEEVENT eHardwareMouseEvent, int wheelDelta )
{	
	m_x = iX;
	m_y = iY;
	
	if(eHardwareMouseEvent == HARDWAREMOUSEEVENT_LBUTTONDOWN)
	{
		CryLogAlways("LEFT BUTTON PRESSED");
		CryLogAlways("requesting movement...");

		CPlayer* pPlayer = CPlayer::GetHero();
		Vec3 pos;
		getWorldCoords(pos.x, pos.y, pos.z);		
		m_clickFeedback.Start(pos);
		CMovementRequest request;
		request.SetMoveTarget(pos);		
		pPlayer->GetMovementController()->RequestMovement(request);
	}
	if (eHardwareMouseEvent == HARDWAREMOUSEEVENT_LBUTTONUP)
	{

	}

	if(eHardwareMouseEvent == HARDWAREMOUSEEVENT_RBUTTONDOWN)
	{
		CryLogAlways("RIGHT BUTTON PRESSED");
		getEntityUnderCursor();
	}
	if(eHardwareMouseEvent == HARDWAREMOUSEEVENT_RBUTTONUP)
	{
		CryLogAlways("RIGHT BUTTON RELEASED");
	}

	if (eHardwareMouseEvent == HARDWAREMOUSEEVENT_WHEEL)
	{
		CryLogAlways("WHEEL MOVED");
		m_wheelDelta -= static_cast<float>(wheelDelta) * gEnv->pTimer->GetFrameTime();
		if (m_wheelDelta > 0)
			m_wheelDelta = 0;
		else if (m_wheelDelta < -10)
			m_wheelDelta = -10;

		getEntityUnderCursor();
	}
}

int Mouse::getMouseVPosition()
{
	return m_vPosition;
}

int Mouse::getMouseHPosition()
{
	return m_hPosition;
}

void Mouse::getScreenPosition( int& x, int& y )
{
	x = m_x;
	y = m_y;
}

bool Mouse::getWorldCoords( float& x, float& y, float& z )
{
	IRenderer* pRenderer = gEnv->pRenderer;

	if(!gEnv->pHardwareMouse || !pRenderer || !gEnv->p3DEngine || !gEnv->pSystem || !gEnv->pEntitySystem || !g_pGame->GetIGameFramework())
		return false;

	IActor *pClientActor = g_pGame->GetIGameFramework()->GetClientActor();

	if (!pClientActor)
		return false;

	float mx, my, cx, cy, cz = 0.0f;

	mx = m_x - 4;
	my = pRenderer->GetHeight() - m_y + 10;

	pRenderer->UnProjectFromScreen(mx, my, 0.0f, &cx, &cy, &cz);
	
	IPhysicalEntity *pPhysicalEnt = pClientActor->GetEntity() ? pClientActor->GetEntity()->GetPhysics() : NULL;

	if(!pPhysicalEnt)
		return false;

	entity_query_flags queryFlags = ent_terrain; // see physicsnterface.h for details	
	static const unsigned int flags = rwi_stop_at_pierceable|rwi_colltype_any;
	float  fRange = gEnv->p3DEngine->GetMaxViewDistance();

	Vec3 vCamPos = gEnv->pSystem->GetViewCamera().GetPosition();
	Vec3 vDir = (Vec3(cx, cy, cz) - vCamPos).GetNormalizedSafe();

	static ray_hit hit;

	if (gEnv->pPhysicalWorld && gEnv->pPhysicalWorld->RayWorldIntersection(vCamPos, vDir * fRange, queryFlags, flags, &hit, 1, pPhysicalEnt))
	{
		x = hit.pt.x;
		y = hit.pt.y;
		z = hit.pt.z;

		return true;
	}

	return false;
}

EntityId Mouse::getEntityUnderCursor()
{
	IRenderer* pRenderer = gEnv->pRenderer;

	if(!gEnv->pHardwareMouse || !pRenderer || !gEnv->p3DEngine || !gEnv->pSystem || !gEnv->pEntitySystem || !g_pGame->GetIGameFramework())
		return false;

	IActor *pClientActor = g_pGame->GetIGameFramework()->GetClientActor();

	if (!pClientActor)
		return false;

	float mx, my, cx, cy, cz = 0.0f;

	mx = m_x;
	my = pRenderer->GetHeight() - m_y;

	pRenderer->UnProjectFromScreen(mx, my, 0.0f, &cx, &cy, &cz);

	IPhysicalEntity *pPhysicalEnt = pClientActor->GetEntity() ? pClientActor->GetEntity()->GetPhysics() : NULL;

	if(!pPhysicalEnt)
		return false;

	entity_query_flags queryFlags = ent_all; // see physicsnterface.h for details	
	static const unsigned int flags = rwi_stop_at_pierceable|rwi_colltype_any;
	float  fRange = gEnv->p3DEngine->GetMaxViewDistance();

	Vec3 vCamPos = gEnv->pSystem->GetViewCamera().GetPosition();
	Vec3 vDir = (Vec3(cx, cy, cz) - vCamPos).GetNormalizedSafe();

	static ray_hit hit;

	if (gEnv->pPhysicalWorld && gEnv->pPhysicalWorld->RayWorldIntersection(vCamPos, vDir * fRange, queryFlags, flags, &hit, 1, pPhysicalEnt))
	{
		CryLogAlways("Entity position: %f, %f, %f", hit.pt.x, hit.pt.y, hit.pt.z);
		if (IEntity* pEntity = gEnv->pEntitySystem->GetEntityFromPhysics(hit.pCollider))
		{						
			CryLogAlways("Entity name:", pEntity->GetName());
			return pEntity->GetId();
		}		
	}

	return 0;
}

float Mouse::getWheelDelta()
{
	return m_wheelDelta;
}

CPlayer* Mouse::getPlayer(EntityId id)
{
	if (id == 0)
	{
		return NULL;
	}
	
	CActor* pActor = g_pGame ? static_cast<CActor*> (g_pGame->GetIGameFramework()->GetIActorSystem()->GetActor(id)) : NULL;

	if (pActor != NULL && pActor->GetActorClass() == CPlayer::GetActorClassType())
	{
		return static_cast<CPlayer*> (pActor);
	}

	return NULL;
}

void Mouse::setCursor()
{
	// HCURSOR hCursor = LoadCursor(GetModuleHandle(0),MAKEINTRESOURCE(DEFAULT_CURSOR_RESOURCE_ID));
	// ::SetCursor(hCursor);
}


} // namespace hotw