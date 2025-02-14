--������֤

require "Friend_pb"
require "Const_pb"
require "HP_pb"

local GameConfig = require "GameConfig"
local thisPageName = "FriendApplyPage"
local RoleManager = require("PlayerInfo.RoleManager")
local UserInfo = require("PlayerInfo.UserInfo");
local FriendManager = require("FriendManager")
local OSPVPManager = require("OSPVPManager")

local option = {
	ccbiFile = "FriendApplicationPopUp.ccbi",
	entermateCcbiFile = "FriendApplicationPopUp.ccbi",
	handlerMap = {
		onClose = "onClose"
	},
	opcodes = {
		--FRIEND_LIST_S = HP_pb.FRIEND_LIST_S,
		--FRIEND_LIST_KAKAO_C = HP_pb.FRIEND_LIST_KAKAO_C,
		--FRIEND_LIST_KAKAO_S = HP_pb.FRIEND_LIST_KAKAO_S,
	}
}

local FriendApplyItem = {
    ccbiFile = "FriendApplicationContent.ccbi"
}

local FriendApplyPageBase = {}

local roleConfig = {}
-----------------------------------------------
local mercenaryHeadContent = {
    ccbiFile = "FormationTeamContent.ccbi"
}
function mercenaryHeadContent:refreshItem(container,Info)
    self.container = container
    UserInfo = require("PlayerInfo.UserInfo")
    local roleIcon = ConfigManager.getRoleIconCfg()
    local trueIcon = Info.headIcon
    if not roleIcon[trueIcon] then
        local icon = common:getPlayeIcon(UserInfo.roleInfo.prof, trueIcon)
        if NodeHelper:isFileExist(icon) then
            NodeHelper:setSpriteImage(container, { mHead = icon })
        end
        --NodeHelper:setSpriteImage(container, { mHeadFrame = GameConfig.MercenaryBloodFrame[1] })
        NodeHelper:setStringForLabel(container, { mLv = Info.level })
    else
        NodeHelper:setSpriteImage(container, { mHead = roleIcon[trueIcon].MainPageIcon })
        NodeHelper:setStringForLabel(container, { mLv = Info.level })
    end

    NodeHelper:setNodesVisible(container, { mClass = false, mElement = false, mMarkFighting = false, mMarkChoose = false, 
                                            mMarkSelling = false, mMask = false, mSelectFrame = false, mStageImg = false })
end
-----------------------------------------------
function FriendApplyItem:new(o)
    o = o or {}
    setmetatable(o,self)
    self.__index = self
    return o
end

function FriendApplyItem:onRefreshContent(ccbRoot)
    local id = self.id
    local index = self.index
    local container = ccbRoot:getCCBFileNode()
    local info = FriendManager.getApplyInfoById(id)

    local sprite2Img = {}
    local scaleMap = {}
    local menu2Quality = {}
    local lb2Str = {}


    if info then
        lb2Str["mName"] = info.name
        lb2Str["mLevelNum"] = UserInfo.getOtherLevelStr(info.rebirthStage, info.level)
        
        lb2Str["mFightingNum"] =GameUtil:formatDotNumber(info.fightValue)--common:getLanguageString("@ArenaFightingNum",info.fightValue)

        local headNode = ScriptContentBase:create(mercenaryHeadContent.ccbiFile)
        local parentNode = container:getVarNode("mHeadNode")
        parentNode:removeAllChildren()
        mercenaryHeadContent:refreshItem(headNode,info)
        headNode:setAnchorPoint(ccp(0.5, 0.5))
        parentNode:addChild(headNode)
	  

        if info.cspvpRank and info.cspvpRank > 0 then
        local stage = OSPVPManager.checkStage(info.cspvpScore, info.cspvpRank)
            --sprite2Img.mFrame = stage.stageIcon
        else
            --sprite2Img.mFrame = GameConfig.QualityImage[1]
        end
    end

    NodeHelper:setStringForLabel(container,lb2Str)
    NodeHelper:setSpriteImage(container,sprite2Img,scaleMap)
    NodeHelper:setQualityFrames(container, menu2Quality)
    NodeHelper:setNodesVisible(container, {
        -- 上線狀態/時間
        mLastLandTime = false,
    })
