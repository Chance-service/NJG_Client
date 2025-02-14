local NodeHelper = require("NodeHelper")
local thisPageName = 'Event001Page'
local Activity5_pb = require("Activity5_pb");
local HP_pb = require("HP_pb");
local InfoAccesser = require("Util.InfoAccesser")

local Event001Base =  {}
local option = {
    ccbiFile = "NGEvent_001_Main.ccbi",
    handlerMap ={},
}

local DailyMissionContent = {
    ccbiFile = "NGEvent_001_EventMissionContent.ccbi",
    BarLong = 121
}
local AchivementContent = {
    ccbiFile = "NGEvent_001_EventMissionContent.ccbi",
    BarLong = 121
}

local StageData = {}
local QuestData = {Daily = {content = {},DailyPoint = { },Target = {}},Achive = {nowPassed={} }}

local opcodes = {
    CYCLE_LIST_INFO_S = HP_pb.CYCLE_LIST_INFO_S,
    ACTIVITY191_CYCLE_STAGE_S = HP_pb.ACTIVITY191_CYCLE_STAGE_S,
    PLAYER_AWARD_S = HP_pb.PLAYER_AWARD_S
}

local DailyCCB = {}

local EventPageInfo={
    container = nil,
    CountDown = nil
}

function Event001Base:onLoad(container)
    container:loadCcbiFile(option.ccbiFile)
end

function Event001Base:onEnter(container)
    SoundManager:getInstance():playGeneralMusic()
    EventPageInfo.container = container
    container:registerFunctionHandler(Event001Base.onFunction)
    Event001Base:sendQuest(2)
    self:registerPacket(container)
    --common:sendEmptyPacket(HP_pb.CYCLE_LIST_INFO_C,false)
    self:refresh()
    local PageJumpMange = require("PageJumpMange")
    if PageJumpMange._IsPageJump then
        if PageJumpMange._CurJumpCfgInfo._ThirdFunc ~= "" then
           Event001Base.onFunction(PageJumpMange._CurJumpCfgInfo._ThirdFunc,container)
        end
        PageJumpMange._IsPageJump = false
    else
        require("TransScenePopUp")
        TransScenePopUp_closePage()
    end
    CCUserDefault:sharedUserDefault():setStringForKey("ACT191_"..UserInfo.playerInfo.playerId,StageData.startTime)
end

function Event001Base:refresh()
    local container = EventPageInfo.container
    if not container then return end
    local Count_7002 = InfoAccesser:getUserItemInfo(Const_pb.TOOL, 7002).count or 0
    local Count_7003 = InfoAccesser:getUserItemInfo(Const_pb.TOOL, 7003).count or 0
    local stringTable = {}
    stringTable["m7002Count"] = Count_7002
    stringTable["m7003Count"] = common:getLanguageString("@activitystageCount",Count_7003)

    local txt = common:getDayNumber(StageData.leftTime) + 1 .. common:getLanguageString("@Days")
    stringTable["mLeftTime"] = txt
 
    NodeHelper:setStringForLabel(container,stringTable)
end

