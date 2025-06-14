
#include "stdafx.h"

#include "MainFrame.h"
#include "GameMessages.h"
#include "Language.h"
#include "cocos-ext.h"
#include "cocos2d.h"

#include "SoundManager.h"
#include "CustomPage.h"
#include "MessageBoxPage.h"
#include "GamePrecedure.h"
#include "BlackBoard.h"
#include "MessageBoxPage.h"
#include "libOS.h"
#include "json/json.h"
#include "GamePlatform.h"
#include "AppDelegate.h"
#include "DataTableManager.h"
#include "AnimMgr.h"
#include "RadialBlurSprite.h"
#include "GameTypedef.h"
#include "shaders/shaderhelper/CCBlurScreenSH.h"
#include "BlurSprite.h"
#include "LoadingFrame.h"
#include "MessageHintPage.h"
#include "waitingManager.h"
//#include "libVoiceChat.h"
#define BATTLE_PAGE_NAME "BattlePage"

USING_NS_CC;
USING_NS_CC_EXT;

REGISTER_PAGE("MainFrame",MainFrame);
class MainframeScorllviewController : public cocos2d::extension::CCScrollViewDelegate
{
	virtual void scrollViewDidScroll(CCScrollView* view)
	{
	
	}
	virtual void scrollViewDidDeaccelerateScrolling(CCScrollView* view, CCPoint initSpeed)
	{

	};
	virtual void scrollViewDidDeaccelerateStop(CCScrollView* view, CCPoint initSpeed)
	{
		static std::string buttonsStr =  VaribleManager::getInstance()->getSetting("MainFrameScrollButtons","","6");
		if(buttonsStr == "6")
		{
			CCBContainer* con = CCBManager::Get()->getPage("MainFrame");
			float button = 0.0f;
			CCB_FUNC_RETURN(con,"mBottomL",CCNode,getContentSize().width,button);
			float xoff = view->getContentOffset().x;
			float unit = view->getContainer()->getContentSize().width/6;
			if(xoff<-(unit-button)*0.5f)
			{
				view->setContentOffsetInDuration(view->minContainerOffset(),0.3f);
				CCB_FUNC(con,"mBottomL",cocos2d::CCNode,setVisible(true));
				CCB_FUNC(con,"mBottomR",cocos2d::CCNode,setVisible(false));
			}
			else
			{
				view->setContentOffsetInDuration(view->maxContainerOffset(),0.3f);
				CCB_FUNC(con,"mBottomL",cocos2d::CCNode,setVisible(false));
				CCB_FUNC(con,"mBottomR",cocos2d::CCNode,setVisible(true));
			}
		}
	};
	virtual void scrollViewDidZoom(CCScrollView* view)
	{

	}
};

static MainframeScorllviewController sMainframeScrollviewController;

/// MainFrame?建的?机在最?始，而LOAD?机在登?后，指?初始化避免野??
MainFrame::MainFrame(void)
	: mNodeFight(NULL),mScene(NULL)
	, mFightPage(NULL)
	,mNodeMsgForLua(NULL)
	,mNodeMid(NULL)
	,mNodeBack(NULL)
	,mNodeFront(NULL)
	,mNodeMsg(NULL)
	,mNoTouch(NULL)
	,mMainFrameButtons(NULL)
{
	
	mCurShowPageName = "";
	mLastChangePageName="";
	mMainFrameButtons = NULL;
	mGridBlur = NULL;
	mCurShowPage = NULL;
	isInChooseRolePage = false;
}


MainFrame::~MainFrame(void)
{

	if (mGridBlur)
	{
		mGridBlur->release();
	}
}


void MainFrame::_loadPopPage()
{
	if(VaribleManager::Get()->getSetting("AnnouncementPageOpenStatus")=="1")
	{
		MsgMainFramePushPage msg;
		msg.pageName = "AnnouncementNewPage";
		MessageManager::Get()->sendMessage(&msg);
	}
	
}

void MainFrame::reEnter(GamePrecedure*)
{
	//mScene->setVisible(true);
	cocos2d::CCScene * scene = cocos2d::CCTransitionFade::create(1.0f, mScene);
	// run
	if(cocos2d::CCDirector::sharedDirector()->getRunningScene())
		cocos2d::CCDirector::sharedDirector()->replaceScene(scene);
	else
		cocos2d::CCDirector::sharedDirector()->runWithScene(mScene);
	//

	//_loadPopPage();

	int roleItemID = ServerDateManager::Get()->getLoginInfo().m_iRoleItemID;
	//如果roleItemID = 0, 表示??有?建角色，?需要?入角色?取?面，否?，直接?入MainScenePage
	if (roleItemID == 0)
	{
		//_showPage("ChooseRolePage");
		pushPage("ChooseRolePage");
		//pushPage("PromptPage");
		isInChooseRolePage = true;//search it, when reenter not need _initFightPage
	}
	else
	{
		isInChooseRolePage = false;
		//_initFightPage();
		popAllPage();
		_showPage("MainScenePage");
	}
	//
	libPlatformManager::getPlatform()->notifyEnterGame();
	//
	setBackgroundColor(0, 0, 0, 1);
	GamePrecedure::Get()->closeMovie("LoadingFrame");	// 關閉OP
	return;
}

