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

#include "CCConfiguration.h"
#include "CCShaderNode.h"
#include "CCDirector.h"
#include "platform/platform.h"
#include "platform/CCImage.h"
#include "shaders/CCGLProgram.h"
#include "shaders/ccGLStateCache.h"
#include "CCConfiguration.h"
#include "support/ccUtils.h"
#include "textures/CCTextureCache.h"
#include "platform/CCFileUtils.h"
#include "CCGL.h"
#include "support/CCNotificationCenter.h"
#include "CCEventType.h"
#include "effects/CCGrid.h"
// extern
#include "kazmath/GL/matrix.h"
#include "CCEGLView.h"

NS_CC_BEGIN

using namespace shaderNs;

// const GLchar * shadervertex =
// #include "ccShader_PositionTextureColor_vert.h";


class CCShaderSprite : public CCSprite{
	CC_RTTI(CCShaderSprite, CCSprite)
public:
	static CCShaderSprite* create(CCShaderNode* shaderNode, CCTexture2D *pTexture);
	virtual void visit();
	virtual void draw();

	CC_SYNTHESIZE(float, m_value1, Value1);
	CC_SYNTHESIZE(float, m_value2, Value2);
	CC_SYNTHESIZE(float, m_value3, Value3);
	CC_SYNTHESIZE(float, m_value4, Value4);
	CC_SYNTHESIZE(float, m_pass, Pass);
private:
	CC_SYNTHESIZE(std::string, m_shaderFile, ShaderFile);
	CC_SYNTHESIZE(CCShaderNode*, m_pShaderNode, ShaderNode);
};

							   
CCShaderSprite* CCShaderSprite::create(CCShaderNode* shaderNode, CCTexture2D *pTexture)
{
	CCShaderSprite *pobSprite = new CCShaderSprite();
	if (pobSprite && pobSprite->initWithTexture(pTexture))
	{
        pTexture->setAntiAliasTexParameters();
		pobSprite->setShaderNode(shaderNode);
		pobSprite->autorelease();
		return pobSprite;
	}
	CC_SAFE_DELETE(pobSprite);
	return NULL;
}
void CCShaderSprite::visit(){
	if (m_shaderFile != m_pShaderNode->getShaderFile()){
		m_shaderFile = m_pShaderNode->getShaderFile();
		CCGLProgram* shader = new CCGLProgram();
		setShaderProgram(shader);
		
		std::string vsfile = CCFileUtils::sharedFileUtils()->fullPathForFilename("Shader/vs.vs");
		shader->initWithVertexShaderFilename(vsfile.c_str(), CCFileUtils::sharedFileUtils()->fullPathForFilename(m_shaderFile.c_str()).c_str());
		//shader->initWithVertexShaderByteArray(shadervertex, shaderfragment);
		shader->addAttribute(kCCAttributeNamePosition, kCCVertexAttrib_Position);
		shader->addAttribute(kCCAttributeNameColor, kCCVertexAttrib_Color);
		shader->addAttribute(kCCAttributeNameTexCoord, kCCVertexAttrib_TexCoords);
		shader->link();
		shader->updateUniforms();
		shader->release();
	}
	CCNode::visit();
}
void CCShaderSprite::draw(){

	CC_NODE_DRAW_SETUP();

	int location = 0; 
	location = glGetUniformLocation(getShaderProgram()->getProgram(), "paras");
	if (location != -1){
		getShaderProgram()->setUniformLocationWith4f(location,	m_value1,
																m_value2,
																m_value3, 
																m_value4);
	}
	CHECK_GL_ERROR_DEBUG();

	location = glGetUniformLocation(getShaderProgram()->getProgram(), "texSize");
	if (location != -1){
		float width = m_pShaderNode->getContentSize().width;
		float height = m_pShaderNode->getContentSize().height;
		float userscale = getShaderNode()->getUserScale();
		if (userscale > 0){
			width *= userscale;
			height *= userscale;
		}
		getShaderProgram()->setUniformLocationWith2f(location, width, height);
	}
	CHECK_GL_ERROR_DEBUG();

	location = glGetUniformLocation(getShaderProgram()->getProgram(), "pass");
	if (location != -1){
		getShaderProgram()->setUniformLocationWith1f(location, m_pass);
	}
	CHECK_GL_ERROR_DEBUG();

    ccBlendFunc fun;
    fun.src = GL_SRC_ALPHA;
    fun.dst = GL_ONE_MINUS_SRC_ALPHA;
    setBlendFunc(fun);
	CCSprite::draw();
}




