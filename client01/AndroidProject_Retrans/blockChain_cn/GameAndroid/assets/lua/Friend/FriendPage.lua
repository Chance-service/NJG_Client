----------------------------------------------------------------------------------
--好友面板
--点击主界面按钮显示
----------------------------------------------------------------------------------
require "Friend_pb"
require "Const_pb"
require "HP_pb"
local GameConfig = require "GameConfig"
local thisPageName = "FriendPage"
local NewbieGuideManager = require("NewbieGuideManager")
local RoleManager = require("PlayerInfo.RoleManager")
local json = require('json')
local UserInfo = require("PlayerInfo.UserInfo")
local NodeHelper = require("NodeHelper")
local ViewPlayerInfo = require("PlayerInfo.ViewPlayerInfo")

local FRIEND_MAX_NUM = 50

local option = {
	ccbiFile = "FriendPage.ccbi",
	entermateCcbiFile = "FriendPage_KR.ccbi",
	handlerMap = {
		onSearchFriend = "onSearchFriend",
		onFriendRecommend = "onFriendRecommend",
		onGetAllGift = "onGetAllGift",
		onSendAllGift = "onSendAllGift",
		onHelp = "onHelp",
		onClose = "onClose"
	},
	opcodes = {
		FRIEND_POINT_GET_S = HP_pb.FRIEND_POINT_GET_S,
		FRIEND_POINT_GIFT_S = HP_pb.FRIEND_POINT_GIFT_S,
	}
}

local FriendPageBase = {}

-----------------------------------------------
local mercenaryHeadContent = {
	ccbiFile = "FormationTeamContent.ccbi"
}
function mercenaryHeadContent:refreshItem(container,Info)
	self.container = container
	UserInfo = require("PlayerInfo.UserInfo")
	local roleIcon = ConfigManager.getRoleIconCfg()
	local trueIcon = GameConfig.headIconNew or Info.headIcon
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
local FriendItem = {
ccbiFile 	= "FriendContent.ccbi",
entermateCcbiFile = "FriendContent_KR.ccbi",
}

function FriendItem:new(o)
	o = o or {}
	setmetatable(o,self)
	self.__index = self
	return o
end

function FriendItem:onRefreshContent(ccbRoot)
	local container = ccbRoot:getCCBFileNode()
	local id = self.id
	--local index = self.index
	local info = FriendManager.getFriendInfoById(id)

	local sprite2Img = {}
	local scaleMap = {}
	local menu2Quality = {}
	local lb2Str = {}
	local node2Visible = {}

	if info then
		lb2Str["mName"] = info.name
		lb2Str["mLevelNum"] = UserInfo.getOtherLevelStr(info.rebirthStage, info.level)
	   
		lb2Str["mFightingNum"] =  GameUtil:formatDotNumber(info.fightValue)--common:getLanguageString("@ArenaFightingNum",info.fightValue)
		if info.offlineTime and info.offlineTime >= 1 then
			lb2Str["mLastLandTime"] = common:getLanguageString("@FriendLastTimeTxt", common:secondToDateXX(info.offlineTime, 7))
			NodeHelper:setColorForLabel(container,{mLastLandTime = "247 18 228"})
		else
			lb2Str["mLastLandTime"] = common:getLanguageString("@FriendOnlineTxt")
			NodeHelper:setColorForLabel(container,{mLastLandTime = "0 224 0"})
		end

		print("FriendItem:onRefreshContent==========")
		print(info.name)
		print(string.format("info.canGift[%s], info.haveGift[%s]", tostring(info.canGift), tostring(info.haveGift)))

		--node2Visible["mGiftNode"] = info.haveGift or info.canGift
		--NodeHelper:setNodesVisible(container, node2Visible)
		NodeHelper:setMenuItemEnabled(container, "mGetGift", info.haveGift)
		NodeHelper:setMenuItemEnabled(container, "mSendGift", info.canGift)

		local headNode = ScriptContentBase:create(mercenaryHeadContent.ccbiFile)
		local parentNode = container:getVarNode("mHeadNode")
		parentNode:removeAllChildren()
		mercenaryHeadContent:refreshItem(headNode,info)
		headNode:setAnchorPoint(ccp(0.5, 0.5))
		parentNode:addChild(headNode)
	end

	NodeHelper:setStringForLabel(container,lb2Str)
	NodeHelper:setSpriteImage(container,sprite2Img,scaleMap)
	NodeHelper:setQualityFrames(container, menu2Quality)
