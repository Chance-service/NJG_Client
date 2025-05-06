/****************************************************************************
Copyright (c) 2010-2012 cocos2d-x.org
Copyright (c) 2008-2010 Ricardo Quesada

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
#include "CCLabelTTF.h"
#include "CCDirector.h"
#include "shaders/CCGLProgram.h"
#include "shaders/CCShaderCache.h"
#include "CCApplication.h"

#include "shaders/shaderhelper/CCTextShadowSH.h"
#include "shaders/shaderhelper/CCTextFadeSH.h"
#include "shaders/shaderhelper/CCTextBorderSH.h"
#include "textures/CCTextureCache.h"

NS_CC_BEGIN

//#if CC_USE_LA88_LABELS
//#define SHADER_PROGRAM kCCShader_PositionTextureColor
//#else
//#define SHADER_PROGRAM kCCShader_PositionTextureA8Color
//#endif

#define SHADER_TEXT_OUTLINE	kCCShader_Text_Outline
#define SHADER_TEXT_SHADOW	kCCShader_Text_Shadow
#define SHADER_TEXT_FADE	kCCShader_Text_Fade
#define SHADER_TEXT_BORDER	kCCShader_Text_Border

#define SHADER_PROGRAM kCCShader_PositionTextureColor

//
//CCLabelTTF
//
CCLabelTTF::CCLabelTTF()
: m_hAlignment(kCCTextAlignmentCenter)
, m_vAlignment(kCCVerticalTextAlignmentTop)
, m_pFontName(NULL)
, m_fFontSize(0.0)
, m_string("")
, m_shadowEnabled(false)
, m_strokeEnabled(false)
,m_textShadowFourDirEnabled(false)
, m_textFillColor(ccWHITE)
, m_fadeTexture(NULL)
,m_fShadowOffsetX(1.0)
,m_fShadowOffsetY(1.0)
,m_fShadowOffsetX2(1.0)
,m_fShadowOffsetY2(1.0)
,m_fShadowOffsetX3(1.0)
,m_fShadowOffsetY3(1.0)
,m_fShadowOffsetX4(1.0)
,m_fShadowOffsetY4(1.0)
{
	m_textShadowEnabled=false;
	m_textFadeEnabled=false;
	m_textBorderEnabled=false;
	m_textFadeImageURL="";
	m_shadowColor = ccc4f(1.0,1.0,1.0,1.0);
	m_borderColor = ccc4f(1.0,1.0,1.0,1.0);
}

CCLabelTTF::~CCLabelTTF()
{
    CC_SAFE_DELETE(m_pFontName);
	CC_SAFE_RELEASE(m_fadeTexture);
}

CCLabelTTF * CCLabelTTF::create()
{
    CCLabelTTF * pRet = new CCLabelTTF();
    if (pRet && pRet->init())
    {
        pRet->autorelease();
    }
    else
    {
        CC_SAFE_DELETE(pRet);
    }
    return pRet;
}

CCLabelTTF * CCLabelTTF::create(const char *string, const char *fontName, float fontSize)
{
    return CCLabelTTF::create(string, fontName, fontSize,
                              CCSizeZero, kCCTextAlignmentCenter, kCCVerticalTextAlignmentTop);
}

CCLabelTTF * CCLabelTTF::create(const char *string, const char *fontName, float fontSize,
                                const CCSize& dimensions, CCTextAlignment hAlignment)
{
    return CCLabelTTF::create(string, fontName, fontSize, dimensions, hAlignment, kCCVerticalTextAlignmentTop);
}

CCLabelTTF* CCLabelTTF::create(const char *string, const char *fontName, float fontSize,
                               const CCSize &dimensions, CCTextAlignment hAlignment, 
                               CCVerticalTextAlignment vAlignment,
							   bool bBold /*= false*/, bool bUnderline /*= false*/)
{
    CCLabelTTF *pRet = new CCLabelTTF();
    if(pRet && pRet->initWithString(string, fontName, fontSize, dimensions, hAlignment, vAlignment, bBold, bUnderline))
    {
        pRet->autorelease();
        return pRet;
    }
    CC_SAFE_DELETE(pRet);
    return NULL;
}

