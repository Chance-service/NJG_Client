-- 符石裝備選擇介面
local FateWearsSelectPageBase = { }
local HP_pb = require("HP_pb")
local MysticalDress_pb = require("Badge_pb")
local NodeHelper = require("NodeHelper")
local FateDataManager = require("FateDataManager")
local UserMercenaryManager = require("UserMercenaryManager")
local option = {
	ccbiFile = "RuneSelectPopUp.ccbi",
	handlerMap = {
        onDisEquip = "onDisEquip",
        onClose = "onClose",
	},
	opcode = {
        -- 裝備符石
        MYSTICAL_DRESS_CHANGE_C = HP_pb.BADGE_DRESS_C,
        MYSTICAL_DRESS_CHANGE_S = HP_pb.BADGE_DRESS_S,
    },
}
local ItemInfo = FateDataManager.FateWearSelectItem
local currRuneData = { }

local PageInfo = {
    roleId =  nil,  --角色ID
    locPos = nil, --裝備位置
    currentFateData = nil, --當前裝備的符石
    fateIdList = { },
    bg1DefaultSize = nil,
    bg2DefaultSize = nil,
    bg3DefaultSize = nil,
}

local function sortFates(fateData_1, fateData_2)
    local conf_1 = fateData_1:getConf()
    local conf_2 = fateData_2:getConf()
    if conf_1.rare ~= conf_2.rare then
        return conf_1.rare > conf_2.rare
    end
    if conf_1.star ~= conf_2.star then
        return conf_1.star > conf_2.star
    end
    local score1 = UserEquipManager:calAttrScore(conf_1.basicAttr) + UserEquipManager:calAttrScore(fateData_1.attr)
    local score2 = UserEquipManager:calAttrScore(conf_2.basicAttr) + UserEquipManager:calAttrScore(fateData_2.attr)
    if score1 ~= score2 then
        return score1 > score2
    end
end
--------------------------------------------------------------------------
local FateWearsSelectItem = { }

function FateWearsSelectItem.onFunction(eventName,container)
    if eventName == "luaInitItemView" then
		FateWearsSelectItem.onRefreshItemView(container)
	elseif eventName == "onEquipRune" then
		FateWearsSelectItem.onEquipRune(container)
	end
end

function FateWearsSelectItem.onRefreshItemView(container)
	local contentId = container:getTag()
	local fateData = PageInfo.fateIdList[contentId]
    if not fateData then return end
    
    local conf = fateData:getConf()
    local fullName = common:getLanguageString(conf.name) .. 
                    (fateData.skill > 0 and common:getLanguageString("@Eye_Name_" .. math.floor(fateData.skill / 100) % 100) or "") ..
                     common:getLanguageString("@Rune")
    local attrs = { }
    local basicInfo = common:split(conf.basicAttr, ",")
    local randInfo = common:split(fateData.attr, ",")
    for i = 1, #basicInfo do
        table.insert(attrs, basicInfo[i])
    end
    for i = 1, #randInfo do
        if string.find(randInfo[i], "_") then
            table.insert(attrs, randInfo[i])
        end
    end
    for i = 1, 3 do
        if attrs[i] then
            local attr, value = unpack(common:split(attrs[i], "_"))
            NodeHelper:setNodesVisible(container, { ["mAttrNode" .. i] = true })
            NodeHelper:setSpriteImage(container, { ["mAttrImg" .. i] = "attri_" .. attr .. ".png" })
            NodeHelper:setStringForLabel(container, { ["mAttrTxt" .. i] = value })
            -- 比較當前符石屬性
            if currRuneData[attr] then
                local diff = value - currRuneData[attr]
                if diff > 0 then
                    NodeHelper:setStringForLabel(container, { ["mAttrTxt" .. i .. "_" .. i] = "(+" .. diff .. ")" })
                    NodeHelper:setColorForLabel(container, { ["mAttrTxt" .. i .. "_" .. i] = GameConfig.ATTR_CHANGE_COLOR.PLUS })
                elseif diff < 0 then
                    NodeHelper:setStringForLabel(container, { ["mAttrTxt" .. i .. "_" .. i] = "(" .. diff .. ")" })
                    NodeHelper:setColorForLabel(container, { ["mAttrTxt" .. i .. "_" .. i] = GameConfig.ATTR_CHANGE_COLOR.MINUS })
                else
                    NodeHelper:setStringForLabel(container, { ["mAttrTxt" .. i .. "_" .. i] = "" })
                end
            else
                NodeHelper:setStringForLabel(container, { ["mAttrTxt" .. i .. "_" .. i] = "(+" .. value .. ")" })
                NodeHelper:setColorForLabel(container, { ["mAttrTxt" .. i .. "_" .. i] =  GameConfig.ATTR_CHANGE_COLOR.PLUS })
            end
        else
            NodeHelper:setNodesVisible(container, { ["mAttrNode" .. i] = false })
        end
    end
    local strMap = {
        mRuneName = fullName,
    }
    local childNode = container:getVarMenuItemCCB("mIcon")
    childNode = childNode:getCCBFile()
    local sprite2Img = { }
    sprite2Img["mBg"] = NodeHelper:getImageBgByQuality(conf.rare)
    sprite2Img["mPic"] = conf.icon
    sprite2Img["mFrame"] = NodeHelper:getImageByQuality(conf.rare)
    NodeHelper:setSpriteImage(childNode, sprite2Img)
    NodeHelper:setNodesVisible(childNode, { mLock = false, mPoint = false, mStarNode = true })
    for star = 1, 6 do
        NodeHelper:setNodesVisible(childNode, { ["mStar" .. star] = (star == conf.star) })
    end
    NodeHelper:setStringForLabel(container, strMap)

    if fateData.roleId then
        local curRoleInfo = UserMercenaryManager:getUserMercenaryById(fateData.roleId)
        itemId = curRoleInfo.itemId
        NodeHelper:setNodesVisible(container, { mBtnNode1 = false, mBtnNode2 = true })
        NodeHelper:setStringForLabel(container, { mHeroName = common:getLanguageString("@HeroName_" .. itemId) })
    else
        NodeHelper:setNodesVisible(container, { mBtnNode1 = true, mBtnNode2 = false })
    end
