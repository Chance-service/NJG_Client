----------------------------------------------------------------------------------
-- 英雄皮膚預覽介面
----------------------------------------------------------------------------------
local NodeHelper = require("NodeHelper")
local thisPageName = "NgSkinPreviewPage"
local ShopSubPage_Skin = require("Shop.ShopSubPage_Skin")
local CONST = require("Battle.NewBattleConst")
local NgSkinPreviewPage = { }
local PAGE_INFO = {
    ITEM_ID = 0,
    SKIN_ID = 0,
}
local option = {
    ccbiFile = "SkinShop_Preview.ccbi",
    handlerMap =
    {
        onHelp = "onHelp",
        onReturn = "onReturn",
    },
}
for i = 1, 4 do
    option.handlerMap["onSkill" .. i] = "showSkill"
end

local selfContainer = nil

local heroCfg = nil
local skinCfg = ConfigManager.getSkinCfg()
local skillCfg = ConfigManager.getSkillCfg()

local itemId = nil
local curRoleInfo = nil
-----------------------------------------------------------------------------------------------------
function NgSkinPreviewPage.onFunction(eventName, container)
    if option.handlerMap[eventName] then
        NgSkinPage[option.handlerMap[eventName]](NgSkinPage, container, eventName)
    end
end
function NgSkinPreviewPage:onEnter(container)
    selfContainer = container
    selfContainer:registerFunctionHandler(NgSkinPreviewPage.onFunction)
    
    heroCfg = ConfigManager.getNewHeroCfg()[PAGE_INFO.ITEM_ID]

    self:refreshPage(selfContainer) 
    self:showRoleSpine(selfContainer)
end
-- 刷新頁面
function NgSkinPreviewPage:refreshPage(container)
    UserInfo.sync()
    self:showPageInfo(container)
    self:showSkillInfo(container)
end
-- 設定顯示資訊
function NgSkinPreviewPage:showPageInfo(container)
    -- 名稱顯示
    NodeHelper:setStringForLabel(container, { mLeaderName = common:getLanguageString("@HeroName_" .. PAGE_INFO.ITEM_ID) })
    -- 屬性, 職業顯示
    local element = (PAGE_INFO.SKIN_ID == 0) and heroCfg.Element or skinCfg[PAGE_INFO.SKIN_ID].element
    NodeHelper:setSpriteImage(container, { mClassIcon = GameConfig.MercenaryClassImg[heroCfg.Job],
                                           mElementIcon = GameConfig.MercenaryElementImg[element] })
end
-- 設定顯示資訊
function NgSkinPreviewPage:showSkillInfo(container)
    local skill = skinCfg[PAGE_INFO.SKIN_ID].skinSkill
    local baseSkillId = math.floor(skill / 10)
    local replaceSkillId = math.floor(skinCfg[PAGE_INFO.SKIN_ID].replacedSkill / 10)
    local level = skill % 10
    -- SKILLS ICON
    local skills = common:split(skinCfg[PAGE_INFO.SKIN_ID].skills, ",")
    for k, v in ipairs(skills)do  
        local skillBaseId = math.floor(v / 10)
        NodeHelper:setSpriteImage(container, { ["Skill" .. k] = "skill/S_" .. skillBaseId .. ".png" })
    end
    for i = 1, 4 do
        NodeHelper:setStringForLabel(container, { ["mSkillLv" .. i] = 3 })
    end
    -- SKIN DES
    local skinDesc = container:getVarLabelTTF("mSkinDescTxt")
    skinDesc:setDimensions(CCSizeMake(540, 200))
    NodeHelper:setStringForLabel(container, {
        mSkinDescTxt = ShopSubPage_Skin:createSkinAttrString(PAGE_INFO.SKIN_ID, PAGE_INFO.ITEM_ID)
    })
end
-- 設定spine
function NgSkinPreviewPage:showRoleSpine(container)
    self:showTachieSpine(container)
    self:showChibiSpine(container)
end 
-- 設定立繪spine
function NgSkinPreviewPage:showTachieSpine(container) 
    local spineName
    if PAGE_INFO.SKIN_ID > 0 then
        spineName = "NG2D_" .. string.format("%05d", PAGE_INFO.SKIN_ID)
    else
        spineName = "NG2D_" .. string.format("%02d", PAGE_INFO.ITEM_ID)
    end

    local parentNode = container:getVarNode("mSpine")
    parentNode:removeAllChildrenWithCleanup(true)

    local spine = SpineContainer:create("NG2D", spineName)
    local spineNode = tolua.cast(spine, "CCNode")
    spine:runAnimation(1, "animation", -1)
    spineNode:setScale(NodeHelper:getScaleProportion())
    parentNode:addChild(spineNode)
end
-- 設定小人spine
function NgSkinPreviewPage:showChibiSpine(container)
    local spineName
    if PAGE_INFO.SKIN_ID > 0 then
        spineName = "NG_" .. string.format("%05d", PAGE_INFO.SKIN_ID)
    else
        spineName = "NG_" .. string.format("%02d000", PAGE_INFO.ITEM_ID)
    end

    local parentNode = container:getVarNode("mSpineLittle")
    parentNode:removeAllChildrenWithCleanup(true)

    local spine = SpineContainer:create("Spine/CharacterSpine", spineName)
    local spineNode = tolua.cast(spine, "CCNode")
    spine:runAnimation(1, CONST.BUFF_SPINE_ANI_NAME.WAIT, -1)
    parentNode:addChild(spineNode)
end
------------------------------------------------------------------------------------------
-- Main Page Button
------------------------------------------------------------------------------------------
function NgSkinPreviewPage:showSkill(container, eventName)
    local id = string.sub(eventName, -1)
    local skill = tonumber(common:split(skinCfg[PAGE_INFO.SKIN_ID].skills, ",")[tonumber(id)])
    require("HeroSkillPage")
    HeroSkillPage_setPageRoleInfo(355, 13)
    HeroSkillPage_setPageSkillLevel(3)
    HeroSkillPage_setPageSkillId(skill)
    PageManager.pushPage("HeroSkillPage")
end
function NgSkinPreviewPage:onReturn(container)
    PageManager.popPage(thisPageName)
end
------------------------------------------------------------------------------------------
function NgSkinPreviewPage_setPageInfo(_itemId, _skinId)
    PAGE_INFO.ITEM_ID = _itemId
    PAGE_INFO.SKIN_ID = _skinId
end

local CommonPage = require('CommonPage')
NgSkinPreviewPage = CommonPage.newSub(NgSkinPreviewPage, thisPageName, option)
return NgSkinPreviewPage