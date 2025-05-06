----------------------------------------------
-- 模塊引入與全局局部變數定義
----------------------------------------------
local NodeHelper      = require("NodeHelper")
local Activity6_pb    = require("Activity6_pb")
local HP_pb           = require("HP_pb")
local CONST           = require("Battle.NewBattleConst")
local TimeDateUtil    = require("Util.TimeDateUtil")
local TowerDataBase   = require "Tower.TowerPageData"

local TowerBase       = {}
local parentPage      = nil
local selfContainer   = nil
local TOWER_CELL_HEIGHT = 290  -- 每層高度
local countdownScheduler = nil
local isTowerMoving   = false
local SwitchTowerCD   = false

local TowerContent    = { ccbiFile = "TowerOnelife_StageContent.ccbi" }
local RewardContent   = { ccbiFile = "Tower_PopupContent.ccbi" }
local TaskContent = { ccbiFile = "TaskContent.ccbi"}

local _curShowTaskInfo = {}

local StageContent    = { ccbiFile = "TowerOnelife_LevelContent.ccbi" }
local StageContainers = {}
local StageClear = {}

local RewardPopCCB    = nil
local TaskPopUpCCB = nil
local PageInfo        = {}
local nowType         = 1

local mainContainer = nil

local BAR_WIDTH = 100
local BAR_HEIGHT = 21
----------------------------------------------
-- 頁面選項
----------------------------------------------
local pageOption = {
    ccbiFile   = "TowerOnelife.ccbi",
    handlerMap = {
        onBack   = "onBack",
        onHelp   = "onHelp",  -- 爬塔說明
        onReward = "onReward",
        onEffect = "onEffect",
        onAchive = "onAchive"
    },
}

local opcodes = {
    ACTIVITY199_FEAR_LESS_TOWER_C = HP_pb.ACTIVITY199_FEAR_LESS_TOWER_C,
    ACTIVITY199_FEAR_LESS_TOWER_S = HP_pb.ACTIVITY199_FEAR_LESS_TOWER_S,
    BATTLE_FORMATION_S         = HP_pb.BATTLE_FORMATION_S,
}
----------------------------------------------
-- local function 
----------------------------------------------

-- RewardPopFunction：用於彈窗內容處理
local function RewardPopFunction(eventName, container)
    if eventName == "onClose" then
        local parentNode = selfContainer:getVarNode("mPopUpNode")
        if parentNode then
            parentNode:removeAllChildren()
        end
    end
end

local function TaskPopFunction(eventName, container)
    if eventName == "onClose" then
        local parentNode = selfContainer:getVarNode("mPopUpNode")
        if parentNode then
            parentNode:removeAllChildren()
        end
    end
end

----------------------------------------------
-- TowerBase 方法定義
----------------------------------------------

function TowerBase:createPage(_parentPage)
    local selfObj = self
    parentPage = _parentPage
    local container = ScriptContentBase:create(pageOption.ccbiFile)
    
    container:registerFunctionHandler(function(eventName, container)
        local funcName = pageOption.handlerMap[eventName]
        local func = selfObj[funcName]
        if func then
            func(selfObj, container)
        end
    end)
    
    return container
end

function TowerBase:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

function TowerBase:onEffect(container)
    local skillId = TowerDataBase:getFearCfg(nil,nowType)[1].BuffId
    if skillId and skillId > 0 then
        GameUtil:showSkillTip(container:getVarNode("mEffectSprite"), skillId)
    end
end

function TowerBase:onBack(container)
    local Floor = tonumber(string.sub(PageInfo.MaxFloor,2,4)) or 0
    self:scrollToLevel(container.MainScroll, Floor, PageInfo.totalLevels, nil)
end

function TowerBase:onAchive(container)
    if ActivityInfo:getActivityIsOpenById(199) and needNewTowerData then
        local Activity6_pb = require("Activity6_pb")
        local msg = Activity6_pb.FearLessTowerReq()
        msg.action = 4 
        msg.towerId = 0
        common:sendPacket(HP_pb.ACTIVITY199_FEAR_LESS_TOWER_C, msg, true)
    end
end
function TowerBase:onHelp(container)
    PageManager.showHelp(GameConfig.HelpKey.HELP_CLIMB_TOWER)
end

