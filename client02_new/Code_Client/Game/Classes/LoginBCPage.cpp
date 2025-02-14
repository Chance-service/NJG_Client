#include "stdafx.h"

#include "LoginBCPage.h"
#include "StringConverter.h"
#include "BlackBoard.h"
#include "GamePlatform.h"
#include "SeverConsts.h"
#include "AnimMgr.h"
#include "MessageHintPage.h"
#include "GraySprite.h"

REGISTER_PAGE("LoginBCPage", LoginBCPage);
USING_NS_CC;
USING_NS_CC_EXT;

#define TAG_LABLE 10001
#define PWD_LEN_LIMIT 12
#define USER_LEN_LIMIT 255
#define EDITBOXTAG 2000
#define CURSOR_TAG 66666
#define CURSOR_ICON "LoadingUI_JP/input_blink.png"
#define EMT_SendCode "EMT_SendCode"
#define EMT_StartGame "EMT_StartGame"

void EditDelegate::editBoxEditingDidBegin(CCEditBox* editBox)
{
	mCustom->onEditboxReturn(editBox, editBox->getText(), mInputType);
	if (mInputType == INPUT_CODE)
	{
		//mCustom->setCodeFrameVisible(true);
	}
	else if (mInputType == INPUT_EMAIL)
	{
		//mCustom->setPwdFrameVisible(true);
	}
}

void EditDelegate::editBoxEditingDidEnd(CCEditBox* editBox)
{
	mCustom->onEditboxReturn(editBox, editBox->getText(), mInputType);
	if (mInputType == INPUT_CODE)
	{
		//mCustom->setCodeFrameVisible(false);
	}
	else if (mInputType == INPUT_EMAIL)
	{
		//mCustom->setPwdFrameVisible(false);
	}
}

void EditDelegate::editBoxTextChanged(CCEditBox* editBox, const std::string& text)
{
	mCustom->onEditboxReturn(editBox, editBox->getText(), mInputType, true);

	if (mInputType == INPUT_CODE)
	{

		//mCustom->setCodeFrameVisible(false);
	}
	else if (mInputType == INPUT_EMAIL)
	{
		//mCustom->setPwdFrameVisible(false);
	}
}

void EditDelegate::editBoxReturn(CCEditBox* editBox)
{
	mCustom->onEditboxReturn(editBox, editBox->getText(), mInputType);
}

void LoginBCPage::onEditboxReturn(cocos2d::extension::CCEditBox* editbox, std::string text, EditDelegate::InputType type, bool isChange/* = false*/)
{
	mInputType = type;
	if (mInputType == EditDelegate::InputType::INPUT_CODE)
	{
		mStrCode = text;
	}
	else if (mInputType == EditDelegate::InputType::INPUT_EMAIL)
	{
		mStrEmail = text;
	}
	if (!isChange)
	{
		editbox->setText(text.c_str());
	}
}

LoginBCPage::LoginBCPage(void) :mInputType(-1)
{
	bgNodeDefaultPosX = 0.0f;
	bgNodeDefaultPosY = 0.0f;
	isOpenKeyBoard = false;
	isMoveFullNode = false;

	mEmailEditBoxDelegate = new EditDelegate();
	mCodeEditBoxDelegate = new EditDelegate();
	
	mEmailEditBoxDelegate->setCustom(this);
	mEmailEditBoxDelegate->setInputType(EditDelegate::InputType::INPUT_EMAIL);
	mCodeEditBoxDelegate->setCustom(this);
	mCodeEditBoxDelegate->setInputType(EditDelegate::InputType::INPUT_CODE);
}

LoginBCPage::~LoginBCPage(void)
{
	delete mEmailEditBoxDelegate;
	delete mCodeEditBoxDelegate;
}

void LoginBCPage::Enter(MainFrame*)
{
	libOS::getInstance()->registerListener(this);
	libPlatformManager::getPlatform()->registerListener(this);
	resetPageData();
}

void LoginBCPage::Execute(MainFrame*)
{
	if (TimeCalculator::getInstance()->hasKey("SendCodeTime"))
	{
		if (TimeCalculator::getInstance()->getTimeLeft("SendCodeTime") <= 0)
		{
			TimeCalculator::getInstance()->removeTimeCalcultor("SendCodeTime");
			showSendBtn(true);
		}
		else
		{
			showSendBtn(false);
		}
	}
}

void LoginBCPage::Exit(MainFrame*)
{

}

