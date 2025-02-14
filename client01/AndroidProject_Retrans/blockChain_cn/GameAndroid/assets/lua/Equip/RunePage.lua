----------------------------------------------------------------------------------
-- 符文合成
----------------------------------------------------------------------------------
local HP_pb = require("HP_pb")
local Badge_pb = require("Badge_pb")
local UserInfo = require("PlayerInfo.UserInfo")
local FateDataManager = require("FateDataManager")
------------local variable for system api--------------------------------------
local pairs = pairs
--------------------------------------------------------------------------------
-- registerScriptPage(buildPage)

local thisPageName = "RunePage"

local opcodes = {
    BADGE_FUSION_C = HP_pb.BADGE_FUSION_C,
    BADGE_FUSION_S = HP_pb.BADGE_FUSION_S,
    ERROR_CODE_S = HP_pb.ERROR_CODE
}

local RUNE_ITME_NUM = 5

local option = {
    ccbiFile = "RefiningPopUp.ccbi",
    handlerMap =
    {
        onHelp = "showHelp",
        onClose = "onClose",
        onAddAll = "onAddAll",
        onForge = "onForge",
        onSkillDetail = "onSkillDetail",
    },
    opcode = opcodes
}

for i = 1, RUNE_ITME_NUM do
    option.handlerMap["onHand"] = "goSelectEquip"
end

local RunePageBase = { ccbiFile = "RefiningPopUp.ccbi" }

local NodeHelper = require("NodeHelper")
local PBHelper = require("PBHelper")
local EquipOprHelper = require("Equip.EquipOprHelper")
local ItemManager = require("Item.ItemManager")

local items = { }
local spines = { }
local selectInfos = { }
local btnLock = false
local isFirstEnter = true
local mParentContainer = nil
local selfContainer = nil
local selectRank = nil
local batchMeltreFiningValue = 0
local meltreFiningValue = 0

local RuneItem = {
    ccbiFile = "EquipmentItem_Rune.ccbi",
}
local RuneAttrItem = {
    ccbiFile = "RefiningPopUpContent.ccbi",
}
function RuneItem:new(o)
    o = o or { }
    setmetatable(o, self)
    self.__index = self
    return o
end

function RuneItem:refresh(container)
    local iconBgSprite = "UI/Mask/Image_Empty.png"
    NodeHelper:setNodesVisible(container, { mCheckNode = false, mStarNode = false })
    NodeHelper:setSpriteImage(container, { mPic = "UI/Mask/Image_Empty.png", mFrameShade = "UI/Mask/Image_Empty.png", mFrame = "UI/Mask/Image_Empty.png" })
end

function RuneItem.onFunction(eventName, container)
    if eventName == "onHand" then
        PageManager.pushPage("RuneBuildSelectPage")
    end
end

function RunePageBase:onEnter(ParentContainer)
    
    mParentContainer = ParentContainer

    self.container = ScriptContentBase:create(option.ccbiFile)
    self.container:registerFunctionHandler(RunePageBase.onFunction)
    selfContainer = self.container

    btnLock = false
    
    self:registerPacket(mParentContainer)
    mParentContainer:registerMessage(MSG_MAINFRAME_REFRESH)
    -- self.container:registerMessage(MSG_MAINFRAME_REFRESH)

    self:initRuneItem(self.container)
    self:initSpine(self.container)
    self:resetTopNodePos(self.container)
    self:refreshPage(self.container, ParentContainer)

    NodeHelper:setNodesVisible(self.container, { mRuneNode6 = false })

    return self.container
end

function RunePageBase:onExit(container)
    selectInfos = { }
    batchMeltreFiningValue = 0
    meltreFiningValue = 0
    btnLock = false

    self:removePacket(mParentContainer)

    mParentContainer:removeMessage(MSG_MAINFRAME_REFRESH)
end
----------------------------------------------------------------
function RunePageBase:refreshPage(container)
    self:refreshUserInfo(container)
    --self:showMeltInfo(container)
    --self:showSourceEquips(container)
end

function RunePageBase:resetTopNodePos(container)
    local visibleSize = CCEGLView:sharedOpenGLView():getFrameSize()
    offsetY = math.max(visibleSize.height - GameConfig.ScreenSize.height, 0)
    local node = container:getVarNode("mSkillDetailNode")
    node:setPositionY(offsetY)
end

-- 刷新玩家金幣&鑽石數量
function RunePageBase:refreshUserInfo(container)
    local coinStr = GameUtil:formatNumber(UserInfo.playerInfo.coin)
    local diamondStr = GameUtil:formatNumber(UserInfo.playerInfo.gold)
    local txt = mParentContainer:getVarLabelTTF("mDiamond")
    font = txt:getFontName()
    NodeHelper:setStringForLabel(mParentContainer, { mCoin = coinStr, mDiamond = diamondStr })