void MainFrame::Enter( GamePrecedure* )
{
	if (mScene != NULL)
	{
		reEnter(NULL);
		return;
	}
    libPlatformManager::getPlatform()->registerListener(this);

	MessageManager::Get()->regisiterMessageHandler(MSG_MAINFRAME_CHANGEPAGE,this);
	MessageManager::Get()->regisiterMessageHandler(MSG_MAINFRAME_POPPAGE,this);
	MessageManager::Get()->regisiterMessageHandler(MSG_MAINFRAME_PUSHPAGE,this);
	MessageManager::Get()->regisiterMessageHandler(MSG_SEVERINFO_UPDATE,this);
	MessageManager::Get()->regisiterMessageHandler(MSG_MAINFRAME_COVERSHOW,this);
	MessageManager::Get()->regisiterMessageHandler(MSG_MAINFRAME_COVERHIDE,this);
	MessageManager::Get()->regisiterMessageHandler(MSG_MAINFRAME_MSGSHOW,this);
	
	mScene = CCScene::create();
	mScene->retain();

	load();
    cocos2d::extension::CCScrollView* view = 0;
	cocos2d::CCObject* viewNode = this->getVariable("mMainbuttons");
	if(viewNode)
	{
		view = dynamic_cast<cocos2d::extension::CCScrollView*>(viewNode);
		if(view)
		{
			view->setContentOffsetInDuration(view->maxContainerOffset(),0.5f);
			view->setDelegate(&sMainframeScrollviewController);
			view->setBounceable(false);
		}
	}


	mScene->addChild(this);

	m_pStateMachine = new StateMachine<MainFrame>(this);
	
	CCDirector::sharedDirector()->setDepthTest(true);
	cocos2d::CCScene * scene =  cocos2d::CCTransitionFade::create(1.0f,mScene);
	// run
	if(cocos2d::CCDirector::sharedDirector()->getRunningScene())
		cocos2d::CCDirector::sharedDirector()->replaceScene(scene);
	else
		cocos2d::CCDirector::sharedDirector()->runWithScene(mScene);

	LoadingFrame* loadingFrame = dynamic_cast<LoadingFrame*>(CCBManager::Get()->getPage("LoadingFrame"));
	if (loadingFrame)
	{
		cocos2d::CCLog("loading frame mScene retainCount:%d", loadingFrame->retainCount());
	}
	
	int roleItemID = ServerDateManager::Get()->getLoginInfo().m_iRoleItemID;
	//如果roleItemID = 0, 表示??有?建角色，?需要?入角色?取?面，否?，直接?入MainScenePage
	if (roleItemID ==0)
	{
		//_showPage("ChooseRolePage");
		pushPage("ChooseRolePage");
		//pushPage("PromptPage");
		isInChooseRolePage = true;

	}
	else
	{
		isInChooseRolePage = false;
		//_initFightPage();
		_showPage("MainScenePage");
	}

    libPlatformManager::getPlatform()->notifyEnterGame();
	//setBackgroundColor(0, 0, 0, 1);
	GamePrecedure::Get()->closeMovie("LoadingFrame");	// 關閉OP
}

void MainFrame::Exit( GamePrecedure* )
{
	//mScene->setVisible(false);
	return;
	//
	popAllPage();
	removeAllPageFromNode(mNodeMsg);
	removeAllPageFromNode(mNodeMsgForLua);
	removeAllPageFromNode(mNodeMid);
	removeAllPageFromNode(mNodeBack);
	removeAllPageFromNode(mNodeFront);
	removeAllPageFromNode(mNoTouch);
	removeAllPageFromNode(mNodeFight);

	MessageManager::Get()->removeMessageHandler(this);
	libOS::getInstance()->removeListener(this);
	libPlatformManager::getPlatform()->removeListener(this);

	if(m_pStateMachine)
	{
		m_pStateMachine->CurrentState()->Exit(this);
		delete m_pStateMachine;
		m_pStateMachine = 0;
	}

	if ( mFightPage )
	{
		mFightPage->unload();
		State<MainFrame>* sta = dynamic_cast<State<MainFrame>*>(mFightPage);
		if ( sta )
		{
			sta->Execute(this);
		}
	}
	BasePage* mainpage = CCBManager::Get()->getPage("MainScenePage");
	if(mainpage)
		mainpage->unload();

	MessageManager::Get()->removeMessageHandler(this);
	mScene->release();	
	unload();
	mScene->removeAllChildrenWithCleanup(true);
	cocos2d::CCLog("main frame mScene retainCount:%d", mScene->retainCount());
}

void MainFrame::Execute( GamePrecedure* )
{
	//登?播放主?ccb按???
	do 
	{
		if(!BlackBoard::getInstance()->hasVarible("assemblyFinish"))
			break;
		if(!BlackBoard::getInstance()->getVaribleAsBool("assemblyFinish"))
			break;
		BlackBoard::getInstance()->delVarible("assemblyFinish");
// 		CCMenuItemCCBFile* mButton = dynamic_cast<CCMenuItemCCBFile*>(this->getVariable("mMainPageBtn"));
// 		if(mButton==NULL)
// 			break;
// 		if (mButton->getCCBFile()==NULL)
// 			break;
// 		mButton->changeState("TouchBegin");
	} while (false);

	if(m_pStateMachine)
		m_pStateMachine->Update();

	if ( mFightPage )
	{
		State<MainFrame>* sta = dynamic_cast<State<MainFrame>*>(mFightPage);
		if ( sta )
		{
			sta->Execute(this);
		}
	}


	if (isInChooseRolePage && GamePrecedure::Get()->getLoginAssemblyFinished())
	{
		popAllPage();
		//_initFightPage();
		_showPage("MainScenePage");
		isInChooseRolePage = false;
	}

	static float durationTime=0;
	static float durationTimeTip=0;
	durationTime+=GamePrecedure::Get()->getFrameTime();
	durationTimeTip+=GamePrecedure::Get()->getFrameTime();
	static float delayRemoveLoadingRes = 0.f;
	static bool bDone = false;
	delayRemoveLoadingRes += GamePrecedure::Get()->getFrameTime();
	if (!bDone && delayRemoveLoadingRes > 5.f)
	{
		bDone = true;
		//if (InstructionManager::Get()->serverInstructionDone() || InstructionManager::Get()->loadLocalInstructionStep() >= InstructionManager::TOTAL_INSTRUCTION)
		{
			CCSpriteFrameCache::sharedSpriteFrameCache()->removeUnusedSpriteFramesPerFrame();
			CCTextureCache::sharedTextureCache()->removeUnusedTexturesPerFrame();
			cocos2d::CCLog("clean SpriteFrameCache&TextureCache after enter MainFrame");
		}
	}

	//MainFrame::handleVoiceChat();
	//--end
}

