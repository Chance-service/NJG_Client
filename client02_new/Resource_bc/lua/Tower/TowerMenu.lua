-- TowerLobby.lua（優化後）

local thisPageName = "Tower.TowerMenu"
local TowerDataBase = require "Tower.TowerPageData"
local PageJumpMange = require("PageJumpMange")
local UserMercenaryManager = require("UserMercenaryManager")
local EquipPage= require("Equip.EquipmentPage")
local TimeDateUtil    = require("Util.TimeDateUtil")
local mainContainer = nil
local CountDown = {}
require("TransScenePopUp")

local option = {
    ccbiFile = "Tower_Memu.ccbi",
    handlerMap = {
        onReturn = "onReturn",
        onPass = "onPass"
    },
    opcode = {},
}

local TowerLobby = {}
local StageContent = { ccbiFile = "Tower_Memu_Content.ccbi" }

-- Stage 配置
local StageData = {
    { id = 1, Page = "Tower.TowerPage", ActId = 194, TypePassId = {} },
    { id = 2, Page = "TowerLimit.TowerLimitPage", ActId = 198, TypePassId = {} },
    { id = 3, Page = "TowerLimit.TowerLimitPage", ActId = 198, TypePassId = {} },
    { id = 4, Page = "TowerOneLife.TowerOneLifePage", ActId = 199, TypePassId = {} },
}
local _ClickType = 1
-- 賦值 TypePassId
local function setPassedId()
    local data = TowerDataBase:getData()
    for _, content in ipairs(StageData) do
        local info = data[content.ActId] or {}
        for k, v in pairs(info) do
            if content.id == 3 and k > 10 then
                content.TypePassId[k - 10] = v.MaxFloor
            elseif content.id == 2 and k < 5 then
                content.TypePassId[k] = v.MaxFloor
            elseif content.id ~= 2 and content.id ~= 3 then
                content.TypePassId[k] = v.MaxFloor or 0
            end
            if v.endTime then
                local endTimeSec = math.floor(v.endTime / 1000)
                local clientSafeTime = TimeDateUtil:getClientSafeTime()
                content.leftTime = endTimeSec - clientSafeTime
            end
        end
    end
    table.sort(StageData, function(a, b) return a.id < b.id end)
end

function TowerLobby:onEnter(container)
    if PageJumpMange._IsPageJump then
        local jumpCfg = PageJumpMange._CurJumpCfgInfo
        if jumpCfg and jumpCfg._ThirdFunc and jumpCfg._ThirdFunc ~= "" then
            local func = jumpCfg._ThirdFunc
            if TowerLobby[func] then
                TowerLobby[func](TowerLobby, container)
            end
        end
        PageJumpMange._IsPageJump = false
        TransScenePopUp_closePage()
    else
        PageJumpMange._IsPageJump = false
        TransScenePopUp_closePage()
    end
    setPassedId()
    mainContainer = container
    local bg = container:getVarNode("mBg")
    bg:setScale(NodeHelper:getScaleProportion())

    mainContainer.MainScroll = container:getVarScrollView("mContent")
    NodeHelper:autoAdjustResizeScrollview(mainContainer.MainScroll)
    local mPass = container:getVarNode("mPass")
    if mPass then
        mPass:setPositionY(1080 + NodeHelper:calcAdjustResolutionOffY())
    end

    self:buildContent(mainContainer)

end

function TowerLobby:buildContent(container)
    NodeHelper:setStringForLabel(container, { mPassTxt = common:getLanguageString("@ActivityNotOpen") })
    local scroll = container.MainScroll
    if not scroll then return end
    scroll:removeAllCell()
    for idx = 1, #StageData do
        local cell = CCBFileCell:create()
        cell:setCCBFile(StageContent.ccbiFile)
        local handler = common:new({ id = idx }, StageContent)
        cell:registerFunctionHandler(handler)
        scroll:addCell(cell)
    end
    scroll:orderCCBFileCells()
    scroll:setTouchEnabled(true)