CCLabelTTF * CCLabelTTF::createWithFontDefinition(const char *string, ccFontDefinition &textDefinition)
{
    CCLabelTTF *pRet = new CCLabelTTF();
    if(pRet && pRet->initWithStringAndTextDefinition(string, textDefinition))
    {
        pRet->autorelease();
        return pRet;
    }
    CC_SAFE_DELETE(pRet);
    return NULL;
}

bool CCLabelTTF::init()
{
    return this->initWithString("", "Barlow SemiBold", 12);
}

bool CCLabelTTF::initWithString(const char *label, const char *fontName, float fontSize, 
                                const CCSize& dimensions, CCTextAlignment alignment)
{
    return this->initWithString(label, fontName, fontSize, dimensions, alignment, kCCVerticalTextAlignmentTop);
}

bool CCLabelTTF::initWithString(const char *label, const char *fontName, float fontSize)
{
    return this->initWithString(label, fontName, fontSize, 
                                CCSizeZero, kCCTextAlignmentLeft, kCCVerticalTextAlignmentTop);
}

bool CCLabelTTF::initWithString(const char *string, const char *fontName, float fontSize,
                                const cocos2d::CCSize &dimensions, CCTextAlignment hAlignment,
                                CCVerticalTextAlignment vAlignment,
								bool bBold /*= false*/, bool bUnderline /*= false*/)
{
    if (CCSprite::init())
    {
        // shader program
        this->setShaderProgram(CCShaderCache::sharedShaderCache()->programForKey(SHADER_PROGRAM));
        
        m_tDimensions = CCSizeMake(dimensions.width, dimensions.height);
        m_hAlignment  = hAlignment;
        m_vAlignment  = vAlignment;
		if (CCFileUtils::sharedFileUtils()->isFileExist(fontName)) {
			m_pFontName = new std::string(fontName);
		}
		else {
			m_pFontName = new std::string("Barlow SemiBold");
		}
        m_fFontSize   = fontSize;
        
        this->setStringWithFontInfo(string, bBold, bUnderline);
        
        return true;
    }
    
    return false;
}

bool CCLabelTTF::initWithStringAndTextDefinition(const char *string, ccFontDefinition &textDefinition)
{
    if (CCSprite::init())
    {
        // shader program
        this->setShaderProgram(CCShaderCache::sharedShaderCache()->programForKey(SHADER_PROGRAM));
        
        // prepare everythin needed to render the label
        _updateWithTextDefinition(textDefinition, false);
        
        // set the string
        this->setString(string);
        
        //
        return true;
    }
    else
    {
        return false;
    }
}

void CCLabelTTF::setString(const char *string)
{
    CCAssert(string != NULL, "Invalid string");
    
    if (m_string.compare(string))
    {
        m_string = string;
        
        this->updateTexture();
    }
}

void CCLabelTTF::setStringWithFontInfo(const char* string, bool bBold, bool bUnderline)
{
	CCAssert(string != NULL, "Invalid string");

	if (m_string.compare(string))
	{
		m_string = string;

		this->updateTexture(bBold, bUnderline);
	}
}

const char* CCLabelTTF::getString(void)
{
    return m_string.c_str();
}

const char* CCLabelTTF::description()
{
    return CCString::createWithFormat("<CCLabelTTF | FontName = %s, FontSize = %.1f>", m_pFontName->c_str(), m_fFontSize)->getCString();
}

CCTextAlignment CCLabelTTF::getHorizontalAlignment()
{
    return m_hAlignment;
}

void CCLabelTTF::setHorizontalAlignment(CCTextAlignment alignment)
{
    if (alignment != m_hAlignment)
    {
        m_hAlignment = alignment;
        
        // Force update
        if (m_string.size() > 0)
        {
            this->updateTexture();
        }
    }
}

CCVerticalTextAlignment CCLabelTTF::getVerticalAlignment()
{
    return m_vAlignment;
}