void MainFrame::handleVoiceChat()
{
	//#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
	/*
		if (libVoiceChat::getInstance()->voiceChatLoginResultInfo.isLoginResult)
		{
			libVoiceChat::getInstance()->voiceChatLoginResultInfo.isLoginResult = false;
			cocos2d::CCScriptEngineManager::sharedManager()->getScriptEngine()
				->executeGlobalFunctionByName("VoiceChat_NotifyLoginResult", NULL, "VoiceChat_NotifyLoginResult()");
			CCLOG("VoiceChatManager-login C++:" + libVoiceChat::getInstance()->voiceChatLoginResultInfo.result);
		}

		if (libVoiceChat::getInstance()->voiceChatLogoutResultInfo.isLogoutResult)
		{
			libVoiceChat::getInstance()->voiceChatLogoutResultInfo.isLogoutResult = false;
			cocos2d::CCScriptEngineManager::sharedManager()->getScriptEngine()
				->executeGlobalFunctionByName("VoiceChat_NotifyLougoutResult", NULL, "VoiceChat_NotifyLougoutResult()");
		}

		if (libVoiceChat::getInstance()->voiceChatVoiceMsgInfo.isVoiceMsg)
		{
			CCLOG("VoiceChatManager-login C++:voiceChatVoiceMsgInfo");
			libVoiceChat::getInstance()->voiceChatVoiceMsgInfo.isVoiceMsg = false;
			cocos2d::CCScriptEngineManager::sharedManager()->getScriptEngine()
				->executeGlobalFunctionByName("VoiceChat_NotifyVoiceMessage", NULL, "VoiceChat_NotifyVoiceMessage()");
		}

		if (libVoiceChat::getInstance()->voiceChatUploadVoiceMessage.isUploadVoice)
		{
			libVoiceChat::getInstance()->voiceChatUploadVoiceMessage.isUploadVoice = false;
			cocos2d::CCScriptEngineManager::sharedManager()->getScriptEngine()
				->executeGlobalFunctionByName("VoiceChat_UploadVoiceMessage", NULL, "VoiceChat_UploadVoiceMessage()");
		}

		if(libVoiceChat::getInstance()->voiceChatSendTextMessage.isSendTextMessage)
		{
			libVoiceChat::getInstance()->voiceChatSendTextMessage.isSendTextMessage = false;
			cocos2d::CCScriptEngineManager::sharedManager()->getScriptEngine()
				->executeGlobalFunctionByName("VoiceChat_SendTextMessage", NULL, "VoiceChat_SendTextMessage()");
		}

		if (libVoiceChat::getInstance()->voiceChatReceiveTextMessage.isReceive)
		{
			libVoiceChat::getInstance()->voiceChatReceiveTextMessage.isReceive = false;
			cocos2d::CCScriptEngineManager::sharedManager()->getScriptEngine()
				->executeGlobalFunctionByName("VoiceChat_ReceiveTextMessage", NULL, "VoiceChat_ReceiveTextMessage()");
		}

		if (libVoiceChat::getInstance()->voiceChatVoiceAndTextInfo.isNotify)
		{
			libVoiceChat::getInstance()->voiceChatVoiceAndTextInfo.isNotify = false;
			cocos2d::CCScriptEngineManager::sharedManager()->getScriptEngine()
				->executeGlobalFunctionByName("VoiceChat_VoiceAndTextInfo", NULL, "VoiceChat_VoiceAndTextInfo()");
		}

		if (libVoiceChat::getInstance()->voiceChatBdMineTxtMsg.isNotify)
		{
			libVoiceChat::getInstance()->voiceChatBdMineTxtMsg.isNotify = false;
			cocos2d::CCScriptEngineManager::sharedManager()->getScriptEngine()
				->executeGlobalFunctionByName("VoiceChat_BdMineTxtMsg", NULL, "VoiceChat_BdMineTxtMsg()");
		}

*/
	//#endif

	
}

void MainFrame::onReceiveMassage( const GameMessage * message )
{
	if(message->getTypeId() == MSG_MAINFRAME_CHANGEPAGE)
	{
		const MsgMainFrameChangePage * msg = dynamic_cast<const MsgMainFrameChangePage*>(message);
		if(msg)
		{
			if(msg->needPopAllPage)
				popAllPage();
			_showPage(msg->pageName);
		}
	}
	else if(message->getTypeId() == MSG_MAINFRAME_PUSHPAGE)
	{
		const MsgMainFramePushPage * msg = dynamic_cast<const MsgMainFramePushPage*>(message);
		if(msg)
		{
			pushPage(msg->pageName);
		}
	}
	else if(message->getTypeId() == MSG_MAINFRAME_POPPAGE)
	{
		const MsgMainFramePopPage * msg = dynamic_cast<const MsgMainFramePopPage*>(message);
		if(msg)
		{
			if(msg->pageName == "popAllPage")
				popAllPage();
			else
				popPage(msg->pageName);
		}
	}
	else if(message->getTypeId()==MSG_SEVERINFO_UPDATE)
	{
		//const MsgSeverInfoUpdate * msg = dynamic_cast<const MsgSeverInfoUpdate*>(message);
		//if ( msg )
		//{
		//	unsigned int opcode = msg->opcode;
		//	if ( opcode == ROLE_CREATE_S )
		//	{
		//		//_initFightPage();
		//	}
		//	//if(msg->opcode==OPCODE_CS_USER_KICKOUT)
		//	//{
		//	//	std::string _outStr=Language::Get()->getString("@UserKickoutMsg");
		//	//	GamePrecedure::Get()->setUserKickedByServer();
		//	//	libOS::getInstance()->registerListener(this);
		//	//	libOS::getInstance()->showMessagebox(_outStr,UserKickout);
		//	//}
		//}
	}
	else if(message->getTypeId() == MSG_MAINFRAME_COVERSHOW)
	{
		const MsgMainFrameCoverShow * msg = dynamic_cast<const MsgMainFrameCoverShow*>(message);
		if(msg)
		{
			cocos2d::CCLog("************showCover");
			showCover(msg->pageName);
		}
	}
	else if(message->getTypeId() == MSG_MAINFRAME_COVERHIDE)
	{
		cocos2d::CCLog("************hideCover");
		hideCover();
	}
	else if(message->getTypeId() == MSG_MAINFRAME_MSGSHOW)
	{
		const MsgMainFrameMSGShow * msg = dynamic_cast<const MsgMainFrameMSGShow*>(message);
		if(msg)
		{
			showMsg();
		}
	}
}

void MainFrame::showPage( const std::string& name )
{
    BasePage* page = CCBManager::Get()->getPage(name);
	if(!page || page == mCurShowPage)
		return;
	MsgMainFrameChangePage msg;
	msg.pageName = name;
	MessageManager::Get()->sendMessage(&msg);
	SoundManager::getInstance()->playGeneralMusic();
}

void MainFrame::showFightPage()
{

	if ( m_pStateMachine )
	{
		m_pStateMachine->ChangeState(NULL);
	}

	if ( mCurShowPage )
	{
		mCurShowPage->onBringToBackend();
		mCurShowPage->unload();
		mNodeBack->removeAllChildrenWithCleanup(true);
		mCurShowPage = NULL;
		mCurShowPageName = "";
	}
	if (!VaribleManager::getInstance()->getSetting("BattleMusic").empty())
		SoundManager::getInstance()->playMusic(VaribleManager::getInstance()->getSetting("BattleMusic"));
	mNodeFight->setVisible(true);
	cocos2d::CCLuaEngine* pEngine = cocos2d::CCLuaEngine::defaultEngine();
	if(pEngine)
	{
		pEngine->executeGlobalFunctionByName("BattlePage_ShowFightPage",this,"MainFrame");
	}
}