void LoginBCPage::onMenuItemAction(const std::string& itemName, cocos2d::CCObject* sender)
{
	if (itemName == "onClose" || itemName == "onCancel")
	{
		closePage();
	}

	if (itemName == "onEMailContent")
	{
		mInputType = EditDelegate::InputType::INPUT_EMAIL;
		libOS::getInstance()->showInputbox(false, 0, USER_LEN_LIMIT, mStrEmail);

	}
	else if (itemName == "onCodeContent")
	{
		mInputType = EditDelegate::InputType::INPUT_CODE;
		libOS::getInstance()->showInputbox(false, 0, PWD_LEN_LIMIT, mStrCode);

	}
	else if (itemName == "onSendCode")
	{
		if (!GamePrecedure::Get()->CheckMailRule(mStrEmail))
		{
			MessageHintPage::Msg_Hint(Language::Get()->getString("@Logintxt11").c_str());
			return;
		}

		std::string uinkey = "LoginEmail";
		CCUserDefault::sharedUserDefault()->setStringForKey(uinkey.c_str(), mStrEmail);
		SendCode(mStrEmail);
	}
	else if (itemName == "onStartGame")
	{
		if (!GamePrecedure::Get()->CheckMailRule(mStrEmail))
		{
			MessageHintPage::Msg_Hint(Language::Get()->getString("@Logintxt11").c_str());
			return;
		}

		int length = mStrCode.length();
		if ((length < 6) || (length > PWD_LEN_LIMIT))
		{
			MessageHintPage::Msg_Hint(Language::Get()->getString("@ERRORCODE_36").c_str());
			return;
		}
		int areturn = 0;
		for (int i = 0; i < length; i++) // 檢查字串除了英數,有無他字元
		{
			areturn = isalnum(mStrCode[i]);
			if (areturn == 0)
			{
				MessageHintPage::Msg_Hint(Language::Get()->getString("@ERRORCODE_36").c_str());
				return;
			}
		}
		StartGame(mStrEmail, mStrCode);
	}
}

void LoginBCPage::onInputboxEnter(const std::string& content)
{
	onInputChangeText(content);
	if (mInputType == EditDelegate::InputType::INPUT_CODE)
	{
		cursorNode(textMap["mCodeLabel"], true);
	}
	else if (mInputType == EditDelegate::InputType::INPUT_EMAIL)
	{
		cursorNode(textMap["mEmailLabel"], true);
	}


}

void LoginBCPage::load(void)
{
	loadCcbiFile("LoginReturnPopUp.ccbi");
}

cocos2d::extension::CCEditBox* LoginBCPage::_createBCEditBox(CCEditBoxDelegate* delegate, const CCSize& size, CCNode* node, const CCPoint& pos, std::string plactHolder/*=""*/)
{
	cocos2d::extension::CCEditBox* editbox =
		cocos2d::extension::CCEditBox::create(size, cocos2d::extension::CCScale9Sprite::create("UI/Mask/Image_Empty.png"));
	if (editbox)
	{
		editbox->setAnchorPoint(node->getAnchorPoint());
		editbox->setDelegate(delegate);
		editbox->setPosition(pos);
		editbox->setScale(node->getScale()*0.8);
		editbox->setFont("Barlow-SemiBold.ttf", 20);
		editbox->setFontColor(ccc3(132, 113, 92));
		editbox->setPlaceholderFont("Barlow-SemiBold.ttf", 20);
		editbox->setPlaceHolder(plactHolder.c_str());
		//editbox->setMaxLength(PWD_LEN_LIMIT);
		node->getParent()->removeChildByTag(EDITBOXTAG, true);
		node->getParent()->addChild(editbox, 1, EDITBOXTAG);
		node->setVisible(false);
	}
	return editbox;
}

void LoginBCPage::closePage()
{
	if (GamePrecedure::Get()->isInLoadingScene())
	{
		//setVisible(false);
		removeFromParent();
	}
	else
	{
		MsgMainFramePopPage msg;
		msg.pageName = "LoginBCPage";
		MessageManager::Get()->sendMessage(&msg);
	}
	libOS::getInstance()->removeListener(this);
}

void LoginBCPage::cursorNode(CCLabelTTF* labelNode, bool isShow)
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

void LoginBCPage::DefaultEmail()
{
	std::string uinkey = "LoginEmail";
	std::string email = CCUserDefault::sharedUserDefault()->getStringForKey(uinkey.c_str(), "");
	if (email != "")
	{
		mInputType = EditDelegate::InputType::INPUT_EMAIL;
		onInputChangeText(email);
	}
}

