--------------------------------------------------
-- 成長戰令重構版
-- 模組名稱：TowerPassPage
-- 本模組負責成長戰令頁面（購買、展示獎勵、標籤切換等）的邏輯與 UI 更新
--------------------------------------------------

-- 載入依賴模組
local NodeHelper          = require("NodeHelper")
local UserInfo            = require("PlayerInfo.UserInfo")
local Activity6_pb        = require("Activity6_pb")
local HP_pb               = require("HP_pb")
local BuyManager          = require("BuyManager")
local TowerPassData       = require("TowerPass.TowerPassData")
local TowerPageData       = require("Tower.TowerPageData")
local ConfigManager       = require("ConfigManager")
local common              = require("common")
local json                = require("json")
local PackageLogicForLua  = require("PackageLogicForLua")
local PageManager         = require("PageManager")
local MSG_MAINFRAME_REFRESH = MSG_MAINFRAME_REFRESH
local MSG_RECHARGE_SUCCESS  = MSG_RECHARGE_SUCCESS

--------------------------------------------------
-- 全域模型：存放頁面狀態與數據
--------------------------------------------------
local Model = {
    cfg         = {},   -- 配置資料（包含 StageData、RechargeId 等）
    rechargeId  = 1,
    serverData  = {},
    currentType = 1,    -- 當前選擇的標籤類型
    scrollOffset = nil, -- 畫面滾動偏移記錄
    TagContainers = {}
}

--------------------------------------------------
-- 常數與配置
--------------------------------------------------
local OPTION = {
    ccbiFile   = "GrowthBundleVer2.ccbi",
    handlerMap = {
        onHelp = "onHelp",
        onBuy  = "onBuy",
    },
}
local ContentCellCCBI = "GrowthBundleItemVer2.ccbi"  -- 獎勵 cell 對應檔案
local TagCCBI         = "GrowthBundleVer2_tag.ccbi"     -- 標籤模板檔案

local OPCODES = {
    FETCH_SHOP_LIST_S  = HP_pb.FETCH_SHOP_LIST_S,
    PLAYER_AWARD_S     = HP_pb.PLAYER_AWARD_S,
    SUPER_TOWER_PASS_S = HP_pb.SUPER_TOWER_PASS_S,
}

--------------------------------------------------
-- 子模組：TowerPassContent
-- 此模組用來處理每個 cell（獎勵項目）中的 UI 與邏輯
--------------------------------------------------
local TowerPassContent = {}
TowerPassContent.__index = TowerPassContent

-- 建立新的 TowerPassContent 物件
function TowerPassContent:new(params)
    local o = params or {}
    setmetatable(o, TowerPassContent)
    return o
end

