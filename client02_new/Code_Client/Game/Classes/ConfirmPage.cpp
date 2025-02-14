#include "ConfirmPage.h"
#include "GameMessages.h"
#include "MessageManager.h"

REGISTER_PAGE("ConfirmPage", ConfirmPage);

ConfirmPage::ConfirmPage(void)
{
	_clear();
}

ConfirmPage::~ConfirmPage(void)
{
}

void ConfirmPage::Enter(MainFrame*)
{
	CCB_FUNC(this, "mButtonMiddleNode", CCNode, setVisible(!mCancel));
	CCB_FUNC(this, "mButtonDoubleNode", CCNode, setVisible(mCancel));
	CCB_FUNC(this, "mDecisionTex", CCLabelTTF, setString(mMsg.c_str()));
	CCB_FUNC(this, "mTitle", CCLabelTTF, setString(mTitle.c_str()));
	CCB_FUNC(this, "mConfirmation", CCLabelTTF, setString(myesStr.c_str()));
	CCB_FUNC(this, "mCancel", CCLabelTTF, setString(mnoStr.c_str()));
	CCB_FUNC(this, "mCancelTxt", CCLabelTTF, setVisible(mCancel));
}

void ConfirmPage::Exit(MainFrame*)
{
	_clear();
}

void ConfirmPage::load()
{
	if (mHideBtn && !GamePrecedure::Get()->isInLoadingScene()) {
		loadCcbiFile("GeneralDecisionPopUp2.ccbi");
	}
	else {
		loadCcbiFile("GeneralDecisionPopUp.ccbi");
	}
}

void ConfirmPage::onMenuItemAction(const std::string& itemName, cocos2d::CCObject* sender)
{
	if ( itemName == "onConfirmation" || itemName == "onCancel" || itemName == "onClose")
	{
		if (mCancel)
			_popSelf();
		if ( mCb ) 
			mCb(itemName == "onConfirmation");
		if (mCancel)
			_clear();
	}
}

void ConfirmPage::showPage(std::string confirmMsg, std::string confirmTitle, ConfirmCallback cb, std::string yesStr, std::string noStr, bool canCancel, bool hideBtn)
{
	MsgMainFramePushPage gameMsg;
	gameMsg.pageName = "ConfirmPage";
	MessageManager::Get()->sendMessage(&gameMsg);

	ConfirmPage* page = dynamic_cast<ConfirmPage* >(CCBManager::Get()->getPage("ConfirmPage"));
	if ( page )
	{
		page->mMsg = confirmMsg;
		page->mTitle = confirmTitle;
		page->myesStr = Language::Get()->getString(yesStr).c_str();
		page->mnoStr = Language::Get()->getString(noStr).c_str();
		page->mCancel = canCancel;
		page->mCb = cb;
		page->mHideBtn = hideBtn;
	}
}

void ConfirmPage::refresh()
{
	CCB_FUNC(this, "mButtonMiddleNode", CCNode, setVisible(!mCancel));
	CCB_FUNC(this, "mButtonDoubleNode", CCNode, setVisible(mCancel));
	CCB_FUNC(this, "mDecisionTex", CCLabelTTF, setString(mMsg.c_str()));
	CCB_FUNC(this, "mTitle", CCLabelTTF, setString(mTitle.c_str()));
	CCB_FUNC(this, "mConfirmation", CCLabelTTF, setString(myesStr.c_str()));
	CCB_FUNC(this, "mCancel", CCLabelTTF, setString(mnoStr.c_str()));
	CCB_FUNC(this, "mCancelTxt", CCLabelTTF, setVisible(mCancel));
}

void ConfirmPage::_clear()
{
	mMsg = "";
	mCb = NULL;
}

void ConfirmPage::_popSelf()
{
	MsgMainFramePopPage msg;
	msg.pageName = "ConfirmPage";
	MessageManager::Get()->sendMessage(&msg);
	if (GamePrecedure::Get()->isInLoadingScene())
	{
		CCLog("AnnouncePage removeFromParent");
		removeFromParent();
	}
}