end

function RunePageBase:initRuneItem(container)
    items = { }
    for i = 1, RUNE_ITME_NUM do
        local itemNode = ScriptContentBase:create(RuneItem.ccbiFile)
        local parentNode = container:getVarNode("mRuneNode" .. i)
        itemNode:registerFunctionHandler(RuneItem.onFunction)
        itemNode:setAnchorPoint(ccp(0.5, 0.5))
        parentNode:removeAllChildren()
        RuneItem:refresh(itemNode)
        parentNode:addChild(itemNode)
        table.insert(items, itemNode)
    end
end

function RunePageBase:initSpine(container)
    spines = { }
    for i = 1, RUNE_ITME_NUM do
        local parentNode = container:getVarNode("mSpineNode" .. i)
        local spine = SpineContainer:create("NGUI", "NGUI_17_RuneSelect")
        local spineNode = tolua.cast(spine, "CCNode")
        parentNode:addChild(spineNode)
        table.insert(spines, spine)
    end
    local parentNode = container:getVarNode("mSpineNode6")
    local spine = SpineContainer:create("NGUI", "NGUI_18_RuneForge")
    local spineNode = tolua.cast(spine, "CCNode")
    parentNode:addChild(spineNode)
    table.insert(spines, spine)
end
----------------click event------------------------
function RunePageBase:onClose(container, eventName)
    PageManager.popPage(thisPageName)
end	

