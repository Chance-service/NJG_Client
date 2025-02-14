local common = require("common")
local HP_pb = require("HP_pb")
local Friend_pb = require("Friend_pb")
local PageManager = require("PageManager")
local UserInfo = require("PlayerInfo.UserInfo");
local OSPVPManager = require("OSPVPManager")
local table = require "table"
local MessageBoxPage = MessageBoxPage
local ipairs = ipairs
local pairs = pairs
local string = string
local tostring = tostring
local print = print

module("FriendManager")

local friend_apply_list = {}

local friend_list = {}

local new_friend_list = {}

--local send_apply_list = {}

local isInitFriendList = false
local isInitFriendApplyList = false

local FRIEND_MAIN_PAGE = "FriendPage"
local FRIEND_APPLY_PAGE = "FriendApplyPage"
local MAIN_PAGE = "MainScenePage"

onSyncApplyList = "onSyncApplyList"
onSyncList = "onSyncList"
onNewFriendApply = "onNewFriendApply"
onNewFriendAdd = "onNewFriendAdd"
onNoticeChecked = "onFriendNoticeChecked"

local needCheck = false

local viewPlayerId = nil

local agreePlayerId = nil

local deletePlayerId = nil

local function doNoticeCheck()
    if friend_apply_list and #friend_apply_list > 0 then
        needCheck = true
        PageManager.refreshPage(MAIN_PAGE, onSyncApplyList)
        PageManager.refreshPage(FRIEND_MAIN_PAGE, onNewFriendApply)
    else
        needCheck = false
        PageManager.refreshPage(MAIN_PAGE, onNoticeChecked)
        PageManager.refreshPage(FRIEND_MAIN_PAGE, onNoticeChecked)
    end
end

-- friendID : 0: all >0:特定好友
function requestGiftTo(friendID)
    local msg = Friend_pb.HPGiftFriendshipReq()
	msg.friendId = friendID
    print(string.format("Send[%s] MsgType[%s] friendID[%s]", "HP_pb.FRIEND_POINT_GIFT_C", "HPGiftFriendshipReq", tostring(friendID)))
	common:sendPacket(HP_pb.FRIEND_POINT_GIFT_C, msg, true)
end

-- friendID : 0: all >0:特定好友
function requestGiftFrom(friendID) 
    local msg = Friend_pb.HPGetFriendshipReq()
	msg.friendId = friendID
	common:sendPacket(HP_pb.FRIEND_POINT_GET_C, msg, true)
end

function requestFriendApplyList()
    if isInitFriendApplyList then return end
    common:sendEmptyPacket(HP_pb.FRIEND_APPLY_LIST_C, false)
end

function requestFriendList()
    if isInitFriendList then 
        PageManager.refreshPage(FRIEND_MAIN_PAGE, onSyncList)
        return 
    end
    common:sendEmptyPacket(HP_pb.FRIEND_LIST_C, false)
end

function searchFriendById(id)
    local msg = Friend_pb.HPFindFriendReq()
    msg.playerId = id
    common:sendPacket(HP_pb.FRIEND_FIND_C, msg, true)
end

function searchFriendByName(name)
    local msg = Friend_pb.HPFindFriendReq()
    msg.playerId = 0
    msg.playerName = name
    common:sendPacket(HP_pb.FRIEND_FIND_C, msg, true)
end
function sendApplyById(id)
--    if common:table_hasValue(send_apply_list,id) then
--        MessageBoxPage:Msg_Box('@FriendAlreadyRecommendTxt')
--        return
--    end
    if getFriendInfoById(id).playerId then
        MessageBoxPage:Msg_Box("@AlreadyBeFriendTxt")
        return
    end
    if id == UserInfo.playerInfo.playerId then
        MessageBoxPage:Msg_Box("@FriendAddSelfTxt")
        return
    end
    local msg = Friend_pb.HPApplyFriend()
    msg.playerId = id
    common:sendPacket(HP_pb.FRIEND_APPLY_C, msg, false)
    --MessageBoxPage:Msg_Box("@RecommendSuccessTxt")
    --table.insert(send_apply_list,id)
end

function agreeApply(id)
    agreePlayerId = id
    local msg = Friend_pb.HPRefuseApplyFriend()
    msg.playerId = id
    common:sendPacket(HP_pb.FRIEND_AGREE_C, msg, false)
end

function refuseApply(id)
    local msg = Friend_pb.HPRefuseApplyFriend()
    msg.playerId = id
    common:sendPacket(HP_pb.FRIEND_REFUSE_C, msg, true)
end

function deleteById(id)
    PageManager.showConfirm(common:getLanguageString("@FriendDeleteTitle"),common:getLanguageString("@FriendDeleteTxt"),function(isSure)
        if isSure then
            deletePlayerId = id
            local msg = Friend_pb.HPFriendDel()
            msg.targetId = id
            common:sendPacket(HP_pb.FRIEND_DELETE_C, msg, true)
        end
    end)
