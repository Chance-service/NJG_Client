local HP_pb = require("HP_pb")
local Shop_pb = require("Shop_pb")
local Const_pb = require("Const_pb")
local CONST = require("Battle.NewBattleConst")
local UserItemManager = require("Item.UserItemManager")
local InfoAccesser = require("Util.InfoAccesser")
local SkinShop = require("Shop.ShopSubPage_Skin")
local thisPageName = "Shop.SkinShopPopUp"
local PAGE_INFO = {
    BASE_SKILL_ID = 0,
    REPLACE_SKILL_ID = 0,
    TAG_LIST = { },
    TAG_MAX_NUM = 3,    -- tag最大數量
    SKILL_LEVEL_NUM = 3,-- 技能有幾階
    SCROLLVIEW_VIEWWIDTH = 0,
    SCROLLVIEW_VIEWHEIGHT = 0,
    SCROLLVIEW_POSY = 0,
    SKILL_CONTENT_SHIFT = 35,
    HTML_TAG = 891,
    SKIN_ID = 0,
    END_TIME = 0,
}
local opcodes = {
    SHOP_BUY_S = HP_pb.SHOP_BUY_S,
    SHOP_ITEM_S = HP_pb.SHOP_ITEM_S
}
local option = {
    ccbiFile = "SkinShop_SkillPopout.ccbi",
    handlerMap =
    {
        onDetail = "onDetail",
        onConfirmation = "onBtn",
        onClose = "onReturn",
    },
    opcode = opcodes
}

local SkinShopPopUp = { }
local skillCfg = ConfigManager.getSkillCfg()
-----------------------------------
local HeroSkillDescItem = {
    ccbiFile = "SkillContent.ccbi",
}
-----------------------------------
function SkinShopPopUp:refreshSkillItem(container, level)
    -- 檢查容器是否存在，避免後續報錯
    if not container then return end

    -- 設置技能等級文字
    NodeHelper:setStringForLabel(container, {
        mSkillLvTxt = common:getLanguageString("@LevelStr", string.format(level))
    })

    -- 生成技能完整ID並清空技能描述節點
    local skillFullId = tonumber(PAGE_INFO.BASE_SKILL_ID .. level)
    local skillDesNode = container:getVarNode("mContentNode")
    skillDesNode:removeAllChildren()
    
    -- 獲取技能HTML內容
    local htmlStr = FreeTypeConfig[skillFullId] and FreeTypeConfig[skillFullId].content or ""
    local tipStr = nil

    -- 顯示技能描述內容
    local htmlLabel = CCHTMLLabel:createWithString(htmlStr, 
        CCSizeMake(PAGE_INFO.SCROLLVIEW_VIEWWIDTH - PAGE_INFO.SKILL_CONTENT_SHIFT * 2, 50), 
        "Barlow-SemiBold")
    htmlLabel:setPosition(ccp(PAGE_INFO.SKILL_CONTENT_SHIFT, 0))
    htmlLabel:setAnchorPoint(ccp(0, 0))
    skillDesNode:addChild(htmlLabel)
    htmlLabel:setTag(PAGE_INFO.HTML_TAG)

    -- 更新提示文字
    NodeHelper:setStringForLabel(container, { mTipTxt = common:getLanguageString(tipStr or "") })
    
    -- 調整技能項目大小
    return self:resizeSkillItem(container, tipStr)
end

function SkinShopPopUp:resizeSkillItem(container, tipStr)
    local titleNode = container:getVarNode("mTopNode")
    local contentNode = container:getVarNode("mContentNode")
    local tipNode = container:getVarNode("mTipNode")
    local bottomNode = container:getVarNode("mBottomNode")
    local bg = container:getVarScale9Sprite("mBg")
    local htmlLabe = contentNode:getChildByTag(PAGE_INFO.HTML_TAG)

    local txtHeight = htmlLabe:getContentSize().height
    local tipHeight = tipStr and tipNode:getContentSize().height or 0
    contentNode:setPositionY(bottomNode:getContentSize().height + tipHeight)
    contentNode:setContentSize(CCSize(contentNode:getContentSize().width, txtHeight))
    titleNode:setPositionY(txtHeight + bottomNode:getContentSize().height + tipHeight)
    container:setContentSize(CCSize(container:getContentSize().width, txtHeight + bottomNode:getContentSize().height + titleNode:getContentSize().height + tipHeight))

    bg:setContentSize(CCSize(bg:getContentSize().width, txtHeight + bottomNode:getContentSize().height + titleNode:getContentSize().height + tipHeight))

    return container:getContentSize().height
end

function SkinShopPopUp:onEnter(container)
    self:registerPacket(container)
    self:refreshPageInfo(container)
    self:refreshSkillInfo(container)
    self:initScrollView(container)
    self:refreshScrollView(container)
    self:initSpine(container)
end
function SkinShopPopUp:onExecute(container)
    NodeHelper:setStringForLabel(container, { 
        mTimeTxt = common:getLanguageString("@ActivityDays") .. self:getEndTimeTxt(container)
    })
