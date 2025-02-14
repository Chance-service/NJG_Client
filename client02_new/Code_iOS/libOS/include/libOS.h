#pragma once
#include <string>
#include <set>
#include <map>

typedef void (*GetStringCallback)(std::string str);

typedef enum {
    NotReachable = 0,
    ReachableViaWiFi,
    ReachableViaWWAN
} NetworkStatus;

struct GAME_CONFIG_STU
{
    std::string gameid;      //项目ID
    std::string channel;     //渠道名
    std::string mta_key;     //MTA统计参数
    bool        mtaEnable;   //是否启用MTA统计
    bool        flurryEnable;//是否启用Flurry统计
    //   std::string dataeye_appid;
    //   bool        dataeyeEnable;
};

class libOSListener
{
public:
    virtual void onInputboxEnter(const std::string& content){}
    virtual void onInputboxCancel(const std::string& content){}
    virtual void onMessageboxEnter(int tag){}
    virtual void onShareEngineMessage(bool _result){}
    virtual void onPlayMovieEndMessage(){}
    virtual void onMotionShakeMessage() {}
    virtual void onPlayMovieLoadingDone() {}
	virtual void onCloseKeyboard(){}
	virtual void onOpenKeyboard(){}
	virtual void OnKeyboardHightChange(int nHight){}
    virtual std::string onInputboxEdit(const std::string& content)
    {
        std::string s(content);
        return s;
    }
	virtual void onFBShareBackMessage(bool success){};
	virtual void onShowMessageBox(const std::string& msgString, int tag){};
};

class libOS
{
public:
    
    libOS()
    {
        mAnalyticsOpen = false;
        mIsShareWC=false;
        mIsInPlayMovie = false;
        m_chatState = false;
        m_connector="";
    }
    void requestRestart();
    
    long avalibleMemory();
    void rmdir(const char* path);
    
    const std::string& generateSerial();
	void TheEditTextCloseKeyboardCallback(void* ctx);
	void TheEditTextOpenKeyboardCallback(void* ctx);
	void UpdateKeyboardHight(void* ctx, int nHight);
    void showInputbox(bool multiline, std::string content = "", bool chatState = false);
	void showInputbox(bool multiline,int InputMode, std::string content = "", bool chatState = false);//数字键盘fhr
	void showInputbox(bool multiline, int InputMode,int nMaxLength, std::string content = "", bool chatState = false);
    
//    void showInputbox(bool multiline, std::string content = "");
    void showMessagebox(const std::string& msg, int tag = 0);
    //    void showBulletinBoard(const std::string& url);
    
    void openURL(const std::string& url);
    void openURLHttps(const std::string& url);//appstore 大版本 lvpeizong
    void checkIosSDKVersion(const std::string& version, GetStringCallback p_callback);
    void emailTo(const std::string& mailto, const std::string & cc , const std::string& title, const std::string & body);
    
    void setWaiting(bool);
    
    long long getFreeSpace();
    
    NetworkStatus getNetWork();
    
    void clearNotification();
    void addNotification(const std::string& msg, int secondsdelay,bool daily = false);
    
    const std::string getDeviceID();
    const std::string getPlatformInfo();
    std::string getDeviceInfo();
    std::string getPackageNameToLua();
    std::string getPathFormBundle(const std::string& fileName);
    void setConnector(const std::string& connector) { m_connector = connector; }
    std::string getConnector()
    {
        if(m_connector == "")
            return "_";
        return m_connector;
    }
    std::string getChannelID() { return m_gameconfig.channel; }
    std::string getGameID() { return m_gameconfig.gameid; }
    void initGameConfig(const GAME_CONFIG_STU& gameconfig) { m_gameconfig = gameconfig; }
    
    void initUserID(const std::string userid);
    void analyticsLogEvent(const std::string& event);
    void analyticsLogEvent(const std::string& event, const std::map<std::string, std::string>& dictionary, bool timed = false);
    void analyticsLogEndTimeEvent(const std::string& event);
    
    void platformSharePerson(const std::string& shareContent, const std::string& shareImgPath, int platFormCfg = 0);
    //void createRole(const std::string& serverId);
    void playMovie(const char * fileName,int need_skip);
    void playMovie(const char * fileName,bool need_skip = true);
    
