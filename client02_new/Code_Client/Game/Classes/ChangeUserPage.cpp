
#include "stdafx.h"

#include "ChangeUserPage.h"
#include "StringConverter.h"
#include "BlackBoard.h"
#include "GamePlatform.h"
#include "SeverConsts.h"
#include "AnimMgr.h"

REGISTER_PAGE("ChangeUserPage", ChangeUserPage);
USING_NS_CC;
USING_NS_CC_EXT;
#define TAG_LABLE 10001
#define PWD_LEN_LIMIT 30
#define EDITBOXTAG 2000
#define CURSOR_TAG 66666
#define CURSOR_ICON "LoadingUI_JP/input_blink.png"

ChangeUserPage::ChangeUserPage(void) :mInputType(-1)
{
	bgNodeDefaultPosX = 0.0f;
	bgNodeDefaultPosY = 0.0f;
	isOpenKeyBoard = false;
    isMoveFullNode = false;

	mCodeEditBoxDelegate = new EditBoxDelegate();
	mPassWordEditBoxDelegate = new EditBoxDelegate();
	mCodeEditBoxDelegate->setCustom(this);
	mCodeEditBoxDelegate->setInputType(INPUT_CODE);
	mPassWordEditBoxDelegate->setCustom(this);
	mPassWordEditBoxDelegate->setInputType(INPUT_PWD);
}

ChangeUserPage::~ChangeUserPage(void)
{
	delete mCodeEditBoxDelegate;
	delete mPassWordEditBoxDelegate;
}

void ChangeUserPage::Enter(MainFrame*)
{
	//setVisible(false);
	libOS::getInstance()->registerListener(this);
	libPlatformManager::getPlatform()->registerListener(this);
	resetPageData();
	//loadConfigFile("Feedback.txt");
}
void ChangeUserPage::Execute(MainFrame*)
{

}

void ChangeUserPage::Exit(MainFrame*)
{

}

void ChangeUserPage::loadConfigFile(const std::string& announcementFile, bool isDownload)
{
	
}


void ChangeUserPage::onMenuItemAction(const std::string& itemName, cocos2d::CCObject* sender, int tag)
{
}

//***************************************************************************************

//***************************************************************************************
void ChangeUserPage::URLlabelCallback(IRichNode* root, IRichElement* ele, int _id)
{
	REleHTMLButton *button = dynamic_cast<REleHTMLButton*> (ele);
	if(button)
	{
		string strName = button->getName();
		string strValue = button->getValue();

		if(strName.compare("URL") == 0 && !strValue.empty())
		{
			std::string serverid = cocos2d::CCUserDefault::sharedUserDefault()->getStringForKey("JapanServrId", "unkonw");
			std::string playerid = cocos2d::CCUserDefault::sharedUserDefault()->getStringForKey("JapanPlayerId", "unkonw");
			std::string time = cocos2d::CCUserDefault::sharedUserDefault()->getStringForKey("JapanLastLoginTime", "unkonw");

			Json::Value data;
			data["serverid"] = Json::Value(serverid);
			data["playerid"] = Json::Value(playerid);
			data["time"] = Json::Value(time);
			data["version"] = Json::Value(SeverConsts::Get()->getServerVersion());

			string EmailInfo = data.toStyledString();
			libPlatformManager::getPlatform()->sendMessageG2P("G2P_SEND_EMAIL", EmailInfo);
		}
	}
	
}
void ChangeUserPage::onMenuItemAction(const std::string& itemName, cocos2d::CCObject* sender)
{
	if (itemName == "onClose" || itemName == "onCancel")
	{
		closePage();
	}
	else if(itemName == "onInPutData")
	{
		mInputType = INPUT_CODE;
		libOS::getInstance()->showInputbox(false, 0, PWD_LEN_LIMIT,mStrCode);

	}
	else if (itemName == "onInPutPassword")
	{
		mInputType = INPUT_PWD;
		libOS::getInstance()->showInputbox(false, 0, PWD_LEN_LIMIT, mStrPwd);

	}
	else if (itemName == "onConfirmation")
	{
		if (mPwdTextNode && mCodeTextNode)
		{
			if (mStrCode.length() == 0)
			{
				libPlatformManager::getPlatform()->sendMessageG2P("G2P_SHOW_TOAST", Language::Get()->getString("@DataTransferWasEmpty"));
			}
			else
			{
				if (2 == BlackBoard::getInstance()->PLATFORM_TYPE_FOR_LUA)
				{
					libOS::getInstance()->setWaiting(true);
				}
				Json::Value data;
				data["code"] = Json::Value(string(mStrCode));
				data["pwd"] = Json::Value(string(mStrPwd));

				libPlatformManager::getPlatform()->sendMessageG2P("G2P_DATA_TRANSFER", data.toStyledString());
			}

		}
	}
}
void ChangeUserPage::cursorNode(CCLabelTTF* labelNode, bool isShow)
{
	CCSprite* cursor = CCSprite::create(CURSOR_ICON);
	CCNode* nodeParent = labelNode->getParent();
	if (cursor && labelNode && nodeParent)
	{
		nodeParent->removeChildByTag(CURSOR_TAG, true);
		if (!isShow)
		{
			return;
		}
		float nHeight = labelNode->getContentSize().height * labelNode->getScaleY();
		float nWidth = labelNode->getContentSize().width * labelNode->getScaleX();
		std::string str = labelNode->getString();
		if (str.length() == 0)
		{
			nWidth = 0;
		}

		float posX = labelNode->getPositionX() + nWidth*(1 - labelNode->getAnchorPoint().x);
		float posY = labelNode->getPositionY();
		cursor->setTag(CURSOR_TAG);
		nodeParent->addChild(cursor);
		cursor->setPosition(ccp(posX + 2, posY));
		cursor->setAnchorPoint(labelNode->getAnchorPoint());
		AnimMgr::Get()->fadeInAndOut(cursor, 0.25);
	}
}

