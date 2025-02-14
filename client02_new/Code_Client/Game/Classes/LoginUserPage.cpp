
#include "stdafx.h"

#include "LoginUserPage.h"
#include "StringConverter.h"
#include "BlackBoard.h"
#include "GamePlatform.h"
#include "SeverConsts.h"
#include "AnimMgr.h"
#include "MessageHintPage.h"
#include "Lua_EcchiGamerSDKBridge.h"

REGISTER_PAGE("LoginUserPage", LoginUserPage);
USING_NS_CC;
USING_NS_CC_EXT;
#define TAG_LABLE 10001
#define PWD_LEN_LIMIT 12
#define USER_LEN_LIMIT 100
#define EDITBOXTAG 2000
#define CURSOR_TAG 66666
#define CURSOR_ICON "LoadingUI_JP/input_blink.png"

LoginUserPage::LoginUserPage(void) :mInputType(-1)
{
	bgNodeDefaultPosX = 0.0f;
	bgNodeDefaultPosY = 0.0f;
	isOpenKeyBoard = false;
    isMoveFullNode = false;

	mCodeEditBoxDelegate = new EditUIDelegate();
	mPassWordEditBoxDelegate = new EditUIDelegate();
	mRegIDEditBoxDelegate = new EditUIDelegate();
	mRegPwdEditBoxDelegate = new EditUIDelegate();
	mRegAgainEditBoxDelegate = new EditUIDelegate();

	mCodeEditBoxDelegate->setCustom(this);
	mCodeEditBoxDelegate->setInputType(INPUT_CODE);
	mPassWordEditBoxDelegate->setCustom(this);
	mPassWordEditBoxDelegate->setInputType(INPUT_PWD);

	mRegIDEditBoxDelegate->setCustom(this);
	mRegIDEditBoxDelegate->setInputType(INPUT_RegID);
	mRegPwdEditBoxDelegate->setCustom(this);
	mRegPwdEditBoxDelegate->setInputType(INPUT_RegPwd);
	mRegAgainEditBoxDelegate->setCustom(this);
	mRegAgainEditBoxDelegate->setInputType(INPUT_RegAgain);
}

LoginUserPage::~LoginUserPage(void)
{
	delete mCodeEditBoxDelegate;
	delete mPassWordEditBoxDelegate;
	delete mRegIDEditBoxDelegate;
	delete mRegPwdEditBoxDelegate;
	delete mRegAgainEditBoxDelegate;
}

void LoginUserPage::Enter(MainFrame*)
{
	//setVisible(false);
	libOS::getInstance()->registerListener(this);
	libPlatformManager::getPlatform()->registerListener(this);
	resetPageData();
	//loadConfigFile("Feedback.txt");
}
void LoginUserPage::Execute(MainFrame*)
{

}

void LoginUserPage::Exit(MainFrame*)
{

}

void LoginUserPage::loadConfigFile(const std::string& announcementFile, bool isDownload)
{
	
}


void LoginUserPage::onMenuItemAction(const std::string& itemName, cocos2d::CCObject* sender, int tag)
{
}

//***************************************************************************************