    void stopMovie();
    
    void setShareWCCallBackEnabled() { mIsShareWC=true;};
    
    void setShareWCCallBackDisabled() { mIsShareWC=false;};
    
    bool getShareWCCallBack() { return mIsShareWC;};
    
    bool IsInPlayMovie() {return mIsInPlayMovie; };
    
    void setIsInPlayMovie(bool state) { mIsInPlayMovie = state; };
    
    
    void setKeyChainUDIDGroup(const std::string& keyChainUDIDAccessGroup);
    
    ////////////////////zhanche///////////////////////////////////////
    long totalMemory();
    const std::string getDeviceType();
    void setCanPressBack(bool enable);
    ////////////////////////////////////////////////////////////////
    /** Library Recorder By zhaozhen and xiatian @20140712 Begin*/
    void playRecordFile(std::string &fileName, unsigned int rTag);
    void stopPlayRecordeFile(std::string &fileName, unsigned int rTag);
    void encodeRecordFile(std::string &inFileName, std::string &outFileName, unsigned int rTag);
    void decodeRecordFile(std::string &inFileName, std::string &outFileName, unsigned int rTag);
    bool openRecorder(std::string&fileName, unsigned int rType, unsigned int rTag);
    bool openRecorder(const std::string& fileName,unsigned int rType, unsigned int rTag);
    bool closeRecorder(unsigned int rTag);
    bool destoryRecorder(unsigned int rTag);
    /////////////////////////////////////////////////////////////////

	std::string getCurrentCountry();
	/*
	facebook 分享 
	@link link地址
	@picture 图片地址
	@name 标题
	@caption 副标题
	@description 描述 
	*/
	void facebookShare(std::string& link,std::string& picture,std::string& name,std::string& caption,std::string& description);
    //韩国kakao 处理游戏内登出时 serverlist
    void reEnterGameGetServerlistForKakao();
	//重登陆
	void reEnterLoading();
	//------------------------
	//韩国Entermate Android
	//退出游戏
	void OnLuaExitGame();
	//官方网站
	void OnEntermateHomepage();
	//活动
	void OnEntermateEvent();
	//移除注册
	void OnUnregister();
	//发送玩家信息变化
	void OnUserInfoChange(std::string& playerid,std::string& name,std::string& serverId,std::string& level,std::string& exp,std::string& vip,std::string& gold);
	//cdkeys
	void OnEntermateCoupons(std::string& strCoupons);
	//设置剪切板内容
	void setClipboardText(std::string& text);
	//获得剪切板内容
	std::string getClipboardText();
	void setEditBoxText(std::string& text);
	std::string getGameVersion();

	//------------------------
private:
    
    bool mIsShareWC;
    
    bool mAnalyticsOpen;
    
    bool mIsInPlayMovie;
    
    std::set<libOSListener*> mListeners;
    static libOS *m_sInstance;
    bool m_chatState;
    std::string m_connector;//连接符
    GAME_CONFIG_STU m_gameconfig;//iOS初始化结构体
public:
    static libOS* getInstance()
    {
        if(!m_sInstance)
        {
            m_sInstance = new libOS();
        }
        return m_sInstance;
    }
    void setChatState(bool state) { m_chatState = state; }
    bool getChatState() const { return m_chatState; }
    