// implementation CCShaderNode
CCShaderNode::CCShaderNode()
: mRenderTexture(0)
, m_bInitDirty(false)
, m_bInitialized(false)
, m_uDepthStencilFormat(GL_DEPTH24_STENCIL8)
, m_targetWidth(0)
, m_targetHeight(0)
, m_bEnable(true)
, m_bTwoPass(false)
, m_userScale(1.0f)
, m_updateFrame(0)
, mSplashRT(0)
, m_bStaticFrame(false)
//, staticFrameUpdateTime(0)
{

	// add
	//drawImplemented = true;

#if CC_ENABLE_CACHE_TEXTURE_DATA
	// Listen this event to save render texture before come to background.
	// Then it can be restored after coming to foreground on Android.
	CCNotificationCenter::sharedNotificationCenter()->addObserver(this,
		callfuncO_selector(CCShaderNode::listenToBackground),
		EVENT_COME_TO_BACKGROUND,
		NULL);

	CCNotificationCenter::sharedNotificationCenter()->addObserver(this,
		callfuncO_selector(CCShaderNode::listenToForeground),
		EVENT_COME_TO_FOREGROUND, // this is misspelt
		NULL);
#endif
}

CCShaderNode::~CCShaderNode()
{
    CC_SAFE_RELEASE(mSplashRT);
}


void CCShaderNode::setLastPass(bool lastpass)
{
//	m_bTwoPass = lastpass;
	if (!m_pSprite){
		return;
	}

	float USER_SCALE_INV = 1.0f / m_userScale;
	if (lastpass){
		m_pSprite->removeFromParent();
		if (mRenderTexture){
			//mRenderTexture->removeFromParent();
			CC_SAFE_RELEASE_NULL(mRenderTexture);
		}		
		m_pSprite->setScaleY(-USER_SCALE_INV);
		m_pSprite->setScaleX(USER_SCALE_INV);
		m_pSprite->setPositionX(m_targetWidth*0.5f);
		m_pSprite->setPositionY(m_targetHeight*0.5f);
		((CCShaderSprite*)getSprite())->setPass(0);
		addChild(m_pSprite);
	}
	else{
		setClearColor(ccc4f(0, 0, 0, 0));
		m_pSprite->removeFromParent();
		if (!mRenderTexture || mRenderTexture->getRenderTargetHeight() != m_targetHeight*m_userScale || mRenderTexture->getRenderTargetWidth() != m_targetWidth*m_userScale){
			if (mRenderTexture)mRenderTexture->removeFromParent();
			mRenderTexture = CCShaderNode::create();
            mRenderTexture->setShaderFile(getShaderFile());
			mRenderTexture->setClearColor(ccc4f(0, 0, 0, 0));
			mRenderTexture->setClearFlags(GL_COLOR_BUFFER_BIT);
			mRenderTexture->m_uDepthStencilFormat = 0;
            mRenderTexture->setStaticFrame(false);
			mRenderTexture->retain();
		}
		//mRenderTexture->setContentSize(m_targetWidth, m_targetHeight);
		m_pSprite->setScaleY(-1);
		m_pSprite->setScaleX(1);
		m_pSprite->setAnchorPoint(0, 1);
		m_pSprite->setPosition(0, 0);
// 		((CCShaderSprite*)getSprite())->setValue1(0.0f);
// 		((CCShaderSprite*)getSprite())->setValue2(1.0f);
		((CCShaderSprite*)getSprite())->setPass(0);

		mRenderTexture->addChild(m_pSprite);
        //mRenderTexture->setAnchorPoint(0, 0);
        mRenderTexture->setContentSize(CCSizeMake(m_targetWidth*m_userScale, m_targetHeight*m_userScale));
        mRenderTexture->setUserScale(1.0f);

		//mRenderTexture->setPosition(m_targetWidth*0.5f, m_targetHeight*0.5f);
		mRenderTexture->setTwoPass(false);
		mRenderTexture->init();
        mRenderTexture->setValue1(getValue1());
        mRenderTexture->setValue2(getValue2());
        mRenderTexture->setValue3(getValue3());
        mRenderTexture->setValue4(getValue4());
		mRenderTexture->getSprite()->removeFromParent();
        CCShaderSprite* subSprite = CCShaderSprite::create(mRenderTexture, mRenderTexture->m_pTexture);
		mRenderTexture->setSprite(subSprite);
        subSprite->setValue1(getValue1());
        subSprite->setValue2(getValue2());
        subSprite->setValue3(getValue3());
        subSprite->setValue4(getValue4());
        
		mRenderTexture->setLastPass(true);
		mRenderTexture->setScale(USER_SCALE_INV);
		((CCShaderSprite*)mRenderTexture->getSprite())->setPass(1.0f);
// 		mRenderTexture->getSprite()->setScaleY(-USER_SCALE_INV);
// 		mRenderTexture->getSprite()->setScaleX(USER_SCALE_INV);
// 		((CCShaderSprite*)mRenderTexture->getSprite())->setPositionX(m_targetWidth*m_userScale*0.5f);
// 		((CCShaderSprite*)mRenderTexture->getSprite())->setPositionY(m_targetHeight*m_userScale*0.5f);
        
        CC_SAFE_RELEASE_NULL(mRenderTexture->mRenderTexture);
        CC_SAFE_RELEASE_NULL(mRenderTexture->mSplashRT);

		setDrawOnceDirty();

	}
}

