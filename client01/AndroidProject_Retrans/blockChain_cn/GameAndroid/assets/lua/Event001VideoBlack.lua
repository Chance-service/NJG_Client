local thisPageName = "Event001VideoBlack"

local opcodes = {
    
}

local option = {
    ccbiFile = "AlbumStoryDisplayPage_Flip.ccbi",
    handlerMap = {
    },
}
local Event001BlackBase = { }
local libPlatformListener1 = { }
isACT191Played = false

function libPlatformListener1:onPlayMovieEnd(listener)
    if not listener or isACT191Played then return end
    isACT191Played = true
    GamePrecedure:getInstance():closeMovie(thisPageName)
    local mainContainer = tolua.cast(MainFrame:getInstance(), "CCBContainer")
    local backNode = mainContainer:getCCNodeFromCCB("mNodeMid")
    backNode:setVisible(true)
    PageManager.pushPage("Event001Page")
    PageManager.popPage(thisPageName)
end

function Event001BlackBase:onEnter(container)
    if CC_TARGET_PLATFORM_LUA == common.platform.CC_PLATFORM_WIN32 then
        PageManager.pushPage("Event001Page")
        PageManager.popPage(thisPageName)
        return
    end
    SoundManager:getInstance():stopMusic()
    NodeHelper:setStringForLabel(container, { mTxt = "" })
    PageManager.pushPage("TransScenePopUp")
    local EventDataMgr = require("Event001DataMgr")
    local video = EventDataMgr[EventDataMgr.nowActivityId].FETTER_MOVEMENT_CFG[99999901].spine
    if video ~= "" then
        LibPlatformScriptListener:new(libPlatformListener1)
        GamePrecedure:getInstance():playMovie(thisPageName, video, 0, 0)
        local mainContainer = tolua.cast(MainFrame:getInstance(), "CCBContainer")
        local backNode = mainContainer:getCCNodeFromCCB("mNodeMid")
        backNode:setVisible(false)
    else
        PageManager.pushPage("Event001Page")
        PageManager.popPage(thisPageName)
    end
    if EventDataMgr[EventDataMgr.nowActivityId].isCommonUI then
        SoundManager:getInstance():playMusic(EventDataMgr[EventDataMgr.nowActivityId].FETTER_MOVEMENT_CFG[99999901].spine .. ".mp3")
    end
end
function Event001BlackBase:setSpine(container)
    
end

local CommonPage = require("CommonPage")
local Event001Black = CommonPage.newSub(Event001BlackBase, thisPageName, option)

return Event001Black
