----------------------------------------------------------------------------------
-- 英雄皮膚介面
----------------------------------------------------------------------------------
local NodeHelper = require("NodeHelper")
local thisPageName = "NgSkinPage"
local HP_pb = require("HP_pb")
local Const_pb = require("Const_pb")
local PBHelper = require("PBHelper")
local EquipManager = require("EquipManager")
local UserMercenaryManager = require("UserMercenaryManager")
local CONST = require("Battle.NewBattleConst")
local NgSkinPage = { }

local option = {
    ccbiFile = "EquipmentPageRoleContent_costumeUI.ccbi",
    handlerMap =
    {
        -- main page
        onReturn = "onReturn",
        onHelp = "onHelp",
        onDetail = "onDetail",      -- 切換資訊頁面
        onPlus = "onPlus",          -- 切換角色
        onMinus = "onMinus",        -- 切換角色
        onEquip = "onEquip",        -- 裝備皮膚
    },
    opcodes = {
        -- 切換皮膚
        ROLE_CHANGE_SKIN_C = HP_pb.ROLE_CHANGE_SKIN_C,
        ROLE_CHANGE_SKIN_S = HP_pb.ROLE_CHANGE_SKIN_S,
        -- 請求屬性資料
        ROLE_ATTRINFO_COUNT_C = HP_pb.ROLE_ATTRINFO_COUNT_C,
        ROLE_ATTRINFO_COUNT_S = HP_pb.ROLE_ATTRINFO_COUNT_S,
        -- 皮膚購買回傳
        SHOP_BUY_S = HP_pb.SHOP_BUY_S,
    }
}
for i = 1, 4 do
    option.handlerMap["onSkill" .. i] = "showSkill"
end

local selfContainer = nil

local BTN_TYPE = { ENABLE = 1, DISABLE_EQUIPED = 2, ENABLE_HAVENT = 3 }
local btnType = BTN_TYPE.ENABLE

local PAGE_TYPE = { SELECT = 1, DETAIL = 2 }
local nowPageType = PAGE_TYPE.SELECT
local heroCfg = nil
local skinCfg = ConfigManager.getSkinCfg()

local itemId = nil
local curRoleInfo = nil
local preOffsetX = 0
local stopCounter = 0

local COUNTER_MAX = 5
local COSTUME_ITEM_WIDTH = 240
local COSTUME_ITEM_BASE_SCALE = 0.2
local COSTUME_DATA = {
    NOW_SKIN = 0,   -- 現在選擇中的皮膚
    ALL_SKIN = { }, -- 該角色全部皮膚
    OWN_SKIN = { }, -- 玩家擁有的該角色皮膚
    COSTUME_ITEMS = { },    -- 皮膚卡牌物件
    NOW_COSTUME_ID = 1, -- 當前選擇的皮膚卡牌id
    MOVE_TIME = 0.1,    -- 卡牌位置校正時間
    IS_MOVEING = false, -- 卡牌移動中
}
local allAttrData = { }
-----------------------------------------------------------------------------------------------------
local libPlatformListener = { }
function libPlatformListener:onPlayMovieEnd(listener)
    if not listener then return end
    --NgSkinPage:closeMovie(pageContainer)
end
-----------------------------------------------------------------------------------------------------
function NgSkinPage.onFunction(eventName, container)
    if option.handlerMap[eventName] then
        NgSkinPage[option.handlerMap[eventName]](NgSkinPage, container, eventName)
    end