end

function FateWearsSelectItem.onEquipRune(container)
    local contentId = container:getTag()
	local fateData = PageInfo.fateIdList[contentId]
    if not fateData then return end
    local msg = MysticalDress_pb.HPMysticalDressChange()
    if PageInfo.currentFateData then
        msg.type = 3
        msg.offEquipId = PageInfo.currentFateData.id
    else
        msg.type = 1
    end
    msg.roleId = PageInfo.roleId
    msg.loc = PageInfo.locPos
    msg.onEquipId = fateData.id
    common:sendPacket(HP_pb.BADGE_DRESS_C, msg)

    MessageBoxPage:Msg_Box("@HasEquiped")
end
------------------------------------------------------------------------
function FateWearsSelectPageBase:onEnter(container)
    PageInfo.fateIdList = FateDataManager:getAllFateList2(PageInfo.roleId) or { }

    table.sort(PageInfo.fateIdList, sortFates)
    FateWearsSelectPageBase:registerPacket(container)
    FateWearsSelectPageBase:initPage(container)
    FateWearsSelectPageBase:showCurrentFateInfo(container)
    FateWearsSelectPageBase:BuildAllItems(container)
    -- 新手教學
    local GuideManager = require("Guide.GuideManager")
    GuideManager.PageContainerRef["RuneSelectPage"] = container
    if GuideManager.isInGuide then
        PageManager.pushPage("NewbieGuideForcedPage")
    end
end

function FateWearsSelectPageBase:initPage(container)
    NodeHelper:initRawScrollView(container, "mContent")
    local isEquip = PageInfo.currentFateData and true or false
    NodeHelper:setNodesVisible(container, { mPageType1 = isEquip, mPageType2 = not isEquip })
    currRuneData = { }
end