-- 刷新 cell 內容（獎勵資訊與按鈕狀態）
function TowerPassContent:onRefreshContent(ccbRoot)
    local index      = self.index             -- 當前 cell 序號
    local container  = ccbRoot:getCCBFileNode()
    local stageData  = Model.cfg[Model.currentType].StageData
    local visibleMap = {}  -- 用來設定各節點是否顯示
    local spriteMap  = {}  -- 圖片與框架對應資料
    local qualityMap = {}  -- 品質標識（框架顏色）
    local labelMap   = {}  -- 標籤文字
    local colorMap   = {}  -- 文字顏色

    -- 將 mRewardNode2 至 mRewardNode4 預設為隱藏
    for i = 2, 4 do
        visibleMap["mRewardNode" .. i] = false
    end
    local actId = Model.cfg[1].ActivityId
    local imgTable = {
        [194] = { BG = "BG/Activity/Growth_Tower_img2.png",Flag = "BG/Activity/Growth_Tower_img3.png" },
        [198] = { BG = "BG/Activity/Growth_Tower_img2.png", Flag = "BG/Activity/Growth_Tower_img3.png" },
        [199] = { BG = "BG/Activity/Growth_TowerOnelife_img2.png", Flag = "BG/Activity/Growth_TowerOnelife_img3.png" }
    }
    for i = 1 , 3 do
        local _Type = i == 3
        visibleMap["mBg"..i] = _Type
        visibleMap["mFlag"..i] = _Type
    end
    spriteMap["mBg3"] = imgTable[actId].BG
    spriteMap["mFlag3"] = imgTable[actId].Flag

    if stageData then    
        -- 更新按鈕狀態
        self:buttonControl(container, Model.cfg[Model.currentType], index)

        -- 設定領取狀態
        local received = (self.status == 3)
        NodeHelper:setNodesVisible(container, {
            mReceived1 = (self.status == 2 or self.status == 3 or self.status == 5),
            mReceived2 = received,
            mReceived3 = received,
            mReceived4 = received,
        })

        -- 免費獎勵資訊
        local info = stageData[index]
        if info then
            local freeReward = info.Free[1]
            local freeRes    = ResManagerForLua:getResInfoByTypeAndId(freeReward.type, freeReward.itemId, freeReward.count)
            spriteMap["mPic1"]         = freeRes.icon
            spriteMap["mFrameShade1"]  = NodeHelper:getImageBgByQuality(freeRes.quality)
            qualityMap["mFrame1"]      = freeRes.quality
            labelMap["mNum1"]          = tostring(freeReward.count)
            labelMap["mName1"]         = ""  -- 可依需求顯示 freeRes.name
            labelMap["mLv"]            = info.PassStage

            -- 付費獎勵資訊處理
            for i = 1, #info.Cost do
                local costCfg = info.Cost[i]
                visibleMap["mRewardNode" .. (i + 1)] = (costCfg ~= nil)
                if costCfg then
                    local resInfo = ResManagerForLua:getResInfoByTypeAndId(costCfg.type, costCfg.itemId, costCfg.count)
                    if resInfo then
                        spriteMap["mPic" .. (i + 1)]  = resInfo.icon
                        labelMap["mNum" .. (i + 1)]    = GameUtil:formatNumber(costCfg.count)
                        labelMap["mName" .. (i + 1)]   = ""  -- 可填入 resInfo.name
                        qualityMap["mFrame" .. (i + 1)] = resInfo.quality
                        colorMap["mName" .. (i + 1)]    = ConfigManager.getQualityColor()[resInfo.quality].textColor
                    else
                        CCLuaLog("Error: 獎勵項目未找到！")
                    end
                end
            end
        end

        -- 更新各節點：可見性、文字、圖示、框架、顏色
        NodeHelper:setNodesVisible(container, visibleMap)
        NodeHelper:setStringForLabel(container, labelMap)
        NodeHelper:setSpriteImage(container, spriteMap)
        NodeHelper:setQualityFrames(container, qualityMap)
        NodeHelper:setColorForLabel(container, colorMap)
    end
end

-- 控制獎勵按鈕狀態
function TowerPassContent:buttonControl(container, cfgData, index)
    local function lang(lan)
        return common:getLanguageString(lan)
    end 
    local btnLabel = ""
    local nowPass  = TowerPageData:getData(cfgData.ActivityId,cfgData._LimitType).MaxFloor or 0
    self.target    = cfgData.StageData[index].PassStage

    -- 根據 serverData 判定各種狀態：
    -- 狀態定義：
    -- 1：已購買，未領取；2：已購買，已領取免費；3：已購買，已領取全部
    -- 4：未購買，未領取；5：未購買，已領取免費；6：未達成目標
    if nowPass >= self.target then
        if Model.serverData.costFlag then
            if Model.serverData.costStageId[index] and Model.serverData.costStageId[index] ~= 0 then
                btnLabel = lang("@ReceiveDone")
                self.status = 3
            else
                if Model.serverData.freeStageId[index] and Model.serverData.freeStageId[index] ~= 0 then
                    self.status = 2
                else
                    self.status = 1
                end
                btnLabel = lang("@Receive")
            end
        else
            if Model.serverData.freeStageId[index] and Model.serverData.freeStageId[index] ~= 0 then
                btnLabel = lang("@buy")
                self.status = 5
            else
                btnLabel = lang("@Receive")
                self.status = 4
            end
        end
    else
        btnLabel = lang("@Underway")
        self.status = 6
    end

    NodeHelper:setStringForLabel(container, { mBtnLabel = btnLabel })
    NodeHelper:setMenuItemsEnabled(container, { mBtn = not (self.status == 3 or self.status == 6 or self.status == 5) })
end