end
function NgSkinPage:onExecute(container)
    local isTouching = selfContainer.mScrollView:isTouchMoved()
    local offset = container.mScrollView:getContentOffset()
    -- 校正位置function
    local fn = function()
        local minDis = 9999999
        for i = 1, #COSTUME_DATA.ALL_SKIN do
            local dis = math.abs(offset.x - ((i - 1) * -1 * COSTUME_ITEM_WIDTH))
            if dis < minDis then
                minDis = dis
                COSTUME_DATA.NOW_COSTUME_ID = i
            end
        end
        container.mScrollView:setContentOffsetInDuration(ccp((COSTUME_DATA.NOW_COSTUME_ID - 1) * -1 * COSTUME_ITEM_WIDTH, 0), COSTUME_DATA.MOVE_TIME)
        COSTUME_DATA.NOW_SKIN = COSTUME_DATA.ALL_SKIN[COSTUME_DATA.NOW_COSTUME_ID] or 0
        self:refreshSkinUI(container)
    end
    if isTouching then  -- 玩家拖曳中
        COSTUME_DATA.IS_MOVEING = true
        stopCounter = 0
    else
        if COSTUME_DATA.IS_MOVEING then -- 非校正位移的狀態
            if (preOffsetX == offset.x) then    -- 停止位移
                stopCounter = stopCounter + 1
            else    -- 慣性位移中
                stopCounter = 0
            end
        end
    end
    if stopCounter >= COUNTER_MAX then  -- 停止位移計數超過設定上限值
        COSTUME_DATA.IS_MOVEING = false
        stopCounter = 0
        fn()
    end
    -- 計算縮放
    for i = 1, #COSTUME_DATA.COSTUME_ITEMS do
        local centerOffsetX = (i - 1) * -1 * COSTUME_ITEM_WIDTH + COSTUME_ITEM_WIDTH -- 該卡牌在中心時的offsetX
        local diffOffsetX = math.abs(offset.x - centerOffsetX)  -- 中心跟實際offsetX的差絕對值
        local scale = 1 - (diffOffsetX / COSTUME_ITEM_WIDTH * COSTUME_ITEM_BASE_SCALE)  -- 每差240縮小0.2倍
        if COSTUME_DATA.COSTUME_ITEMS[i].isShow and NgSkinPage:checkItemInView(container, i) then    -- 只改畫面會看到的
            if COSTUME_DATA.COSTUME_ITEMS[i].scale ~= math.floor(scale * 1000) then
                NodeHelper:setNodeScale(COSTUME_DATA.COSTUME_ITEMS[i].container, "mNode", scale, scale)
                COSTUME_DATA.COSTUME_ITEMS[i].scale = math.floor(scale * 1000)
            end
            NodeHelper:setNodesVisible(COSTUME_DATA.COSTUME_ITEMS[i].container, { mMask = (COSTUME_DATA.COSTUME_ITEMS[i].skinId ~= COSTUME_DATA.NOW_SKIN) })
        end
    end
    preOffsetX = offset.x
end
function NgSkinPage:onEnter(container)
    selfContainer = container
    nowPageType = PAGE_TYPE.SELECT

    selfContainer:registerFunctionHandler(NgSkinPage.onFunction)
    
    heroCfg = ConfigManager.getNewHeroCfg()[itemId]

    preOffsetX = 0
    stopCounter = 0

    self:registerPacket(selfContainer)
    self:initSkinData(selfContainer)
    self:initSkinItem(selfContainer)
    self:refreshPage(selfContainer) 
    self:showRoleSpine(selfContainer)
end
function NgSkinPage:onHelp(container)
    PageManager.showHelp(GameConfig.HelpKey.HELP_HEROHELP)
end
-- 刷新頁面
function NgSkinPage:refreshPage(container)
    UserInfo.sync()
    if curRoleInfo then
        curRoleInfo = UserMercenaryManager:getUserMercenaryById(curRoleInfo.roleId)
    end
    self:showPageInfo(container)
    self:refreshPageVisible(container)
    self:refreshEquipBtn(container)
    if nowPageType == PAGE_TYPE.DETAIL then
        local key = self:getAttrDataKey(container)
        self:clearAttrInfo(container)
        if not allAttrData[key] then
            self:requestAttrInfo(container)
        else
            self:showAllAttrInfo(container)
        end
        self:showSkillInfo(container)
    end