function RunePageBase:onAddAll(container, eventName)
    local nonWearRuneTable = FateDataManager:getNotWearFateList()
    if #nonWearRuneTable <= 0 then
        return
    end
    table.sort(nonWearRuneTable, function(v1, v2)
        local conf1 = v1:getConf()
        local conf2 = v2:getConf()
        if conf1.rank ~= conf2.rank then
            return conf1.rank < conf2.rank
        end
        if v1.skill ~= v2.skill then
            return v1.skill < v2.skill
        end
        return false
    end)
    -- 分類不同等級符石
    local index = 1
    local nowLevel = 1
    selectInfos = { }
    local tempInfo = { }
    for i = 1, #nonWearRuneTable do
        local conf = nonWearRuneTable[i]:getConf()
        if conf.afterId ~= -1 then  -- afterId = -1無法合成
            tempInfo[conf.rank] = tempInfo[conf.rank] or { }
            table.insert(tempInfo[conf.rank], nonWearRuneTable[i])
        end
    end
    -- 搜尋最終顯示的符石等級
    local tarLevel = 0
    for i = 1, 20 do 
        local runeNum = tempInfo[i] and #tempInfo[i] or 0
        if runeNum >= RUNE_ITME_NUM then
            tarLevel = i
            break
        end
        if runeNum > 0 and tarLevel == 0 then
            tarLevel = i
        end
    end
    -- 更新選擇資料
    local finalInfo = { }
    for i = 1, math.min(RUNE_ITME_NUM, #tempInfo[tarLevel]) do
        finalInfo[i] = tempInfo[tarLevel][i]
    end
    if #finalInfo > 0 then
        RunePageBase_setSelectInfo(finalInfo)
    end
end	

function RunePageBase:onForge(container, eventName)
    if #selectInfos < RUNE_ITME_NUM then
        return
    end
    local hasSkill=false
    for i = 1, #selectInfos do
        if selectInfos[i].skill~=0 then
            hasSkill=true
            break
        end
    end
    if hasSkill then
        local title=common:getLanguageString("@HintTitle")
        local message=common:getLanguageString("@RuneSynthesisNotice")
        PageManager.showConfirm(title, message, function(isSure)
            if isSure then
               RunePageBase:sendReq()
            end
        end );
    else
        RunePageBase:sendReq()
    end
end
function RunePageBase:sendReq()
    local msg = Badge_pb.HPBadgeFusionReq()
    for i = 1, #selectInfos do
        if selectInfos[i] then
            msg.fusionIds:append(selectInfos[i].id)
        end
    end
    common:sendPacket(opcodes.BADGE_FUSION_C, msg)
end

function RunePageBase:onSkillDetail(container, eventName)
    PageManager.pushPage("RuneSkillPage")
end

function RunePageBase_setSelectInfo(infos)
    local newSelectInfo = { }
    for i = 1, #infos do
        if (not selectInfos[i] or selectInfos[i].itemId <= 0) and (infos[i] and infos[i].itemId > 0) then
            newSelectInfo[i] = true
        else
            newSelectInfo[i] = false
        end
    end
    selectInfos = { }
    for i = 1, #infos do
        selectInfos[i] = infos[i]
    end
    for i = 1, #items do
        if selectInfos[i] then
            local cfg = ConfigManager.getFateDressCfg()[selectInfos[i].itemId]
            local iconBgSprite = NodeHelper:getImageBgByQuality(cfg.rare)
            NodeHelper:setNodesVisible(items[i], { mStarNode = true })
            for star = 1, 6 do
                NodeHelper:setNodesVisible(items[i], { ["mStar" .. star] = (star == cfg.star) })
            end
            NodeHelper:setSpriteImage(items[i], { mPic = cfg.icon, mFrameShade = iconBgSprite, mFrame = GameConfig.QualityImage[cfg.rare] })
        else
            local iconBgSprite = "UI/Mask/Image_Empty.png"
            NodeHelper:setNodesVisible(items[i], { mStarNode = false })
            NodeHelper:setSpriteImage(items[i], { mPic = "UI/Mask/Image_Empty.png", mFrameShade = "UI/Mask/Image_Empty.png", mFrame = "UI/Mask/Image_Empty.png" })
        end
    end
    if #selectInfos == RUNE_ITME_NUM then
        NodeHelper:setNodesVisible(selfContainer, { mRuneNode6 = true })
        local cfg = ConfigManager.getFateDressCfg()[selectInfos[1]:getConf().afterId or 1]
        if not cfg then
            cfg = ConfigManager.getFateDressCfg()[selectInfos[1].itemId]
        end
        NodeHelper:setNodesVisible(selfContainer,{mSkillNode=true})
        if cfg.hasSkill == 1 then
            NodeHelper:setSpriteImage(selfContainer,{mSkillNode="skill/S_9998.png"})
        else
            NodeHelper:setSpriteImage(selfContainer,{mSkillNode="skill/S_9999.png"})
        end
        for star = 1, 6 do
            NodeHelper:setNodesVisible(selfContainer, { ["mStar" .. star] = (star == cfg.star) })
        end
        NodeHelper:setSpriteImage(selfContainer, { mMiddlePic = "Rune_"..cfg.rank..".png", mMiddleBg = NodeHelper:getImageBgByQuality(cfg.rare) })
        RunePageBase:BuildAttrInfo(selfContainer,selectInfos)
    else
        NodeHelper:setNodesVisible(selfContainer, { mRuneNode6 = false,mSkillNode=false })
        local MainScroview=selfContainer:getVarScrollView("mMainAttr")
        local OtherScrollview=selfContainer:getVarScrollView("mOtherAttr")
        MainScroview:removeAllCell()
        OtherScrollview:removeAllCell()
    end
    -- 播放動畫
    for i = 1, #newSelectInfo do
        if newSelectInfo[i] == true then
            spines[i]:runAnimation(1, "animation", 0)
        end
    end
end

function RunePageBase_getSelectInfo()
    return selectInfos
end
function RunePageBase:BuildAttrInfo(container,Table)
    local MainScroview=container:getVarScrollView("mMainAttr")
    local OtherScrollview=container:getVarScrollView("mOtherAttr")
    MainScroview:removeAllCell()
    OtherScrollview:removeAllCell()
    local MainTable={}
    local OtherTable={}
    for key,_ in pairs  (Table) do
        local cfg = ConfigManager.getFateDressCfg()[Table[key]:getConf().afterId or 1]
         table.insert(MainTable,cfg.basicAttr)
         local Attr=common:split(cfg.OtherAttr,",")
         for k,v in pairs (Attr) do
             table.insert(OtherTable,v)
         end
    end

     local function removeDuplicates(t)
        local seen = {}
        local result = {}

        for _, value in ipairs(t) do
            if not seen[value] then
                table.insert(result, value)
                seen[value] = true
            end
        end
        return result
     end

     MainTable=removeDuplicates(MainTable)
     OtherTable=removeDuplicates(OtherTable)
         
    for i=1,#MainTable do
        local Info=MainTable[i]
        local cell=RunePageBase:CreateCell(Info)
        MainScroview:addCell(cell)
    end
    for i=1,#OtherTable do
        local Info=OtherTable[i]
        local cell=RunePageBase:CreateCell(Info)
        OtherScrollview:addCell(cell)
    end
    MainScroview:orderCCBFileCells()
    OtherScrollview:orderCCBFileCells()

    MainScroview:setTouchEnabled(false)
    if #OtherTable >4 then
        OtherScrollview:setTouchEnabled(true)
    else
        OtherScrollview:setTouchEnabled(false)
    end
end
function RunePageBase:CreateCell(_info)
     local cell = CCBFileCell:create()
     cell:setCCBFile(RuneAttrItem.ccbiFile)
     local panel = common:new( {Info=_info }, RuneAttrItem)
     cell:registerFunctionHandler(panel)
     return cell
end
function RuneAttrItem:onRefreshContent(content)
    local container=content:getCCBFileNode()
    local attrId, attrNum = unpack(common:split(self.Info, "_"))
    local txt=common:getLanguageString("@Combatattr_"..attrId)
    NodeHelper:setSpriteImage(container, { ["mAttrImg1"] = "attri_" .. attrId .. ".png" })
    NodeHelper:setStringForLabel(container, { ["mAttrTxt1"] = ("+" .. attrNum) ,mTxt=txt})
     
end
function RunePageBase:clearSelectInfo()
    selectInfos = { }
    for i = 1, #items do
        local iconBgSprite = "UI/Mask/Image_Empty.png"
        NodeHelper:setSpriteImage(items[i], { mPic = "UI/Mask/Image_Empty.png", mFrameShade = "UI/Mask/Image_Empty.png", mFrame = "UI/Mask/Image_Empty.png", })
        NodeHelper:setNodesVisible(items[i], { mStarNode = false })
    end
    NodeHelper:setNodesVisible(selfContainer, { mRuneNode6 = false })
    local MainScroview=selfContainer:getVarScrollView("mMainAttr")
    local OtherScrollview=selfContainer:getVarScrollView("mOtherAttr")
    MainScroview:removeAllCell()
    OtherScrollview:removeAllCell()
    NodeHelper:setNodesVisible(selfContainer,{mSkillNode=false})
end

function RunePageBase:onReceivePacket(container)
    local opcode = container:getRecPacketOpcode()
    local msgBuff = container:getRecPacketBuffer()

    if opcode == opcodes.BADGE_FUSION_S then
        local msg = Badge_pb.HPBadgeFusionRet()
        msg:ParseFromString(msgBuff)
        local success = msg.success
        local reward = msg.award
        local showReward = { }
        --local rewardData = common:split(reward, "_")
        --local resInfo = { }
        --resInfo["type"] = tonumber(rewardData[1])
        --resInfo["itemId"] = tonumber(rewardData[2])
        --resInfo["count"] = tonumber(rewardData[3])
        --showReward[1] = resInfo
        --local CommonRewardPage = require("CommPop.CommItemReceivePage")
        --CommonRewardPage:setData(showReward, common:getLanguageString("@ItemObtainded"), nil)

        local actArray = CCArray:create()
        actArray:addObject(CCCallFunc:create(function()
            spines[6]:runAnimation(1, "animation", 0)
        end))
        actArray:addObject(CCDelayTime:create(1.4))
        actArray:addObject(CCCallFunc:create(function(msgBuff)
            --PageManager.pushPage("CommPop.CommItemReceivePage")
            require("RuneInfoPage")
            RuneInfoPage_setPageInfo(GameConfig.RuneInfoPageType.NON_EQUIPPED, tonumber(reward))
            PageManager.pushPage("RuneInfoPage")
            self:clearSelectInfo()
        end))
        container:runAction(CCSequence:create(actArray))
    end
end

function RunePageBase:registerPacket(container)
    for key, opcode in pairs(opcodes) do
        if string.sub(key, -1) == "S" then
            mParentContainer:registerPacket(opcode)
        end
    end
end

function RunePageBase:removePacket(container)
    for key, opcode in pairs(opcodes) do
        if string.sub(key, -1) == "S" then
            mParentContainer:removePacket(opcode)
        end
    end
end

function RunePageBase:onReceiveMessage(container)
    local message = container:getMessage()
    local typeId = message:getTypeId()
    if typeId == MSG_MAINFRAME_REFRESH then
        local pageName = MsgMainFrameRefreshPage:getTrueType(message).pageName
        if pageName == thisPageName then
            self:refreshPage(container)
        end
    end
end
---------------------------------------------------------------------
-- 修改
function RunePageBase.onFunction(eventName, container)
    if eventName == "onHelp" then
        RunePageBase:showHelp(container)
    elseif eventName == "onClose" then
        RunePageBase:onClose(container)
    elseif eventName == "onAddAll" then
        RunePageBase:onAddAll(container)
    elseif eventName == "onForge" then
        RunePageBase:onForge(container)
    elseif eventName == "onSkillDetail" then
        RunePageBase:onSkillDetail(container)
    end
end

return RunePageBase