--------------------------------------------------------------------------------
local HP_pb = require("HP_pb")
local json = require("json")
local Reward_pb = require "Reward_pb"
local Const_pb = require("Const_pb")
local UserInfo = require("PlayerInfo.UserInfo")
local NodeHelper = require("NodeHelper")
local common = require("common")
local NewbieGuideManager = require("Guide.NewbieGuideManager")
local Player_pb = require "Player_pb"
local Formation_pb = require("Formation_pb")
local ChatManager = require("Chat.ChatManager")
local FetterManager = require("FetterManager")
local GVGManager = require("GVGManager")
local ShopDataManager = require("ShopDataManager")
local AnnounceDownLoad = require("AnnounceDownLoad")
local MissionManager = require("MissionManager")
local Sign_pb=require("Sign_pb")
local TimeDateUtil = require("Util.TimeDateUtil")
local FriendManager = require("FriendManager")
local TapDBManager = require("TapDBManager")
local thisPageName = "MainScenePage"

require("Util.RedPointManager")
require("Util.LockManager")
require("AnnouncementPopPageNew")
require("AutoPopUpManager")

local MainScenePageInfo = { isInit = false, mainRoleSpine = nil } -- all ui information

local broadCastTime = 0
local ConstCastTime = 0

local voiceId = nil
local marqueeBanner = nil

local libPlatformListener = { }
local libPlatformSwitchAccountListener = { } -- 切换账号监听

local assemblyFinish = false

local ActivityCountDown={}
------------------------activity------------------------------
local m_currentActivityIndex = nil
MainScenePageInfo.loginDay = 0 -- 开服活动到达第几天\
local activityTimeInterval = 5 -- 时间间隔
local mainActivityTimeIntervalKey = "MainActivityTimeIntervalKey" -- 计时器的key
local popupPagesTimeInterval = 0.5 -- 时间间隔
local popupPagesTimeIntervalKey = "popupPagesTimeIntervalKey" -- 计时器的key
local voiceMsgTimeInterval = 5 -- 时间间隔
local voiceMsgTimeIntervalKey = "voiceMsgTimeIntervalKey" -- 计时器的key
local isEnter = false
local isEnterGame = false
local isEnterGameLoadingEnd = false
require("Activity.ActivityConfig")


GCAndGPBoundStatu = false-- 当前账号是否绑定了 gamecenter or google+
GCBoundSuccess = false

NoticePointState =
{
    isChange = true,
    MAIL_POINT_OPEN = false,
    -- 邮件红点
    MESSAGE_POINT_OPEN = false,
    -- 消息红点
    ALLIANCE_BOSS_OPEN = false,
    -- 联盟
    GIFT_NEW_MSG = false,
    ACTIVITY_POINT = false,
    REGINMENTWAR_POINT = false,
    TITLE_CHANGE_MSG = false,
    ARENARECORD_POINT = false,
    ACCOUNTBOUND_POINT = false,
    WORlDBOSS_POINT = false,
    FIRSTGIFTPACK_POINT = false,
    -- 首充礼包点
    ACHIEVEMENT_POINT = false,
    -- 成就系统红点
    GUILD_SIGNIN = false,
    -- 公会签到红点
    DAILY_QUEST_POINT = false,
    TANABATA_POINT = false,
    GOD_EQUIP = false,
    -- 神装锻造
    SHOOT_POINT = false,
    -- 打靶活动
    SHOP_POINT = false,
    -- 商店免费刷新
    MISSION_POINT = false,
    -- 任务红点
    -- 七天奖励红点
    SEVENDAY_POINT = false,
    --派遣紅點
    EXPEDITION_POINT=false,
    --禮包商城紅點
    IAP_POINT=false,
    --福袋紅點
    REWARD_POINT=false,
}
--[[
local testListener = {}
function testListener:onDownLoaded(listener)
    local filename = listener:getFileName();
    local fileurl = listener:getUrl();
end
function testListener:onDownLoadFailed(listener)
    local filename = listener:getFileName();
    local fileurl = listener:getUrl();
end
function testListener:onAlreadyDownSize(listener)
    local downSize = listener:getLoadSize()

    local a = 0
    CCLuaLog("downSize:" .. tostring(downSize))
end
CurlDownloadScriptListener:new(testListener)  --可实现下载 记得驱动CurlDownload:getInstance():update(0.2);
]]
LibPlatformScriptListener:new(libPlatformSwitchAccountListener)

------------
local NewBattleInfo = {
    awardTime = 0,
    serverTimeOffset = 0,
    MAX_TIME = 60 * 60 * 12,
}

local OPCODES = {
    ROLE_PANEL_INFOS_S = HP_pb.ROLE_PANEL_INFOS_S,
    SYNC_LEVEL_INFO_S = HP_pb.SYNC_LEVEL_INFO_S,
    SEND_MARKETPLACE_SYNC_S = HP_pb.SEND_MARKETPLACE_SYNC_S,
    PLAYER_AWARD_S = HP_pb.PLAYER_AWARD_S,
    FETCH_GIFT_S = HP_pb.FETCH_GIFT_S,
    ACTIVITY152_S = HP_pb.ACTIVITY152_S,
    GET_FORMATION_EDIT_INFO_S = HP_pb.GET_FORMATION_EDIT_INFO_S,
    SIGN_SYNC_S = HP_pb.SIGN_SYNC_S,
    FETCH_SHOP_LIST_S = HP_pb.FETCH_SHOP_LIST_S,
    NP_CONTINUE_RECHARGE_MONEY_S=HP_pb.NP_CONTINUE_RECHARGE_MONEY_S
}

local ScorllBtnMap=require("MainScenePage_BtnMap")

local BtnScrollviewState={Left=false,Right=false}
local BtnItem={
    ccbiFile="MainSceneBtn.ccbi"
}
local btnItemsLeft = { }
local btnItemsRight = { }


local UIHandlers = {
  -- 页面生命周期事件
  luaInit = function(_, container)
    MainScenePageInfo.onInit(container)
  end,
  luaLoad = function(_, container)
    MainScenePageInfo.onLoad(container)
  end,
  luaEnter = function(_, container)
    MainScenePageInfo.onEnter(container)
  end,
  luaExecute = function(_, container)
    MainScenePageInfo.onExecute(container)
  end,
  luaExit = function(_, container)
    MainScenePageInfo.onExit(container)
  end,
  luaUnLoad = function(_, container)
    MainScenePageInfo.onUnLoad(container)
  end,
  luaReceivePacket = function(_, container)
    MainScenePageInfo.onReceivePacket(container)
  end,
  luaGameMessage = function(_, container)
    MainScenePageInfo.onGameMessage(container)
  end,

  onPersonalConfidence = function()
    PageManager.pushPage("PlayerInfoPage")
  end,
  onViewExp = function(_, container)
    local ExpNode = container:getVarNode("mExp")
    local cfg = ConfigManager.getRoleLevelExpCfg()
    local lvlLimit = ConfigManager.getLevelLimitCfg()[GameConfig.LevelLimitCfgKey.roleLevelLimit].level
    local nextLevel = math.min(UserInfo.roleInfo.level, lvlLimit)
    local nextExp = cfg[nextLevel] and cfg[nextLevel]["exp"] or UserInfo.roleInfo.exp
    local txt = GameUtil:formatNumber(UserInfo.roleInfo.exp)
              .. "/"
              .. GameUtil:formatNumber(nextExp)
    NodeHelper:setStringForLabel(container, { mExp = txt })
    ExpNode:setVisible(not ExpNode:isVisible())
  end,
  onRecharge = function()
    require("IAP.IAPPage"):setEntrySubPage("Diamond")
    PageManager.pushPage("IAP.IAPPage")
  end,
  onChat = function()
    MainFrame_onChatBtn()
  end,
  onAlert = function(_, container)
    local closeR18 = VaribleManager:getInstance():getSetting("IsCloseR18")
    if tonumber(closeR18 == 1) then
      MessageBoxPage:Msg_Box(common:getLanguageString("@ComingSoon"))
    else
      PageManager.pushPage("AnnouncementPopPageNew")
    end
  end,
  onMail = function()
    PageManager.pushPage("MailPage")
  end,
  onBag = function()
    PageManager.pushPage("Inventory.InventoryPage")
  end,
  onSevenDay = function()
    require("NewPlayerBasePage")
    NewPlayerBasePage_setPageType(ACTIVITY_TYPE.NEWPLAYER_LEVEL9)
    PageManager.pushPage("NewPlayerBasePage")
  end,
  onNewPlayer = function()
    PageManager.pushPage("LivenessPage")
  end,
  onTouchHero = function(_, container)
    MainScenePageInfo.onTouchHero(container)
  end,
  onActivity = function(_, container)
    local key = "ACT191_" .. UserInfo.playerInfo.playerId
    local TimeTxt = CCUserDefault:sharedUserDefault():getStringForKey(key)
    local page = require("Event001Page")
    if TimeTxt == "" or page:getStageInfo().startTime ~= tonumber(TimeTxt) then
      PageManager.pushPage("Event001VideoBlack")
    else
      PageManager.pushPage("Event001Page")
    end
  end,
  BackSingleBoss = function()
    PageManager.pushPage("SingleBoss.SingleBossPage")
  end,
  BackPuzzle = function()
    PageManager.pushPage("PuzzlePage")
  end,
  onTest = function()
    PageManager.pushPage("TestPage")
  end,

  -- 按钮点击事件
  onPoP = function()
    local active = false
    for _, id in ipairs(ActivityInfo.PopUpSaleIds) do
      local cfg = ActivityConfig[id]
      if cfg.isShowFn and cfg.isShowFn() then
        active = true; break
      end
    end
    if active then
      PageManager.pushPage("ActPopUpSale.ActPopUpSalePage")
    else
      MessageBoxPage:Msg_Box(common:getLanguageString("@ERRORCODE_80104"))
    end
  end,
  onIAP = function()
    local IAP = require("IAP.IAPDataMgr")
    for _, cfg in ipairs(IAP.SubPageCfgs) do
      local aid = cfg.activityID
      if (not aid or ActivityInfo:getActivityIsOpenById(aid))
         and (not cfg.LOCK_KEY or not LockManager_getShowLockByPageName(cfg.LOCK_KEY))
      then
        require("IAP.IAPPage"):setEntrySubPage(cfg.subPageName)
        break
      end
    end
    PageManager.pushPage("IAP.IAPPage")
  end,
  onReward = function()
    local Free = require("Reward.RewardSubPage_FreeSummon")
    if Free:hasData() then
      PageManager.pushPage("Reward.RewardPage")
    else
      MessageBoxPage:Msg_Box(common:getLanguageString("@RequestingData"))
    end
  end,
  onShop = function()
    PageManager.pushPage("ShopControlPage")
  end,
  onStar = function()
    PageManager.pushPage("WishingWell.WishingWellPage")
  end,
  onQuest = function()
    require("Mission.MissionMainPage")
    MissionMainPage_setIsBattleView(false)
    PageManager.pushPage("MissionMainPage")
    require("Mission.MissionMainPage"):onAgencyBtn(MainScenePageInfo.container)
  end,
  onFriend = function()
    PageManager.pushPage("FriendPage")
  end,
  onForge = function()
    MainFrame_onForge()
  end,
  onBounty = function()
    PageManager.pushPage("MercenaryExpeditionPage")
  end,
  onSecert = function()
    local closeR18 = VaribleManager:getInstance():getSetting("IsCloseR18")
    if tonumber(closeR18) == 1 then
      MessageBoxPage:Msg_Box(common:getLanguageString("@ComingSoon")); 
      return
    end
    require("SecretMessage.SecretMessagePage")
    SecretMessagePage_setPageType(GameConfig.SECRET_PAGE_TYPE.MAIN_PAGE)
    PageManager.pushPage("SecretMessage.SecretPage")
  end,
  onGlory = function()
    local t = MainScenePageInfo:getActTime(175)
    local today = tostring(os.date("*t").wday)
    local open = (type(t) == "string" and common:table_contains(common:split(t, ","), today))
              or (type(t) == "number" and t > 0)
    if not open then
      MessageBoxPage:Msg_Box(common:getLanguageString("@ActivityCloseTex"))
      MainScenePageInfo:BuildBtnScrollview(MainScenePageInfo.container, btn.Pos, BtnScrollviewState[btn.Pos])
      return
    end
    local closeR18 = VaribleManager:getInstance():getSetting("IsCloseR18")
    if tonumber(closeR18) == 1 then
      MessageBoxPage:Msg_Box(common:getLanguageString("@ComingSoon")); return
    end
    TransScenePopUp_setCallbackFun(function()
      local msg = require("Activity5_pb").GloryHoleReq()
      msg.action = 0
      common:sendPacket(HP_pb.ACTIVITY175_GLORY_HOLE_C, msg, true)
    end)
    UserInfo.sync()
    PageManager.pushPage("TransScenePopUp")
  end,
  on7Day = function()
    require("NewPlayerBasePage")
    NewPlayerBasePage_setPageType(ACTIVITY_TYPE.NEWPLAYER_LEVEL9)
    PageManager.pushPage("NewPlayerBasePage")
  end,
  onSingleBoss = function()
    local sb = require("SingleBoss.SingleBossDataMgr")
    local data = sb:getPageData()
    data.dataDirtyBase = true
    PageManager.pushPage("SingleBoss.SingleBossPage")
  end,
  onPuzzle = function()
    TransScenePopUp_setCallbackFun(function()
      PageManager.pushPage("PuzzlePage")
    end)
    UserInfo.sync()
    PageManager.pushPage("TransScenePopUp")
  end,
  onActGift = function()
    PageManager.pushPage("IAP_Act.IAP_ActPage")
  end,
  onLogin = function()
    PageManager.pushPage("LoginRewardPage")
  end,
  onLeftScorllview = function()     
      MainScenePageInfo:onScrollBtn("onLeftScorllview")
  end,
  onRightScorllview = function()     
      MainScenePageInfo:onScrollBtn("onRightScorllview")
  end,
  onStory = function()
     PageManager.pushPage("Story.StoryPage")
  end,
}
------------

