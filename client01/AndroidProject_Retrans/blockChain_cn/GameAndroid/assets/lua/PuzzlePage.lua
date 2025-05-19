--------------------------------------------------------------------------------
-- PuzzlePage 模組 (重構優化後)
--------------------------------------------------------------------------------

-- 載入所需模組與常數
local HP_pb             = require("HP_pb")
local Activity6_pb      = require("Activity6_pb")
local CommonPage        = require("CommonPage")
local NodeHelper        = require("NodeHelper")
local CommItem          = require("CommUnit.CommItem")
local InfoAccesser      = require("Util.InfoAccesser")
local CONST             = require("Battle.NewBattleConst")
local Battle_pb         = require("Battle_pb")
local NewBattleConst    = require("Battle.NewBattleConst")
local MainScenePageInfo = require("MainScenePage")
local PAGE_NAME = "PuzzlePage"

-- 定義封包 opcode
local opcodes = {
    ACTIVITY195_PUZZLE_BATTLE_S = HP_pb.ACTIVITY195_PUZZLE_BATTLE_S,
    BATTLE_FORMATION_S          = HP_pb.BATTLE_FORMATION_S,
    PLAYER_AWARD_S              = HP_pb.PLAYER_AWARD_S
}

-- 頁面選項設定
local pageOptions = {
    ccbiFile   = "Puzzle.ccbi",
    handlerMap = {
        onReturnBtn = "onExit",
        onReward    = "onReward",
        onHelp      = "onHelp"
    },
    opcode = opcodes,
}

--------------------------------------------------------------------------------
-- 常數與圖片、Spine 配置
--------------------------------------------------------------------------------
local IMAGE_STAGE = {
    [0] = "BG/Puzzle/Puzzle_Stage1.png",  -- 鎖定 / 未解鎖 (stageId > completeStage)
    [1] = "BG/Puzzle/Puzzle_Stage1.png",  -- 可挑戰預設 (stageId == completeStage)
    [2] = "BG/Puzzle/Puzzle_Stage2.png",  -- 已通關預設 (stageId < completeStage)
    [3] = "BG/Puzzle/Puzzle_Stage3.png",  -- 可挑戰選中 (stageId == completeStage 且選中)
    [4] = "BG/Puzzle/Puzzle_Stage4.png"   -- 已通關選中 (stageId < completeStage 且選中)
}

local SPINE_CONFIG = {
    PATH        = "Spine/NGUI",
    NINE_GRID_A = "NGUI_96_NineGrid_A",  -- StageCell Spine
    NINE_GRID_B = "NGUI_96_NineGrid_B",  -- 邊框 Spine
    NINE_GRID_C = "NGUI_96_NineGrid_C",  -- 卡牌 Spine
}

local STAGE_CELL_WIDTH = 122

--------------------------------------------------------------------------------
-- PuzzleController 控制器定義 (內部狀態與方法)
--------------------------------------------------------------------------------
local PuzzleController = {
    currentStage         = 0,         -- 當前關卡編號
    completeStage        = {},         -- 完成的關卡
    completedLevelIds    = {},        -- 已完成關卡ID列表
    paidEntries          = 0,         -- 已付費挑戰次數
    freeEntries          = 0,         -- 免費挑戰次數
    remainingTime        = 0,         -- 剩餘時間（秒）
    currentStageCardIds  = {},        -- 當前關卡卡牌ID列表
    selectedStageCardId  = 0,         -- 當前選取的卡牌ID
    countdownTimerId     = nil,       -- 倒數計時器ID
    container            = nil,       -- 畫面容器
    rewardScrollView     = nil,       -- 獎勵捲動視窗
    heroSelectionStatus  = {},        -- 英雄上陣狀態 (key = hero id, value = 是否可上陣)
    HeroTable            = {},        -- 英雄資料表
    isPass               = false,     -- 通關標記
    showReward           = {},
    isPassStage          = false,
    isCoolDown           = false,
    preStageCell         = {},
    openedGroup          = {},
    firstId              = 0,
    openedStageCount     = 0,
    isConfirmPop         = false
}
local isFirst = true

-- 取得 Puzzle 配置檔 (主關卡與子關卡)
local mainPuzzleConfig    = ConfigManager.getMainPuzzleCfg()
local subPuzzleConfig     = ConfigManager.getSubPuzzleCfg()

-- 獎勵及所有獎勵的 UI 內容配置
local rewardCellContent   = { ccbiFile = "GoodsItem_2.ccbi" }
local AllRewardContent    = { ccbiFile = "Puzzle_RewardContent.ccbi" }

-- 本模組內彈出節點暫存 (關卡資訊、全部獎勵)
local allRewardNode, stageInfoNode = nil, nil

--------------------------------------------------------------------------------
-- 本地輔助函數
--------------------------------------------------------------------------------

-- 清空節點的所有子節點
local function clearNode(node)
    if node then node:removeAllChildren() end
end

--- 註冊卡牌按鈕事件 (依照前綴與數量)
local function registerCardButtonEvents(prefix, count)
    for i = 1, count do
        pageOptions.handlerMap[prefix .. i] = "onCardSelected"
    end
end

--- 重置 PuzzleController 狀態資料
local function resetControllerData()
    PuzzleController.currentStage        = 0
    PuzzleController.completedLevelIds   = {}
    PuzzleController.paidEntries         = 0
    PuzzleController.freeEntries         = 0
    PuzzleController.remainingTime       = 0
    PuzzleController.currentStageCardIds = {}
    PuzzleController.selectedStageCardId = 0
    if PuzzleController.countdownTimerId then
        CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(PuzzleController.countdownTimerId)
        PuzzleController.countdownTimerId = nil
    end
    PuzzleController.openedGroup          = {}
