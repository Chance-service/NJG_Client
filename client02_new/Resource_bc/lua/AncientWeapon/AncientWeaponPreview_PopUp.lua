local AncientWeaponDataMgr = require("AncientWeapon.AncientWeaponDataMgr")

local thisPageName = "AncientWeaponPreview_PopUp"

local opcodes = {
}

local option = {
    ccbiFile = "AWPreview_Card.ccbi",
    handlerMap =
    {
        onClose = "onClose",
    },
    opcode = opcodes
}

local REWARD_EQUIP_ID = 0
local FREETYPE_FONT_COLOR = "#763306" -- FreeType原始文字顏色
local UI_FONT_COLOR = "#FFFFFF" -- UI文字顏色

local AWPreviewPopUp = { }

-----------------------------------
function AWPreviewPopUp.onFunction(eventName, container)
    if eventName == "luaLoad" then
        AWPreviewPopUp:onLoad(container)
    elseif eventName == "luaEnter" then
        AWPreviewPopUp:onEnter(container)
    elseif eventName =="onClose" then
        AWPreviewPopUp:onClose(container)
    end
end

function AWPreviewPopUp:onLoad(container)
    container:loadCcbiFile(option.ccbiFile)
end

function AWPreviewPopUp:onEnter(container)
    self.container = container
    self:refreshPage(container)
end
function AWPreviewPopUp:onClose(container)
    PageManager.popPage(thisPageName)
end
-- 刷新內容
function AWPreviewPopUp:refreshPage(container)
    local equipAttr, maxLv = AncientWeaponDataMgr:getEquipMaxAttr(REWARD_EQUIP_ID)
    local txtMap = { }
    local node2Img = { }
    -- 屬性 
    for i = 1, 2 do
        local curAttr = equipAttr[i]
        -- 最大等级属性
        txtMap["curStarAttrValTxt_" .. i] = curAttr.val
        node2Img["curStarAttrValIcon_" .. i] = curAttr.icon
    end
    -- 等級
    txtMap["curLvNum"] = maxLv
    -- 技能
    local equipCfg = ConfigManager.getEquipCfg()[REWARD_EQUIP_ID]
    local roleEquipID = equipCfg.mercenarySuitId
    local roleEquipCfg = ConfigManager.RoleEquipDescCfg()[roleEquipID]
    for idx = 1, 3 do
        local skillDesc = roleEquipCfg["desc" .. tostring(idx)]
        if skillDesc then
            local freeTypeCfg = FreeTypeConfig[tonumber(skillDesc)]
            local str = common:fill(freeTypeCfg and freeTypeCfg.content or "")
            local parent = container:getVarLabelTTF("mLockTxt" .. idx)

            str = string.gsub(str, FREETYPE_FONT_COLOR, UI_FONT_COLOR)

            NodeHelper:addHtmlLable(parent, str, tonumber(skillDesc), CCSizeMake(400, 80))
        end
        txtMap["mLockTxt" .. idx] = ""
    end
    -- 專武圖
    node2Img["mCardImg"] = "UI/AncientWeaponSystem/AWS_" .. REWARD_EQUIP_ID .. ".jpg"
    -- 外框圖
    local tagToLevel = {
        [1] = 3, [2] = 2, [3] = 1
    }
    local tag = math.floor(REWARD_EQUIP_ID / 10000)
    level = tagToLevel[tag] or 3
    node2Img["mCardFrame"] = "AWS_Card2_T" .. level .. ".png"

    NodeHelper:setSpriteImage(container, node2Img)
    NodeHelper:setStringForLabel(container, txtMap)
end

function AWPreviewPopUp:setShowId(equipId)
    REWARD_EQUIP_ID = equipId
end

local CommonPage = require('CommonPage')
local AWPreviewPopUp = CommonPage.newSub(AWPreviewPopUp, thisPageName, option)

return AWPreviewPopUp