CCShaderNode * CCShaderNode::create(){
	CCShaderNode *pRet = new CCShaderNode();
	pRet->setClearColor(ccc4f(0, 0, 0, 0));
	pRet->setClearFlags(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT|GL_STENCIL_BUFFER_BIT);
	if (pRet)
	{
		pRet->autorelease();
		return pRet;
	}
	CC_SAFE_DELETE(pRet);
	return NULL;
}

bool CCShaderNode::initWithWidthAndHeight(int w, int h, CCTexture2DPixelFormat eFormat)
{
	return initWithWidthAndHeight(w, h, eFormat, GL_DEPTH24_STENCIL8);
}

bool CCShaderNode::initWithWidthAndHeight(int w, int h, CCTexture2DPixelFormat eFormat, GLuint uDepthStencilFormat)
{
	CCAssert(eFormat != kCCTexture2DPixelFormat_A8, "only RGB and RGBA formats are valid for a render texture");

	bool bRet = false;

	bool recreateTexture = false;
	if (m_pSprite){
		CCTexture2D* texture = m_pSprite->getTexture();
		if (texture->getPixelFormat() != eFormat){
			recreateTexture = true;
		}
		else{
			int w2 = (int)(w * CC_CONTENT_SCALE_FACTOR());
			int h2 = (int)(h * CC_CONTENT_SCALE_FACTOR());
			const CCSize& contentSize = texture->getContentSizeInPixels();
			if (contentSize.width != w2 || contentSize.height != h2){
				recreateTexture = true;
			}
		}
	}
	else{
		recreateTexture = true;
	}
	if (recreateTexture){
		// clear
		if (m_pSprite){
			removeChild(m_pSprite);
			CC_SAFE_RELEASE_NULL(m_pSprite);
		}
		CC_SAFE_RELEASE_NULL(m_pTextureCopy);
		if (m_uFBO){
			glDeleteFramebuffers(1, &m_uFBO);
			m_uFBO = 0;
		}
		if (m_uDepthRenderBufffer)
		{
			glDeleteRenderbuffers(1, &m_uDepthRenderBufffer);
			m_uDepthRenderBufffer = 0;
        }
        if(m_uStencilRenderBufffer)
        {
            glDeleteRenderbuffers(1, &m_uStencilRenderBufffer);
            m_uStencilRenderBufffer = 0;
        }
		CC_SAFE_DELETE(m_pUITextureImage);
	}
	if (w == 0 || h == 0){
		CCMessageBox("can not make shader Node with width or height set 0 !!!", "");
		recreateTexture = false;
	}

	m_bInitDirty = recreateTexture;
	m_ePixelFormat = eFormat;
	m_uDepthStencilFormat = uDepthStencilFormat;
	m_targetWidth = w;
	m_targetHeight = h;
	m_uRenderTargetHeight = h;
	m_uRenderTargetWidth = w;
	return true;
}
bool CCShaderNode::init()
{
	bool bRet = false;
	void *data = NULL;
	do
	{
		int w = m_targetWidth*m_userScale;
		int h = m_targetHeight*m_userScale;

		// textures must be power of two squared
		w = (int)(w * CC_CONTENT_SCALE_FACTOR());
		h = (int)(h * CC_CONTENT_SCALE_FACTOR());

		glGetIntegerv(GL_FRAMEBUFFER_BINDING, &m_nOldFBO);

		// textures must be power of two squared
		unsigned int powW = 0;
		unsigned int powH = 0;

		if (CCConfiguration::sharedConfiguration()->supportsNPOT())
		{
			powW = w;
			powH = h;
		}
		else
		{
			powW = ccNextPOT(w);
			powH = ccNextPOT(h);
		}

		data = malloc((int)(powW * powH * 4));
		CC_BREAK_IF(!data);

		memset(data, 0, (int)(powW * powH * 4));

		m_pTexture = new CCTexture2D();
		if (m_pTexture)
		{
			m_pTexture->initWithData(data, (CCTexture2DPixelFormat)m_ePixelFormat, powW, powH, CCSizeMake((float)w, (float)h));
		}
		else
		{
			break;
		}
		GLint oldRBO;
		glGetIntegerv(GL_RENDERBUFFER_BINDING, &oldRBO);

		if (CCConfiguration::sharedConfiguration()->checkForGLExtension("GL_QCOM"))
		{
			m_pTextureCopy = new CCTexture2D();
			if (m_pTextureCopy)
			{
				m_pTextureCopy->initWithData(data, (CCTexture2DPixelFormat)m_ePixelFormat, powW, powH, CCSizeMake((float)w, (float)h));
			}
			else
			{
				break;
			}
		}

		// generate FBO
		glGenFramebuffers(1, &m_uFBO);
		glBindFramebuffer(GL_FRAMEBUFFER, m_uFBO);

		// associate texture with FBO
		glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, m_pTexture->getName(), 0);

		if (m_uDepthStencilFormat != 0)
		{
			//create and attach depth buffer
			glGenRenderbuffers(1, &m_uDepthRenderBufffer);
			glBindRenderbuffer(GL_RENDERBUFFER, m_uDepthRenderBufffer);
            
            bool packedDepthStencil = CCConfiguration::sharedConfiguration()->checkForGLExtension("GL_OES_packed_depth_stencil");
#if CC_TARGET_PLATFORM == CC_PLATFORM_WIN32
			packedDepthStencil = true;
#endif
            if(packedDepthStencil)
                glRenderbufferStorage(GL_RENDERBUFFER, m_uDepthStencilFormat, (GLsizei)powW, (GLsizei)powH);
            else
                glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, (GLsizei)powW, (GLsizei)powH);

            glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, m_uDepthRenderBufffer);
			// if depth format is the one with stencil part, bind same render buffer as stencil attachment

            if (m_uDepthStencilFormat == GL_DEPTH24_STENCIL8)
			{
                if(packedDepthStencil){
                    glRenderbufferStorage(GL_RENDERBUFFER, m_uDepthStencilFormat, (GLsizei)powW, (GLsizei)powH);
                    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_STENCIL_ATTACHMENT, GL_RENDERBUFFER, m_uDepthRenderBufffer);
                }
                else{
                    CCLOG("create unpacked depth and stencil buffer!");
                    glGenRenderbuffers(1, &m_uStencilRenderBufffer);
                    glBindRenderbuffer(GL_RENDERBUFFER, m_uStencilRenderBufffer);
                    glRenderbufferStorage(GL_RENDERBUFFER, GL_STENCIL_INDEX8, (GLsizei)powW, (GLsizei)powH);
                    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_STENCIL_ATTACHMENT, GL_RENDERBUFFER, m_uStencilRenderBufffer);
                }
			}
		}

		// check if it worked (probably worth doing :) )
		CCAssert(glCheckFramebufferStatus(GL_FRAMEBUFFER) == GL_FRAMEBUFFER_COMPLETE, "Could not attach texture to framebuffer");
        if(glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE){
            CCLOG("Could not attach texture to framebuffer");
        }

		// retained
        CCShaderSprite* subSprite = CCShaderSprite::create(this, m_pTexture);
        m_pTexture->setAntiAliasTexParameters();
        setSprite(subSprite);
        subSprite->setValue1(getValue1());
        subSprite->setValue2(getValue2());
        subSprite->setValue3(getValue3());
        subSprite->setValue4(getValue4());
        

		m_pTexture->release();

		ccBlendFunc tBlendFunc = { GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA };
		m_pSprite->setBlendFunc(tBlendFunc);

		glBindRenderbuffer(GL_RENDERBUFFER, oldRBO);
		glBindFramebuffer(GL_FRAMEBUFFER, m_nOldFBO);

		//m_bAutoDraw = true;
		setLastPass(!m_bTwoPass);

		bRet = true;

		m_bInitDirty = false;
		m_bInitialized = true;
	} while (0);

	CC_SAFE_FREE(data);

	return bRet;
}


