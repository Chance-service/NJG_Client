local NodeHelper = require("NodeHelper")
local thisPageName = 'TowerSubPage_MainScene'
local Activity6_pb = require("Activity6_pb");
local HP_pb = require("HP_pb");
local CONST = require("Battle.NewBattleConst")
local TimeDateUtil = require("Util.TimeDateUtil")
local TowerRankPage = require "Tower.TowerSubPage_Rank"

local TowerBase = {}
local parentPage = nil
local selfContainer = nil
local TowerContent = {ccbiFile = "Tower_Content.ccbi"}
local RewardContent = {ccbiFile = "Tower_PopupContent.ccbi"}
local RewardPopCCB = nil
local PageInfo = {}
local Tower_ContentHeight = 252  -- �C�h����
local CountDown = nil

local isTowerMoving = false

local option = {
    ccbiFile = "Tower.ccbi",
    handlerMap =
    {
        onBack = "onBack",
        onHelp = "onHelp",
        onReward = "onReward",
        onEffect = "onEffect"
    },
}

local opcodes = {
    ACTIVITY194_SEASON_TOWER_C = HP_pb.ACTIVITY194_SEASON_TOWER_C,
    ACTIVITY194_SEASON_TOWER_S = HP_pb.ACTIVITY194_SEASON_TOWER_S,
    BATTLE_FORMATION_S = HP_pb.BATTLE_FORMATION_S,
}
function TowerBase:createPage(_parentPage)
    
    local slf = self
    
    parentPage = _parentPage
    
    local container = ScriptContentBase:create(option.ccbiFile)

     container:registerFunctionHandler(function(eventName, container)
        local funcName = option.handlerMap[eventName]
        local func = slf[funcName]
        if func then
            func(slf, container)
        end
    end)
    
    return container
end
function TowerBase:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end
function TowerBase:onEffect(container)
    local skillId = ConfigManager.getTowerData()[1].BuffId
    if skillId and skillId > 0 then
        GameUtil:showSkillTip(container:getVarNode("mEffectSprite"), skillId)
    end
    --MessageBoxPage:Msg_Box(message)
end
function TowerBase:onBack(container)
    TowerBase:scrollToLevel(container.mScrollview, PageInfo.MaxFloor, PageInfo.totalLevels,nil)
end
function TowerBase:onHelp(container)
    PageManager.showHelp(GameConfig.HelpKey.HELP_CLIMB_TOWER)
end
function TowerBase:onReward(container)
   local parentNode = container:getVarNode("mPopUpNode")
   if parentNode then 
       parentNode:removeAllChildren()
       RewardPopCCB = ScriptContentBase:create("Tower_Popup")
       parentNode:addChild(RewardPopCCB)
       RewardPopCCB:registerFunctionHandler(RewardPopFunction)
       RewardPopCCB:setAnchorPoint(ccp(0.5,0.5))
       TowerBase:setRewardPopCCB(RewardPopCCB)
   end
end
function TowerBase:onEnter(container)
    parentPage:registerPacket(opcodes)
    parentPage:registerMessage(MSG_MAINFRAME_REFRESH)
    self.container = container
    require("TransScenePopUp")
    TransScenePopUp_closePage()
    local PageJumpMange = require("PageJumpMange")
    PageJumpMange._IsPageJump = false
    selfContainer = container
    --Bg
    container:getVarNode("mBg"):setScale(NodeHelper:getScaleProportion())
    container.mScrollview = container:getVarScrollView("mContent")
    container.mScrollview:setBounceable(true)
    local TowerDataBase = require "Tower.TowerPageData"
    PageInfo = TowerDataBase:getData()
    local TowerEnter = CCUserDefault:sharedUserDefault():getStringForKey("TOWER_" .. UserInfo.playerInfo.playerId) or ""
    if TowerEnter ~= self:getCurrentDateString() then
       PageInfo.isFirstEnter = true
    else
        PageInfo.isFirstEnter = false
    end
    local TowerPass = CCUserDefault:sharedUserDefault():getIntegerForKey("TOWERPASS_" .. UserInfo.playerInfo.playerId) or ""
    if TowerPass ~= PageInfo.MaxFloor then
       PageInfo.isPassLevel = true
    else
        PageInfo.isPassLevel = false
    end
    self:buildScrollview(container)
    self:setPage(container)
    --PageInfo.MaxFloor = 25
