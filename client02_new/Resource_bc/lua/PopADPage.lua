local HP_pb = require("HP_pb") -- 包含协议id文件
local thisPageName = "PopADPage"

-- 这里是协议的 id
local opcodes = {}

local option = {
    ccbiFile = "LobbyPopout_01.ccbi",
    handlerMap = {
        onClose = "onClose",
        onJump = "onJump",
        onHelp = "onHelp"
    },
    opcode = opcodes
}

local PopADBase = {}
local rewardCellContent = { ccbiFile = "GoodsItem_2.ccbi" }

local JumpTarget = {
    [1] = { 
        fun = function()
            require("IAP.IAPSubPage_Recharge"):setEnterFun("onDay")
            require("IAP.IAPPage"):setEntrySubPage("Recharge")
            PageManager.pushPage("IAP.IAPPage")
        end,
        Cfg = ConfigManager.getRechargeDiscountCfg(),
        getReward = function(GiftCfg) return common:parseItemWithComma(GiftCfg.salepacket) end,
        getName =  function(GiftCfg) return GiftCfg.name end,
    },
    [2] = { 
        fun = function()
            require("IAP.IAPSubPage_Recharge"):setEnterFun("onWeek")
            require("IAP.IAPPage"):setEntrySubPage("Recharge")
            PageManager.pushPage("IAP.IAPPage")
        end,
        Cfg = ConfigManager.getRechargeDiscountCfg(),
        getReward = function(GiftCfg) return common:parseItemWithComma(GiftCfg.salepacket) end,
        getName =  function(GiftCfg) return GiftCfg.name end,
    },
    [3] = { 
        fun = function()
            require("IAP.IAPSubPage_Recharge"):setEnterFun("onMonth")
            require("IAP.IAPPage"):setEntrySubPage("Recharge")
            PageManager.pushPage("IAP.IAPPage")
        end,
        Cfg = ConfigManager.getRechargeDiscountCfg(),
        getReward = function(GiftCfg) return common:parseItemWithComma(GiftCfg.salepacket) end,
        getName =  function(GiftCfg) return GiftCfg.name end,
    },
    [4] = { 
        fun = function()
            require("IAP.IAPPage"):setEntrySubPage("StepBundle")
            PageManager.pushPage("IAP.IAPPage")
        end,
        Cfg = ConfigManager.getStepBundleCfg(),
        getReward = function(GiftCfg) return GiftCfg.reward end,
        getName =  function(GiftCfg) return "NoName" end,
    },
    [5] = { 
        fun = function()
            require("IAP.IAPPage"):setEntrySubPage("Subscription")
            PageManager.pushPage("IAP.IAPPage")
        end,
        Cfg = ConfigManager.getSubscription(),
        getReward = function(GiftCfg) return GiftCfg.DailyGift end,
        getName =  function(GiftCfg) return "NoName" end,
    },
    [6] = { 
        fun = function()
            PageManager.popPage(thisPageName)
        end,
        Cfg = ConfigManager.getPopUpCfg2(),
        getReward = function(GiftCfg) return GiftCfg.Reward end,
        getName =  function(GiftCfg) return GiftCfg.Title end,
    },
    [7] = { 
        fun = function()
            require("IAP_Act.IAP_ActPage"):setEntrySubPage("WishBundle")
            PageManager.pushPage("IAP_Act.IAP_ActPage")
        end,
        Cfg = ConfigManager.getPopUpCfg2(),
        getReward = function(GiftCfg) 
                        require("Act187_DataBase")
                        local RewardTable = Act187_DataBase_GetData(GameConfig.GIFT_TYPE.WISHINGWHEEL_GIFT)
                        return RewardTable[GiftCfg.GiftId] and GiftCfg.Reward or {}
                    end,
        getName =  function(GiftCfg) return GiftCfg.Title end,
    },
    [8] = { 
        fun = function()
            require("IAP_Act.IAP_ActPage"):setEntrySubPage("CycleGift")
            PageManager.pushPage("IAP_Act.IAP_ActPage")
        end,
        Cfg = ConfigManager.getPopUpCfg2(),
        getReward = function(GiftCfg) 
                        require("Act187_DataBase")
                        local RewardTable = Act187_DataBase_GetData(GameConfig.GIFT_TYPE.CYCLE_GIFT)
                        return RewardTable[GiftCfg.GiftId] and GiftCfg.Reward or {}
                    end,
        getName =  function(GiftCfg) return GiftCfg.Title end,
    },
    [9] = { 
        fun = function()
            require("IAP_Act.IAP_ActPage"):setEntrySubPage("SummonGift")
            PageManager.pushPage("IAP_Act.IAP_ActPage")
        end,
        Cfg = ConfigManager.getPopUpCfg2(),
        getReward = function(GiftCfg) 
                        require("Act187_DataBase")
                        local RewardTable = Act187_DataBase_GetData(GameConfig.GIFT_TYPE.SUMMON_GIFT)
                        return RewardTable[GiftCfg.GiftId] and GiftCfg.Reward or {}
                    end,
        getName =  function(GiftCfg) return GiftCfg.Title end,
    }, 
    [10] = { 
        fun = function()
            require("IAP.IAPPage"):setEntrySubPage("GiftShop")
            require("IAP.IAPSubPage_GiftShop"):setBundle(GameConfig.GIFT_TYPE.STARUP_GIFT)
            PageManager.pushPage("IAP.IAPPage")
        end,
        Cfg = ConfigManager.getPopUpCfg2(),
        getReward = function(GiftCfg) 
                        require("Act187_DataBase")
                        local RewardTable = Act187_DataBase_GetData(GameConfig.GIFT_TYPE.STARUP_GIFT)
                        return RewardTable[GiftCfg.GiftId] and GiftCfg.Reward or {}
                    end,
        getName =  function(GiftCfg) return GiftCfg.Title end,
    },
    [11] = { 
        fun = function()
            require("IAP.IAPPage"):setEntrySubPage("GiftShop")
            require("IAP.IAPSubPage_GiftShop"):setBundle(GameConfig.GIFT_TYPE.MEMORY_GIFT)
            PageManager.pushPage("IAP.IAPPage")
        end,
        Cfg = ConfigManager.getPopUpCfg2(),
        getReward = function(GiftCfg) 
                        require("Act187_DataBase")
                        local RewardTable = Act187_DataBase_GetData(GameConfig.GIFT_TYPE.MEMORY_GIFT)
                        return RewardTable[GiftCfg.GiftId] and GiftCfg.Reward or {}
                    end,
        getName =  function(GiftCfg) return GiftCfg.Title end,
    },
    [12] = { 
        fun = function()
            require("IAP.IAPPage"):setEntrySubPage("GiftShop")
            require("IAP.IAPSubPage_GiftShop"):setBundle(GameConfig.GIFT_TYPE.ROLE_GIFT)
            PageManager.pushPage("IAP.IAPPage")
        end,
        Cfg = ConfigManager.getPopUpCfg2(),
        getReward = function(GiftCfg) 
                        require("Act187_DataBase")
                        local RewardTable = Act187_DataBase_GetData(GameConfig.GIFT_TYPE.ROLE_GIFT)
                        return RewardTable[GiftCfg.GiftId] and GiftCfg.Reward or {}
                    end,
        getName =  function(GiftCfg) return GiftCfg.Title end,
    },
}


