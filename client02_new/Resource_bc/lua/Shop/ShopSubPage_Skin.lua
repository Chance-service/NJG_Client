----------------------------------------------------------------------------------

----------------------------------------------------------------------------------

local TimeDateUtil = require("Util.TimeDateUtil")

local ShopSubPage_Base = require("Shop.ShopSubPage_Base")
local ShopDataMgr = require("Shop.ShopDataMgr")
local InfoAccesser = require("Util.InfoAccesser")
-- 主體
local ShopSubPage_Skin = { }

local SaleContent = { ccbiFile = "SkinShopContent.ccbi" }

-- 建立
function ShopSubPage_Skin.new()

    -- 繼承自 基礎頁面
    Inst = ShopSubPage_Base.new()

    -- ##     ##    ###    ########  ####    ###    ########  ##       ######## 
    -- ##     ##   ## ##   ##     ##  ##    ## ##   ##     ## ##       ##       
    -- ##     ##  ##   ##  ##     ##  ##   ##   ##  ##     ## ##       ##       
    -- ##     ## ##     ## ########   ##  ##     ## ########  ##       ######   
    --  ##   ##  ######### ##   ##    ##  ######### ##     ## ##       ##       
    --   ## ##   ##     ## ##    ##   ##  ##     ## ##     ## ##       ##       
    --    ###    ##     ## ##     ## #### ##     ## ########  ######## ######## 

    -- 手動 紀錄 原腳本 相關
    Inst.SubPage_Base = { }

    -- overwrite ----

    -- new ----------
    Inst.skinShopCfg = ConfigManager.getSkinShopCfg()
    Inst.heroCfg = ConfigManager.getNewHeroCfg()
    Inst.skinCfg = ConfigManager.getSkinCfg()
    Inst.ownSkin = { }
    Inst.GOODS_TYPE = {
        BUY = 0,
        EVENT = 1,
    }
    Inst.PAGE_TYPE = {
        NORMAL = 0,
        EVENT = 1,
        ALL = 9,
    }
    Inst.nowPageType = Inst.PAGE_TYPE.ALL
    Inst.nowElement = 0
    Inst.nowClass = 0
    Inst.allCardItem = { }
    Inst.cardSize = CCSize(204, 369)
    Inst.filterOpenSize = CCSize(500, 142)
    Inst.filterCloseSize = CCSize(500, 74)
    -- 自動刷新 下次時間
    Inst.refreshAutoNextTime = -1
    
    -- 請求 冷卻時間 (幀)
    Inst.requestCooldownFrame = 60
    Inst.requestCooldownLeft = Inst.requestCooldownFrame

    -- #### ##    ## ######## ######## ########  ########    ###     ######  ######## 
    --  ##  ###   ##    ##    ##       ##     ## ##         ## ##   ##    ## ##       
    --  ##  ####  ##    ##    ##       ##     ## ##        ##   ##  ##       ##       
    --  ##  ## ## ##    ##    ######   ########  ######   ##     ## ##       ######   
    --  ##  ##  ####    ##    ##       ##   ##   ##       ######### ##       ##       
    --  ##  ##   ###    ##    ##       ##    ##  ##       ##     ## ##    ## ##       
    -- #### ##    ##    ##    ######## ##     ## ##       ##     ##  ######  ######## 

    --[[ 初始化 ]]
    -- Inst.SubPage_Base.init = Inst.init
    -- function Inst:init(shopInfo)
    --     Inst.SubPage_Base.init(self, shopInfo)
    -- end

    --[[ 當 進入頁面 ]]
    Inst.SubPage_Base.onEnter = Inst.onEnter
    function Inst:onEnter(parentContainer, controlPage)
        self.ccbiFile = "SkinShop.ccbi"
        -- 設置 父容器, 主頁面
        self.parentContainer = parentContainer
        self.controlPage = controlPage

        -- 以 ui檔 建立 並 設置 為 容器
        self.container = ScriptContentBase:create(self.ccbiFile)
        
        -- 註冊 呼叫 行為
        self.container:registerFunctionHandler(function (eventName, container)
            self:onFunction(eventName, container)
        end)

        self.mScrollView = self.container:getVarScrollView("mContent")

        self:initOwnSkin()
        self:closeFilter(self.container)
        self:filterSkinCard()
        self:settingFilterBtn(self.container)

        self.controlPage:requestPanelScrollView(true, {
            size = 1,
        })

        return self.container
    end

    --[[ 當 離開頁面 ]]
    Inst.SubPage_Base.onExit = Inst.onExit
    function Inst:onExit(parentContainer)
        self.nowPageType = self.PAGE_TYPE.ALL
        self.nowElement = 0
        self.nowClass = 0
        -- 取消設值 自動刷新UI
        self.controlPage.isRefreshAutoShowVals:set(nil, self)

        self.SubPage_Base.onExit(self, parentContainer)

        return self.container
    end

    --[[ 當 每幀 ]]
    Inst.SubPage_Base.onExecute = Inst.onExecute
    function Inst:onExecute(parentContainer)
        self.SubPage_Base.onExecute(self, parentContainer)
    end

    --[[ 按鈕邏輯 ]]
    Inst.SubPage_Base.onFunction = Inst.onFunction
    function Inst:onFunction(eventName, parentContainer)
        if eventName == "onFilter" then
            self:onFilter(self.container)
            return
        end
        local _type = tonumber(eventName:sub(-1))
        if string.find(eventName, "onElement") then
            Inst.nowElement = _type
        elseif string.find(eventName, "onClass") then
            Inst.nowClass = _type
        elseif string.find(eventName, "onSkin") then
            Inst.nowPageType = _type
        end
        self:filterSkinCard()
        self:settingFilterBtn(self.container)
        self.mScrollView:orderCCBFileCells()
    end

    --[[ 清除 所有商品 ]]
    Inst.SubPage_Base.clearAllItem = Inst.clearAllItem
    function Inst:clearAllItem()
        self.allCardItem = { }
        self.mScrollView:removeAllCell()
    end
    --[[ 組建 所有商品 ]]
    Inst.SubPage_Base.buildItem = Inst.buildItem
    function Inst:buildItem()
        if not self.mScrollView then return end
        local count = 0
        local cfg = { }
        for _, info in pairs (self.curPagePacketInfo.allItemInfo) do
            table.insert (cfg, info)
        end
        table.sort(cfg, function(a, b) 
            return Inst.skinShopCfg[a.id].Sort < Inst.skinShopCfg[b.id].Sort
        end)
        local idx = 0
        for _id, _data in ipairs(cfg) do
            if not Inst.ownSkin[Inst.skinShopCfg[_data.id].SkinId] then
                idx = idx + 1
                local cell = CCBFileCell:create()
                cell:setCCBFile(SaleContent.ccbiFile)
                local panel = common:new({ id = idx, data = _data, shopCfg = Inst.skinShopCfg[_data.id], heroCfg = Inst.heroCfg[Inst.skinShopCfg[_data.id].HeroId],
                                           shopType = Inst.skinShopCfg[_data.id].type, cfgIdx = _data.id }, SaleContent)
                cell:registerFunctionHandler(panel)
                self.mScrollView:addCell(cell)
                table.insert(self.allCardItem, { cell = cell, handler = panel })
            end
        end
        NodeHelper:setNodesVisible(self.container, { mEmptyNode = (idx <= 0) }) -- 沒有商品提示文字
        self.mScrollView:orderCCBFileCells()
        self.mScrollView:setTouchEnabled(true)
    end

    --[[ 當 接收協定封包 ]]
    Inst.SubPage_Base.onReceivePacket = Inst.onReceivePacket
    function Inst:onReceivePacket(parentContainer)
        local opcode = parentContainer:getRecPacketOpcode()
        local msgBuff = parentContainer:getRecPacketBuffer()
        if opcode == HP_pb.SHOP_BUY_S then
            MessageBoxPage:Msg_Box(common:getLanguageString("@BuyOK"))
            Inst:initOwnSkin()
        end
        -- 設置 當前頁面 封包
        self.curPagePacketInfo = ShopDataMgr:getPacketInfo(self.shopType)
        if self.onReceiveSubPagePacket then
            self:onReceiveSubPagePacket(self.curPagePacketInfo)
        end
        if opcode == HP_pb.SHOP_BUY_S then
            Inst:refreshPage()
            Inst:filterSkinCard()
        end
        if opcode == HP_pb.SHOP_ITEM_S then
            Inst:refreshPage()
        end
    end

    --[[ 當 接收 子頁面 封包 ]]
    Inst.SubPage_Base.onReceiveSubPagePacket = Inst.onReceiveSubPagePacket
    function Inst:onReceiveSubPagePacket(packetInfo)
        self.SubPage_Base.onReceiveSubPagePacket(self, packetInfo)
    end

    --[[ 模板 ]]
    -- Inst.SubPage_Base.someFunc = Inst.someFunc
    -- function Inst:someFunc(arg1)
    --     self.SubPage_Base.someFunc(self, arg1)

    -- end

    -- ########  ##     ## ########  ##       ####  ######  
    -- ##     ## ##     ## ##     ## ##        ##  ##    ## 
    -- ##     ## ##     ## ##     ## ##        ##  ##       
    -- ########  ##     ## ########  ##        ##  ##       
    -- ##        ##     ## ##     ## ##        ##  ##       
    -- ##        ##     ## ##     ## ##        ##  ##    ## 
    -- ##         #######  ########  ######## ####  ######  

    --[[ 更新 自動刷新 時間 ]]
    function Inst:updateRefreshAutoTime(lastRefreshTime)

    end

    --[[ 初始化 擁有的皮膚資料 ]]
    function Inst:initOwnSkin()
        local UserMercenaryManager = require("UserMercenaryManager")
        local mercenaryInfos = UserMercenaryManager:getUserMercenaryInfos()
        for i, v in pairs(mercenaryInfos) do
            if v.stageLevel > 0 then
                for idx = 1, #v.ownSkin do
                    Inst.ownSkin[v.ownSkin[idx]] = true   
                end
            end
        end
    end

    --[[ 收起 職業過濾按鈕 ]]
    function Inst:closeFilter(container)
        local filterBg = container:getVarScale9Sprite("mFilterBg")
        filterBg:setContentSize(self.filterCloseSize)
        NodeHelper:setNodesVisible(container, { mClassNode = false })
    end

    --[[ 展開 or 收起 職業過濾按鈕 ]]
    function Inst:onFilter(container)
        local isShowClass = container:getVarNode("mClassNode"):isVisible()
        local filterBg = container:getVarScale9Sprite("mFilterBg")
        if isShowClass then
            filterBg:setContentSize(self.filterCloseSize)
            NodeHelper:setNodesVisible(container, { mClassNode = false })
        else
            filterBg:setContentSize(self.filterOpenSize)
            NodeHelper:setNodesVisible(container, { mClassNode = true })
        end
    end

    --[[ 過濾 皮膚 ]]
    function Inst:filterSkinCard()
        for i = 1, #self.allCardItem do
            local isVisible = (self.nowElement == self.allCardItem[i].handler.heroCfg.Element or self.nowElement == 0) and
                              (self.nowClass == self.allCardItem[i].handler.heroCfg.Job or self.nowClass == 0) and
                              (self.nowPageType == self.allCardItem[i].handler.shopCfg.type or self.nowPageType == self.PAGE_TYPE.ALL)
            self.allCardItem[i].cell:setVisible(isVisible)
            self.allCardItem[i].cell:setContentSize(isVisible and self.cardSize or CCSize(0, 0))
        end
    end

    --[[ 設定 過濾按鈕 狀態 ]]
    function Inst:settingFilterBtn(container)
        for i = 0, 5 do
            container:getVarSprite("mElement" .. i):setVisible(self.nowElement == i)
        end
        for i = 0, 4 do
            container:getVarSprite("mClass" .. i):setVisible(self.nowClass == i)
        end
        for i = 0, 9 do
            NodeHelper:setMenuItemSelected(container, { ["mSkinBtn" .. i] = (self.nowPageType == i) })
        end
    end

    return Inst