end
-- 設定顯示資訊
function NgSkinPage:showPageInfo(container)
    -- 名稱顯示
    NodeHelper:setStringForLabel(container, { mLeaderName = common:getLanguageString("@HeroName_" .. itemId) })
    -- 屬性, 職業顯示
    local element = (COSTUME_DATA.NOW_SKIN == 0) and heroCfg.Element or skinCfg[COSTUME_DATA.NOW_SKIN].element
    NodeHelper:setSpriteImage(container, { mClassIcon = GameConfig.MercenaryClassImg[heroCfg.Job],
                                           mElementIcon = GameConfig.MercenaryElementImg[element] })
end
-- 設定顯示狀態
function NgSkinPage:refreshPageVisible(container)
    NodeHelper:setNodesVisible(container, { mSelectNode = (nowPageType == PAGE_TYPE.SELECT), 
                                            mDetailNode = (nowPageType == PAGE_TYPE.DETAIL) })
end
-- 設定spine
function NgSkinPage:showRoleSpine(container)
    self:showTachieSpine(container)
    self:showChibiSpine(container)
end 
-- 播放mp4
function NgSkinPage:playMovie(container)
    -- 播放影片
    if COSTUME_DATA.NOW_SKIN ~= 0 then
        local fileName = "Hero/Hero" .. string.format("%05d", COSTUME_DATA.NOW_SKIN)
        local isFileExist =  NodeHelper:isFileExist("Video/" .. fileName .. ".mp4")
        if isFileExist then
            NgSkinPage.libPlatformListener = LibPlatformScriptListener:new(libPlatformListener)
            GamePrecedure:getInstance():playMovie(thisPageName, fileName, 1, 0)
            NodeHelper:setNodesVisible(container, { mSpine = false })
        end
    end
end
-- 關閉影片
function NgSkinPage:closeMovie(container)
    CCLuaLog("EquipLeadPage:closeMovie")
    --NodeHelper:setNodesVisible(container, { mSpine = true })
    GamePrecedure:getInstance():closeMovie(thisPageName)
end
-- 設定立繪spine
function NgSkinPage:showTachieSpine(container) 
    local spineName
    local parentNode = container:getVarNode("mSpine")
    parentNode:removeAllChildrenWithCleanup(true)
    if COSTUME_DATA.NOW_SKIN > 0 then
        spineName = "NG2D_" .. string.format("%05d", COSTUME_DATA.NOW_SKIN)
        local isFileExist =  NodeHelper:isFileExist("Spine/NG2D/" .. spineName .. ".skel")
        if not isFileExist then
            --self:closeMovie(container)
            -- 沒有皮膚立繪spine -> 播mp4
            self:playMovie(container)
            return
        end
    else
        spineName = "NG2D_" .. string.format("%02d", itemId)
        NodeHelper:setNodesVisible(container, { mSpine = true })
    end

    local spine = SpineContainer:create("NG2D", spineName)
    local spineNode = tolua.cast(spine, "CCNode")
    spine:runAnimation(1, "animation", -1)
    spineNode:setScale(NodeHelper:getScaleProportion())
    parentNode:addChild(spineNode)
end
-- 設定小人spine
function NgSkinPage:showChibiSpine(container)
    local spineName
    if COSTUME_DATA.NOW_SKIN > 0 then
        spineName = "NG_" .. string.format("%05d", COSTUME_DATA.NOW_SKIN)
    else
        spineName = "NG_" .. string.format("%02d000", itemId)
    end

    local parentNode = container:getVarNode("mSpineLittle")
    parentNode:removeAllChildrenWithCleanup(true)

    local spine = SpineContainer:create("Spine/CharacterSpine", spineName)
    local spineNode = tolua.cast(spine, "CCNode")
    spine:runAnimation(1, CONST.BUFF_SPINE_ANI_NAME.WAIT, -1)
    parentNode:addChild(spineNode)