function PopADBase:getData()
    local PopCfgs = ConfigManager.getPopADCfg()
    local currentTime = os.time()
    local PopCfg

    -- 遍历 `PopCfgs`，找到第一个符合时间范围的 `PopCfg`
    for _, data in pairs(PopCfgs) do
        if currentTime > data.startTime and currentTime < data.endTime then
            PopCfg = data
            break
        end
    end

    if not (PopCfg and PopCfg.JumpId and PopCfg.GiftId) then
        print("Error: PopCfg is missing or invalid JumpId/GiftId")
        return nil, {}
    end

    local jumpTarget = JumpTarget[PopCfg.JumpId]
    local cfg = jumpTarget and jumpTarget.Cfg and jumpTarget.Cfg[PopCfg.GiftId]

    if not cfg then
        print(string.format("Warning: Invalid JumpId: %s, GiftId: %s", PopCfg.JumpId, PopCfg.GiftId))
        return PopCfg, {}
    end

    return PopCfg, cfg
end

function PopADBase:onEnter(container)
    local PopCfg, GiftCfg = self:getData()
    if not PopCfg then 
        PageManager.popPage(thisPageName)
        return
    end

    local JumpId = PopCfg.JumpId
    local reward = (JumpTarget[JumpId] and JumpTarget[JumpId].getReward) and JumpTarget[JumpId].getReward(GiftCfg) or {}

    -- 確保 reward 不為 nil
    reward = reward or {}

    local PackageName = (JumpTarget[JumpId] and JumpTarget[JumpId].getName) and JumpTarget[JumpId].getName(GiftCfg) or {}
    local Banner = PopCfg.PageBanner
    local Txt = common:getLanguageString(PopCfg.PageTxt)

    NodeHelper:setStringForLabel(container, { mGiftNane = PackageName, mTxt = Txt })
    NodeHelper:setSpriteImage(container, { mBanner = Banner })

    local scrollview = container:getVarScrollView("mContent")
    self:buildRewardCells(scrollview, reward, 0.7)
end


function PopADBase:buildRewardCells(scrollView, items, scale)
    scrollView:removeAllCell()
    local contentSize = 134 * scale

    for _, value in ipairs(items) do
        local cell = CCBFileCell:create()
        cell:setCCBFile(rewardCellContent.ccbiFile)
        cell:setScale(scale)
        cell:setContentSize(CCSizeMake(contentSize, contentSize))

        local panel = common:new({ rewardItem = value }, rewardCellContent)
        cell:registerFunctionHandler(panel)
        scrollView:addCell(cell)
    end

    scrollView:orderCCBFileCells()
    scrollView:setTouchEnabled(#items > 4)
end

function rewardCellContent:onRefreshContent(content)
    local container = content:getCCBFileNode()
    local ResManager = require("ResManagerForLua")
    local resInfo = ResManager:getResInfoByTypeAndId(self.rewardItem.type, self.rewardItem.itemId, self.rewardItem.count or 1)

    NodeHelper:setNodesVisible(container, { mStarNode = (self.rewardItem.type == 40000) })
    NodeHelper:setStringForLabel(container, { mNumber = resInfo.count > 0 and ("x" .. GameUtil:formatNumber(resInfo.count)) or "" })
    NodeHelper:setSpriteImage(container, { mPic = resInfo.icon }, { mPic = 1 })
    NodeHelper:setQualityFrames(container, { mHand = resInfo.quality })
    NodeHelper:setNodesVisible(container, { mName = false })
end

function rewardCellContent:onHand(container)
    GameUtil:showTip(container:getVarNode("mHand"), self.rewardItem)
end

function PopADBase:onClose(container)
    PageManager.popPage(thisPageName)
end

function PopADBase:onJump(container)
    local PopCfg = self:getData()
    if PopCfg and JumpTarget[PopCfg.JumpId] then
        JumpTarget[PopCfg.JumpId].fun()
        PageManager.popPage(thisPageName)
    end
end

local CommonPage = require("CommonPage")
local PopADPage = CommonPage.newSub(PopADBase, thisPageName, option)

return PopADPage