    void registerListener(libOSListener* listerner)
    {
        mListeners.insert(listerner);
    }
    void removeListener(libOSListener* listener)
    {
        mListeners.erase(listener);
    }
    void _boardcastInputBoxOK(const std::string& content)
    {
        setShareWCCallBackDisabled();
        std::set<libOSListener*> listeners;
        listeners.insert(mListeners.begin(),mListeners.end());
        
        std::set<libOSListener*>::iterator it = listeners.begin();
        for(;it!=listeners.end();++it)
        {
            (*it)->onInputboxEnter(content);
        }
    }
    std::string _boardcastInputEdit(const std::string& content)
    {
        std::set<libOSListener*> listeners;
        listeners.insert(mListeners.begin(),mListeners.end());
        
        std::set<libOSListener*>::iterator it = listeners.begin();
        for(;it!=listeners.end();++it)
        {
            return (*it)->onInputboxEdit(content);
        }
        return "";
    }
	void _boardcastCloseKeyboard()
	{
		std::set<libOSListener*> listeners;
		listeners.insert(mListeners.begin(), mListeners.end());

		std::set<libOSListener*>::iterator it = listeners.begin();
		for (; it != listeners.end(); ++it)
		{
			(*it)->onCloseKeyboard();
		}
	}
	void _boardcastOpenKeyboard()
	{
		std::set<libOSListener*> listeners;
		listeners.insert(mListeners.begin(), mListeners.end());

		std::set<libOSListener*>::iterator it = listeners.begin();
		for (; it != listeners.end(); ++it)
		{
			(*it)->onOpenKeyboard();
		}
	}
	void _boardcastKeyboardHight(int nHight)
	{
		std::set<libOSListener*> listeners;
		listeners.insert(mListeners.begin(), mListeners.end());

		std::set<libOSListener*>::iterator it = listeners.begin();
		for (; it != listeners.end(); ++it)
		{
			(*it)->OnKeyboardHightChange(nHight);
		}
	}
	
    void _boardcastInputBoxCancel(const std::string& content)
    {
        setShareWCCallBackDisabled();
        std::set<libOSListener*> listeners;
        listeners.insert(mListeners.begin(),mListeners.end());
        
        std::set<libOSListener*>::iterator it = listeners.begin();
        for(;it!=listeners.end();++it)
        {
            (*it)->onInputboxCancel(content);
        }
    }
    void _boardcastMessageboxOK(int tag)
    {
        setShareWCCallBackDisabled();
        std::set<libOSListener*> listeners;
        listeners.insert(mListeners.begin(),mListeners.end());
        
        std::set<libOSListener*>::iterator it = listeners.begin();
        for(;it!=listeners.end();++it)
        {
            (*it)->onMessageboxEnter(tag);
        }
    }
    void boardcastMessageShareEngine(bool _result,std::string _resultStr)
    {
        setShareWCCallBackDisabled();
        std::set<libOSListener*> listeners;
        listeners.insert(mListeners.begin(),mListeners.end());
        
        std::set<libOSListener*>::iterator it = listeners.begin();
        for(;it!=listeners.end();++it)
        {
            (*it)->onShareEngineMessage(_result);
        }
    }
    
    void boardcastMessageOnPlayEnd()
    {
        std::set<libOSListener*> listeners;
        listeners.insert(mListeners.begin(),mListeners.end());
        
        std::set<libOSListener*>::iterator it = listeners.begin();
        for(;it!=listeners.end();++it)
        {
            (*it)->onPlayMovieEndMessage();
        }
    }
    void boardcastMotionShakeMessage()
    {
        std::set<libOSListener*> listeners;
        listeners.insert(mListeners.begin(),mListeners.end());
        
        std::set<libOSListener*>::iterator it = listeners.begin();
        for(;it!=listeners.end();++it)
        {
            (*it)->onMotionShakeMessage();
        }
    }
    void boardcastMessageOnPlayMovieLoadingDone()
    {
        std::set<libOSListener*> listeners;
        listeners.insert(mListeners.begin(),mListeners.end());
        
        std::set<libOSListener*>::iterator it = listeners.begin();
        for(;it!=listeners.end();++it)
        {
            (*it)->onPlayMovieLoadingDone();
        }
    }

	void boardcastMessageonFBShareBack(bool success)
	{
		std::set<libOSListener*> listeners;
		listeners.insert(mListeners.begin(),mListeners.end());

		std::set<libOSListener*>::iterator it = listeners.begin();
		for(;it!=listeners.end();++it)
		{
			(*it)->onFBShareBackMessage(success);
		}
	}

	void boardcastShowMessageBox(const std::string& msgString, int tag)
	{
		std::set<libOSListener*> listeners;
		listeners.insert(mListeners.begin(),mListeners.end());

		std::set<libOSListener*>::iterator it = listeners.begin();
		for(;it!=listeners.end();++it)
		{
			(*it)->onShowMessageBox(msgString,tag);
		}
	}
};