void CCShaderNode::_prepareTexture()
{
	unsigned int currentframe = CCDirector::sharedDirector()->getTotalFrames();
	if (currentframe <= m_updateFrame){
		return;
	}
	m_updateFrame = currentframe;

	_travalSubShaderNode(getChildren());

	if ((m_bInitDirty||!m_bInitialized) && m_bEnable){
		if (m_bInitialized)
		{
			clearUp();
		}
		if (!init()){
			m_bVisible = false;
			return;
		}
	}

	if (!m_bInitialized)
		return;


	if (m_bInitialized)
	{
		begin();

		if (m_uClearFlags)
		{
			GLfloat oldClearColor[4] = { 0.0f };
			GLfloat oldDepthClearValue = 0.0f;
			GLint oldStencilClearValue = 0;

			// backup and set
			if (m_uClearFlags & GL_COLOR_BUFFER_BIT)
			{
				glGetFloatv(GL_COLOR_CLEAR_VALUE, oldClearColor);
				glClearColor(m_sClearColor.r, m_sClearColor.g, m_sClearColor.b, m_sClearColor.a);
			}

			if (m_uClearFlags & GL_DEPTH_BUFFER_BIT)
			{
				glGetFloatv(GL_DEPTH_CLEAR_VALUE, &oldDepthClearValue);
				glClearDepth(m_fClearDepth);
			}

			if (m_uClearFlags & GL_STENCIL_BUFFER_BIT)
			{
				glGetIntegerv(GL_STENCIL_CLEAR_VALUE, &oldStencilClearValue);
				glClearStencil(m_nClearStencil);
			}

			// clear
			glClear(m_uClearFlags);

			// restore
			if (m_uClearFlags & GL_COLOR_BUFFER_BIT)
			{
				glClearColor(oldClearColor[0], oldClearColor[1], oldClearColor[2], oldClearColor[3]);
			}
			if (m_uClearFlags & GL_DEPTH_BUFFER_BIT)
			{
				glClearDepth(oldDepthClearValue);
			}
			if (m_uClearFlags & GL_STENCIL_BUFFER_BIT)
			{
				glClearStencil(oldStencilClearValue);
			}
		}

		//! make sure all children are drawn
		sortAllChildren();

		kmMat4 mat;
		//kmMat4Translation(&mat, -getContentSize().width*0.25, -getContentSize().height*0.25, 0);
		//kmGLMultMatrix(&mat);
		kmMat4Scaling(&mat, m_userScale, m_userScale, 1.0f);
		kmGLMultMatrix(&mat);


		CCObject *pElement;
		CCARRAY_FOREACH(m_pChildren, pElement)
		{
			CCNode *pChild = (CCNode*)pElement;

			if (pChild != mRenderTexture && pChild != m_pSprite)
			{
				pChild->visit();
			}
		}

		end();
	}

    if (mRenderTexture){
		mRenderTexture->_prepareTexture();
    }
}

