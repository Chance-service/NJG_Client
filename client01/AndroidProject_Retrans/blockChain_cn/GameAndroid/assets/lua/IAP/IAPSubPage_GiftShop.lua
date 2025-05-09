local GiftShopPage = {}

-- 模組引用
local NodeHelper         = require("NodeHelper")
local HP_pb              = require("HP_pb")
local UserInfo           = require("PlayerInfo.UserInfo")
local Activity_pb        = require("Activity_pb")
local Const_pb           = require("Const_pb")
local ActivityFunction   = require("ActivityFunction")
local TimeDateUtil       = require("Util.TimeDateUtil")
local CommTabStorage     = require("CommComp.CommTabStorage")
local Recharge_pb        = require("Recharge_pb")
local BuyManager         = require("BuyManager")
local json               = require("json")
local common             = require("common")
local ConfigManager      = require("ConfigManager")
local PageManager        = require("PageManager")
local ResManagerForLua   = require("ResManagerForLua")
local Activity5_pb       = require("Activity5_pb")
local Act187_DataBase    = require("Act187_DataBase")

-- 常數設定與配置
local rechargeCfg = RechargeCfg
local option = {
    ccbiFile = "FragmentsBundle.ccbi",
    handlerMap = {
        onHelp   = "onHelp",
        onStarUp = "onStarUp",
        onMemory = "onMemory",
        onRole   = "onRole"
    }
}
local opcodes = { LAST_SHOP_ITEM_S = HP_pb.LAST_SHOP_ITEM_S }

-- 禮包配置初始化：STARUP, ROLE, MEMORY
local Bundles = {}
for _, key in ipairs({ "STARUP_GIFT", "ROLE_GIFT", "MEMORY_GIFT" }) do
    local bundleType = GameConfig.GIFT_TYPE[key]
    Bundles[bundleType] = { cfg = {} }
end

-- 資源與狀態變數
local SaleContent      = { ccbiFile = "DailyBundleShopContent.ccbi" }
local curBundle        = GameConfig.GIFT_TYPE.ROLE_GIFT
local _serverData      = {}
local mainContainer    = nil
local parentPage       = nil
local isRequesting     = false
local CountDown = nil
local scrollOffset = nil
------------------------------------------------------------
-- GiftShopPage 類別初始化
------------------------------------------------------------
function GiftShopPage:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

------------------------------------------------------------
-- 建立頁面（並註冊事件處理函式）
------------------------------------------------------------
function GiftShopPage:createPage(_parentPage)
    parentPage = _parentPage
    local container = ScriptContentBase:create(option.ccbiFile)
    container:registerFunctionHandler(function(eventName, container)
        local func = self[option.handlerMap[eventName]]
        if func then func(self, container) end
    end)
    return container
end

------------------------------------------------------------
-- 將所有禮包資料分配到各 Bundle 中
------------------------------------------------------------
function GiftShopPage:prepareGiftCfg()
    local allCfg = ConfigManager.getPopUpCfg2()
    for id, data in pairs(allCfg) do
        if Bundles[data.type] then
            Bundles[data.type].cfg[id] = data
        end
    end
end

------------------------------------------------------------
-- 發送請求取得當前禮包資料
------------------------------------------------------------
function GiftShopPage:ItemInfoRequest()
    isRequesting = true
    local msg = Activity5_pb.MaxJumpGiftReq()
    msg.action = 0
    msg.type   = curBundle
    common:sendPacket(HP_pb.ACTIVITY187_MAXJUMP_GIFT_C, msg, false)
end

------------------------------------------------------------
-- 進入頁面時初始化資料與 UI
------------------------------------------------------------
function GiftShopPage:onEnter(container)
    mainContainer = container
    self:prepareGiftCfg()
    if parentPage then
        parentPage:registerMessage(MSG_RECHARGE_SUCCESS)
        parentPage:registerPacket(opcodes)
    end

    CountDown = nil
    NodeHelper:setStringForLabel(container, { mEmpty = "" ,refreshAutoCountdownText = "---"})

    _serverData = Act187_DataBase_GetData(curBundle)
    self:initUI()
end

------------------------------------------------------------
-- 當收到訊息（例如充值成功）時刷新資料
------------------------------------------------------------
function GiftShopPage:onReceiveMessage(message)
    local typeId = message:getTypeId()
    if typeId == MSG_RECHARGE_SUCCESS then
        self:ItemInfoRequest()
        common:sendEmptyPacket(HP_pb.LAST_SHOP_ITEM_C, true)
    end
end

------------------------------------------------------------
-- 當收到封包（例如商品列表更新）時處理
------------------------------------------------------------
function GiftShopPage:onReceivePacket(packet)
    if packet.opcode == HP_pb.LAST_SHOP_ITEM_S then
        requestingLastShop = false
        local msg = Recharge_pb.LastGoodsItem()
        msg:ParseFromString(packet.msgBuff)
        if msg.Items == "" then return end
        local Items = common:parseItemWithComma(msg.Items)
        if next(Items) then
            local CommonRewardPage = require("CommPop.CommItemReceivePage")
            CommonRewardPage:setData(Items, common:getLanguageString("@ItemObtainded"), nil)
            PageManager.pushPage("CommPop.CommItemReceivePage")
        end
    end