function libPlatformListener:P2G_GET_BIND_STATE(listener)
    if not listener then return end
    local strResult = listener:getResultStr()
    local packageName = libOS:getInstance():getPackageNameToLua()
    if strResult == "true" then
        GCAndGPBoundStatu = true
        if BlackBoard:getInstance().PLATFORM_TYPE_FOR_LUA == 2 and(packageName == "jp.co.ryuk.leave2" or packageName == "jp.co.ryuk.rpg") then
        end
    else
        GCAndGPBoundStatu = false
        -- 提示用户绑定
    end
end
function libPlatformListener:P2G_BIND_GC_GP(listener)
    if not listener then return end
    local strResult = listener:getResultStr()
    local json = require("json")
    local strTable = json.decode(strResult)
    if strTable.code == "success" then
        GCAndGPBoundStatu = true
        GCBoundSuccess = true
        MessageBoxPage:Msg_Box_Lan("@bindsuccess")
        local Player_pb = require "Player_pb"
        local msg = Player_pb.HPPlayerBindPrice()
        local pb = msg:SerializeToString()
        PacketManager:getInstance():sendPakcet(HP_pb.PLAYER_BIND_PRICE_C, pb, #pb, false)
    else
        GCAndGPBoundStatu = false
        MessageBoxPage:Msg_Box_Lan("@bindfailed" .. strTable.state)
    end
    --PageManager.refreshPage("GpAndGcBoundPage")
end

-- 在游戏中检测到gc登陆 且当前正在登陆的账号没有绑定，或者是绑定的gc跟当前登陆的gc不一样
-- 提示玩家是否要切换账号
function libPlatformListener:P2G_CHANGE_USER(listener)
    local title = Language:getInstance():getString("@HintTitle")
    local message = Language:getInstance():getString("@changeGC")
    if BlackBoard:getInstance().PLATFORM_TYPE_FOR_LUA == 2 then
        local changeUser = function(flag)
            if flag then
                GamePrecedure:getInstance():reEnterLoading()
                libPlatformManager:getPlatform():sendMessageG2P("G2P_CHANGE_USER", "true")
            else
                libPlatformManager:getPlatform():sendMessageG2P("G2P_CHANGE_USER", "false")
            end
        end
        PageManager.showConfirm(title, message, changeUser)
    end
end

function libPlatformListener:P2G_HAS_PLATFORM_USER_CENTER(listener)
    if not listener then return end
    local strResult = listener:getResultStr()
    if strResult == "1" then
        -- 显示平台按钮
    end

    CCLuaLog("P2G_HAS_PLATFORM_USER_CENTER:" .. strResult)
end

function libPlatformSwitchAccountListener:P2G_RE_ENTER_LOADING_SCENE(listener)
    if not listener then return end
    GamePrecedure:getInstance():reEnterLoading()
end
--------------------------------------------

function RESETINFO_NOTICE_STATE()
    for key, value in pairs(NoticePointState) do
        NoticePointState[key] = false
    end
    NoticePointState.isChange = true
end

function luaCreat_MainScenePage(container)
    CCLuaLog("Z#:luaCreate_MainScenePage!")
    container:registerFunctionHandler(MainScenePageInfo.onFunction)
end

function MainFrame_RefreshExpBar()
    local currentExp = UserInfo.roleInfo.exp
    local roleExpCfg = ConfigManager.getRoleLevelExpCfg()

    if currentExp ~= nil and roleExpCfg ~= nil then
        if UserInfo.roleInfo.level >= ConfigManager.getLevelLimitCfg()[GameConfig.LevelLimitCfgKey.roleLevelLimit].level then
            MainFrame:getInstance():setExpBar(1.0)
        else
            if UserInfo.roleInfo and roleExpCfg[UserInfo.roleInfo.level] then
                local nextLevelExp = roleExpCfg[UserInfo.roleInfo.level]["exp"]
                assert(nextLevelExp ~= nil, "MainFrame_RefreshExpBar roleExpCfg nextLevelExp is nil")
                local percent = currentExp / nextLevelExp
                if percent >= 0 then
                    MainFrame:getInstance():setExpBar(percent)
                end
            end
        end
    end
end
local function unschedulePos(pos)
    for _, v in pairs(ActivityCountDown) do
        if v.Pos == pos and v.Fn then
            CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(v.Fn)
            v.Fn = nil
        end
    end
end
function MainScenePageInfo:onScrollBtn(eventName)
    local container = MainScenePageInfo.container
    local pos = (eventName == "onLeftScorllview") and "Left" or "Right"
    BtnScrollviewState[pos] = not BtnScrollviewState[pos]
    if BtnScrollviewState[pos] then unschedulePos(pos) end
    MainScenePageInfo:BuildBtnScrollview(container, pos, BtnScrollviewState[pos])
    local btn = container:getVarNode("m"..pos.."Btn")
    btn:setScale(BtnScrollviewState[pos] and -1 or 1)
    local back = tolua.cast(container:getVarNode("m"..pos.."Back"), "CCScale9Sprite")
    btn:setPositionY(-back:getContentSize().height)
end
function MainScenePageInfo.onFunction(eventName, container)
  local fn = UIHandlers[eventName]
  if fn then
    return fn(eventName, container)
  end
end


function MainScenePageInfo.onJumpFirstRecharge(container)
    PageManager.pushPage("FirstChargePageNew")
    -- 记录上次点击首冲提示按钮的时间 隔天后如果还没有充值 则继续显示首冲提示按钮
    local tabTime = os.date("*t")
    tabTime.hour = 0
    tabTime.min = 0
    tabTime.sec = 0
    local time = os.time(tabTime)
    CCUserDefault:sharedUserDefault():setStringForKey("LastClickTime_" .. GamePrecedure:getInstance():getServerID(), time)
    MainScenePageInfo.refreshFetchGiftBtn(MainScenePageInfo.container)
end
function MainScenePageInfo:setLoginDay(loginDay)
    if loginDay > 0 and loginDay < 9 then
        MainScenePageInfo.loginDay = loginDay
    else
        MainScenePageInfo.loginDay = 0
    end
end

function MainScenePageInfo.broadcastMessage(container)
    local dt = GamePrecedure:getInstance():getFrameTime() * 1000
    broadCastTime = broadCastTime + dt
    if broadCastTime > GameConfig.BroadcastLastTime then
        isInAnimation = false
        local castNode = container:getVarNode("mNoticeNode")
        castNode:removeAllChildren()
    end
    -- local PackageLogicForLua = require("PackageLogicForLua")
    local size = #worldBroadCastList
    if size > 0 then
        if isInAnimation == false then
            -- get the first msg and remove
            local oneMsg = table.remove(worldBroadCastList, 1)

            local castNode = container:getVarNode("mNoticeNode")
            if castNode ~= nil then
                castNode:setVisible(true)
                castNode:removeAllChildren()
                local castCCB = ScriptContentBase:create("NoticeItem.ccbi")
                if string.find(oneMsg.chatMsg, "##") then
                    -- 如果是翅膀的话显示翅膀的Label
                    local htmlLabel = castCCB:getVarLabelTTF("mWingTex")
                    -- castCCB:getVarLabelTTF("mNoticeTex"):setVisible(false)
                    -- htmlLabel:setVisible(true)
                    NodeHelper:setNodeVisible(castCCB:getVarLabelTTF("mNoticeTex"), false)
                    NodeHelper:setNodeVisible(htmlLabel, true)
                    local name, htmlId = unpack(common:split(oneMsg.chatMsg, "##"))

                    local wingStr = common:fillNormalHtmlStr(tonumber(htmlId), tostring(name))
                    local wingHtmlStr = NodeHelper:addHtmlLable_Tips(htmlLabel, wingStr,
                    GameConfig.Tag.HtmlLable, CCSizeMake(600, htmlLabel:getContentSize().height), htmlLabel)
                    wingHtmlStr:setAnchorPoint(ccp(0.5, 1.0))
                    castCCB:runAnimation("Wing")
                elseif string.find(oneMsg.chatMsg, "@declareBattle") and not string.find(oneMsg.chatMsg, "@declareBattleNpc") then
                    local json = require("json")
                    local msg = json.decode(oneMsg.chatMsg)
                    local GVGManager = require("GVGManager")
                    GVGManager.initCityConfig()
                    local cityCfg = GVGManager.getCityCfg(msg.data[3])
                    local str = common:getLanguageString(msg.key, msg.data[1], msg.data[2], cityCfg.cityName)

                    local msgLabel = castCCB:getVarLabelTTF("mNoticeTex")
                    -- msgLabel:setVisible(true)
                    NodeHelper:setNodeVisible(msgLabel, true)
                    msgLabel:setFontSize(18)
                    -- castCCB:getVarLabelTTF("mWingTex"):setVisible(false)
                    NodeHelper:setNodeVisible(castCCB:getVarLabelTTF("mWingTex"), false)
                    msgLabel:setString(str)
                    castCCB:runAnimation("Notice")
                elseif string.find(oneMsg.chatMsg, "@declareBattleNpc") then
                    local json = require("json")
                    local msg = json.decode(oneMsg.chatMsg)
                    local GVGManager = require("GVGManager")
                    GVGManager.initCityConfig()
                    local cityCfg = GVGManager.getCityCfg(msg.data[2])
                    local str = ""
                    if cityCfg.level == 0 then
                        str = common:getLanguageString("@GVGRevive", msg.data[1], cityCfg.cityName)
                    else
                        str = common:getLanguageString(msg.key, msg.data[1], cityCfg.cityName)
                    end

                    local msgLabel = castCCB:getVarLabelTTF("mNoticeTex")
                    -- msgLabel:setVisible(true)
                    NodeHelper:setNodeVisible(msgLabel, true)
                    msgLabel:setFontSize(18)
                    -- castCCB:getVarLabelTTF("mWingTex"):setVisible(false)
                    NodeHelper:setNodeVisible(castCCB:getVarLabelTTF("mWingTex"), false)
                    msgLabel:setString(str)
                    castCCB:runAnimation("Notice")
                elseif string.find(oneMsg.chatMsg, "@declareFightback") then
                    local json = require("json")
                    local msg = json.decode(oneMsg.chatMsg)
                    local GVGManager = require("GVGManager")
                    GVGManager.initCityConfig()
                    local cityCfg = GVGManager.getCityCfg(msg.data[3])
                    local str = common:getLanguageString(msg.key, msg.data[1], msg.data[2], cityCfg.cityName)

                    local msgLabel = castCCB:getVarLabelTTF("mNoticeTex")
                    -- msgLabel:setVisible(true)
                    NodeHelper:setNodeVisible(msgLabel, true)
                    msgLabel:setFontSize(18)
                    -- castCCB:getVarLabelTTF("mWingTex"):setVisible(false)
                    NodeHelper:setNodeVisible(castCCB:getVarLabelTTF("mWingTex"), false)
                    msgLabel:setString(str)
                    castCCB:runAnimation("Notice")
                elseif string.find(oneMsg.chatMsg, "@attackerWin") then
                    local json = require("json")
                    local msg = json.decode(oneMsg.chatMsg)
                    local GVGManager = require("GVGManager")
                    GVGManager.initCityConfig()
                    local cityCfg = GVGManager.getCityCfg(msg.data[3])
                    local str = common:getLanguageString(msg.key, msg.data[1], msg.data[2], cityCfg.cityName)

                    local msgLabel = castCCB:getVarLabelTTF("mNoticeTex")
                    -- msgLabel:setVisible(true)
                    NodeHelper:setNodeVisible(msgLabel, true)
                    msgLabel:setFontSize(18)
                    -- castCCB:getVarLabelTTF("mWingTex"):setVisible(false)
                    NodeHelper:setNodeVisible(castCCB:getVarLabelTTF("mWingTex"), false)
                    msgLabel:setString(str)
                    castCCB:runAnimation("Notice")
                elseif string.find(oneMsg.chatMsg, "@defenderWin") then
                    local json = require("json")
                    local msg = json.decode(oneMsg.chatMsg)
                    local GVGManager = require("GVGManager")
                    GVGManager.initCityConfig()
                    local cityCfg = GVGManager.getCityCfg(msg.data[3])
                    local str = common:getLanguageString(msg.key, msg.data[1], msg.data[2], cityCfg.cityName)

                    local msgLabel = castCCB:getVarLabelTTF("mNoticeTex")
                    -- msgLabel:setVisible(true)
                    NodeHelper:setNodeVisible(msgLabel, true)
                    msgLabel:setFontSize(18)
                    -- castCCB:getVarLabelTTF("mWingTex"):setVisible(false)
                    NodeHelper:setNodeVisible(castCCB:getVarLabelTTF("mWingTex"), false)
                    msgLabel:setString(str)
                    castCCB:runAnimation("Notice")
                elseif string.find(oneMsg.chatMsg, "@fightbackWin") then
                    local json = require("json")
                    local msg = json.decode(oneMsg.chatMsg)
                    local GVGManager = require("GVGManager")
                    GVGManager.initCityConfig()
                    local cityCfg = GVGManager.getCityCfg(msg.data[3])
                    local str = common:getLanguageString(msg.key, msg.data[1], msg.data[2], cityCfg.cityName)

                    local msgLabel = castCCB:getVarLabelTTF("mNoticeTex")
                    -- msgLabel:setVisible(true)
                    NodeHelper:setNodeVisible(msgLabel, true)
                    msgLabel:setFontSize(18)
                    -- castCCB:getVarLabelTTF("mWingTex"):setVisible(false)
                    NodeHelper:setNodeVisible(castCCB:getVarLabelTTF("mWingTex"), false)
                    msgLabel:setString(str)
                    castCCB:runAnimation("Notice")
                elseif string.find(oneMsg.chatMsg, "@WorldBossBroadcast") then
                    -- local json = require("json")
                    -- local msg = json.decode(oneMsg.chatMsg)

                    local htmlLabel = castCCB:getVarLabelTTF("mWingTex")
                    htmlLabel:setString("")--common:getLanguageString("@WorldBossBroadcast"))
                    htmlLabel:setAnchorPoint(ccp(0.5, 0.5))

                    local layerColor = castCCB:getVarNode("mLayerColor")
                    -- layerColor:setVisible(true)
                    NodeHelper:setNodeVisible(layerColor, true)
                    -- htmlLabel:getParent():setVisible(true)
                    NodeHelper:setNodeVisible(htmlLabel:getParent(), true)
                    local nPosX = htmlLabel:getContentSize().width / 2 + 640 + 25
                    htmlLabel:setPositionX(nPosX)
                    -- htmlLabel:setVisible(true);
                    NodeHelper:setNodeVisible(htmlLabel, true)

                    local fTimeDuration = nPosX / GameConfig.BroadcastMoveSpeed
                    ConstCastTime = GameConfig.BroadcastLastTime
                    GameConfig.BroadcastLastTime = (fTimeDuration + 1) * 1000
                    CCLuaLog("acttion timeDuration = " .. fTimeDuration)

                    local actMoveTo = CCMoveTo:create(fTimeDuration, ccp(-htmlLabel:getContentSize().width / 2 - 25, 0))
                    local actFunc = CCCallFuncN:create(MainScenePageInfo.showMsgFinish)
                    local actArray = CCArray:create()
                    actArray:addObject(actMoveTo)
                    actArray:addObject(actFunc)
                    local actSeq = CCSequence:create(actArray)
                    htmlLabel:runAction(actSeq)
                elseif string.find(oneMsg.chatMsg, "@fightbackFail") then
                    local json = require("json")
                    local msg = json.decode(oneMsg.chatMsg)
                    local GVGManager = require("GVGManager")
                    GVGManager.initCityConfig()
                    local cityCfg = GVGManager.getCityCfg(msg.data[3])
                    local str = common:getLanguageString(msg.key, msg.data[1], msg.data[2], cityCfg.cityName)

                    local msgLabel = castCCB:getVarLabelTTF("mNoticeTex")
                    -- msgLabel:setVisible(true)
                    NodeHelper:setNodeVisible(msgLabel, true)
                    msgLabel:setFontSize(18)
                    -- castCCB:getVarLabelTTF("mWingTex"):setVisible(false)
                    NodeHelper:setNodeVisible(castCCB:getVarLabelTTF("mWingTex"), false)
                    msgLabel:setString(str)
                    castCCB:runAnimation("Notice")
                elseif string.find(oneMsg.chatMsg, "#D#") then
                    -- add  文字滚动新需求
                    local htmlLabel = castCCB:getVarLabelTTF("mWingTex")
                    -- castCCB:getVarLabelTTF("mNoticeTex"):setVisible(false);
                    NodeHelper:setNodeVisible(castCCB:getVarLabelTTF("mNoticeTex"), false)
                    local argStr, htmlId = unpack(common:split(oneMsg.chatMsg, "#D#"))
                    local args = common:split(argStr, "#DD#")
                    local Name=common:getLanguageString("@HeroName_"..args[2])
                    args[2]=Name
                    local wingStr = common:fillNormalHtmlStr(tonumber(htmlId), unpack(args))
                    local wingHtmlStr = NodeHelper:addHtmlLable_Tips(htmlLabel, wingStr,
                    GameConfig.Tag.HtmlLable, htmlLabel:getContentSize(), htmlLabel)
                    wingHtmlStr:setAnchorPoint(ccp(0.5, 0.5))

                    local layerColor = castCCB:getVarNode("mLayerColor")
                    -- layerColor:setVisible(true);
                    NodeHelper:setNodeVisible(layerColor, true)
                    -- htmlLabel:getParent():setVisible(true);
                    NodeHelper:setNodeVisible(htmlLabel:getParent(), true)
                    local nPosX = wingHtmlStr:getContentSize().width / 2 + 640 + 25
                    htmlLabel:setPositionX(nPosX)
                    -- htmlLabel:setVisible(true);
                    NodeHelper:setNodeVisible(htmlLabel, true)

                    local fTimeDuration = nPosX / GameConfig.BroadcastMoveSpeed
                    ConstCastTime = GameConfig.BroadcastLastTime
                    GameConfig.BroadcastLastTime = (fTimeDuration + 1) * 1000
                    CCLuaLog("acttion timeDuration = " .. fTimeDuration)

                    local actMoveTo = CCMoveTo:create(fTimeDuration, ccp(- wingHtmlStr:getContentSize().width / 2 - 25, 0))
                    local actFunc = CCCallFuncN:create(MainScenePageInfo.showMsgFinish)
                    local actArray = CCArray:create()
                    actArray:addObject(actMoveTo)
                    actArray:addObject(actFunc)
                    local actSeq = CCSequence:create(actArray)
                    htmlLabel:runAction(actSeq)
                    -- the end
                elseif string.find(oneMsg.chatMsg, "@gvgSeasonEnd") then
                    local json = require("json")
                    local msg = json.decode(oneMsg.chatMsg)
                    local htmlLabel = castCCB:getVarLabelTTF("mNoticeTex")
                    NodeHelper:setNodeVisible(castCCB:getVarLabelTTF("mWingTex"), false)
                    local wingStr = common:fillNormalHtmlStr(9, msg.data[2], msg.data[1])
                    local wingHtmlStr = NodeHelper:addHtmlLable_Tips(htmlLabel, wingStr,
                    GameConfig.Tag.HtmlLable, htmlLabel:getContentSize(), htmlLabel)
                    wingHtmlStr:setAnchorPoint(ccp(0.5, 0.5))
                    wingHtmlStr:setPosition(ccp(0, 3.5))
                    -- NodeHelper:setNodeVisible(wingHtmlStr,true)
                    NodeHelper:setNodeVisible(htmlLabel:getParent(), true)
                    NodeHelper:setNodeVisible(htmlLabel, true)
                    castCCB:runAnimation("Notice")
                else
                    -- 不是翅膀的广播
                    local msgLabel = castCCB:getVarLabelTTF("mNoticeTex")
                    -- msgLabel:setVisible(true)
                    NodeHelper:setNodeVisible(msgLabel, true)
                    msgLabel:setFontSize(22)
                    -- castCCB:getVarLabelTTF("mWingTex"):setVisible(false)
                    NodeHelper:setNodeVisible(castCCB:getVarLabelTTF("mWingTex"), false)
                    msgLabel:setString(oneMsg.chatMsg)
                    castCCB:runAnimation("Notice")
                end
                castNode:addChild(castCCB)
                castCCB:release()

                isInAnimation = true
            end
            broadCastTime = 0
        end
    end