function TowerBase:onReward(container)
    local parentNode = container:getVarNode("mPopUpNode")
    if parentNode then 
        parentNode:removeAllChildren()
        RewardPopCCB = ScriptContentBase:create("Tower_Popup")
        parentNode:addChild(RewardPopCCB)
        RewardPopCCB:registerFunctionHandler(RewardPopFunction)
        RewardPopCCB:setAnchorPoint(ccp(0.5, 0.5))
        TowerBase:setRewardPopCCB(RewardPopCCB)
    end
end

function TowerBase:setRewardPopCCB(container)
    local scrollview = container:getVarScrollView("mContent")
    if not scrollview then
        print("Error: container 沒有 mContent scroll view")
        return
    end
    local cfg = TowerDataBase:getFearCfg(nil,nowType)
    for k, value in pairs(cfg) do
        local cell = CCBFileCell:create()
        cell:setCCBFile(RewardContent.ccbiFile)
        local panel = common:new({ data = value }, RewardContent)
        cell:registerFunctionHandler(panel)
        scrollview:addCell(cell)
    end
    NodeHelper:setStringForLabel(container, { mTitle = common:getLanguageString("@SeasonTowerReward") })
    scrollview:orderCCBFileCells()
    scrollview:setTouchEnabled(true)
    if PageInfo.MaxFloor > 1 then
        local options = { height = 146, durationPerLevel = 0 }
        local floor = math.max(PageInfo.MaxFloor - 1, 1)
        TowerBase:scrollToLevel(scrollview, floor, PageInfo.totalLevels, nil, options)
    end