end

------------------------------------------------------------
-- 退出頁面（預留擴展）
------------------------------------------------------------
function GiftShopPage:onExit()
    if CountDown then
        CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(CountDown)
        CountDown = nil
    end
end

------------------------------------------------------------
-- 每幀執行（例如倒數時間更新）
------------------------------------------------------------
function GiftShopPage:onExecute()
    if not mainContainer then return end
    local now = os.time()
    for id, data in pairs(_serverData) do
        if data.limitDate and now >= data.limitDate then
            self:ItemInfoRequest()
            break
        end
    end
end

------------------------------------------------------------
-- 更新頁面頂部動畫與按鈕狀態
------------------------------------------------------------
function GiftShopPage:updateHeaderUI(container)
    local aniMap = {
        [GameConfig.GIFT_TYPE.STARUP_GIFT] = "Default Upstars",
        [GameConfig.GIFT_TYPE.ROLE_GIFT]   = "Default Char",
        [GameConfig.GIFT_TYPE.MEMORY_GIFT] = "Default Memory"
    }
    local menuMap = {
        [GameConfig.GIFT_TYPE.STARUP_GIFT] = { mRole = true,  mMemory = true,  mStarUp = false },
        [GameConfig.GIFT_TYPE.ROLE_GIFT]   = { mRole = false, mMemory = true,  mStarUp = true  },
        [GameConfig.GIFT_TYPE.MEMORY_GIFT] = { mRole = true,  mMemory = false, mStarUp = true  }
    }

    local titleStr = {
        [GameConfig.GIFT_TYPE.ROLE_GIFT] = "@CharacterBundle",
        [GameConfig.GIFT_TYPE.MEMORY_GIFT] = "@AncientWeaponBundle",
        [GameConfig.GIFT_TYPE.STARUP_GIFT] = "@2001Bundle",
    }

    container:runAnimation(aniMap[curBundle] or "Default Timeline")
    NodeHelper:setMenuItemsEnabled(container, menuMap[curBundle] or {})
    parentPage.tabStorage:setTitle (titleStr[curBundle])

    local scheduler = CCDirector:sharedDirector():getScheduler()
    local _, firstData = next(_serverData)
    if not firstData then
        NodeHelper:setStringForLabel(container, {refreshAutoCountdownText = "---"})
        if CountDown then
            NodeHelper:setNodesVisible(container, {refreshAuto = true})
            scheduler:unscheduleScriptEntry(CountDown)
            CountDown = nil
        end
        return
    end
    
    local leftTime = firstData.limitDate - os.time()
   
    
    -- 取消之前的倒計時
    if CountDown then
        scheduler:unscheduleScriptEntry(CountDown)
        CountDown = nil
    end
    if leftTime > 86400*60 then
        NodeHelper:setNodesVisible(container, {refreshAuto = false})
        return
    else
        NodeHelper:setNodesVisible(container, {refreshAuto = true})
    end

    CountDown = scheduler:scheduleScriptFunc(function()
        leftTime = leftTime - 0.1

        local txt = common:second2DateString(leftTime, leftTime < 86400)
        NodeHelper:setStringForLabel(container, {refreshAutoCountdownText = txt})
        
        -- 當倒計時結束時，取消調度
        if leftTime <= 0 then
            scheduler:unscheduleScriptEntry(CountDown)
            CountDown = nil
        end
    end, 0.1, false)
end

------------------------------------------------------------
-- 刷新 ScrollView 區域
------------------------------------------------------------
function GiftShopPage:refreshScroll(container)
    local scroll = container:getVarScrollView("mContent")
    if not scroll then return end
    scroll:removeAllCell()
    local count = 0
    local cfg = {}
    for _,info in pairs (Bundles[curBundle].cfg) do
        table.insert (cfg,info)
    end
    table.sort(cfg,function(a,b) return a.Sort < b.Sort end)
    for _, data in ipairs(cfg) do
        local _id = data.GiftId
        if _serverData[_id] then
            count = count + 1
            local cell = CCBFileCell:create()
            cell:setCCBFile(SaleContent.ccbiFile)
            local panel = common:new({ id = _id, container = cell }, SaleContent)
            cell:registerFunctionHandler(panel)
            scroll:addCell(cell)
        end
    end
    NodeHelper:setStringForLabel(container, { mEmpty = count > 0 and "" or common:getLanguageString("@Empty") })
    scroll:setTouchEnabled(true)
    if scrollOffset then
        scroll:setContentOffset(scrollOffset)
        scrollOffset = nil
    end
    scroll:orderCCBFileCells()
end

------------------------------------------------------------
-- 初始化 UI：更新 header 與 scroll 區域
------------------------------------------------------------
function GiftShopPage:initUI()
    self:updateHeaderUI(mainContainer)
    self:refreshScroll(mainContainer)
end