end
function TowerBase:getCurrentDateString()
    local dateTable = os.date("*t")
    local year = dateTable.year
    local month = string.format("%02d", dateTable.month)  -- Ensure two digits
    local day = string.format("%02d", dateTable.day)      -- Ensure two digits
    return year .. "_" .. month .. "_" .. day
end
function TowerBase:setPage(container)
    local cfg = ConfigManager.getTowerData()
    local skillId = cfg[1].BuffId
    local img = "S_" .. math.floor(skillId / 10) .. ".png"
    NodeHelper:setSpriteImage(container,{mEffectSprite = img})
    local Time = math.floor(PageInfo.endTime/1000)
    local clientSafeTime = TimeDateUtil:getClientSafeTime()
    local leftTime = Time - clientSafeTime
    --setTime
     CountDown = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(function()
        -- ��s leftTime
        leftTime = leftTime - 1
        local txt =  common:second2DateString5(leftTime,false)
        NodeHelper:setStringForLabel(container, {mCountDown = common:getLanguageString("@SeasonTowerEndTime",txt)})
        TowerRankPage:setTime(txt)
    end, 1, false)
end
function TowerBase:setReward(container)
    local cfg = ConfigManager.getTowerData()

end
function TowerBase:buildScrollview(container)
    container.mScrollview:removeAllCell()
    local cfg = ConfigManager.getTowerData()
    PageInfo.totalLevels = #cfg
    PageInfo.Items = {}
    for i=#cfg,1,-1 do
        cell = CCBFileCell:create()
        cell:setCCBFile(TowerContent.ccbiFile)
        local panel = common:new({data = cfg[i]}, TowerContent)
        cell:registerFunctionHandler(panel)
        container.mScrollview:addCell(cell)
    end
    container.mScrollview:setTouchEnabled(true)
    container.mScrollview:orderCCBFileCells()
    if PageInfo.isFirstEnter then
        container.mScrollview:setContentOffset(ccp(0, 0))  -- �]�m������̩���
    else
         local option = {}
        option.durationPerLevel = 0 
        TowerBase:initScrollToCurrentLevel(container.mScrollview)
        return
    end
    local array = CCArray:create()
    array:addObject(CCDelayTime:create(0.1))
    array:addObject(CCCallFunc:create(function()
        TowerBase:initScrollToCurrentLevel(container.mScrollview)
    end))
    -- ����ǦC
    container:runAction(CCSequence:create(array))
end
function TowerBase:onReceivePacket(packet)
    local opcode = packet.opcode
    local msgBuff = packet.msgBuff
    if opcode == HP_pb.ACTIVITY194_SEASON_TOWER_S then
        
    end
    if opcode == HP_pb.BATTLE_FORMATION_S then
        local msg = Battle_pb.NewBattleFormation()
        msg:ParseFromString(msgBuff)
        if msg.type == NewBattleConst.FORMATION_PROTO_TYPE.REQUEST_ENEMY then
            local battlePage = require("NgBattlePage")
            resetMenu("mBattlePageBtn", true)
            require("NgBattleDataManager")
            NgBattleDataManager_setDungeonId(tonumber(msg.mapId))
            PageManager.changePage("NgBattlePage")
            battlePage:onSeasonTower(selfContainer, msg.resultInfo, msg.battleId, msg.battleType, tonumber(msg.mapId))
        end
    end
end
function TowerBase:onClose(container)
    parentPage:removePacket(opcodes)
    --parentPage.container:unregisterFunctionHandler()
    if CountDown~=nil then
        CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(CountDown)
        CountDown = nil
    end

end
function TowerBase:onExecute(container)

end
function TowerBase:onHelp(container)
    PageManager.showHelp(GameConfig.HelpKey.HELP_DAILY_BUNDLE)