void LoginBCPage::resetPageData()
{
	textMap.clear();
	//hintMap.clear();
	EditBoxMap.clear();
	textMap["mEmailLabel"] = dynamic_cast<CCLabelTTF*>(getVariable("mEmailLabel"));
	// = mCodeTextNode;
	textMap["mCodeLabel"] = dynamic_cast<CCLabelTTF*>(getVariable("mCodeLabel"));
	// = mPwdTextNode;
	if (checkLabelUI())
	{
		if (2 == BlackBoard::getInstance()->PLATFORM_TYPE_FOR_LUA)
		{
			//code editbox
			EditBoxMap[Edit_Email] = _createBCEditBox(mEmailEditBoxDelegate, CCSizeMake(400, 40), textMap["mEmailLabel"], textMap["mEmailLabel"]->getPosition(), Language::Get()->getString("@Logintxt5"));
			EditBoxMap[Edit_Email]->setInputMode(kEditBoxInputModeEmailAddr);
			EditBoxMap[Edit_Email]->setMaxLength(USER_LEN_LIMIT);
			//password editbox
			EditBoxMap[Edit_Code] = _createBCEditBox(mCodeEditBoxDelegate, CCSizeMake(400, 40), textMap["mCodeLabel"], textMap["mCodeLabel"]->getPosition(), Language::Get()->getString("@Logintxt6"));
			EditBoxMap[Edit_Code]->setInputMode(kEditBoxInputModeNumeric);
			EditBoxMap[Edit_Code]->setMaxLength(PWD_LEN_LIMIT);

			CCB_FUNC(this, "mEMailContent", CCMenuItem, setEnabled(false));
			CCB_FUNC(this, "mCodeContent", CCMenuItem, setEnabled(false));
		}
		else //回主畫面重登
		{
			//CCNode *_pNode = dynamic_cast<CCNode*>(getVariable("mBG_FullNode"));
			//bgNodeDefaultPosX = _pNode->getPositionX();
			//bgNodeDefaultPosY = _pNode->getPositionY();
		}
	}
	else
	{
		//重要提示！
		closePage();
	}
}

void LoginBCPage::onInputChangeText(const std::string& content)
{
	//CCLabelTTF* hintNode = NULL;
	CCLabelTTF* textNode = NULL;
	std::string tempContent = content;



	if (mInputType == EditDelegate::InputType::INPUT_EMAIL)
	{
		mStrEmail = tempContent;
		//hintNode = hintMap["mLoginMailLabelHint"];
		textNode = textMap["mEmailLabel"];

	}
	else if (mInputType == EditDelegate::InputType::INPUT_CODE)
	{
		mStrCode = tempContent;
		//hintNode = hintMap["mLoginPassLabelHint"];
		textNode = textMap["mCodeLabel"];

	}

	if (tempContent.length() > 0)
	{
		//if (hintNode){
		//	hintNode->setVisible(false);
		//}
		if (textNode){
			std::string text;
			//if ((mInputType == INPUT_PWD) || (mInputType == INPUT_RegPwd) || (mInputType == INPUT_RegAgain)){
			//	for (int i = 0; i < tempContent.length(); i++)
			//	{
			//		if (i == tempContent.length() - 1)
			//		{
			//			text = text + tempContent.at(i);
			//		}
			//		else{
			//			text = text + "*";
			//		}
			//	}
			//	textNode->setString(text.c_str());
			//}
			//else{
				textNode->setString(tempContent.c_str());
			//}

		}
	}
	else{
		//if (hintNode){
		//	hintNode->setVisible(true);
		//}
		if (textNode){
			textNode->setString("");
		}
	}
}

bool LoginBCPage::checkLabelUI()
{
	for (auto itr : textMap)
	{
		if (!itr.second)
			return false;
	}

	return true;
}

void LoginBCPage::SendCode(const std::string& email)
{
	try
	{
		std::string url = VaribleManager::Get()->getSetting("BCUrl", "", "https://apisky.ntoken.bwtechnology.net");

		LoadingFrame* pLoadingFrame = GamePrecedure::Get()->getLoadingFrame();
		int serverid = pLoadingFrame->getSelectedSeverID();

		if (serverid == 8) // jack debug use
		{
			url = "https://apisky.ntoken.bwtechnology.net/api";
		}
		
		url.append("/sendcodeingame.php");

		std::string data = CCString::createWithFormat("api_id=skyark_ingame_api&api_token=3C2D36F79AFB3D5374A49BE767A17C6A3AEF91635BF7A3FB25CEA8D4DD&user_email=%s",email.c_str())->m_sString;

		auto request = new CCHttpRequest();
		request->setTag(EMT_SendCode);
		request->setUrl(url.c_str());
		request->setRequestType(CCHttpRequest::HttpRequestType::kHttpPost);
		request->setRequestData(data.c_str(), data.size());
		request->setResponseCallback(this, callfuncND_selector(LoginBCPage::onHttpRequestCompleted));
		CCHttpClient::getInstance()->send(request);

		request->release();
	}
	catch (...)
	{
		CCLOG("URL REQUEST IS NOT  REACH");
	}
}