end
-- 初始化皮膚資料
function NgSkinPage:initSkinData(container)
    local allSkinData = common:split(heroCfg.Skin, ",")
    COSTUME_DATA.ALL_SKIN = { }
    COSTUME_DATA.OWN_SKIN = { }
    
    table.insert(COSTUME_DATA.ALL_SKIN, 0)
    for i = 1, #allSkinData do
        if tonumber(allSkinData[i]) ~= 0 then
            table.insert(COSTUME_DATA.ALL_SKIN, tonumber(allSkinData[i]))
        end
    end
    local curRoleInfo = UserMercenaryManager:getUserMercenaryByItemId(itemId)
    if curRoleInfo then
        COSTUME_DATA.OWN_SKIN[0] = true
        for i = 1, #curRoleInfo.ownSkin do
            COSTUME_DATA.OWN_SKIN[tonumber(curRoleInfo.ownSkin[i])] = true
        end
    else
        COSTUME_DATA.OWN_SKIN[0] = false
    end
    if not COSTUME_DATA.OWN_SKIN[COSTUME_DATA.NOW_SKIN] then
        COSTUME_DATA.NOW_SKIN = 0
    end
end
------------------------------------------------------------------------------------------
-- Main Page Button
------------------------------------------------------------------------------------------
function NgSkinPage:onReturn(container)
    if nowPageType == PAGE_TYPE.DETAIL then
        nowPageType = PAGE_TYPE.SELECT
        self:refreshPage(container)
    else
        self:removePacket(container)
        PageManager.refreshPage("EquipmentPage", "refreshScrollView")
        PageManager.popPage(thisPageName)
        NgSkinPage:closeMovie(container)
        if NgSkinPage.libPlatformListener then
            NgSkinPage.libPlatformListener:delete()
            NgSkinPage.libPlatformListener = nil
        end
    end
end

function NgSkinPage:onDetail(container)
    if nowPageType == PAGE_TYPE.DETAIL then
        return
    end
    nowPageType = PAGE_TYPE.DETAIL
    self:refreshPage(container)
end
function NgSkinPage:onEquip(container)
    if btnType == BTN_TYPE.ENABLE then  -- 裝備
        local RoleOpr_pb = require("RoleOpr_pb")
        local msg = RoleOpr_pb.HPChangeMercenarySkinReq()
	    msg.fromRoleId = curRoleInfo.roleId
	    msg.toRoleId = COSTUME_DATA.NOW_SKIN
        common:sendPacket(HP_pb.ROLE_CHANGE_SKIN_C, msg, true)
    elseif btnType == BTN_TYPE.ENABLE_HAVENT then   -- 解鎖
        require("Shop.SkinShopJumpPopUp")
        SkinShopJumpPopUp_setPageInfo(COSTUME_DATA.NOW_SKIN, itemId)
        PageManager.pushPage("Shop.SkinShopJumpPopUp")
    end
end

function NgSkinPage:onPlus(container)
	if COSTUME_DATA.ALL_SKIN[COSTUME_DATA.NOW_COSTUME_ID] and COSTUME_DATA.ALL_SKIN[COSTUME_DATA.NOW_COSTUME_ID + 1] then
        COSTUME_DATA.NOW_COSTUME_ID = COSTUME_DATA.NOW_COSTUME_ID + 1
    else
        COSTUME_DATA.NOW_COSTUME_ID = 1
    end
    selfContainer.mScrollView:setContentOffsetInDuration(ccp((COSTUME_DATA.NOW_COSTUME_ID - 1) * -1 * COSTUME_ITEM_WIDTH, 0), 0)
    COSTUME_DATA.NOW_SKIN = COSTUME_DATA.ALL_SKIN[COSTUME_DATA.NOW_COSTUME_ID] or 0
    NgSkinPage:refreshSkinUI(selfContainer)