//***************************************************************************************
void LoginUserPage::URLlabelCallback(IRichNode* root, IRichElement* ele, int _id)
{
	//REleHTMLButton *button = dynamic_cast<REleHTMLButton*> (ele);
	//if(button)
	//{
	//	string strName = button->getName();
	//	string strValue = button->getValue();

	//	if(strName.compare("URL") == 0 && !strValue.empty())
	//	{
	//		std::string serverid = cocos2d::CCUserDefault::sharedUserDefault()->getStringForKey("JapanServrId", "unkonw");
	//		std::string playerid = cocos2d::CCUserDefault::sharedUserDefault()->getStringForKey("JapanPlayerId", "unkonw");
	//		std::string time = cocos2d::CCUserDefault::sharedUserDefault()->getStringForKey("JapanLastLoginTime", "unkonw");

	//		Json::Value data;
	//		data["serverid"] = Json::Value(serverid);
	//		data["playerid"] = Json::Value(playerid);
	//		data["time"] = Json::Value(time);
	//		data["version"] = Json::Value(SeverConsts::Get()->getServerVersion());

	//		string EmailInfo = data.toStyledString();
	//		libPlatformManager::getPlatform()->sendMessageG2P("G2P_SEND_EMAIL", EmailInfo);
	//	}
	//}
	
}
void LoginUserPage::onMenuItemAction(const std::string& itemName, cocos2d::CCObject* sender)
{
	if (itemName == "onClose" || itemName == "onCancel")
	{
		closePage();
	}
	else if (itemName == "onLoginTabBtn")
	{
		setInputMode(LoginMode);
	}
	else if (itemName == "onRegisterTabBtn")
	{
		setInputMode(RegisterMode);
	}
	else if(itemName == "onLoginMailContent")
	{
		mInputType = INPUT_CODE;
		libOS::getInstance()->showInputbox(false, 0, USER_LEN_LIMIT, mStrCode);
		defaultInGame = false;

	}
	else if (itemName == "onLoginPassContent")
	{
		mInputType = INPUT_PWD;
		libOS::getInstance()->showInputbox(false, 0, PWD_LEN_LIMIT, mStrPwd);
		defaultInGame = false;

	}
	else if (itemName == "onRegisterMailContent")
	{
		mInputType = INPUT_RegID;
		libOS::getInstance()->showInputbox(false, 0, USER_LEN_LIMIT, mStrReg_ID);

	}
	else if (itemName == "onRegisterPassContent")
	{
		mInputType = INPUT_RegPwd;
		libOS::getInstance()->showInputbox(false, 0, PWD_LEN_LIMIT, mStrReg_Pwd);

	}
	else if (itemName == "onRegisterConfirmContent")
	{
		mInputType = INPUT_RegAgain;
		libOS::getInstance()->showInputbox(false, 0, PWD_LEN_LIMIT, mStrReg_Again);

	}
	else if (itemName == "onKeyInBtn")
	{
		if (mTabMode == LoginMode)
		{
			LoadingFrame* pLoadingFrame = GamePrecedure::Get()->getLoadingFrame();
			if (pLoadingFrame)
			{
				if (defaultInGame)
				{
					pLoadingFrame->onEnterGame();
				}
				else
				{
					if (!SeverConsts::Get()->IsEroR18()) // H365, JGG
					{
						if ((!mStrCode.empty()))
						{
							libPlatformManager::getPlatform()->setLoginName(mStrCode);
							if (mStrPwd.empty())
							{
								GamePrecedure::getInstance()->setDefaultPwd("888888");
							}
							else
							{
								GamePrecedure::getInstance()->setDefaultPwd(mStrPwd);
							}
							pLoadingFrame->onEnterGame();
						}
					}
					else
					{
						if ((!mStrCode.empty()) && (!mStrPwd.empty()))
						{
							int len = mStrPwd.length();
							if ((len < 6) || (len > PWD_LEN_LIMIT))
							{
								MessageHintPage::Msg_Hint(Language::Get()->getString("@Logintxt10").c_str());
								return;
							}
							libPlatformManager::getPlatform()->setLoginName(mStrCode);
							GamePrecedure::getInstance()->setDefaultPwd(mStrPwd);
							pLoadingFrame->onEnterGame();
						}
						else
						{
							if (mStrCode.empty())
							{
								MessageHintPage::Msg_Hint(Language::Get()->getString("@Logintxt11").c_str());
								return;
							}
							if (mStrPwd.empty())
							{
								MessageHintPage::Msg_Hint(Language::Get()->getString("@Logintxt10").c_str());
								return;
							}
						}
					}
				}
			}
		}
		else if (mTabMode == RegisterMode)
		{
			LoadingFrame* pLoadingFrame = GamePrecedure::Get()->getLoadingFrame();
			if (pLoadingFrame)
			{
				if (!SeverConsts::Get()->IsEroR18()) //H365, JGG
				{
					if (mStrReg_ID == "")
					{
						MessageHintPage::Msg_Hint(Language::Get()->getString("@Logintxt11").c_str());
						return;
					}
					mStrReg_Pwd = "888888";
				}
				else
				{
					if (!GamePrecedure::Get()->CheckMailRule(mStrReg_ID))
					{
						MessageHintPage::Msg_Hint(Language::Get()->getString("@Logintxt11").c_str());
						return;
					}

					if ((mStrReg_Pwd != mStrReg_Again))
					{
						MessageHintPage::Msg_Hint(Language::Get()->getString("@Logintxt14").c_str());
						return;
					}
					else
					{
						int length = mStrReg_Pwd.length();
						if ((length < 6) || (length > PWD_LEN_LIMIT))
						{
							MessageHintPage::Msg_Hint(Language::Get()->getString("@Logintxt13").c_str());
							return;
						}
						int areturn = 0;
						for (int i = 0; i < length; i++) // 檢查字串除了英數,有無他字元
						{
							areturn = isalnum(mStrReg_Pwd[i]);
							if (areturn == 0)
							{
								MessageHintPage::Msg_Hint(Language::Get()->getString("@Logintxt13").c_str());
								return;
							}
						}
					}
				}
				libPlatformManager::getPlatform()->setLoginName(mStrReg_ID);
				GamePrecedure::getInstance()->setDefaultPwd(mStrReg_Pwd);
				pLoadingFrame->onEnterGame(true);
			}
		}
	}
	else if (itemName == "onConfirmation")
	{
		//if (mPwdTextNode && mCodeTextNode)
		//{
		//	if (mStrCode.length() == 0)
		//	{
		//		libPlatformManager::getPlatform()->sendMessageG2P("G2P_SHOW_TOAST", Language::Get()->getString("@DataTransferWasEmpty"));
		//	}
		//	else
		//	{
		//		if (2 == BlackBoard::getInstance()->PLATFORM_TYPE_FOR_LUA)
		//		{
		//			libOS::getInstance()->setWaiting(true);
		//		}
		//		Json::Value data;
		//		data["code"] = Json::Value(string(mStrCode));
		//		data["pwd"] = Json::Value(string(mStrPwd));

		//		libPlatformManager::getPlatform()->sendMessageG2P("G2P_DATA_TRANSFER", data.toStyledString());
		//	}

		//}
	}
	else if (itemName == "onLoginLocalBtn")
	{
		CCB_FUNC(this, "mLoginLocal", CCNode, setVisible(true));
		CCB_FUNC(this, "mLoginSDK", CCNode, setVisible(false));
	}
	else if (itemName == "onLoginbySDKBtn")
	{
		CCB_FUNC(this, "mLoginSDK", CCNode, setVisible(false));
		if (SeverConsts::Get()->IsEroR18()) // eror18 is true
		{
			//Lua_EcchiGamerSDKBridge::callinitbyC();
			//Lua_EcchiGamerSDKBridge::callLoginbyC();
		}
	}
}
void LoginUserPage::cursorNode(CCLabelTTF* labelNode, bool isShow)
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

