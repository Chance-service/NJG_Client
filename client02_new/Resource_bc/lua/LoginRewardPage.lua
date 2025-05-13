local NodeHelper = require("NodeHelper")
local UserInfo = require("PlayerInfo.UserInfo")
local thisPageName = "LoginRewardPage"
local HP_pb = require("HP_pb")
local Activity6_pb = require("Activity6_pb")
local CONST = require("Battle.NewBattleConst")

local LoginRewardPage = {
}
LoginRewardPage.timerName = "LoginRewardPage_timerName"
local configData = nil
local mIsInitScrollView = false
local mIsUpdateTime = false
local mSigninCount = 0
local mItemList = { }
local serverData = nil
local mIsJumpToDaily = false
local option = {
    ccbiFile = "LivenessPage_Login8day.ccbi",
    handlerMap = {
        onClose = "onClose",
        onClaim = "onClaim",
        onClick = "onClick",
        onHand = "onHand",
    }
}
local opcodes = {
    ACTIVITY200_EIGHT_DAY_LOGIN_C = HP_pb.ACTIVITY200_EIGHT_DAY_LOGIN_C,
    ACTIVITY200_EIGHT_DAY_LOGIN_S = HP_pb.ACTIVITY200_EIGHT_DAY_LOGIN_S,
    PLAYER_AWARD_S = HP_pb.PLAYER_AWARD_S,
}

-----------------------------------
-- Item
local LoginRewardPageItemState = {
    Null = 0,
    -- 已領取
    HaveReceived = 1,
    -- 可補簽
    Supplementary = 2,
    -- 可以領取
    CanGet = 3
}

local LoginRewardPageItem = {
    ccbiFile = "DayLogin30Item.ccbi",
}
function LoginRewardPageItem:new(o)
    o = o or { }
    setmetatable(o, self)
    self.__index = self
    return o
end

function LoginRewardPageItem:onRefreshContent(ccbRoot)
    self:refresh(ccbRoot:getCCBFileNode())
end

function LoginRewardPageItem:setState(state)
    self.mState = state
end

function LoginRewardPageItem:getState()
    return self.mState
end

function LoginRewardPageItem:getCCBFileNode()
    return self.ccbiFile:getCCBFileNode()
end

function LoginRewardPageItem:refresh(container)
    if container == nil then
        return
    end

    if self.rewardData == nil then
        local itemInfo = configData[self.id].reward
        
        self.rewardData = itemInfo[1]
    end

    local resInfo = ResManagerForLua:getResInfoByTypeAndId(self.rewardData.type, self.rewardData.itemId, self.rewardData.count)

    local iconBgSprite = NodeHelper:getImageBgByQuality(resInfo.quality)
    NodeHelper:setSpriteImage(container, { mIconSprite = resInfo.icon, mDiBan = iconBgSprite })
    NodeHelper:setQualityFrames(container, { mQuality = resInfo.quality })
    local icon = container:getVarSprite("mIconSprite")
    --icon:setPosition(ccp(0, 0))

    NodeHelper:setStringForLabel(container, { mNumLabel = (self.rewardData.type == 40000 and "" or tostring(resInfo.count)) })

    local mGetSprite = container:getVarSprite("mGetSprite")
    local mDayLabel = container:getVarLabelTTF("mDayLabel")
    local mTodayNode = container:getVarNode("mTodayNode")
    local mMask = container:getVarSprite("mMask")
    local mSpine=container:getVarNode("mSpine")
    LoginRewardPageItem:setAnim(container)
    if self.mState == LoginRewardPageItemState.HaveReceived then
        mDayLabel:setString(common:getLanguageString("@Receive"))
        mDayLabel:setColor(ccc3(248, 205, 127))
        mSpine:setVisible(false)
    end
    if self.mState == LoginRewardPageItemState.Null then
        mDayLabel:setString(common:getLanguageString("@DayLogin30_CurrontDay", string.format("%02d", self.id)))
        mDayLabel:setColor(ccc3(81, 75, 78))
        mSpine:setVisible(false)
    end
    if self.mState == LoginRewardPageItemState.CanGet then
        mDayLabel:setString(common:getLanguageString("@DayLogin30_CurrontDay", string.format("%02d", self.id)))
        mDayLabel:setColor(ccc3(81, 75, 78))
        mSpine:setVisible(true)
    end
    mMask:setVisible(self.mState == LoginRewardPageItemState.HaveReceived)
    mGetSprite:setVisible(self.mState == LoginRewardPageItemState.HaveReceived)
    mTodayNode:setVisible(self.mState == LoginRewardPageItemState.CanGet)
    for i = 1, 5 do -- icon星星
        container:getVarSprite("mStar" .. i):setVisible(self.rewardData.type == 40000 and resInfo.quality >= i)
    end
