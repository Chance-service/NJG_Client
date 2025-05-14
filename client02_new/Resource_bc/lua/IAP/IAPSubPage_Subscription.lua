local NodeHelper = require("NodeHelper")
local Activity_pb = require("Activity_pb")
local Activity4_pb = require("Activity4_pb")
local Activity5_pb = require("Activity5_pb")
local HP_pb = require("HP_pb")
local Recharge_pb = require("Recharge_pb")
local json = require("json")
local BuyManager = require("BuyManager")
local ExpeditionDataHelper = require("Activity.ExpeditionDataHelper")

local SubscriptionPage = {}
local SubscriptionItem = {}

local subscriptionCfg = ConfigManager.getSubscription()
local parentPage = nil
local requestingLastShop = false
local gotId = {}

local opcodes = {
    FETCH_SHOP_LIST_S = HP_pb.FETCH_SHOP_LIST_S,
    ACTIVITY168_SUBSCRIPTION_S = HP_pb.ACTIVITY168_SUBSCRIPTION_S,
    PLAYER_AWARD_S = HP_pb.PLAYER_AWARD_S,
    LAST_SHOP_ITEM_S = HP_pb.LAST_SHOP_ITEM_S
}

local option = {
    ccbiFile = "Subscripton.ccbi",
    handlerMap = {
        onBtnClick = "onBtnClick",
    },
}

local COUNTDOWN = {}

--------------------------------------------------------------------------------
-- Utility: 搜尋 RechargeCfg 中對應的產品資料
--------------------------------------------------------------------------------
local function getRechargeItemById(id)
    for _, item in ipairs(RechargeCfg or {}) do
        if tonumber(item.productId) == id then
            return item
        end
    end
    return nil
end

--------------------------------------------------------------------------------
-- 建立頁面
--------------------------------------------------------------------------------
function SubscriptionPage:createPage(_parentPage)
    parentPage = _parentPage
    local container = ScriptContentBase:create(option.ccbiFile)

    container:registerFunctionHandler(function(eventName, container)
        local func = self[option.handlerMap[eventName]]
        if func then func(self, container) end
    end)

    return container
end

function SubscriptionPage:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

--------------------------------------------------------------------------------
-- 初始化
--------------------------------------------------------------------------------
function SubscriptionPage:onEnter(parentContainer)
    self.container = parentContainer
    parentPage:registerPacket(opcodes)
    parentPage:registerMessage(MSG_MAINFRAME_REFRESH)
    parentPage:registerMessage(MSG_RECHARGE_SUCCESS)
    requestingLastShop = false

    local scrollview = self.container:getVarScrollView("mContent")
    NodeHelper:autoAdjustResizeScrollview(scrollview)
    self:requestItemInfo()
end

--------------------------------------------------------------------------------
-- 請求伺服器訂閱資訊
--------------------------------------------------------------------------------
function SubscriptionPage:requestItemInfo()
    local msg = Activity5_pb.SubScriptionReq()
    msg.action = 0
    common:sendPacket(HP_pb.ACTIVITY168_SUBSCRIPTION_C, msg, true)
end

--------------------------------------------------------------------------------
-- 建立排序後的訂閱項目
--------------------------------------------------------------------------------
function SubscriptionPage:buildSubscriptionCfgList()
    local list = {}
    for _,data in pairs (subscriptionCfg) do
        table.insert(list, data)
    end
    table.sort(list, function(a, b) return a.id < b.id end)
    return list
end

--------------------------------------------------------------------------------
-- 更新畫面內容
--------------------------------------------------------------------------------
function SubscriptionPage:refresh(container)
    parentPage:updateCurrency()
    local scrollview = container:getVarScrollView("mContent")
    scrollview:removeAllCell()

    local cfgList = self:buildSubscriptionCfgList()
   
    local totalHeight = 0

    for _, cfg in ipairs(cfgList) do
        local cell = CCBFileCell:create()
        cell:setCCBFile("SubscriptonContent_02.ccbi")

        local cellHeight = cell:getContentSize().height
        cell:setContentSize(CCSize(cell:getContentSize().width, cellHeight + 10))
        cell:setPositionX(10)

        local panel = common:new({ id = cfg.id }, SubscriptionItem)
        cell:registerFunctionHandler(panel)
        scrollview:addCell(cell)

        totalHeight = totalHeight + cellHeight + 20
    end

    scrollview:setTouchEnabled(true)
    scrollview:setContentSize(CCSize(scrollview:getContentSize().width, totalHeight))
    scrollview:orderCCBFileCells()