end
function NgSkinPage:onMinus(container)
	if COSTUME_DATA.ALL_SKIN[COSTUME_DATA.NOW_COSTUME_ID] and COSTUME_DATA.ALL_SKIN[COSTUME_DATA.NOW_COSTUME_ID - 1] then
        COSTUME_DATA.NOW_COSTUME_ID = COSTUME_DATA.NOW_COSTUME_ID - 1
    else
        COSTUME_DATA.NOW_COSTUME_ID = #COSTUME_DATA.ALL_SKIN
    end
    selfContainer.mScrollView:setContentOffsetInDuration(ccp((COSTUME_DATA.NOW_COSTUME_ID - 1) * -1 * COSTUME_ITEM_WIDTH, 0), 0)
    COSTUME_DATA.NOW_SKIN = COSTUME_DATA.ALL_SKIN[COSTUME_DATA.NOW_COSTUME_ID] or 0
    NgSkinPage:refreshSkinUI(selfContainer)
end
------------------------------------------------------------------------------------------
-- Detail Page
------------------------------------------------------------------------------------------
function NgSkinPage:showSkill(container, eventName)
    local id = string.sub(eventName, -1)
    local skill
    if COSTUME_DATA.NOW_SKIN == 0 then
        skill = tonumber(common:split(heroCfg.Skills, ",")[tonumber(id)])
    else
        skill = tonumber(common:split(skinCfg[COSTUME_DATA.NOW_SKIN].skills, ",")[tonumber(id)])
    end
    
    -- 等級顯示
    local skillLv = 0
    local nowSkills
    if curRoleInfo.skinId == 0 then
        nowSkills = tonumber(common:split(heroCfg.Skills, ",")[tonumber(id)])
    else
        nowSkills = tonumber(common:split(skinCfg[curRoleInfo.skinId].skills, ",")[tonumber(id)])
    end
    for i = 1, #curRoleInfo.skills do
        if math.floor(curRoleInfo.skills[i].itemId / 10) == math.floor(nowSkills / 10) then
            skillLv = curRoleInfo.skills[i] and tonumber(string.sub(curRoleInfo.skills[i].itemId, -1))
            break
        end
    end
    require("HeroSkillPage")
    HeroSkillPage_setPageRoleInfo(curRoleInfo.level, curRoleInfo.starLevel, curRoleInfo.roleId, itemId)
    HeroSkillPage_setPageSkillLevel(skillLv)
    HeroSkillPage_setPageSkillId(skill, tonumber(id))
    PageManager.pushPage("HeroSkillPage")
end
-----------------------------------------------------------------------------------------------------
local AttributeContent = { }
local AttributeSetting = {
    { Const_pb.BUFF_CRITICAL_DAMAGE, 4 },
    { Const_pb.BUFF_AVOID_CONTROL, 6 },
    { Const_pb.BUFF_MAGDEF_PENETRATE, 1 },
    { Const_pb.BUFF_PHYDEF_PENETRATE, 1 },
    { Const_pb.RESILIENCE, 3 },
    { Const_pb.CRITICAL, 3 },
    { Const_pb.DODGE, 3 },
    { Const_pb.HIT, 3 },
    { Const_pb.MAGDEF, 2 },
    { Const_pb.PHYDEF, 2 },
    { Const_pb.HP, 5 },
    { Const_pb.MAGIC_attr, 5 },
    { Const_pb.ATTACK_attr, 5 },
}
function AttributeContent:onRefreshContent(ccbRoot)
    local container = ccbRoot:getCCBFileNode()
    local key = AttributeSetting[self.id][1]
    local attrDataKey = NgSkinPage:getAttrDataKey(container)
    local attr = allAttrData[attrDataKey] or curRoleInfo.attribute.attribute
    local value = PBHelper:getAttrById(attr, key)
    if AttributeSetting[self.id][2] == 4 or AttributeSetting[self.id][2] == 6 then
        NodeHelper:setStringForLabel(container, { mAtt1 = common:getLanguageString("@Specialattr_" .. key) })
    else
        NodeHelper:setStringForLabel(container, { mAtt1 = common:getLanguageString("@Combatattr_" .. key) })
    end
    if AttributeSetting[self.id][2] == 4 then
        value = (value + 100) .. "%"
    end
    if AttributeSetting[self.id][2] == 1 or AttributeSetting[self.id][2] == 6 then
        value = value .. "%"
    end
    NodeHelper:setStringForLabel(container, { mAtt2 = value })
    if AttributeSetting[self.id][2] == 2 or AttributeSetting[self.id][2] == 3 then
        NodeHelper:setNodesVisible(container, { mAtt3 = true })
        NodeHelper:setStringForLabel(container, { mAtt3 = "(" .. EquipManager:getBattleAttrEffect(key, value, curRoleInfo.level) .. "%)" })
    else
        NodeHelper:setNodesVisible(container, { mAtt3 = false })
    end
    NodeHelper:setSpriteImage(container, { FightIcon = "attri_" .. key .. ".png" })