void CCLabelTTF::setVerticalAlignment(CCVerticalTextAlignment verticalAlignment)
{
    if (verticalAlignment != m_vAlignment)
    {
        m_vAlignment = verticalAlignment;
        
        // Force update
        if (m_string.size() > 0)
        {
            this->updateTexture();
        }
    }
}

CCSize CCLabelTTF::getDimensions()
{
    return m_tDimensions;
}

void CCLabelTTF::setDimensions(const CCSize &dim)
{
    if (dim.width != m_tDimensions.width || dim.height != m_tDimensions.height)
    {
        m_tDimensions = dim;
        
        // Force update
        if (m_string.size() > 0)
        {
            this->updateTexture();
        }
    }
}

float CCLabelTTF::getFontSize()
{
    return m_fFontSize;
}

void CCLabelTTF::setFontSize(float fontSize)
{
    if (m_fFontSize != fontSize)
    {
        m_fFontSize = fontSize;
        
        // Force update
        if (m_string.size() > 0)
        {
            this->updateTexture();
        }
    }
}

const char* CCLabelTTF::getFontName()
{
    return m_pFontName->c_str();
}

void CCLabelTTF::setFontName(const char *fontName)
{
    if (m_pFontName->compare(fontName))
    {
        delete m_pFontName;

#if CC_TARGET_PLATFORM == CC_PLATFORM_WIN32
		if (CCFileUtils::sharedFileUtils()->isFileExist(fontName)) {
			if (std::string(fontName).find("-Bold") != std::string::npos) {
				m_pFontName = new std::string("Barlow Bold");
			}
			else if (std::string(fontName).find("-Medium") != std::string::npos) {
				m_pFontName = new std::string("Barlow SemiBold");
			}
			else if (std::string(fontName).find("-Regular Regular") != std::string::npos) {
				m_pFontName = new std::string("Barlow");
			}
			else {
				m_pFontName = new std::string("Barlow SemiBold");
			}
		}
		else{
			m_pFontName = new std::string("Barlow SemiBold");
		}
#else
		//m_pFontName = new std::string("Barlow-SemiBold.ttf");
		//m_pFontName = new std::string(fontName);
		if (CCFileUtils::sharedFileUtils()->isFileExist(fontName)){
			m_pFontName = new std::string(fontName);
		}
		else{
			m_pFontName = new std::string("Barlow-SemiBold.ttf");
		}
#endif		        
        // Force update
        if (m_string.size() > 0)
        {
            this->updateTexture();
        }
    }
}

// Helper
bool CCLabelTTF::updateTexture(bool bBold /*= false*/, bool bUnderline /*= false*/)
{
    CCTexture2D *tex;
    tex = new CCTexture2D();
    
    if (!tex)
    {
        return false;
    }
	if (m_textShadowFourDirEnabled)
	{
		m_string = " " + m_string + " ";
	}
    #if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID) || (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
    
        ccFontDefinition texDef = _prepareTextDefinition(true);
        tex->initWithString( m_string.c_str(), &texDef );
    
    #else
    
        tex->initWithString( m_string.c_str(),
                            m_pFontName->c_str(),
                            m_fFontSize * CC_CONTENT_SCALE_FACTOR(),
                            CC_SIZE_POINTS_TO_PIXELS(m_tDimensions),
                            m_hAlignment,
							m_vAlignment,
							bBold,
							bUnderline);
    #endif
    // set the texture
    this->setTexture(tex);
    // release it
    tex->release();
    
    // set the size in the sprite
    CCRect rect =CCRectZero;
    rect.size   = m_pobTexture->getContentSize();
	rect.size.height += 2;
    this->setTextureRect(rect);
    
    //ok
    return true;
}

