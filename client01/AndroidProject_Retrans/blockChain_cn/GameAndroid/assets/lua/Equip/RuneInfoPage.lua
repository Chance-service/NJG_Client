---- 符文資訊頁面
local FateDataManager = require("FateDataManager")
local MysticalDress_pb = require("Badge_pb")
local RuneInfoPage = { }

local thisPageName = "RuneInfoPage"
local option = {
    ccbiFile = "RunePopUp.ccbi",
    handlerMap = {
        onClose = "onClose" ,
        onFusion = "onFusion",
        onChange = "onChange",
        onEquip = "onEquip",
    },
    opcodes = {
        MYSTICAL_DRESS_CHANGE_C = HP_pb.BADGE_DRESS_C,
        MYSTICAL_DRESS_CHANGE_S = HP_pb.BADGE_DRESS_S,
    },
}
local IllItemContent = {
    ccbiFile = "EquipmentItem_Rune.ccbi"
}
local MAX_ATTR_NUM = 4
local pageContainer = nil
local runeInfo = nil
local nowPageType = 0
local nowRuneId = 0
local nowRoleId = nil
local nowPos = nil

function RuneInfoPage:onEnter(container)
    pageContainer = container
    self:registerPacket(container)
    self:initData(container)
    self:initUI(container)
    self:refreshPage(container)
end

function RuneInfoPage:initData(container)
    local nonWearRuneTable = FateDataManager:getAllFateList()
    runeInfo = nil
    for i = 1, #nonWearRuneTable do
        if nonWearRuneTable[i].id == nowRuneId then
            runeInfo = nonWearRuneTable[i]
            break
        end
    end
end

function RuneInfoPage:initUI(container)
    -- 符文資訊
    if runeInfo then
        local cfg = ConfigManager.getFateDressCfg()[runeInfo.itemId]
        local fullName = common:getLanguageString(cfg.name) .. 
                        (runeInfo.skill > 0 and common:getLanguageString("@Eye_Name_" .. math.floor(runeInfo.skill / 100) % 100) or "") ..
                         common:getLanguageString("@Rune")
        NodeHelper:setStringForLabel(container, { mRuneName = fullName })
        local attrInfo = { }
        local basicInfo = common:split(cfg.basicAttr, ",")
        local randInfo = common:split(runeInfo.attr, ",")
        for i = 1, #basicInfo do
            table.insert(attrInfo, basicInfo[i])
        end
        for i = 1, #randInfo do
            if string.find(randInfo[i], "_") then
                table.insert(attrInfo, randInfo[i])
            end
        end
        for i = 1, MAX_ATTR_NUM do
            if attrInfo[i] then
                NodeHelper:setNodesVisible(container, { ["mAttrNode" .. i] = true })
                local attrId, attrNum = unpack(common:split(attrInfo[i], "_"))
                NodeHelper:setSpriteImage(container, { ["mAttrImg" .. i] = "attri_" .. attrId .. ".png" })
                NodeHelper:setStringForLabel(container, { ["mAttrName" .. i] = common:getLanguageString("@AttrName_" .. attrId),
                                                          ["mAttrValue" .. i] = attrNum })
            else
                NodeHelper:setNodesVisible(container, { ["mAttrNode" .. i] = false })
            end
        end
        if runeInfo.skill > 0 then
            NodeHelper:setNodesVisible(container, { mEffectNode = true, mSkillNullStr = false })
            local baseSkillId = math.floor(runeInfo.skill / 10)
            NodeHelper:setSpriteImage(container, { mSkillIcon = "skill/S_" .. baseSkillId .. ".png" })
            NodeHelper:setStringForLabel(container, { mSkillName = common:getLanguageString("@Skill_Name_" .. runeInfo.skill) })
            -- 技能說明
            local freeTypeId = runeInfo.skill
            local skillDesNode = container:getVarNode("mSkillDes")
            skillDesNode:removeAllChildren()
            local htmlLabel = CCHTMLLabel:createWithString((FreeTypeConfig[freeTypeId] and FreeTypeConfig[freeTypeId].content or ""),
                                                           CCSizeMake(400, 50), "Barlow-SemiBold")
            local htmlSize = htmlLabel:getContentSize()
            htmlLabel:setAnchorPoint(ccp(0, 1))
            skillDesNode:addChild(htmlLabel)
        else
            NodeHelper:setNodesVisible(container, { mEffectNode = false, mSkillNullStr = true })
        end
    else
        NodeHelper:setStringForLabel(container, { mRuneNmae = "" })
        for i = 1, MAX_ATTR_NUM do
            NodeHelper:setNodesVisible(container, { ["mAttrNode" .. i] = false })
        end
        NodeHelper:setNodesVisible(container, { mEffectNode = false, mSkillNullStr = true })
    end
    -- 按鈕顯示
    NodeHelper:setNodesVisible(container, { mBtnNode1 = (nowPageType ~= GameConfig.RuneInfoPageType.FUSION),
                                            mBtnNode2 = (nowPageType ~= GameConfig.RuneInfoPageType.FUSION),
                                            mBtnNode3 = (nowPageType ~= GameConfig.RuneInfoPageType.FUSION) })
    NodeHelper:setMenuItemEnabled(container, "mBtn1", nowPageType ~= GameConfig.RuneInfoPageType.FUSION)
    NodeHelper:setMenuItemEnabled(container, "mBtn2", nowPageType == GameConfig.RuneInfoPageType.EQUIPPED)
    NodeHelper:setMenuItemEnabled(container, "mBtn3", nowPageType ~= GameConfig.RuneInfoPageType.FUSION)
    if nowPageType == GameConfig.RuneInfoPageType.EQUIPPED then
        NodeHelper:setStringForLabel(container, { mBtnTxt3 = common:getLanguageString("@TakeOff") })
    else
        NodeHelper:setStringForLabel(container, { mBtnTxt3 = common:getLanguageString("@Mosaic") })
    end