end
-- �u�ʨ���w���d
function TowerBase:scrollToLevel(scrollView, level, totalLevels, callback, options)
    -- �q�{�ѼƳB�z
    options = options or {}
    local height = options.height or Tower_ContentHeight or 252  -- �C�h����
    local durationPerLevel = options.durationPerLevel or 0.1  -- �C�h���u�ʮɶ�
    if options.height then
        level = totalLevels - level - 2
    end
    -- �Ѽ��ˬd
    if level < 1 or level > totalLevels then
        print(string.format("�L�Ī��h�šG%d�]�d��G1-%d�^", level, totalLevels))
        return
    end

    -- �u�ʰѼ�
    local viewHeight = scrollView:getViewSize().height  -- ScrollView ��ܽd�򰪫�
    local contentHeight = totalLevels * height  -- ���e�`����
    local centerOffset = options.centerOffset or 0  -- �����q�վ�

    -- �p��ؼа����q�A���̩��� (level = 1)
    local targetY = (level - 1) * height - (viewHeight / 2) + centerOffset
    targetY = math.max(0, math.min(contentHeight - viewHeight, targetY))  -- ����d��

    -- ��e�h�ũM�����q
    local currentOffset = math.abs(scrollView:getContentOffset().y)
    local currentLevel = math.floor(currentOffset / height) + 1
    local levelDifference = math.abs(level - currentLevel)  -- �p��h�Ůt�Z

    -- �p��u�ʫ���ɶ�
    local duration = math.min(levelDifference * durationPerLevel,2)
    -- �p�G�ؼЦ�m�b���Ͻd�򤺡A�h���u��
    --if math.abs(targetY - currentOffset) < (viewHeight / 2) then
    --    print("�ؼмh�Ťw�b�i���d�򤺡A�L�ݺu�ʡC")
    --    if callback and type(callback) == "function" then
    --        callback()
    --    end
    --    return
    --end

    -- ���ƺu�ʨ�ؼЦ�m
    print(string.format(
        "���b�u�ʨ�h�šG%d�A��e�h�šG%d�A�h�Ůt�Z�G%d�A�ؼа����G%.2f�A����ɶ��G%.2f",
        level, currentLevel, levelDifference, targetY, duration
    ))
    if duration >0 then
        scrollView:setContentOffsetInDuration(ccp(0, -targetY), duration)
    else
        scrollView:setContentOffset(ccp(0, -targetY))
    end

    -- �K�[����^�I
    local array = CCArray:create()
    array:addObject(CCCallFunc:create(function()
          isTowerMoving = true
          scrollView:setTouchEnabled(false)
    end))
    array:addObject(CCDelayTime:create(duration))  -- �u�ʫ���ɶ�
    array:addObject(CCCallFunc:create(function()
        isTowerMoving = false
        scrollView:setTouchEnabled(true)
        if callback and type(callback) == "function" then
            callback()
        end
    end))

    -- ����ʧ@�ǦC
    scrollView:runAction(CCSequence:create(array))
end

-- ��l�ƺu���޿�
function TowerBase:initScrollToCurrentLevel(scrollView)
    if PageInfo.isFirstEnter then
        CCUserDefault:sharedUserDefault():setStringForKey("TOWER_" .. UserInfo.playerInfo.playerId,self:getCurrentDateString())
        self:scrollToLevel(scrollView, PageInfo.MaxFloor,PageInfo.totalLevels)
    elseif PageInfo.isPassLevel then
        local option = {}
        option.durationPerLevel = 0
        local function setNode()
            local preNode = PageInfo.Items[PageInfo.MaxFloor-1]
            local nowNode = PageInfo.Items[PageInfo.MaxFloor]
            NodeHelper:setNodesVisible(preNode,{PassImg = true,mNowStage = false})
            NodeHelper:setNodesVisible(nowNode,{PassImg = false,mNowStage = true})
            if string.find(data.stageBg,"Tower_img1") then
                NodeHelper:setScale9SpriteImage2(preNode,{mBg = "BG/UI/Tower_img1_1.png",mBg2 = "BG/UI/Tower_img1_1.png"})
            elseif string.find(data.stageBg,"Tower_img2") then
                 NodeHelper:setScale9SpriteImage2(preNode,{mBg = "BG/UI/Tower_img2_1.png",mBg2 = "BG/UI/Tower_img2_1.png"})
            end
            local parentNode = preNode:getVarNode("mSpine")
                if parentNode then
                   parentNode:removeAllChildren()
                end
            end
        local array = CCArray:create()
        array:addObject(CCCallFunc:create(function()
             self:scrollToLevel(scrollView, PageInfo.MaxFloor-1,PageInfo.totalLevels,nil,option)
        end))
        array:addObject(CCDelayTime:create(0.5))
        array:addObject(CCCallFunc:create(function()
            option.durationPerLevel = 0.2
             self:scrollToLevel(scrollView, PageInfo.MaxFloor,PageInfo.totalLevels,nil,option)
             CCUserDefault:sharedUserDefault():setIntegerForKey("TOWERPASS_" .. UserInfo.playerInfo.playerId,PageInfo.MaxFloor)
        end))
        -- ����ǦC
        selfContainer:runAction(CCSequence:create(array))     
    else
        local option = {}
        option.durationPerLevel = 0 
        self:scrollToLevel(scrollView, PageInfo.MaxFloor,PageInfo.totalLevels,nil,option)
    end
end
-- �q���޿�
function TowerBase:passLevel(scrollView)
    if PageInfo.MaxFloor < PageInfo.totalLevels then
        -- �����e���d���q�L�ʵe
        --playPassAnimation(currentLevel)

        -- �u�ʨ�U�@��
        self:scrollToLevel(scrollView, PageInfo.MaxFloor, function()
            -- ����U�@��������ʵe
           -- playOpenNextLevelAnimation(currentLevel)
        end)
    else
        print("All levels cleared!")
    end
end
function TowerBase:isLevelVisible(scrollView, level, totalLevels)
    -- �ˬd���d�O�_����
    if level < 1 or level > totalLevels then
        print("�L�Ī��h�šG", level)
        return "invalid"
    end

    -- �u�ʰѼ�
    local viewHeight = scrollView:getViewSize().height  -- ScrollView ��ܽd�򰪫�
    local totalContentHeight = totalLevels * Tower_ContentHeight  -- ���]���e���ץ����d�ƩM�C�h���׭p��

    -- �p��i���d��
    local offsetY = math.abs(scrollView:getContentOffset().y)  -- ��e�����q�]�q�����}�l�p��^
    local visibleStartY = offsetY  -- �i���d��_�I
    local visibleEndY = offsetY + viewHeight  -- �i���d����I

    -- �p������d���d��
    local levelStartY = (level - 1) * Tower_ContentHeight
    local levelEndY = levelStartY + Tower_ContentHeight

    -- �P�_�ؼ����d����m
    if levelEndY < visibleStartY then
        return "above"  -- ���d�����b�i���d�򤧤W
    elseif levelStartY > visibleEndY then
        return "below"  -- ���d�����b�i���d�򤧤U
    else
        return "visible"  -- ���d�b�i���d��
    end
end
function TowerContent:onRefreshContent(content)
    local container = content:getCCBFileNode()
    local data = self.data
    if data.id == 1 then
        NodeHelper:setNodesVisible(container,{mBase = true})
    else
        NodeHelper:setNodesVisible(container,{mBase = false})
    end
    PageInfo.Items[data.id] = container
    NodeHelper:setStringForLabel(container,{mStage = data.id})
    NodeHelper:setScale9SpriteImage2(container,{mBg = data.stageBg,mBg2 = data.stageBg})
    if data.id < PageInfo.MaxFloor then
        NodeHelper:setNodesVisible(container,{PassImg = true,mNowStage = false})
        if string.find(data.stageBg,"Tower_img1") then
            NodeHelper:setScale9SpriteImage2(container,{mBg = "BG/UI/Tower_img1_1.png",mBg2 = "BG/UI/Tower_img1_1.png"})
        elseif string.find(data.stageBg,"Tower_img2") then
             NodeHelper:setScale9SpriteImage2(container,{mBg = "BG/UI/Tower_img2_1.png",mBg2 = "BG/UI/Tower_img2_1.png"})
        end
        local parentNode = container:getVarNode("mSpine")
         if parentNode then
            parentNode:removeAllChildren()
         end
    elseif data.id == PageInfo.MaxFloor then
        NodeHelper:setNodesVisible(container,{PassImg = false,mNowStage = true})
        self:addSpine(container,data.Spine)
    else
        NodeHelper:setNodesVisible(container,{PassImg = false,mNowStage = false})
        self:addSpine(container,data.Spine)
    end
    local Status = TowerBase:isLevelVisible(selfContainer.mScrollview, PageInfo.MaxFloor, PageInfo.totalLevels)
    if Status == "above" then
        NodeHelper:setNodesVisible(selfContainer,{mUpperArrow = false,mLowerArrow = false,mBack = true})
    elseif Status == "below" then
         NodeHelper:setNodesVisible(selfContainer,{mUpperArrow = false,mLowerArrow = false,mBack = true})
    else
         NodeHelper:setNodesVisible(selfContainer,{mUpperArrow = false,mLowerArrow = false,mBack = false})
    end

    --local scrollView = selfContainer.mScrollview
    --scrollView:setBounceable(true)
end
function TowerContent:onFight(container)
    if isTowerMoving then return end
    if self.data.id > PageInfo.MaxFloor then
        MessageBoxPage:Msg_Box(common:getLanguageString("@activitystagetNotice02"))
        return 
    end
    container:runAnimation("onFight")
    local msg = Battle_pb.NewBattleFormation()
    msg.type = NewBattleConst.FORMATION_PROTO_TYPE.REQUEST_ENEMY
    msg.battleType = NewBattleConst.SCENE_TYPE.SEASON_TOWER
    msg.mapId = tostring(self.data.id)
    common:sendPacket(HP_pb.BATTLE_FORMATION_C, msg, true)
end
function TowerContent:addSpine(container,spine)
     local spinePath, spineName = unpack(common:split(spine, ","))
     local spine = SpineContainer:create(spinePath, spineName)
     spine:runAnimation(1, CONST.ANI_ACT.WAIT, -1)
     local sNode = tolua.cast(spine, "CCNode")
     local parentNode = container:getVarNode("mSpine")
     if parentNode then
        parentNode:removeAllChildren()
        parentNode:addChild(sNode)
     end
end
function RewardPopFunction(eventName,container)
    if eventName == "onClose" then
        local parentNode = selfContainer:getVarNode("mPopUpNode")
        if parentNode then
            parentNode:removeAllChildren()
        end
    end
end
function TowerBase:setRewardPopCCB(container)
    local scrollview = container:getVarScrollView("mContent")
    local cfg =  ConfigManager.getTowerData()
    for k,value in pairs (cfg) do
        local cell = CCBFileCell:create()
        cell:setCCBFile(RewardContent.ccbiFile)
        local panel = common:new({data = value}, RewardContent)
        cell:registerFunctionHandler(panel)
        scrollview:addCell(cell)
    end
    NodeHelper:setStringForLabel(container,{mTitle = common:getLanguageString("@SeasonTowerReward") })
    scrollview:orderCCBFileCells()
    scrollview:setTouchEnabled(true)
    if PageInfo.MaxFloor > 1 then
        local option = {height = 146 ,durationPerLevel = 0}
        local Floor = math.max(PageInfo.MaxFloor - 1,1)
        TowerBase:scrollToLevel(scrollview, Floor, PageInfo.totalLevels,nil,option)
    end
end
function RewardContent:onRefreshContent(content)
    local container = content:getCCBFileNode()
    local stringTable = {}
    stringTable["mTitleTxt"] = common:getLanguageString("@SeasonTowerXstage",self.data.id)
    NodeHelper:setStringForLabel(container,stringTable)
    local Items = self.data.reward
    if self.data.id < PageInfo.MaxFloor then
        NodeHelper:setNodesVisible(container,{mPassed = true})
    else
        NodeHelper:setNodesVisible(container,{mPassed = false})
    end
    for i = 1 ,4 do
         local parentNode=container:getVarNode("mPosition"..i)
         parentNode:removeAllChildren()
          if Items[i] then
            local ItemNode = ScriptContentBase:create("CommItem")
            ItemNode:setScale(0.8)
            --ItemNode:registerFunctionHandler(ItemCCB.onFunction)
            ItemNode.Reward= Items[i]
            NodeHelper:setNodesVisible(ItemNode,{selectedNode=false,mStarNode=false,nameBelowNode=false, mPoint = false})
            local resInfo = ResManagerForLua:getResInfoByTypeAndId(Items[i].type, Items[i].itemId, Items[i].count)
            local normalImage = NodeHelper:getImageByQuality(resInfo.quality)
            local iconBg = NodeHelper:getImageBgByQuality(resInfo.quality)
            NodeHelper:setMenuItemImage(ItemNode, {mHand1 = {normal = normalImage}})
            NodeHelper:setSpriteImage(ItemNode, {mPic1 = resInfo.icon, mFrameShade1 = iconBg})
            NodeHelper:setStringForLabel(ItemNode,{mNumber1_1=Items[i].count})
            parentNode:addChild(ItemNode)
        end
    end
end

----------------------------------------------------------------
local CommonPage = require('CommonPage')
return  CommonPage.newSub(TowerBase, thisPageName, option)