void ChangeUserPage::resetPageData()
{
	mStrCode = "";
	mStrPwd = "";
	mPwdTextNode = dynamic_cast<CCLabelTTF*>(getVariable("mPasswordTxt"));
	mCodeTextNode = dynamic_cast<CCLabelTTF*>(getVariable("mDataTxt"));
	mPwdHintNode = dynamic_cast<CCLabelTTF*>(getVariable("mPasswordHint"));
	mCodeHintNode = dynamic_cast<CCLabelTTF*>(getVariable("mDataHint"));
	mSprite9_Code = dynamic_cast<CCScale9Sprite*>(getVariable("mDataChoose"));
	mSprite9_Pwd = dynamic_cast<CCScale9Sprite*>(getVariable("mPasswordChoose"));
	if (mPwdTextNode && mCodeTextNode && mPwdHintNode && mCodeHintNode && mSprite9_Pwd && mSprite9_Code)
	{
		if(2 == BlackBoard::getInstance()->PLATFORM_TYPE_FOR_LUA)
		{
			//code editbox
			//_createEditBox(mCodeEditBoxDelegate,CCSizeMake(400,40),mCodeTextNode,mCodeTextNode->getPosition(),Language::Get()->getString("@DataHint"));
			//password editbox
			//cocos2d::extension::CCEditBox* passwordEditBox = _createEditBox(mPassWordEditBoxDelegate,CCSizeMake(400,40),mPwdTextNode,mPwdTextNode->getPosition(),Language::Get()->getString("@DataSetPasswordHint"));
			//passwordEditBox->setInputFlag(kEditBoxInputFlagPassword);
			mPwdHintNode->setVisible(false);
			mCodeHintNode->setVisible(false);
			CCB_FUNC(this,"mInputBtn",CCMenuItem,setEnabled(false));
			CCB_FUNC(this,"mInPutPasswordBtn",CCMenuItem,setEnabled(false));
		}
		else
		{

			CCNode *_pNode = dynamic_cast<CCNode*>(getVariable("mFullNode"));
			bgNodeDefaultPosX = _pNode->getPositionX();
			bgNodeDefaultPosY = _pNode->getPositionY();

			mPwdTextNode->setString("");
			mCodeTextNode->setString("");
			mPwdHintNode->setVisible(true);
			mCodeHintNode->setVisible(true);
		}
		mSprite9_Code->setVisible(false);
		mSprite9_Pwd->setVisible(false);
	}
	else
	{
		//重要提示！
		closePage();
	}
	
}
void ChangeUserPage::onInputChangeText(const std::string& content)
{
	CCLabelTTF* hintNode = NULL;
	CCLabelTTF* textNode = NULL;
	std::string tempContent = content;
	
	

	if (mInputType == INPUT_CODE)
	{
		mStrCode = tempContent;
		hintNode = mCodeHintNode;
		textNode = mCodeTextNode;

	}
	else if (mInputType == INPUT_PWD)
	{
		mStrPwd = tempContent;
		hintNode = mPwdHintNode;
		textNode = mPwdTextNode;

	}

	if (tempContent.length() > 0)
	{
		if (hintNode){
			hintNode->setVisible(false);
		}
		if (textNode){
			std::string text;
			if (mInputType == INPUT_PWD){
				for (int i = 0; i < tempContent.length(); i++)
				{
					if (i == tempContent.length() - 1)
					{
						text = text + tempContent.at(i);
					}
					else{
						text = text + "*";
					}
				}
				textNode->setString(text.c_str());
			}
			else{
				textNode->setString(tempContent.c_str());
			}
				
		}
	}
	else{
		if (hintNode){
			hintNode->setVisible(true);
		}
		if (textNode){
			textNode->setString("");
		}
	}
}
void ChangeUserPage::onOpenKeyboard()
{
	//isOpenKeyBoard = true;
	//if (keyBoardHeight < 300)   return;

	//isMoveFullNode = true;

	//CCNode *_pNode = dynamic_cast<CCNode*>(getVariable("mFullNode"));
	//
	//if (_pNode == NULL) return;
	////相對於螢幕解析度 鍵盤的高度，要轉換為遊戲邏輯高度
	//keyBoardHeight = keyBoardHeight / CCEGLView::sharedOpenGLView()->getScaleY();

	//CCPoint   convertPos = _pNode->getParent()->convertToNodeSpace(ccp(0, keyBoardHeight));

	//if (_pNode->getPositionY() == convertPos.y)   return;

	//CCArray *  actionArr = CCArray::create();

	//actionArr->addObject(CCMoveTo::create(0.3, ccp(bgNodeDefaultPosX, convertPos.y)));
	//_pNode->stopAllActions();
	//_pNode->runAction(CCSequence::create(actionArr));
}
void ChangeUserPage::OnKeyboardHightChange(int nHight)
{ 
	keyBoardHeight = nHight; 


	/*if (keyBoardHeight > 300 && isOpenKeyBoard  && !isMoveFullNode)
	{
		isMoveFullNode = true;
		onOpenKeyboard();
	}
*/

	isOpenKeyBoard = true;
	if (keyBoardHeight < 300)   return;

	isMoveFullNode = true;

	CCNode *_pNode = dynamic_cast<CCNode*>(getVariable("mFullNode"));

	if (_pNode == NULL) return;
	//相對於螢幕解析度 鍵盤的高度，要轉換為遊戲邏輯高度
	keyBoardHeight = keyBoardHeight / CCEGLView::sharedOpenGLView()->getScaleY();

	CCPoint   convertPos = _pNode->getParent()->convertToNodeSpace(ccp(0, keyBoardHeight));

	if (_pNode->getPositionY() == convertPos.y)   return;

	CCArray *  actionArr = CCArray::create();

	actionArr->addObject(CCMoveTo::create(0.3, ccp(bgNodeDefaultPosX, convertPos.y)));
	_pNode->stopAllActions();
	_pNode->runAction(CCSequence::create(actionArr));


}
void ChangeUserPage::onCloseKeyboard()
{
	if (mInputType == INPUT_CODE)
	{
		cursorNode(mCodeTextNode, false);
		mSprite9_Code->setVisible(false);
	}
	else{
		cursorNode(mPwdTextNode, false);
		mSprite9_Pwd->setVisible(false);
	}
	CCNode *_pNode = dynamic_cast<CCNode*>(getVariable("mFullNode"));
	if (_pNode == NULL) return;
	if (_pNode->getPositionY() == bgNodeDefaultPosY)   return;

	CCArray *  actionArr = CCArray::create();
	actionArr->addObject(CCMoveTo::create(0.2, ccp(bgNodeDefaultPosX, bgNodeDefaultPosY)));
	_pNode->stopAllActions();
	_pNode->runAction(CCSequence::create(actionArr));

	isMoveFullNode = false;
	isOpenKeyBoard = false;
	keyBoardHeight = 0.0f;
}
void ChangeUserPage::onInputboxEnter(const std::string& content)
{
	onInputChangeText(content);
	if (mInputType == INPUT_CODE)
	{
		cursorNode(mCodeTextNode, true);
		mSprite9_Code->setVisible(true);
	}
	else{
		cursorNode(mPwdTextNode, true);
		mSprite9_Pwd->setVisible(true);
	}

}

