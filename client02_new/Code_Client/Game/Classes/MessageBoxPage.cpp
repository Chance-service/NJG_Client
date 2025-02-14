
#include "stdafx.h"

#include "MessageBoxPage.h"
#include "ServerDateManager.h"
#include "StringConverter.h"
#include "DataTableManager.h"
#include "BlackBoard.h"
#include "CCBManager.h"
#include "Language.h"
#include "GameMessages.h"

USING_NS_CC;
MessageBoxPage::MessageBoxPage(void)
{

}

MessageBoxPage::~MessageBoxPage(void)
{
}

void MessageBoxPage::load( void )
{
	loadCcbiFile("MessageBox.ccbi");
}

void MessageBoxPage::showMsg( std::string msgString, bool isHtml )
{
	
	bool quietRestart = ServerDateManager::Get()->getServerWillRestart();
	if (quietRestart)
	{
		CCLOG("@MessageBoxPage::showMsg -- quiet restart");
		return;
	}
	load();
	CCLabelTTF* message = dynamic_cast<CCLabelTTF* >(getVariable("mMsg"));
	CCHTMLLabel* htmlLabel = NULL;
	if (message)
	{
		message->removeAllChildrenWithCleanup(true);
		if (isHtml) {
			htmlLabel = CCHTMLLabel::createWithString(msgString.c_str(), CCSize(250.0f, 100.0f));
			//htmlLabel->setAnchorPoint(CCPoint(0.5f, 0.5f));
			htmlLabel->setTag(1234);
			message->setCascadeOpacityEnabled(true);
			message->addChild(htmlLabel);
			message->setString("");
		}
		else {
			message->setString(Language::Get()->getString(msgString).c_str());
		}

	}
	float contentWidth = 0.0f;
	if (isHtml && htmlLabel){
		contentWidth = htmlLabel->getContentSize().width;
	}
	else {
		contentWidth = message->getContentSize().width;
	}
	//CCScale9Sprite* img1 = dynamic_cast<CCScale9Sprite* >(getVariable("mLeftImg"));
	//if (img1)
	//{
	//	img1->setPositionX(contentWidth * -0.5f - 40);
	//}
	//CCScale9Sprite* img2 = dynamic_cast<CCScale9Sprite* >(getVariable("mRightImg"));
	//if (img2)
	//{
	//	img2->setPositionX(contentWidth * 0.5f + 40);
	//}

	MsgMainFrameMSGShow msg;
	MessageManager::Get()->sendMessage(&msg);
}

void MessageBoxPage::Enter( MainFrame* )
{
	this->stopAllActions();
	this->setPosition(0, 0);

	CCNode* root = dynamic_cast<CCNode*>(getVariable("mRootNode"));
	if (root)
	{
		CCArray* array = root->getChildren();
		for (unsigned int i = 0;i < array->count(); ++i)
		{
			cocos2d::extension::CCScale9Sprite* child = dynamic_cast<cocos2d::extension::CCScale9Sprite*>(array->objectAtIndex(i));
			if (child)
			{
				child->stopAllActions();
				child->setOpacity(255);
				child->runAction(CCSequence::create(CCDelayTime::create(/*3.0f*/1.0f),  
					CCFadeOut::create(0.3f),
					NULL));
				continue;
			}
		}
	}
	CCLabelTTF* msg = dynamic_cast<CCLabelTTF*>(getVariable("mMsg"));
	if (msg)
	{
		msg->stopAllActions();
		msg->setOpacity(255);
		msg->runAction(CCSequence::create(CCDelayTime::create(/*3.0f*/1.0f),
			CCFadeOut::create(0.3f),
			NULL));
		CCNode* child = msg->getChildByTag(1234);
		if (child) {
			child->stopAllActions();
			child->setOpacity(255);
			child->runAction(CCSequence::create(CCDelayTime::create(/*3.0f*/1.0f),
				CCFadeOut::create(0.3f),
				NULL));
		}
	}
	CCLabelTTF* title = dynamic_cast<CCLabelTTF*>(getVariable("mTitle"));
	if (title)
	{
		title->stopAllActions();
		title->setOpacity(255);
		title->runAction(CCSequence::create(CCDelayTime::create(/*3.0f*/1.0f),
			CCFadeOut::create(0.3f),
			NULL));
	}
}

void MessageBoxPage::Execute( MainFrame* )
{

}

void MessageBoxPage::Exit( MainFrame* )
{

}

void MessageBoxPage::Msg_Box(std::string msgString)
{
	MessageBoxPage::Get()->showMsg(msgString); 
}

void MessageBoxPage::Msg_Box_Lan( std::string msgString )
{
	MessageBoxPage::Get()->showMsg(Language::Get()->getString(msgString));
}

void MessageBoxPage::Msg_Box_Html(std::string msgString)
{
	MessageBoxPage::Get()->showMsg(Language::Get()->getString(msgString), true);
}

void MessageBoxPage::showMsgByErrCode(unsigned int errId)
{
	std::string msg; 
	const ErrMsgItem* item = ErrMsgTableManager::Get()->getErrMsgItemByID(errId);
	if (item)
	{
		msg = item->msgContent;
	}
	MessageBoxPage::Get()->showMsg(msg);
}
