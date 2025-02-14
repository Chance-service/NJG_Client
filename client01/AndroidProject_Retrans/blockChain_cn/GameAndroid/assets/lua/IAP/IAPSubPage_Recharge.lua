-- 商城禮包
local NodeHelper = require("NodeHelper")
local HP_pb = require("HP_pb")
local UserInfo = require("PlayerInfo.UserInfo")
local Activity_pb = require("Activity_pb")
local Const_pb = require("Const_pb")
local NewbieGuideManager = require("NewbieGuideManager")
local ActivityFunction = require("ActivityFunction")
local TimeDateUtil = require("Util.TimeDateUtil")
local thisPageName = 'IAPSubPage_Recharge'
local CommTabStorage = require("CommComp.CommTabStorage")
local Recharge_pb = require("Recharge_pb")
local BuyManager = require("BuyManager")
local DiscountGiftPage = {}
local SaleContent = {}
local saleItems = { }

-----------------------------------------------
local SalepacketCfg = ConfigManager.getRechargeDiscountCfg()
local ChosenBundle = nil
local DailyBundle = {}
local WeeklyBundle = {}
local MonthlyBundle = {}
local BoughtNum = 0
local SeverDatas = {}
local timeStr = ""
local parentPage = nil
local requesting = false
-----------------------------------------------
local mCommTabStorage = nil
local selfContainer = nil

local currentScrollviewOffset = nil
-----------------------------------------------
local option = {
    ccbiFile = "DailyBundleShop.ccbi",
    handlerMap =
    {
        onHelp = "onHelp",
        onDay = "onDay",
        onWeek = "onWeek",
        onMonth = "onMonth",
    },
}

function DiscountGiftPage:createPage(_parentPage)
    
    local slf = self
    
    parentPage = _parentPage
    
    local container = ScriptContentBase:create(option.ccbiFile)
    selfContainer = container
    
    -- ���U �I�s�欰
    container:registerFunctionHandler(function(eventName, container)
        local funcName = option.handlerMap[eventName]
        local func = slf[funcName]
        if func then
            func(slf, container)
        end
    end)
    
    return container
end

