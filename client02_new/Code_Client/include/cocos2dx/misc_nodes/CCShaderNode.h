/****************************************************************************
Copyright (c) 2010-2012 cocos2d-x.org
Copyright (c) 2009      Jason Booth

http://www.cocos2d-x.org

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
****************************************************************************/
#ifndef __CCShaderNode_H__
#define __CCShaderNode_H__

#include "base_nodes/CCNode.h"
#include "sprite_nodes/CCSprite.h"
#include "kazmath/mat4.h"
#include "misc_nodes/CCRenderTexture.h"

NS_CC_BEGIN

/**
* @addtogroup textures
* @{
*/

namespace shaderNs{
	typedef enum eImageFormat
	{
		kCCImageFormatJPEG = 0,
		kCCImageFormatPNG = 1,
	} tCCImageFormat;
}



/**
@brief CCRenderTexture is a generic rendering target. To render things into it,
simply construct a render target, call begin on it, call visit on any cocos
scenes or objects to render them, and call end. For convenience, render texture
adds a sprite as it's display child with the results, so you can simply add
the render texture to your scene and treat it like any other CocosNode.
There are also functions for saving the render texture to disk in PNG or JPG format.

@since v0.8.1
*/
class CC_DLL CCShaderNode : public CCRenderTexture
{
	CC_RTTI(CCShaderNode, CCNode)

public:
	/**
	* @js ctor
	*/
	CCShaderNode();
	/**
	* @js NA
	* @lua NA
	*/
	virtual ~CCShaderNode();

	virtual void visit();
	virtual void draw();
	bool onDraw();

	static CCShaderNode * create();

	/** initializes a RenderTexture object with width and height in Points and a pixel format, only RGB and RGBA formats are valid */
	bool initWithWidthAndHeight(int w, int h, CCTexture2DPixelFormat eFormat);

	/** initializes a RenderTexture object with width and height in Points and a pixel format( only RGB and RGBA formats are valid ) and depthStencil format*/
	bool initWithWidthAndHeight(int w, int h, CCTexture2DPixelFormat eFormat, GLuint uDepthStencilFormat);

	// add
	virtual void setContentSize(const CCSize& contentSize);

	void setLastPass(bool bAutoDraw);

	void setEnable(bool enable, bool clearUp = false);

	CC_SYNTHESIZE(float, m_value1, Value1);
	CC_SYNTHESIZE(float, m_value2, Value2);
	CC_SYNTHESIZE(float, m_value3, Value3);
	CC_SYNTHESIZE(float, m_value4, Value4);

	CC_SYNTHESIZE(bool, m_bTwoPass, TwoPass);
    CC_SYNTHESIZE(bool, m_bStaticFrame, StaticFrame);

	CC_SYNTHESIZE_READONLY(std::string, m_shaderFile, ShaderFile);
	void setShaderFile(std::string filename);

	CC_SYNTHESIZE(float, m_userScale, UserScale)
    
    virtual void setDrawOnceDirty();
protected:
	CCShaderNode* mRenderTexture;
    CCRenderTexture* mSplashRT;

	virtual void clearUp();
private:
	bool init();

	bool m_bInitDirty;
	bool m_bInitialized;
	GLuint m_uDepthStencilFormat;
	int m_targetWidth;
	int m_targetHeight;

	bool m_bEnable;

	void _prepareTexture();
	void _travalSubShaderNode(CCArray* children);

	unsigned int m_updateFrame;
    //float staticFrameUpdateTime;
};

// end of textures group
/// @}

NS_CC_END

#endif //__CCRENDER_TEXTURE_H__