end

local function isStageFinish(_stageId)
        for _,value in pairs(PuzzleController.completeStage) do
            if value == _stageId then 
                return true
            end
        end
        return false
    end

--- 更新關卡圖示 (統一圖片更新邏輯)
-- @param container 關卡項目容器
-- @param stageId 當前關卡編號
-- @param completeStage 完成關卡編號
-- @param isSelect 是否為選中狀態
-- @param defaultImage 預設圖片
-- @param selectedImage 選中後圖片 (可為 nil)
local function updateStageIcon(container, stageId, completeStage, isSelect, defaultImage, selectedImage)
    NodeHelper:setSpriteImage(container, { mStageIcon = defaultImage })
    if isSelect and selectedImage then
        NodeHelper:setSpriteImage(container, { mStageIcon = selectedImage })
        PuzzleController.preStageCell = { container = container, id = stageId }
    end
end

local function removeDuplicates(t)
    local seen = {}
    local result = {}
    for _, value in ipairs(t) do
        if not seen[value] then
            seen[value] = true
            table.insert(result, value)
        end
    end
    return result
end

local function mergeTables(target, source)
    for _, v in ipairs(source) do
        table.insert(target, tonumber(v))
    end
    table.sort(target)  -- 數字排序可直接使用 table.sort
    return removeDuplicates(target)
end
--- 將 handleStageInfoEvent 局部化，避免全局污染
local function handleStageInfoEvent(eventName, container)
    local popUp = PuzzleController.container:getVarNode("PopUpNode")
    if eventName == "onClose" or eventName == "onConfirm" then
        popUp:removeAllChildren()
    elseif eventName == "onFight" then
        -- 確認所有限制英雄均已上陣
        for _, hasHero in pairs(PuzzleController.heroSelectionStatus) do
            if not hasHero then
                MessageBoxPage:Msg_Box(common:getLanguageString("@PuzzleBattle_MissingNG"))
                return
            end
        end
        popUp:removeAllChildren()
        local function sendBattleFormation()
            if PuzzleController.selectedStageCardId == 0 then return end
            local msg = Battle_pb.NewBattleFormation()
            msg.type = NewBattleConst.FORMATION_PROTO_TYPE.REQUEST_ENEMY
            msg.battleType = NewBattleConst.SCENE_TYPE.PUZZLE
            msg.mapId = tostring(PuzzleController.selectedStageCardId)
            msg.Id = PuzzleController.currentStage
            common:sendPacket(HP_pb.BATTLE_FORMATION_C, msg, true)
            PuzzleController.isPass = false
        end

        if PuzzleController.freeEntries == 0 and PuzzleController.paidEntries > 0 then
            local title = common:getLanguageString("@ERRORCODE_11007")
            local msg = common:getLanguageString("@PuzzleBattle_NoFreeCount")
            PageManager.showConfirm(title, msg, function(isSure)
                if isSure then sendBattleFormation() end
            end)
            return
        elseif PuzzleController.paidEntries == 0 then
            MessageBoxPage:Msg_Box(common:getLanguageString("@PuzzleBattle_EnterFail"))
            return
        end
        sendBattleFormation()
    elseif eventName == "onUse" then
        PuzzleController:sendSkipStage()
    end
end

--- 根據配置數據設定節點顯示與子節點 (通用版)
local function configureNodesVisibility(container, basePrefix, data, oddLimit, evenLimit, addNodes)
    local count = type(data) == "table" and #data or data

    if basePrefix == "mLimit_" then
        if count == 0 then
            NodeHelper:setNodesVisible(container, { mNoLimit = true, mLimit_4 = false, mLimit_5 = false })
            return
        else 
            NodeHelper:setNodesVisible(container, { mNoLimit = false })
        end
    end

    local limit     = (count % 2 == 1) and oddLimit or evenLimit
    local mainGroup = (count % 2 == 1) and "5" or "4"
    local otherGroup= (count % 2 == 1) and "4" or "5"
    local visibilityMap = { [basePrefix .. mainGroup] = true, [basePrefix .. otherGroup] = false }

    if count > limit then
        print("OverLimit！")
        return
    end

    for i = 1, limit do
        visibilityMap[basePrefix .. mainGroup .. "_" .. i] = false
    end
    local startPos  = math.floor((limit - count) / 2) + 1
    local finishPos = startPos + count - 1
    for pos = startPos, finishPos do
        visibilityMap[basePrefix .. mainGroup .. "_" .. pos] = true
        if addNodes then
            local heroNode   = ScriptContentBase:create("Puzzle_iconContentccb")
            local parentNode = container:getVarNode(basePrefix .. mainGroup .. "_" .. pos)
            parentNode:addChild(heroNode)
            if type(data) == "table" then
                local info = data[pos - startPos + 1]
                if info then
                    if info.id then
                        local portrait = "UI/Role/Portrait_" .. string.format("%02d", info.id) .. "000.png"
                        NodeHelper:setSpriteImage(heroNode, { mSprite = portrait }, { mSprite = 0.9 })
                        local heroFound = false
                        for _, heroData in pairs(PuzzleController.HeroTable) do
                            if heroData.itemId == info.id then
                                NodeHelper:setNodeIsGray(heroNode, { mSprite = false })
                                PuzzleController.heroSelectionStatus[info.id] = true
                                heroFound = true
                                break
                            end
                        end
                        if not heroFound then
                            NodeHelper:setNodeIsGray(heroNode, { mSprite = true })
                            PuzzleController.heroSelectionStatus[info.id] = false
                        end
                        NodeHelper:setStringForLabel(heroNode, { mPos = info.pos })
                        NodeHelper:setNodesVisible(heroNode, { mHeroNode = true, mPosNode = (info.pos ~= 0) })
                        heroNode:registerFunctionHandler(function(eventName, container)
                            if eventName == "onHead" and not PuzzleController.heroSelectionStatus[info.id] then
                                MessageBoxPage:Msg_Box(
                                    common:getLanguageString("@PuzzleBattle_MissingNG") .. " : " ..
                                    common:getLanguageString("@HeroName_" .. info.id)
                                )
                            end
                        end)
                    elseif info.element then
                        NodeHelper:setNodesVisible(heroNode, { mHeroNode = false })
                        local elementImg = "Attributes_elemet_" .. string.format("%02d", info.element) .. ".png"
                        NodeHelper:setSpriteImage(heroNode, { mSprite = elementImg }, { mSprite = 1.44 })
                    end
                end
            end
        end
    end

    NodeHelper:setNodesVisible(container, visibilityMap)