end

function ShopSubPage_Skin:createSkinAttrString(skinId, heroId)
    local attrStr = ""
    local skinCfg = ConfigManager.getSkinCfg()[skinId]
    if not skinCfg then
        return attrStr
    end
    local addAttrs = common:split(skinCfg.ownAdd, ",")
    local decAttrs = common:split(skinCfg.ownDec, ",")
    if addAttrs[1] and addAttrs[1] ~= "" then
        for i = 1, #addAttrs do
            local attrId, num = unpack(common:split(addAttrs[i], "_"))
            if attrStr ~= "" then
                attrStr = attrStr .. ", "
            end
            attrStr = attrStr .. common:getLanguageString("@SkinWindos_info_Add", common:getLanguageString("@AttrName_" .. attrId), num)
        end
    end
    if decAttrs[1] and decAttrs[1]  ~= "" then
        for i = 1, #decAttrs do
            local attrId, num = unpack(common:split(decAttrs[i], "_"))
            if attrStr ~= "" then
                attrStr = attrStr .. ", "
            end
            attrStr = attrStr .. common:getLanguageString("@SkinWindos_info_Dec", common:getLanguageString("@AttrName_" .. attrId), num)
        end
    end
    return attrStr
end
function ShopSubPage_Skin:createSkinDesc(txtNode, skinId, heroId, size)
    local skinCfg = ConfigManager.getSkinCfg()[skinId]
    if not skinCfg then
        return
    end
    local attrStr = self:createSkinAttrString(skinId, heroId)
    local htmlContent = common:fillHtmlStr("SkinShopDesc", common:getLanguageString(skinCfg.name), attrStr)
    local htmlLabel = NodeHelper:addHtmlLable(txtNode, htmlContent, 168, size)
    return htmlLabel
