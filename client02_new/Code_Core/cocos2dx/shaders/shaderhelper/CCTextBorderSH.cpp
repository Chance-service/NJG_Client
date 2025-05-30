#include "CCTextBorderSH.h"
#include "../CCGLProgram.h"

NS_CC_BEGIN


CCTextBorderSH::CCTextBorderSH(CCGLProgram* _program)
: CCShaderHelper(_program)
{
	uni_color = 0;
	uni_offset = 0;

	color_r = 0.0;
	color_g = 0.0;
	color_b = 0.0;
	color_a = 1.0;

	off_x = 1.0/512.0;
	off_y = 1.0/512.0;

	init();
}

CCTextBorderSH::~CCTextBorderSH()
{
}

void CCTextBorderSH::init()
{
	uni_color = glGetUniformLocation(m_Program->getProgram(), "v_BorderColor");
	uni_offset = glGetUniformLocation(m_Program->getProgram(), "v_BorderWidth");
}

void CCTextBorderSH::begin()
{
	CCShaderHelper::begin();

	if (m_Program)
	{
		if (uni_color > 0)
			m_Program->setUniformLocationWith4f(uni_color, color_r, color_g, color_b, color_a);
		if (uni_offset > 0)
			m_Program->setUniformLocationWith2f(uni_offset, off_x, off_y);
	}
}

void CCTextBorderSH::end()
{
	CCShaderHelper::end();
}

void CCTextBorderSH::setBorderColor(float _r, float _g, float _b, float _a)
{
	color_r = _r;
	color_g = _g;
	color_b = _b;
	color_a = _a;
}

void CCTextBorderSH::setBorderWidth(float _off_x, float _off_y)
{
	off_x = _off_x;
	off_y = _off_y;
}

NS_CC_END