void CCLabelTTF::enableShadow(const CCSize &shadowOffset, float shadowOpacity, float shadowBlur, bool updateTexture)
{
    #if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID) || (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
    
        bool valueChanged = false;
        
        if (false == m_shadowEnabled)
        {
            m_shadowEnabled = true;
            valueChanged    = true;
        }
        
        if ( (m_shadowOffset.width != shadowOffset.width) || (m_shadowOffset.height!=shadowOffset.height) )
        {
            m_shadowOffset.width  = shadowOffset.width;
            m_shadowOffset.height = shadowOffset.height;
            
            valueChanged = true;
        }
        
        if (m_shadowOpacity != shadowOpacity )
        {
            m_shadowOpacity = shadowOpacity;
            valueChanged = true;
        }

        if (m_shadowBlur    != shadowBlur)
        {
            m_shadowBlur = shadowBlur;
            valueChanged = true;
        }
        
        
        if ( valueChanged && updateTexture )
        {
            this->updateTexture();
        }
    
    #else
        CCLOGERROR("Currently only supported on iOS and Android!");
    #endif
    
}

void CCLabelTTF::disableShadow(bool updateTexture)
{
    #if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID) || (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
    
        if (m_shadowEnabled)
        {
            m_shadowEnabled = false;
    
            if (updateTexture)
                this->updateTexture();
            
        }
    
    #else
        CCLOGERROR("Currently only supported on iOS and Android!");
    #endif
}

void CCLabelTTF::enableStroke(const ccColor3B &strokeColor, float strokeSize, bool updateTexture)
{
    #if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID) || (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
    
        bool valueChanged = false;
        
        if(m_strokeEnabled == false)
        {
            m_strokeEnabled = true;
            valueChanged = true;
        }
        
        if ( (m_strokeColor.r != strokeColor.r) || (m_strokeColor.g != strokeColor.g) || (m_strokeColor.b != strokeColor.b) )
        {
            m_strokeColor = strokeColor;
            valueChanged = true;
        }
        
        if (m_strokeSize!=strokeSize)
        {
            m_strokeSize = strokeSize;
            valueChanged = true;
        }
        
        if ( valueChanged && updateTexture )
        {
            this->updateTexture();
        }
    
    #else
        CCLOGERROR("Currently only supported on iOS and Android!");
    #endif
    
}

void CCLabelTTF::disableStroke(bool updateTexture)
{
    #if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID) || (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
    
        if (m_strokeEnabled)
        {
            m_strokeEnabled = false;
            
            if (updateTexture)
                this->updateTexture();
        }
    
    #else
        CCLOGERROR("Currently only supported on iOS and Android!");
    #endif
    
}

void CCLabelTTF::setFontFillColor(const ccColor3B &tintColor, bool updateTexture)
{
    #if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID) || (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
        if (m_textFillColor.r != tintColor.r || m_textFillColor.g != tintColor.g || m_textFillColor.b != tintColor.b)
        {
            m_textFillColor = tintColor;
            
            if (updateTexture)
                this->updateTexture();
        }
    #else
        CCLOGERROR("Currently only supported on iOS and Android!");
    #endif
}

void CCLabelTTF::setTextDefinition(ccFontDefinition *theDefinition)
{
    if (theDefinition)
    {
        _updateWithTextDefinition(*theDefinition, true);
    }
}

ccFontDefinition *CCLabelTTF::getTextDefinition()
{
    ccFontDefinition *tempDefinition = new ccFontDefinition;
    *tempDefinition = _prepareTextDefinition(false);
    return tempDefinition;
}

void CCLabelTTF::_updateWithTextDefinition(ccFontDefinition & textDefinition, bool mustUpdateTexture)
{
    m_tDimensions = CCSizeMake(textDefinition.m_dimensions.width, textDefinition.m_dimensions.height);
    m_hAlignment  = textDefinition.m_alignment;
    m_vAlignment  = textDefinition.m_vertAlignment;
    
	m_pFontName = new std::string("Barlow SemiBold"); //new std::string(textDefinition.m_fontName);
    m_fFontSize   = textDefinition.m_fontSize;
    
    
    // shadow
    if ( textDefinition.m_shadow.m_shadowEnabled )
    {
        enableShadow(textDefinition.m_shadow.m_shadowOffset, textDefinition.m_shadow.m_shadowOpacity, textDefinition.m_shadow.m_shadowBlur, false);
    }
    
    // stroke
    if ( textDefinition.m_stroke.m_strokeEnabled )
    {
        enableStroke(textDefinition.m_stroke.m_strokeColor, textDefinition.m_stroke.m_strokeSize, false);
    }
    
    // fill color
    setFontFillColor(textDefinition.m_fontFillColor, false);
    
    if (mustUpdateTexture)
        updateTexture();
}

