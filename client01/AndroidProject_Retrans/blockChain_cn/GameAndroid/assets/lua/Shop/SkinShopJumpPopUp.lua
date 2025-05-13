local SkinShop = require("Shop.ShopSubPage_Skin")
local thisPageName = "Shop.SkinShopJumpPopUp"
local PAGE_INFO = {
    HTML_TAG = 891,
    SKIN_ID = 0,
    HERO_ID = 0,
}
local opcodes = {
}
local option = {
    ccbiFile = "SkinShop_GetPopout.ccbi",
    handlerMap =
    {
        onClose = "onClose",
    },
    opcode = opcodes
}

local SkinShopJumpPopUp = { }
local skillCfg = ConfigManager.getSkillCfg()
-----------------------------------
local SkinShopJumpItem = {
    ccbiFile = "SkinShop_GetPopoutContent.ccbi",
}
function SkinShopJumpItem:onRefreshContent(ccbRoot)
    local container = ccbRoot:getCCBFileNode()
    NodeHelper:setStringForLabel(container, {
        mNameTxt = common:getLanguageString(self.jumpTxt),
    })
end
function SkinShopJumpItem:onJump(container)
    local LobbyMarqueeBanner = require("LobbyMarqueeBanner")
    LobbyMarqueeBanner:jumpActivityById(self.jumpId)
end
-----------------------------------
function SkinShopJumpPopUp:onEnter(container)
    self:refreshPageInfo(container)
    self:refreshScrollView(container)
end
-- 刷新頁面資訊
function SkinShopJumpPopUp:refreshPageInfo(container)
    local skinCfg = ConfigManager.getSkinCfg()[PAGE_INFO.SKIN_ID]
    NodeHelper:setStringForLabel(container, { 
        mSkinName = common:getLanguageString(skinCfg.name),
        mSkinDescTxt = "",
    })
    local txtNode = container:getVarLabelTTF("mSkinDescTxt")
    SkinShop:createSkinDesc(txtNode, PAGE_INFO.SKIN_ID, PAGE_INFO.HERO_ID, CCSize(380, 85))
    NodeHelper:setSpriteImage(container, {
        mPic1 = "UI/RoleIcon/Icon_" .. string.format("%05d", PAGE_INFO.SKIN_ID) .. ".png"
    })
end
-- 刷新滾動層內容
function SkinShopJumpPopUp:refreshScrollView(container)
    local skinCfg = ConfigManager.getSkinCfg()[PAGE_INFO.SKIN_ID]
    local mScrollView = container:getVarScrollView("mContent")
    mScrollView:removeAllCell()
    local ids = common:split(skinCfg.jumpId, ",")
    local txts = common:split(skinCfg.jumpTxt, ",")
    for i = 1, #ids do
        local cell = CCBFileCell:create()
        cell:setCCBFile(SkinShopJumpItem.ccbiFile)
        local handler = common:new( { id = i, jumpTxt = txts[i], jumpId = tonumber(ids[i]) }, SkinShopJumpItem)
        cell:registerFunctionHandler(handler)
        mScrollView:addCell(cell)
    end
    mScrollView:orderCCBFileCells()
end

function SkinShopJumpPopUp:onClose(container)
    PageManager.popPage(thisPageName)
end

function SkinShopJumpPopUp_setPageInfo(skinId, heroId)
    PAGE_INFO.SKIN_ID = skinId
    PAGE_INFO.HERO_ID = heroId
end

local CommonPage = require('CommonPage')
local SkinShopJumpPopUp = CommonPage.newSub(SkinShopJumpPopUp, thisPageName, option)