end
function LoginRewardPageItem:setAnim(container)
    local spinePath = "Spine/NGUI"
    local spineName = "NGUI_06_WaitItem"
    local spine = SpineContainer:create(spinePath, spineName)
    local spineNode = tolua.cast(spine, "CCNode")
    local parentNode=container:getVarNode("mSpine")
    parentNode:removeAllChildrenWithCleanup(true)
    parentNode:addChild(spineNode)
    spine:runAnimation(1, "animation", -1)
    parentNode:setScale(0.75)
    parentNode:setPositionY(5)
end
-- item點擊
function LoginRewardPageItem:onClick(container)
    if self.rewardData ~= nil then
        GameUtil:showTip(container:getVarNode("mIconSprite"), self.rewardData)
    end
end

-----------------------------------------------
function LoginRewardPage:onEnter(container)
    self.container = container
    configData = ConfigManager.getLoginReward()
    NodeHelper:setSpriteImage(container,{mTitle = configData[1].Title})
    self:initSpine(container)
    self:registerPacket(container)
    container:registerMessage(MSG_MAINFRAME_REFRESH)
    self:sendLoginSignedInfoReqMessage()
end

function LoginRewardPage:initSpine(container)
    local spineNode = container:getVarNode("mSpineNode")
    if spineNode:getChildByTag(10086) == nil then
        spineNode:removeAllChildren()
        local spinePath,spineName = unpack(common:split(configData[1].Spine,","))
        local spine = SpineContainer:create(spinePath, spineName)
        local spineToNode = tolua.cast(spine, "CCNode")
        spineNode:addChild(spineToNode)
        spineToNode:setTag(10086)
        spineToNode:setScale(NodeHelper:getScaleProportion())
        spine:runAnimation(1, "animation", -1)
    end

end

function LoginRewardPage:initData()
    
end


-------------------------------onClick--------------------------------
function LoginRewardPage:onClose(container)
    PageManager.popPage(thisPageName)
end

function LoginRewardPage:onClaim(container)
    if mItemList[serverData.days]:getState() == LoginRewardPageItemState.CanGet then
        local msg = Activity6_pb.EightDayLoginAwardReq()
        msg.day = serverData.days
        msg.action = 1
        common:sendPacket(opcodes.ACTIVITY200_EIGHT_DAY_LOGIN_C, msg, false)
    else
        --MessageBoxPage:Msg_Box_Lan("@ERRORCODE_9006")
    end
end

function LoginRewardPage_onClaim(container)
    --LoginRewardPage:onClaim(container)
end
----------------------------------------------------------------------

function LoginRewardPage:onExit(container)
   
    TimeCalculator:getInstance():removeTimeCalcultor(self.timerName)
    mIsUpdateTime = false
    container:removeMessage(MSG_MAINFRAME_REFRESH)
    mIsInitScrollView = false
    self:removePacket(container)
    if container.mScrollView then
        container.mScrollView:removeAllCell()
        container.mScrollView = nil
        container.mScrollViewRootNode = nil
    end
end

function LoginRewardPage:refreshAll(container)
    self:updateTime(container)
    self:refreshItem(container)

    --if #serverData.awardDays == serverData.days then
    --    ActivityInfo.changeActivityNotice(122)
    --    PageManager.refreshPage("MissionMainPage", "refreshSignState")
    --end
    if mItemList[serverData.days]:getState() == LoginRewardPageItemState.CanGet then
        NodeHelper:setMenuItemEnabled(container, "mReceiveBtn", true)
    else
        NodeHelper:setMenuItemEnabled(container, "mReceiveBtn", false)
    end
end

function LoginRewardPage:refreshItem(container)
    if not mIsInitScrollView then
        mItemList = { }
        self:initScrollView(container)
        mIsInitScrollView = true
    end

    for k, v in pairs(mItemList) do
        if serverData.days >= k then
            if self:isContain(serverData.awardDays, k) then
                -- 已領取
                v:setState(LoginRewardPageItemState.HaveReceived)
            else
                -- 可領取
                v:setState(LoginRewardPageItemState.CanGet)
            end
        else
            -- 未達標
            v:setState(LoginRewardPageItemState.Null)
        end
    end

    -- 刷新item
    for k, v in pairs(mItemList) do
        v:refresh(v:getCCBFileNode())
    end
