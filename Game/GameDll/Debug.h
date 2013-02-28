#pragma once

#include "IRenderer.h"

namespace hotw
{
	struct LinePosition
	{
		int x;
		int y;
	};
	
	class CDebug
	{
		
	public:
		CDebug(int line) : m_line(line-1) { m_pRenderer = gEnv->pRenderer; }	
			
		void operator()(const char* format, ...);
	
	protected:
		IRenderer* m_pRenderer;
		int m_line;
		static const float m_color[4];
		static const LinePosition m_lines[5];		
	};
	
	const float CDebug::m_color[4] = {1, 1, 1, 1};
	const LinePosition CDebug::m_lines[5] = { {50, 50}, {50, 75}, {50, 100}, {50, 125}, {50, 150} };
	
	inline void CDebug::operator()(const char* format, ...)
	{
		va_list args;
		va_start(args,format);
		SDrawTextInfo ti;
		ti.xscale = 1.5;
		ti.yscale = 1.5;
		ti.flags = eDrawText_2D | eDrawText_800x600 | eDrawText_FixedSize;

		if (m_color) 
		{ 
			ti.color[0] = m_color[0]; 
			ti.color[1] = m_color[1]; 
			ti.color[2] = m_color[2]; 
			ti.color[3] = m_color[3]; 
		}

		m_pRenderer->DrawTextQueued( Vec3(m_lines[m_line].x, m_lines[m_line].y,0.5f),ti,format,args );
		va_end(args);
	}
	
	inline CDebug cDebug(int line) { return CDebug(line); }
	
} // namespace hotw