void ChangeUserPage::closePage()
{
	if ( GamePrecedure::Get()->isInLoadingScene() )
	{
		//setVisible(false);
		removeFromParent();
	}
	else
	{
		MsgMainFramePopPage msg;
		msg.pageName = "ChangeUserPage";
		MessageManager::Get()->sendMessage(&msg);
	}
	libOS::getInstance()->removeListener(this);
}

void ChangeUserPage::load(void)
{
	loadCcbiFile("DataTransferImportPopUp.ccbi");
}

std::string ChangeUserPage::onReceiveCommonMessage(const std::string& tag, const std::string& msg)
{
	if (tag == "P2G_DATA_TRANSFER")
	{
		Json::Reader jreader;
		Json::Value jvalue;
		jreader.parse(msg, jvalue, false);

		Json::Value jroot = jvalue;
		if (!jroot.empty() && !jroot["result"].empty() && !jroot["code"].empty())
		{
			std::string result = jroot["result"].asString();
			if (result == "1"){//成功
				libPlatformManager::getPlatform()->sendMessageG2P("G2P_SHOW_TOAST", Language::Get()->getString("@DataTransferSuccessful"));
				closePage();
			}
			else if (result == "0")//失敗
			{
				std::string code = jroot["code"].asString();
				if (code =="1"){//參數確實或者密碼長度的問題
					libPlatformManager::getPlatform()->sendMessageG2P("G2P_SHOW_TOAST", Language::Get()->getString("@DataTransferPasswordTooShort"));
				}
				else if (code == "2")//沒有找到該accode對應的帳號紀錄
				{
					libPlatformManager::getPlatform()->sendMessageG2P("G2P_SHOW_TOAST", Language::Get()->getString("@DataTransferWasWrong"));
				}
				else if (code == "3")//密碼錯誤
				{
					libPlatformManager::getPlatform()->sendMessageG2P("G2P_SHOW_TOAST", Language::Get()->getString("@DataTransferWasWrong"));
				}
				else if (code == "4")//該設備已經進行過了移行
				{
					libPlatformManager::getPlatform()->sendMessageG2P("G2P_SHOW_TOAST", Language::Get()->getString("@DataTransferAlreadyBeenOnce"));
				}
			}
		}
	}
	return "";
}