end

function LoginRewardPage:isContain(t, num)
    for i = 1, #t do
        if t[i] == num then
            return true
        end
    end
    return false
end

function LoginRewardPage:updateTime(container)
    if serverData.surplusTime > 0 then
        if not TimeCalculator:getInstance():hasKey(self.timerName) then
            TimeCalculator:getInstance():createTimeCalcultor(self.timerName, serverData.surplusTime)
        end
        mIsUpdateTime = true
    else
        mIsUpdateTime = false
    end
end

function LoginRewardPage:onExecute(container)
    if mIsUpdateTime then
        if not TimeCalculator:getInstance():hasKey(self.timerName) then
            if serverData.surplusTime == 0 then
                local endStr = common:getLanguageString("@ActivityEnd")
                NodeHelper:setStringForLabel(container, { mTimeTxt = endStr })
            elseif serverData.surplusTime < 0 then
                NodeHelper:setStringForLabel(container, { mTimeTxt = "" })
            end
            return
        end

        local remainTime = TimeCalculator:getInstance():getTimeLeft(self.timerName)
        if remainTime + 1 > serverData.surplusTime then
            return
        end
        local timeStr =  common:second2DateString4(remainTime,true)
        local text=string.format(common:getLanguageString("@ActPopUpSale.LeftTimeText.dhm"),timeStr[1], timeStr[2], timeStr[3], timeStr[4])
        NodeHelper:setStringForLabel(container, { mTimeTxt = text })
    end
end

function LoginRewardPage:onClose(container)
    PageManager.popPage(thisPageName)
end

function LoginRewardPage:registerPacket(container)
    for key, opcode in pairs(opcodes) do
        if string.sub(key, -1) == "S" then
            container:registerPacket(opcode)
        end
    end
end
function LoginRewardPage:setServerData(msg)
    serverData = msg
end
function LoginRewardPage:getServerData()
    return serverData
end
function LoginRewardPage:onReceivePacket(container)
    local opcode = container:getRecPacketOpcode()
    local msgBuff = container:getRecPacketBuffer()

    if opcode == HP_pb.ACTIVITY200_EIGHT_DAY_LOGIN_S then
        local msg = Activity6_pb.EightDayLoginAwardRep()
        msg:ParseFromString(msgBuff)
        serverData = msg
        self:refreshAll(container)
      
    elseif opcode == HP_pb.PLAYER_AWARD_S then
        local PackageLogicForLua = require("PackageLogicForLua")
        PackageLogicForLua.PopUpReward(msgBuff)
    end
end

--
function LoginRewardPage:removePacket(container)
    for key, opcode in pairs(opcodes) do
        if string.sub(key, -1) == "S" then
            container:removePacket(opcode)
        end
    end
end

function LoginRewardPage:initScrollView(container)
    container.mScrollView = container:getVarScrollView("mContent")
    if container.mScrollView == nil or container.mScrollViewRootNode then return end
    container.mScrollViewRootNode = container.mScrollView:getContainer()
    container.m_pScrollViewFacade = CCReViScrollViewFacade:new_local(container.mScrollView)
    container.m_pScrollViewFacade:init(0, 0)

    container.mScrollView:removeAllCell()
    for i = 1, #configData do
        local cell = CCBFileCell:create()
        local panel = LoginRewardPageItem:new( { id = i, ccbiFile = cell, mState = 0, rewardData = nil })
        cell:registerFunctionHandler(panel)
        cell:setCCBFile(LoginRewardPageItem.ccbiFile)
        container.mScrollView:addCellBack(cell)
        mItemList[i] = panel
    end
    container.mScrollView:orderCCBFileCells()
    container.mScrollView:setTouchEnabled(false)
end

function LoginRewardPage:sendLoginSignedInfoReqMessage()
    local msg = Activity6_pb.EightDayLoginAwardReq()
    msg.action = 0
    common:sendPacket(opcodes.ACTIVITY200_EIGHT_DAY_LOGIN_C, msg, false)
end

local CommonPage = require("CommonPage")
Activity_LoginRewardPage = CommonPage.newSub(LoginRewardPage, thisPageName, option)

return LoginRewardPage