void MainFrame::_initFightPage()
{
	BasePage* page = CCBManager::Get()->getPage(BATTLE_PAGE_NAME);
	if ( page )
	{
		if (mFightPage)
		{
			return;
		}
		mFightPage = page;

		mFightPage->load();

		State<MainFrame>* sta = dynamic_cast<State<MainFrame>*>(mFightPage);
		if ( sta )
		{
			sta->Enter(this);
		}

		if ( mNodeFight )
		{
			mNodeFight->addChild(mFightPage);
		}
	}
}

void MainFrame::_showPage( const std::string& name )
{
	BasePage* page = CCBManager::Get()->getPage(name);
	if(!page || page == mCurShowPage)
		return;
	
	State<MainFrame>* sta = dynamic_cast<State<MainFrame>*>(page);
	if(sta)
	{
		page->load();

		m_pStateMachine->ChangeState(sta);
		//_setContent(page);
		if(mCurShowPage!=page)
		{
			mNodeBack->removeAllChildrenWithCleanup(true);
			//page->setPositionY(page->getContentSize().height > 1280 ? (page->getContentSize().height - 1280) * -0.5 : 0);
			//page->setPositionX(page->getContentSize().width > 720 ? (page->getContentSize().width - 720) * -0.5 : 0);
			mNodeBack->addChild(page);
		}
		
		if(mCurShowPage && mCurShowPage!=page)
		{
			mCurShowPage->onBringToBackend();
			mCurShowPage->unload();
			mCurShowPage->removeAllChildrenWithCleanup(true);	
		}

		mCurShowPage = page;
		mCurShowPage->onBringToFronted();
		mLastChangePageName=mCurShowPageName;
		mCurShowPageName = name;

		g_AppDelegate->notifyRecycleTex();
		if(mNodeFight->isVisible())
		{
			mNodeFight->setVisible(false);
			cocos2d::CCLuaEngine* pEngine = cocos2d::CCLuaEngine::defaultEngine();
			if(pEngine)
			{
				pEngine->executeGlobalFunctionByName("BattlePage_HideFightPage",this,"MainFrame");
			}
		}
	}
	std::string music_str = "general.mp3";

	if (name == "GVGMapPage")
	{
		music_str = "GVG_Bg.mp3";
	}
	else if (name == "WorldBossPage")
	{
		music_str = "WorldBoss_Bg.mp3";
	}
	//else if(name == "NewBattlePage")
	//{
	//	music_str = "battle.mp3";
	//}
	if (name != "NgBattlePage") {
		SoundManager::getInstance()->playMusic(music_str);
	}
}

void MainFrame::setBlurEnabled(bool b)
{
	if (b)
	{
		if (mCurShowPage)
		{
			if (mCurShowPage->getChildByTag(BLUR_TAG))
			{
				return;
			}
			CCSprite* blur = BlurSpriteMgr::createBlurSprite(mCurShowPage,mCurShowPage->getContentSize());
			if (blur)
			{
				blur->setPosition(ccp(mCurShowPage->getContentSize().width/2.0f,mCurShowPage->getContentSize().height/2.0f));
				blur->setAnchorPoint(ccp(0.5f,0.5f));
				blur->setTag(BLUR_TAG);			
				mCurShowPage->addChild(blur);	
			}			
		}		
	}
	else
	{
		if (mCurShowPage && mCurShowPage->getChildByTag(BLUR_TAG))
		{
			mCurShowPage->removeChildByTag(BLUR_TAG);
		}	
	}
}

void MainFrame::setBlurEnabledForMultiPush(bool b)
{
    if(!mNodeMid)
    {
        return;
    }
	if (b)
	{
		CCNode* node = mNodeMid->getChildByTag(PUSH_TAG_BLUR);
		if (node)
		{
			CCSprite* blur = BlurSpriteMgr::createBlurSprite(node,node->getContentSize());
			if (blur)
			{
				blur->setPosition(ccp(node->getContentSize().width/2.0f,node->getContentSize().height/2.0f));
				blur->setAnchorPoint(ccp(0.5f,0.5f));
				blur->setTag(BLUR_TAG);			
				mNodeMid->addChild(blur);	
			}			
		}		
	}
	else
	{
		if (mNodeMid->getChildByTag(BLUR_TAG))
		{
			mNodeMid->removeChildByTag(BLUR_TAG);
		}
	}
}

void MainFrame::onScaleToShowDone(CCNode* node,void* param)
{
	BasePage* page = (BasePage*)param;
	if (page)
	{
		State<MainFrame>* sta = dynamic_cast<State<MainFrame>*>(page);
		if(sta)
		{
			m_pStateMachine->AddGlobalState(sta);//sta->Enter(this);
		}
	}
}

void MainFrame::pushPage( const std::string& name )
{
	PageStruct* pageStruct = getPageFromPageList(name);
	if(pageStruct)
	{
		mNodeMid->removeChild(pageStruct->mBasePage,false);
		if (name == "TransScenePopUp")
			mNodeMid->addChild(pageStruct->mBasePage, 999);
		else
			mNodeMid->addChild(pageStruct->mBasePage);
		return;
	}
	BasePage* page = CCBManager::Get()->getPage(name);
	if(!page)
		return;
		
	page->load();


	PushPageItem* item = PushPageTableManager::Get()->getPushPageByName(name);
	if (item)
	{	
		/*switch(item->blurType)
		{
		case BlurType_PushSingle:
		{
		setBlurEnabled(true);
		}
		break;
		case BlueType_PushMulti:
		{
		setBlurEnabledForMultiPush(true);
		}
		break;
		default:
		break;
		}*/
	}

	//page->setPositionY(page->getContentSize().height > 1280 ? (page->getContentSize().height - 1280) * -0.5 : 0);
	//page->setPositionX(page->getContentSize().width > 720 ? (page->getContentSize().width - 720) * -0.5 : 0);

	if (name == "TransScenePopUp")
		mNodeMid->addChild(page, 999);
	else
		mNodeMid->addChild(page);
	page->setTag(PUSH_TAG_BLUR);
	//mPageList.insert(PageList::value_type(name,page));
	addPageToPageList(name,page);

	cocos2d::CCLayer* layer = CCLayer::create();
	//layer->setContentSize(CCDirector::sharedDirector()->getOpenGLView()->getVisibleSize());
	//CCSize maxsize(738.0f,1152.0f);
	CCSize maxsize(720.0f, 1280.0f);
	layer->setContentSize(maxsize);
	layer->setPosition(0,0);
	layer->setAnchorPoint(ccp(0,0));
	layer->setTouchEnabled(true);
	layer->setTouchMode(cocos2d::kCCTouchesOneByOne);
	layer->setTag(PUSH_TAG_LAYER);
	page->addChild(layer, -100);	

	if (item && item->isPushAni)
	{
		if (item->isBeforeEnter)
		{
			CCCallFuncND* func = CCCallFuncND::create(this,callfuncND_selector(MainFrame::onScaleToShowDone),page);
			CCNode* node = dynamic_cast<CCNode*>(page->getVariable("mPushAnimNode"));
			if (node)
			{
				AnimMgr::Get()->scaleToShow(node,0.0f,node->getScale(),func);
			}
			else
			{
				AnimMgr::Get()->scaleToShow(page,0.0f,page->getScale(),func);
			}
		}
		else
		{
			if (page)
			{
				State<MainFrame>* sta = dynamic_cast<State<MainFrame>*>(page);
				if(sta)
				{
					m_pStateMachine->AddGlobalState(sta);//sta->Enter(this);
				}
			}

			CCNode* node = dynamic_cast<CCNode*>(page->getVariable("mPushAnimNode"));
			if (node)
			{
				AnimMgr::Get()->scaleToShow(node,0.0f,node->getScale(),NULL);
			}
			else
			{
				AnimMgr::Get()->scaleToShow(page,0.0f,page->getScale(),NULL);
			}
		}
		
	}
	else
	{		
		if (page)
		{
			State<MainFrame>* sta = dynamic_cast<State<MainFrame>*>(page);
			if(sta)
			{
				m_pStateMachine->AddGlobalState(sta);//sta->Enter(this);
			}
		}
	}	
}