//cocos2d::extension::CCEditBox* ChangeUserPage::_createEditBox(CCEditBoxDelegate* delegate,const CCSize& size,CCNode* node,const CCPoint& pos,std::string plactHolder/*=""*/)
/*{
	cocos2d::extension::CCEditBox* editbox = 
		cocos2d::extension::CCEditBox::create(size,cocos2d::extension::CCScale9Sprite::create("UI/Mask/Image_Empty.png"));
	if (editbox)
	{
		editbox->setAnchorPoint(node->getAnchorPoint());
		editbox->setDelegate(delegate);
		editbox->setPosition(pos);
		editbox->setScale(node->getScale()*0.8);
		editbox->setFont("Barlow-SemiBold.ttf",26);
        editbox->setFontColor(ccc3(132,113,92));
		editbox->setPlaceholderFont("Barlow-SemiBold.ttf",26);
		editbox->setPlaceHolder(plactHolder.c_str());
		editbox->setMaxLength(PWD_LEN_LIMIT);
		node->getParent()->removeChildByTag(EDITBOXTAG,true);
		node->getParent()->addChild(editbox,1,EDITBOXTAG);
		node->setVisible(false);
	}
	return editbox;
}*/

void EditBoxDelegate::editBoxEditingDidBegin( CCEditBox* editBox )
{
	mCustom->onEditboxReturn(editBox,editBox->getText(),mInputType);
	if (mInputType == INPUT_CODE)
	{
		mCustom->setCodeFrameVisible(true);
	}
	else if(mInputType == INPUT_PWD)
	{
		mCustom->setPwdFrameVisible(true);
	}
}

void EditBoxDelegate::editBoxEditingDidEnd( CCEditBox* editBox )
{
	mCustom->onEditboxReturn(editBox,editBox->getText(),mInputType);
	if (mInputType == INPUT_CODE)
	{
		mCustom->setCodeFrameVisible(false);
	}
	else if(mInputType == INPUT_PWD)
	{
		mCustom->setPwdFrameVisible(false);
	}
}

void EditBoxDelegate::editBoxTextChanged( CCEditBox* editBox, const std::string& text )
{
	mCustom->onEditboxReturn(editBox,editBox->getText(),mInputType,true);
    
	if (mInputType == INPUT_CODE)
	{
        
		mCustom->setCodeFrameVisible(false);
	}
	else if(mInputType == INPUT_PWD)
	{
		mCustom->setPwdFrameVisible(false);
	}
}

void EditBoxDelegate::editBoxReturn( CCEditBox* editBox )
{
	mCustom->onEditboxReturn(editBox,editBox->getText(),mInputType);
}
void ChangeUserPage::onEditboxReturn( cocos2d::extension::CCEditBox* editbox,std::string text,InputType type,bool isChange/* = false*/ )
{
	mInputType = type;
	if (mInputType == INPUT_CODE)
	{
		mStrCode = text;
	}
	else if (mInputType == INPUT_PWD)
	{
		mStrPwd = text;
	}
	if(!isChange)
	{
		editbox->setText(text.c_str());
	}
}