end
-- Spine初始化
function SkinShopPopUp:initSpine(container)
    local parentNode = container:getVarNode("mCostumeSpineNode")
    parentNode:removeAllChildrenWithCleanup(true)
    local skinCfg = ConfigManager.getSkinCfg()[PAGE_INFO.SKIN_ID]
    local spineFolder, spineName = unpack(common:split(skinCfg.chibi, ","))

    local spine = SpineContainer:create(spineFolder, spineName)
    local spineNode = tolua.cast(spine, "CCNode")
    spine:runAnimation(1, CONST.BUFF_SPINE_ANI_NAME.WAIT, -1)
    parentNode:addChild(spineNode)
end
-- ScrollView初始化
function SkinShopPopUp:initScrollView(container)
    NodeHelper:initScrollView(container, "mContent", 10)
    PAGE_INFO.SCROLLVIEW_VIEWWIDTH = container.mScrollView:getViewSize().width
    PAGE_INFO.SCROLLVIEW_VIEWHEIGHT = container.mScrollView:getViewSize().height
    PAGE_INFO.SCROLLVIEW_POSY = container.mScrollView:getPositionY()
end
-- 刷新頁面資訊
function SkinShopPopUp:refreshPageInfo(container)
    local skinCfg = ConfigManager.getSkinCfg()[PAGE_INFO.SKIN_ID]
    NodeHelper:setStringForLabel(container, { 
        currencyText_1 = GameUtil:formatNumber(InfoAccesser:getUserItemCount(PAGE_INFO.SHOP_CFG.price[1].type, PAGE_INFO.SHOP_CFG.price[1].itemId)),
        mSkinName = common:getLanguageString(skinCfg.name),
        mSkinDescTxt = "",
        mTimeTxt = common:getLanguageString("@ActivityDays") .. self:getEndTimeTxt(container)
    })
    local txtNode = container:getVarLabelTTF("mSkinDescTxt")
    SkinShop:createSkinDesc(txtNode, PAGE_INFO.SKIN_ID, PAGE_INFO.SHOP_CFG.HeroId, CCSize(380, 85))
    local _type = PAGE_INFO.SHOP_CFG.type
    NodeHelper:setNodesVisible(container, {
        mCoin = (_type == 0),
        mOffNode = (_type == 0) and (PAGE_INFO.SHOP_CFG.discount ~= 100),
        mTimeTxt = (PAGE_INFO.SHOP_CFG.timeType == 1),
    })
    if _type == 0 then  -- 購買
        NodeHelper:setStringForLabel(container, { 
            mOffTxt = PAGE_INFO.SHOP_CFG.discount .. "%",
            mCost = PAGE_INFO.SHOP_CFG.price[1].count,
        })
    elseif _type == 1 then  -- 活動
        NodeHelper:setStringForLabel(container, { 
            mCost = common:getLanguageString("@GoToActivity")
        })
    end
end
-- 刷新技能資訊
function SkinShopPopUp:refreshSkillInfo(container)
    -- ICON
    NodeHelper:setSpriteImage(container, { 
        mSkillImg = "skill/S_" .. PAGE_INFO.BASE_SKILL_ID .. ".png",
        -- TODO
        mOriSkillImg = "skill/S_" .. PAGE_INFO.REPLACE_SKILL_ID .. ".png", 
    })
    -- NAME
    NodeHelper:setStringForLabel(container, { 
        mSkillName = common:getLanguageString("@Skill_Name_" .. PAGE_INFO.BASE_SKILL_ID),
    })
    -- TAG
    for i = 1, PAGE_INFO.TAG_MAX_NUM do
        NodeHelper:setNodesVisible(container, { ["mTagNode" .. i] = PAGE_INFO.TAG_LIST[i] and true or false })
        if PAGE_INFO.TAG_LIST[i] then
            NodeHelper:setStringForLabel(container, { ["mTag" .. i] = common:getLanguageString("@Skill_Type_" .. PAGE_INFO.TAG_LIST[i])})
        end
    end
end
-- 刷新滾動層內容
function SkinShopPopUp:refreshScrollView(container)
    container.mScrollView:removeAllCell()
    container.m_pScrollViewFacade:clearAllItems()
    local nowHeight = 0
    -----------------------------------------
    -- SKILL
    for i = PAGE_INFO.SKILL_LEVEL_NUM, 1, -1 do
        local pItemData = CCReViSvItemData:new_local()
        local pItem = ScriptContentBase:create(HeroSkillDescItem.ccbiFile)
        pItem.skillId = tonumber(PAGE_INFO.BASE_SKILL_ID .. i)
        local itemHeight = self:refreshSkillItem(pItem, i)
        container.m_pScrollViewFacade:addItem(pItemData, pItem.__CCReViSvItemNodeFacade__)
        pItemData.m_ptPosition = ccp(0, nowHeight)
        nowHeight = nowHeight + itemHeight
    end
    -----------------------------------------
    container.mScrollView:setContentSize(CCSize(PAGE_INFO.SCROLLVIEW_VIEWWIDTH, nowHeight))
    container.mScrollView:setViewSize(CCSize(PAGE_INFO.SCROLLVIEW_VIEWWIDTH, math.min(nowHeight, PAGE_INFO.SCROLLVIEW_VIEWHEIGHT)))
    container.mScrollView:setContentOffset(ccp(0, nowHeight >= PAGE_INFO.SCROLLVIEW_VIEWHEIGHT and PAGE_INFO.SCROLLVIEW_VIEWHEIGHT - nowHeight or 0))
    container.m_pScrollViewFacade:setDynamicItemsStartPosition(0)
    container.mScrollView:forceRecaculateChildren()
    container.mScrollView:setTouchEnabled(nowHeight > PAGE_INFO.SCROLLVIEW_VIEWHEIGHT)
    container.mScrollView:setPositionY(nowHeight >= PAGE_INFO.SCROLLVIEW_VIEWHEIGHT and PAGE_INFO.SCROLLVIEW_POSY 
                                       or (PAGE_INFO.SCROLLVIEW_POSY + (PAGE_INFO.SCROLLVIEW_VIEWHEIGHT - nowHeight)))