function Event001Base.onFunction(eventName,container)
    if eventName == "luaLoad" then
        Event001Base:onLoad(container)
    elseif eventName == "luaEnter" then
        Event001Base:onEnter(container)
    elseif eventName =="onReturn" then
        PageManager.popPage(thisPageName)
        if EventPageInfo.CountDown then
            CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(EventPageInfo.CountDown)
            EventPageInfo.CountDown = nil
        end
    elseif eventName == "onMission" then
        NodeHelper:setNodesVisible(container, {mMission = true, mDailyOn = true, mAchiveOn = false, mAchiveScrollview = false, mTaskNode = true, mNotOpenMask = false})
        NodeHelper:setStringForLabel(container, {mTitle = common:getLanguageString("@Act141DailyTasksBtnText")})
    elseif eventName == "onCloseMission" then
        NodeHelper:setNodesVisible(container,{mMission = false})
    elseif eventName == "onDailyMission" then
       NodeHelper:setNodesVisible(container, {mDailyOn = true, mAchiveOn = false, mAchiveScrollview = false, mTaskNode = true, mNotOpenMask = false})
       Event001Base:sendQuest(2)
       NodeHelper:setStringForLabel(container, {mTitle = common:getLanguageString("@Act141DailyTasksBtnText")})
     elseif eventName == "onAchiveMission" then
        NodeHelper:setNodesVisible(container, {mDailyOn = false, mAchiveOn = true, mAchiveScrollview = true, mTaskNode = false , mNotOpenMask = false})
        Event001Base:sendQuest(0)
        NodeHelper:setStringForLabel(container, {mTitle = common:getLanguageString("@TaskAchievementName")})
    elseif eventName =="onBattle" then
        PageManager.pushPage("Event001BattlePage")
    elseif eventName == "onShop" then
        PageManager.pushPage("ShopControlPage")
    elseif eventName == "onHistory" then
        local StoryTable = Event001Base:CreateMapTable()
        local StoryLogPage= require("Event001StoryLog")
        StoryLogPage:SetData(StoryTable)
        PageManager.pushPage("Event001StoryLog")
    elseif eventName =="luaReceivePacket" then
        Event001Base:onReceivePacket(container)
    end
end

function  Event001Base:onReceivePacket(container)
    local opcode = container:getRecPacketOpcode();
    local msgBuff = container:getRecPacketBuffer();

    if opcode == HP_pb.PLAYER_AWARD_S then
        local PackageLogicForLua = require("PackageLogicForLua")
        PackageLogicForLua.PopUpReward(msgBuff)    
    end
end

function DailyCCB.onFunction(eventName, container)
    --local BgImg = "message_GH_bg.png"
    local function handleEvent(targetIndex,rewardPoint)
        if Target[targetIndex] == targetIndex then
            MessageBoxPage:Msg_Box_Lan("@dailyQuestPointGotTxt")
        elseif Target[targetIndex] ~= targetIndex and QuestData.Daily.DailyPoint < targetIndex then
            RegisterLuaPage("DailyTaskRewardPreview")
            ShowRewardPreview(ConfigManager.get191DailyQuestPointCfg()[rewardPoint].award, common:getLanguageString("@TaskDailyRewardPreviewTitle"), common:getLanguageString("@TaskDailyRewardPreviewInfo"), BgImg)
            PageManager.pushPage("DailyTaskRewardPreview")
        else
            Event001Base:sendQuest(4,rewardPoint)
        end
    end
    
    if eventName == "onGetBox1" then
        handleEvent(25, QuestData.Daily.DailyPoint, 25)
    elseif eventName == "onGetBox2" then
        handleEvent(50, QuestData.Daily.DailyPoint, 50)
    elseif eventName == "onGetBox3" then
        handleEvent(75, QuestData.Daily.DailyPoint, 75)
    elseif eventName == "onGetBox4" then
        handleEvent(100, QuestData.Daily.DailyPoint, 100)
    end
end
function Event001Base:SetStageInfo(msg)
    StageData.PassedId = msg.passId
    StageData.startTime = msg.starTime/1000
    StageData.leftTime = msg.leftTime
    StageData.useItem = msg.item

    if not EventPageInfo.CountDown and StageData.leftTime<86400 then
        EventPageInfo.CountDown = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(function()
            -- 更新 leftTime
            StageData.leftTime = StageData.leftTime - 1
            local txt = common:dateFormat2String(StageData.leftTime, true)
            NodeHelper:setStringForLabel(EventPageInfo.container, {mLeftTime=txt})
        end, 1, false)
    else
        local txt = common:getDayNumber(StageData.leftTime) + 1 .. common:getLanguageString("@Days")
        NodeHelper:setStringForLabel(EventPageInfo.container, {mLeftTime=txt})
    end
end

function Event001Base:getStageInfo()
    return StageData
end