void MainFrame::doPopPageByName(CCNode* node,void* param)
{
	std::string* pName = static_cast<std::string*>(param);
	std::string name = *pName;
	PageStruct* pPageStruct = getPageFromPageList(name);
	if(pPageStruct)
	{		
		State<MainFrame>* sta = dynamic_cast<State<MainFrame>*>(pPageStruct->mBasePage);
		if(sta)
			m_pStateMachine->removeGlobalState(sta);//sta->Exit(this);

		if(pPageStruct->mBasePage)
			pPageStruct->mBasePage->unload();

		mNodeMid->removeChild(pPageStruct->mBasePage,false);
		removePageFromPageList(name);
	}

	delete pName;
}

void MainFrame::popPage(const std::string& name)
{	
	PageStruct* pPageStruct = getPageFromPageList(name);
	if(pPageStruct)
	{
		PushPageItem* item = PushPageTableManager::Get()->getPushPageByName(name);
		if (item)
		{
			switch(item->blurType)
			{
			case BlurType_PushSingle:
				{
					setBlurEnabled(false);
				}
				break;
			case BlueType_PushMulti:
				{
					setBlurEnabledForMultiPush(false);
				}
				break;
			default:
				break;
			}
		}
		if (item && item->isPopAni)
		{
			CCCallFuncND* func = CCCallFuncND::create(this,callfuncND_selector(MainFrame::doPopPageByName),static_cast<void*>(new std::string(name)));
			CCNode* node = dynamic_cast<CCNode*>(pPageStruct->mBasePage->getVariable("mPushAnimNode"));
			if (node)
			{
				AnimMgr::Get()->scaleToHide(node,node->getScale(),func);
			}
			else
			{
				AnimMgr::Get()->scaleToHide(pPageStruct->mBasePage,pPageStruct->mBasePage->getScale(),func);
			}
		}
		else
		{
			doPopPageByName(pPageStruct->mBasePage,static_cast<void*>(new std::string(name)));
		}		
	}	
}

void MainFrame::doPopPageByPage(CCNode* node,void* param)
{
	BasePage* page = dynamic_cast<BasePage*>(node);
	if (!page)
	{
		return;
	}
	PageList::iterator itr = mPageList.begin();
	while(itr != mPageList.end())
	{
		if((*itr)->mBasePage == page)
		{
			State<MainFrame>* sta = dynamic_cast<State<MainFrame>*>((*itr)->mBasePage);
			if(sta)
				m_pStateMachine->removeGlobalState(sta);//sta->Exit(this);
			if((*itr)->mBasePage)
				(*itr)->mBasePage->unload();
			mNodeMid->removeChild((*itr)->mBasePage,false);
			delete *itr;
			mPageList.erase(itr);		

			return;
		}

		++itr;
	}
}

void MainFrame::popPage(BasePage* page)
{
	if (!page)
	{
		return;
	}
	PushPageItem* item = PushPageTableManager::Get()->getPushPageByName(page->mPageName);
	if (item)
	{
		switch(item->blurType)
		{
		case BlurType_PushSingle:
			{
				setBlurEnabled(false);
			}
			break;
		case BlueType_PushMulti:
			{
				setBlurEnabledForMultiPush(false);
			}
			break;
		default:
			break;
		}
	}
	
	if (item && item->isPopAni)
	{
		CCCallFuncND* func = CCCallFuncND::create(this,callfuncND_selector(MainFrame::doPopPageByPage),NULL);
		CCNode* node = dynamic_cast<CCNode*>(page->getVariable("mPushAnimNode"));
		if (node)
		{
			AnimMgr::Get()->scaleToHide(node,node->getScale(),func);
		}	
		else
		{
			AnimMgr::Get()->scaleToHide(page,page->getScale(),func);
		}
	}
	else
	{
		doPopPageByPage(page,NULL);
	}
}

void MainFrame::popAllPage()
{
	PageList::iterator itr = mPageList.begin();
	while(itr != mPageList.end())
	{
		State<MainFrame>* sta = dynamic_cast<State<MainFrame>*>((*itr)->mBasePage);
		if(sta)
			m_pStateMachine->removeGlobalState(sta);//sta->Exit(this);
		
		if((*itr)->mBasePage)
			(*itr)->mBasePage->unload();

		mNodeMid->removeChild((*itr)->mBasePage,false);
		delete *itr;
		++itr;
	}
	mPageList.clear();

	setBlurEnabled(false);
	setBlurEnabledForMultiPush(false);
}

bool MainFrame::isPageInList(BasePage* page)
{
	PageList::iterator itr = mPageList.begin();
	while(itr != mPageList.end())
	{
		if((*itr)->mBasePage == page)
			return true;

		++itr;
	}
	return false;
}

bool MainFrame::isPageInList(const std::string& name)
{
	PageList::iterator itr = mPageList.begin();
	while(itr != mPageList.end())
	{
		if((*itr)->mName == name)
			return true;

		++itr;
	}

	return false;
}

