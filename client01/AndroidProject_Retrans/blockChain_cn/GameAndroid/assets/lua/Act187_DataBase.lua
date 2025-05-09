local HP_pb = require("HP_pb")
local thisPageName = "Act187_DataBase"
local Act187_DataBase = {}
local Act187_Data = {}

local option = {
    handlerMap = {},
    opcodes = {}
}

local GiftShopTypes = {
   [GameConfig.GIFT_TYPE.MEMORY_GIFT] = true,
   [GameConfig.GIFT_TYPE.ROLE_GIFT] = true,
   [GameConfig.GIFT_TYPE.STARUP_GIFT] = true
}

local ActGiftShopTypes = {
   [GameConfig.GIFT_TYPE.CYCLE_GIFT] = true,
   [GameConfig.GIFT_TYPE.WISHINGWHEEL_GIFT] = true,
   [GameConfig.GIFT_TYPE.SUMMON_GIFT] = true
}

local cfgData = ConfigManager:getPopUpCfg2()

function Act187_DataBase_SetData(msg)
    local now = os.time()

    for _, itemData in ipairs(msg.info) do
        local goodsId = itemData.goodsId
        local cfg = cfgData[goodsId]
        local canBuyCount = (cfg and cfg.Count) or 1
        local goodsType = (cfg and cfg.type) or 0

        Act187_Data[goodsId] = {
            id = goodsId,
            buyCount = itemData.count,
            isGot = itemData.count >= canBuyCount,
            limitDate = itemData.leftTime + now,
            type = goodsType
        }
    end

    local giftType = msg.type    

    local data = Act187_DataBase_GetData(giftType == 0 and GameConfig.GIFT_TYPE.POPUP_GIFT or giftType)

    if giftType == GameConfig.GIFT_TYPE.POPUP_GIFT or giftType == 0 then
        require("ActPopUpSale.ActPopUpSaleSubPage_Content")
        ActPopUpSaleSubPage_Content_setServerData(data)
        PageManager.refreshPage("MainScenePage", "isShowActivity187Icon")
    elseif GiftShopTypes[giftType] then
        require("IAP.IAPSubPage_GiftShop"):setServerData(data)
    elseif ActGiftShopTypes[giftType] then
        require("IAP_Act.ActSubPage_Gift"):setServerData(data)
    end
end

function Act187_DataBase_GetData(_type)
    local _typeTable = {}
    for _, info in pairs(Act187_Data) do
        if info.type == _type then
            _typeTable[info.id] = info
        end
    end
    return _typeTable
end

function Act187_DataBase_GetActGiftlastTime()
    local minTime = nil
    for _, info in pairs(Act187_Data) do
        if ActGiftShopTypes[info.type] then
            if minTime == nil or info.limitDate < minTime then
                minTime = info.limitDate - os.time()
            end
        end
    end
    return minTime
end


local CommonPage = require("CommonPage")
local Act187_DataBase = CommonPage.newSub(Act187_DataBase, thisPageName, option)

return Act187_DataBase
