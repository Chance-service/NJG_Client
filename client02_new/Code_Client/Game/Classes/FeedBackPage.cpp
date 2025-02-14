
#include "stdafx.h"

#include "FeedBackPage.h"
#include "StringConverter.h"
#include "BlackBoard.h"
#include "libOS.h"
#include "GamePlatform.h"
#include "SeverConsts.h"
REGISTER_PAGE("FeedBackPage", FeedBackPage);
USING_NS_CC;
USING_NS_CC_EXT;
#define TAG_LABLE 10001
FeedBackPage::FeedBackPage(void)
{
}

FeedBackPage::~FeedBackPage(void)
{

}

void FeedBackPage::Enter(MainFrame*)
{
	libPlatformManager::getPlatform()->registerListener(this);
	//if (SeverConsts::Get()->IsH365())
		loadConfigFile("Feedback.txt");
	//else if (severconsts::get()->iseror18())
	//	loadconfigfile("feedback_eror18.txt");
	//else if (severconsts::get()->isjgg())
	//	loadconfigfile("feedback_jgg.txt");
}
void FeedBackPage::Execute(MainFrame*)
{

}

void FeedBackPage::Exit(MainFrame*)
{

}

void FeedBackPage::loadConfigFile(const std::string& announcementFile, bool isDownload)
{
	unsigned long filesize = 0;
	char* pBuffer = (char*)getFileData(
		cocos2d::CCFileUtils::sharedFileUtils()->fullPathForFilename(announcementFile.c_str()).c_str(),
		"rt",&filesize,0,false);

	if(!pBuffer)
	{
		libOS::getInstance()->showMessagebox(announcementFile+" not found!", 100);
		CC_SAFE_DELETE_ARRAY(pBuffer);
		return;
	}
	if ( pBuffer[filesize - 1] != '\0' )
	{
		char* newBuffer = new char[filesize + 1];
		memcpy(newBuffer, pBuffer, filesize);
		newBuffer[filesize] = '\0';
		CC_SAFE_DELETE_ARRAY(pBuffer);
		pBuffer = newBuffer;
	}
	if (members->getChildByTag(TAG_LABLE))
	{
		members->removeChildByTag(TAG_LABLE);
	}

	CCSize size = members->getViewSize();
	CCHTMLLabel* label = CCHTMLLabel::createWithString(pBuffer, size);
	label->setPosition(ccp(0, 0));
	
	//CCRichNode* pRichNode = label->GetRichNode();
	label->registerClickListener(this, &FeedBackPage::URLlabelCallback);
	label->setTag(TAG_LABLE);
	members->addChild(label);
	unsigned int height = label->getContentSize().height;
	members->setContentSize(CCSizeMake(members->getContentSize().width, height));
	members->setContentOffset(ccp(0, size.height - height));

	CC_SAFE_DELETE_ARRAY(pBuffer);
	setVisible(true);

	if(isDownload)
	{
		/*cocos2d::CCUserDefault::sharedUserDefault()->setIntegerForKey(ANNOUNCEMENT_VERSION_KEY.c_str(),SeverConsts::Get()->getInternalAnnouncementVersion());
		cocos2d::CCUserDefault::sharedUserDefault()->setIntegerForKey(ANNOUNCEMENT_DWONLOAD_TIME_KEY.c_str(),GamePrecedure::Get()->getServerTime());
		cocos2d::CCUserDefault::sharedUserDefault()->flush();*/
	}
}


void FeedBackPage::onMenuItemAction(const std::string& itemName, cocos2d::CCObject* sender, int tag)
{
}

void FeedBackPage::URLlabelCallback(IRichNode* root, IRichElement* ele, int _id)
{
	REleHTMLButton *button = dynamic_cast<REleHTMLButton*> (ele);
	if(button)
	{
		string strName = button->getName();
		string strValue = button->getValue();

		if(strName.compare("URL") == 0 && !strValue.empty())
		{
			std::string serverid = cocos2d::CCUserDefault::sharedUserDefault()->getStringForKey("JapanServrId", "unknown");
			std::string playerid = cocos2d::CCUserDefault::sharedUserDefault()->getStringForKey("JapanPlayerId", "unknown");
			std::string time =   ::CCUserDefault::sharedUserDefault()->getStringForKey("JapanLastLoginTime", "unknown");
			std::string version = cocos2d::CCUserDefault::sharedUserDefault()->getStringForKey("versionResource", "unknown");
			std::string verisonApp  = CCUserDefault::sharedUserDefault()->getStringForKey("versionApp","unknow");
			version = verisonApp + "-" + version;
			Json::Value data;
			data["serverid"] = Json::Value(serverid);
			data["playerid"] = Json::Value(playerid);
			data["time"] = Json::Value(time);
			data["version"] = Json::Value(version);
			data["url"] = Json::Value(strValue);

			string EmailInfo = data.toStyledString();
			libPlatformManager::getPlatform()->sendMessageG2P("G2P_SEND_EMAIL", EmailInfo);
		}
		else{
			libOS::getInstance()->openURL(strValue);
		}
	}
	
}