function FateWearsSelectPageBase:showCurrentFateInfo(container)
    if PageInfo.currentFateData then
        local conf = PageInfo.currentFateData:getConf()
        local fullName = common:getLanguageString(conf.name) .. 
                        (PageInfo.currentFateData.skill > 0 and common:getLanguageString("@Eye_Name_" .. math.floor(PageInfo.currentFateData.skill / 100) % 100) or "") ..
                         common:getLanguageString("@Rune")
        local attrs = common:split(conf.basicAttr, ",")
        local randInfo = common:split(PageInfo.currentFateData.attr, ",")
        for i = 1, #randInfo do
            table.insert(attrs, randInfo[i])
        end
        for i = 1, 3 do
            if attrs[i] then
                local attr, value = unpack(common:split(attrs[i], "_"))
                NodeHelper:setNodesVisible(container, { ["mAttrNode" .. i] = true })
                NodeHelper:setSpriteImage(container, { ["mAttrImg" .. i] = "attri_" .. attr .. ".png" })
                NodeHelper:setStringForLabel(container, { ["mAttrTxt" .. i] = value })
                currRuneData[attr] = value
            else
                NodeHelper:setNodesVisible(container, { ["mAttrNode" .. i] = false })
            end
        end
        local strMap = {
            mRuneName = fullName,
        }
        local childNode = container:getVarMenuItemCCB("mIcon")
        childNode = childNode:getCCBFile()
        local sprite2Img = { }
        sprite2Img["mBg"] = NodeHelper:getImageBgByQuality(conf.rare)
        sprite2Img["mPic"] = conf.icon
        sprite2Img["mFrame"] = NodeHelper:getImageByQuality(conf.rare)
        NodeHelper:setSpriteImage(childNode, sprite2Img)
        NodeHelper:setNodesVisible(childNode, { mLock = false, mPoint = false, mStarNode = true }) 
        for star = 1, 6 do
            NodeHelper:setNodesVisible(childNode, { ["mStar" .. star] = (star == conf.star) })
        end
        NodeHelper:setStringForLabel(container, strMap)
    else
        local childNode = container:getVarMenuItemCCB("mIcon")
        childNode = childNode:getCCBFile()
        local sprite2Img = { }
        sprite2Img["mBg"] = "UI/Mask/Image_Empty.png"
        sprite2Img["mPic"] = "UI/Mask/Image_Empty.png"
        sprite2Img["mFrame"] = "UI/Mask/Image_Empty.png"
        NodeHelper:setSpriteImage(childNode, sprite2Img)
        NodeHelper:setNodesVisible(childNode, { mLock = false, mPoint = false, mStarNode = false })
    end
end

function FateWearsSelectPageBase:BuildAllItems(container)
    NodeHelper:clearScrollView(container)
    local items = nil
    if #PageInfo.fateIdList > 0 then
        items = NodeHelper:buildRawScrollView(container, #PageInfo.fateIdList, ItemInfo.ccbiFile, FateWearsSelectItem.onFunction)
    end
    if items and items[1] then
        local GuideManager = require("Guide.GuideManager")
        GuideManager.PageContainerRef["RuneSelectItem"] = items[1]
    end
end

function FateWearsSelectPageBase:onDisEquip(container)
    local msg = MysticalDress_pb.HPMysticalDressChange()
    msg.roleId = PageInfo.roleId
    msg.loc = PageInfo.locPos
    msg.type = 2 -- 1: 裝備符石 2: 脫下符石 3: 交換符石
    msg.offEquipId = PageInfo.currentFateData.id
    common:sendPacket(option.opcode.MYSTICAL_DRESS_CHANGE_C, msg)

    MessageBoxPage:Msg_Box("@RemoveEquip")
end

function FateWearsSelectPageBase:onExit(container)
    FateWearsSelectPageBase:removePacket(container)
    local currentNode = container:getVarNode("mNowNode")
    if currentNode then
        currentNode:removeAllChildren()
    end
    NodeHelper:deleteScrollView(container)
end

function FateWearsSelectPageBase:onClose(container)
    PageManager.popPage("FateWearsSelectPage")
end

function FateWearsSelectPageBase:registerPacket(container)
    for key, opcode in pairs(option.opcode) do
		if string.sub(key, -1) == "S" then
			container:registerPacket(opcode)
		end
	end
end

function FateWearsSelectPageBase:removePacket(container)
	for key, opcode in pairs(option.opcode) do
		if string.sub(key, -1) == "S" then
			container:removePacket(opcode)
		end
	end
end

function FateWearsSelectPageBase:onReceivePacket(container)
    local opcode = container:getRecPacketOpcode()
    if opcode == option.opcode.MYSTICAL_DRESS_CHANGE_S then
        PageManager.refreshPage("EquipLeadPage", "refreshPage")
        PageManager.popPage("FateWearsSelectPage")
        -- 新手教學
        local GuideManager = require("Guide.GuideManager")
        if GuideManager.isInGuide then
            PageManager.pushPage("NewbieGuideForcedPage")
        end
    end
end

--roleId 角色Id
--locPos 穿戴位置
--currentFateId 當前穿戴的浮石Id 
function FateWearsSelectPage_setFate(data)
    PageInfo.roleId = data.roleId
    PageInfo.locPos = data.locPos
    PageInfo.currentFateData = FateDataManager:getFateDataById(data.currentFateId)
end

local CommonPage = require("CommonPage")
FateWearsSelectPage = CommonPage.newSub(FateWearsSelectPageBase, "FateWearsSelectPage", option)