------------------------------------------------------------
-- 切換禮包頁籤（共用函數）
------------------------------------------------------------
function GiftShopPage:switchBundle(newBundle)
    if isRequesting then return end
    curBundle   = newBundle
    _serverData = Act187_DataBase_GetData(curBundle)
    self:initUI()
end
function GiftShopPage:setBundle(newBundle)
    curBundle   = newBundle
end

local bundleMapping = {
    onRole   = GameConfig.GIFT_TYPE.ROLE_GIFT,
    onMemory = GameConfig.GIFT_TYPE.MEMORY_GIFT,
    onStarUp = GameConfig.GIFT_TYPE.STARUP_GIFT,
}

for funcName, giftType in pairs(bundleMapping) do
    GiftShopPage[funcName] = function(self)
        self:switchBundle(giftType)
    end
end


------------------------------------------------------------
-- 更新伺服器回傳資料後刷新 UI
------------------------------------------------------------
function GiftShopPage:setServerData(data)
    _serverData = data
    self:initUI()
    isRequesting = false
end

------------------------------------------------------------
-- 建立商品價格快取表（減少重複迴圈查找）
------------------------------------------------------------
local priceMap = {}
for _, item in ipairs(rechargeCfg) do
    priceMap[tonumber(item.productId)] = item.productPrice or 0
end

------------------------------------------------------------
-- SaleContent：UI cell 相關邏輯
------------------------------------------------------------
function SaleContent:onRefreshContent(content)
    local container = content:getCCBFileNode()
    local item  = Bundles[curBundle].cfg[self.id]
    local data  = _serverData[self.id] or { buyCount = 0, isGot = false }
    
    if item.Reward then
        self:fillRewardItem(container, item.Reward, #item.Reward)
    end

    NodeHelper:setNodesVisible(container, {
        mSold    = data.isGot,
        mCoin    = not data.isGot,
        mCost    = not data.isGot,
        mBtn     = not data.isGot,
        mCount   = not data.isGot,
        mReceive = false,
        mPoint   = false,
    })

    local leftAmount = (item.Count or 0) - (data.buyCount or 0)
    local leftStr    = common:getLanguageString("@Shop.Item.leftAmount", leftAmount, item.Count or 0)
    NodeHelper:setStringForLabel(container, {
        mTitle = item.Title,
        mCount = leftStr,
        mCost  = tonumber(self:getPrice(self.id))
    })
end

function SaleContent:getPrice(id)
    return priceMap[tonumber(id)] or 0
end

------------------------------------------------------------
-- 填充 cell 中的獎勵圖示
------------------------------------------------------------
function SaleContent:fillRewardItem(container, items, maxSize, isShowNum)
    maxSize   = maxSize or 4
    isShowNum = isShowNum or false
    local nodes, labels, sprites, qualities, colors, hands = {}, {}, {}, {}, {}, {}
    
    -- 初始化所有獎勵節點為隱藏
    for i = 1, 4 do
        nodes["mRewardNode" .. i] = false
    end

    for i = 1, maxSize do
        local cfg = items[i]
        nodes["mRewardNode" .. i] = (cfg ~= nil)
        if cfg then
            local res = ResManagerForLua:getResInfoByTypeAndId(cfg.type, cfg.itemId, cfg.count)
            if res then
                sprites["mPic" .. i]     = res.icon
                labels["mNum" .. i]      = GameUtil:formatNumber(cfg.count)
                labels["mName" .. i]     = res.name
                qualities["mFrame" .. i] = res.quality
                hands["mHand" .. i]      = res.quality
                colors["mName" .. i]     = ConfigManager.getQualityColor()[res.quality].textColor
                if isShowNum then
                    labels["mNum" .. i] = (res.count or 0) .. "/" .. cfg.count
                end
            end
        end
    end

    NodeHelper:setNodesVisible(container, nodes)
    NodeHelper:setStringForLabel(container, labels)
    NodeHelper:setSpriteImage(container, sprites)
    NodeHelper:setImgBgQualityFrames(container, qualities)
    NodeHelper:setQualityFrames(container, hands)
    NodeHelper:setColorForLabel(container, colors)
end

------------------------------------------------------------
-- 購買按鈕點擊事件
------------------------------------------------------------
function SaleContent:onBtn()
    if not _serverData[self.id] or _serverData[self.id].isGot or isRequesting then return end
    local scroll = mainContainer:getVarScrollView("mContent")
    scrollOffset = scroll:getContentOffset()
    BuyItem(tonumber(self.id))
end

------------------------------------------------------------
-- 點擊道具圖示顯示詳情
------------------------------------------------------------
for i = 1, 4 do
    SaleContent["onFrame" .. i] = function(self, cell)
        SaleContent:onShowItemInfo(cell, self.id, i)
    end
end

function SaleContent:onShowItemInfo(cell, index, goodIndex)
    local rewards = Bundles[curBundle].cfg[index].Reward or {}
    if rewards[goodIndex] then
        GameUtil:showTip(cell:getVarNode('mPic' .. goodIndex), rewards[goodIndex])
    end
end

return GiftShopPage