end

function FriendApplyItem:onSure(container)
    local id = self.id
    FriendManager.agreeApply(id)
end

function FriendApplyItem:onDelete(container)
    local id = self.id
    FriendManager.refuseApply(id)
end

function FriendApplyItem:onViewDetail(container)
    --local id = self.id
    --FriendManager.setViewPlayerId(id)
    --ViewPlayerInfo:getInfo(id)
end

function FriendApplyPageBase:onLoad(container)
    if not Golb_Platform_Info.is_entermate_platform then
		container:loadCcbiFile(option.ccbiFile)
	else 
		container:loadCcbiFile(option.entermateCcbiFile)
	end
	container.scrollview=container:getVarScrollView("mContent");
	if container.scrollview~=nil then
		--container:autoAdjustResizeScrollview(container.scrollview);
	end
end

function FriendApplyPageBase:onEnter(container) 
	self:registerPacket(container)	

    container:registerMessage(MSG_MAINFRAME_REFRESH)
	
	NodeHelper:initScrollView(container, "mContent", 10);
    roleConfig = ConfigManager.getRoleCfg()
    self:clearAndReBuildAllItem(container)

    FriendManager.hasCheckedApply()

    local friendList = FriendManager.getFriendList()
	local friendSize = #friendList
    NodeHelper:setStringForLabel(container, { mFriendLimitNum = common:getLanguageString('@FriendNumLimitTxt',tostring(friendSize)) })
end

function FriendApplyPageBase:clearAndReBuildAllItem(container)
    container.mScrollView:removeAllCell()
    local friendApplyList = FriendManager.getFriendApplyList()
    if #friendApplyList >= 1 then
        for i,v in ipairs(friendApplyList) do
            local titleCell = CCBFileCell:create()
            local panel = FriendApplyItem:new({id = v.playerId, index = i})
            titleCell:registerFunctionHandler(panel)
            titleCell:setCCBFile(FriendApplyItem.ccbiFile)
            container.mScrollView:addCellBack(titleCell)
        end
        container.mScrollView:orderCCBFileCells()
    end
    local isRequestEmpty = #friendApplyList < 1
    NodeHelper:setNodesVisible(container, {mEmpty = isRequestEmpty})
end

function FriendApplyPageBase:onExecute(container)
	
end	

function FriendApplyPageBase:onExit(container)
    self:removePacket(container)

end

function FriendApplyPageBase:onClose(container)
    PageManager.popPage(thisPageName)
end

function FriendApplyPageBase:onReceivePacket(container)
	local opcode = container:getRecPacketOpcode()
	local msgBuff = container:getRecPacketBuffer()
	if opcode == HP_pb.FRIEND_LIST_S then
		
	end
end

--�̳д���Ļ���ͬʱ������Ϣ��������ͬʱ����,ͨ��tag������
function FriendApplyPageBase:onReceiveMessage(container)
	local message = container:getMessage()
	local typeId = message:getTypeId()
	if typeId == MSG_MAINFRAME_REFRESH then
		local pageName = MsgMainFrameRefreshPage:getTrueType(message).pageName
		if pageName == thisPageName then
			--FriendPageBase:onRequestData(container)
            self:clearAndReBuildAllItem(container)
        elseif pageName == OSPVPManager.moduleName then
            local extraParam = MsgMainFrameRefreshPage:getTrueType(message).extraParam
            if extraParam == OSPVPManager.onLocalPlayerInfo then
                if container.mScrollView then
                    container.mScrollView:refreshAllCell()
                end
            end
		end
	end
end

function FriendApplyPageBase:registerPacket(container)
    for key, opcode in pairs(option.opcodes) do
		if string.sub(key, -1) == "S" then
			container:registerPacket(opcode)
		end
	end
end

function FriendApplyPageBase:removePacket(container)
	for key, opcode in pairs(option.opcodes) do
		if string.sub(key, -1) == "S" then
			container:removePacket(opcode)
		end
	end
end

-------------------------------------------------------------------------
local CommonPage = require("CommonPage");
local FriendApplyPage = CommonPage.newSub(FriendApplyPageBase, thisPageName, option);