end

function RuneInfoPage:onFusion(container)
    if LockManager_getShowLockByPageName(GameConfig.LOCK_PAGE_KEY.FORGE) then
        MessageBoxPage:Msg_Box(LockManager_getLockStringByPageName(GameConfig.LOCK_PAGE_KEY.FORGE))
    else
        require("EquipIntegrationPage")
        EquipIntegrationPage_SetCurrentPageIndex(1)
        PageManager.pushPage("EquipIntegrationPage")
    end
    
    PageManager.popPage(thisPageName)
end

function RuneInfoPage:onChange(container)
    require("FateWearsSelectPage")
    FateWearsSelectPage_setFate({ roleId = nowRoleId, locPos = nowPos, currentFateId = nowRuneId })
    PageManager.pushPage("FateWearsSelectPage")
end

function RuneInfoPage:onEquip(container)
    if nowPageType == GameConfig.RuneInfoPageType.EQUIPPED then
        if nowRuneId and nowRoleId and nowPos then
            local msg = MysticalDress_pb.HPMysticalDressChange()
            msg.roleId = nowRoleId
            msg.loc = nowPos
            msg.type = 2 -- 1: 裝備符石 2: 脫下符石 3: 交換符石
            msg.offEquipId = nowRuneId
            common:sendPacket(option.opcodes.MYSTICAL_DRESS_CHANGE_C, msg)

            MessageBoxPage:Msg_Box("@RemoveEquip")
        end
    elseif nowPageType == GameConfig.RuneInfoPageType.NON_EQUIPPED then
        PageManager.popPage(thisPageName)
        MainFrame_onLeaderPageBtn()
    end
end

function RuneInfoPage:refreshPage(container)
    local itemNode = ScriptContentBase:create(IllItemContent.ccbiFile)
    local parentNode = container:getVarNode("mIconNode")
    itemNode:setAnchorPoint(ccp(0.5, 0.5))
    parentNode:removeAllChildren()
    IllItemContent:refresh(itemNode)
    parentNode:addChild(itemNode)
end
------------------------------------------------
function IllItemContent:refresh(container)
    if runeInfo then
        local cfg = ConfigManager.getFateDressCfg()[runeInfo.itemId]
        NodeHelper:setNodesVisible(container, { mCheckNode = false, mStarNode = true })
        NodeHelper:setSpriteImage(container, { mPic = cfg.icon, mFrameShade = NodeHelper:getImageBgByQuality(cfg.rare), 
                                               mFrame = NodeHelper:getImageByQuality(cfg.rare) })
        for star = 1, 6 do
            NodeHelper:setNodesVisible(container, { ["mStar" .. star] = (star == cfg.star) })
        end
    else
        NodeHelper:setNodesVisible(container, { mCheckNode = false, mStarNode = false })
        NodeHelper:setSpriteImage(container, { mPic = "UI/Mask/Image_Empty.png", mFrameShade = "UI/Mask/Image_Empty.png", mFrame = "UI/Mask/Image_Empty.png" })
    end
end
------------------------------------------------
function RuneInfoPage:registerPacket(container)
    for key, opcode in pairs(option.opcodes) do
		if string.sub(key, -1) == "S" then
			container:registerPacket(opcode)
		end
	end
end

function RuneInfoPage:removePacket(container)
	for key, opcode in pairs(option.opcodes) do
		if string.sub(key, -1) == "S" then
			container:removePacket(opcode)
		end
	end
end

function RuneInfoPage:onReceivePacket(container)
    local opcode = container:getRecPacketOpcode()
    if opcode == option.opcodes.MYSTICAL_DRESS_CHANGE_S then
        PageManager.refreshPage("EquipLeadPage", "refreshPage")
        PageManager.popPage(thisPageName)
    end
end

function RuneInfoPage:onClose()
    runeInfo = nil
    nowPageType = 0
    nowRuneId = 0
    nowRoleId = nil
    nowPos = nil
    PageManager.popPage(thisPageName)
end

function RuneInfoPage_setPageInfo(pageType, runeId, roleId, pos)
    nowPageType = pageType
    nowRuneId = runeId
    nowRoleId = roleId
    nowPos = pos
end

local CommonPage = require("CommonPage")
RuneInfoPage = CommonPage.newSub(RuneInfoPage, thisPageName, option)

return RuneInfoPage