ccFontDefinition CCLabelTTF::_prepareTextDefinition(bool adjustForResolution)
{
    ccFontDefinition texDef;
    
    if (adjustForResolution)
        texDef.m_fontSize       =  m_fFontSize * CC_CONTENT_SCALE_FACTOR();
    else
        texDef.m_fontSize       =  m_fFontSize;
    
    texDef.m_fontName       = *m_pFontName;
    texDef.m_alignment      =  m_hAlignment;
    texDef.m_vertAlignment  =  m_vAlignment;
    
    
    if (adjustForResolution)
        texDef.m_dimensions     =  CC_SIZE_POINTS_TO_PIXELS(m_tDimensions);
    else
        texDef.m_dimensions     =  m_tDimensions;
    
    
    // stroke
    if ( m_strokeEnabled )
    {
        texDef.m_stroke.m_strokeEnabled = true;
        texDef.m_stroke.m_strokeColor   = m_strokeColor;
        
        if (adjustForResolution)
            texDef.m_stroke.m_strokeSize = m_strokeSize * CC_CONTENT_SCALE_FACTOR();
        else
            texDef.m_stroke.m_strokeSize = m_strokeSize;
        
        
    }
    else
    {
        texDef.m_stroke.m_strokeEnabled = false;
    }
    
    
    // shadow
    if ( m_shadowEnabled )
    {
        texDef.m_shadow.m_shadowEnabled         = true;
        texDef.m_shadow.m_shadowBlur            = m_shadowBlur;
        texDef.m_shadow.m_shadowOpacity         = m_shadowOpacity;
        
        if (adjustForResolution)
            texDef.m_shadow.m_shadowOffset = CC_SIZE_POINTS_TO_PIXELS(m_shadowOffset);
        else
            texDef.m_shadow.m_shadowOffset = m_shadowOffset;
    }
    else
    {
        texDef.m_shadow.m_shadowEnabled = false;
    }
    
    // text tint
    texDef.m_fontFillColor = m_textFillColor;
    
    return texDef;
}

void CCLabelTTF::setTextShadowEnabled(bool textShadowEnabled)
{
	this->m_textShadowEnabled=textShadowEnabled;
}

bool CCLabelTTF::getTextShadowEnabled()
{
	return m_textShadowEnabled;
}

void CCLabelTTF::setTextFadeEnabled(bool textFadeEnabled)
{
	this->m_textFadeEnabled=textFadeEnabled;
}

bool CCLabelTTF::getTextFadeEnabled()
{
	return m_textFadeEnabled;
}

void CCLabelTTF::setTextBorderEnabled(bool textBorderEnabled)
{
	this->m_textBorderEnabled=textBorderEnabled;
}

void CCLabelTTF::setTextShadowColor(float _r, float _g, float _b, float _a)
{
	m_shadowColor = ccc4f(_r,_g,_b,_a);
}

void CCLabelTTF::setTextBorderColor(float _r, float _g, float _b, float _a)
{
	m_borderColor = ccc4f(_r,_g,_b,_a);
}

bool CCLabelTTF::getTextBorderEnabled()
{
	return m_textBorderEnabled;
}

void CCLabelTTF::setTextShadowFourDirEnabled(bool fourDirEnable){
	m_textShadowFourDirEnabled = fourDirEnable;
}
bool CCLabelTTF::getTextShadowFourDirEnabled(){
	return m_textShadowFourDirEnabled;
}

void CCLabelTTF::setTexShadowOffset(float shadowOffsetX,float shadowOffsetY){
	m_fShadowOffsetX = shadowOffsetX;
	m_fShadowOffsetY = shadowOffsetY;

}