function DiscountGiftPage:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end
local opcodes = {
    DISCOUNT_GIFT_INFO_S = HP_pb.DISCOUNT_GIFT_INFO_S,
    DISCOUNT_GIFT_BUY_SUCC_S = HP_pb.DISCOUNT_GIFT_BUY_SUCC_S,
    DISCOUNT_GIFT_GET_REWARD_S = HP_pb.DISCOUNT_GIFT_GET_REWARD_S,
    FETCH_SHOP_LIST_S = HP_pb.FETCH_SHOP_LIST_S,
    PLAYER_AWARD_S = HP_pb.PLAYER_AWARD_S,
}
function DiscountGiftPage:onEnter(Parentcontainer)
    self.container = Parentcontainer
    parentPage:registerPacket(opcodes)
    parentPage:registerMessage(MSG_MAINFRAME_REFRESH)
    parentPage:registerMessage(MSG_RECHARGE_SUCCESS)
    parentPage:registerMessage(MSG_REFRESH_REDPOINT)

    NodeHelper:setStringForLabel(Parentcontainer, {
        mDayTxt = common:getLanguageString("@DailyBundleText1"),
        mWeekTxt = common:getLanguageString("@DailyBundleText2"),
        mMonthTxt = common:getLanguageString("@DailyBundleText3")})
    
    --local msg = Recharge_pb.HPFetchRechargeCfg()
    --msg.platform = GameConfig.win32Platform
    --CCLuaLog("PlatformName2:" .. msg.platform)
    --pb_data = msg:SerializeToString()
    --PacketManager:getInstance():sendPakcet(HP_pb.FETCH_SHOP_LIST_C, pb_data, #pb_data, true)

    self:refreshAllPoint(self.container)
    requesting = false
    self:ItemInfoRequest()
end
function DiscountGiftPage:ItemInfoRequest()
    if not requesting then
        requesting = true
        local msg = Activity2_pb.DiscountInfoReq()
        msg.actId = Const_pb.DISCOUNT_GIFT
        common:sendPacket(HP_pb.DISCOUNT_GIFT_INFO_C, msg, true)
    end
end
function DiscountGiftPage:SetItemInfo()
    DailyBundle = {}
    WeeklyBundle = {}
    MonthlyBundle = {}
    for i, v in pairs(SeverDatas) do
        if SeverDatas[i] ~= nil then
            local tmp = SeverDatas[i].id
            if SalepacketCfg[tmp] then
             if SalepacketCfg[tmp].limitType == 1 then
                 table.insert(DailyBundle, SalepacketCfg[tmp]);
             elseif SalepacketCfg[tmp].limitType == 2 then
                 table.insert(WeeklyBundle, SalepacketCfg[tmp]);
             elseif SalepacketCfg[tmp].limitType == 4 then
                 table.insert(MonthlyBundle, SalepacketCfg[tmp]);
             end
            end
        end
    end
end
function DiscountGiftPage:onExit(container)
    currentScrollviewOffset = nil
    parentPage:removePacket(opcodes)
    ChosenBundle = nil
    DailyBundle = {}
    WeeklyBundle = {}
    MonthlyBundle = {}
    SeverDatas = {}
    PageManager.refreshPage("MainScenePage", "refreshInfo")
end
function DiscountGiftPage:onReceivePacket(packet)
    local opcode = packet.opcode
    local msgBuff = packet.msgBuff
    if opcode == HP_pb.DISCOUNT_GIFT_INFO_S then
        SeverDatas = {}
        local msg = Activity2_pb.HPDiscountInfoRet()
        msg:ParseFromString(msgBuff)
        local giftInfo = {}
        giftInfo = msg.info;
        for i = 1, #giftInfo do
            table.insert(SeverDatas, {
                id = giftInfo[i].goodsId,
                boughtTimes = giftInfo[i].buyTimes,
                status = giftInfo[i].status,
                countDown = giftInfo[i].countdownTime,
                refreshTime = giftInfo[i].refreshTime})
        end
         self:SetItemInfo()
        if ChosenBundle == nil then
            self:onDay(self.container)
        else
            self:refresh(self.container)
        end
        RedPointManager_refreshPageShowPoint(RedPointManager.PAGE_IDS.GOODS_DAILY_TAB, 1, msgBuff)
        RedPointManager_refreshPageShowPoint(RedPointManager.PAGE_IDS.GOODS_WEEKLY_TAB, 1, msgBuff)
        RedPointManager_refreshPageShowPoint(RedPointManager.PAGE_IDS.GOODS_MONTHLY_TAB, 1, msgBuff)
        self:refreshAllPoint(self.container)
        requesting = false
    end
    if packet.opcode == HP_pb.DISCOUNT_GIFT_BUY_SUCC_S then
        CCLuaLog("BuySuccessfull")
        self:ItemInfoRequest()
    end
    if packet.opcode == HP_pb.FETCH_SHOP_LIST_S then
        --local msg = Recharge_pb.HPRechargeCfgSync()
        --msg:ParseFromString(msgBuff)
        --RechargeCfg = msg.shopItems
        --if not RechargeCfg[1] then
        --    RechargeCfg=RechargeCfg
        --end
    end
    if packet.opcode == HP_pb.DISCOUNT_GIFT_GET_REWARD_S then
        self:ItemInfoRequest()
    end
    if opcode == HP_pb.PLAYER_AWARD_S then
        local PackageLogicForLua = require("PackageLogicForLua")
       PackageLogicForLua.PopUpReward(msgBuff)
    end
end
function DiscountGiftPage:onTimer(container)
    local remainTime = 0
    for i = 1, #ChosenBundle do
        for t = 1, #SeverDatas do
            if (ChosenBundle[i].id == SeverDatas[t].id) then
                remainTime = SeverDatas[t].refreshTime
                timeStr = common:second2DateString2(remainTime, false);
                NodeHelper:setStringForLabel(container, {refreshAutoCountdownText = timeStr})
                return
            end
        end
    end

end
function DiscountGiftPage:refresh(container)
    if ChosenBundle == nil then return end
    self:onTimer(container)
    parentPage:updateCurrency()
    if (ChosenBundle == DailyBundle) then
        NodeHelper:setMenuItemsEnabled(container, {mDay = false, mWeek = true, mMonth = true})
    elseif (ChosenBundle == WeeklyBundle) then
        NodeHelper:setMenuItemsEnabled(container, {mDay = true, mWeek = false, mMonth = true})
    elseif (ChosenBundle == MonthlyBundle) then
        NodeHelper:setMenuItemsEnabled(container, {mDay = true, mWeek = true, mMonth = false})
    end
    local scrollview = container:getVarScrollView("mContent")
    local contentH=0
    local count=#ChosenBundle
    scrollview:removeAllCell()
    saleItems = { }
    for i, v in pairs(ChosenBundle) do
        cell = CCBFileCell:create()
        cell:setCCBFile("DailyBundleShopContent.ccbi")
        cell:setContentSize(CCSize(cell:getContentSize().width, cell:getContentSize().height - 10))
        local panel = common:new({id = i}, SaleContent)
        contentH=cell:getContentSize().height
        cell:registerFunctionHandler(panel)
        scrollview:addCell(cell)
        local pos = ccp(0, cell:getContentSize().height * #ChosenBundle - cell:getContentSize().height * i)
        cell:setPosition(pos)
        table.insert(saleItems, cell)
    end
    local size = CCSizeMake(cell:getContentSize().width, cell:getContentSize().height * #ChosenBundle)
    scrollview:setContentSize(size)
    if not currentScrollviewOffset then
        scrollview:setContentOffset(ccp(0, scrollview:getViewSize().height - contentH*count-10))
    else
        scrollview:setContentOffset(currentScrollviewOffset)
    end
    scrollview:forceRecaculateChildren()
end
function DiscountGiftPage:onDay(container)
    if not DailyBundle then
        return
    end
    ChosenBundle = DailyBundle
    if not ChosenBundle then
        return
    end
    currentScrollviewOffset = nil
    NodeHelper:setNodesVisible(container, {mDayChosen = true,
        mWeekChosen = false,
        mMonthChosen = false,
        DayBanner = true,
        WeekBanner = false,
        MonthBanner = false,
        DayTitle = true,
        WeekTitle = false,
        MonthTitle = false})
    
    self:onTimer(container)
    self:refresh(self.container)
end
function DiscountGiftPage:onWeek(container)
    if not WeeklyBundle then
        return
    end
    ChosenBundle = WeeklyBundle
    if not ChosenBundle then
        return
    end
    currentScrollviewOffset = nil
    NodeHelper:setNodesVisible(container, {mDayChosen = false,
        mWeekChosen = true,
        mMonthChosen = false,
        DayBanner = false,
        WeekBanner = true,
        MonthBanner = false,
        DayTitle = false,
        WeekTitle = true,
        MonthTitle = false})
    
    self:onTimer(container)
    self:refresh(self.container)
end
function DiscountGiftPage:onMonth(container)
    if not MonthlyBundle then
        return
    end
    ChosenBundle = MonthlyBundle
    if not ChosenBundle then
        return
    end
    currentScrollviewOffset = nil
    NodeHelper:setNodesVisible(container, {mDayChosen = false,
        mWeekChosen = false,
        mMonthChosen = true,
        DayBanner = false,
        WeekBanner = false,
        MonthBanner = true,
        DayTitle = false,
        WeekTitle = false,
        MonthTitle = true})
    
    self:onTimer(container)
    self:refresh(self.container)
end
function DiscountGiftPage:registerPacket(container)
    for key, opcode in pairs(opcodes) do
        if string.sub(key, -1) == "S" then
            ParentContainer:registerPacket(opcode)
        end
    end
end
function DiscountGiftPage:removePacket(container)
    for key, opcode in pairs(opcodes) do
        if string.sub(key, -1) == "S" then
            ParentContainer:removePacket(opcode)
        end
    end
end
function DiscountGiftPage:onExecute(container)

end

function DiscountGiftPage:onReceiveMessage(message)
	local typeId = message:getTypeId()
	if typeId == MSG_RECHARGE_SUCCESS then
        CCLuaLog(">>>>>>onReceiveMessage DiscountGiftPage")
		self:ItemInfoRequest()
    elseif typeId == MSG_REFRESH_REDPOINT then
        self:refreshAllPoint(self.container)
	end
end

function DiscountGiftPage:refreshAllPoint(container)
    for k, v in pairs(saleItems) do
        SaleContent:refreshPoint(v, k)
    end
    NodeHelper:setNodesVisible(selfContainer, { mTabPoint1 = RedPointManager_getShowRedPoint(RedPointManager.PAGE_IDS.GOODS_DAILY_TAB) })
    NodeHelper:setNodesVisible(selfContainer, { mTabPoint2 = RedPointManager_getShowRedPoint(RedPointManager.PAGE_IDS.GOODS_WEEKLY_TAB) })
    NodeHelper:setNodesVisible(selfContainer, { mTabPoint3 = RedPointManager_getShowRedPoint(RedPointManager.PAGE_IDS.GOODS_MONTHLY_TAB) })
end

function DiscountGiftPage_calIsShowRedPoint(pageId, msgBuff)
    local msg = Activity2_pb.HPDiscountInfoRet()
    msg:ParseFromString(msgBuff)
    local giftInfo = { }
    SeverDatas = { }
    giftInfo = msg.info
    for i = 1, #giftInfo do
        table.insert(SeverDatas, {
            id = giftInfo[i].goodsId,
            boughtTimes = giftInfo[i].buyTimes,
            status = giftInfo[i].status,
            countDown = giftInfo[i].countdownTime,
            refreshTime = giftInfo[i].refreshTime
        })
    end
    DiscountGiftPage:SetItemInfo()
    local bundle = nil
    if pageId == RedPointManager.PAGE_IDS.DAILY_REWARD_BTN then
        bundle = DailyBundle
    elseif pageId == RedPointManager.PAGE_IDS.WEEKLY_REWARD_BTN then
        bundle = WeeklyBundle
    elseif pageId == RedPointManager.PAGE_IDS.MONTHLY_REWARD_BTN then
        bundle = MonthlyBundle
    end
    if bundle then
        for i, v in pairs(bundle) do
            local ItemInfo = bundle[i]
            local PackageId = ItemInfo.id
            local BoughtNum = 0
            if (tonumber(SaleContent:getPrice(PackageId)) <= 0) then
                for i = 1, #SeverDatas do
                    if (SeverDatas[i].id == PackageId) then
                        BoughtNum = SeverDatas[i].boughtTimes
                        break
                    end
                end
                if (ItemInfo.limitNum - BoughtNum) > 0 then
                    return true 
                end
            end
        end
    end
    return false
end

function SaleContent:refreshPoint(content, id)
    if not ChosenBundle then
        return
    end
    local container = content:getCCBFileNode()
    local ItemInfo = ChosenBundle[id]
    local PackageId = ItemInfo.id
    local BoughtNum = 0
    
    if (tonumber(SaleContent:getPrice(PackageId)) <= 0) then
        for i = 1, #SeverDatas do
            if (SeverDatas[i].id == PackageId) then
                BoughtNum = SeverDatas[i].boughtTimes
                break
            end
        end
        local isShow = ((ItemInfo.limitNum - BoughtNum) > 0)
        NodeHelper:setNodesVisible(container, { mPoint = isShow })
        if ChosenBundle == DailyBundle then
            RedPointManager_setShowRedPoint(RedPointManager.PAGE_IDS.DAILY_REWARD_BTN, 1, isShow)
        elseif ChosenBundle == WeeklyBundle then
            RedPointManager_setShowRedPoint(RedPointManager.PAGE_IDS.WEEKLY_REWARD_BTN, 1, isShow)
        elseif ChosenBundle == MonthlyBundle then
            RedPointManager_setShowRedPoint(RedPointManager.PAGE_IDS.MONTHLY_REWARD_BTN, 1, isShow)
        end
    end
end

function SaleContent:onRefreshContent(content)
    local container = content:getCCBFileNode()
    local ItemInfo = ChosenBundle[self.id]
    local packetItem = ItemInfo.salepacket
    local PackageId = ItemInfo.id
    local contentWidth = content:getContentSize().width
    if packetItem ~= nil then
        local rewardItems = {}
        local nNum = 0;
        local SalePrice = 0
        for _, item in ipairs(common:split(packetItem, ",")) do
            local _type, _id, _count = unpack(common:split(item, "_"));
            table.insert(rewardItems, {
                type = tonumber(_type),
                itemId = tonumber(_id),
                count = tonumber(_count)
            });
            nNum = nNum + 1;
        end
        SaleContent:fillRewardItem(container, rewardItems, nNum)
    end
    for i = 1, #SeverDatas do
        if (SeverDatas[i].id == PackageId) then
            BoughtNum = SeverDatas[i].boughtTimes
            if SeverDatas[i].status == 0 then
                NodeHelper:setNodeVisible(container:getVarNode("mSold"), true)
            elseif SeverDatas[i].status == 1 then
                NodeHelper:setNodesVisible(container, {mCoin = true, mCost = true, mReceive = false})
                NodeHelper:setNodeVisible(container:getVarNode("mSold"), false)
            elseif SeverDatas[i].status == 2 then
                NodeHelper:setNodesVisible(container, {mCoin = false, mCost = false, mReceive = true})
                NodeHelper:setNodeVisible(container:getVarNode("mSold"), false)
            end
            local isShow = ((ItemInfo.limitNum - BoughtNum) > 0) and (self:getPrice(PackageId) == 0)
            NodeHelper:setNodesVisible(container, { mPoint = isShow })
        end
    end
    local str = common:getLanguageString("@Shop.Item.leftAmount", ItemInfo.limitNum - BoughtNum, ItemInfo.limitNum)
    NodeHelper:setStringForLabel(container, {mTitle = ItemInfo.name, mCount = str, mCost = tonumber(self:getPrice(PackageId))})
end
function SaleContent:fillRewardItem(container, items, maxSize, isShowNum)
    local maxSize = maxSize or 4;
    isShowNum = isShowNum or false
    local nodesVisible = {};
    local lb2Str = {};
    local sprite2Img = {};
    local menu2Quality = {};
    local colorMap = {}
    local HandMap = {}
    for i = 1, 4 do
        nodesVisible["mRewardNode" .. i] = false
    end
    
    for i = 1, maxSize do
        local cfg = items[i];
        nodesVisible["mRewardNode" .. i] = cfg ~= nil;
        if cfg ~= nil then
            local resInfo = ResManagerForLua:getResInfoByTypeAndId(cfg.type, cfg.itemId, cfg.count);
            if resInfo ~= nil then
                sprite2Img["mPic" .. i] = resInfo.icon
                lb2Str["mNum" .. i] = GameUtil:formatNumber(cfg.count)
                lb2Str["mName" .. i] = resInfo.name;
                menu2Quality["mFrame" .. i] = resInfo.quality
                HandMap["mHand" .. i] = resInfo.quality
                colorMap["mName" .. i] = ConfigManager.getQualityColor()[resInfo.quality].textColor
                if isShowNum then
                    resInfo.count = resInfo.count or 0
                    lb2Str["mNum" .. i] = resInfo.count .. "/" .. cfg.count;
                end
            else
                CCLuaLog("Error::***reward item not found!!");
            end
        end
    end
    
    NodeHelper:setNodesVisible(container, nodesVisible);
    NodeHelper:setStringForLabel(container, lb2Str);
    NodeHelper:setSpriteImage(container, sprite2Img);
    NodeHelper:setImgBgQualityFrames(container, menu2Quality);
    NodeHelper:setQualityFrames(container, HandMap)
    NodeHelper:setColorForLabel(container, colorMap)
end
function SaleContent:onBtn(container)
    local scrollview = selfContainer:getVarScrollView("mContent")
    currentScrollviewOffset = scrollview:getContentOffset() 
    local ItemInfo = ChosenBundle[self.id]
    local id = ItemInfo.id
    for i = 1, #SeverDatas do
        if SeverDatas[i].id == id then
            if SeverDatas[i].status == 2 then
                local msg = Activity2_pb.HPDiscountGetRewardReq()
                msg.goodsId = id
                common:sendPacket(HP_pb.DISCOUNT_GIFT_GET_REWARD_C, msg, true)
                return;
            elseif SeverDatas[i].status == 0 then
                return
            else
                BuyItem(id)
            end
        end
    end 
end
function SaleContent:getPrice(id)
    local itemInfo = nil
    if not RechargeCfg then RechargeCfg = { } end
    for i = 1, #RechargeCfg do
        if tonumber(RechargeCfg[i].productId) == id then
            itemInfo = RechargeCfg[i]
            break
        end
    end
    
    return itemInfo and itemInfo.productPrice or 0
end
function BuyItem(id)
    local itemInfo = nil
    for i = 1, #RechargeCfg do
        if tonumber(RechargeCfg[i].productId) == id then
            itemInfo = RechargeCfg[i]
            break
        end
    end
    local buyInfo = BUYINFO:new()
    buyInfo.productType = itemInfo.productType
    buyInfo.name = itemInfo.name;
    buyInfo.productCount = 1
    buyInfo.productName = itemInfo.productName
    buyInfo.productId = itemInfo.productId
    buyInfo.productPrice = itemInfo.productPrice
    buyInfo.productOrignalPrice = itemInfo.gold
    
    buyInfo.description = ""
    if itemInfo:HasField("description") then
        buyInfo.description = itemInfo.description
    end
    buyInfo.serverTime = GamePrecedure:getInstance():getServerTime()
    
    local _type = tostring(itemInfo.productType)
    local _ratio = tostring(itemInfo.ratio)
    local extrasTable = {productType = _type, name = itemInfo.name, ratio = _ratio}
    buyInfo.extras = json.encode(extrasTable)
    
    BuyManager.Buy((UserInfo.playerInfo.playerId), buyInfo)
end
function SaleContent:onFrame1(container)
    SaleContent:onShowItemInfo(container, self.id, 1)
end
function SaleContent:onFrame2(container)
    SaleContent:onShowItemInfo(container, self.id, 2)
end
function SaleContent:onFrame3(container)
    SaleContent:onShowItemInfo(container, self.id, 3)
end
function SaleContent:onFrame4(container)
    SaleContent:onShowItemInfo(container, self.id, 4)
end
function SaleContent:onShowItemInfo(container, index, goodIndex)
    local packetItem = ChosenBundle[index].salepacket;
    local rewardItems = {}
    for _, item in ipairs(common:split(packetItem, ",")) do
        local _type, _id, _count = unpack(common:split(item, "_"));
        table.insert(rewardItems, {
            type = tonumber(_type),
            itemId = tonumber(_id),
            count = tonumber(_count)
        });
    end
    GameUtil:showTip(container:getVarNode('mPic' .. goodIndex), rewardItems[goodIndex])
end


return DiscountGiftPage