void MainFrame::resetAllMenuCCBI()
{
	CCB_FUNC(this,"mMainPageBtn",CCMenuItemCCBFile,runExtraAnimation("Normal"));
	CCB_FUNC(this,"mBattlePageBtn",CCMenuItemCCBFile,runExtraAnimation("Normal"));
	CCB_FUNC(this,"mEquipmentPageBtn",CCMenuItemCCBFile,runExtraAnimation("Normal"));
	CCB_FUNC(this,"mBackpackPageBtn",CCMenuItemCCBFile,runExtraAnimation("Normal"));
	CCB_FUNC(this,"mSkillPageBtn",CCMenuItemCCBFile,runExtraAnimation("Normal"));
	CCB_FUNC(this,"mMercenaryPageBtn",CCMenuItemCCBFile,runExtraAnimation("Normal"));
}

void MainFrame::onMenuItemAction( const std::string& itemName ,cocos2d::CCObject* sender)
{
	/*
	if(itemName == "onMainPageBtn")
	{
		//GamePrecedure::Get()->reEnterLoading();
		//return;
		//
		resetAllMenuCCBI();
		CCB_FUNC(this,"mMainPageBtn",CCMenuItemCCBFile,runExtraAnimation("TouchBegin"));

		popAllPage();
		showPage("MainScenePage");
	}
	else if(itemName == "onBattlePageBtn")
	{
		resetAllMenuCCBI();
		CCB_FUNC(this,"mBattlePageBtn",CCMenuItemCCBFile,runExtraAnimation("TouchBegin"));
		popAllPage();
		showFightPage();
	}else if(itemName == "onEquipmentPageBtn")
	{
		resetAllMenuCCBI();
		CCB_FUNC(this,"mEquipmentPageBtn",CCMenuItemCCBFile,runExtraAnimation("TouchBegin"));
	}else if(itemName == "onBackpackPageBtn")
	{
		resetAllMenuCCBI();
		CCB_FUNC(this,"mBackpackPageBtn",CCMenuItemCCBFile,runExtraAnimation("TouchBegin"));
	}else if(itemName == "onSkillPageBtn")
	{
		resetAllMenuCCBI();
		CCB_FUNC(this,"mSkillPageBtn",CCMenuItemCCBFile,runExtraAnimation("TouchBegin"));
	}else if(itemName == "onMercenaryPageBtn")
	{
		RoleInfo roleInfo = ServerDateManager::Get()->getUserRoleInfo();
		unsigned int levelLimit = StringConverter::parseInt(VaribleManager::getInstance()->getSetting("MercenaryEnterLevel"), 15);
		if (roleInfo.level() >= levelLimit)
		{
			resetAllMenuCCBI();
			CCB_FUNC(this,"mMercenaryPageBtn",CCMenuItemCCBFile,runExtraAnimation("TouchBegin"));
		}
		else
		{
			CCB_FUNC(this,"mMercenaryPageBtn",CCMenuItemCCBFile,runExtraAnimation("Normal"));
		}
	}else if (itemName == "onTeamPageBtn")
	{
	}else if (itemName == "onGuildPageBtn")
	{
	}
	*/
	cocos2d::CCObject* viewNode = this->getVariable("mMainbuttons");
	cocos2d::extension::CCScrollView* view = viewNode?dynamic_cast<cocos2d::extension::CCScrollView*>(viewNode):0;
	CCTouchHandler* pHandler = CCDirector::sharedDirector()->getTouchDispatcher()->findHandler(view);
	if (pHandler)
	{
		CCTargetedTouchHandler* pTh = dynamic_cast<CCTargetedTouchHandler*>(pHandler);
		if (pTh)
		{
			pTh->setSwallowsTouches(true);
		}
	}

	static std::string buttonenable =  VaribleManager::getInstance()->getSetting("MainFrameScrollButEnable","","true");
	if(view && itemName == "onBottomR" && buttonenable == "true")
	{
		view->setContentOffsetInDuration(view->minContainerOffset(),0.3f);
		CCB_FUNC(this,"mBottomL",cocos2d::CCNode,setVisible(true));
		CCB_FUNC(this,"mBottomR",cocos2d::CCNode,setVisible(false));
	}
	else if(view && itemName == "onBottomL"  && buttonenable == "true")
	{
		view->setContentOffsetInDuration(view->maxContainerOffset(),0.3f);
		CCB_FUNC(this,"mBottomL",cocos2d::CCNode,setVisible(false));
		CCB_FUNC(this,"mBottomR",cocos2d::CCNode,setVisible(true));
	}
	//
	//g_AppDelegate->checkMemoryWarning(true);
	//
}

void MainFrame::load( void )
{
	loadCcbiFile("MainFrame.ccbi");
	//只針對高度resize
	CCNode* rootNode = dynamic_cast<CCNode*>(getVariable("mMainFrameRoot"));
	rootNode->setContentSize(CCSize(720.0f, rootNode->getContentSize().height));
	mNodeMid = dynamic_cast<CCNode*>(getVariable("mNodeMid"));
	mNodeBack = dynamic_cast<CCNode*>(getVariable("mNodeBack"));
	mNodeFront = dynamic_cast<CCNode*>(getVariable("mNodeFront"));

	mNodeFight = dynamic_cast<CCNode*>(getVariable("mNodeFight"));
	mNodeMsg = dynamic_cast<CCNode*>(getVariable("mNodeMsg"));

	mNodeMsgForLua = dynamic_cast<CCNode*>(getVariable("mPromptAniNode"));
	mMainFrameButtons = dynamic_cast<CCNode*>(getVariable("mMainFrameButtons"));


	mNoTouch=dynamic_cast<CCLayer*>(getVariable("mNoTouch"));
	mNoTouch->setContentSize(CCDirector::sharedDirector()->getOpenGLView()->getVisibleSize());
	mNoTouch->setPosition(0,0);
	mNoTouch->setAnchorPoint(ccp(0,0));
	mNoTouch->setTouchEnabled(false);
	mNoTouch->setVisible(false);
	mNoTouch->setTouchMode(cocos2d::kCCTouchesOneByOne);

	mNodeFight->setVisible(false);
}