end

function MainScenePageInfo.showMsgFinish(node)
    GameConfig.BroadcastLastTime = ConstCastTime
    CCLuaLog("finish action")
end

-- 检查红点
function MainScenePageInfo.checkActivityRedPoint(container, t)
    local showId = -1
    for i = 1, #ActivityInfo.allIds do
        local id = ActivityInfo.allIds[i]
        if id == 109 then
            return false
        end
        if t[id] then
            return true, id
        end
    end

    return false
end

-- 检查红点
function MainScenePageInfo.checkActivityRedPointByActivityId(container, t, activityId)
    local showId = -1
    for k, v in pairs(t) do
        if v and k == activityId and activityId ~= 109 then
            return true, activityId
        end
    end

    return false
end

function MainScenePageInfo.refreshFetchGiftBtn(container)
    UserInfo.sync()
    -- NG主頁紅點顯示
    NodeHelper:setNodesVisible(container, { mNewPlayerPoint = MainScenePageInfo.refreshNewPlayerRedPoint() })
    NodeHelper:setNodesVisible(container, { mSevenDayPoint = MainScenePageInfo.refreshSevenDayRedPoint() })
end
function MainScenePageInfo.refreshLock(container)
    NodeHelper:setNodesVisible(container, {
        mSecretLock = LockManager_getShowLockByPageName(GameConfig.LOCK_PAGE_KEY.SECRET_MESSAGE),
    })