end

function FriendItem:onSure(container)
	local id = self.id
	FriendManager.agreeApply(id)
end

function FriendItem:onSendMail(container)
	local id = self.id
	local info = FriendManager.getFriendInfoById(id)
	if 1 then--ViewPlayerInfo.isSendAllow then
		--跳转到个人聊天页面
		local ChatManager = require("Chat.ChatManager")
		local Friend_pb = require("Friend_pb")
		--add playerinfo into msgbox
		local info = FriendManager.getFriendInfoById(id)
		local chatUnit = Friend_pb.MsgBoxUnit()
		--PageManager.changePage("ChatPage")
		resetMenu("mChatBtn",true)
		chatUnit.playerId = id
		chatUnit.name = info.name
		chatUnit.level = info.level
		chatUnit.roleItemId = info.roleId
		chatUnit.avatarId = info.avatarId
		chatUnit.headIcon = info.headIcon
		--私聊聊天记录修改
		if isSaveChatHistory then
			ChatManager.insertSortChatPrivate(id)
		end
		ChatManager.insertPrivateMsg(id,chatUnit,nil, false,false)
		ChatManager.setCurrentChatPerson(id)
		
		PageManager.popAllPage()    
		if MainFrame:getInstance():getCurShowPageName() ~= "ChatPage" then
			BlackBoard:getInstance():delVarible("PrivateChat")
			BlackBoard:getInstance():addVarible("PrivateChat","PrivateChat")
			PageManager.pushPage("ChatPage")
		end
		PageManager.refreshPage("ChatPage","PrivateChat")

	else
		MessageBoxPage:Msg_Box("@PrivateChatLimitInvoke")
	end
end

function FriendItem:onGetGift(container)
	local id = self.id
	local info = FriendManager.getFriendInfoById(id)
	if info.haveGift then 
		FriendManager.requestGiftFrom(id)
	end
end

function FriendItem:onSendGift(container)
	local id = self.id
	local info = FriendManager.getFriendInfoById(id)
	if info.canGift then
		FriendManager.requestGiftTo(id)
	end
end

function FriendItem:onDelete(container)
	local id = self.id
	FriendManager.deleteById(id)
end

function FriendItem:onViewDetail(container)
	--local id = self.id
	--FriendManager.setViewPlayerId(id)
	--ViewPlayerInfo:getInfo(id)
end
----------------------------------------------------------------------------------

-----------------------------------------------
--FriendPageBase页面中的事件处理
----------------------------------------------
function FriendPageBase:onLoad(container)
	if not Golb_Platform_Info.is_entermate_platform then
		container:loadCcbiFile(option.ccbiFile)
	else 
		container:loadCcbiFile(option.entermateCcbiFile)
	end
	container.scrollview=container:getVarScrollView("mContent")

	local mScale9Sprite2 = container:getVarScale9Sprite("mScale9Sprite2")
	if mScale9Sprite2 ~= nil then
		container:autoAdjustResizeScale9Sprite( mScale9Sprite2 )
	end
	
	local mScale9Sprite3 = container:getVarScale9Sprite("mScale9Sprite3")
	if mScale9Sprite3 ~= nil then
		container:autoAdjustResizeScale9Sprite( mScale9Sprite3 )
	end
end

function FriendPageBase:onEnter(container)
	self:registerPacket(container)	
	
	print("UserInfo.stateInfo.friendship:"..tostring(UserInfo.stateInfo.friendship))

	container:registerMessage(MSG_MAINFRAME_REFRESH)
	
	NodeHelper:initScrollView(container, "mContent", 10)
	NodeHelper:setNodesVisible(container, { mRecommendPoint = FriendManager.needCheckNotice() })

	self:onRequestData(container)
	
	NewbieGuideManager.showHelpPage(GameConfig.HelpKey.HELP_FRIEND)	
end

function FriendPageBase:onHelp( container )
	PageManager.showHelp(GameConfig.HelpKey.HELP_FRIEND)
end

function FriendPageBase:getKakaoFriendsList()
	FriendPageBase.libPlatformListener = LibPlatformScriptListener:new(libPlatformListener)	
	libPlatformManager:getPlatform():OnKrgetFriendLists()