void CCLabelTTF::setTexShadowOffset2(float shadowOffsetX,float shadowOffsetY){
	m_fShadowOffsetX2 = shadowOffsetX;
	m_fShadowOffsetY2 = shadowOffsetY;

}

void CCLabelTTF::setTexShadowOffset3(float shadowOffsetX,float shadowOffsetY){
	m_fShadowOffsetX3 = shadowOffsetX;
	m_fShadowOffsetY3 = shadowOffsetY;

}

void CCLabelTTF::setTexShadowOffset4(float shadowOffsetX,float shadowOffsetY){
	m_fShadowOffsetX4 = shadowOffsetX;
	m_fShadowOffsetY4 = shadowOffsetY;

}

void CCLabelTTF::setFadeTexture(CCTexture2D * tex){
	if (tex)
	{
		tex->retain();
		if (m_fadeTexture)
		{
			m_fadeTexture->release();
		}
		m_fadeTexture = tex;
		
	}	
}

void CCLabelTTF::setTextFadeImageURL(std::string fadeImageUrl)
{
	this->m_textFadeEnabled=true;
	this->m_textFadeImageURL=fadeImageUrl;

	if (m_fadeTexture)
	{
		m_fadeTexture->release();
	}
	m_fadeTexture = CCTextureCache::sharedTextureCache()->addImage(m_textFadeImageURL.c_str());
	m_fadeTexture->retain();
}