void CCShaderNode::_travalSubShaderNode(CCArray* children)
{
	if (children == NULL)return;
	CCObject *child;
	CCARRAY_FOREACH(children, child) {

#ifdef DEBUG
		CCAssert(dynamic_cast<CCNode*>(child),"all children of ccshaderNode must be CCNode!!");
#endif // DEBUG
        CCNode* node  = (CCNode*)child;
        if(node->isVisible()){
            _travalSubShaderNode(((CCNode*)child)->getChildren());
            
            if (dynamic_cast<CCShaderNode*>(child))
            {
                CCShaderNode* sn = (CCShaderNode*)child;
                sn->_prepareTexture();
            }
        }
	}
}


void CCShaderNode::visit()
{
	// override visit.
	// Don't call visit on its children
	if (!m_bVisible)
	{
		return;
	}
	if (!m_bEnable)
	{
		bool orivisRenderTexture = false;
		if (mRenderTexture){
			orivisRenderTexture = mRenderTexture->isVisible();
			mRenderTexture->setVisible(false);
		}
		bool orivisSprite = false;
		if (m_pSprite){
			orivisSprite = m_pSprite->isVisible();
			m_pSprite->setVisible(false);
		}
		CCNode::visit();

		if (mRenderTexture)mRenderTexture->setVisible(orivisRenderTexture);
		if (m_pSprite)m_pSprite->setVisible(orivisSprite);

		return;
	}
    
    if(!mSplashRT || mSplashRT->isDrawOnceDirty()){
        //_travalSubShaderNode(getChildren());
        
        _prepareTexture();
    }
    
    //set static frame
    if(!mSplashRT && getStaticFrame()){
        mSplashRT = CCRenderTexture::create(m_targetWidth*m_userScale, m_targetHeight*m_userScale, kCCTexture2DPixelFormat_RGBA8888, 0);
        mSplashRT->setScale(1.0f/m_userScale);
        mSplashRT->setClearColor(ccc4f(0, 0, 0, 0));
        mSplashRT->setClearFlags(GL_COLOR_BUFFER_BIT);
        mSplashRT->setDrawOnceDirty();
        //addChild(mSplashRT);
        CC_SAFE_RETAIN(mSplashRT);
        
        if(m_bTwoPass){
            mRenderTexture->removeFromParent();
            mSplashRT->addChild(mRenderTexture);
            mRenderTexture->setScale(mRenderTexture->getScale()*m_userScale);
        }
        else{
            m_pSprite->removeFromParent();
            mSplashRT->addChild(m_pSprite);
            m_pSprite->setScaleX(1.0f);
            m_pSprite->setScaleY(-1.0f);
            m_pSprite->setPositionX(m_targetWidth*0.5f*m_userScale);
            m_pSprite->setPositionY(m_targetHeight*0.5f*m_userScale);
        }
        mSplashRT->setPosition(m_targetWidth*0.5f, m_targetHeight*0.5f);
    }
    
    //cancel static frame
    if(mSplashRT && !getStaticFrame()){
        //single pass
        if(m_pSprite->getParent()==mSplashRT){
            m_pSprite->removeFromParent();
            m_pSprite->setScaleY(-1.0f/m_userScale);
            m_pSprite->setScaleX(1.0f/m_userScale);
            m_pSprite->setPositionX(m_targetWidth*0.5f);
            m_pSprite->setPositionY(m_targetHeight*0.5f);
            addChild(m_pSprite);
        }
        CC_SAFE_RELEASE_NULL(mSplashRT);
    }
    
	kmGLPushMatrix();

	if (m_pGrid && m_pGrid->isActive())
	{
		m_pGrid->beforeDraw();
		transformAncestors();
	}

	transform();
	//draw();
    
    if(!mSplashRT)
    {
        if (!m_bTwoPass){
            //m_pSprite->setVisible(true);
            if (m_pSprite)
            {
                ((CCShaderSprite*)getSprite())->setValue1(getValue1());
                ((CCShaderSprite*)getSprite())->setValue2(getValue2());
                ((CCShaderSprite*)getSprite())->setValue3(getValue3());
                ((CCShaderSprite*)getSprite())->setValue4(getValue4());
                
                m_pSprite->visit();
            }
        }
        else if (mRenderTexture)
        {
            //m_pSprite->visit();
            mRenderTexture->setValue1(getValue1());
            mRenderTexture->setValue2(getValue2());
            mRenderTexture->setValue3(getValue3());
            mRenderTexture->setValue4(getValue4());

            //mRenderTexture->getSprite()->setPosition(m_targetWidth*0.5f*m_userScale, m_targetHeight*0.5f*m_userScale);
            //mRenderTexture->setVisible(true);
            mRenderTexture->visit();
        }
    }
    else{
        
        mSplashRT->visit();
        
//        staticFrameUpdateTime+=0.016;
//        if(staticFrameUpdateTime>2.0f)
//        {
//            setDrawOnceDirty();
//            mSplashRT->setDrawOnceDirty();
//            staticFrameUpdateTime = 0;
//        }
    }

	if (m_pGrid && m_pGrid->isActive())
	{
		m_pGrid->afterDraw(this);
	}

	kmGLPopMatrix();

	m_uOrderOfArrival = 0;
}

