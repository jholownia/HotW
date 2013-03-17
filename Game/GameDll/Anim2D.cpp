#include "StdAfx.h"
#include "Anim2D.h"

namespace hotw
{

Anim2D::Anim2D(int seconds) :
	m_seconds(seconds),
	m_timeLeft(0)
{
	m_texture = gEnv->pRenderer->EF_LoadTexture("Textures/click.dds");
}


Anim2D::~Anim2D(void)
{

}

void Anim2D::Update()
{	
	if (m_timeLeft > 0)
	{
		m_timeLeft -= gEnv->pTimer->GetFrameTime();
		float color[4] = {0.5, 1.0, 0.0, 1.0};
		// gEnv->pRenderer->DrawLabelEx(m_pos, m_timeLeft*2, color, true, false, "x");
		// gEnv->pRenderer->SetState( GS_BLSRC_SRCALPHA | GS_BLDST_ONEMINUSSRCALPHA | GS_NODEPTHTEST );
		// gEnv->pRenderer->Set2DMode(true, gEnv->pRenderer->GetWidth(), gEnv->pRenderer->GetHeight());		
		// gEnv->pRenderer->Set2DMode(false, 0,0);
		// gEnv->pRenderer->DrawLabelImage(m_pos, 2, m_texture->GetTextureID());		
	}
}

void Anim2D::Start( Vec3 pos )
{
	m_timeLeft = static_cast<float>(m_seconds);
	m_pos = pos;
}

}