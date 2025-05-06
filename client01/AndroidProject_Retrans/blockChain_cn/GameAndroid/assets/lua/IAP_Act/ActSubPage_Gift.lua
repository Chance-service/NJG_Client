local ActGiftPage = {}

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

-- 常數設定
local rechargeCfg = RechargeCfg
local option = {
    ccbiFile = "GachaBundle.ccbi",
    handlerMap = {
        onHelp   = "onHelp",
    }
}
local opcodes = { LAST_SHOP_ITEM_S = HP_pb.LAST_SHOP_ITEM_S }

-- 禮包配置初始化
local Bundles = {}
for _, key in ipairs({ "CYCLE_GIFT", "SUMMON_GIFT", "WISHINGWHEEL_GIFT" }) do
    local type = GameConfig.GIFT_TYPE[key]
    Bundles[type] = { cfg = {} }
end

-- 資源與狀態變數
local SaleContent = { ccbiFile = "DailyBundleShopContent.ccbi" }
local curBundle   = GameConfig.GIFT_TYPE.CYCLE_GIFT
local _serverData = {}
local mainContainer = nil
local CountDown = nil
local scrollOffset = nil

------------------------------------------------------------
-- 類初始化
------------------------------------------------------------
function ActGiftPage:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end

------------------------------------------------------------
-- 建立頁面（並註冊事件處理函式）
------------------------------------------------------------
function ActGiftPage:createPage(_parentPage)
    parentPage = _parentPage
    local container = ScriptContentBase:create(option.ccbiFile)
    container:registerFunctionHandler(function(eventName, container)
        local func = self[option.handlerMap[eventName]]
        if func then func(self, container) end
    end)
    return container
end

------------------------------------------------------------
-- 配置表處理：將所有禮包資料分配到各 Bundle 中
------------------------------------------------------------
function ActGiftPage:prepareGiftCfg()
    local allCfg = ConfigManager.getPopUpCfg2()
    for id, data in pairs(allCfg) do
        if Bundles[data.type] then
            Bundles[data.type].cfg[id] = data
        end
    end
end

------------------------------------------------------------
-- 禮包列表請求：發送請求取得當前禮包資料
------------------------------------------------------------
function ActGiftPage:ItemInfoRequest()
    local msg = Activity5_pb.MaxJumpGiftReq()
    msg.action = 0
    msg.type   = curBundle
    common:sendPacket(HP_pb.ACTIVITY187_MAXJUMP_GIFT_C, msg, false)
end

------------------------------------------------------------
-- 進入頁面
------------------------------------------------------------
function ActGiftPage:onEnter(container)
    mainContainer = container
    self:prepareGiftCfg()
    
    if parentPage then
        parentPage:registerMessage(MSG_RECHARGE_SUCCESS)
        parentPage:registerPacket(opcodes)
    end
    CountDown = nil
    NodeHelper:setStringForLabel(container, { mEmpty = "" ,refreshAutoCountdownText = "---"})
     require("Act187_DataBase")
     _serverData = Act187_DataBase_GetData(curBundle)
     self:initUI()
end

------------------------------------------------------------
-- 接收訊息（例如充值成功時刷新資料）
------------------------------------------------------------
function ActGiftPage:onReceiveMessage(message)
    local typeId = message:getTypeId()
    if typeId == MSG_RECHARGE_SUCCESS then
        self:ItemInfoRequest()
        common:sendEmptyPacket(HP_pb.LAST_SHOP_ITEM_C, true)
    end
end

function ActGiftPage:onReceivePacket(packet)
    local opcode = packet.opcode
    local msgBuff = packet.msgBuff
    if opcode == HP_pb.LAST_SHOP_ITEM_S then
        requestingLastShop = false
        local Recharge_pb = require("Recharge_pb")
        local msg = Recharge_pb.LastGoodsItem()
        msg:ParseFromString(msgBuff)
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
-- 退出頁面
------------------------------------------------------------
function ActGiftPage:onExit()
    if CountDown then
        CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(CountDown)
        CountDown = nil
    end
end

------------------------------------------------------------
-- 每幀執行（可加入倒數時間更新邏輯）
------------------------------------------------------------
function ActGiftPage:onExecute()
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
function ActGiftPage:updateHeaderUI(container)
    local aniMap = {
        [GameConfig.GIFT_TYPE.CYCLE_GIFT] = "OpenAni Story",
        [GameConfig.GIFT_TYPE.SUMMON_GIFT]   = "OpenAni Gacha",
        [GameConfig.GIFT_TYPE.WISHINGWHEEL_GIFT] = "OpenAni Star"
    }
    container:runAnimation(aniMap[curBundle] or "Default Timeline")
    
    local _, firstData = next(_serverData)
    if not firstData then
        NodeHelper:setStringForLabel(container, {refreshAutoCountdownText = "---"})
        return
    end
    
    local leftTime = firstData.limitDate - os.time()
    local scheduler = CCDirector:sharedDirector():getScheduler()
    
    -- 取消之前的倒計時
    if CountDown then
        scheduler:unscheduleScriptEntry(CountDown)
        CountDown = nil
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
function ActGiftPage:refreshScroll(container)
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
    if scrollOffset then
        scroll:setContentOffset(scrollOffset)
        scrollOffset = nil
    end
    scroll:setTouchEnabled(true)
    scroll:orderCCBFileCells()
end

------------------------------------------------------------
-- 初始化 UI（更新 header 與 scroll 區域）
------------------------------------------------------------
function ActGiftPage:initUI()
    self:refreshScroll(mainContainer)
    self:updateHeaderUI(mainContainer)
end

function ActGiftPage:setEnterIdx(idx)
    curBundle = idx
end

------------------------------------------------------------
-- 伺服器回傳資料設定
------------------------------------------------------------
function ActGiftPage:setServerData(data)
    _serverData = data
    self:initUI()
end

------------------------------------------------------------
-- 建立商品價格快取表（減少迴圈查找）
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
    maxSize  = maxSize or 4
    isShowNum = isShowNum or false
    local nodes, labels, sprites, qualities, colors, hands = {}, {}, {}, {}, {}, {}
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
-- 購買按鈕點擊邏輯
------------------------------------------------------------
function SaleContent:onBtn()
    if not _serverData[self.id] or _serverData[self.id].isGot then return end
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

return ActGiftPage