void CCShaderNode::setDrawOnceDirty()
{
    CCRenderTexture::setDrawOnceDirty();
    if(mSplashRT)mSplashRT->setDrawOnceDirty();
}

void CCShaderNode::draw()
{
	if (isVisible()&& m_bEnable)
		_prepareTexture();
}
void CCShaderNode::setContentSize(const CCSize& _contentSize){
	// here _contentSize is 300 * 300, but now it make render nothing, should fixed after 
	// use full screen size instead for test
	//const CCSize& contentSize = CCDirector::sharedDirector()->getWinSize();


	CCNode::setContentSize(_contentSize);
	initWithWidthAndHeight(_contentSize.width, _contentSize.height, kCCTexture2DPixelFormat_RGBA8888);
}

void CCShaderNode::clearUp()
{
	if (m_bInitialized){
		if (m_pSprite){
			m_pSprite->removeFromParent(); 
			CC_SAFE_RELEASE_NULL(m_pSprite);
		}
		if (mRenderTexture){
			mRenderTexture->removeFromParent();
			CC_SAFE_RELEASE_NULL(mRenderTexture);
		}
		CCRenderTexture::clearUp();
		m_bInitialized = false;
	}
}

void CCShaderNode::setEnable(bool enable, bool _clearUp /*= false*/)
{
	m_bEnable = enable;
	if (!enable && _clearUp){
		clearUp();
		CC_SAFE_RELEASE_NULL(mSplashRT);
	}
    if(enable){
        if(mSplashRT)mSplashRT->setDrawOnceDirty();
    }
    if(mSplashRT)mSplashRT->setVisible(enable);
}

void CCShaderNode::setShaderFile(std::string filename)
{
	if (getShaderFile() != filename)
	{
		m_shaderFile = filename;
		m_bInitDirty = true;
	}
}






NS_CC_END
