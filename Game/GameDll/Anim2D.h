#pragma once

namespace hotw
{

class Anim2D
{
public:
	Anim2D(int seconds);
	~Anim2D();

	void Update();
	void Start(Vec3 pos);	

private:
	float m_seconds;
	float m_timeLeft;
	Vec3 m_pos;
	ITexture* m_texture;
	float* m_color;

};

}