void MainFrame::showCover(const std::string& pagename)
{
	BasePage* page = CCBManager::Get()->getPage(pagename.c_str());
	if(!page)
		return;

	if(mNodeFront && mNodeFront->getChildren() && mNodeFront->getChildren()->count()>0)
	{
		for (unsigned int i=0;i<mNodeFront->getChildren()->count();i++)
		{
			BasePage* childPage = dynamic_cast<BasePage*>(mNodeFront->getChildren()->objectAtIndex(i));
			if (childPage == page)
				return;
		}		
	}
	
	State<MainFrame>* sta = dynamic_cast<State<MainFrame>*>(page);
	if(sta)
	{
		hideCover();

		page->load();
		page->removeFromParent();
		m_pStateMachine->AddGlobalState(sta);
		//_setContent(page);		//mNodeFront->removeAllChildrenWithCleanup(false);
		cocos2d::CCLayer* layer = CCLayer::create();
		layer->setContentSize(CCDirector::sharedDirector()->getOpenGLView()->getVisibleSize());
		layer->setPosition(0,0);
		layer->setAnchorPoint(ccp(0,0));
		layer->setTouchEnabled(true);
		layer->setTouchMode(cocos2d::kCCTouchesOneByOne);
		page->addChild(layer, -1);
		mNodeFront->addChild(page);

		if (mCurShowPage)
			mCurShowPage->onBringToBackend();
		//??LoadingAniPage 等待?面 ?行特殊?理，不需要?藏背景?面，
		if (pagename == "LoadingAniPage")
		{
			mNodeMid->setVisible(true);
			//mNodeBack->setVisible(true);
			//mMainFrameButtons->setVisible(true);
			
		}else{
			//mCurShowPage = page;
			mNodeMid->setVisible(false);
			//mNodeBack->setVisible(false);
			//mMainFrameButtons->setVisible(false);
		}
		
	}
}

void MainFrame::hideCover()
{
	if(mNodeFront && mNodeFront->getChildren() && mNodeFront->getChildren()->count()>0)
	{
		CCObject* obj = mNodeFront->getChildren()->objectAtIndex(0);
		if (obj)
		{
			State<MainFrame>* sta = obj ? dynamic_cast<State<MainFrame>*>(obj) : 0;
			if (sta)
			{
				m_pStateMachine->removeGlobalState(sta);
			}

			BasePage* bp = obj ? dynamic_cast<BasePage*>(obj) : 0;
			if (bp)
			{
				bp->onBringToBackend();
				bp->unload();
			}
		}
        mNodeFront->removeAllChildrenWithCleanup(true);
	}

	mNodeMid->setVisible(true);
	//mNodeBack->setVisible(true);
	//mMainFrameButtons->setVisible(true);

	g_AppDelegate->notifyRecycleTex();
}

void MainFrame::showMsg()
{
	BasePage* page = MessageBoxPage::Get();
	if(!page)
		return;

	State<MainFrame>* sta = dynamic_cast<State<MainFrame>*>(page);
	if(sta)
	{
		m_pStateMachine->AddGlobalState(sta);
		//mNodeMsg->removeAllChildren();
		if(page->getParent() == NULL)
			mNodeMsg->addChild(page);
	}
}

void MainFrame::onPlatformLogout(libPlatform*)
{
    bool ok = true;
    if(!libPlatformManager::getPlatform()->getLogined())
        ok = false;
    if(libPlatformManager::getPlatform()->loginUin()!=GamePrecedure::Get()->getUin())
        ok = false;
    
    if(!ok)
    {
//        std::string outStr = Language::Get()->getString("@RELOGIN_ERROR");
		libOS::getInstance()->registerListener(this);
//        libOS::getInstance()->showMessagebox(outStr,RELOGIN_ERROR);
    }
}
void MainFrame::onMessageboxEnter(int tag)
{
    if(tag == RELOGIN_ERROR)
	{
		unsigned int exit2platlogout=0;
		const PlatformRoleItem* item=PlatformRoleTableManager::Get()->getPlatformRoleByName(libPlatformManager::getPlatform()->getClientChannel());
		if(item)
		{
			exit2platlogout=item->exit2platlogout;
		}
		if(exit2platlogout==1)
		{
			libPlatformManager::getPlatform()->logout();
		}
		exit(0);
	}
        
	if(tag == UserKickout)
	{
		unsigned int exit2platlogout=0;
		const PlatformRoleItem* item=PlatformRoleTableManager::Get()->getPlatformRoleByName(libPlatformManager::getPlatform()->getClientChannel());
		if(item)
		{
			exit2platlogout=item->exit2platlogout;
		}
		if(exit2platlogout==1)
		{
			libPlatformManager::getPlatform()->logout();
		}
		exit(0);
	}
	else
		libOS::getInstance()->removeListener(this);
        //lib91::getInstance()->switchUsers();
}

MainFrame* MainFrame::getInstance()
{
	return dynamic_cast<MainFrame*>(CCBManager::Get()->getPage("MainFrame"));
}

CCScene* MainFrame::getRootSceneNode()
{
	return mScene;
}

void MainFrame::showNoTouch()
{
	mNoTouch->setVisible(true);
	mNoTouch->setTouchEnabled(true);
}

void MainFrame::hideNoTouch()
{
	mNoTouch->setVisible(false);
	mNoTouch->setTouchEnabled(false);
}

void MainFrame::onRequestBindTryUserToOkUser( const char* tyrUin, const char* okUin )
{

}

void MainFrame::onTryUserRegistSuccess()
{
	BasePage* bp  = CCBManager::Get()->getPage("SettingsPage");
	if (bp)
	{
		cocos2d::extension::CCScrollView* settingsScrollView =  dynamic_cast<cocos2d::extension::CCScrollView*>(bp->getVariable("settings"));
		if(settingsScrollView)
		{
			CCBContainer* content = dynamic_cast<CCBContainer*>(settingsScrollView->getContainer()->getChildByTag(1));
			if (content)
			{
				CCLabelBMFont* gameCommunity = dynamic_cast<CCLabelBMFont*>(content->getVariable(("mGameCommunity")));
				if (gameCommunity)
				{
					if (libPlatformManager::getPlatform()->getIsTryUser())
					{
						gameCommunity->setString(Language::Get()->getString("@BindAccount").c_str());
					} 
					else
					{
						gameCommunity->setString(Language::Get()->getString("@GameCommunity").c_str());
					}
				}
			}
		}
	}
}

void MainFrame::removeAllPageFromNode(CCNode* node)
{
	if (node)
	{
		CCArray* children = node->getChildren();
		CCObject* child = NULL;
		CCARRAY_FOREACH(children, child)
		{
			BasePage* page = dynamic_cast<BasePage*>(child);
			if (page)
			{
				page->unload();
				page->removeFromParentAndCleanup(true);
			}
		}
		node->removeFromParentAndCleanup(true);
	}
}

void MainFrame::setChildVisible(const char* childName, bool visible)
{
	CCB_FUNC(this, childName, CCNode, setVisible(visible));
}