void CCLabelTTF::renderShadow(void)
{
	if (m_pobTexture == NULL)
	{
		return;
	}
	
	//CCTextShadowSH t_shader_helper(CCShaderCache::sharedShaderCache()->programForKey(SHADER_TEXT_OUTLINE));
	//t_shader_helper.init();
	//t_shader_helper.setColor(m_shadowColor.r,m_shadowColor.g,m_shadowColor.b,m_shadowColor.a);
	//float offsetx = m_fShadowOffsetX/m_pobTexture->getPixelsWide();
	//float offsety = m_fShadowOffsetY/m_pobTexture->getPixelsWide();
	//t_shader_helper.setOff(offsetx,offsety);
	//t_shader_helper.begin();
	//glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
	//CC_INCREMENT_GL_DRAWS(1);
	
	//four direction offset to mimic the bord effect
	if (m_textShadowFourDirEnabled)
	{
		CCTextShadowSH t_shader_helper(CCShaderCache::sharedShaderCache()->programForKey(SHADER_TEXT_SHADOW));
		t_shader_helper.init();
		t_shader_helper.setColor(m_shadowColor.r, m_shadowColor.g, m_shadowColor.b, m_shadowColor.a);
		float offsetx = m_fShadowOffsetX / m_pobTexture->getPixelsWide();
		float offsety = m_fShadowOffsetY / m_pobTexture->getPixelsHigh();
		t_shader_helper.setOff(offsetx, offsety);
		t_shader_helper.begin();
		glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);

		offsetx = m_fShadowOffsetX / m_pobTexture->getPixelsWide();
		offsety = m_fShadowOffsetY / m_pobTexture->getPixelsHigh();
		if (offsetx < 0) {
			offsetx *= -1;
		}
		t_shader_helper.setOff(offsetx, offsety * 0.1);
		t_shader_helper.begin();
		glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);

		offsetx = m_fShadowOffsetX2 / m_pobTexture->getPixelsWide();
		offsety = m_fShadowOffsetY2 / m_pobTexture->getPixelsHigh();
		if (offsetx > 0) {
			offsetx *= -1;
		}
		t_shader_helper.setOff(offsetx, offsety * 0.1);
		t_shader_helper.begin();
		glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);

		offsetx = m_fShadowOffsetX3 / m_pobTexture->getPixelsWide();
		offsety = m_fShadowOffsetY3 / m_pobTexture->getPixelsHigh();
		if (offsety < 0) {
			offsety *= -1;
		}
		t_shader_helper.setOff(offsetx * 0.1, offsety);
		t_shader_helper.begin();
		glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);

		offsetx = m_fShadowOffsetX4 / m_pobTexture->getPixelsWide();
		offsety = m_fShadowOffsetY4 / m_pobTexture->getPixelsHigh();
		if (offsety > 0) {
			offsety *= -1;
		}
		t_shader_helper.setOff(offsetx * 0.1, offsety);
		t_shader_helper.begin();
		glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);

		offsetx = m_fShadowOffsetX2 / m_pobTexture->getPixelsWide();
		offsety = m_fShadowOffsetY2 / m_pobTexture->getPixelsHigh();
		t_shader_helper.setOff(offsetx, offsety);
		t_shader_helper.begin();
		glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
		
		offsetx = m_fShadowOffsetX3 / m_pobTexture->getPixelsWide();
		offsety = m_fShadowOffsetY3 / m_pobTexture->getPixelsHigh();
		t_shader_helper.setOff(offsetx, offsety);
		t_shader_helper.begin();
		glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
		
		offsetx = m_fShadowOffsetX4 / m_pobTexture->getPixelsWide();
		offsety = m_fShadowOffsetY4 / m_pobTexture->getPixelsHigh();
		t_shader_helper.setOff(offsetx, offsety);
		t_shader_helper.begin();
		glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);

		//CCTextShadowSH t_shader_helper(CCShaderCache::sharedShaderCache()->programForKey(SHADER_TEXT_OUTLINE));
		//t_shader_helper.init();
		//t_shader_helper.setColor(m_shadowColor.r, m_shadowColor.g, m_shadowColor.b, m_shadowColor.a);
		//float offsetx = abs(m_fShadowOffsetX) / m_pobTexture->getPixelsWide();
		//float offsety = abs(m_fShadowOffsetY) / m_pobTexture->getPixelsHigh();
		//t_shader_helper.setOff(offsetx, offsety);
		//t_shader_helper.begin();
		//glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);

		CC_INCREMENT_GL_DRAWS(8);

		t_shader_helper.end();
	}
	else
	{
		CCTextShadowSH t_shader_helper(CCShaderCache::sharedShaderCache()->programForKey(SHADER_TEXT_SHADOW));
		t_shader_helper.init();
		t_shader_helper.setColor(m_shadowColor.r, m_shadowColor.g, m_shadowColor.b, m_shadowColor.a);
		float offsetx = m_fShadowOffsetX / m_pobTexture->getPixelsWide();
		float offsety = m_fShadowOffsetY / m_pobTexture->getPixelsHigh();
		t_shader_helper.setOff(offsetx, offsety);
		t_shader_helper.begin();
		glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
		CC_INCREMENT_GL_DRAWS(1);

		t_shader_helper.end();
	}
	//t_shader_helper.end();

	CCShaderHelper t_ori_shader(CCShaderCache::sharedShaderCache()->programForKey(kCCShader_PositionTextureColor));
	t_ori_shader.init();
	t_ori_shader.begin();
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
	t_ori_shader.end();
	CC_INCREMENT_GL_DRAWS(1);
}

void CCLabelTTF::renderFade(void)
{
	if (m_pobTexture == NULL || m_fadeTexture == NULL)
	{
		return ;
	}
	
	CCTextFadeSH t_shader_helper(CCShaderCache::sharedShaderCache()->programForKey(kCCShader_Text_Fade));
	t_shader_helper.init();
	t_shader_helper.setSrcTexture(m_pobTexture);
	t_shader_helper.setFadeTexture(m_fadeTexture);
	t_shader_helper.begin();
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
	t_shader_helper.end();
	CC_INCREMENT_GL_DRAWS(1);
}

void CCLabelTTF::renderBorder(void)
{
	CCTextBorderSH tshaderHelper(CCShaderCache::sharedShaderCache()->programForKey(kCCShader_Text_Border));
	tshaderHelper.init();
	static float tAlph = 0.0;
	tshaderHelper.setBorderColor(m_borderColor.r, m_borderColor.g, m_borderColor.b, m_borderColor.a);
	tshaderHelper.setBorderWidth(2.0 / m_pobTexture->getContentSize().width, 2.0 / m_pobTexture->getContentSize().height);
	tAlph+= 0.0005;
	if(tAlph>1.0)
		tAlph = 0.0;
	tshaderHelper.begin();

	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);

	tshaderHelper.end();
	CC_INCREMENT_GL_DRAWS(1);
}