end

--------------------------------------------------------------------------------
-- 處理伺服器返回資料
--------------------------------------------------------------------------------
function SubscriptionPage:onReceivePacket(packet)
    local opcode = packet.opcode
    local msgBuff = packet.msgBuff

    if opcode == HP_pb.ACTIVITY168_SUBSCRIPTION_S then
        local msg = Activity5_pb.SubScriptionResp()
        msg:ParseFromString(msgBuff)
        gotId.status, gotId.leftTime = {}, {}

        for k, _ in pairs(subscriptionCfg) do
            gotId.status[k] = 0
        end

        for _, data in ipairs(msg.Info) do
            gotId.status[data.activateId] = 1
            gotId.leftTime[data.activateId] = data.leftTimes
        end

        self:refresh(self.container)
    elseif opcode == HP_pb.PLAYER_AWARD_S then
        local PackageLogicForLua = require("PackageLogicForLua")
        PackageLogicForLua.PopUpReward(msgBuff)
    elseif opcode == HP_pb.LAST_SHOP_ITEM_S then
        requestingLastShop = false
        local msg = Recharge_pb.LastGoodsItem()
        msg:ParseFromString(msgBuff)

        if msg.Items == "" then return end
        if string.find(msg.Items, "@") then
            local title = common:getLanguageString("@Subscription168_title")
            local content = common:getLanguageString(msg.Items)
            PageManager.showConfirm(title, content, function(isSure) end, true, nil, nil, false, 0.9)
        end
    end
end

--------------------------------------------------------------------------------
-- 處理消息
--------------------------------------------------------------------------------
function SubscriptionPage:onReceiveMessage(message)
    if message:getTypeId() == MSG_RECHARGE_SUCCESS then
        if requestingLastShop then return end
        self:requestItemInfo()
        common:sendEmptyPacket(HP_pb.LAST_SHOP_ITEM_C, true)
    end
end

function SubscriptionPage:onExit()
    parentPage:removePacket(opcodes)
    gotId = {}
    PageManager.refreshPage("MainScenePage", "refreshInfo")
    for _,data in pairs (COUNTDOWN) do
        CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(data)
        data = nil
    end
    COUNTDOWN = {}
end

--------------------------------------------------------------------------------
-- SubscriptionItem 控制
--------------------------------------------------------------------------------
function SubscriptionItem:onRefreshContent(content)
    local container = content:getCCBFileNode()
    local info = subscriptionCfg[self.id]
    local key = string.sub(self.id, -1)

    -- 設定圖示與價格文字
    NodeHelper:setSpriteImage(container, {
        mIcon = info.BG
    })

    NodeHelper:setStringForLabel(container, {
        mTxt = common:getLanguageString(info.Title),
        mCost = self:getPrice(self.id)
    })

    -- 顯示購買與每日禮包物品
    self:addItems(container, "mItem1", info.OnBuy, self.id)
    self:addItems(container, "mItem2", info.DailyGift, self.id)

    local isBuy = gotId.status[self.id] == 1

    -- 控制購買狀態相關節點
    NodeHelper:setNodesVisible(container, {
        mCost = not isBuy, mCoin = not isBuy, mBtnTxt = isBuy, mBuyMask = isBuy
    })
    NodeHelper:setStringForLabel(container, {
        mBtnTxt = common:getLanguageString("@HasBuy")
    })
    NodeHelper:setNodeIsGray(container, { mBtn = not isBuy })
    NodeHelper:setMenuItemsEnabled(container, { mBtn = not isBuy })

    -- 僅當購買後才啟動倒數邏輯
    if isBuy then
        local leftTime = gotId.leftTime[self.id] or 0

        -- 清理舊 scheduler
        if COUNTDOWN[self.id] then
            CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(COUNTDOWN[self.id])
            COUNTDOWN[self.id] = nil
        end

        -- 啟動倒數
        COUNTDOWN[self.id] = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(function()
            leftTime = leftTime - 1
            if leftTime <= 0 then
                CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(COUNTDOWN[self.id])
                COUNTDOWN[self.id] = nil
                NodeHelper:setStringForLabel(container, { mCountDown = "" })
                return
            end

            local hms = Split(GameMaths:formatSecondsToTime(leftTime), ":")
            local days = math.floor(tonumber(hms[1]) / 24)
            local showTxt
            if days < 1 then
                showTxt = common:getLanguageString("@GVGCountDownTxt", hms[1], hms[2], hms[3])
            else
                showTxt = common:getLanguageString("@LuckyMercenaryCloseTime", days) .. common:getLanguageString("@Days")
            end
            NodeHelper:setStringForLabel(container, { mCountDown = showTxt })
        end, 1.0, false)
    else
        -- 如果未購買，顯示空倒數字串（或預設提示）
        NodeHelper:setStringForLabel(container, { mCountDown = "" })
    end