end

function ShopSubPage_Skin:hasItem()
    local info = ShopDataMgr:getPacketInfo(Const_pb.SKIN_MARKET)
    return #info.allItemInfo > 0
end
------------------------------------------------------------
-- SaleContent：UI cell 相關邏輯
------------------------------------------------------------
function SaleContent:onRefreshContent(ccbRoot)
    local skinCfg = Inst.skinCfg[self.shopCfg.SkinId]
    if not skinCfg then
        return
    end
    local container = ccbRoot:getCCBFileNode()
    -- image
    local img = {
        mSkillIcon = "skill/S_" .. math.floor(skinCfg.skinSkill / 10) .. ".png",
        mIcon = "UI/RoleShowCards/Hero_" .. string.format("%05d", self.shopCfg.SkinId) .. ".png"
    }
    NodeHelper:setSpriteImage(container, img)
    local timeTxt = self:calShowTimeTxt(self.data.endTime)
    -- string
    local str = {
        mCost = (self.shopType == Inst.GOODS_TYPE.BUY) and self.shopCfg.price[1].count or 0,
        mOffTxt = (self.shopType == Inst.GOODS_TYPE.BUY) and (self.shopCfg.discount .. "%"),
        mName = common:getLanguageString(skinCfg.name),
        mTimeTxt = timeTxt
    }
    local scale9 = container:getVarScale9Sprite("mBg")
    if scale9 then
        local oldSize = scale9:getContentSize()
        oldSize.width = 40 + #timeTxt * 10
        scale9:setContentSize(oldSize)
    end
    NodeHelper:setStringForLabel(container, str)
    -- visible
    local visible = {
        mBuyInfoNode = (self.shopType == Inst.GOODS_TYPE.BUY),
        mJumpNode = (self.shopType == Inst.GOODS_TYPE.EVENT),
        mOffNode = (self.shopType == Inst.GOODS_TYPE.BUY) and (self.shopCfg.discount ~= 100),
        mTimeNode = (self.shopCfg.timeType == 1),
    }
    NodeHelper:setNodesVisible(container, visible)
