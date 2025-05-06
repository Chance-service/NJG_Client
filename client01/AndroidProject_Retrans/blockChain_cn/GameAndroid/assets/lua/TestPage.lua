local NodeHelper = require("NodeHelper")
local thisPageName = "TestPage"
local RoleOpr_pb = require("RoleOpr_pb")
local UserMercenaryManager = require("UserMercenaryManager")

local TestPage = { }

local option = {
    ccbiFile = "TestPage.ccbi",
    handlerMap =
    {
        onClose = "onClose",
        -- SETTING
        onBtn1 = "onBtn1", onBtn2 = "onBtn2",
        onBtn3 = "onBtn3", onBtn4 = "onBtn4", 
        onBtn5 = "onBtn5", onBtn6 = "onBtn6", 
    },
    opcodes =
    {
        -- 切換皮膚
        ROLE_CHANGE_SKIN_C = HP_pb.ROLE_CHANGE_SKIN_C,
        ROLE_CHANGE_SKIN_S = HP_pb.ROLE_CHANGE_SKIN_S,
    }
}
-----------------------------------------------------------------------
local libPlatformListener = { }
function libPlatformListener:onPlayMovieEnd(listener)
    if not listener then return end
    GameUtil:setPlayMovieVisible(true)
    GamePrecedure:getInstance():closeMovie(thisPageName)
    local mainContainer = tolua.cast(MainFrame:getInstance(), "CCBContainer")
    local backNode = mainContainer:getCCNodeFromCCB("mNodeMid")
    backNode:setVisible(true)
end

function TestPage:onEnter(container)
    self.container = container
    TestPage.container = container

    self:registerPacket(container)
    local bg = container:getVarSprite("mBg")
    bg:setScale(NodeHelper:getScaleProportion())

    self:refresh(container)
end

-----------------------------------------------------------------------
--- Buttons
function TestPage:refresh(container)
    NodeHelper:setStringForLabel(container, {
        mBtnTxt1 = "1558x720 1.5M",
        mBtnTxt2 = "1558x720 3M",
        mBtnTxt3 = "1280x720 1.5M",
        mBtnTxt4 = "1280x720 3M",
        mBtnTxt5 = "裝備螢火Skin",
        mBtnTxt6 = "脫下螢火Skin",
    })
end
function TestPage:onBtn1(container)
    self:playMovie(container, "HVideo/HV01")
end
function TestPage:onBtn2(container)
    self:playMovie(container, "HVideo/HV02")
end
function TestPage:onBtn3(container)
    self:playMovie(container, "HVideo/HV03")
end
function TestPage:onBtn4(container)
    self:playMovie(container, "HVideo/HV04")
end
function TestPage:onBtn5(container)
    local status = UserMercenaryManager:getMercenaryStatusByItemId(1)
    local msg = RoleOpr_pb.HPChangeMercenarySkinReq()
	msg.fromRoleId = status.roleId
	msg.toRoleId = 1001
    common:sendPacket(HP_pb.ROLE_CHANGE_SKIN_C, msg, false)
end
function TestPage:onBtn6(container)
    local status = UserMercenaryManager:getMercenaryStatusByItemId(1)
    local msg = RoleOpr_pb.HPChangeMercenarySkinReq()
	msg.fromRoleId = status.roleId
	msg.toRoleId = 0
    common:sendPacket(HP_pb.ROLE_CHANGE_SKIN_C, msg, false)
end
---
-----------------------------------------------------------------------
function TestPage:playMovie(container, path)
    -- 播放影片
    if CC_TARGET_PLATFORM_LUA ~= common.platform.CC_PLATFORM_WIN32 then
        LibPlatformScriptListener:new(libPlatformListener)
        GamePrecedure:getInstance():playMovie(thisPageName, path, 0, 0)
        GameUtil:setPlayMovieVisible(false)
        local mainContainer = tolua.cast(MainFrame:getInstance(), "CCBContainer")
        local backNode = mainContainer:getCCNodeFromCCB("mNodeMid")
        backNode:setVisible(false)
    end
end
function TestPage:onClose(container)
    PageManager.popPage(thisPageName)
end
--------------------------------------------------------------------
function TestPage:registerPacket(container)
    for key, opcode in pairs(option.opcodes) do
        if string.sub(key, -1) == "S" then
            container:registerPacket(opcode)
        end
    end
end
function TestPage:removePacket(container)
    for key, opcode in pairs(option.opcodes) do
        if string.sub(key, -1) == "S" then
            container:removePacket(opcode)
        end
    end
end
-- 接收服务器回包
function TestPage:onReceivePacket(container)
    local opcode = container:getRecPacketOpcode()
    local msgBuff = container:getRecPacketBuffer()
    if opcode == HP_pb.ROLE_CHANGE_SKIN_S then
        MessageBoxPage:Msg_Box_Lan("Success")
    end
end
-------------------------------------------------------

local CommonPage = require("CommonPage")
TestPage = CommonPage.newSub(TestPage, thisPageName, option)