end

function syncFriendList(msg)
    --isInitFriendList = true
    if msg.friendItem then
        friend_list = {}
        local playerIds = {}
        for i = 1, #msg.friendItem do
            table.insert(friend_list, msg.friendItem[i])
            table.insert(playerIds, msg.friendItem[i].playerId)
        end
        if #playerIds > 0 then
            OSPVPManager.reqLocalPlayerInfo(playerIds)
        end
        PageManager.refreshPage(FRIEND_MAIN_PAGE, onSyncList)
    end
end

function syncFriendApplyList(msg)
    isInitFriendApplyList = true
    if msg.friendItem then
        friend_apply_list = {}
        local playerIds = {}
        for i = 1, #msg.friendItem do
            table.insert(friend_apply_list, msg.friendItem[i])
            table.insert(playerIds, msg.friendItem[i].playerId)
        end
        if #playerIds > 0 then
            OSPVPManager.reqLocalPlayerInfo(playerIds)
        end
        PageManager.refreshPage(FRIEND_APPLY_PAGE, onSyncApplyList)
        doNoticeCheck()
    end
end

function onNewApply(playerItem)
    for k,v in pairs(friend_apply_list) do
        if v.playerId == playerItem.playerId then return end
    end
    needCheck = true
    table.insert(friend_apply_list,playerItem)
    OSPVPManager.reqLocalPlayerInfo({playerItem.playerId})
    PageManager.refreshPage(FRIEND_APPLY_PAGE, onSyncApplyList)
    PageManager.refreshPage(FRIEND_MAIN_PAGE, onNewFriendApply)
    PageManager.refreshPage(MAIN_PAGE, onNewFriendApply)
end

function onNewFriend(playerItem)
    for k,v in pairs(friend_list) do
        if v.playerId == playerItem.playerId then return end
    end
    local new_apply_list = {}
    local needRefreshApply = false
    for i,v in pairs(friend_apply_list) do
        if v.playerId == playerItem.playerId then
            needRefreshApply = true
        else
            table.insert(new_apply_list, v)
        end
    end
    table.insert(friend_list,playerItem)
    OSPVPManager.reqLocalPlayerInfo({playerItem.playerId})
    PageManager.refreshPage(MAIN_PAGE, onNewFriendAdd)
    PageManager.refreshPage(FRIEND_MAIN_PAGE, onSyncList)
    if needRefreshApply then
        friend_apply_list = new_apply_list
        PageManager.refreshPage(FRIEND_APPLY_PAGE, onSyncApplyList)
        --doNoticeCheck()
    end
    if agreePlayerId then
        agreePlayerId = nil
        MessageBoxPage:Msg_Box(common:getLanguageString("@FriendAddSuccessTxt",playerItem.name))
    end
    --send_apply_list = common:table_removeFromArray(send_apply_list, playerItem.playerId)
end

function onDeleteFriend(playerId)
    local newList = {}
    for k,v in ipairs(friend_list) do
        if v.playerId ~= playerId then
            table.insert(newList, v)
        end
    end
    friend_list = newList
    --send_apply_list = common:table_removeFromArray(send_apply_list, playerId)
    PageManager.refreshPage(FRIEND_MAIN_PAGE, onSyncList)
    if deletePlayerId and deletePlayerId == playerId then
        deletePlayerId = nil
        MessageBoxPage:Msg_Box("@DelFriendSuccess")
    end
end

function onRefuseApply(playerId)
    local newList = {}
    for k,v in ipairs(friend_apply_list) do
        if v.playerId ~= playerId then
            table.insert(newList, v)
        end
    end
    friend_apply_list = newList
    --send_apply_list = common:table_removeFromArray(send_apply_list, playerId)
    PageManager.refreshPage(FRIEND_APPLY_PAGE, onSyncApplyList)  
    --doNoticeCheck()
end

function getFriendApplyList()
    return friend_apply_list
end

function getFriendList()
    return friend_list
end

function getApplyInfoById(playerId)
    local info = {}
    for i,v in ipairs(friend_apply_list) do
        if v.playerId == playerId then
            info = v
            break
        end
    end
    return info
end

function getFriendInfoById(playerId)
    local info = {}
    for i,v in ipairs(friend_list) do
        if v.playerId == playerId then
            info = v
            break
        end
    end
    return info
end

function getFriendInfoByName(name)
    local info = {}
    for i,v in ipairs(friend_list) do
        if v.name == name then
            info = v
            break
        end
    end
    return info
end

function hasCheckedApply()
    needCheck = false
    PageManager.refreshPage(MAIN_PAGE, onNoticeChecked)
    PageManager.refreshPage(FRIEND_MAIN_PAGE, onNoticeChecked)
end

function needCheckNotice()
    return needCheck
end

function setViewPlayerId(playerId)
    viewPlayerId = playerId
end

function getViewPlayerId()
    return viewPlayerId
end

function cleanViewPlayer()
    viewPlayerId = nil
end