end
-----------------------------------------------------------------------------------------------------
function NgSkinPage:requestAttrInfo(container)
    local RoleOpr_pb = require("RoleOpr_pb")
    local msg = RoleOpr_pb.HPRoleCountAttrReq()
	msg.roleId = curRoleInfo.roleId
	msg.skinId = COSTUME_DATA.NOW_SKIN
    common:sendPacket(HP_pb.ROLE_ATTRINFO_COUNT_C, msg, false)
end

function NgSkinPage:clearAttrInfo(container)
    local attrScrollView = container:getVarScrollView("mAttrScrollView")
    attrScrollView:removeAllCell()
end

function NgSkinPage:showAllAttrInfo(container)
    local attrScrollView = container:getVarScrollView("mAttrScrollView")
    attrScrollView:removeAllCell()
    for i = 13, 1, -1 do
        local cell = CCBFileCell:create()
        cell:setCCBFile("AttributeBattleContent.ccbi")
        local handler = common:new( { id = i }, AttributeContent)
        cell:registerFunctionHandler(handler)
        attrScrollView:addCell(cell)
    end
    attrScrollView:orderCCBFileCells()
    attrScrollView:setTouchEnabled(false)
end

function NgSkinPage:showSkillInfo(container)
    -- 圖片顯示
    local skills
    if COSTUME_DATA.NOW_SKIN == 0 then
        skills = common:split(heroCfg.Skills, ",")
    else
        skills = common:split(skinCfg[COSTUME_DATA.NOW_SKIN].skills, ",")
    end
    local ownSkills = curRoleInfo.skills
    for i = 1, 4 do
        NodeHelper:setStringForLabel(container, { ["mSkillLv" .. i] = 0 })
    end
    for k, v in ipairs(skills) do  
        local skillBaseId = math.floor(v / 10)
        NodeHelper:setSpriteImage(container, { ["Skill" .. k] = "skill/S_" .. skillBaseId .. ".png" })
    end
    -- 等級顯示
    local nowSkills
    if curRoleInfo.skinId == 0 then
        nowSkills = common:split(heroCfg.Skills, ",")
    else
        nowSkills = common:split(skinCfg[curRoleInfo.skinId].skills, ",")
    end
    for k, v in ipairs(nowSkills) do  
        local skillBaseId = math.floor(v / 10)
        for i = 1, #ownSkills do
            local ownBaseId = math.floor(ownSkills[i].itemId / 10)
            if ownBaseId == tonumber(skillBaseId) then
                local level = string.sub(ownSkills[i].itemId, -1)
                NodeHelper:setStringForLabel(container, { ["mSkillLv" .. k] = level })
            end
        end
    end
end
------------------------------------------------------------------------------------------
-- Select Page
------------------------------------------------------------------------------------------
local CostumeItem = {
    ccbiFile = "EquipmentPageRoleContent_CostumeItem.ccbi",
}
function CostumeItem:onCostumeItem(container)
    if COSTUME_DATA.IS_MOVEING then
        return
    end
    if COSTUME_DATA.NOW_COSTUME_ID == self.id then
        return
    end
    COSTUME_DATA.NOW_COSTUME_ID = self.id
    selfContainer.mScrollView:setContentOffsetInDuration(ccp((COSTUME_DATA.NOW_COSTUME_ID - 1) * -1 * COSTUME_ITEM_WIDTH, 0), COSTUME_DATA.MOVE_TIME)
    COSTUME_DATA.NOW_SKIN = COSTUME_DATA.ALL_SKIN[COSTUME_DATA.NOW_COSTUME_ID] or 0
    NgSkinPage:refreshSkinUI(selfContainer)