void LoginBCPage::StartGame(const std::string& email, const std::string& aCode)
{
	try
	{
		std::string url = VaribleManager::Get()->getSetting("BCUrl", "", "https://apisky.ntoken.bwtechnology.net");

		LoadingFrame* pLoadingFrame = GamePrecedure::Get()->getLoadingFrame();
		int serverid = pLoadingFrame->getSelectedSeverID();

		if (serverid == 8) // jack debug use
		{
			url = "https://apisky.ntoken.bwtechnology.net/api";
		}

		url.append("/verifyuservodeingame.php");

		std::string data = CCString::createWithFormat("vcode=%s&uEmail=%s&api_id=skyark_ingame_api&api_token=3C2D36F79AFB3D5374A49BE767A17C6A3AEF91635BF7A3FB25CEA8D4DD",aCode.c_str(), email.c_str())->m_sString;

		auto request = new CCHttpRequest();
		request->setTag(EMT_StartGame);
		request->setUrl(url.c_str());
		request->setRequestType(CCHttpRequest::HttpRequestType::kHttpPost);
		request->setRequestData(data.c_str(), data.size());
		request->setResponseCallback(this, callfuncND_selector(LoginBCPage::onHttpRequestCompleted));
		CCHttpClient::getInstance()->send(request);

		request->release();
	}
	catch (...)
	{
		CCLOG("URL REQUEST IS NOT  REACH");
	}
}

void LoginBCPage::onHttpRequestCompleted(cocos2d::CCNode *sender, void*data)
{
	CCLOG("BCLogin : onHttpRequestCompleted");

	CCHttpResponse* response = (CCHttpResponse*)data;
	int codeIndex = response->getResponseCode();
	std::vector<char>* buffer = response->getResponseData();
	std::string temp(buffer->begin(), buffer->end());
	CCString* responseData = CCString::create(temp);
	const char* content = responseData->getCString();
	const char* tag = response->getHttpRequest()->getTag();
	if (!response->isSucceed())
	{
		CCLOG("BCLogin: onHttpRequestCompleted fail");

		//if (codeIndex == 201) // have errorcode
		//{
		//	Json::Reader e_reader;
		//	Json::Value e_value;
		//	bool backbool = e_reader.parse(content, e_value);
		//	if (!backbool)
		//	{
		//		return;
		//	}
		//	int errcode = std::atoi(e_value["err"].asString().c_str());
		//	std::string key = "";
		//	if (errcode == 101)
		//	{
		//		key = "@ERRORCODE_35";
		//	}
		//	else if (errcode == 102)
		//	{
		//		key = "@ERRORCODE_35";
		//	}
		//	else if (errcode == 103)
		//	{
		//		key = "@ERRORCODE_38";
		//	}
		//	else if (errcode == 104)
		//	{
		//		key = "@ERRORCODE_36";
		//	}
		//	if (key != "")
		//		MessageHintPage::Msg_Hint(Language::Get()->getString(key).c_str());
		//}
	}
	else
	{
		CCLOG("BCLogin: onHttpRequestCompleted Succeed");

		Json::Reader reader;
		Json::Value value;
		std::string key = "";

		bool ret = reader.parse(content, value);
		if (!ret)
		{
			MessageHintPage::Msg_Hint("API parse error");
			return;
		}

		int errcode = value["err"].asInt();

		if (errcode > 0)
		{
			if (errcode == 1)
			{
				key = "@Logintxt11";
			}
			else if (errcode == 3)
			{
				key = "@ERRORCODE_35";
			}
			else if (errcode == 9)
			{
				key = "@ERRORCODE_28";
			}
			if (key != "")
				MessageHintPage::Msg_Hint(Language::Get()->getString(key).c_str());
			else
				MessageHintPage::Msg_Hint(value["msg"].asString());
			return;
		}

		if (strcmp(tag, EMT_SendCode) == 0)
		{
			MessageHintPage::Msg_Hint(Language::Get()->getString("@Logintxt17").c_str());
			// do something
			TimeCalculator::getInstance()->createTimeCalcultor("SendCodeTime",60); //60秒不能再送
			showSendBtn(false);
		}
		else if (strcmp(tag, EMT_StartGame) == 0)
		{
			std::string uid = value["account"].asString(); 
			libPlatformManager::getPlatform()->setLoginName(uid);
			std::string wallet = value["msg"].asString();
			GamePrecedure::getInstance()->setWallet(wallet);
			GamePrecedure::getInstance()->setDefaultPwd("888888");
			LoadingFrame* pLoadingFrame = GamePrecedure::Get()->getLoadingFrame();
			pLoadingFrame->onEnterGame();
		}
	}
}
void LoginBCPage::showSendBtn(bool isShow)
{
	CCB_FUNC(this, "mSendCodeBtn", CCMenuItem, setEnabled(isShow));
	CCNode* node = dynamic_cast<CCNode*>(getVariable("mSendCodeBmf"));
	if (isShow)
	{
		GraySprite::RemoveColorGrayToNode(node);
	}
	else
		GraySprite::AddColorGrayToNode(node);
}