end

-- 取得剩餘時間文字
function SkinShopPopUp:getEndTimeTxt(container)
    local secTime = PAGE_INFO.END_TIME / 1000
    local leftTime = secTime - os.time()
    if leftTime < 0 then
        leftTime = 0
    end
    local hour = math.floor(leftTime / 3600)
    local min = math.floor((leftTime % 3600) / 60)
    local sec = leftTime % 60

    return string.format("%02d:%02d:%02d", hour, min, sec)
end

function SkinShopPopUp:onDetail(container)
    require("NgSkinPreviewPage")
    NgSkinPreviewPage_setPageInfo(PAGE_INFO.SHOP_CFG.HeroId, PAGE_INFO.SKIN_ID)
    PageManager.pushPage("NgSkinPreviewPage")
end

function SkinShopPopUp:onBtn(container)
    local shopCfg  = PAGE_INFO.SHOP_CFG
    local cfgIdx   = PAGE_INFO.CFG_IDX
    local skinId   = PAGE_INFO.SKIN_ID
    local shopType = shopCfg.type

    -- 購買類型
    if shopType == 0 then
        local priceInfo = shopCfg.price[1]
        local cost      = priceInfo.count
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

        -- 確認購買
        PageManager.showConfirm(
            common:getLanguageString("@ShopComfirmTitle"),
            common:getLanguageString("@ShopComfirm"),
            function(isSure)
                if isSure then
                    local msg       = Shop_pb.BuyShopItemsRequest()
                    msg.type        = 1
                    msg.id          = cfgIdx
                    msg.amount      = 1
                    msg.shopType    = Const_pb.SKIN_MARKET
                    common:sendPacket(HP_pb.SHOP_BUY_C, msg, true)
                end
            end,
            true
        )

    -- 活動跳轉類型
    elseif shopType == 1 then
        local skinCfg = ConfigManager.getSkinCfg()[skinId]
        if not skinCfg then return end

        local LobbyMarqueeBanner = require("LobbyMarqueeBanner")
        local ids = common:split(skinCfg.jumpId, ",")
        LobbyMarqueeBanner:jumpActivityById(tonumber(ids[1]))
    end
end


function SkinShopPopUp:onReturn(container)
    self:removePacket(container)
    PageManager.popPage(thisPageName)
end

function SkinShopPopUp:registerPacket(container)
    for key, opcode in pairs(opcodes) do
        if string.sub(key, -1) == "S" then
            container:registerPacket(opcode)
        end
    end
end

function SkinShopPopUp:removePacket(container)
    for key, opcode in pairs(opcodes) do
        if string.sub(key, -1) == "S" then
            container:removePacket(opcode)
        end
    end
end

function SkinShopPopUp:onReceivePacket(container)
    local opcode = container:getRecPacketOpcode()
    local msgBuff = container:getRecPacketBuffer()
    if opcode == HP_pb.SHOP_BUY_S then
        MessageBoxPage:Msg_Box(common:getLanguageString("@BuyOK"))
        SkinShopPopUp:onReturn(container)
    end
end

function SkinShopPopUp_setPageInfo(skinId, skillId, replaceSkillId, shopCfg, endTime, cfgIdx)
    PAGE_INFO.SKIN_ID = skinId
    PAGE_INFO.BASE_SKILL_ID = skillId
    PAGE_INFO.REPLACE_SKILL_ID = replaceSkillId
    PAGE_INFO.FULL_SKILL_ID = tonumber(PAGE_INFO.BASE_SKILL_ID .. PAGE_INFO.SKILL_LEVEL_NUM)
    PAGE_INFO.TAG_LIST = common:split(skillCfg[PAGE_INFO.FULL_SKILL_ID].tagType, ",")
    PAGE_INFO.SHOP_CFG = shopCfg
    PAGE_INFO.END_TIME = endTime
    PAGE_INFO.CFG_IDX = cfgIdx
end

local CommonPage = require('CommonPage')
local SkinShopPopUp = CommonPage.newSub(SkinShopPopUp, thisPageName, option)