end

--- 依據關卡限制配置添加英雄節點 (帶圖示)
local function configureLimitDisplay(container, limitData)
    configureNodesVisibility(container, "mLimit_", limitData, 5, 4, true)
end

--- 配置女英雄上陣限制 (僅顯示，不新增子節點)
local function configureHeroLimitDisplay(container, heroCount)
    configureNodesVisibility(container, "mGirlLimit_", heroCount, 5, 4, false)
end

--- 根據物品列表生成獎勵節點 (固定 4 個位置)
local function populateItemNodes(container, items)
    for i = 1, 4 do
        local parentNode = container:getVarNode("mPosition" .. i)
        clearNode(parentNode)
        if items[i] then
            local itemNode = ScriptContentBase:create("CommItem")
            itemNode:setScale(0.8)
            itemNode.Reward = items[i]
            NodeHelper:setNodesVisible(itemNode, { selectedNode = false, mStarNode = false, nameBelowNode = false, mPoint = false })
            local resInfo = ResManagerForLua:getResInfoByTypeAndId(items[i].type, items[i].itemId, items[i].count)
            local normalImage = NodeHelper:getImageByQuality(resInfo.quality)
            local iconBg      = NodeHelper:getImageBgByQuality(resInfo.quality)
            NodeHelper:setMenuItemImage(itemNode, { mHand1 = { normal = normalImage } })
            NodeHelper:setSpriteImage(itemNode, { mPic1 = resInfo.icon, mFrameShade1 = iconBg })
            NodeHelper:setStringForLabel(itemNode, { mNumber1_1 = items[i].count })
            parentNode:addChild(itemNode)
            itemNode:registerFunctionHandler(function(eventName, container)
                if eventName == "onHand1" then
                    GameUtil:showTip(container:getVarNode("mPic1"), items[i])
                end
            end)
        end
    end
end