end
function CostumeItem:onRefreshContent(ccbRoot)
    local container = ccbRoot:getCCBFileNode()
    self.container = container
    if not self.isShow then
        NodeHelper:setNodesVisible(self.container, { mNode = false })
        return
    end
    local skinImgName
    if self.skinId == 0 then
        skinImgName = "HeroSkin_" .. string.format("%02d000", itemId)
    else
        skinImgName = "HeroSkin_" .. string.format("%05d", self.skinId)
    end
    local element = (self.skinId == 0) and heroCfg.Element or skinCfg[self.skinId].element

    NodeHelper:setMenuItemImage(self.container, { mCostumeBtn = { normal = "UI/RoleSkinSeries/" .. skinImgName .. ".png", 
                                                                  press = "UI/RoleSkinSeries/" .. skinImgName .. ".png" } })
    NodeHelper:setNodesVisible(self.container, { mMask = (self.skinId ~= COSTUME_DATA.NOW_SKIN), mNode = true })
    NodeHelper:setSpriteImage(self.container, { mElementImg = GameConfig.MercenaryElementImg[element] })

    NodeHelper:setNodeScale(self.container, "mNode", self.scale / 1000, self.scale / 1000)
end

function NgSkinPage:checkItemInView(container, i)
    local offset = container.mScrollView:getContentOffset()
    local centerOffsetX = (i - 1) * -1 * COSTUME_ITEM_WIDTH + COSTUME_ITEM_WIDTH -- 該卡牌在中心時的offsetX
    local diffOffsetX = math.abs(offset.x - centerOffsetX)  -- 中心跟實際offsetX的差絕對值
    return diffOffsetX < 480
end