end



function SubscriptionItem:addItems(container, nodeName, itemList, id)
    local parentNode = container:getVarNode(nodeName)
    if not parentNode then return end

    parentNode:removeAllChildren()
    local row = ScriptContentBase:create("ItemsRow")
    parentNode:addChild(row)

    row:registerFunctionHandler(function(eventName, child)
        local idx = tonumber(eventName:match("(%d+)$"))
        if idx and itemList[idx] then
            self:onShowItemInfo(child, itemList[idx], idx)
        end
    end)

    self:fillContent(row, itemList, id)
end

function SubscriptionItem:fillContent(container, items, id)
    local visibleNodes, strMap, imgMap, qualityMap, colorMap, handMap = {}, {}, {}, {}, {}, {}
    for i = 1, 4 do visibleNodes["mRewardNode" .. i] = false end

    for i, cfg in ipairs(items) do
        if cfg then
            local res = ResManagerForLua:getResInfoByTypeAndId(cfg.type, cfg.itemId, cfg.count)
            if res then
                visibleNodes["mRewardNode" .. i] = true
                strMap["mNum" .. i] = GameUtil:formatNumber(cfg.count)
                strMap["mName" .. i] = res.name
                imgMap["mPic" .. i] = res.icon
                qualityMap["mFrame" .. i] = res.quality
                handMap["mHand" .. i] = res.quality
                colorMap["mName" .. i] = ConfigManager.getQualityColor()[res.quality].textColor
                visibleNodes["mMask" .. i] = false
            else
                CCLuaLog("Error: reward item not found")
            end
        end
    end

    NodeHelper:setNodesVisible(container, visibleNodes)
    NodeHelper:setStringForLabel(container, strMap)
    NodeHelper:setSpriteImage(container, imgMap)
    NodeHelper:setImgBgQualityFrames(container, qualityMap)
    NodeHelper:setQualityFrames(container, handMap)
    NodeHelper:setColorForLabel(container, colorMap)
end

function SubscriptionItem:onShowItemInfo(container, data, idx)
    GameUtil:showTip(container:getVarNode("mPic" .. idx), data)
end

function SubscriptionItem:onBtnClick()
    BuyItem(self.id)
end

function SubscriptionItem:getPrice(id)
    local item = getRechargeItemById(id)
    return item and item.productPrice or 0
end

--------------------------------------------------------------------------------
-- 購買流程
--------------------------------------------------------------------------------
function BuyItem(id)
    local item = getRechargeItemById(id)
    if not item then return end

    local buyInfo = BUYINFO:new()
    buyInfo.productType = item.productType
    buyInfo.name = item.name
    buyInfo.productCount = 1
    buyInfo.productName = item.productName
    buyInfo.productId = item.productId
    buyInfo.productPrice = item.productPrice
    buyInfo.productOrignalPrice = item.gold
    buyInfo.description = item:HasField("description") and item.description or ""
    buyInfo.serverTime = GamePrecedure:getInstance():getServerTime()

    local extras = {
        productType = tostring(item.productType),
        name = item.name,
        ratio = tostring(item.ratio)
    }
    buyInfo.extras = json.encode(extras)

    BuyManager.Buy(UserInfo.playerInfo.playerId, buyInfo)
end

return SubscriptionPage