--- 設定「全部獎勵」頁面內容
local function configureAllRewardPage(container)
    local currentConfig = mainPuzzleConfig[PuzzleController.currentStage]
    PuzzleController.currentStage = math.min(#mainPuzzleConfig,PuzzleController.currentStage)
    NodeHelper:setStringForLabel(container, { mTitleTxt = common:getLanguageString("@PuzzleBattle_NowAward2") })
    populateItemNodes(container, currentConfig.item)

    local scrollView = container:getVarScrollView("mContent")
    scrollView:removeAllCell()
    for _, value in pairs(mainPuzzleConfig) do
        if  PuzzleController.openedGroup[value.groupId] then
            local cell = CCBFileCell:create()
            cell:setCCBFile(AllRewardContent.ccbiFile)
            local panel = common:new({ data = value }, AllRewardContent)
            cell:registerFunctionHandler(panel)
            scrollView:addCell(cell)
        end
    end
    scrollView:orderCCBFileCells()
    scrollView:setTouchEnabled(PuzzleController.openedStageCount > 3)
end

--- 更新物品數量與挑戰按鈕狀態
local function updateItemCountDisplay(container)
    local cost = 1
    local have = InfoAccesser:getUserItemInfo(30000, 7301).count or 0
    NodeHelper:setStringForLabel(container, { mUseItemCount = have .. "/" .. cost })
    NodeHelper:setMenuItemEnabled(container, "mUse", have >= cost)
end

--- 配置關卡資訊彈窗內容
local function configureStageInfoPage(container)
    local stageInfo = subPuzzleConfig[PuzzleController.selectedStageCardId]
    local elementInfo = common:split(stageInfo.limitElement, ",")
    local heroLimitData = {}
    PuzzleController.heroSelectionStatus = {} -- 重置上陣狀態

    local posList = stageInfo.limitPos ~= "" and common:split(stageInfo.limitPos, ",") or {}
    for _, value in ipairs(posList) do
        local parts = common:split(value, "_")
        table.insert(heroLimitData, { id = tonumber(parts[1]), pos = tonumber(parts[2]) })
    end
    for _, element in ipairs(elementInfo) do
        local elemNum = tonumber(element)
        if elemNum and elemNum ~= 0 then
            table.insert(heroLimitData, { element = elemNum })
        end
    end

    configureLimitDisplay(container, heroLimitData)
    configureHeroLimitDisplay(container, stageInfo.limitGirl)

    for _, hasHero in pairs(PuzzleController.heroSelectionStatus) do
        NodeHelper:setMenuItemEnabled(container, "mFight", hasHero)
        if not hasHero then break end
    end

    local costItem   = CommItem:new()
    local costItemUI = costItem:requestUI()
    local parentNode = container:getVarNode("ItemNode")
    if parentNode then parentNode:addChild(costItemUI) end
    costItemUI:setScale(0.4)
    local sz = costItemUI:getContentSize()
    costItemUI:setPosition(ccp(sz.width * -0.2, sz.height * -0.2))
    local itemInfo = InfoAccesser:getItemInfo(30000, 7301, 1)
    costItem:autoSetByItemInfo(itemInfo, false)
    updateItemCountDisplay(container)
    costItemUI:registerFunctionHandler(function(eventName, evtContainer)
        if eventName == "onHand1" then
            local tipNode = evtContainer:getVarNode("mPic1")
            GameUtil:showTip(tipNode, { type = 30000, itemId = 7301, count = 1 })
        end
    end)
end

--------------------------------------------------------------------------------
-- StageCell (關卡項目) 定義與優化
--------------------------------------------------------------------------------
local StageCell = {}
StageCell.ccbiFile = "Puzzle_Content.ccbi"

-- 刷新關卡項目的 UI
function StageCell:onRefreshContent(content)
    local container     = content:getCCBFileNode()
    local stageId       = self.data.id
    local completeStage = PuzzleController.completeStage
    local currentStage  = PuzzleController.currentStage
    local isFinished = isStageFinish(stageId)
    local isChallenging = not isFinished
    local stageText     = isFinished and "@PuzzleBattle_Finish" or
                          (isChallenging and "@PuzzleBattle_Challenging" or "@PuzzleBattle_Locked")
    
    self.isSelect = (stageId == currentStage)

    -- 將更新靜態圖片邏輯封裝起來，避免重複寫條件分支
    local function updateIcon()
        local iconSetting = nil
      
        if isChallenging then
            iconSetting = { default = IMAGE_STAGE[1], selected = IMAGE_STAGE[3] }
        else
            iconSetting = { default = IMAGE_STAGE[2], selected = IMAGE_STAGE[4] }
        end
        updateStageIcon(container, stageId, completeStage, self.isSelect, iconSetting.default, iconSetting.selected)
    end


    -- 將建立 spine 與播放動畫邏輯抽取成函數
    local function playAnimation()
        local spineParent = container:getVarNode("mSpine")
        clearNode(spineParent)
        local success, spineInstance = pcall(SpineContainer.create, SpineContainer, SPINE_CONFIG.PATH, SPINE_CONFIG.NINE_GRID_A)
        if not (success and spineInstance) then
            CCLuaLog("Failed to create spine: " .. (spineInstance or "Unknown error"))
            return false
        end
        spineParent:addChild(tolua.cast(spineInstance, "CCNode"))
        NodeHelper:setNodesVisible(container, { mStageIcon = false })
        if stageId == currentStage then
            spineInstance:runAnimation(1, "A04", 0)
        end
        return true
    end

    -- 判斷是否需要動畫
    if PuzzleController.isPass and isFinished and stageId == PuzzleController.currentStage then
        if not playAnimation() then
            -- 如果建立 spine 失敗則退化為靜態圖片更新
            NodeHelper:setNodesVisible(container, { mStageIcon = true })
            updateIcon()
        end
    else
        NodeHelper:setNodesVisible(container, { mStageIcon = true })
        updateIcon()
    end

    if PuzzleController.preStageCell.id and math.abs(stageId - PuzzleController.preStageCell.id) > 5 then
        PuzzleController.preStageCell = {}
    end

    NodeHelper:setStringForLabel(container, { mStageName = common:getLanguageString(stageText) })
    NodeHelper:setNodesVisible(container, { mLine = (PuzzleController.openedStageCount + PuzzleController.firstId - 1 ~= stageId) })
end



-- 點擊關卡項目事件處理
function StageCell:onHand(container)
    if PuzzleController.isCoolDown then return end

    local actionArray = CCArray:create()
    actionArray:addObject(CCCallFunc:create(function() PuzzleController.isCoolDown = true end))
    actionArray:addObject(CCDelayTime:create(0.5))
    actionArray:addObject(CCCallFunc:create(function() PuzzleController.isCoolDown = false end))
    PuzzleController.container:runAction(CCSequence:create(actionArray))

    local stageId = self.data.id
    --if PuzzleController.completeStage < stageId then
    --    MessageBoxPage:Msg_Box(common:getLanguageString("@PuzzleBattle_Condition"))
    --    return
    if PuzzleController.currentStage == stageId then
        return
    end
    PuzzleController.currentStage = stageId
    PuzzleController.refreshPage()
   
    -- 更新當前選中的關卡圖示

    NodeHelper:setSpriteImage(container, { mStageIcon = IMAGE_STAGE[isStageFinish(stageId) and 4 or 3] })

    if PuzzleController.preStageCell.id then
        if isStageFinish(PuzzleController.preStageCell.id) then
             NodeHelper:setSpriteImage(PuzzleController.preStageCell.container, { mStageIcon = IMAGE_STAGE[2] })
        else
             NodeHelper:setSpriteImage(PuzzleController.preStageCell.container, { mStageIcon = IMAGE_STAGE[1] })
        end
    end
    PuzzleController.preStageCell.container = container
    PuzzleController.preStageCell.id = stageId 
end

--------------------------------------------------------------------------------
-- PuzzleController 方法定義
--------------------------------------------------------------------------------

-- 進入頁面初始化
function PuzzleController:onEnter(container)
    local PageJumpMange = require("PageJumpMange")
    PageJumpMange._IsPageJump = false
    PuzzleController.container = container
    PuzzleController.rewardScrollView = container:getVarScrollView("mRewardContent")
    PuzzleController:registerPackets(container)
    PuzzleController:initHeroTable()
    PuzzleController:sendInfoRequest()

    PuzzleController.remainingTime = MainScenePageInfo:getActTime(195)
    PuzzleController:refreshTime(container)
end

-- 初始化英雄資料表 (僅加入符合條件的英雄)
function PuzzleController:initHeroTable()
    PuzzleController.HeroTable = {}
    local EquipPage = require("Equip.EquipmentPage")
    local UserMercenaryManager = require("UserMercenaryManager")
    local sortedHeroes = EquipPage:sortData(UserMercenaryManager:getMercenaryStatusInfos())
    for _, hero in ipairs(sortedHeroes) do
        if hero.itemId <= 24 and hero.roleStage == Const_pb.IS_ACTIVITE then
            table.insert(PuzzleController.HeroTable, hero)
        end
    end
end

-- 建立獎勵物品捲動視窗的 Cell
function PuzzleController:buildRewardCells(scrollView, items, scale)
    scrollView:removeAllCell()
    for _, value in ipairs(items) do
        local cell = CCBFileCell:create()
        cell:setCCBFile(rewardCellContent.ccbiFile)
        cell:setScale(scale)
        local contentSize = 134 * scale
        cell:setContentSize(CCSizeMake(contentSize + 2, contentSize))
        local panel = common:new({ rewardItem = value }, rewardCellContent)
        cell:registerFunctionHandler(panel)
        scrollView:addCell(cell)
    end
    scrollView:orderCCBFileCells()
    scrollView:setTouchEnabled(#items > 4)
end

-- rewardCellContent 的 onRefreshContent (獎勵 Cell 刷新)
function rewardCellContent:onRefreshContent(content)
    local container = content:getCCBFileNode()
    local ResManager = require("ResManagerForLua")
    local resInfo = ResManager:getResInfoByTypeAndId(self.rewardItem.type, self.rewardItem.itemId, self.rewardItem.count or 1)
    local numStr = resInfo.count > 0 and ("x" .. GameUtil:formatNumber(resInfo.count)) or ""
    NodeHelper:setNodesVisible(container, { mStarNode = (self.rewardItem.type == 40000) })
    NodeHelper:setStringForLabel(container, { mNumber = numStr })
    NodeHelper:setSpriteImage(container, { mPic = resInfo.icon }, { mPic = 1 })
    NodeHelper:setQualityFrames(container, { mHand = resInfo.quality })
    NodeHelper:setNodesVisible(container, { mName = false })
end

-- rewardCellContent 點擊事件處理
function rewardCellContent:onHand(container)
    GameUtil:showTip(container:getVarNode("mHand"), self.rewardItem)
end

-- AllRewardContent 的 onRefreshContent 
function AllRewardContent:onRefreshContent(content)
    local container = content:getCCBFileNode()
    populateItemNodes(container, self.data.item)
    local txt = common:getLanguageString("@PuzzleBattle_Trial_" .. self.data.TrailNumber, 
                                           common:getLanguageString("@HeroName_" .. self.data.HeroId))
    NodeHelper:setStringForLabel(container, { mTitleTxt = txt })
end


-- 建立關卡捲動視窗內容
function PuzzleController:buildStageScrollview()
    local container = PuzzleController.container
    local stageScroll = container:getVarScrollView("mStageScrollView")
    if stageScroll then stageScroll:removeAllCell() end
    PuzzleController.openedStageCount = 0
    for _, stageCfg in ipairs(mainPuzzleConfig) do
        if  PuzzleController.openedGroup[stageCfg.groupId] then  
            PuzzleController.openedStageCount = PuzzleController.openedStageCount + 1
            local cell = CCBFileCell:create()
            cell:setCCBFile(StageCell.ccbiFile)
            local panel = common:new({ data = stageCfg }, StageCell)
            cell:registerFunctionHandler(panel)
            stageScroll:addCell(cell)
        end
    end
    stageScroll:orderCCBFileCells()
    stageScroll:setTouchEnabled(PuzzleController.openedStageCount > 5)

    local viewWidth   = stageScroll:getViewSize().width
    local contentWidth = PuzzleController.openedStageCount * STAGE_CELL_WIDTH
    local targetX = (PuzzleController.currentStage - PuzzleController.firstId + 1 - 0.5) * STAGE_CELL_WIDTH - (viewWidth / 2)
    targetX = math.max(0, math.min(contentWidth - viewWidth, targetX))
    stageScroll:setContentOffset(ccp(-targetX, 0))
end

-- 刷新頁面整體內容 (關卡、卡牌、獎勵、倒數計時)
function PuzzleController:refreshPage()
    local container = PuzzleController.container
    local currentConfig = mainPuzzleConfig[PuzzleController.currentStage]
    if not currentConfig then return end

    NodeHelper:setNodesVisible(container, { mPuzzleImg = true })
    NodeHelper:setSpriteImage(container, { mPuzzleImg = currentConfig.image })
    local stageIds = common:split(currentConfig.StageId or "", ",")
    PuzzleController.currentStageCardIds = stageIds

    PuzzleController:buildRewardCells(PuzzleController.rewardScrollView, currentConfig.item, 0.42)

    -- 根據卡牌數量決定版面設定
    local spinePath = SPINE_CONFIG.PATH
    local prefix, layoutCount, cardAnimation, borderAnimation
    local BorderParent = {}
    if #stageIds > 4 then
        NodeHelper:setNodesVisible(container, { mCard_9_Node = true, mCard_4_Node = false })
        prefix = "mCard_9_"
        layoutCount = 9
        cardAnimation = "C03"
        borderAnimation = "D03"
        BorderParent[9] = container:getVarNode("Border_Spine_9")
    else
        NodeHelper:setNodesVisible(container, { mCard_9_Node = false, mCard_4_Node = true })
        prefix = "mCard_4_"
        layoutCount = 4
        cardAnimation = "C01"
        borderAnimation = "D01"
        BorderParent[4] = container:getVarNode("Border_Spine_4")
    end

    -- 清除邊框動畫節點
    for _, parent in pairs(BorderParent) do
        clearNode(parent)
    end

    -- 建立已通關記錄查找表
    local passedSet = {}
    for _, passedId in ipairs(PuzzleController.completedLevelIds or {}) do
        passedSet[tonumber(passedId) or passedId] = true
    end

    -- 建立卡牌動畫 (僅對尚未通關的卡牌)
    for i = 1, layoutCount do
        local cardId = tonumber(stageIds[i]) or stageIds[i]
        NodeHelper:setNodesVisible(container, { [prefix .. i] = not passedSet[cardId] })
        if not passedSet[cardId] then
            local success, spineInstance = pcall(SpineContainer.create, SpineContainer, spinePath, SPINE_CONFIG.NINE_GRID_C)
            local parentNode = container:getVarNode(prefix .. i .. "_Spine")
            clearNode(parentNode)
            if success and spineInstance then
                parentNode:addChild(tolua.cast(spineInstance, "CCNode"))
                spineInstance:runAnimation(1, cardAnimation, 0)
            else
                CCLuaLog("Failed to create card spine: " .. (spineInstance or "Unknown error"))
            end
        end
    end

    -- 建立邊框動畫 (僅在未全部通關時)
    local allPassed = true
    for i = 1, layoutCount do
        local cardId = tonumber(stageIds[i]) or stageIds[i]
        if not passedSet[cardId] then
            allPassed = false
            break
        end
    end
    if not allPassed then
        local success, spineInstance = pcall(SpineContainer.create, SpineContainer, spinePath, SPINE_CONFIG.NINE_GRID_B)
        if success and spineInstance then
            for _, parent in pairs(BorderParent) do
                parent:addChild(tolua.cast(spineInstance, "CCNode"))
            end
            spineInstance:runAnimation(1, borderAnimation, 0)
        else
            CCLuaLog("Failed to create border spine: " .. (spineInstance or "Unknown error"))
        end
    end

    -- 更新標題與剩餘挑戰次數文字
    local stringTable = { mRewardTitle = common:getLanguageString("@PuzzleBattle_NowAward") }
    if PuzzleController.freeEntries == 0 then
        stringTable.mEnterCount = common:getLanguageString("@PuzzleBattle_BuyEnterCount") .. PuzzleController.paidEntries
    else
        stringTable.mEnterCount = common:getLanguageString("@PuzzleBattle_EnterCount") .. PuzzleController.freeEntries
    end
    NodeHelper:setStringForLabel(container, stringTable)

    -- 啟動倒數計時器 (每秒更新)
    PuzzleController:refreshTime(container)
end
function PuzzleController:refreshTime(container)
     if not PuzzleController.countdownTimerId then
        local scheduler = CCDirector:sharedDirector():getScheduler()
        PuzzleController.countdownTimerId = scheduler:scheduleScriptFunc(function()
            PuzzleController.remainingTime = PuzzleController.remainingTime - 1
            if PuzzleController.countdownTimerId and PuzzleController.remainingTime <= 0 and not PuzzleController.isConfirmPop then
                PageManager.showConfirm("@PuzzleBattle_Title", "@PuzzleBattle_Error_01", function(isSure)
                    if isSure then
                        PuzzleController:onExit()
                    end
                end, true, nil, nil, false, nil, nil, nil, false)
                PuzzleController.isConfirmPop = true
                return
            end
            local timeText = ""
            if PuzzleController.remainingTime > 86400 then
                timeText = (common:getDayNumber(PuzzleController.remainingTime) + 1) .. common:getLanguageString("@Days")
            else
                timeText = common:dateFormat2String(PuzzleController.remainingTime, true)
            end
            NodeHelper:setStringForLabel(container, { mCountDown = common:getLanguageString("@PuzzleBattle_Time") .. timeText })
        end, 1, false)
    end
end
-- 點擊卡牌事件處理 (根據點擊卡牌索引設定選取卡牌ID並開啟關卡資訊彈窗)
function PuzzleController:onCardSelected(container, eventName)
    if PuzzleController.isCoolDown then return end
    local stageIndex = tonumber(string.sub(eventName, -1))
    PuzzleController.selectedStageCardId = tonumber(PuzzleController.currentStageCardIds[stageIndex])
    
    local popUp = PuzzleController.container:getVarNode("PopUpNode")
    if popUp then clearNode(popUp) end
    stageInfoNode = ScriptContentBase:create("Puzzle_Price")
    popUp:addChild(stageInfoNode)
    configureStageInfoPage(stageInfoNode)
    stageInfoNode:registerFunctionHandler(handleStageInfoEvent)
end

-- 送出跳過關卡請求
function PuzzleController:sendSkipStage()
    local msg = Activity6_pb.PuzzleBattleReq()
    msg.action     = 1
    msg.mainId = PuzzleController.currentStage
    msg.subStageId = PuzzleController.selectedStageCardId or 0
    common:sendPacket(HP_pb.ACTIVITY195_PUZZLE_BATTLE_C, msg, true)   
end

-- 送出資訊請求
function PuzzleController:sendInfoRequest()
    local msg = Activity6_pb.PuzzleBattleReq()
    msg.action = 0
    common:sendPacket(HP_pb.ACTIVITY195_PUZZLE_BATTLE_C, msg, false)
end

-- 離開頁面處理：清除計時器與解除封包監聽
function PuzzleController:onExit()
    PuzzleController:removePackets(PuzzleController.container)
    if PuzzleController.countdownTimerId then
        CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(PuzzleController.countdownTimerId)
        PuzzleController.countdownTimerId = nil
    end
    PuzzleController.completeStage = 0
    PuzzleController.isPass = false
    PuzzleController.isConfirmPop = false
    onUnload(PAGE_NAME, PuzzleController.container)
    PageManager.popPage(PAGE_NAME)
    isFirst = true
end

-- 接收伺服器回傳封包處理
function PuzzleController:onReceivePacket(container)
    local opcode  = container:getRecPacketOpcode()
    local msgBuff = container:getRecPacketBuffer()

    if opcode == HP_pb.PLAYER_AWARD_S then
        local msg = Reward_pb.HPPlayerReward()
        msg:ParseFromString(msgBuff)
        if msg then
            local rewards = msg.rewards.showItems
            local showReward = {}
            for i = 1, #rewards do
                local oneReward = rewards[i]
                if oneReward.itemCount > 0 then
                    local resInfo = { type = oneReward.itemType, itemId = oneReward.itemId, count = oneReward.itemCount }
                    showReward[#showReward + 1] = resInfo
                end
            end
            PuzzleController.showReward = showReward
        end
    end

    local CardSpine, BorderSpine, cardAni, borderAni, borderAniIdle = nil, nil, "", "", ""
    if opcode == opcodes.ACTIVITY195_PUZZLE_BATTLE_S then
        local msg = Activity6_pb.PuzzleBattleResp()
        msg:ParseFromString(msgBuff)
        if msg.action == 1 then
            PuzzleController.isPass = true
            local popUp = PuzzleController.container:getVarNode("PopUpNode")
            if popUp then clearNode(popUp) end
        end
        if msg.action == 0 or msg.action == 1 then
            PuzzleController.completeStage = msg.passId
            for _,groupId in pairs (msg.groupId) do
                if type(groupId) == "number" then
                    PuzzleController.openedGroup[groupId] = true
                end
            end
            PuzzleController:refreshPage()
            PuzzleController:buildStageScrollview()
            if PuzzleController.isPass and isStageFinish(PuzzleController.currentStage) then
                newStage = 1
                PuzzleController.isPassStage = true
                local parentNode = nil
                if #PuzzleController.currentStageCardIds > 4 then
                    borderAni = "D04"
                    borderAniIdle = "D03"
                    parentNode = PuzzleController.container:getVarNode("Border_Spine_9")
                else
                    borderAni = "D02"
                    borderAniIdle = "D01"
                    parentNode = PuzzleController.container:getVarNode("Border_Spine_4")
                end
                clearNode(parentNode)
                local success, spine = pcall(SpineContainer.create, SpineContainer, SPINE_CONFIG.PATH, SPINE_CONFIG.NINE_GRID_B)
                if success and spine then
                    parentNode:addChild(tolua.cast(spine, "CCNode"))
                    BorderSpine = spine
                    BorderSpine:runAnimation(1, borderAniIdle, 0)
                else
                    CCLuaLog("Failed to create spine: " .. (spine or "Unknown error"))
                end
            end
            local _, firstGroup = next(msg.groupId) 
            for _,data in pairs (mainPuzzleConfig) do
                if data.groupId == firstGroup then
                    PuzzleController.firstId = data.id
                    if PuzzleController.currentStage == 0 then
                        PuzzleController.currentStage = PuzzleController.firstId
                    end
                    break
                end
            end
            local groupPassedIds = {}
            for _,passId in pairs (msg.passId) do
                if type(passId) == "number" then
                    local mId = mainPuzzleConfig[passId].groupId
                    if PuzzleController.openedGroup[mId] then
                        groupPassedIds[passId] = true
                    end
                end
            end
           if PuzzleController.currentStage == PuzzleController.firstId and #groupPassedIds > 1 then
                local passed = {}
                for _, s in ipairs(PuzzleController.completeStage) do
                    passed[s] = true
                end
                for i = PuzzleController.firstId, #mainPuzzleConfig do
                    if not passed[i] then
                        PuzzleController.currentStage = i
                        break
                    end
                end
           end

            local ServerCompleteIds = {}
            ServerCompleteIds = mergeTables(ServerCompleteIds, msg.puzzleId)
            ServerCompleteIds = mergeTables(ServerCompleteIds, PuzzleController.completedLevelIds)
            if PuzzleController.isPass then
                require("TransScenePopUp")
                TransScenePopUp_closePage()        
                if ServerCompleteIds ~= PuzzleController.completedLevelIds then
                    local id = PuzzleController.selectedStageCardId
                    local idx = 1
                    for _id, _val in pairs(PuzzleController.currentStageCardIds) do
                        if tonumber(_val) == id then
                            idx = _id
                        end
                    end
                    local parentNode = nil
                    if #PuzzleController.currentStageCardIds > 4 then
                        cardAni = "C04"
                        parentNode = PuzzleController.container:getVarNode("mCard_9_" .. idx .. "_Spine")
                    else
                        cardAni = "C02"
                        parentNode = PuzzleController.container:getVarNode("mCard_4_" .. idx .. "_Spine")
                    end
                    clearNode(parentNode)
                    local success, spine = pcall(SpineContainer.create, SpineContainer, SPINE_CONFIG.PATH, SPINE_CONFIG.NINE_GRID_C)
                    if success and spine then
                        parentNode:addChild(tolua.cast(spine, "CCNode"))
                        CardSpine = spine
                    else
                        CCLuaLog("Failed to create spine: " .. (spine or "Unknown error"))
                    end
                end
            end
            PuzzleController.completedLevelIds = {}
            for k,v in pairs (msg.passId) do
                local config = mainPuzzleConfig[v]
                if type(k) == "number" and config and config.StageId then
                    local stages = common:split(config.StageId, ",")
                    PuzzleController.completedLevelIds = mergeTables(PuzzleController.completedLevelIds, stages)
                end
            end
            PuzzleController.completedLevelIds = mergeTables(PuzzleController.completedLevelIds, msg.puzzleId)
            PuzzleController.paidEntries   = msg.usePay
            PuzzleController.freeEntries   = msg.useFree
            local MainScenePageInfo = require("MainScenePage")
            local puzzleTime = MainScenePageInfo:getActTime(195)
            PuzzleController.remainingTime = puzzleTime --msg.leftTime
        end

        local actionArray = CCArray:create()
        if CardSpine and cardAni ~= "" then
            actionArray:addObject(CCCallFunc:create(function()
                CardSpine:runAnimation(1, cardAni, 0)
                CardSpine = nil
                cardAni = ""
                PuzzleController.isPass = false
                PuzzleController.isCoolDown = true
            end))
            actionArray:addObject(CCDelayTime:create(2))
        end
        if BorderSpine and borderAni ~= "" and borderAniIdle ~= "" then          
            actionArray:addObject(CCCallFunc:create(function()
                BorderSpine:runAnimation(1, borderAni, 0)
                BorderSpine = nil
                PuzzleController.isCoolDown = true
            end))
            actionArray:addObject(CCDelayTime:create(1))
        end
        if #PuzzleController.showReward ~= 0 then
            actionArray:addObject(CCCallFunc:create(function()
                local CommonRewardPage = require("CommPop.CommItemReceivePage")
                CommonRewardPage:setData(PuzzleController.showReward, common:getLanguageString("@ItemObtainded"), nil)
                PageManager.pushPage("CommPop.CommItemReceivePage")
                PuzzleController.showReward = {}
            end))
        end
        actionArray:addObject(CCCallFunc:create(function()
            PuzzleController.isCoolDown = false
            PuzzleController:refreshPage()
            PuzzleController:buildStageScrollview()
            require("TransScenePopUp")
            TransScenePopUp_closePage() 
        end))
        PuzzleController.container:runAction(CCSequence:create(actionArray))

    elseif opcode == HP_pb.BATTLE_FORMATION_S then
        local msg = Battle_pb.NewBattleFormation()
        msg:ParseFromString(msgBuff)
        if msg.type == NewBattleConst.FORMATION_PROTO_TYPE.REQUEST_ENEMY then
            local battlePage = require("NgBattlePage")
            resetMenu("mBattlePageBtn", true)
            require("NgBattleDataManager")
            NgBattleDataManager_setDungeonId(tonumber(msg.mapId))
            PageManager.changePage("NgBattlePage")
            battlePage:onPuzzle(PuzzleController.container, msg.resultInfo, msg.battleId, msg.battleType, tonumber(msg.mapId))
        end
    end
end

function PuzzleController:setPassState(_isPass)
    PuzzleController.isPass = _isPass
end

function PuzzleController:setReward(reward)
    PuzzleController.showReward = reward
end

-- 註冊監聽封包 (所有 S 結尾的 opcode)
function PuzzleController:registerPackets(container)
    for key, opcode in pairs(opcodes) do
        if key:sub(-1) == "S" then container:registerPacket(opcode) end
    end
end

-- 解除監聽封包
function PuzzleController:removePackets(container)
    for key, opcode in pairs(opcodes) do
        if key:sub(-1) == "S" then container:removePacket(opcode) end
    end
end

-- 說明按鈕事件處理
function PuzzleController:onHelp()
   local file=GameConfig.HelpKey["HELP_PUZZLE"]
    PageManager.showHelp(file)
end

-- 點擊獎勵按鈕時顯示全部獎勵頁面
function PuzzleController:onReward()
    local popUp = PuzzleController.container:getVarNode("PopUpNode")
    if popUp then clearNode(popUp) end
    allRewardNode = ScriptContentBase:create("Puzzle_Reward")
    popUp:addChild(allRewardNode)
    configureAllRewardPage(allRewardNode)
    allRewardNode:registerFunctionHandler(function(eventName, container)
        if eventName == "onClose" or eventName == "onConfirm" then
            clearNode(PuzzleController.container:getVarNode("PopUpNode"))
        end
    end)
end

--------------------------------------------------------------------------------
-- 註冊卡牌按鈕 (9 張與 4 張版面)
--------------------------------------------------------------------------------
registerCardButtonEvents("onCard_9_", 9)
registerCardButtonEvents("onCard_4_", 4)

--------------------------------------------------------------------------------
-- 生成 PuzzlePage 頁面並返回
--------------------------------------------------------------------------------
local PuzzlePage = CommonPage.newSub(PuzzleController, PAGE_NAME, pageOptions)
return PuzzlePage