function NgSkinPage:initSkinItem(container)
    container.mScrollView = container:getVarScrollView("mContent")
    COSTUME_DATA.COSTUME_ITEMS = { }
    COSTUME_DATA.IS_MOVEING = false
    COSTUME_DATA.NOW_COSTUME_ID = 1
    container.mScrollView:removeAllCell()
    -- 最前面塞入一個空物件
    local cell = CCBFileCell:create()
    cell:setCCBFile(CostumeItem.ccbiFile)
    local handler = common:new( { id = 0, skinId = 0, isShow = false }, CostumeItem)
    cell:registerFunctionHandler(handler)
    container.mScrollView:addCell(cell)
    table.insert(COSTUME_DATA.COSTUME_ITEMS, handler)
    for i = 1, #COSTUME_DATA.ALL_SKIN do
        local cell = CCBFileCell:create()
        cell:setCCBFile(CostumeItem.ccbiFile)
        local handler = common:new( { id = i, skinId = COSTUME_DATA.ALL_SKIN[i], isShow = true, scale = 1 }, CostumeItem)
        cell:registerFunctionHandler(handler)
        container.mScrollView:addCell(cell)
        table.insert(COSTUME_DATA.COSTUME_ITEMS, handler)
        if COSTUME_DATA.ALL_SKIN[i] == COSTUME_DATA.NOW_SKIN then
            COSTUME_DATA.NOW_COSTUME_ID = i
        end
    end
    -- 最後面塞入一個空物件
    local cell = CCBFileCell:create()
    cell:setCCBFile(CostumeItem.ccbiFile)
    local handler = common:new( { id = #COSTUME_DATA.ALL_SKIN + 1, skinId = 0, isShow = false, scale = 1 }, CostumeItem)
    cell:registerFunctionHandler(handler)
    container.mScrollView:addCell(cell)
    table.insert(COSTUME_DATA.COSTUME_ITEMS, handler)
    container.mScrollView:setBounceable(false)
    container.mScrollView:orderCCBFileCells()

    container.mScrollView:setContentOffsetInDuration(ccp((COSTUME_DATA.NOW_COSTUME_ID - 1) * -1 * COSTUME_ITEM_WIDTH, 0), 0)
end
function NgSkinPage:refreshSkinUI(container)
    for i = 1, #COSTUME_DATA.COSTUME_ITEMS do
        if COSTUME_DATA.COSTUME_ITEMS[i].isShow and self:checkItemInView(container, i) then
            NodeHelper:setNodesVisible(COSTUME_DATA.COSTUME_ITEMS[i].container, { mMask = (COSTUME_DATA.COSTUME_ITEMS[i].skinId ~= COSTUME_DATA.NOW_SKIN) })
        end
    end
    self:refreshPage(container)
    self:showRoleSpine(container)
end
function NgSkinPage:refreshEquipBtn(container)
    local btnTxt = ""
    if COSTUME_DATA.OWN_SKIN[COSTUME_DATA.NOW_SKIN] then
        if curRoleInfo.skinId == COSTUME_DATA.NOW_SKIN then
            btnType = BTN_TYPE.DISABLE_EQUIPED
            btnTxt = common:getLanguageString("@Skin_Applying")
        else
            btnType = BTN_TYPE.ENABLE
            btnTxt = common:getLanguageString("@Skin_Apply")
        end
    else
        btnType = BTN_TYPE.ENABLE_HAVENT
        btnTxt = common:getLanguageString("@Unlock")
    end
    NodeHelper:setStringForLabel(container, { mEquipBtnTxt = btnTxt })
    NodeHelper:setMenuItemEnabled(container, "mEquipBtn", (btnType ~= BTN_TYPE.DISABLE_EQUIPED))
end
------------------------------------------------------------------------------------------
function NgSkinPage:setPageInfo(_roleId, _skinId)
    curRoleInfo = UserMercenaryManager:getUserMercenaryById(_roleId)
    itemId = curRoleInfo.itemId
    COSTUME_DATA.NOW_SKIN = _skinId
end

function NgSkinPage:registerPacket(container)
    for key, opcode in pairs(option.opcodes) do
        if string.sub(key, -1) == "S" then
            container:registerPacket(opcode)
        end
    end
end
function NgSkinPage:removePacket(container)
    for key, opcode in pairs(option.opcodes) do
        if string.sub(key, -1) == "S" then
            container:removePacket(opcode)
        end
    end
end
function NgSkinPage:onReceivePacket(container)
    local opcode = container:getRecPacketOpcode()
    local msgBuff = container:getRecPacketBuffer()

    if opcode == HP_pb.ROLE_CHANGE_SKIN_S then
        MessageBoxPage:Msg_Box_Lan(common:getLanguageString("@Skin_ApplyCompleted"))
        NgSkinPage:refreshPage(container)
    end
    if opcode == HP_pb.ROLE_ATTRINFO_COUNT_S then  -- 屬性資料
        local msg = RoleOpr_pb.HPRoleCountAttrRes()
        msg:ParseFromString(msgBuff)
        local roleId = msg.roleId
        local attr = msg.attribute.attribute
        local key = self:getAttrDataKey(container)
        allAttrData[key] = attr
        self:showAllAttrInfo(container)
    end
    if opcode == HP_pb.SHOP_BUY_S then
        self:initSkinData(container)
        NgSkinPage:refreshPage(container)
    end
end

function NgSkinPage:getAttrDataKey(container)
    return string.format("%02d", itemId) .. string.format("%02d", COSTUME_DATA.NOW_COSTUME_ID) .. string.format("%02d", curRoleInfo.starLevel) .. string.format("%03d", curRoleInfo.level)
end

local CommonPage = require('CommonPage')
NgSkinPage = CommonPage.newSub(NgSkinPage, thisPageName, option)
return NgSkinPage