end
function TowerBase:setTaskPopCCB(container)
    local scrollview = container:getVarScrollView("mContent")   
    NodeHelper:buildCellScrollView(scrollview, #_curShowTaskInfo, "TaskContent.ccbi",TaskContent)
    NodeHelper:setStringForLabel(container, { mTitle = common:getLanguageString("@TaskTitle") })
end

function TowerBase:onEnter(container)
    parentPage:registerPacket(opcodes)
    parentPage:registerMessage(MSG_MAINFRAME_REFRESH)
    mainContainer = container
    
    require("TransScenePopUp")
    TransScenePopUp_closePage()
    
    local PageJumpMange = require("PageJumpMange")
    PageJumpMange._IsPageJump = false
    
    selfContainer = container
    container:getVarNode("mBg"):setScale(NodeHelper:getScaleProportion())
    container.MainScroll = container:getVarScrollView("mContent")
    container.SubScroll = container:getVarScrollView("mSubContent")
    NodeHelper:autoAdjustResizeScrollview(container.MainScroll)
    
    PageInfo = TowerDataBase:getData(199,nowType)

   self:refresh()
   
    --NodeHelper:setNodesVisible(container,{mBuffNode = false,mTimeNode = false})
    --local bgName = string.format("BG/Tower/Tower_bg%02d.png", nowType)
    --NodeHelper:setSpriteImage(container, { mBg = bgName })

   -- NodeHelper:setStringForLabel(container,{mTowerTitle = common:getLanguageString(TowerTitle[nowType])})
    --self:setPage(container)
end

function TowerBase:getCurrentDateString()
    local dateTable = os.date("*t")
    local year  = dateTable.year
    local month = string.format("%02d", dateTable.month)
    local day   = string.format("%02d", dateTable.day)
    return year .. "_" .. month .. "_" .. day
end

function TowerBase:setReward(container)
    -- 如有獎勵邏輯，可在此處補充
   local cfg = TowerDataBase:getFearCfg(nil,nowType)
end
function TowerBase:buildScrolls(container)
    TowerBase:buildSubScroll(container)
    TowerBase:buildMainScroll(container)
end
function TowerBase:buildSubScroll(container)
    local scrollView = container.SubScroll
    scrollView:removeAllCell()
    local cfg = ConfigManager.getFearTowerMainCfg()
    for _,v in ipairs (cfg) do
        local cell = CCBFileCell:create()
        cell:setCCBFile(StageContent.ccbiFile)
        local panel = common:new({ data = v }, StageContent)
        cell:registerFunctionHandler(panel)
        scrollView:addCell(cell)
    end
    scrollView:orderCCBFileCells()
end
function TowerBase:buildMainScroll(container)
    local scrollView = container.MainScroll
    scrollView:removeAllCell()
    local cfg = TowerDataBase:getFearCfg(nil,nowType)
    PageInfo.totalLevels = #cfg
    PageInfo.Items = {}
    
    for i = #cfg, 1, -1 do
        local cell = CCBFileCell:create()
        cell:setCCBFile(TowerContent.ccbiFile)
        local cellHeight = 0
        if i == 1 then
           cellHeight = 400
        elseif i == #cfg then
           cellHeight = 550
        else
           cellHeight = TOWER_CELL_HEIGHT
        end
        cell:setContentSize(CCSizeMake(720,cellHeight))
        local panel = common:new({ data = cfg[i],index = i, height = cellHeight }, TowerContent)
        cell:registerFunctionHandler(panel)
        scrollView:addCell(cell)
    end
    
    scrollView:setTouchEnabled(true)
    scrollView:orderCCBFileCells()
    
    if PageInfo.isFirstEnter then
        scrollView:setContentOffset(ccp(0, 0))
        local actionArray = CCArray:create()
        actionArray:addObject(CCDelayTime:create(0.1))
        actionArray:addObject(CCCallFunc:create(function()
            self:initScrollToCurrentLevel(scrollView)
        end))
        container:runAction(CCSequence:create(actionArray))
    else
        local options = { durationPerLevel = 0 }
        self:initScrollToCurrentLevel(scrollView)
    end
end

function TowerBase:onReceivePacket(packet)
    local opcode = packet.opcode
    local msgBuff = packet.msgBuff
    if opcode == HP_pb.ACTIVITY199_FEAR_LESS_TOWER_S then
        local msg = Activity6_pb.FearLessTowerResp()
        msg:ParseFromString(msgBuff)
        if msg.action == 4 then
           _curShowTaskInfo= {}
           local cfg = ConfigManager.getFearTowerAchivCfg()
           for i = 1 ,#cfg do
                _curShowTaskInfo[i] = cfg[i]
                _curShowTaskInfo[i].questState = Const_pb.ING
                _curShowTaskInfo[i].finishedCount = 0
           end
           for _ , data in pairs (msg.achievementInfo) do
             local id = data.achiType
             if id then
                _curShowTaskInfo[id].finishedCount = counter
                if _curShowTaskInfo[id].finishedCount ==  _curShowTaskInfo[id].targetCount then
                   curShowTaskInfo[id].questState = Const_pb.FINISHED
                end
             end
           end
           for _ , id in pairs (msg.achiTakeId) do
             if type(id) == "number" then
             curShowTaskInfo[id].questState = Const_pb.REWARD
             end
           end
           local parentNode = mainContainer:getVarNode("mPopUpNode")
           if parentNode then 
               parentNode:removeAllChildren()
               TaskPopUpCCB = ScriptContentBase:create("Tower_Popup")
               parentNode:addChild(TaskPopUpCCB)
               TaskPopUpCCB:registerFunctionHandler(TaskPopFunction)
               TaskPopUpCCB:setAnchorPoint(ccp(0.5, 0.5))
               TowerBase:setTaskPopCCB(TaskPopUpCCB)
           end
        end
    elseif opcode == HP_pb.BATTLE_FORMATION_S then
        local msg = Battle_pb.NewBattleFormation()
        msg:ParseFromString(msgBuff)
        if msg.type == NewBattleConst.FORMATION_PROTO_TYPE.REQUEST_ENEMY then
            local battlePage = require("NgBattlePage")
            resetMenu("mBattlePageBtn", true)
            require("NgBattleDataManager")
            NgBattleDataManager_setDungeonId(tonumber(msg.mapId))
            PageManager.changePage("NgBattlePage")
            battlePage:onFearTower(selfContainer, msg.resultInfo, msg.battleId, msg.battleType, tonumber(msg.mapId))
        end
    end
end

function TowerBase:onClose(container)
    parentPage:removePacket(opcodes)
    if countdownScheduler then
        CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(countdownScheduler)
        countdownScheduler = nil
    end
end

function TowerBase:onExecute(container)
    -- 如有額外執行邏輯，在此處補充
end

-- 滾動到指定層級
function TowerBase:scrollToLevel(scrollView, level, totalLevels, callback, options)
    options = options or {}
    level = math.max(1,level)
    local cellHeight = options.height or TOWER_CELL_HEIGHT 
    if options.height then
        level = totalLevels - level - 2
    end

    if level < 1 or level > totalLevels then
        print(string.format("無效的層級：%d（範圍：1-%d）", level, totalLevels))
        return
    end
    local viewHeight    = scrollView:getViewSize().height
    local contentHeight = totalLevels * cellHeight + 48
    local centerOffset  = options.centerOffset or 0
    local targetY       = ( level + 0.5 ) * cellHeight + 48 - (viewHeight / 2) + centerOffset
    targetY = math.max(0, math.min(contentHeight - viewHeight, targetY))
    if level == 1 then targetY = 0 end
    local currentOffset = math.abs(scrollView:getContentOffset().y)
    local currentLevel  = math.floor(currentOffset / cellHeight) + 1
    local levelDiff     = math.abs(level - currentLevel)
    local duration      = math.min(levelDiff * (options.durationPerLevel or 0.1), 2)
    
    print(string.format("滾動到層級：%d，當前層級：%d，層級差距：%d，目標偏移：%.2f，持續時間：%.2f",
          level, currentLevel, levelDiff, targetY, duration))
    
    if duration > 0 then
        scrollView:setContentOffsetInDuration(ccp(0, -targetY), duration)
    else
        scrollView:setContentOffset(ccp(0, -targetY))
    end
    
    local actionArray = CCArray:create()
    actionArray:addObject(CCCallFunc:create(function()
        isTowerMoving = true
        scrollView:setTouchEnabled(false)
    end))
    actionArray:addObject(CCDelayTime:create(duration))
    actionArray:addObject(CCCallFunc:create(function()
        isTowerMoving = false
        scrollView:setTouchEnabled(true)
        if callback and type(callback) == "function" then
            callback()
        end
    end))
    scrollView:runAction(CCSequence:create(actionArray))
end

-- 初始化滾動邏輯
function TowerBase:initScrollToCurrentLevel(scrollView)
    local Floor = tonumber(string.sub(PageInfo.MaxFloor,2,4)) or 0
    if PageInfo.isFirstEnter then
        local key = "OneLifeTOWER" ..nowType.."_".. UserInfo.playerInfo.playerId
        CCUserDefault:sharedUserDefault():setStringForKey(key, self:getCurrentDateString())      
        self:scrollToLevel(scrollView, Floor, PageInfo.totalLevels)
    elseif PageInfo.isPassLevel then
        local options = { durationPerLevel = 0 }
        local actionArray = CCArray:create()
        actionArray:addObject(CCCallFunc:create(function()
            self:scrollToLevel(scrollView, Floor - 1, PageInfo.totalLevels, nil, options)
        end))
        actionArray:addObject(CCDelayTime:create(0.5))
        actionArray:addObject(CCCallFunc:create(function()
            options.durationPerLevel = 0.2
            self:scrollToLevel(scrollView, Floor, PageInfo.totalLevels, nil, options)
            local passKey = "OneLifeTOWERPASS_" ..nowType.."_".. UserInfo.playerInfo.playerId
            CCUserDefault:sharedUserDefault():setIntegerForKey(passKey, PageInfo.MaxFloor)
        end))
        selfContainer:runAction(CCSequence:create(actionArray))
    else
        local options = { durationPerLevel = 0 }
        self:scrollToLevel(scrollView, Floor, PageInfo.totalLevels, nil, options)
    end
end

function TowerBase:refresh()
    local towerEnterKey = "OneLifeTOWER" ..nowType.."_".. UserInfo.playerInfo.playerId
    local TowerEnter = CCUserDefault:sharedUserDefault():getStringForKey(towerEnterKey) or ""
    PageInfo.isFirstEnter = (TowerEnter ~= self:getCurrentDateString())
    
    local towerPassKey = "OneLifeTOWERPASS_" ..nowType.."_".. UserInfo.playerInfo.playerId
    local TowerPass = CCUserDefault:sharedUserDefault():getIntegerForKey(towerPassKey) or 0
    PageInfo.isPassLevel = (TowerPass ~= PageInfo.MaxFloor)
    PageInfo = TowerDataBase:getData(199,nowType)
    self:buildScrolls(mainContainer)
    
    local RankData = TowerDataBase:getRank(199,nowType)
    local RankItems = RankData and RankData.otherItem or {}
    local isVisible = #RankData.otherItem ~= 0
    NodeHelper:setNodesVisible(mainContainer, {mRank = isVisible})

    if isVisible then
        local stringTable = {}
        local ImgTable = {}
        local visibleTable = {}
        for i = 1,4 do
            visibleTable["mRankNode"..i] = false
        end
        for _,data in pairs(RankItems) do
            local idx = math.max(data.rank,1)
            local floor = tonumber(string.sub(data.MaxFloor,2,4))
            local name = data.name
            local head = data.head
            visibleTable["mRankNode"..idx] = true
            ImgTable["mHead"..idx] = common:getPlayeIcon(nil, head)
            stringTable["mRank"..idx] = common:getLanguageString("@FearlessTower_LayerNumber",floor)
            stringTable["mName"..idx] = name
        end
        NodeHelper:setNodesVisible(mainContainer,visibleTable)
        NodeHelper:setSpriteImage(mainContainer,ImgTable)
        NodeHelper:setStringForLabel(mainContainer,stringTable)
    end

    NodeHelper:setStringForLabel(mainContainer,{mCount = PageInfo.nowMorale.." / "..PageInfo.maxMorale})
    NodeHelper:setScale9SpriteBar(mainContainer,"mBar",PageInfo.nowMorale,PageInfo.maxMorale,560)
end

function TowerBase:passLevel(scrollView)
    if PageInfo.MaxFloor < PageInfo.totalLevels then
        -- 播放當前層通關動畫（如有需要）
        self:scrollToLevel(scrollView, PageInfo.MaxFloor, PageInfo.totalLevels, function()
            -- 此處可加入解鎖下一層動畫
        end)
    else
        print("All levels cleared!")
    end
end

function TowerBase:isLevelVisible(scrollView, level, totalLevels)
    -- 保證層級不小於 1
    level = math.max(1, level)
    -- 超出總層數，視為無效
    if level > totalLevels then
        print("無效的層級：", level)
        return false
    end

    -- 取得可視區高度及當前位移
    local viewHeight    = scrollView:getViewSize().height
    local offsetY       = math.abs(scrollView:getContentOffset().y)
    local visibleStartY = offsetY
    local visibleEndY   = offsetY + viewHeight

    -- 計算該層級的 Y 範圍
    local levelHeight   = TOWER_CELL_HEIGHT
    local levelStartY   = (level - 1) * levelHeight
    local levelEndY     = levelStartY + levelHeight

    -- 若有任何重疊，則該層級至少部分可見
    if levelStartY < visibleEndY and levelEndY > visibleStartY then
        return true
    else
        return false
    end
end

----------------------------------------------
-- StageContent 相關方法
----------------------------------------------
function StageContent:onRefreshContent(content)
    local container = content:getCCBFileNode()
    local data = self.data
    local id = data.id
    local stageCount = #TowerDataBase:getFearCfg(nil,id)
    local MaxFloor = id*1000 + TowerDataBase:getData(199,id).MaxFloor
    MaxFloor = tonumber(string.sub(MaxFloor,2,4))
    StageClear[0] = true
    StageClear[id] = stageCount <= MaxFloor
    self.isLock = not StageClear[id -1]
    NodeHelper:setStringForLabel(container,{mStageName = common:getLanguageString(data.Title)})
    NodeHelper:setNodesVisible(container,{mChoose = id == nowType,mLock = self.isLock })
    StageContainers[id] = container
end

function StageContent:onBtn(container)
    if isTowerMoving or SwitchTowerCD then return end

    if self.data.id == nowType or self.isLock then
        return 
    end
    
    nowType = self.data.id

    for id,content in pairs (StageContainers) do
        NodeHelper:setNodesVisible(content,{mChoose = id == nowType})
    end

    PageInfo = TowerDataBase:getData(199,nowType)
    TowerBase:refresh()    
end


----------------------------------------------
-- TowerContent 相關方法
----------------------------------------------
function TowerContent:onRefreshContent(content)
    local container = content:getCCBFileNode()
    local data = self.data
    local Floor = tonumber(string.sub(data.id,2,4))
    local isFirst = (self.index == 1)
    local isLast = (self.index == PageInfo.totalLevels)
    
    NodeHelper:setNodesVisible(container, {
        mBase = isFirst,
        mTop = isLast
    })
    
    local posY
    if isFirst then
        posY = self.height
    else
        posY = TOWER_CELL_HEIGHT
    end
    
    container:getVarNode("mNode"):setPositionY(posY)

    
    PageInfo.Items[Floor] = container
    NodeHelper:setStringForLabel(container, { mStage = Floor })
    NodeHelper:setScale9SpriteImage2(container, { mBg = data.stageBg, mBg2 = data.stageBg })
    
    if self.data.id <= PageInfo.MaxFloor then
        NodeHelper:setNodesVisible(container, { PassImg = true, mNowStage = false })
        local parentNode = container:getVarNode("mSpine")
        if parentNode then
            parentNode:removeAllChildren()
        end
    elseif self.data.id == PageInfo.MaxFloor + 1 or PageInfo.MaxFloor == 0 and self.data.id == 1001 then 
        NodeHelper:setNodesVisible(container, { PassImg = false, mNowStage = true })
        self:addSpine(container, data.spine)
    else
        NodeHelper:setNodesVisible(container, { PassImg = false, mNowStage = false })
        self:addSpine(container, data.spine)
    end
    NodeHelper:setNodesVisible(container,{mShop = data.Type == 1 })
    local Floor = tonumber(string.sub(PageInfo.MaxFloor,2,4)) or 0
    local status = TowerBase:isLevelVisible(selfContainer.MainScroll, Floor, PageInfo.totalLevels)
    NodeHelper:setNodesVisible(selfContainer, {  mBack = not status })
end

function TowerContent:onFight(container)
    if isTowerMoving then return end
    if self.data.id - 1 > math.max(PageInfo.MaxFloor,1001) then
        MessageBoxPage:Msg_Box(common:getLanguageString("@activitystagetNotice02"))
        return 
    elseif self.data.id <= PageInfo.MaxFloor then
        return
    end
    container:runAnimation("onFight")
    if self.data.Type == 0 then
        local msg = Battle_pb.NewBattleFormation()
        msg.type = NewBattleConst.FORMATION_PROTO_TYPE.REQUEST_ENEMY
        msg.battleType = NewBattleConst.SCENE_TYPE.FEAR_TOWER
        msg.mapId = tostring(nowType)
        common:sendPacket(HP_pb.BATTLE_FORMATION_C, msg, true)
    else
        local parentNode = mainContainer:getVarNode("mPopUpNode")
        if parentNode then 
            parentNode:removeAllChildren()
            TaskPopUpCCB = ScriptContentBase:create("Tower_Popup")
            parentNode:addChild(TaskPopUpCCB)
            TaskPopUpCCB:registerFunctionHandler(TaskPopFunction)
            TaskPopUpCCB:setAnchorPoint(ccp(0.5, 0.5))
            TowerBase:setTaskPopCCB(TaskPopUpCCB)
        end
    end
end

local function removeOldSpineFrom(node)
    if not node then return end
    local children = node:getChildren()
    if children then
        for i = 0, children:count() - 1 do
            local child = tolua.cast(children:objectAtIndex(i), "CCNode")
            if child and child.stopAllActions then
                child:stopAllActions()
            end
            -- 如果有自訂釋放函式，可呼叫
            if child and child.dispose then
                child:dispose()
            end
        end
    end
    node:removeAllChildrenWithCleanup(true)
end


function TowerContent:addSpine(container, spine)
    if spine == "" then
        return
    end
    local spinePath, spineName = unpack(common:split(spine, ","))
    local spineObj = SpineContainer:create(spinePath, spineName)
    spineObj:runAnimation(1, CONST.ANI_ACT.WAIT, -1)
    local parentNode = container:getVarNode("mSpine")
    if parentNode then
        removeOldSpineFrom(parentNode)
        parentNode:addChild(tolua.cast(spineObj, "CCNode"))
    end
end

----------------------------------------------
-- RewardContent 相關方法
----------------------------------------------
function RewardContent:onRefreshContent(content)
    local container = content:getCCBFileNode()
    local titleStr = common:getLanguageString("@SeasonTowerXstage", self.data.id)
    NodeHelper:setStringForLabel(container, { mTitleTxt = titleStr })
    local items = self.data.reward
    if (self.data.id <= PageInfo.MaxFloor ) then
        NodeHelper:setNodesVisible(container, { mPassed = true })
    else
        NodeHelper:setNodesVisible(container, { mPassed = false })
    end
    for i = 1, 4 do
        local parentNode = container:getVarNode("mPosition" .. i)
        parentNode:removeAllChildren()
        if items[i] then
            local itemNode = ScriptContentBase:create("CommItem")
            itemNode:setScale(0.8)
            itemNode.Reward = items[i]
            itemNode:registerFunctionHandler(function(eventName,container) 
                                                if eventName=="onHand1" then
                                                   GameUtil:showTip(container:getVarNode('mPic1'), container.Reward)
                                                end
                                             end)
            NodeHelper:setNodesVisible(itemNode, { selectedNode = false, mStarNode = false, nameBelowNode = false, mPoint = false })
            local resInfo = ResManagerForLua:getResInfoByTypeAndId(items[i].type, items[i].itemId, items[i].count)
            local normalImage = NodeHelper:getImageByQuality(resInfo.quality)
            local iconBg      = NodeHelper:getImageBgByQuality(resInfo.quality)
            NodeHelper:setMenuItemImage(itemNode, { mHand1 = { normal = normalImage } })
            NodeHelper:setSpriteImage(itemNode, { mPic1 = resInfo.icon, mFrameShade1 = iconBg })
            NodeHelper:setStringForLabel(itemNode, { mNumber1_1 = items[i].count })
            parentNode:addChild(itemNode)
        end
    end
end
----------------------------------------------
-- TaskContent 相關方法
----------------------------------------------
function TaskContent:onDetial(container)
    local index = self.id
    local ItemInfo = _curShowTaskInfo[index].reward[1]
    GameUtil:showTip(container:getVarNode("mDetial"), ItemInfo)
end

function TaskContent:onRefreshContent(content)
    local container   = content:getCCBFileNode()
    local packetInfo  = _curShowTaskInfo[self.id]
    local cfgInfo     = ConfigManager.getFearTowerAchivCfg()[packetInfo.id]

    -- 狀態對應表
    local stateMap = {
        [Const_pb.ING]      = { key="@inProgress",                enabled=false, showPoint=false },
        [Const_pb.FINISHED] = { key="@ActDailyMissionBtn_Receive", enabled=true,  showPoint=true  },
        [Const_pb.REWARD]   = { key="@Receive",                   enabled=false, showPoint=false },
    }
    local st = stateMap[packetInfo.questState] or stateMap[Const_pb.ING]
    local statusText = common:getLanguageString(st.key)

    -- 按鈕與紅點
    NodeHelper:setMenuItemEnabled(container, "mConfirmationBtn", st.enabled)
    NodeHelper:setNodesVisible(container, { mPoint = st.showPoint })

    -- 計算完成數與進度條比例
    local targetCount = cfgInfo.targetCount
    local finishCount = (packetInfo.questState == Const_pb.FINISHED)
                        and targetCount
                        or packetInfo.finishedCount
    local percent = math.min(1, math.max(0.14, finishCount / targetCount))
    local hasProgress = (finishCount > 0)

    -- 顯示與調整進度條
    NodeHelper:setNodesVisible(container, { mTaskBar = hasProgress })
    if hasProgress then
        local bar = container:getVarScale9Sprite("mTaskBar")
        bar:setContentSize(CCSize(BAR_WIDTH * percent, BAR_HEIGHT))
    end

    -- 獎勵圖示設定
    local reward = cfgInfo.reward[1]
    local resInfo = ResManagerForLua:getResInfoByTypeAndId(reward.type, reward.itemId)
    NodeHelper:setSpriteImage(container, {
        mQualityItem = NodeHelper:getImageByQuality(resInfo.quality),
        mIconBg      = NodeHelper:getImageBgByQuality(resInfo.quality),
        mSkillPic    = resInfo.icon,
    })

    -- 任務描述（HTML 標籤）
    local descNode = container:getVarLabelTTF("mSkillTex")
    descNode:removeAllChildren()
    local html = string.format(
        '<p style="margin:10px;"><font color="#737466">%s</font></p>',
        common:getLanguageString(cfgInfo.name, targetCount)
    )
    local label = CCHTMLLabel:createWithString(html, CCSizeMake(400, 30), "Barlow-Bold")
    label:setScale(0.8)
    label:setAnchorPoint(ccp(0, 1))
    label:setPosition(ccp(0, 10))
    descNode:addChild(label)

    -- 文字標籤設定
    NodeHelper:setStringForLabel(container, {
        mTaskTimes    = GameUtil:formatNumber(finishCount) .. "/" .. GameUtil:formatNumber(targetCount),
        mConfirmation = common:getLanguageString(statusText),
        mRewardNum    = "",
        mSkillTex     = "",
        mTaskReward   = reward.count,
    })

    -- 隱藏不必要節點
    NodeHelper:setNodesVisible(container, { mLivenessNode = false })
end
----------------------------------------------
-- 返回新子頁面
----------------------------------------------
local CommonPage = require('CommonPage')
return CommonPage.newSub(TowerBase, "TowerSubPage_MainScene", pageOption)