void MainFrame::onReLogin()
{
    GamePrecedure::getInstance()->reEnterLoading();
}
void MainFrame::setExpBar(float percent)
{
	CCScale9Sprite* expBar = dynamic_cast<CCScale9Sprite*>(this->getVariable("mExp"));
	if ( expBar )
	{
		if (percent>=1.0)
		{
			expBar->setScaleX(1.0);
		}
		else
		{
			expBar->setScaleX(percent);
		}
	}
}

PageStruct* MainFrame::getPageFromPageList( const std::string& name )
{
	PageList::iterator iter = mPageList.begin();
	for (; iter != mPageList.end(); ++iter)
	{
		if ((*iter)->mName == name)
		{
			return *iter;
		}
	}
	return NULL;
}

void MainFrame::removePageFromPageList( const std::string& name )
{
	PageList::iterator iter = mPageList.begin();
	for (; iter != mPageList.end(); ++iter)
	{
		if ((*iter)->mName == name)
		{
			delete *iter;
			mPageList.erase(iter);
			break;
		}
	}
}

void MainFrame::addPageToPageList( const std::string& name,BasePage* pBasePage )
{
	PageStruct* pPageStruct = new PageStruct(name,pBasePage);
	mPageList.push_back(pPageStruct);
}

bool MainFrame::popCurrentPage()
{
	if (mPageList.size() > 0)
	{
		PageStruct* pPageStruct = mPageList.back();
		//popPage(pPageStruct->mName);
		MsgMainFramePopPage msg;
		msg.pageName = pPageStruct->mName;

		if (msg.pageName.compare("ChooseRolePage") == 0)
		{
			return false;
		}
		MessageManager::getInstance()->sendMessage(&msg);
		return true;
	}
	return false;
}

void MainFrame::onShowMessageBox( const std::string& msgString, int tag )
{
	MessageHintPage::Msg_Hint(msgString,tag);
}

void MainFrame::setBackgroundColor(float r, float g, float b, float a)
{
	glClearColor(r, g, b, a);
	glClear(GL_COLOR_BUFFER_BIT);
}

int MainFrame::getPageNum()
{
	if (waitingManager::Get()->getWaiting()) {
		return 1;
	}
	return mPageList.size();
}

void MainFrame::addMovie(std::string pageName, std::string movieName, int isLoop, int autoScale)
{
	CCLog("MovieLog -- Add Movie : %s", pageName.c_str());
	MovieList::iterator iter = mMovieList.begin();
	bool isExit = false;
	for (; iter != mMovieList.end(); ++iter)
	{
		if ((*iter)->pageName == pageName) {
			if ((*iter)->movieName == movieName && (*iter)->loop == isLoop && (*iter)->autoScale == autoScale) {	// 已存在
				isExit = true;
			}
			else {
				// 播放設定不同 更新資訊
				(*iter)->movieName = movieName;
				(*iter)->loop = isLoop;
				(*iter)->autoScale = autoScale;
				isExit = true;
			}
		}
	}
	if (!isExit) {	// 該頁面沒有影片設定 -> 加入list
		MovieStruct* pMovieStruct = new MovieStruct(pageName, movieName, isLoop, autoScale);
		mMovieList.push_back(pMovieStruct);
	}
	// 關閉UI顯示
	if (pageName != "MainScenePage" && pageName != "EquipmentPage" &&
		pageName != "NgBattlePage" && pageName != "Lobby2Page") {
		if (mNodeBack) {
			mNodeBack->setVisible(false);
		}
		if (mMainFrameButtons) {
			mMainFrameButtons->setVisible(false);
		}
		CCLog("MovieLog -- UI Visible = False");
	}
	else {
		// 主頁UI不關NodeBack跟Buttons
		if (mNodeBack) {
			mNodeBack->setVisible(true);
		}
		if (mMainFrameButtons) {
			mMainFrameButtons->setVisible(true);
		}
		CCLog("MovieLog -- UI Visible = True");
	}
	setBackgroundColor(0, 0, 0, 0);
	// 設定隱藏下方pushPage顯示
	settingMoviePushPageVisible(pageName, PLAY_MOVIE);
}

void MainFrame::removeMovieByPage(std::string pageName)
{
	CCLog("MovieLog -- Remove Movie : %s", pageName.c_str());
	MovieList::iterator iter = mMovieList.begin();
	bool getTarget = false;
	for (; iter != mMovieList.end(); ++iter)
	{
		if ((*iter)->pageName == pageName) {
			delete *iter;
			iter = mMovieList.erase(iter);
			break;
		}
	}
	MovieList::iterator lastIter = mMovieList.end();
	if (!mMovieList.empty()) {
		lastIter = mMovieList.end();
		--lastIter; // 指向最後一個元素
	}
	// 開啟全部pushPage顯示
	settingMoviePushPageVisible("", CLOSE_MOVIE);
	// 移除後播放剩餘最上層影片
	if (lastIter != mMovieList.end()) {
		CCLog("MovieLog -- Play Next Movie : %s", (*lastIter)->pageName.c_str());
		GamePrecedure::Get()->playMovie((*lastIter)->pageName, (*lastIter)->movieName, (*lastIter)->loop, (*lastIter)->autoScale);
	}
	else {
		if (mNodeBack) {
			mNodeBack->setVisible(true);
		}
		if (mMainFrameButtons) {
			mMainFrameButtons->setVisible(true);
		}
		setBackgroundColor(0, 0, 0, 1);
	}
}

void MainFrame::settingMoviePushPageVisible(std::string pageName, int moviePlayType)
{
	PageList::iterator iter = mPageList.begin();
	bool getTarget = false;
	if (pageName == "MainScenePage" || pageName == "EquipmentPage" ||
		pageName == "NgBattlePage" || pageName == "Lobby2Page") {
		getTarget = true;
		CCLog("MovieLog -- Target is back movie");
	}
	for (; iter != mPageList.end(); ++iter)
	{
		if ((*iter)->mName == pageName)
		{
			getTarget = true;
			CCLog("MovieLog -- Target get");
		}
		if ((*iter)->mName == "TransScenePopUp") {	// 轉場UI永遠在最上層 -> 不關閉
			(*iter)->mBasePage->setVisible(true);
		}
		else if (moviePlayType == PLAY_MOVIE) {	// play
			if (!getTarget) {	// 只關閉目標頁面下層page顯示
				(*iter)->mBasePage->setVisible(false);
			}
			else {
				(*iter)->mBasePage->setVisible(true);
			}
		}
		else if (moviePlayType == CLOSE_MOVIE) {	// close
			(*iter)->mBasePage->setVisible(true);
		}
	}
}