end
function MainScenePageInfo.refreshMainIcon(container)
    -- 首次充值是否顯示
    -- NodeHelper:setNodeVisible(container:getVarNode("mFirstRechargeIcon"), ActivityInfo.activities[122] ~= nil)
    -- BuildBtnScrollview
    local GuideManager = require("Guide.GuideManager")
    if GuideManager.isInGuide then  -- 新手教學中強制展開
        BtnScrollviewState.Left = false
        BtnScrollviewState.Right = false
    end
    MainScenePageInfo:BuildBtnScrollview(MainScenePageInfo.container,"Left",BtnScrollviewState.Left)
    MainScenePageInfo:BuildBtnScrollview(MainScenePageInfo.container,"Right",BtnScrollviewState.Right)

    -- 7日祭活動是否顯示
    --local isShowSevenDay = false
    --NodeHelper:setNodeVisible(container:getVarNode("mSevenDayIcon"), false)
    --for i = 1, #ActivityInfo.NewPlayerLevel9Ids do
    --    local id = ActivityInfo.NewPlayerLevel9Ids[i]
    --    if ActivityInfo.activities[id] then
    --        NodeHelper:setNodeVisible(container:getVarNode("mSevenDayIcon"), true)
    --        isShowSevenDay = true
    --        break
    --    end
    --end
    -- 8天登入是否顯示
   -- NodeHelper:setNodeVisible(container:getVarNode("mNewPlayerIcon"), false)
   -- for i = 1, #ActivityInfo.NewPlayerLogin do
   --     local id = ActivityInfo.NewPlayerLogin[i]
   --     if ActivityInfo.activities[id] then
   --         NodeHelper:setNodeVisible(container:getVarNode("mNewPlayerIcon"), true)
   --         break
   --     end
   -- end
    --local newPlayerIconNode = container:getVarNode("mNewPlayerIcon")
    --if isShowSevenDay then -- 移動icon位置
    --    newPlayerIconNode:setPositionY(-462)
    --else
    --    newPlayerIconNode:setPositionY(-359)
    --end
   
end

function MainScenePageInfo.onInit(container)
    CCLuaLog("Z#:MainScenePageInfo.onInit!")
    MainScenePageInfo.isInit = true
    if FreeTypeConfig == nil or table.maxn(FreeTypeConfig) <= 0 then
        local tabel = nil
        local userType = CCUserDefault:sharedUserDefault():getIntegerForKey("LanguageType")
	    if userType == kLanguageChinese then
	    	tabel = TableReaderManager:getInstance():getTableReader("FreeTypeFont.txt")
	    elseif userType == kLanguageCH_TW then
	    	tabel = TableReaderManager:getInstance():getTableReader("FreeTypeFontTW.txt")
	    else
	    	tabel = TableReaderManager:getInstance():getTableReader("FreeTypeFont.txt")
        end
        local count = tabel:getLineCount() - 1
        for i = 1, count do
            local index = tonumber(tabel:getData(i, 0))
            if FreeTypeConfig[index] == nil then
                FreeTypeConfig[index] = { }
                FreeTypeConfig[index].id = tonumber(tabel:getData(i, 0))
                FreeTypeConfig[index].content = tabel:getData(i, 1)
            end
        end
    end
end

function MainScenePageInfo.onLoad(container)
    CCLuaLog("Z#:MainScenePageInfo.onLoad!")
    -- 进入页面时，重置当前状态	
    container:loadCcbiFile("MainScene.ccbi", true)
end

function MainScenePageInfo.registerPacket(container)
    for key, opcode in pairs(OPCODES) do
        if string.sub(key, -1) == "S" then
            container:registerPacket(opcode)
        end
    end
end

function MainScenePageInfo.removePacket(container)
    for key, opcode in pairs(OPCODES) do
        if string.sub(key, -1) == "S" then
            container:removePacket(opcode)
        end
    end