function Event001Base:SetQuestInfo(msg)
    if msg.action==0 or msg.action==1 then
        local cfg = ConfigManager.getAct191Achive()
        for i, quest in ipairs(cfg) do
            QuestData.Achive[i] = { }
            QuestData.Achive.nowPassed = msg.questInfo.passId
            local achive = QuestData.Achive[i]
            achive.Quest = quest
            
            -- 判斷是否完成任務
            if quest.targetType == 2 then
                achive.isPass = (msg.questInfo.passId == quest.needCount)
            else
                achive.isPass = (msg.questInfo.passId >= quest.needCount)
            end
        
            -- 判斷獎勵是否已領取
            achive.isGot = false
            for _, takeId in ipairs(msg.questInfo.takeId) do
                if quest.id == takeId then
                    achive.isGot = true
                    break
                end
            end
        end
         Event001Base:BuildScrollview(EventPageInfo.container)
    end
    if msg.action==2 or msg.action==3 or msg.action==4 then
        local finishedQuest={}
        QuestData.Daily.content = {}
        local QuestCount = #msg.dailyInfo.allDailyQuest
        for i=1,QuestCount do
            if msg.dailyInfo.allDailyQuest.takeStatus == 1 then
                table.insert(finishedQuest,msg.dailyInfo.allDailyQuest[i])
            else
                table.insert(QuestData.Daily.content,msg.dailyInfo.allDailyQuest[i])
                QuestData.Daily.DailyPoint=msg.dailyInfo.dailyPoint
                QuestData.Daily.Target[i]=msg.dailyInfo.dailyPointCore[i] or nil
            end
        end
        table.merge(QuestData.Daily.content,finishedQuest)
        Event001Base:BuildScrollview(EventPageInfo.container, true)
    end

end
function table.merge(t1, t2)
    for k, v in ipairs(t2) do
        table.insert(t1, v)
    end
    return t1
end

function Event001Base:BuildScrollview(container, isDaily)
    local _Daily = false
    local Scrollview
    local Data = QuestData
    if isDaily ~= nil then
        _Daily = isDaily
    end
    if _Daily then
        local parent = container:getVarNode("mTaskNode")
        parent:removeAllChildrenWithCleanup(true)
        local TaskCCB = ScriptContentBase:create("GloryHole_DailyContent")
        Target = {}
        for i = 1, 4 do
            local TargetId = Data.Daily.Target[i] and Data.Daily.Target[i].dailyPointNumber or i * 25
            Target[TargetId] = Data.Daily.Target[i] and Data.Daily.DailyPoint or {}
        end
        TaskCCB:registerFunctionHandler(DailyCCB.onFunction)
        Event001Base:SetContentSize(TaskCCB, 100, Data.Daily.DailyPoint)
        NodeHelper:setStringForLabel(TaskCCB, {mNowPoint = Data.Daily.DailyPoint or 0})
        NodeHelper:setNodesVisible(TaskCCB, {mBoxPoint1 = (Data.Daily.DailyPoint >= 25 and Target[25] ~= 25),
            mBoxPoint2 = (Data.Daily.DailyPoint >= 50 and Target[50] ~= 50),
            mBoxPoint3 = (Data.Daily.DailyPoint >= 75 and Target[75] ~= 75),
            mBoxPoint4 = (Data.Daily.DailyPoint >= 100 and Target[100] ~= 100)})
        parent:addChild(TaskCCB)
        local Scrollview = TaskCCB:getVarScrollView("mContent")
        Scrollview:removeAllCell()
        for _, Data in pairs(Data.Daily.content) do
            local Info = Data
            local cell = CCBFileCell:create()
            cell:setCCBFile(DailyMissionContent.ccbiFile)
            local handler = common:new({Data = Info}, DailyMissionContent)
            cell:registerFunctionHandler(handler)
            Scrollview:addCell(cell)
        end
        Scrollview:orderCCBFileCells()
    else
        local scrollview = container:getVarScrollView("mAchiveScrollview")
        scrollview:removeAllCell()

        local BuildTable={}
        local finishedTable={}

        for k, Info in pairs(Data.Achive) do         
            if Info~= 0 and Info.isGot then
                table.insert(finishedTable,Info)
            elseif Info~=0 then
                table.insert(BuildTable,Info)
            end
        end
        for k,v in pairs (finishedTable) do
            table.insert(BuildTable,v)
        end
        for i = 1, #BuildTable do
            local Info = BuildTable[i]
            local cell = CCBFileCell:create()
            cell:setCCBFile(AchivementContent.ccbiFile)
            local handler = common:new({ data = Info }, AchivementContent)
            cell:registerFunctionHandler(handler)
            cell:setScale(0.99)
            scrollview:addCell(cell)
        end
        scrollview:orderCCBFileCells()
    end
