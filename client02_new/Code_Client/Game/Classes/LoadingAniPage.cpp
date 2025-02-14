

#include "stdafx.h"

#include "LoadingAniPage.h"
#include "ServerDateManager.h"
#include "StringConverter.h"
#include "DataTableManager.h"
#include "BlackBoard.h"

REGISTER_PAGE("LoadingAniPage",LoadingAniPage);
USING_NS_CC;

LoadingAniPage::LoadingAniPage(void)
{
	isInWaitingPage=false;
}

LoadingAniPage::~LoadingAniPage(void)
{
	isInWaitingPage=false;
}

void LoadingAniPage::load( void )
{

	loadCcbiFile("LoadingAni.ccbi");
	//refreshPage();	
}

void LoadingAniPage::onMenuItemAction( const std::string& itemName, cocos2d::CCObject* sender )
{

}

void LoadingAniPage::refreshPage( void )
{

}

void LoadingAniPage::Enter( MainFrame* )
{
	isInWaitingPage=true;
	this->runAnimation("Default Timeline");
}

void LoadingAniPage::setClarmPos()
{
	CCNode *_clarmNode = dynamic_cast<CCNode*>(getVariable("mClarmNode"));
	if (_clarmNode)
	{
		//_clarmNode->setPositionY(_clarmNode->getPositionY());

	}
}
void LoadingAniPage::onAnimationDone(const std::string& animationName){
	this->runAnimation("Default Timeline");
}

void LoadingAniPage::Execute( MainFrame* )
{
}

void LoadingAniPage::Exit( MainFrame* )
{
	isInWaitingPage=false;
}

void LoadingAniPage::showPage()
{
	bool quietRestart = ServerDateManager::Get()->getServerWillRestart();
	if (quietRestart)
	{
		CCLOG("@LoadingAniPage::showMsg -- quiet restart");
		return;
	}
	if(!isInWaitingPage)
	{
		MsgMainFrameCoverShow msg;
		msg.pageName="LoadingAniPage";
		MessageManager::Get()->sendMessage(&msg);

	}
}

void LoadingAniPage::hidePage()
{
	bool quietRestart = ServerDateManager::Get()->getServerWillRestart();
	if (quietRestart)
	{
		CCLOG("@LoadingAniPage::showMsg -- quiet restart");
		return;
	}
	isInWaitingPage=false;
	MsgMainFrameCoverHide msg;
	msg.pageName="LoadingAniPage";
	MessageManager::Get()->sendMessage(&msg);
}

void LoadingAniPage::runLoadingAni()
{
	isInWaitingPage=true;
	this->runAnimation("Default Timeline");
}

void LoadingAniPage::stopLoadingAni()
{
	isInWaitingPage=false;
}