end

function FriendPageBase:onRequestData(container)
	FriendManager.requestFriendList()
end

function FriendPageBase:onExecute(container)
	
end	

function FriendPageBase:onExit(container)
	container:removeMessage(MSG_MAINFRAME_REFRESH)
	NodeHelper:deleteScrollView(container);	
end

function FriendPageBase:onClose(container)
	PageManager.popPage(thisPageName)
end
----------------------------------------------------------------

function FriendPageBase:refreshPage(container)
	local friendList = FriendManager.getFriendList()
	local friendSize = #friendList
	local hasNoFriend = container:getVarNode("NoFriendTxt")
	local hasNoFreindSprite=container:getVarNode("NoFriendSprite")
	
	local canGift = self:isAnyCanGift(friendList)
	local haveGift = self:isAnyHaveGift(friendList)
	local isHasFriend = friendSize > 0
	print("isAnyCanGiftOrHaveGift : "..tostring(isAnyCanGiftOrHaveGift))
	
	NodeHelper:setNodesVisible(container, {
		mScale9Sprite2 = isHasFriend,
		NoFriendTxt = not isHasFriend,
		NoFriendSprite = not isHasFriend,
		mGiftPoint = canGift or haveGift,
	})

	friendSize = math.max(0,friendSize)
	local onlineSize = 0
	for idx, friendInfo in ipairs(friendList) do 
		if friendInfo.offlineTime == nil then
			onlineSize = onlineSize + 1
		end
		print(string.format("name[%s], info.canGift[%s], info.haveGift[%s]", friendInfo.name, tostring(friendInfo.canGift), tostring(friendInfo.haveGift)))
	end
	local friendshipPoint = UserInfo.stateInfo.friendship or 0
	local lb2Str = {
		mFriendPointNum = tostring(friendshipPoint),
		mFriendLimitNum = common:getLanguageString('@FriendNumLimitTxt',tostring(friendSize)),
		mFriendOnlineNum = common:getLanguageString('@Friend.currentOnlineNumDesc',tostring(onlineSize)),
	}
	NodeHelper:setStringForLabel(container, lb2Str)

	NodeHelper:setMenuItemEnabled(container, "mGetAllGift", haveGift)
	NodeHelper:setMenuItemEnabled(container, "mSendAllGift", canGift)
end


----------------scrollview-------------------------
function FriendPageBase:rebuildAllItem(container)
	self:clearAllItem(container);
	self:buildItem(container);
end

function FriendPageBase:clearAllItem(container)
	container.mScrollView:removeAllCell()
end

function FriendPageBase:buildItem(container)
	local list = FriendManager.getFriendList()
	table.sort(list,function(a,b)
		if not a.offlineTime or a.offlineTime < 1 then
			if not b.offlineTime or b.offlineTime < 1 then
				if a.level ~= b.level then
					return a.level > b.level
				else
					return a.playerId < b.playerId
				end
			else
				return true
			end
		else
			if not b.offlineTime or b.offlineTime < 1 then
				return false
			else
				if a.level ~= b.level then
					return a.level > b.level
				else
					return a.playerId < b.playerId
				end
			end
		end
	end)

	--All the friend's list
	local friendSize = #list;
	local ccbiFile = FriendItem.ccbiFile

	--if friendSize ==1 return 
	if friendSize < 1 or ccbiFile == nil or ccbiFile == ''then return end
	--totolSize = 6
	for i ,v in ipairs(list) do
		local titleCell = CCBFileCell:create()
		local panel = FriendItem:new({id = v.playerId})
		titleCell:registerFunctionHandler(panel)
		titleCell:setCCBFile(ccbiFile)
		container.mScrollView:addCellBack(titleCell)
	end
	container.mScrollView:orderCCBFileCells()
end

----------------click event------------------------
function FriendPageBase:onCancel(container)
end

function FriendPageBase:onSearchFriend(container)
	if #FriendManager.getFriendList() >= FRIEND_MAX_NUM then
		MessageBoxPage:Msg_Box("@FriendNumReachLimitTxt")
		return
	end
	PageManager.pushPage("FriendSearchPopPage");
end