-- 通用顯示物品提示（免費或付費獎勵皆適用）
function TowerPassContent:onShowItemInfo(container, stageIndex, goodIndex, isFree)
    local stageData = Model.cfg[Model.currentType].StageData
    if not stageData or not stageData[stageIndex] then return end
    local packetItem = nil
    if isFree then
        packetItem = stageData[stageIndex].Free
        GameUtil:showTip(container:getVarNode('mPic' .. goodIndex), packetItem[goodIndex])
    else
        packetItem = stageData[stageIndex].Cost
        GameUtil:showTip(container:getVarNode('mPic' .. goodIndex), packetItem[goodIndex - 1])
    end
end

-- 處理獎勵按鈕點擊：發送領取請求
function TowerPassContent:onBtnClick(container)
    Model.scrollOffset = Model.scrollview:getContentOffset()
    if self.status == 3 or self.status == 6 then return end
    local msg = Activity6_pb.SuperTowerPassReq()
    msg.action = 1
    msg.rechargeId = Model.rechargeId
    msg.passStageId = self.target
    local pb = msg:SerializeToString()
    PacketManager:getInstance():sendPakcet(HP_pb.SUPER_TOWER_PASS_C, pb, #pb, true)
end
function TowerPassContent:onFrame1(container)
     self:onShowItemInfo(container, self.index, 1, true)
end
function TowerPassContent:onFrame2(container)
     self:onShowItemInfo(container, self.index, 2, false)
end
function TowerPassContent:onFrame3(container)
     self:onShowItemInfo(container, self.index, 3, false)
end
function TowerPassContent:onFrame4(container)
     self:onShowItemInfo(container, self.index, 4, false)
end
-- 通用 onFrame 回調，用以顯示獎勵物品提示
function TowerPassContent:onFrame(container, index, isFree)
    self:onShowItemInfo(container, self.id, index, isFree)
end

--------------------------------------------------
-- 主模組：TowerPassPage
--------------------------------------------------
local TowerPassPage = {}
TowerPassPage.__index = TowerPassPage

-- 建立頁面，並註冊按鈕處理
function TowerPassPage:createPage(_parentPage)
    parentPage = _parentPage
    local container = ScriptContentBase:create(OPTION.ccbiFile)
    container:registerFunctionHandler(function(eventName, container)
        local funcName = OPTION.handlerMap[eventName]
        if self[funcName] then
            self[funcName](self, container)
        end
    end)
    return container
end

-- 建立新的實例
function TowerPassPage:new(o)
    o = o or {}
    setmetatable(o, self)
    return o
end

-- 頁面進入：初始化、註冊封包及更新貨幣等
function TowerPassPage:onEnter(container)
    Model.container = container
    parentPage:registerPacket(OPCODES)
    parentPage:registerMessage(MSG_MAINFRAME_REFRESH)
    parentPage:registerMessage(MSG_RECHARGE_SUCCESS)
    requesting = false
    -- 調整背景縮放
    for i = 1, 3 do
        local bg = container:getVarSprite("mBGSprite" .. i)
        bg:setScale(NodeHelper:getScaleProportion())
    end

    Model.cfg = parentPage.currentSubPageData.configData
    Model.rechargeId = Model.cfg[Model.currentType].RechargeId or 1
    Model.scrollview = container:getVarScrollView("mContent")
    CCLuaLog("--------------------------------------------1")
    NodeHelper:autoAdjustResizeScrollview(Model.scrollview)
    NodeHelper:autoAdjustResizeScale9Sprite(container:getVarScale9Sprite("mContentBg"))
    local offsetY = NodeHelper:calcAdjustResolutionOffY()
    container:getVarNode("mTop"):setPositionY(750 + offsetY)
    CCLuaLog("--------------------------------------------2")
    self:updateTabVisual(container)
    self:onCurrentPage()
end

-- 取得頁面配置（StageData）
function TowerPassPage:getPageCfg()
    return Model.cfg[Model.currentType].StageData
end

-- 刷新頁面：重建滾動容器內容
function TowerPassPage:refresh(container)
    local itemInfo = nil
    for i = 1, #RechargeCfg do
        if tonumber(RechargeCfg[i].productId) == Model.rechargeId then
            itemInfo = RechargeCfg[i]
            break
        end
    end
    local scrollview = Model.scrollview
    scrollview:removeAllCell()

    parentPage:updateCurrency()
    Model.serverData = TowerPassData:getData(Model.rechargeId) or {}

    NodeHelper:setNodesVisible(container, { 
        mCost   = (Model.serverData.costFlag == false), 
        mBought = (Model.serverData.costFlag == true), 
        mCoin   = (Model.serverData.costFlag == false)
    })
    NodeHelper:setMenuItemsEnabled(container, { mBuy = (Model.serverData.costFlag == false) })

    if (Model.serverData.costFlag == false) and itemInfo then
        NodeHelper:setStringForLabel(container, { mCost = itemInfo.productPrice })
    end

    -- 更新配置，只保留有 type 的項目
    local cfgTemp = {}
    for i, v in ipairs(Model.cfg) do
        if v.type then
            table.insert(cfgTemp, v)
        end
    end
    Model.cfg = cfgTemp
    local stageData = Model.cfg[Model.currentType].StageData
    if not next(stageData) then return end
    for i = 1 , #stageData do
        cell = CCBFileCell:create()
        cell:setCCBFile(ContentCellCCBI)
        local panel = TowerPassContent:new({ id = stageData[i].id, index = i })
        cell:registerFunctionHandler(panel)
        scrollview:addCell(cell)
    end
        scrollview:orderCCBFileCells()
    if Model.scrollOffset then
        scrollview:setContentOffset(Model.scrollOffset)
        Model.scrollOffset = nil
    else
        scrollview:setContentOffset(ccp(0,scrollview:getViewSize().height - scrollview:getContentSize().height))
    end
end

-- 更新頁面上方標籤及相關 UI
function TowerPassPage:refreshUI(container)
    self:createOrUpdateTagButtons(container)
    self:updatePassProgress(container)
    self:updateTabVisual(container)
end

-- 更新背景、標題、圖示等（根據不同標籤）
function TowerPassPage:updateTabVisual(container)
    -- 活動 ID 與背景及標題圖片對應表
    local imgTable = {
        [194] = { BGSprite = "BG/Activity/Growth_Tower_bg.png", Title = "Growth_TowerVer2_Label.png",Bar = "BG/Activity/Growth_Tower_img1.png" },
        [198] = { BGSprite = "BG/Activity/Growth_Tower_bg.png", Title = "Growth_TowerVer2_Label.png",Bar = "BG/Activity/Growth_Tower_img1.png" },
        [199] = { BGSprite = "BG/Activity/Growth_TowerOnelife_bg.png", Title = "Growth_TowerVer2_Label.png",Bar = "BG/Activity/Growth_TowerOnelife_img1.png" }
    }

    local actId = Model.cfg[1].ActivityId
    local visibleMap = {}
    local rewardLabels = {}
    local commonKeys = {"Title", "BGSprite", "Icon", "Active", "RewardCount"}

    -- 依序處理三個節點索引
    for i = 1, 3 do
        local isCurrent = (i == 3)
        -- 為共通鍵依據當前狀態設定可見性
        for _, key in ipairs(commonKeys) do
            visibleMap["m" .. key .. i] = isCurrent
        end
        -- 特殊處理 "mCG" 節點：僅當是當前且 actId 不等於指定常數時顯示
        visibleMap["mCG" .. i] = isCurrent and (actId ~= Const_pb.ACTIVITY199_FearLess_TOWER)

        -- 準備獎勵數量標籤的字串
        rewardLabels["mRewardCount" .. i] = Model.diamondCount or ""
    end

    -- 更新容器中節點的可見性以及獎勵數量標籤
    NodeHelper:setNodesVisible(container, visibleMap)
    NodeHelper:setStringForLabel(container, rewardLabels)

    -- 根據當前活動 ID 更新精靈圖像（背景及標題）
    local spriteTable = {
        ["mBGSprite3"] = imgTable[actId].BGSprite,
        ["mTitle3"]    = imgTable[actId].Title,
        ["mBar3"]      = imgTable[actId].Bar
    }
    NodeHelper:setSpriteImage(container, spriteTable)

    CCLuaLog("--------------------------------------------3")
end



-- 建立或更新標籤按鈕
function TowerPassPage:createOrUpdateTagButtons(container)
    local parentNode = container:getVarNode("mTagNode")
    if not parentNode then
        print("Error: mTagNode 不存在！")
        return
    end
    parentNode:removeAllChildren()

    local diamondCount = 0
    local typeSet = {}

    local function CountDiamond(data)
        local count = 0
        for _, reward in pairs(data) do
            if reward.itemId == 1001 then
                count = count + reward.count
            end
        end
        return count
    end

    -- 遍歷所有配置，同時計算鑽石數量
    for _, cfg in ipairs(Model.cfg) do
        if cfg.type then
            typeSet[cfg.type] = true
        end
        local stageData = cfg.StageData
        for _,info in pairs(stageData) do
            diamondCount = diamondCount + CountDiamond(info.Free or {})
            diamondCount = diamondCount + CountDiamond(info.Cost or {})
        end
    end
    Model.diamondCount = diamondCount

    -- 統計不同 type 的個數
    local typeCount = 0
    for _ in pairs(typeSet) do
        typeCount = typeCount + 1
    end
    if typeCount == 0 then
        print("Error: 無有效的 type！")
        return
    end

    Model.TagContainers = Model.TagContainers or {}
    local btnWidth = 720 / typeCount
    for i = 1, typeCount do
        local tag = self:createTag(i, Model.cfg[i])
        Model.TagContainers[i] = tag
        local isChosen = (Model.currentType == i)
        NodeHelper:setNodesVisible(tag, { unSelect = not isChosen, Selected = isChosen })
        tag:setPosition(ccp((i - 0.5) * btnWidth, 40))
        parentNode:addChild(tag)
    end
end



-- 產生單一標籤按鈕
function TowerPassPage:createTag(index, cfg)
    local typeCount = #Model.cfg   -- 此處可根據需求修正計算
    local width = 720 / typeCount
    local height = 75
    local tag = ScriptContentBase:create(TagCCBI)
    tag:setContentSize(CCSizeMake(width, height))
    
    local option = {
        scale9Name = {"mBg_1", "mBg_2"},
        scale9Size = CCSizeMake(width, height),
        scale9Pos  = ccp(-width/2, -height/2),
        TxtNode    = {"mTxt_1", "mTxt_2"},
        TxtPosX    = 0,
        TxtName    = common:getLanguageString(cfg.Name),
        Btn        = "mBtn",
        BtnScaleX  = width / 50,
        BtnScaleY  = 1.5,
    }
    self:setTagContent(tag, option)
    tag.idx = index
    tag:registerFunctionHandler(function(eventName, container)
        if eventName == "onTag" then
            self:onTagClick(index)
        end
    end)
    return tag
end

-- 設定標籤內容樣式
function TowerPassPage:setTagContent(container, option)
    if option then
        for _, name in ipairs(option.scale9Name) do
            local node = container:getVarScale9Sprite(name)
            if node then
                node:setContentSize(option.scale9Size)
            end
            local varNode = container:getVarNode(name)
            if varNode then
                varNode:setPosition(option.scale9Pos)
            end
        end
        for _, name in ipairs(option.TxtNode) do
            NodeHelper:setStringForLabel(container, { [name] = option.TxtName })
        end
        if option.Btn then
            local btnNode = container:getVarNode(option.Btn)
            if btnNode then
                btnNode:setScaleX(option.BtnScaleX)
                btnNode:setScaleY(option.BtnScaleY)
            end
        end
    end
end

-- 標籤點擊事件
function TowerPassPage:onTagClick(index)
    Model.currentType = index
    Model.rechargeId = Model.cfg[Model.currentType].RechargeId or 1
    Model.scrollOffset = nil
    for id, container in pairs(Model.TagContainers) do
        local isChosen = (id == index)
        NodeHelper:setNodesVisible(container, { unSelect = not isChosen, Selected = isChosen })
    end
    self:onCurrentPage()
end

-- 更新通行證進度文字
function TowerPassPage:updatePassProgress(container)
    local data = Model.cfg[1]
    local nowPass = TowerPageData:getData(data.ActivityId, data._LimitType).MaxFloor or 0
    local progressStr = common:getLanguageString("@TotalPassStage", nowPass)
    NodeHelper:setStringForLabel(container, { mPassed = progressStr })
end

-- 封包處理：收到後更新數據與頁面
function TowerPassPage:onReceivePacket(packet)
    local opcode = packet.opcode
    local msgBuff = packet.msgBuff

    if opcode == HP_pb.SUPER_TOWER_PASS_S then
        local msg = Activity6_pb.SuperTowerPassRes()
        msg:ParseFromString(msgBuff)
        require("TowerPass.TowerPassData")
        TowerPass_SetInfo(msg)  -- 外部方法更新數據
        self:refresh(Model.container)
        self:refreshUI(Model.container)
        require("TransScenePopUp")
        TransScenePopUp_closePage()
        requesting = false
    elseif opcode == HP_pb.PLAYER_AWARD_S then
        PackageLogicForLua.PopUpReward(msgBuff)
    end
end

-- 點擊購買按鈕
function TowerPassPage:onBuy(container)
    Model.scrollOffset = Model.scrollview:getContentOffset()
    BuyItem(Model.rechargeId)
end

-- 空白執行函式（根據需求擴充）
function TowerPassPage:onExecute(container)
    -- 擴充其他邏輯
end

-- 頁面離開時清理工作
function TowerPassPage:onExit(container)
    Model.scrollOffset = nil
    parentPage:removePacket(OPCODES)
    Model.currentType = 1
    PageManager.refreshPage("MainScenePage", "refreshInfo")
end

-- 註冊需要監聽的封包
function TowerPassPage:registerPacket(container)
    for key, opcode in pairs(OPCODES) do
        if key:sub(-1) == "S" then
            container:registerPacket(opcode)
        end
    end
end

-- 移除監聽封包
function TowerPassPage:removePacket(container)
    for key, opcode in pairs(OPCODES) do
        if key:sub(-1) == "S" then
            container:removePacket(opcode)
        end
    end
end
function TowerPassPage:onHelp(container)
    PageManager.showHelp(GameConfig.HelpKey.HELP_CLIMB_TOWER)
end
-- 初始進入頁面時：如果 serverData 不存在則請求
function TowerPassPage:onCurrentPage()
    Model.serverData = TowerPassData:getData(Model.rechargeId)
    if not Model.serverData then
        local msg = Activity6_pb.SuperTowerPassReq()
        msg.action = 0
        msg.rechargeId = Model.rechargeId
        local pb = msg:SerializeToString()
        PacketManager:getInstance():sendPakcet(HP_pb.SUPER_TOWER_PASS_C, pb, #pb, true)
    else
        require("TransScenePopUp")
        TransScenePopUp_closePage()
        self:refresh(Model.container)
        self:refreshUI(Model.container)
    end
end

-- 接收系統訊息處理（例如儲值成功）
function TowerPassPage:onReceiveMessage(message)
    local typeId = message:getTypeId()
    if typeId == MSG_RECHARGE_SUCCESS then
        CCLuaLog("TowerPassPage 收到儲值成功訊息")
        if not requesting then
            local msg = Activity6_pb.SuperTowerPassReq()
            msg.action = 0
            msg.rechargeId = Model.rechargeId
            local pb = msg:SerializeToString()
            PacketManager:getInstance():sendPakcet(HP_pb.SUPER_TOWER_PASS_C, pb, #pb, true)
            requesting = true
        end
    end
end

-- 購買處理：獨立函式
function BuyItem(id)
    local itemInfo = nil
    for i = 1, #RechargeCfg do
        if tonumber(RechargeCfg[i].productId) == id then
            itemInfo = RechargeCfg[i]
            break
        end
    end

    if itemInfo then
        local buyInfo = BUYINFO:new()
        buyInfo.productType         = itemInfo.productType
        buyInfo.name                = itemInfo.name
        buyInfo.productCount        = 1
        buyInfo.productName         = itemInfo.productName
        buyInfo.productId           = itemInfo.productId
        buyInfo.productPrice        = itemInfo.productPrice
        buyInfo.productOrignalPrice = itemInfo.gold
        buyInfo.description         = itemInfo.description or ""
        buyInfo.serverTime          = GamePrecedure:getInstance():getServerTime()
        local extrasTable = {
            productType = tostring(itemInfo.productType),
            name        = itemInfo.name,
            ratio       = tostring(itemInfo.ratio)
        }
        buyInfo.extras = json.encode(extrasTable)
        BuyManager.Buy(UserInfo.playerInfo.playerId, buyInfo)
    else
        CCLuaLog("BuyItem Error: 商品資訊未找到！")
    end
end

--------------------------------------------------
-- 回傳模組
--------------------------------------------------
return TowerPassPage
