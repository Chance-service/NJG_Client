#include "GUI/CCMenuCCBFile.h"


const int CCMENUITEMCCBFILE_CCBTAG = 100;
const char* CCBMENU_NORMAL = "Normal";
const char* CCBMENU_DISABLE = "Disable";
const char* CCBMENU_TOUCHBEGIN = "TouchBegin";
const char* CCBMENU_TOUCHEND = "TouchEnd";
const char* CCBMENU_DRAGEND = "DragEnd";
NS_CC_EXT_BEGIN


CCMenuItemCCBFile* CCMenuItemCCBFile::create()
{
	CCMenuItemCCBFile *pRet = new CCMenuItemCCBFile();
	if (pRet && pRet->init())
	{
		pRet->autorelease();
		return pRet;
	}
	CC_SAFE_DELETE(pRet);
	return NULL;
}

void CCMenuItemCCBFile::setCCBFile(CCBFileNew* ccbfile)
{
	if (getChildByTag(CCMENUITEMCCBFILE_CCBTAG))
	{
		removeChildByTag(CCMENUITEMCCBFILE_CCBTAG);
	}
	if(!ccbfile)
	{
		CCMessageBox("Failed to loadCcbi file!","error");
	}
	if(!ccbfile->hasAnimation(CCBMENU_NORMAL))
	{
		std::string outstr = "ccbi menu item does NOT have a timeline \"normal\"! file:   " + ccbfile->getCCBFileName();
		//CCMessageBox(outstr.c_str(),"error");
	}
	ccbfile->setListener(this);
	mRunningTouchEnd = false;
	this->setContentSize(ccbfile->getContentSize());
	this->addChild(ccbfile,0,CCMENUITEMCCBFILE_CCBTAG);
	changeState(CCBMENU_NORMAL);
}


void CCMenuItemCCBFile::setEnabled( bool value )
{
	CCMenuItem::setEnabled(value);
	if(value)
		changeState(CCBMENU_NORMAL);	
	else
		if(!changeState(CCBMENU_DISABLE)) changeState(CCBMENU_NORMAL);
}

void CCMenuItemCCBFile::activate()
{
	if(!mRunningTouchEnd)
		CCMenuItem::activate();
}

void CCMenuItemCCBFile::selected()
{
	m_bSelected = true;
	mPreState = mState;
	changeState(CCBMENU_TOUCHBEGIN);
}

void CCMenuItemCCBFile::unselected()
{
	m_bSelected = false;
	mRunningTouchEnd = changeState(CCBMENU_TOUCHEND);
}

void CCMenuItemCCBFile::unselected_cancel()
{
	m_bSelected = false;
	if (mPreState)
	{
		changeState(mPreState);
		mPreState = NULL;
		return;
	}
	if(!changeState(CCBMENU_DRAGEND))
		changeState(CCBMENU_NORMAL);
}

bool CCMenuItemCCBFile::changeState( const char* state )
{
	if(mRunningTouchEnd)return false;

	CCBFileNew* filenode = getCCBFile();
	if(!filenode) return false;

	if(filenode->hasAnimation(state))
	{
		mState = state;
		filenode->runAnimation(state,true);
		return true;
	}
	else
		return false;
	
	
}

void CCMenuItemCCBFile::runExtraAnimation(char* name)
{
	CCBFileNew* filenode = getCCBFile();
	if(!filenode) return;

	if(filenode->hasAnimation(name))
	{
		filenode->stopAllActions();
		filenode->runAnimation(name,true);
	}
}

void CCMenuItemCCBFile::onAnimationDone( const std::string& animationName, CCBFileNew* ccbfile )
{
	if(animationName == CCBMENU_TOUCHEND)
	{
		mRunningTouchEnd = false;
		setEnabled(isEnabled());//do this to run next animation
		CCMenuItem::activate();
	}
	else if(animationName == CCBMENU_DRAGEND)
	{
		changeState(CCBMENU_NORMAL);
	}
}

CCBFileNew * CCMenuItemCCBFile::getCCBFile()
{
	CCNode* node = getChildByTag(CCMENUITEMCCBFILE_CCBTAG);
	if(!node) return 0;

	CCBFileNew* filenode = dynamic_cast<CCBFileNew*>(node);
	return filenode;
}

CCMenuItemCCBFile::CCMenuItemCCBFile()
{
	mPreState = NULL;
	mState = NULL;
}

CCMenuItemCCBFile::~CCMenuItemCCBFile()
{
	mPreState = NULL;
	mState = NULL;
}

NS_CC_EXT_END