end

function Event001Base:setContentScale(container, MaxData, SeverData)
    local Scale = SeverData / tonumber(MaxData) or 0
    if Scale > 1 then Scale = 1 end
    local Bar = tolua.cast(container:getVarNode("mCountSprite"), "CCScale9Sprite")
    Bar:setContentSize(CCSize(DailyMissionContent.BarLong * Scale, Bar:getContentSize().height))
    if SeverData == 0 then
        NodeHelper:setNodesVisible(container, {mCountSprite = false})
    else
        NodeHelper:setNodesVisible(container, {mCountSprite = true})
    end
end

function Event001Base:SetContentSize(container, MaxData, Data)
    local Scale = Data / tonumber(MaxData) or 0
    if Scale > 1 then Scale = 1 end
    local Bar = tolua.cast(container:getVarNode("mBar"), "CCScale9Sprite")
    Bar:setContentSize(CCSize(399 * Scale, Bar:getContentSize().height))
    if Data == 0 then
        NodeHelper:setNodesVisible(container, {mBar = false})
    else
        NodeHelper:setNodesVisible(container, {mBar = true})
    end
end

function Event001Base:sendQuest(_action,_id)
    local msg = Activity5_pb.CycleStageReq()
    msg.action = _action--0.同步成就資訊 1.成就領獎 2.同步日常任務資訊 3.日常任務領獎 4.日常任務點數領獎
    if _id then
        msg.choose = _id
    end
   common:sendPacket(HP_pb.ACTIVITY191_CYCLE_STAGE_C, msg, true)
end

function Event001Base:StageInfo()
   common:sendEmptyPacket(HP_pb.CYCLE_LIST_INFO_C, false)
end

function Event001Base:CreateMapTable()
    local MapTable = {}
    local fetterControlCfg = ConfigManager:getEvent001ControlCfg()
    for i = 1 , 2 do
        local _chapter = i
        for j = 1 , 99 do
            local _level = j
            local _mapId =  Event001Base:getMapId(_chapter,_level)
            for k = 1, 2 do
                local _id = tonumber(string.format("%02d", _chapter) .. string.format("%02d", _level) ..k.."01")
                if fetterControlCfg[_id] then
                    table.insert(MapTable, { mapId=_mapId, id=_id,chapter=_chapter,level=_level,StoryIdx=k ,MapIdx=1})
                end      
            end
        end
    end
    return MapTable
end

function Event001Base:getMapId(chapter,level)
    local cfg = ConfigManager.get191StageCfg()
    for k,v in pairs(cfg) do
        if chapter == v.type and level == v.star then
            return k
        end
    end
end

function DailyMissionContent:onRefreshContent(ccbRoot)
    local container = ccbRoot:getCCBFileNode()
    local cfg = ConfigManager.get191DailyQuest()
    local questId = self.Data.questId
    local takeStatus = self.Data.takeStatus
    local questStatus = self.Data.questStatus
    local taskRewards = self.Data.taskRewards
    local questCompleteCount = self.Data.questCompleteCount
    local StringTable = {}
    local VisableTable = {}
    local value = cfg[questId]
    local normalImage = NodeHelper:getImageByQuality(value.quality)
    local iconBg = NodeHelper:getImageBgByQuality(value.quality)
    if questCompleteCount > value.targetCount then
        questCompleteCount = value.targetCount
    end
    container:getVarNode("mContent"):setScale(0.9)
    container:getVarLabelTTF("mContent"):setDimensions(CCSize(340, 100))
    VisableTable["mStarNode"] = false
    VisableTable["selectedNode"] = false
    VisableTable["nameBelowNode"] = false
    StringTable["mContent"] = common:getLanguageString(value.content)
    StringTable["mName"] = common:getLanguageString(value.name)
    StringTable["mCount"] = questCompleteCount .. "/" .. value.targetCount
    StringTable["mBtnTxt"] = common:getLanguageString("@GVGRewardGetTxt")
    if takeStatus == 1 then
        StringTable["mBtnTxt"] = common:getLanguageString("@AlreadyReceive")
    end
    StringTable["mNumber1_1"] = value.des
    Event001Base:setContentScale(container, value.targetCount, questCompleteCount)
    NodeHelper:setStringForLabel(container, StringTable)
    NodeHelper:setMenuItemsEnabled(container, {mBtn = (takeStatus == 0 and questStatus == 1)})
    NodeHelper:setNodesVisible(container, VisableTable)
    NodeHelper:setSpriteImage(container, {mFrameShade1 = iconBg, mPic1 = value.icon})
    NodeHelper:setMenuItemImage(container, {mHand1 = {normal = normalImage}})