end

function SaleContent:onHead(container)
    local skinCfg = Inst.skinCfg[self.shopCfg.SkinId]
    if not skinCfg then
        return
    end
    require("Shop.SkinShopPopUp")
    SkinShopPopUp_setPageInfo(self.shopCfg.SkinId, math.floor(skinCfg.skinSkill / 10), math.floor(skinCfg.replacedSkill / 10), 
                              self.shopCfg, self.data.endTime, self.cfgIdx)
    PageManager.pushPage("Shop.SkinShopPopUp")
end
function SaleContent:onConfirmation(container)
    if self.shopType == Inst.GOODS_TYPE.BUY then
        local priceInfo = self.shopCfg.price[1]
        local cost = priceInfo.count
        local userCount = InfoAccesser:getUserItemCount(priceInfo.type, priceInfo.itemId)

        if userCount < cost then
            PageManager.showConfirm(
                common:getLanguageString("@ShopComfirmTitle"),
                common:getLanguageString("@Outof6002"),
                function(isSure)
                    if isSure then
                        require("IAP.IAPPage"):setEntrySubPage("Recharge")
                        PageManager.pushPage("IAP.IAPPage")
                    end
                end,
                true
            )
            return
        end

        -- 購買確認
        PageManager.showConfirm(
            common:getLanguageString("@ShopComfirmTitle"),
            common:getLanguageString("@ShopComfirm"),
            function(isSure)
                if isSure then
                    local msg = Shop_pb.BuyShopItemsRequest()
                    msg.type = 1
                    msg.id = self.cfgIdx
                    msg.amount = 1
                    msg.shopType = Const_pb.SKIN_MARKET
                    common:sendPacket(HP_pb.SHOP_BUY_C, msg, true)
                end
            end,
            true
        )

    elseif self.shopType == Inst.GOODS_TYPE.EVENT then
        local skinCfg = Inst.skinCfg[self.shopCfg.SkinId]
        if not skinCfg then
            return
        end
        local LobbyMarqueeBanner = require("LobbyMarqueeBanner")
        local ids = common:split(skinCfg.jumpId, ",")
        LobbyMarqueeBanner:jumpActivityById(tonumber(ids[1]))
    end
end

function SaleContent:calShowTimeTxt(time)
    local leftTime = math.floor(time / 1000) - os.time()
    if leftTime <= 0 then return 0 end

    local leftDay = math.floor(leftTime / 86400)
    local leftHour = math.floor((leftTime % 86400) / 3600)   
    return string.format("%dD %dH", leftDay, leftHour)
end

return ShopSubPage_Skin