void FeedBackPage::URLlabelForLuaCallback(std::string url)
{
	//REleHTMLButton *button = dynamic_cast<REleHTMLButton*> (ele);
	//if (button)
	//{
	//	string strName = button->getName();
	//	string strValue = button->getValue();

	//	if (strName.compare("URL") == 0 && !strValue.empty())
	//	{
			//std::string serverid = cocos2d::CCUserDefault::sharedUserDefault()->getStringForKey("JapanServrId", "unknown");
			//std::string playerid = cocos2d::CCUserDefault::sharedUserDefault()->getStringForKey("JapanPlayerId", "unknown");
			//std::string time = ::CCUserDefault::sharedUserDefault()->getStringForKey("JapanLastLoginTime", "unknown");
			//std::string version = cocos2d::CCUserDefault::sharedUserDefault()->getStringForKey("versionResource", "unknown");
			//std::string verisonApp = CCUserDefault::sharedUserDefault()->getStringForKey("versionApp", "unknow");
			//version = verisonApp + "-" + version;
			//Json::Value data;
			//data["serverid"] = Json::Value(serverid);
			//data["playerid"] = Json::Value(playerid);
			//data["time"] = Json::Value(time);
			//data["version"] = Json::Value(version);
			//data["url"] = Json::Value(url);
			//
			//string EmailInfo = data.toStyledString();
			//libPlatformManager::getPlatform()->sendMessageG2P("G2P_SEND_EMAIL", EmailInfo);
	//	}
	//}
	libOS::getInstance()->openURL(url);
}

void FeedBackPage::onMenuItemAction(const std::string& itemName, cocos2d::CCObject* sender)
{
	if (itemName == "onClose")
	{
		cocos2d::extension::CCScrollView* localmembers = dynamic_cast<cocos2d::extension::CCScrollView*>(getVariable("mAnnMsgContent"));
		if (localmembers)
		{
			CCNode* localRootNode = localmembers->getContainer();
			localRootNode->setVisible(true);
		}
		
		closePage();
	}
}

void FeedBackPage::closePage()
{
	if ( GamePrecedure::Get()->isInLoadingScene() )
	{
		setVisible(false);
		removeFromParent();
	}
	else
	{
		MsgMainFramePopPage msg;
		msg.pageName = "FeedBackPage";
		MessageManager::Get()->sendMessage(&msg);
	}
}

void FeedBackPage::load(void)
{
	setVisible(false);
	loadCcbiFile("AnnouncementPage.ccbi");
	//CCB_FUNC(this, "mTitle", CCLabelBMFont, setString(Language::Get()->getString("@Announcement").c_str()));
	members = dynamic_cast<cocos2d::extension::CCScrollView*>(getVariable("mContent"));
	memberRootNode = members->getContainer();
	memberRootNode->removeAllChildren();

	cocos2d::extension::CCScrollView* localmembers = dynamic_cast<cocos2d::extension::CCScrollView*>(getVariable("mAnnMsgContent"));
	if (localmembers)
	{
		CCNode* localRootNode = localmembers->getContainer();
		localRootNode->setVisible(false);
	}
	CCNode* pFDNode = dynamic_cast<CCNode*>(getVariable("mFeedBackNode"));
	if (pFDNode)
	{
		pFDNode->setVisible(true);
	}

	CCNode* pFDNode1 = dynamic_cast<CCNode*>(getVariable("mTitle"));
	if (pFDNode1)
	{
		pFDNode1->setVisible(false);
	}

	CCNode* pFDNode2 = dynamic_cast<CCNode*>(getVariable("mTitle1"));
	if (pFDNode2)
	{
		pFDNode2->setVisible(true);
	}
	CCNode* pANNode = dynamic_cast<CCNode*>(getVariable("mAnnounceNode"));
	if (pANNode)
	{
		pANNode->setVisible(false);
	}
}

FeedBackPage* FeedBackPage::getInstance()
{
	return FeedBackPage::Get();
}