void LoginUserPage::resetPageData()
{
	//mStrCode = "";
	//mStrPwd = "";
	mStrReg_ID = "";
	mStrReg_Pwd = "";
	mStrReg_Again = "";
	textMap.clear();
	hintMap.clear();
	EditBoxMap.clear();
	textMap["mLoginMailLabel"] = dynamic_cast<CCLabelTTF*>(getVariable("mLoginMailLabel"));
	// = mCodeTextNode;
	textMap["mLoginPassLabel"] = dynamic_cast<CCLabelTTF*>(getVariable("mLoginPassLabel"));
	// = mPwdTextNode;
	textMap["mRegisterMailLabel"] = dynamic_cast<CCLabelTTF*>(getVariable("mRegisterMailLabel"));
	// = mRegIDNode;
	textMap["mRegisterPassLabel"] = dynamic_cast<CCLabelTTF*>(getVariable("mRegisterPassLabel"));
	//= mRegPwdNode;
	textMap["mRegisterConfirmLabel"] = dynamic_cast<CCLabelTTF*>(getVariable("mRegisterConfirmLabel"));
	//= mRegAgainNode;
	hintMap["mLoginPassLabelHint"] = dynamic_cast<CCLabelTTF*>(getVariable("mLoginPassLabelHint"));
	hintMap["mLoginMailLabelHint"] = dynamic_cast<CCLabelTTF*>(getVariable("mLoginMailLabelHint"));
	hintMap["mRegisterMailLabelHint"] = dynamic_cast<CCLabelTTF*>(getVariable("mRegisterMailLabelHint"));
	hintMap["mRegisterPassLabelHint"] = dynamic_cast<CCLabelTTF*>(getVariable("mRegisterPassLabelHint"));
	hintMap["mRegisterConfirmLabelHint"] = dynamic_cast<CCLabelTTF*>(getVariable("mRegisterConfirmLabelHint"));

	//mSprite9_Code = dynamic_cast<CCScale9Sprite*>(getVariable("mLoginMailChoose"));
	//mSprite9_Pwd = dynamic_cast<CCScale9Sprite*>(getVariable("mLoginPassChoose"));
	if (checkLabelUI())
	{
		if(2 == BlackBoard::getInstance()->PLATFORM_TYPE_FOR_LUA)
		{
			//code editbox
			EditBoxMap[Edit_UserID] = _createEditBox(mCodeEditBoxDelegate, CCSizeMake(400, 40), textMap["mLoginMailLabel"], textMap["mLoginMailLabel"]->getPosition(), Language::Get()->getString("@Logintxt5"));
			EditBoxMap[Edit_UserID]->setInputMode(kEditBoxInputModeEmailAddr);
			EditBoxMap[Edit_UserID]->setMaxLength(USER_LEN_LIMIT);
			//password editbox
			EditBoxMap[Edit_UserPwd] = _createEditBox(mPassWordEditBoxDelegate, CCSizeMake(400, 40), textMap["mLoginPassLabel"], textMap["mLoginPassLabel"]->getPosition(), Language::Get()->getString("@Logintxt6"));
			EditBoxMap[Edit_UserPwd]->setInputFlag(kEditBoxInputFlagPassword);
			EditBoxMap[Edit_UserPwd]->setMaxLength(PWD_LEN_LIMIT);

			CCB_FUNC(this,"mLoginMailContent",CCMenuItem,setEnabled(false));
			CCB_FUNC(this,"mLoginPassContent",CCMenuItem,setEnabled(false));

			//RegID editbox
			EditBoxMap[Edit_RegID] = _createEditBox(mRegIDEditBoxDelegate, CCSizeMake(400, 40), textMap["mRegisterMailLabel"], textMap["mRegisterMailLabel"]->getPosition(), Language::Get()->getString("@Logintxt5"));
			EditBoxMap[Edit_RegID]->setInputMode(kEditBoxInputModeEmailAddr);
			EditBoxMap[Edit_RegID]->setMaxLength(USER_LEN_LIMIT);
			//password editbox
			EditBoxMap[Edit_RegPwd] = _createEditBox(mRegPwdEditBoxDelegate, CCSizeMake(400, 40), textMap["mRegisterPassLabel"], textMap["mRegisterPassLabel"]->getPosition(), Language::Get()->getString("@Logintxt6"));
			EditBoxMap[Edit_RegPwd]->setInputFlag(kEditBoxInputFlagPassword);
			EditBoxMap[Edit_RegPwd]->setMaxLength(PWD_LEN_LIMIT);

			EditBoxMap[Edit_RegAgain] = _createEditBox(mRegAgainEditBoxDelegate, CCSizeMake(400, 40), textMap["mRegisterConfirmLabel"], textMap["mRegisterConfirmLabel"]->getPosition(), Language::Get()->getString("@Logintxt16"));
			EditBoxMap[Edit_RegAgain]->setInputFlag(kEditBoxInputFlagPassword);
			EditBoxMap[Edit_RegAgain]->setMaxLength(PWD_LEN_LIMIT);

			CCB_FUNC(this, "mRegisterMailContent", CCMenuItem, setEnabled(false));
			CCB_FUNC(this, "mRegisterPassContent", CCMenuItem, setEnabled(false));
			CCB_FUNC(this, "mRegisterConfirmContent", CCMenuItem, setEnabled(false));

			switchAllhint(false);
		}
		else //回主畫面重登
		{

			CCNode *_pNode = dynamic_cast<CCNode*>(getVariable("mBG_FullNode"));
			bgNodeDefaultPosX = _pNode->getPositionX();
			bgNodeDefaultPosY = _pNode->getPositionY();

			//clearAllLabel();
			//switchAllhint(true);
			hintMap["mLoginMailLabelHint"]->setVisible(mStrCode == "");
			hintMap["mLoginPassLabelHint"]->setVisible(mStrPwd == "");
			

			//mPwdTextNode->setString("");
			//mCodeTextNode->setString("");
			//mPwdHintNode->setVisible(true);
			//mCodeHintNode->setVisible(true);

			//mRegIDNode->setString("");
			//mRegPwdNode->setString("");
			//mRegAgainNode->setString("");
			//mRegIDHintNode->setVisible(true);
			//mRegPwdHintNode->setVisible(true);
			//mRegAgainHintNode->setVisible(true);

		}
		//mSprite9_Code->setVisible(false);
		//mSprite9_Pwd->setVisible(false);
		setInputMode(LoginMode);
		//setInputMode(RegisterMode);
	}
	else
	{
		//重要提示！
		closePage();
	}
	
}
void LoginUserPage::onInputChangeText(const std::string& content)
{
	CCLabelTTF* hintNode = NULL;
	CCLabelTTF* textNode = NULL;
	std::string tempContent = content;
	
	

	if (mInputType == INPUT_CODE)
	{
		mStrCode = tempContent;
		hintNode = hintMap["mLoginMailLabelHint"];
		textNode = textMap["mLoginMailLabel"];

	}
	else if (mInputType == INPUT_PWD)
	{
		mStrPwd = tempContent;
		hintNode = hintMap["mLoginPassLabelHint"];
		textNode = textMap["mLoginPassLabel"];

	}
	else if (mInputType == INPUT_RegID)
	{
		mStrReg_ID = tempContent;
		hintNode = hintMap["mRegisterMailLabelHint"];
		textNode = textMap["mRegisterMailLabel"];
	}
	else if (mInputType == INPUT_RegPwd)
	{
		mStrReg_Pwd = tempContent;
		hintNode = hintMap["mRegisterPassLabelHint"];
		textNode = textMap["mRegisterPassLabel"];
	}
	else if (mInputType == INPUT_RegAgain)
	{
		mStrReg_Again = tempContent;
		hintNode = hintMap["mRegisterConfirmLabelHint"];
		textNode = textMap["mRegisterConfirmLabel"];
	}

	if (tempContent.length() > 0)
	{
		if (hintNode){
			hintNode->setVisible(false);
		}
		if (textNode){
			std::string text;
			if ((mInputType == INPUT_PWD) || (mInputType == INPUT_RegPwd) || (mInputType == INPUT_RegAgain)){
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

bool LoginUserPage::checkLabelUI()
{
	for (auto itr : textMap)
	{
		if (!itr.second)
			return false;
	}

	for (auto itr : hintMap)
	{
		if (!itr.second)
			return false;
	}

	return true;
}

void LoginUserPage::switchAllhint(bool swit)
{
	for (auto itr : hintMap)
	{
		if (itr.second)
		{
			itr.second->setVisible(swit);
		}
	}

}

void LoginUserPage::clearAllLabel()
{
	for (auto itr : textMap)
	{
		if (itr.second)
		{
			itr.second->setString("");
		}
	}
}

void LoginUserPage::setInputMode(TabMode aMode)
{
	mTabMode = aMode;
	setTabSelect();
}
void LoginUserPage::setTabSelect()
{
	if (mTabMode == NoneMode)
	{
		CCB_FUNC(this, "mLoginTab", CCMenuItemImage, unselected());
		CCB_FUNC(this, "mRegisterTab", CCMenuItemImage, unselected());
		CCB_FUNC(this, "mLoginPage", CCNode, setVisible(false));
		CCB_FUNC(this, "mRegisterPage", CCNode, setVisible(false));
	}
	else if (mTabMode == LoginMode)
	{
		CCB_FUNC(this, "mLoginTab", CCMenuItemImage, selected());
		CCB_FUNC(this, "mRegisterTab", CCMenuItemImage, unselected());
		CCB_FUNC(this, "mLoginPage", CCNode, setVisible(true));
		CCB_FUNC(this, "mRegisterPage", CCNode, setVisible(false));
	}
	else if (mTabMode == RegisterMode)
	{
		CCB_FUNC(this, "mLoginTab", CCMenuItemImage, unselected());
		CCB_FUNC(this, "mRegisterTab", CCMenuItemImage, selected());
		CCB_FUNC(this, "mLoginPage", CCNode, setVisible(false));
		CCB_FUNC(this, "mRegisterPage", CCNode, setVisible(true));
	}
}

void LoginUserPage::onOpenKeyboard()
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
void LoginUserPage::OnKeyboardHightChange(int nHight)
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

	CCNode *_pNode = dynamic_cast<CCNode*>(getVariable("mBG_FullNode"));

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

void LoginUserPage::DefaultLogin(std::string UserId, std::string aPwd)
{
	if ((UserId != "") && (aPwd != ""))
	{
		defaultInGame = true;
		//onEditboxReturn(UserId, INPUT_CODE);
		//onEditboxReturn(aPwd, INPUT_PWD);
	}
	else
		defaultInGame = false;
	setInputMode(LoginMode);
	mInputType = INPUT_CODE;
	onInputChangeText(UserId);
	mInputType = INPUT_PWD;
	onInputChangeText(aPwd);
	CCB_FUNC(this, "mLoginSDK", CCNode, setVisible(!defaultInGame));
	CCB_FUNC(this, "mLoginLocal", CCNode, setVisible(defaultInGame));
}

void LoginUserPage::onCloseKeyboard()
{
	if (mInputType == INPUT_CODE)
	{
		cursorNode(textMap["mLoginMailLabel"], false);
		//mSprite9_Code->setVisible(false);
	}
	else if (mInputType == INPUT_PWD)
	{
		cursorNode(textMap["mLoginPassLabel"], false);
		//mSprite9_Pwd->setVisible(false);
	}
	else if (mInputType == INPUT_RegID)
	{
		cursorNode(textMap["mRegisterMailLabel"], false);
		//mSprite9_Pwd->setVisible(false);
	}
	else if (mInputType == INPUT_RegPwd)
	{
		cursorNode(textMap["mRegisterPassLabel"], false);
		//mSprite9_Pwd->setVisible(false);
	}
	else if (mInputType == INPUT_RegAgain)
	{
		cursorNode(textMap["mRegisterConfirmLabel"], false);
		//mSprite9_Pwd->setVisible(false);
	}
	CCNode *_pNode = dynamic_cast<CCNode*>(getVariable("mBG_FullNode"));
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
void LoginUserPage::onInputboxEnter(const std::string& content)
{
	onInputChangeText(content);
	if (mInputType == INPUT_CODE)
	{
		cursorNode(textMap["mLoginMailLabel"], true);
		//mSprite9_Code->setVisible(true);
	}
	else if (mInputType == INPUT_PWD)
	{
		cursorNode(textMap["mLoginPassLabel"], true);
		//mSprite9_Pwd->setVisible(true);
	}
	else if (mInputType == INPUT_RegID)
	{
		cursorNode(textMap["mRegisterMailLabel"], true);
		//mSprite9_Pwd->setVisible(true);
	}
	else if (mInputType == INPUT_RegPwd)
	{
		cursorNode(textMap["mRegisterPassLabel"], true);
		//mSprite9_Pwd->setVisible(true);
	}
	else if (mInputType == INPUT_RegAgain)
	{
		cursorNode(textMap["mRegisterConfirmLabel"], true);
		//mSprite9_Pwd->setVisible(true);
	}

}

void LoginUserPage::closePage()
{
	if ( GamePrecedure::Get()->isInLoadingScene() )
	{
		//setVisible(false);
		removeFromParent();
	}
	else
	{
		MsgMainFramePopPage msg;
		msg.pageName = "LoginUserPage";
		MessageManager::Get()->sendMessage(&msg);
	}
	libOS::getInstance()->removeListener(this);
}



void LoginUserPage::load(void)
{
	loadCcbiFile("LoginPopUp.ccbi");
	CCB_FUNC(this, "mLoginSDK", CCNode, setVisible(false));
	CCB_FUNC(this, "mLoginLocal", CCNode, setVisible(false));
}

std::string LoginUserPage::onReceiveCommonMessage(const std::string& tag, const std::string& msg)
{
	//if (tag == "P2G_DATA_TRANSFER")
	//{
	//	Json::Reader jreader;
	//	Json::Value jvalue;
	//	jreader.parse(msg, jvalue, false);

	//	Json::Value jroot = jvalue;
	//	if (!jroot.empty() && !jroot["result"].empty() && !jroot["code"].empty())
	//	{
	//		std::string result = jroot["result"].asString();
	//		if (result == "1"){//成功
	//			libPlatformManager::getPlatform()->sendMessageG2P("G2P_SHOW_TOAST", Language::Get()->getString("@DataTransferSuccessful"));
	//			closePage();
	//		}
	//		else if (result == "0")//失敗
	//		{
	//			std::string code = jroot["code"].asString();
	//			if (code =="1"){//參數確實或者密碼長度的問題
	//				libPlatformManager::getPlatform()->sendMessageG2P("G2P_SHOW_TOAST", Language::Get()->getString("@DataTransferPasswordTooShort"));
	//			}
	//			else if (code == "2")//沒有找到該accode對應的帳號紀錄
	//			{
	//				libPlatformManager::getPlatform()->sendMessageG2P("G2P_SHOW_TOAST", Language::Get()->getString("@DataTransferWasWrong"));
	//			}
	//			else if (code == "3")//密碼錯誤
	//			{
	//				libPlatformManager::getPlatform()->sendMessageG2P("G2P_SHOW_TOAST", Language::Get()->getString("@DataTransferWasWrong"));
	//			}
	//			else if (code == "4")//該設備已經進行過了移行
	//			{
	//				libPlatformManager::getPlatform()->sendMessageG2P("G2P_SHOW_TOAST", Language::Get()->getString("@DataTransferAlreadyBeenOnce"));
	//			}
	//		}
	//	}
	//}
	return "";
}

cocos2d::extension::CCEditBox* LoginUserPage::_createEditBox(CCEditBoxDelegate* delegate,const CCSize& size,CCNode* node,const CCPoint& pos,std::string plactHolder/*=""*/)
{
	cocos2d::extension::CCEditBox* editbox = 
		cocos2d::extension::CCEditBox::create(size,cocos2d::extension::CCScale9Sprite::create("UI/Mask/Image_Empty.png"));
	if (editbox)
	{
		editbox->setAnchorPoint(node->getAnchorPoint());
		editbox->setDelegate(delegate);
		editbox->setPosition(pos);
		editbox->setScale(node->getScale()*0.8);
		editbox->setFont("Barlow-SemiBold.ttf",20);
        editbox->setFontColor(ccc3(132,113,92));
		editbox->setPlaceholderFont("Barlow-SemiBold.ttf",20);
		editbox->setPlaceHolder(plactHolder.c_str());
		//editbox->setMaxLength(PWD_LEN_LIMIT);
		node->getParent()->removeChildByTag(EDITBOXTAG,true);
		node->getParent()->addChild(editbox,1,EDITBOXTAG);
		node->setVisible(false);
	}
	return editbox;
}

void EditUIDelegate::editBoxEditingDidBegin(CCEditBox* editBox)
{
	mCustom->onEditboxReturn(editBox,editBox->getText(),mInputType);
	if (mInputType == INPUT_CODE)
	{
		//mCustom->setCodeFrameVisible(true);
	}
	else if(mInputType == INPUT_PWD)
	{
		//mCustom->setPwdFrameVisible(true);
	}
}

void EditUIDelegate::editBoxEditingDidEnd(CCEditBox* editBox)
{
	mCustom->onEditboxReturn(editBox,editBox->getText(),mInputType);
	if (mInputType == INPUT_CODE)
	{
		//mCustom->setCodeFrameVisible(false);
	}
	else if(mInputType == INPUT_PWD)
	{
		//mCustom->setPwdFrameVisible(false);
	}
}

void EditUIDelegate::editBoxTextChanged(CCEditBox* editBox, const std::string& text)
{
	mCustom->onEditboxReturn(editBox,editBox->getText(),mInputType,true);
    
	if (mInputType == INPUT_CODE)
	{
        
		//mCustom->setCodeFrameVisible(false);
	}
	else if(mInputType == INPUT_PWD)
	{
		//mCustom->setPwdFrameVisible(false);
	}
}

void EditUIDelegate::editBoxReturn(CCEditBox* editBox)
{
	mCustom->onEditboxReturn(editBox,editBox->getText(),mInputType);
}
void LoginUserPage::onEditboxReturn( cocos2d::extension::CCEditBox* editbox,std::string text,InputType type,bool isChange/* = false*/ )
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
	if (mInputType == INPUT_RegID)
	{
		mStrReg_ID = text;
	}
	else if (mInputType == INPUT_RegPwd)
	{
		mStrReg_Pwd = text;
	}
	if (mInputType == INPUT_RegAgain)
	{
		mStrReg_Again = text;
	}
	if(!isChange)
	{
		editbox->setText(text.c_str());
	}
}