function FriendPageBase:onFriendRecommend(container)
	PageManager.pushPage("FriendApplyPage")
end

function FriendPageBase:onGetAllGift(container)
	local friendList = FriendManager.getFriendList()

	if #friendList == 0 then
		MessageBoxPage:Msg_Box_Lan("@Eighteentip2")
	else
		local haveGift = self:isAnyHaveGift(friendList)
		if haveGift then
			FriendManager.requestGiftFrom(0)
		else
			MessageBoxPage:Msg_Box_Lan("@Eighteentip2")
		end
	end
end

function FriendPageBase:onSendAllGift(container)
	local friendList = FriendManager.getFriendList()

	if #friendList == 0 then
		MessageBoxPage:Msg_Box_Lan("@Eighteentip2")
	else
		local canGift = self:isAnyCanGift(friendList)
		if canGift then
			FriendManager.requestGiftTo(0)
		else
			MessageBoxPage:Msg_Box_Lan("@Eighteentip2")
		end
	end
end

--回包处理
function FriendPageBase:onReceivePacket(container)
	local opcode = container:getRecPacketOpcode()
	local msgBuff = container:getRecPacketBuffer()

	print("FriendPageBase:onReceivePacket")

	if opcode == HP_pb.FRIEND_POINT_GET_S then
		print("FRIEND_POINT_GET_S")
		print("UserInfo.stateInfo.friendship:"..tostring(UserInfo.stateInfo.friendship))
		local msg = Friend_pb.HPGetFriendshipRes()
		msg:ParseFromString(msgBuff)
		print(msg.friendId)
		print(msg.point)
		FriendManager.requestFriendList()
		if msg.friendId == 0 then
			MessageBoxPage:Msg_Box_Lan("@FriendpointGetall")
		else
			MessageBoxPage:Msg_Box_Lan("@FriendpointGet")
		end
	elseif opcode == HP_pb.FRIEND_POINT_GIFT_S then
		print("FRIEND_POINT_GIFT_S")
		local msg = Friend_pb.HPGiftFriendshipReq()
		msg:ParseFromString(msgBuff)
		FriendManager.requestFriendList()
		if msg.friendId == 0 then
			MessageBoxPage:Msg_Box_Lan("@FriendpointSendall")
		else
			MessageBoxPage:Msg_Box_Lan("@FriendpointSend")
		end
	end
end

--继承此类的活动如果同时开，消息监听不能同时存在,通过tag来区分
function FriendPageBase:onReceiveMessage(container)
	local message = container:getMessage()
	local typeId = message:getTypeId()
	if typeId == MSG_MAINFRAME_REFRESH then
		local pageName = MsgMainFrameRefreshPage:getTrueType(message).pageName;
		local extraParam = MsgMainFrameRefreshPage:getTrueType(message).extraParam
		if pageName == thisPageName then
			if extraParam == FriendManager.onNewFriendApply then
				NodeHelper:setNodesVisible(container, {mRecommendPoint = true})
			elseif extraParam == FriendManager.onNoticeChecked then
				NodeHelper:setNodesVisible(container, {mRecommendPoint = false})
			elseif extraParam == FriendManager.onSyncList then
				self:refreshPage(container);	
				self:rebuildAllItem(container)	
			end
		end
	end
end

function FriendPageBase:registerPacket(container)
	for key, opcode in pairs(option.opcodes) do
		if string.sub(key, -1) == "S" then
			container:registerPacket(opcode)
			print("registerPacket : "..tostring(opcode))
		end
	end
end

function FriendPageBase:removePacket(container)
	for key, opcode in pairs(option.opcodes) do
		if string.sub(key, -1) == "S" then
			container:removePacket(opcode)
		end
	end
end


function FriendPageBase:isAnyCanGift (friendList)
	for idx, friendInfo in ipairs(friendList) do
		if friendInfo.canGift then
			print(friendInfo.name.." can gift")
			return true
		end
	end
	return false
end

function FriendPageBase:isAnyHaveGift (friendList)
	for idx, friendInfo in ipairs(friendList) do
		if friendInfo.haveGift then
			print(friendInfo.name.." have gift")
			return true
		end
	end
	return false
end

-------------------------------------------------------------------------
local CommonPage = require("CommonPage");
local FriendPage = CommonPage.newSub(FriendPageBase, thisPageName, option);