end

function StageContent:onRefreshContent(ccbRoot)
    local container = ccbRoot:getCCBFileNode()
    local id = tonumber(self.id)
    local data = StageData[id]
    if not data then return end
    local PassId = data.TypePassId or {}
    local stringTable = {}
    local isLocked = not ActivityInfo:getActivityIsOpenById(data.ActId)

    NodeHelper:setNodesVisible(container, { mClose = isLocked })
    for i = 1, 4 do
        NodeHelper:setNodesVisible(container, { ["mType" .. i] = i == id })
        local stageKey = (id == 2 or id == 3) and (id .. "_" .. i) or id
        if PassId[i] then
            stringTable["mType" .. stageKey .. "Txt"] = PassId[i]
        end
        if isLocked then
            stringTable["mType" .. stageKey .. "Txt"] = ""
        end
        local limitType = i + ((id == 3) and 10 or 0)
        local Lock = not TowerLobby:canChallenge_Limit(limitType)
        NodeHelper:setNodesVisible(container,{["mLock"..stageKey] = Lock })
    end
    NodeHelper:setStringForLabel(container, stringTable)
    if CountDown[id] then
        CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(CountDown[id])
        CountDown[id] = nil
    end
    if data.leftTime then
        CountDown[id] = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(function()
            data.leftTime = data.leftTime - 0.1
            local timeStr = common:second2DateString5(data.leftTime, false)
            local ShowTxt = common:getLanguageString("@ActFTGiftDiscountTimeTxt", timeStr)
            NodeHelper:setStringForLabel(mainContainer, { mPassTxt = ShowTxt })
            NodeHelper:setStringForLabel(container, { ["mType" .. id .. "Txt"] = ShowTxt })
            TowerRankPage:setTime(timeStr)
        end, 0.1, false)
        if data.leftTime <= 0 and CountDown[id] then
            CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(CountDown[id])
            CountDown[id] = nil
        end
    end
end

local function handleTypeClick(idx)
    local data = StageData[idx]
    _ClickType = idx
    local array = CCArray:create()
    array:addObject(CCCallFunc:create(function()
        PageManager.pushPage("TransScenePopUp")
    end))
    array:addObject(CCDelayTime:create(0.8))
    array:addObject(CCCallFunc:create(function()
        if data then
            PageManager.pushPage(data.Page) -- 切換頁面
        end
    end))
    -- 執行序列
    mainContainer:runAction(CCSequence:create(array))
end
function TowerLobby:getClickType()
    return _ClickType
end
local TabName = {
    [2] = {"Fire", "Water", "Wood", "Light_and_Dark"},
    [3] = {"Shield", "Sword", "Heal", "Magic"},
}

local LimitMessage = {
    [1] = "@ERRORCODE_7001", [2] = "@ERRORCODE_7002",
    [3] = "@ERRORCODE_7003", [4] = "@ERRORCODE_7004",
    [11] = "@ERRORCODE_7005", [12] = "@ERRORCODE_7006",
    [13] = "@ERRORCODE_7007", [14] = "@ERRORCODE_7008",
}

-- 根據 idx 和 k 解析 subPage 與 elementIdx
local function parseSubPageInfo(idx, k)
    local subIdx = tonumber(string.sub(k, -1))
    local subPage = TabName[idx] and TabName[idx][subIdx]
    local elementIdx = (idx == 3) and (subIdx + 10) or subIdx
    return subPage, elementIdx
end