void CCLabelTTF::draw(void)
{
	CC_PROFILER_START_CATEGORY(kCCProfilerCategorySprite, "CCSprite - draw");

	CCAssert(!m_pobBatchNode, "If CCSprite is being rendered by CCSpriteBatchNode, CCSprite#draw SHOULD NOT be called");

	CC_NODE_DRAW_SETUP();

	//ccGLBlendFunc(m_sBlendFunc.src, m_sBlendFunc.dst);
	glBlendFuncSeparate(m_sBlendFunc.src, m_sBlendFunc.dst, m_sBlendFunc.src, m_sBlendFunc.dst);

	if(m_pobTexture)
		ccGLBindTexture2D(m_pobTexture->getName());
	ccGLEnableVertexAttribs(kCCVertexAttribFlag_PosColorTex);

#define kQuadSize sizeof(m_sQuad.bl)
#ifdef EMSCRIPTEN
	long offset = 0;
	setGLBufferData(&m_sQuad, 4 * kQuadSize, 0);
#else
	long offset = (long)&m_sQuad;
#endif // EMSCRIPTEN

	// vertex
	int diff = offsetof(ccV3F_C4B_T2F, vertices);
	glVertexAttribPointer(kCCVertexAttrib_Position, 3, GL_FLOAT, GL_FALSE, kQuadSize, (void*)(offset + diff));

	// texCoods
	diff = offsetof(ccV3F_C4B_T2F, texCoords);
	glVertexAttribPointer(kCCVertexAttrib_TexCoords, 2, GL_FLOAT, GL_FALSE, kQuadSize, (void*)(offset + diff));

	// color
	diff = offsetof(ccV3F_C4B_T2F, colors);
	glVertexAttribPointer(kCCVertexAttrib_Color, 4, GL_UNSIGNED_BYTE, GL_TRUE, kQuadSize, (void*)(offset + diff));

	if(m_textBorderEnabled/* && false*/)
	{
		renderBorder();
	}

	if (m_textShadowEnabled)
	{
		renderShadow();

	}

	if (m_textFadeEnabled)
	{
		renderFade();
	}

	

	if(!m_textShadowEnabled&&!m_textFadeEnabled&&!m_textBorderEnabled)
	{
		glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
		CC_INCREMENT_GL_DRAWS(1);
	}

	CHECK_GL_ERROR_DEBUG();


#if CC_SPRITE_DEBUG_DRAW == 1
	// draw bounding box
	CCPoint vertices[4] = {
		ccp(m_sQuad.tl.vertices.x, m_sQuad.tl.vertices.y),
		ccp(m_sQuad.bl.vertices.x, m_sQuad.bl.vertices.y),
		ccp(m_sQuad.br.vertices.x, m_sQuad.br.vertices.y),
		ccp(m_sQuad.tr.vertices.x, m_sQuad.tr.vertices.y),
	};
	ccDrawPoly(vertices, 4, true);
	CC_INCREMENT_GL_DRAWS(1);
#elif CC_SPRITE_DEBUG_DRAW == 2
	// draw texture box
	CCSize s = this->getTextureRect().size;
	CCPoint offsetPix = this->getOffsetPosition();
	CCPoint vertices[4] = {
		ccp(offsetPix.x, offsetPix.y), ccp(offsetPix.x + s.width, offsetPix.y),
		ccp(offsetPix.x + s.width, offsetPix.y + s.height), ccp(offsetPix.x, offsetPix.y + s.height)
	};
	ccDrawPoly(vertices, 4, true);
	CC_INCREMENT_GL_DRAWS(1);
#endif // CC_SPRITE_DEBUG_DRAW


	CC_PROFILER_STOP_CATEGORY(kCCProfilerCategorySprite, "CCSprite - draw");
}

NS_CC_END