end

function DailyMissionContent:onBtn()
    Event001Base:sendQuest(3,self.Data.questId)
end

function DailyMissionContent:onHand1(container)
    GameUtil:showTip(container:getVarNode('mPic1'), common:parseItemWithComma(self.Data.taskRewards)[1])
end

function AchivementContent:onRefreshContent(ccbRoot)
    local container = ccbRoot:getCCBFileNode()
    local Quest = self.data.Quest
    local reward = Quest.reward[1]
    
    local StringTable = {}
    local VisableTable = {}

    VisableTable["mStarNode"] = false
    VisableTable["selectedNode"] = false
    VisableTable["nameBelowNode"] = false
    
    local resInfo = ResManagerForLua:getResInfoByTypeAndId(reward.type, reward.itemId, reward.count)
    local normalImage = NodeHelper:getImageByQuality(resInfo.quality)
    local iconBg = NodeHelper:getImageBgByQuality(resInfo.quality)
    NodeHelper:setMenuItemImage(container, {mHand1 = {normal = normalImage}})
    container:getVarNode("mContent"):setScale(0.9)
    container:getVarLabelTTF("mContent"):setDimensions(CCSize(340, 100))
    
    NodeHelper:setSpriteImage(container, {mPic1 = resInfo.icon, mFrameShade1 = iconBg})
    StringTable["mNumber1_1"] = reward.count
    StringTable["mContent"] = common:getLanguageString(Quest.content)
    StringTable["mName"] = common:getLanguageString(Quest.name)
    local nowPass = math.max(QuestData.Achive.nowPassed-1,0)
    StringTable["mCount"] = nowPass .."/"..Quest.needCount
    Event001Base:setContentScale(container, Quest.needCount, nowPass)
    if self.data.isPass then
        StringTable["mBtnTxt"] = common:getLanguageString("@GVGRewardGetTxt")
    else
        if self.data.isGot then
            StringTable["mBtnTxt"] = common:getLanguageString("@AlreadyReceive")
        else
            StringTable["mBtnTxt"] = common:getLanguageString("@GVGRewardGetTxt")
        end
    end
    NodeHelper:setStringForLabel(container, StringTable)
    NodeHelper:setMenuItemsEnabled(container, {mBtn = self.data.isPass and not self.data.isGot})
    NodeHelper:setNodesVisible(container, VisableTable)
end

function AchivementContent:onBtn()
    Event001Base:sendQuest(3,self.data.Quest.id)
end

function AchivementContent:onHand1(container)
    GameUtil:showTip(container:getVarNode('mPic1'), self.data.Quest.reward[1])
end

function Event001Base:registerPacket(container)
    for key, opcode in pairs(opcodes) do
        if string.sub(key, -1) == "S" then
            container:registerPacket(opcode)
        end
    end
end

function Event001Base:removePacket(container)
    for key, opcode in pairs(opcodes) do
        if string.sub(key, -1) == "S" then
            container:removePacket(opcode);
        end
    end
end 


function Event001Base:onHelp(container)
    PageManager.showHelp(GameConfig.HelpKey.HELP_GLORY_HOLE)
end
local CommonPage = require('CommonPage')
local Event001Page = CommonPage.newSub(Event001Base, thisPageName, option)

return Event001Page