-- StageContent 的 onTypeX_X 事件轉發
local function handleStageContentEvent(k)
    local idx = tonumber(k:match("^onType(%d+)_?%d*$"))
    if not idx or not StageData[idx] then return nil end

    return function()
        if idx == 2 or idx == 3 then
            local subPage, elementIdx = parseSubPageInfo(idx, k)
            local canChallenge = TowerLobby:canChallenge_Limit(elementIdx)
            if canChallenge then
                require("TowerLimit.TowerLimitPage"):setEntrySubPage(subPage)
            else
                MessageBoxPage:Msg_Box(common:getLanguageString(LimitMessage[elementIdx]))
                TowerLobby:buildContent(mainContainer)
                return
            end
        end
        if ActivityInfo:getActivityIsOpenById(StageData[idx].ActId) then 
            handleTypeClick(idx)
        end
    end
end

-- TowerLobby 的 onTypeX_X 頁面跳轉事件
local function handleTowerLobbyEvent(k)
    local idx = tonumber(k:match("^onType(%d+)_?%d*$"))
    if not idx or not StageData[idx] then return nil end

    return function()
        PageManager.pushPage(StageData[idx].Page)
    end
end

-- 註冊 metatable 代理事件
setmetatable(StageContent, {
    __index = function(_, k)
        return handleStageContentEvent(k)
    end
})

setmetatable(TowerLobby, {
    __index = function(_, k)
        return handleTowerLobbyEvent(k)
    end
})

function TowerLobby:onHelp()
    PageManager.showHelp(GameConfig.HelpKey.HELP_PLAYER_RANKING)
end

function TowerLobby:onReturn()
    PageManager.popPage(thisPageName)
    for _,data in pairs (CountDown) do
        CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(data)
        data = nil
    end
    CountDown = {}
end

local function isTowerAccessible()
    -- 檢查活動
    local activityIds = {
        Const_pb.ACTIVITY194_SeasonTower,
        Const_pb.ACTIVITY199_FearLess_TOWER,
    }
    for _, actId in ipairs(activityIds) do
        if ActivityInfo:getActivityIsOpenById(actId) then
            return true
        end
    end

    return false
end

function TowerLobby:onPass()
    if not isTowerAccessible() then
        MessageBoxPage:Msg_Box( common:getLanguageString("@ActivityNotOpen"))
        return
    end
    local array = CCArray:create()
    array:addObject(CCCallFunc:create(function()
        PageManager.pushPage("TransScenePopUp")
    end))
    array:addObject(CCDelayTime:create(0.8))
    array:addObject(CCCallFunc:create(function()     
        PageManager.pushPage("TowerPass.TowerPassPage") -- 切換頁面
    end))
    -- 執行序列
    mainContainer:runAction(CCSequence:create(array))
end


function TowerLobby:registerPacket(container)
    for key, opcode in pairs(option.opcode) do
        if string.sub(key, -1) == "S" then
            container:registerPacket(opcode)
        end
    end
end

function TowerLobby:canChallenge_Limit(_type)
    local cfg = TowerDataBase:getLimitCfg(nil, _type)
    local lvLimit = cfg[1].LevelLimit
    local girlLimit = cfg[1].GirlLimit

    local mercs = EquipPage:sortData(UserMercenaryManager:getMercenaryStatusInfos())
    local heroCfgs = ConfigManager.getNewHeroCfg()
    local isTypeByClass = _type > 10
    local requiredType = _type - (isTypeByClass and 10 or 0)

    local count = 0

    for _, v in ipairs(mercs) do
        if v.itemId <= 24 and v.roleStage == Const_pb.IS_ACTIVITE then
            local cfg = heroCfgs[v.itemId]
            if cfg then
                local class = cfg.Job
                local element = (cfg.Element == 5) and 4 or cfg.Element
                local match = isTypeByClass and class == requiredType
                            or not isTypeByClass and element == requiredType

                if match then
                    local roleInfo = UserMercenaryManager:getUserMercenaryById(v.roleId)
                    if roleInfo and roleInfo.level >= lvLimit then
                        count = count + 1
                    end
                end
            end
        end
    end

    return count >= girlLimit
end




local CommonPage = require('CommonPage')
TowerLobby = CommonPage.newSub(TowerLobby, thisPageName, option)

return TowerLobby
