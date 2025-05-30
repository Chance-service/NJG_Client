----------------------------------------------------------------------------------
--[[
	
--]]
----------------------------------------------------------------------------------
local option = {
	ccbiFile = "GeneralDecisionPopUp.ccbi",
	handlerMap = {
		onCancel		= "onNo",
		onClose			= "onNo",
		onConfirmation 	= "onYes"
	}
};
local UserInfo = require("PlayerInfo.UserInfo");
local thisPageName = "GuildOpenBossConfirmPage";
local CommonPage = require("CommonPage");
local GuildData = require("Guild.GuildData")
local hp = require('HP_pb')
local alliance = require('Alliance_pb')
local GuildOpenBossConfirmPage = CommonPage.new(thisPageName, option);
local decisionMsg = ""
local bossOpenFlag = false
local needGold = 0;

local NodeHelper = require("NodeHelper");
----------------------------------------------------------------------------------
--GuildOpenBossConfirmPage页面中的事件处理
----------------------------------------------
function GuildOpenBossConfirmPage.onEnter(container)
	bossOpenFlag = false
	container:registerPacket(hp.ALLIANCE_CREATE_S)
    local timesInfo = GuildData.allianceInfo.commonInfo.remainderBossTimes.."/"..GuildData.allianceInfo.commonInfo.allBossTimes
	decisionMsg = common:getLanguageString('@OpenBossDescNowVersion', GuildData.allianceInfo.commonInfo.openBossVitality, GuildData.allianceInfo.commonInfo.curBossVitality,timesInfo)
	NodeHelper:setStringForLabel(container, {
		mTitle 			= common:getLanguageString('@OpenBoss'),
		mDecisionTex 	= common:stringAutoReturn(decisionMsg, 20)		--20: char per line
	})
	NodeHelper:setNodeScale(container,"mDecisionTex",1,1)
	NodeHelper:setNodesVisible(container, {mButtonDoubleNode = true, mButtonMiddleNode = false})
end

function GuildOpenBossConfirmPage.onExit(container)
	container:removePacket(hp.ALLIANCE_CREATE_S)
end

function GuildOpenBossConfirmPage.onNo(container)
	PageManager.popPage(thisPageName)
end

function GuildOpenBossConfirmPage.onYes(container)
	if needGold > 0 and UserInfo.playerInfo.gold < needGold then
		PageManager.popPage(thisPageName)
		PageManager.notifyLackGold();
		return;
	end

	-- send open boss packet
	local msg = alliance.HPAllianceBossFunOpenC()
	msg.operType = 1 -- 1 == BossOperOpen
	local pb = msg:SerializeToString()
	container:sendPakcet(hp.ALLIANCE_BOSSFUNOPEN_C, pb, #pb, false)
	bossOpenFlag = true
end	

-- 由于开启boss没有特定的回包，用的是公会信息共用包，所以要设置一个标志bossOpenFlag
-- 来判断这个包是否是开启boss的回包
function GuildOpenBossConfirmPage.onReceiveAllianceInfo(container, msg)

	-- new boss state included in the msg
	GuildData.allianceInfo.commonInfo = msg

	-- if this return packdet is not for open boss, don't close this page.
	-- i need ensure the GuildPage has received new boss state before
	-- close this page.
	if bossOpenFlag then
		-- notice GuildPage refreshPage
		local msg = MsgMainFrameRefreshPage:new()
		msg.pageName = 'GuildPage_Refresh_Right_Now'
		MessageManager:getInstance():sendMessageForScript(msg)

		-- close this pop
		PageManager.popPage(thisPageName)
	end
end

function GuildOpenBossConfirmPage.onReceivePacket(container)
	local opcode = container:getRecPacketOpcode()
	local msgBuff = container:getRecPacketBuffer()

	if opcode == hp.ALLIANCE_CREATE_S then
		-- create alliance
		local msg = alliance.HPAllianceInfoS()
		msg:ParseFromString(msgBuff)
		GuildOpenBossConfirmPage.onReceiveAllianceInfo(container, msg)
         if UserInfo.hasAlliance ~= nil and not UserInfo.hasAlliance  then
           PageManager.showComment()   --评价提示
        end
		return
	end
end

