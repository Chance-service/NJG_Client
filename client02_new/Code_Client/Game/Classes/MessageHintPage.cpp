
#include "stdafx.h"

#include "MessageHintPage.h"
#include "ServerDateManager.h"
#include "StringConverter.h"
#include "DataTableManager.h"
#include "BlackBoard.h"
#include "CCBManager.h"
#include "Language.h"
#include "GameMessages.h"
#include "CCBContainer.h"
#include "GamePrecedure.h"
#include "LoadingFrame.h"
#include "libOS.h"
REGISTER_PAGE("MessageHintPage", MessageHintPage);
USING_NS_CC;
#define HTMLLABELTAG 99
MessageHintPage::MessageHintPage(void)
	:mMsgString("")
{
	
}

MessageHintPage::~MessageHintPage(void)
{
}

void MessageHintPage::load( void )
{
	loadCcbiFile("LoadingSendCodeMessage.ccbi");
}

void MessageHintPage::unload(void)
{

}

void MessageHintPage::showHint( void )
{
	setVisible(true);
	

	//CCB_FUNC(this, "mLoadingHint", CCLabelTTF, setVisible(false));
	CCObject* bmNode = this->getVariable("mLoadingHint");
	if (bmNode)
	{
		CCLabelTTF* bmLabel = dynamic_cast<CCLabelTTF*>(bmNode);
		bmLabel->setString(mMsgString.c_str());
		bmLabel->setDimensions(CCSize(600, 270));
		/*std::string netStr = "<p style=\"margin:8px\" >" + mMsgString + "</p>";
		CCHTMLLabel* htmlLabel = CCHTMLLabel::createWithString(netStr.c_str(), CCSize(400, 200), "Helvetica");
		htmlLabel->setPosition(bmLabel->getPosition());
		htmlLabel->setAnchorPoint(bmLabel->getAnchorPoint());
		CCNode* parent = bmLabel->getParent();
		if (parent)
		{
			if (parent->getChildByTag(HTMLLABELTAG))
				parent->removeChildByTag(HTMLLABELTAG, true);
			parent->addChild(htmlLabel);
			htmlLabel->setTag(HTMLLABELTAG);
		}*/
	}
	CCObject* btnNode = this->getVariable("mBtn");
	if (btnNode) {
		CCNode* node = dynamic_cast<CCNode*>(btnNode);
		node->setVisible(mShowEnter);
	}

	/*CCB_FUNC(this, "mLoadingHint", CCLabelBMFont, setVisible(false));
	CCObject* bmNode = this->getVariable("mLoadingHint");
	if (bmNode)
	{
		CCLabelBMFont* bmLabel = dynamic_cast<CCLabelBMFont*>(bmNode);
		std::string netStr = "<p style=\"margin:8px\" >" + mMsgString + "</p>";
		CCHTMLLabel* htmlLabel = CCHTMLLabel::createWithString(netStr.c_str(),CCSize(400,200),"Helvetica");
		htmlLabel->setPosition(bmLabel->getPosition());
		htmlLabel->setAnchorPoint(bmLabel->getAnchorPoint());
		CCNode* parent = bmLabel->getParent();
		if (parent)
		{
			if (parent->getChildByTag(HTMLLABELTAG))
				parent->removeChildByTag(HTMLLABELTAG,true);
			parent->addChild(htmlLabel);
			htmlLabel->setTag(HTMLLABELTAG);
		}
	}	*/
}

void MessageHintPage::Enter( MainFrame* )
{
	loadCcbiFile("LoadingSendCodeMessage.ccbi");
	showHint( );
}

void MessageHintPage::Execute( MainFrame* )
{

}

void MessageHintPage::Exit( MainFrame* )
{

}
void MessageHintPage::onMenuItemAction( const std::string& itemName, cocos2d::CCObject* sender, int tag )
{
	if ((itemName == "onConfirmation") || (itemName == "onClose"))
	{
		onClose();
		//use libOS to boardcast message
		libOS::getInstance()->_boardcastMessageboxOK(tag);
	}
}

void MessageHintPage::onClose()
{
	if ( GamePrecedure::Get()->isInLoadingScene() )
	{
		setVisible(false);
		removeFromParent();
	}
	else
	{
		MsgMainFramePopPage msg;
		msg.pageName = "MessageHintPage";
		MessageManager::Get()->sendMessage(&msg);
	}
	
}


void MessageHintPage::Msg_Hint(const std::string& msgString,int tag/* = 0*/)
{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
	CCMessageBox(msgString.c_str(),Language::Get()->getString("@ShowMsgBoxTitle").c_str());
#else
	if ( GamePrecedure::Get()->isInLoadingScene() )
	{
		LoadingFrame* pLoadingFrame = GamePrecedure::Get()->getLoadingFrame();
		if (pLoadingFrame)
		{
			MessageHintPage* pMessagePage = dynamic_cast<MessageHintPage*>(CCBManager::Get()->getPage("MessageHintPage"));
			if ( pMessagePage && !pMessagePage->getParent() )
			{
				pMessagePage->setMsgString(msgString);
				pMessagePage->setListener(pMessagePage, tag);
				if (tag == 999) {
					pMessagePage->setShowEnter(false);
				}
				else {
					pMessagePage->setShowEnter(true);
				}

				//pMessagePage->load();
				State<MainFrame>* sta = dynamic_cast<State<MainFrame>* >(pMessagePage);
				if ( sta )
				{
					sta->Enter(NULL);
				}
				pLoadingFrame->addChild(pMessagePage);	

				libOS::getInstance()->setWaiting(false);//hide android waiting view
			}
		}
	}
	else
	{
		MessageHintPage* pMessagePage = dynamic_cast<MessageHintPage*>(CCBManager::Get()->getPage("MessageHintPage"));
		pMessagePage->setMsgString(msgString);
		pMessagePage->setListener(pMessagePage, tag);
		pMessagePage->setShowEnter(true);

		MsgMainFramePushPage msg;
		msg.pageName = "MessageHintPage";
		MessageManager::Get()->sendMessage(&msg);
	}
#endif
}