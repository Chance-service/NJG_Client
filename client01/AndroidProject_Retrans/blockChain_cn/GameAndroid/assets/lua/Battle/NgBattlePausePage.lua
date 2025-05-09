local CONST = require("Battle.NewBattleConst")
require("Battle.NgBattleDataManager")

local thisPageName = "NgBattlePausePage"
local option = {
    ccbiFile = "BattlePagePause.ccbi",
    handlerMap =
    {
        onExit = "onExitPage",
        onRestart = "onRestart",
        onContinue = "onContinue",

        onTestLog = "onTestLog",
        onTestDps = "onTestDps",
    }
}

local NgBattlePausePage = { }

function NgBattlePausePage:onEnter(container)
    container:registerLibOS()
    NodeHelper:setNodesVisible(container, { mTestDpsNode = libOS:getInstance():getIsDebug(), mTestLogNode = libOS:getInstance():getIsDebug() })
end

function NgBattlePausePage:onExitPage(container)
    local PageJumpMange = require("PageJumpMange")
    NgBattleDataManager_setBattleIsPause(false)
    if NgBattleDataManager.battleType == CONST.SCENE_TYPE.BOSS then
        require("Battle.NgBattlePage")
        NgBattlePageInfo_restartAfk(NgBattleDataManager.battlePageContainer)
    elseif NgBattleDataManager.battleType == CONST.SCENE_TYPE.MULTI then
        local PageJumpMange = require("PageJumpMange")
        PageJumpMange.JumpPageById(48)
    elseif NgBattleDataManager.battleType == CONST.SCENE_TYPE.PVP then
        local PageJumpMange = require("PageJumpMange")
        PageJumpMange.JumpPageById(21)
    elseif NgBattleDataManager.battleType == CONST.SCENE_TYPE.WORLD_BOSS then
        local PageJumpMange = require("PageJumpMange")
        PageJumpMange.JumpPageById(45)
    elseif NgBattleDataManager.battleType == CONST.SCENE_TYPE.DUNGEON then
        local PageJumpMange = require("PageJumpMange")
        PageJumpMange.JumpPageById(49)
    elseif NgBattleDataManager.battleType == CONST.SCENE_TYPE.CYCLE_TOWER then
        local PageJumpMange = require("PageJumpMange")
        PageJumpMange.JumpPageById(51)
    elseif NgBattleDataManager.battleType == CONST.SCENE_TYPE.TEST_BATTLE then
        require("Battle.NgBattlePage")
        NgBattlePageInfo_restartAfk(NgBattleDataManager.battlePageContainer)
    elseif NgBattleDataManager.battleType == CONST.SCENE_TYPE.SINGLE_BOSS or
           NgBattleDataManager.battleType == CONST.SCENE_TYPE.SINGLE_BOSS_SIM then
        local PageJumpMange = require("PageJumpMange")
        PageJumpMange.JumpPageById(52)
     elseif NgBattleDataManager.battleType == CONST.SCENE_TYPE.SEASON_TOWER then
        local PageJumpMange = require("PageJumpMange")
        PageJumpMange.JumpPageById(53)
     elseif NgBattleDataManager.battleType == CONST.SCENE_TYPE.LIMIT_TOWER then
        local TabName = {[2] = {"Fire","Water","Wood","Light_and_Dark"},
                         [3] = {"Shield","Sword","Heal","Magic"}  
        }
        local limitType = NgBattleDataManager.limitType
        local tabIndex, subIndex

        if limitType < 10 then
            tabIndex = 2
            subIndex = limitType
            PageJumpMange._JumpCfg[55]._ThirdFunc = "onType2"
        else
            tabIndex = 3
            subIndex = limitType - 10
            PageJumpMange._JumpCfg[55]._ThirdFunc = "onType3"
        end

        local subPage = TabName[tabIndex][subIndex]
        require("TowerLimit.TowerLimitPage"):setEntrySubPage(subPage)
        PageJumpMange.JumpPageById(55)
     elseif NgBattleDataManager.battleType == CONST.SCENE_TYPE.FEAR_TOWER then
        PageJumpMange.JumpPageById(56)
     elseif NgBattleDataManager.battleType == CONST.SCENE_TYPE.PUZZLE then
        
        PageJumpMange.JumpPageById(54)
    end
    PageManager.popPage(thisPageName)
end

function NgBattlePausePage:onRestart(container)
    NgBattleDataManager_setBattleIsPause(false)
    if NgBattleDataManager.battleType == CONST.SCENE_TYPE.TEST_BATTLE then
        require("SpineTouchEdit")
        PageManager.pushPage("SpineTouchEdit")
    else
        require("Battle.NgBattlePage")
        NgBattlePageInfo_onRestartBoss(container)
    end
    PageManager.popPage(thisPageName)
end

function NgBattlePausePage:onContinue(container)
    local sceneHelper = require("Battle.NgFightSceneHelper")
    NgBattleDataManager_setBattleIsPause(false)
    sceneHelper:setSceneSpeed(NgBattleDataManager.battleSpeed)
    PageManager.popPage(thisPageName)
end

function NgBattlePausePage:onTestLog()
    PageManager.pushPage("BattleLogPage")
end

function NgBattlePausePage:onTestDps()
    PageManager.pushPage("BattleLogDpsPage")
end

local CommonPage = require("CommonPage")
local PausePage = CommonPage.newSub(NgBattlePausePage, thisPageName, option)

return PausePage