end
function MainScenePageInfo.RequestData()
    --popUp資料要求
    require("ActPopUpSale.ActPopUpSaleSubPage_132")
    require("ActPopUpSale.ActPopUpSaleSubPage_177")
    ActPopUpSaleSubPage_132_sendInfoRequest()
    ActPopUpSaleSubPage_177_sendInfoRequest()      
    --require("ActPopUpSale.ActPopUpSaleSubPage_Content")
    --local cfg = ConfigManager.getPopUpCfg()
    --for _,v in pairs (cfg) do
    --   if ActivityInfo:getActivityIsOpenById(v.activityId) then
    --        ActPopUpSaleSubPage_setActId(v.activityId)
    --        ActPopUpSaleSubPage_Content_sendInfoRequest()
    --   end     
    --end

    --require("ActPopUpSale.ActPopUpSaleSubPage_Content")
    --ActPopUpSaleSubPage_Content_sendInfoRequest()
    local msg = Activity5_pb.MaxJumpGiftReq()
    msg.action = 0
    msg.type = 0
    common:sendPacket(HP_pb.ACTIVITY187_MAXJUMP_GIFT_C, msg, false)
    --if ActivityInfo:getActivityIsOpenById(187) then
    --     ActPopUpSaleSubPage_Content_sendInfoRequest()
    --end
    --local SpTable = {132,177}
    --local PopUpCfg1 = ConfigManager.getPopUpCfg()
    --local PopUpCfg2 = ConfigManager.getPopUpCfg2()
    --MainScenePageInfo.PopUpIds = {}
    --for i = 1, #PopUpCfg1 do
    --  table.insert(MainScenePageInfo.PopUpIds ,PopUpCfg1[i].activityId)
    --end
    --for key,_ in pairs (PopUpCfg2) do
    --    table.insert(MainScenePageInfo.PopUpIds ,tonumber (key))
    --end
    --for i = 1, #SpTable do
    --    table.insert(MainScenePageInfo.PopUpIds ,SpTable[i]) 
    --end

    local msg = Recharge_pb.HPFetchShopList()
    msg.platform = GameConfig.win32Platform
    CCLuaLog("PlatformName2:" .. msg.platform)
    pb_data = msg:SerializeToString()
    PacketManager:getInstance():sendPakcet(HP_pb.FETCH_SHOP_LIST_C, pb_data, #pb_data, true)
    if (Golb_Platform_Info.is_r18) then --R18
        local IsGuest = libPlatformManager:getPlatform():getIsGuest() 
        if (IsGuest == 0) then
            CCLuaLog("MainScene SendtogetHoneyP")
            local BuyManager = require("BuyManager")
            BuyManager:SendtogetHoneyP() -- getHoneyp
        end
    end

    if (Golb_Platform_Info.is_erolabs) then --Erolabs
        local IsGuest = libPlatformManager:getPlatform():getIsGuest() 
        if (IsGuest == 0) then
            CCLuaLog("MainScene SendtogetECoin")
            local BuyManager = require("BuyManager")
            BuyManager:SendtogetECoin() -- getECoin
        end
    end
end
function MainScenePageInfo.onEnter(container)
    MainFrame_setGuideMask(true)    -- 避免新帳號教學開始前看到大廳畫面
    --
    OnEnterGame()     --2020/3/31啟用

    local UserMercenaryManager = require("UserMercenaryManager")
    if UserMercenaryManager:getMercenaryStatusInfos() == nil or #UserMercenaryManager:getMercenaryStatusInfos() == 0 then
        -- 没有副将信息 请求一次
        common:sendEmptyPacket(HP_pb.ROLE_PANEL_INFOS_C, true)
    end
    container:retain()
    MainScenePageInfo.container = container
    UserInfo.isMainPageLoad = true

    local mainFrame = tolua.cast(MainFrame:getInstance(), "CCBScriptContainer")

    MainScenePageInfo.libPlatformListener = LibPlatformScriptListener:new(libPlatformListener)


    container:registerMessage(MSG_SEVERINFO_UPDATE)
    container:registerMessage(MSG_MAINFRAME_REFRESH)
    container:registerMessage(MSG_REFRESH_REDPOINT)
    MainScenePageInfo.registerPacket(container)

     MainScenePageInfo.refreshPage(container)
    --Flag狀態要求
    require("FlagData")
    local data=FlagDataBase_GetData()
    FlagDataBase_ReqStatus()
    
    --派遣紅點要求
    require("Mercenary.MercenaryExpeditionPage")
    MercenaryExpeditionPage_getSimpleInfo()

    --補給資料要求
    require("IAP.IAPRedPointMgr")
    Calendar_sendNRInfo()
    Calendar_sendPRInfo()

    --月卡資料要求
    --小月卡
    common:sendEmptyPacket(HP_pb.CONSUME_MONTHCARD_INFO_C, false)
    --大月卡
    common:sendEmptyPacket(HP_pb.CONSUME_WEEK_CARD_INFO_C, false)

    --商城資料要求
    local SummonPage=require("Reward.RewardSubPage_FreeSummon")
    SummonPage:sendLoginSignedInfoReqMessage()
    local SummonPage2=require("Reward.RewardSubPage_FreeSummon2")
    SummonPage2:sendLoginSignedInfoReqMessage()
    
    local msg = Activity5_pb.StepSummonReq()
    msg.action=0
    common:sendPacket(HP_pb.ACTIVITY190_STEP_SUMMON_C, msg, false)

    local LoginPage=require("Reward.RewardSubPage_DayLogin30")
    LoginPage:sendLoginSignedInfoReqMessage()
    local StepBundle =  require ("IAP.IAPSubPage_StepBundle")
    StepBundle:ItemInfoRequest()

    --充值回饋資料要求
    local DailyBundlePage = require ("Activity.DailyBundlePage")
    DailyBundlePage:getVipPointRequest()
    --累計登入資料要求
    local msg = Activity6_pb.EightDayLoginAwardReq()
    msg.action = 0
    common:sendPacket(HP_pb.ACTIVITY200_EIGHT_DAY_LOGIN_C, msg, false)

    MainScenePageInfo.setNoticeNodes(container)

    broadCastTime = 0
    ConstCastTime = 0
    isInAnimation = false

    -- 进入主界面加入事件追踪
    libPlatformManager:getPlatform():sendMessageG2P("G2P_ENTER_MAINSCENE_PAGE", "enter_mainscene_page")
    libPlatformManager:getPlatform():sendMessageG2P("G2P_GET_BIND_STATE", "G2P_GET_BIND_STATE")

    -- 数据包接收完，存在主场景未加载的情况。导致红点未显示，--这里重新刷新红点
    PageManager.refreshRedNotice()

    isEnter = true
    -- 注册时间
    TimeCalculator:getInstance():createTimeCalcultor(mainActivityTimeIntervalKey, activityTimeInterval)
    TimeCalculator:getInstance():createTimeCalcultor(popupPagesTimeIntervalKey, popupPagesTimeInterval)
    -- 数据包接收完，存在主场景未加载的情况。导致红点未显示，--这里重新刷新红点

    MissionManager.getRedPointStatus()
    FriendManager.requestFriendApplyList()

    --MainScenePageInfo.showRoleSpineExtend(container)

    MainFrame_createTimeCalculator()

    FetterManager.initFetterCfg()
    MainFrame_onClick()
    if assemblyFinish then
        assemblyFinish = false

        local msg = Guide_pb.HPPlayStorySync()
        msg.isDone = 1
        UserInfo.isPlayStory = true
        SoundManager:getInstance():setMusicOn(tonumber(UserInfo.stateInfo.musicOn) >= 1)
        SimpleAudioEngine:sharedEngine():setBackgroundMusicVolume(UserInfo.stateInfo.musicOn / 10)
        MainFrame:getInstance():hideNoTouch()
        common:sendPacket(HP_pb.PLAYSTORYDONE_SYNC_C, msg, false)

        --local GuideManager = require("Guide.GuideManager")

        --GuideManager.newbieGuide()
        --if UserInfo.isShowLevelUp then
        --    UserInfo.isShowLevelUp = false
        --    if not GuideManager.isInGuide then
        --        GameUtil:showLevelUpAni()
        --    end
        --end
    end

    --新增名簿按鈕
    FetterManager.clear()
    FetterManager.reqFetterInfo()

    local mainContainer = tolua.cast(MainFrame:getInstance(), "CCBContainer")
    local mainButtons = mainContainer:getCCNodeFromCCB("mMainFrameButtons")
    mainButtons:setVisible(true)

    -- 協定收發代理器
    local PacketAgent = require("Util.PacketAgent")
    local packetAgentInst = PacketAgent:inst():init(mainFrame)
    -- 跑馬燈 橫幅 
    if marqueeBanner then
        marqueeBanner:exit()
        marqueeBanner = nil
    end
    local marqueeBannerNode = container:getVarNode("marqueeBannerNode")
    local marqueeBannerNodeSize = marqueeBannerNode:getContentSize()
    marqueeBannerNode:removeAllChildren()
    marqueeBanner = require("LobbyMarqueeBanner"):new():init()
    local marqueeBannerUI = marqueeBanner:getContainer()
    marqueeBannerNode:addChild(marqueeBannerUI)

    local GuideManager = require("Guide.GuideManager")
    if MainScenePageInfo.isInit then    -- 第一次進入頁面
        -- 取得競技場編隊資訊
        MainScenePageInfo:sendArenaEditInfoReq(container)
        if not GuideManager.isInGuide then
            -- 取得編隊資訊
            MainScenePageInfo:sendEditInfoReq(container)
        end
        -- 紀錄玩家資訊
        local StrServer = GamePrecedure:getInstance():getServerNameById(tonumber(UserInfo.serverId))
        local date = os.date("%Y-%m-%d %H:%M:%S")
        CCUserDefault:sharedUserDefault():setStringForKey("JapanLastLoginTime", date)
        CCUserDefault:sharedUserDefault():setStringForKey("JapanServrId", tostring(StrServer))
        CCUserDefault:sharedUserDefault():setStringForKey("JapanPlayerId", tostring(UserInfo.playerInfo.playerId))
        CCUserDefault:sharedUserDefault():setStringForKey("JapanPuid", libPlatformManager:getPlatform():loginUin())
        -- 初始化紅點設定
        RedPointManager_initAllPageData()
        RedPointManager_initSyncAllPageData()

        RedPointManager_refreshPageShowPoint(RedPointManager.PAGE_IDS.BATTLE_FAST_BTN, 1)
    end
    -- 同步寶箱時間
    common:sendEmptyPacket(HP_pb.SYNC_LEVEL_INFO_C, false) 

    SoundManager:getInstance():playGeneralMusic()

    GuideManager.PageContainerRef["MainScene"] = container
    GuideManager.PageContainerRef["MainFrame"] = mainFrame
    MainScene_checkGuide()
    --if GuideManager.isInGuide then
    --    PageManager.pushPage("NewbieGuideForcedPage")
    --else
    --    for i = 2, GuideManager.guideType.MAX_NUM do
    --        GuideManager.openOtherGuideFun(i, true)
    --    end
    --end
    MainScenePageInfo:refreshAllPoint(container)
    NodeHelper:setNodesVisible(container, { mMessageNode = false, mExp = false })

    ConfigManager.getNewMonsterCfg() -- 提前載入monster表 減少第一次戰鬥頁面讀取時間

    if isEnterGameLoadingEnd then
        MainScenePageInfo.showRoleSpineExtend(container)
        container:runAnimation("AdventureOpen2")
    end

  -- 檢查指定活動是否開啟
    local function isActivityOpen(activityId)
        local bannerCfgs = ConfigManager.getBannerCfg()
        local now = os.time()
        for _, data in pairs(bannerCfgs) do
            if data.activityId == activityId and tonumber(data.startTime) < now then
                return tonumber(data.endTime) > now
            end
        end
        return false
    end
    
    local EventDataMgr = require("Event001DataMgr")
    
    -- 定義活動對應的設定，包括活動 id、常數，以及對應的鎖定 key
    local activityMapping = {
        { id = 191, constant = Const_pb.ACTIVITY191_CycleStage, lockKey = GameConfig.LOCK_PAGE_KEY.Event001 },
        { id = 196, constant = Const_pb.ACTIVITY196_CycleStage_Part2, lockKey = GameConfig.LOCK_PAGE_KEY.Event001 },
    }
    
    local found = false
    for _, mapping in ipairs(activityMapping) do
        -- 依序檢查每個活動是否開啟，且對應的鎖定頁面是否未鎖定
        if isActivityOpen(mapping.id) and not LockManager_getShowLockByPageName(mapping.lockKey) then
            EventDataMgr.nowActivityId = mapping.constant
            NodeHelper:setMenuItemImage(container, { mActivityBtn = { normal = EventDataMgr[mapping.constant].MAIN_ENTRY_IMG } })
            NodeHelper:setNodesVisible(container, { mActivityNode = true, mTimeNode = false })
            common:sendEmptyPacket(HP_pb.CYCLE_LIST_INFO_C, false)
            found = true
            break  -- 只顯示第一個符合條件的活動
        end
    end
    
    if not found then
        NodeHelper:setNodesVisible(container, { mActivityNode = false })
        EventDataMgr.nowActivityId = 0
    end

    --測試按鈕
    NodeHelper:setNodesVisible(container, { mTestNode = libOS:getInstance():getIsDebug() })

    local PageJumpMange = require("PageJumpMange")
    if PageJumpMange._IsPageJump then
        if PageJumpMange._CurJumpCfgInfo._SecondFunc ~= "" then
            MainScenePageInfo.onFunction(PageJumpMange._CurJumpCfgInfo._SecondFunc, container)
            return           
        end
        PageJumpMange._IsPageJump = false
        require("TransScenePopUp")
        TransScenePopUp_closePage()
    else
        require("TransScenePopUp")
        TransScenePopUp_closePage()
    end
end
-- helper：判定功能是否被隱藏且鎖定
local function notLocked(id)
    for _, cfg in ipairs(ConfigManager.getFunctionUnlock()) do
        if tonumber(cfg.Function) == id then
            return not (cfg.isHide == 1 and LockManager_getShowLockByPageName(id))
        end
    end
    return true
end



-- 建立按鈕滾動欄
function MainScenePageInfo:BuildBtnScrollview(container, Pos, isShort)
    if not container then return end

    -- 1. 取得並初始化 ScrollView
    local svs = {
        Left  = container:getVarScrollView("mBtnScrollviewLeft"),
        Right = container:getVarScrollView("mBtnScrollviewRight"),
    }
    local scrollview = svs[Pos]
    scrollview:removeAllCell()
    scrollview:setTouchEnabled(false)

    -- 2. 所有按鈕顯示規則
    local rules = {
        DailyLogin = function()
            local d = require("LoginRewardPage"):getServerData()
            return d and d.surplusTime > 0 and d.days < 8
        end,
        PopUpSale = function()
            -- 特規型禮包
            for _, id in ipairs({132,177}) do
                require("ActPopUpSale.ActPopUpSaleSubPage_"..id)
                local fn = _G["ActPopUpSaleSubPage_"..id.."_getIsShowMainSceneIcon"]
                if fn and fn().isShowFn then return true end
            end
            -- 整合型禮包
            require("ActPopUpSale.ActPopUpSaleSubPage_Content")
            for _, v in pairs(ConfigManager.getPopUpCfg2()) do
                if v.type == GameConfig.GIFT_TYPE.POPUP_GIFT
                   and ActPopUpSaleSubPage_Content_getIsShowMainSceneIcon(v.GiftId).isShowIcon
                then return true end
            end
        end,
        ["7Day"] = function()
            for _, id in ipairs(ActivityInfo.NewPlayerLevel9Ids) do
                if ActivityInfo.activities[id] then return true end
            end
        end,
        ["8Day"] = function()
            for _, id in ipairs(ActivityInfo.NewPlayerLogin) do
                if ActivityInfo.activities[id] then return true end
            end
        end,
        GloryHole = function()
            local t = self:getActTime(175)
            if type(t)=="number" and t>0 then return true end
            local wd = os.date("*t").wday
            for _, v in ipairs(common:split(t, ",")) do
                if tonumber(v)==wd then return true end
            end
        end,
        SingleBoss = function()
            return ActivityInfo:getActivityIsOpenById(Const_pb.ACTIVITY193_SingleBoss)
        end,
        Star = function()
            return ActivityInfo:getActivityIsOpenById(Const_pb.ACTIVITY147_WISHING_WELL)
               and self:getActTime(147) > 0
        end,
        Puzzle = function()
            local t = self:getActTime(Const_pb.ACTIVITY195_PuzzleBattle)
            return type(t)=="number" and t>0
        end,
        Act_Gift = function()
            require("Act187_DataBase")
            for _, tp in ipairs({
                GameConfig.GIFT_TYPE.CYCLE_GIFT,
                GameConfig.GIFT_TYPE.WISHINGWHEEL_GIFT,
                GameConfig.GIFT_TYPE.SUMMON_GIFT,
            }) do
                if next(Act187_DataBase_GetData(tp)) then return true end
            end
        end,
    }

    -- 3. 計算 ShowIconTable
    local ShowIconTable = {}
    for key, fn in pairs(rules) do
        ShowIconTable[key] = fn()
    end

    -- 4. 清空按鈕集合並呼叫共用處理
    btnItemsLeft, btnItemsRight = {}, {}
    self:handleScrollview(scrollview, Pos, isShort, ShowIconTable)
end

-- 處理滾動欄內容
function MainScenePageInfo:handleScrollview(scrollview, pos, isShort, showTable)
    local container = MainScenePageInfo.container
    local mapping   = ScorllBtnMap
    local toBuild   = {}
    local totalH    = 0

    -- 過濾按鈕
    for _, info in ipairs(mapping) do
        if info.Pos == pos
        and notLocked(info.Lock)
        and (showTable[info.key] or not info.Time)
        then table.insert(toBuild, info) end
    end

    if isShort then
        local info = toBuild[1]
        if info then
            local cell = self:CreateBtn(info)
            scrollview:addCell(cell)
            totalH = cell:getContentSize().height
        end
    else
        unschedulePos(pos)
        local guideMap = {
            Expdtion  = "mGuideExpeditionNode",
            Forge     = "mGuideForgeNode",
            SecertMsg = "mGuideSecretNode",
        }
        for _, info in ipairs(toBuild) do
            local cell = self:CreateBtn(info)
            if cell then
                scrollview:addCell(cell)
                local h = cell:getContentSize().height
                totalH = totalH + h
                local gname = guideMap[info.key]
                if gname then
                    local node = container:getVarNode(gname)
                    node:setPositionY(-totalH - 170 + h * 0.5)
                end
            end
        end
    end

    if totalH > 850 then
        totalH = 850
        scrollview:setTouchEnabled(true)
        scrollview:setBounceable(false)
    else
        scrollview:setTouchEnabled(false)
    end

    local prefix = (pos == "Left") and "mLeft" or "mRight"
    local back   = tolua.cast(container:getVarNode(prefix .. "Back"), "CCScale9Sprite")
    back:setContentSize(CCSize(77, totalH + 20))

    local btn = container:getVarNode(prefix .. "Btn")
    btn:setScaleY((BtnScrollviewState[pos] and -1) or 1)
    btn:setPositionY(-totalH - 20)

    scrollview:setPositionY(-totalH)
    scrollview:setViewSize(CCSize(120, totalH))
    scrollview:orderCCBFileCells()
end

-- 建立單顆按鈕Cell
function MainScenePageInfo:CreateBtn(info)
    local timeFns = {
        PopUpSale  = function() return self:GetPopUpTime() end,
        GloryHole  = function() return self:getActTime(175) end,
        Star       = function() return self:getActTime(147) end,
        Act_Gift   = function() require("Act187_DataBase"); return Act187_DataBase_GetActGiftlastTime() end,
        DailyLogin = function() local d = require("LoginRewardPage"):getServerData(); return d and d.surplusTime or 0 end,
        Puzzle     = function() return self:getActTime(195) end,
    }
    local time = (timeFns[info.key] and timeFns[info.key]()) or 0

    local cell = CCBFileCell:create()
    cell:setCCBFile(BtnItem.ccbiFile)
    local handler = common:new({
        _Key   = info.key,
        Normal = info.normal,
        fun    = info.fun,
        Lock   = info.Lock,
        Red    = info.isRed,
        Time   = time,
        Pos    = info.Pos,
    }, BtnItem)
    cell:registerFunctionHandler(handler)

    if info.Pos == "Left" then
        table.insert(btnItemsLeft, {cell = cell, handler = handler})
    else
        table.insert(btnItemsRight, {cell = cell, handler = handler})
    end

    local h = (type(time)=="string" or time>0) and 125 or 90
    cell:setContentSize(CCSizeMake(100, h))
    return cell
end

function MainScenePageInfo:GetPopUpTime()
     local _time= 0
     local TimeTable = {}
      --popUp資料要求
      local pages = {132,177}
      local cfg = ConfigManager.getPopUpCfg()
      local cfg2 = ConfigManager.getPopUpCfg2()

      --for _,v in pairs (cfg) do
      --    table.insert (pages,v.activityId)      
      --end

     for key,v in pairs (cfg2) do
        if v.type == GameConfig.GIFT_TYPE.POPUP_GIFT then
          table.insert (pages,key)
        end
      end
     
     for i, page in ipairs(pages) do
         if page == 132 or page == 177 then 
            local serverDataFunc = _G["ActPopUpSaleSubPage_"..page.."_getServerData"]
            local serverData = serverDataFunc and serverDataFunc()
            TimeTable[i] = serverData and serverData.limitDate or 0
         else
             local serverData = ActPopUpSaleSubPage_Content_getServerData(page)
             TimeTable[i] = serverData[page] and serverData[page].limitDate or 0
         end
     end
     
     table.sort(TimeTable,function(a,b)
         return a - os.time()<b - os.time()
      end)
     for i=1,#TimeTable do
         if TimeTable[i]- os.time() > 0 then
             _time=TimeTable[i]- os.time()
             break
         end
     end
     if _time>86400*30 then return nil end
     return _time
end

function MainScenePageInfo:getActTime(ActId)
    local bannerCfgs = ConfigManager:getBannerCfg()
    for key,data in pairs (bannerCfgs) do
        if data.activityId == ActId then
            if data.type == 0 then
                if os.time() > data.startTime and os.time() < data.endTime then
                    return tonumber (data.endTime)- os.time()
                end
            elseif data.type == 1 then
                return data.openDay
            end
        end
    end
    return 0
end

function BtnItem:onRefreshPoint(ccRoot, value)
    local container=ccRoot:getCCBFileNode()
    if value.Red then
        NodeHelper:setNodesVisible(container, { mPoint = RedPointManager_getShowRedPoint(value.Red) })
    end
end

-- 格式化倒計時字串
local function formatTime(t)
    if t > 86400 then
        return math.floor(common:getDayNumber(t)) + 1 .. common:getLanguageString("@Days")
    else
        return common:dateFormat2String(t, true)
    end
end

function BtnItem:onRefreshContent(ccRoot)
    local container = ccRoot:getCCBFileNode()
    local key       = self._Key
    local pos       = self.Pos
    local sched     = CCDirector:sharedDirector():getScheduler()

    -- 取消原有倒计時
    if ActivityCountDown[key] and ActivityCountDown[key].Fn then
        sched:unscheduleScriptEntry(ActivityCountDown[key].Fn)
        ActivityCountDown[key] = nil
    end

    -- 只有當 self.Time>0 時才建立倒計時，結束時再重建 ScrollView
    if type(self.Time) == "number" and self.Time > 0 then
        local left = self.Time
        ActivityCountDown[key] = { Pos = pos }
        ActivityCountDown[key].Fn = sched:scheduleScriptFunc(function()
            left = left - 0.1
            NodeHelper:setStringForLabel(container, { mTimeTxt = formatTime(left) })
            if left <= 0 then
                sched:unscheduleScriptEntry(ActivityCountDown[key].Fn)
                ActivityCountDown[key] = nil
                MainScenePageInfo:BuildBtnScrollview(MainScenePageInfo.container, pos, BtnScrollviewState[pos])
            end
        end, 0.1, false)
    elseif type(self.Time) ~= "number" then
        -- 非數字時間顯示固定文字
        NodeHelper:setStringForLabel(container, { mTimeTxt = common:getLanguageString("@GloryHoleOpenDay") })
    end

    -- 其餘顯示及位置設定不變
    local vis = {
        mTimeNode = (type(self.Time) == "string") or (self.Time > 0),
        mLock     = LockManager_getShowLockByPageName(self.Lock),
        mPoint    = self.Red and RedPointManager_getShowRedPoint(self.Red) or false,
    }
    NodeHelper:setNodesVisible(container, vis)
    NodeHelper:setMenuItemImage(container, { mBtn = { normal = self.Normal } })
    container:getVarNode("mPosition1"):setPositionY(vis.mTimeNode and 80 or 40)
end

-- 處理按鈕點擊事件
function BtnItem:onBtn()
  if self.Lock and LockManager_getShowLockByPageName(self.Lock) then
    MessageBoxPage:Msg_Box(LockManager_getLockStringByPageName(self.Lock))
    return
  end
  local fn = UIHandlers[self.fun]
  if fn then
    return fn()
  end
end

function OnEnterGame()
    if isEnterGame then
        return
    end
    isEnterGame = true
    OnEnterGameLoading()
    sendRoleInfo()
    MainScenePageInfo.RequestData()
end

function OnEnterGameLoading()
    local container = tolua.cast(MainFrame:getInstance(), "CCBScriptContainer")
    local parentNode = container:getVarNode("mEnterLoadingNode")
    if parentNode then
        parentNode:setVisible(true)
        parentNode:removeAllChildrenWithCleanup(true)

        local loadingNode = ScriptContentBase:create("NGLoading.ccbi")
        parentNode:addChild(loadingNode)
        loadingNode:release()
    end
end

function sendRoleInfo()
    if CC_TARGET_PLATFORM_LUA == common.platform.CC_PLATFORM_WIN32 then
        return
    end

    local GuildData = require("Guild.GuildData")

    local UserInfo = require("PlayerInfo.UserInfo")

    local info = GuildData.allianceInfo.commonInfo

    local guildName = " "
    if info then guildName = info.name end

    local serverId = GamePrecedure:getInstance():getServerID()

    TapDBManager.setUser(GamePrecedure:getInstance():getUin())
    TapDBManager.setName(tostring(UserInfo.roleInfo.name))
    TapDBManager.setServer(GamePrecedure:getInstance():getServerNameById(serverId))
    TapDBManager.setLevel(UserInfo.roleInfo.level)

    --if (Golb_Platform_Info.is_h365) then
    --    libPlatformManager:getPlatform():sendMessageG2P('G2P_REPORT_HANDLER',"2")
    --else
        local data ={}
        data['eventId'] = 2
        data['userId'] = GamePrecedure:getInstance():getUin()
        libPlatformManager:getPlatform():sendMessageG2P('G2P_REPORT_HANDLER',json.encode(data))
    --end

    setPayUrl() -- setPayurl(H365/JGG/KUSO/APLUS)
end

function setPayUrl()
    if Golb_Platform_Info.is_r18 or Golb_Platform_Info.is_erolabs then
        return
    end
    local Svrid = GamePrecedure:getInstance():getServerID()
    local PayUrl = ""
    if Golb_Platform_Info.is_h365 then
        if (NodeHelper:isDebug()) then
            if (Svrid == 1) then    --測試服1
                PayUrl = "http://54.255.44.130:5138/payNotice?params="
            elseif (Svrid == 2) then -- 測試服2
	    		PayUrl = "http://18.143.35.236:5138/payNotice?params="
            elseif (Svrid == 3) then -- 測試服3
	    		PayUrl = "http://18.143.216.175:5138/payNotice?params="
            elseif (Svrid == 6) then -- NGTest
	    		PayUrl = "http://18.182.62.36:5132/payNotice?params="
            elseif (Svrid == 9) then -- 內部102
	    		PayUrl = "http://220.130.219.201:5132/payNotice?params="
            --------------------------------
            elseif (Svrid == 1001) then -- 正式服1
	    		PayUrl = "http://175.41.148.243:5138/payNotice?params="
            elseif (Svrid == 1002) then -- 正式服2
	    		PayUrl = "http://13.215.133.203:5138/payNotice?params="
            end
        else
            if (Svrid == 1) then    --測試服
                PayUrl = "http://54.255.44.130:5138/payNotice?params="
            elseif (Svrid == 2) then -- 測試服2
	    		PayUrl = "http://18.143.35.236:5138/payNotice?params="
            elseif (Svrid == 3) then -- 測試服3
	    		PayUrl = "http://18.143.216.175:5138/payNotice?params="
            elseif (Svrid == 6) then
                PayUrl = "http://18.182.62.36:5132/payNotice?params="
            elseif (Svrid == 9) then -- 內部102
	    		PayUrl = "http://220.130.219.201:5132/payNotice?params="
            --------------------------------
            elseif (Svrid == 1001) then -- 正式服1
	    		PayUrl = "http://175.41.148.243:5138/payNotice?params="
            elseif (Svrid == 1002) then -- 正式服2
	    		PayUrl = "http://13.215.133.203:5138/payNotice?params="
            end
        end
    end

    if (Golb_Platform_Info.is_kuso or Golb_Platform_Info.is_aplus) then
        if (NodeHelper:isDebug()) then
            if (Svrid == 1) then    --測試服
                PayUrl = "https://gs01.paycallback.quantagalaxies.com/KusoPay?params="
            elseif (Svrid == 2) then -- 測試服2
	    		PayUrl = "https://gs02.paycallback.quantagalaxies.com/KusoPay?params="
            elseif (Svrid == 3) then -- 測試服3
	    		PayUrl = "https://gs03.paycallback.quantagalaxies.com/KusoPay?params="
            elseif (Svrid == 6) then -- NGTest
	    		PayUrl = "https://dev.paycallback.quantagalaxies.com/KusoPay?params="
            elseif (Svrid == 9) then -- 內部102
	    		PayUrl = "https://debug.paycallback.quantagalaxies.com/KusoPay?params="
            --------------------------------
            elseif (Svrid == 1001) then -- 正式服1
	    		PayUrl = "https://gs1001.paycallback.quantagalaxies.com/KusoPay?params="
            elseif (Svrid == 1002) then -- 正式服2
	    		PayUrl = "https://gs1002.paycallback.quantagalaxies.com/KusoPay?params="
            end
        else
            if (Svrid == 1) then    --測試服
                PayUrl = "https://gs01.paycallback.quantagalaxies.com/KusoPay?params="
            elseif (Svrid == 2) then -- 測試服2
	    		PayUrl = "https://gs02.paycallback.quantagalaxies.com/KusoPay?params="
            elseif (Svrid == 3) then -- 測試服3
	    		PayUrl = "https://gs03.paycallback.quantagalaxies.com/KusoPay?params="
            elseif (Svrid == 6) then
                PayUrl = "https://dev.paycallback.quantagalaxies.com/KusoPay?params="
            elseif (Svrid == 9) then -- 內部102
	    		PayUrl = "https://debug.paycallback.quantagalaxies.com/KusoPay?params="
            --------------------------------
            elseif (Svrid == 1001) then -- 正式服1
	    		PayUrl = "https://gs1001.paycallback.quantagalaxies.com/KusoPay?params="
            elseif (Svrid == 1002) then -- 正式服2
	    		PayUrl = "https://gs1002.paycallback.quantagalaxies.com/KusoPay?params="
            end
        end
    end
    libPlatformManager:getPlatform():setPayH365(PayUrl)
end

--- 添加主角Spine动画
function MainScenePageInfo.showRoleSpineExtend(container)
    if not container then
        return
    end
    local heroNode = container:getVarNode("mSpine")

    if heroNode then
        heroNode:removeAllChildrenWithCleanup(true)
        local mainHero = CCUserDefault:sharedUserDefault():getIntegerForKey("MAIN_HERO_" .. UserInfo.playerInfo.playerId)
        if mainHero == 0 then
            mainHero = 1000
        end
        local skinId = 0
        local fileName = "NG2D_" .. string.format("%02d", math.floor(mainHero / 1000))
        if mainHero % 1000 > 0 then
            skinId = mainHero
            --fileName = "NG2D_" .. string.format("%02d", math.floor(mainHero / 1000)) .. string.format("%03d", skinId)
            MainScenePageInfo.playMovie(container, skinId)
            return
        end
        --MainScenePageInfo.closeMovie(container)

        local spine = SpineContainer:create("NG2D", fileName)
        local spineNode = tolua.cast(spine, "CCNode")
        spine:runAnimation(1, "animation", -1)
        spineNode:setScale(NodeHelper:getScaleProportion())
        spineNode:setTag(10010)
        heroNode:addChild(spineNode)

        MainScenePageInfo.mainRoleSpine = spine
    end
end

function MainScenePageInfo.replayRoleSpineAnimation(container)
    CCLuaLog("replayRoleSpineAnimation1")
    MainScenePageInfo.showRoleSpineExtend(container)
    CCLuaLog("replayRoleSpineAnimation2")
end

function MainScenePageInfo.onExecute(container)
    
    if CurlDownload:getInstance() then
        CurlDownload:getInstance():update(0.2)
    end

    if NoticePointState.isChange then
        MainScenePageInfo.setNoticeNodes(container)
        NoticePointState.isChange = false
    end

    if assemblyFinish then
        assemblyFinish = false
        local GuideManager = require("Guide.GuideManager")
        if UserInfo.isShowLevelUp then
            UserInfo.isShowLevelUp = false
            if not GuideManager.isInGuide then
                GameUtil:showLevelUpAni()
            end
        end
    end

    -- 控制广播的时间	
    MainScenePageInfo.broadcastMessage(container)

    if TimeCalculator:getInstance():hasKey(mainActivityTimeIntervalKey) and
        tonumber(TimeCalculator:getInstance():getTimeLeft(mainActivityTimeIntervalKey)) <= 0
        or isEnter then
        TimeCalculator:getInstance():createTimeCalcultor(mainActivityTimeIntervalKey, activityTimeInterval)
        ----------------------
        --更新領獎提示紅點
        if NewBattleInfo.awardTime > 0 then
            local time = os.time() - NewBattleInfo.awardTime
            RedPointManager_refreshPageShowPoint(RedPointManager.PAGE_IDS.BATTLE_TREASURE_BTN, 1, { time = time })
        end
        -- 更新紅點
        NodeHelper:setNodesVisible(container, { 
            mForgePoint = RedPointManager_getShowRedPoint(RedPointManager.PAGE_IDS.LOBBY_FORGE_BTN),
        })
        if not LockManager_getShowLockByPageName(GameConfig.LOCK_PAGE_KEY.SECRET_MESSAGE) then
            require("SecretMessage.SecretMessageManager")
            local messageQueue = SecretMessageManager_getMessageQueue()
            if #messageQueue>0 then
               NodeHelper:setStringForLabel(container,{mMessageIndex=#messageQueue})
               NodeHelper:setNodesVisible(container, {mSummonPoint=true})
            else
                NodeHelper:setNodesVisible(container, {mSummonPoint=false})
            end
        else
            NodeHelper:setNodesVisible(container, {mSummonPoint=false})
        end
        -- 更新主Banner鎖頭
        MainFrame:getInstance():setChildVisible("mSummonLock", LockManager_getShowLockByPageName(GameConfig.LOCK_PAGE_KEY.SUMMON))
    end

    -- 忍娘語音視窗
    if TimeCalculator:getInstance():hasKey(voiceMsgTimeIntervalKey) and
       tonumber(TimeCalculator:getInstance():getTimeLeft(voiceMsgTimeIntervalKey)) <= 0  then
        NodeHelper:setNodesVisible(container, { mMessageNode = false })
    end
    -- pop pages
    local GuideManager = require("Guide.GuideManager")
    if TimeCalculator:getInstance():hasKey(popupPagesTimeIntervalKey) and
       tonumber(TimeCalculator:getInstance():getTimeLeft(popupPagesTimeIntervalKey)) <= 0 then
        TimeCalculator:getInstance():createTimeCalcultor(popupPagesTimeIntervalKey, popupPagesTimeInterval)
        if isEnterGameLoadingEnd then
            AutoPopupManager_checkAutoPopup()
        end
    end

    -- 教學遮罩
    if GuideManager.isInGuide then
        if GuideManager.getCurrentCfg() and (GuideManager.getCurrentCfg().openMask == 1) then
            MainFrame_setGuideMask(true)
        else
            MainFrame_setGuideMask(false)
        end
    else
        MainFrame_setGuideMask(false)
    end

    local dt = GamePrecedure:getInstance():getFrameTime()
    checkAndCloseMainSceneLoadingEnd(dt)
end

function MainScenePageInfo:setChat(msg)
    if not FreeTypeConfig or #FreeTypeConfig <= 0 then
        return
    end
    NodeHelper:setStringForLabel(self.container,{mChat=""})
    local ChatType=msg.chatType
    local ChatName=msg.voiceInfo[2]
    local ChatContent=msg.chatMsg
    if msg.voiceInfo[1]==GameConfig.SystemId then
        NodeHelper:setStringForLabel(self.container,{mChat=""})
        return 
    end
    for i=1,100 do
        ChatContent=ChatContent:gsub("/"..i.."/","[表情符號]")
    end
    local count=utf8Sub(ChatContent,10)
    if count>=10 then
        ChatContent = string.sub(ChatContent, 1, count).."..."
    end
     NodeHelper:setStringForLabel(self.container,{mChat=""})
    local string = nil
    if ChatType == Const_pb.CHAT_WORLD then
        string = FreeTypeConfig[301244].content
    elseif ChatType == Const_pb.CHAT_ALLIANCE then
        string = FreeTypeConfig[301245].content
    elseif ChatType == Const_pb.CHAT_PERSONAL then
        string = FreeTypeConfig[301246].content
    end
    string = GameMaths:replaceStringWithCharacterAll(string, "#v1#",ChatName)
    string = GameMaths:replaceStringWithCharacterAll(string, "#v2#", ChatContent)
    if MainScenePageInfo.container then
        MainScenePageInfo.container:getVarNode("mChat"):setPositionY(4)
        NodeHelper:setCCHTMLLabel(MainScenePageInfo.container, "mChat", CCSize(300, 5), string, false)
    end
end
function utf8Sub(str, n)
    local i = 1
    local len = #str
    local count = 0

    while count < n and i <= len do
        count = count + 1
        local byte = string.byte(str, i)
        if byte >= 240 then
            i = i + 4
        elseif byte >= 224 then
            i = i + 3
        elseif byte >= 192 then
            i = i + 2
        else
            i = i + 1
        end
    end

    return i-1
end
function MainScenePageInfo.onExit(container)
    if MainScenePageInfo.libPlatformListener then
        MainScenePageInfo.libPlatformListener:delete()
    end
    --[[ if MainScenePageInfo.CurlDownloadScriptListener then
        MainScenePageInfo.CurlDownloadScriptListener:delete()
    end]]
    --
    CCLuaLog("Z#:MainScenePageInfo.onExit!")
    MainScenePageInfo.removePacket(container)
    container:removeMessage(MSG_SEVERINFO_UPDATE)
    container:removeMessage(MSG_MAINFRAME_REFRESH)
    container:removeMessage(MSG_REFRESH_REDPOINT)
    isInAnimation = false
    broadCastTime = 0
    ConstCastTime = 0

    TimeCalculator:getInstance():removeTimeCalcultor(mainActivityTimeIntervalKey)
    TimeCalculator:getInstance():removeTimeCalcultor(voiceMsgTimeIntervalKey)
    TimeCalculator:getInstance():removeTimeCalcultor(popupPagesTimeIntervalKey)

    MainScenePageInfo.container = nil
    if voiceId then
        SimpleAudioEngine:sharedEngine():stopEffect(voiceId)
        voiceId = nil
    end
    if marqueeBanner then
        marqueeBanner:exit()
        marqueeBanner = nil
    end
    MainScenePageInfo.isInit = false

    if MainScenePageInfo.ActCountDown  then
        CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(MainScenePageInfo.ActCountDown)
        MainScenePageInfo.ActCountDown=nil                   
    end
    MainScenePageInfo.closeMovie(container)
end

function MainScenePageInfo.onUnLoad(container)
    CCLuaLog("Z#:MainScenePageInfo.onUnLoad!")
end

function MainScenePageInfo.onReceivePacket(container)
    local opcode = container:getRecPacketOpcode()
    local msgBuff = container:getRecPacketBuffer()
    if opcode == HP_pb.SYNC_LEVEL_INFO_S then
        local msg = Battle_pb.NewBattleLevelInfo()
        msg:ParseFromString(msgBuff)
        local takeTime = msg.TakeTime or 0
        NewBattleInfo.awardTime = takeTime
    elseif opcode == HP_pb.GET_FORMATION_EDIT_INFO_S then
        local msg = Formation_pb.HPFormationEditInfoRes()
        msg:ParseFromString(msgBuff)
        MainScenePageInfo:parseAllGroupInfosMsg_New(container, msg)
    elseif opcode == HP_pb.FETCH_SHOP_LIST_S then
        local msg = Recharge_pb.HPShopListSync()
        msg:ParseFromString(msgBuff)
        RechargeCfg = msg.shopItems
    elseif opcode == HP_pb.NP_CONTINUE_RECHARGE_MONEY_S then
        local msg = Activity5_pb.NPContinueRechargeRes()
        msg:ParseFromString(msgBuff)
        local DailyBundleData = require ("Activity.DailyBundleData")
        DailyBundleBase_SetInfo(msg)
        -- 跑馬燈 橫幅
        if marqueeBanner then
            marqueeBanner:exit()
            marqueeBanner = nil
        end
        local marqueeBannerNode = container:getVarNode("marqueeBannerNode")
        local marqueeBannerNodeSize = marqueeBannerNode:getContentSize()
        marqueeBannerNode:removeAllChildren()
        marqueeBanner = require("LobbyMarqueeBanner"):new():init()
        local marqueeBannerUI = marqueeBanner:getContainer()
        marqueeBannerNode:addChild(marqueeBannerUI)
    end
end

function MainScenePageInfo.onGameMessage(container)
    local message = container:getMessage()
    local typeId = message:getTypeId()
    if typeId == MSG_SEVERINFO_UPDATE then
        --[[local opcode = MsgSeverInfoUpdate:getTrueType(message).opcode;
		if common:table_hasValue(opcodes, opcode) then
			MainScenePageInfo.refreshPage(container);
		end--]]
    elseif typeId == MSG_MAINFRAME_REFRESH then
        local pageName = MsgMainFrameRefreshPage:getTrueType(message).pageName
        local extraParam = MsgMainFrameRefreshPage:getTrueType(message).extraParam
        CCLuaLog("MainScenePageInfo.MSG_MAINFRAME_REFRESH pageName :" .. pageName)
        if pageName == "MainScenePage" then
            if extraParam == "DailyQuest" then
                MainFrame_onBattlePageBtn()
            end
            if extraParam == "showActivityNotice" then
                return
            end
            if extraParam == "hideActivityNotice" then
                return
            end
            if extraParam == "showNodeNoticeInfo" then
                MainScenePageInfo.refreshFetchGiftBtn(container)
                return
            end

            local friendNotices = {
                FriendManager.onSyncApplyList,
                -- FriendManager.onNewFriendAdd,
                FriendManager.onNewFriendApply
            }
            if common:table_hasValue(friendNotices, extraParam) then
                NodeHelper:setNodesVisible(container, { mFriendPoint = true })
                return
            end
            if extraParam == FriendManager.onNoticeChecked then
                NodeHelper:setNodesVisible(container, { mFriendPoint = false })
                return
            end
            if extraParam == "refreshIcon" then
                MainScenePageInfo.setPlayerIcon(container)
                MainScenePageInfo.showRoleSpineExtend(container)
                return
            end
            if extraParam == "refreshInfo" then
                MainScenePageInfo.showPlayerInfo(container)
                return
            end
            CCLuaLog("MainScenePageInfo.MSG_MAINFRAME_REFRESH :" .. extraParam)
            if string.find(extraParam, "isShowActivity") then
                MainScenePageInfo.refreshMainIcon(container)
                return
            else
                MainScenePageInfo.refreshPage(container)
                return
            end
        elseif pageName == GVGManager.moduleName then
            if extraParam == GVGManager.onRewardInfo then
                NodeHelper:setNodeVisible(container, { mGuildPagePoint = NoticePointState.GUILD_SIGNIN or NoticePointState.ALLIANCE_BOSS_OPEN })
            end
        elseif pageName == "ArenaPage" then
            return
        elseif pageName == "FetterSystem" then
            return
        end
        MainScenePageInfo.showPlayerInfo(container)
        resetAllMenu()
        setCCBMenuAnimation("mMainPageBtn", "Selected")
    elseif typeId == MSG_REFRESH_REDPOINT then
        MainScenePageInfo:refreshAllPoint(container)
    end
end
function MainScenePageInfo:refreshAllPoint(container)
    NodeHelper:setNodesVisible(container, { mMailPoint = RedPointManager_getShowRedPoint(RedPointManager.PAGE_IDS.LOBBY_MAIL_BTN, 1) })
    NodeHelper:setNodesVisible(container, { mBagPoint = RedPointManager_getShowRedPoint(RedPointManager.PAGE_IDS.LOBBY_BAG_BTN, 0) })
    for i = 1, #btnItemsLeft do
        BtnItem:onRefreshPoint(btnItemsLeft[i].cell, btnItemsLeft[i].handler)
    end
    for i = 1, #btnItemsRight do
        BtnItem:onRefreshPoint(btnItemsRight[i].cell, btnItemsRight[i].handler)
    end
end

-- 控制主界面中所有的"N"红点显隐
function MainScenePageInfo.setNoticeNodes(container)
    if UserInfo.stateInfo.leftFreeRefreshShopTimes > 0 or GameConfig.shopRedPoint == true then
        -- 月卡免费次数
        NoticePointState.SHOP_POINT = true
    else
        NoticePointState.SHOP_POINT = false
    end
end
-- 刷新七日祭icon紅點
function MainScenePageInfo.refreshSevenDayRedPoint()
    for i = 1, #ActivityInfo.NewPlayerLevel9Ids do
        local id = ActivityInfo.NewPlayerLevel9Ids[i]
        if ActivityInfo.NoticeInfo.NewPlayerLevel9Ids[id] then
            return true
        end
    end
    return false
end
-- 刷新新手登入icon紅點
function MainScenePageInfo.refreshNewPlayerRedPoint()
    for i = 1, #ActivityInfo.NewPlayerLogin do
        local id = ActivityInfo.NewPlayerLogin[i]
        if ActivityInfo.NoticeInfo.NewPlayerLogin[id] then
            return true
        end
    end
    return false
end
-- 刷新彈跳禮包icon紅點
function MainScenePageInfo.refreshPopUpSaleRedPoint()
    for i = 1, #ActivityInfo.PopUpSaleIds do
        local id = ActivityInfo.PopUpSaleIds[i]
        if ActivityInfo.NoticeInfo.PopUpSaleIds[id] then
            return true
        end
    end
    return false
end

function MainScenePageInfo.refreshPage(container)
    MainScenePageInfo.showPlayerInfo(container)
    MainScenePageInfo.refreshFetchGiftBtn(container)
    MainScenePageInfo.setPlayerIcon(container)
    MainScenePageInfo.refreshMainIcon(container)
    MainScenePageInfo.refreshLock(container)
end

function MainScenePageInfo.showPlayerInfo(container)
    UserInfo.sync()

    local lb2Str = {
        mName = UserInfo.roleInfo.name,
        mGold = GameUtil:formatNumber(UserInfo.playerInfo.coin),
        mDiamond = GameUtil:formatNumber(UserInfo.playerInfo.gold),
        mLV = UserInfo.roleInfo.level,
        mFightPoint=UserInfo.roleInfo.marsterFight
    }
    -- 设置各种文字
    NodeHelper:setStringForLabel(container, lb2Str)

    -- 刷新经验条
    MainScenePageInfo.RefreshExpBar(container)
    MainFrame_RefreshExpBar()
    --VIPIcon
    NodeHelper:setSpriteImage(container,{mVipIcon="PlayerInfo_VIP"..UserInfo.playerInfo.vipLevel..".png"})
end

-- 刷新经验条
function MainScenePageInfo.RefreshExpBar(container)
    local currentExp = UserInfo.roleInfo.exp
    local roleExpCfg = ConfigManager.getRoleLevelExpCfg()

    if currentExp ~= nil and roleExpCfg ~= nil then
        local barImg = container:getVarSprite("mExpSprite")
        if barImg then
            local nextLevelExp = currentExp
            if UserInfo.roleInfo.level >= ConfigManager.getLevelLimitCfg()[GameConfig.LevelLimitCfgKey.roleLevelLimit].level then
                barImg:setScaleX(1)
            else
                if UserInfo.roleInfo and roleExpCfg[UserInfo.roleInfo.level] then
                    nextLevelExp = roleExpCfg[UserInfo.roleInfo.level]["exp"]
                    assert(nextLevelExp ~= nil, "MainFrame_RefreshExpBar roleExpCfg nextLevelExp is nil")
                    local percent = math.min(currentExp / nextLevelExp, 1)
                    if percent >= 0 then
                        barImg:setScaleX(percent)
                    end
                end
            end
        end
    end
end

function MainScenePageInfo.setPlayerIcon(container)
    local roleIcon = ConfigManager.getRoleIconCfg()
    local trueIcon = GameConfig.headIconNew or UserInfo.playerInfo.headIcon
    local icon, bgIcon = common:getPlayeIcon(UserInfo.roleInfo.prof, trueIcon)

    if not roleIcon[trueIcon] then
        local icon = common:getPlayeIcon(UserInfo.roleInfo.prof, trueIcon)
        if NodeHelper:isFileExist(icon) then
            NodeHelper:setSpriteImage(container, { mPlayerSprite = icon })
        end
    else
        NodeHelper:setSpriteImage(container, { mPlayerSprite = roleIcon[trueIcon].MainPageIcon })
    end
end

function MainScenePageInfo_resetFirstClick()
    CCLuaLog("MainScenePageInfo_resetFirstClick 1")
    MainScenePageInfo.replayRoleSpineAnimation(MainScenePageInfo.container)
    CCLuaLog("MainScenePageInfo_resetFirstClick 2")
end

function MainScene_ResetForAssembly()
    assemblyFinish = true
    if BlackBoard:getInstance():hasVarible("assemblyFinish") then
        BlackBoard:getInstance():setVarible("assemblyFinish", true)
    else
        BlackBoard:getInstance():addVarible("assemblyFinish", true)
    end
end

function MainScene_openGameLoadingEnd()
    if MainScenePageInfo.container then
        MainScenePageInfo.container:stopAllActions()
        MainScenePageInfo.container:runAnimation("AdventureOpen2")
    end
    MainScenePageInfo.showRoleSpineExtend(MainScenePageInfo.container)
    isEnterGameLoadingEnd = true
    MainScene_checkGuide()
end

function MainScene_checkGuide()
    if isEnterGameLoadingEnd then
        local GuideManager = require("Guide.GuideManager")
        GuideManager.newbieGuide()
        if GuideManager.isInGuide then
            PageManager.pushPage("NewbieGuideForcedPage")
        else
            for i = 2, GuideManager.guideType.MAX_NUM do
                GuideManager.openOtherGuideFun(i, true)
            end
        end
    end
end
--------------------------------------------------------------------------------------------------
-- 取得隊伍資料
function MainScenePageInfo:sendEditInfoReq(container)
    local msg = Formation_pb.HPFormationEditInfoReq()
    msg.index = 1
    common:sendPacket(HP_pb.GET_FORMATION_EDIT_INFO_C, msg, false)
end
function MainScenePageInfo:sendArenaEditInfoReq(container)
    local msg = Formation_pb.HPFormationEditInfoReq()
    msg.index = 8
    common:sendPacket(HP_pb.GET_FORMATION_EDIT_INFO_C, msg, false)
end
-- 接收編隊資訊
function MainScenePageInfo:parseAllGroupInfosMsg_New(container, msg)
    local formation = msg.formations
    local mAllGroupInfos = {}
    mAllGroupInfos[formation.index] = { roleIds = { } }
    mAllGroupInfos[formation.index].name = formation.name
    local groupStr = formation.name .. "_"
    for i = 1, #formation.roleIds do
        table.insert(mAllGroupInfos[formation.index].roleIds, formation.roleIds[i])
        groupStr = groupStr .. formation.roleIds[i] .. "_"
    end
    CCUserDefault:sharedUserDefault():setStringForKey("GROUP_INFOS_" .. formation.index .. "_" .. UserInfo.playerInfo.playerId, groupStr) 
end

function MainScenePageInfo.onTouchHero(container)
    local mainHero = CCUserDefault:sharedUserDefault():getIntegerForKey("MAIN_HERO_" .. UserInfo.playerInfo.playerId)
    if mainHero == 0 then
        mainHero = 1000
    end
    local heroId = math.floor(mainHero / 1000)
    local skinId = mainHero % 1000
    local rand = math.random(1, 3)
    if voiceId then
        SimpleAudioEngine:sharedEngine():stopEffect(voiceId)
        voiceId = nil
    end
    local fileName = nil
    if rand == 1 then
        fileName = heroId .. "_1" .. string.format("%02d", heroId) .. "0"
    elseif rand == 2 then
        fileName = heroId .. "_1" .. string.format("%02d", heroId) .. "1"
    elseif rand == 3 then
        fileName = heroId .. "_31"
    end
    if fileName then
        --voiceId = NodeHelper:playEffect(fileName .. ".mp3")
        local showString = common:getLanguageString("@audio_" .. fileName)
        -- TODO 顯示訊息窗
        TimeCalculator:getInstance():createTimeCalcultor(voiceMsgTimeIntervalKey, voiceMsgTimeInterval)
        NodeHelper:setNodesVisible(container, { mMessageNode = true })
        NodeHelper:setStringForLabel(container, { mMessageTxt = showString })
    end
end

function MainScenePageInfo.setActivityTime(Time)
    local container = MainScenePageInfo.container
    NodeHelper:setNodesVisible(container,{ mTimeNode = true })
    if not MainScenePageInfo.ActCountDown then
        MainScenePageInfo.ActCountDown = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(function()
            -- 更新 leftTime
            Time = Time - 0.1
            local txt = common:dateFormat2String(Time, true)
            NodeHelper:setStringForLabel(container, {mTimeTxt = txt})         
        end, 0.1, false)
        if Time<=0 then
            CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(MainScenePageInfo.ActCountDown)
            MainScenePageInfo.ActCountDown = nil
            NodeHelper:setNodesVisible(container,{mActivityNode = false})
        end
    end
end

-- 播放mp4
function MainScenePageInfo.playMovie(container, skinId)
    -- 播放影片
    local fileName = "Hero/Hero" .. string.format("%05d", skinId)
    local isFileExist =  CCFileUtils:sharedFileUtils():isFileExist("Video/" .. fileName .. ".mp4")
    if isFileExist then
        --MainScenePageInfo.libPlatformListener = LibPlatformScriptListener:new(libPlatformListener)
        GamePrecedure:getInstance():playMovie(thisPageName, fileName, 1, 0)
        NodeHelper:setNodesVisible(container, { mSpine = false })
    end
end
-- 關閉影片
function MainScenePageInfo.closeMovie(container)
    CCLuaLog("MainScenePageInfo:closeMovie")
    NodeHelper:setNodesVisible(container, { mSpine = true })
    GamePrecedure:getInstance():closeMovie(thisPageName)
end

return MainScenePageInfo
