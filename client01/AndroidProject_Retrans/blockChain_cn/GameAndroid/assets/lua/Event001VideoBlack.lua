local thisPageName = "Event001VideoBlack"

local opcodes = {
    
    }

local option = {
    ccbiFile = "AlbumStoryDisplayPage_Flip.ccbi",
    handlerMap = {
    },
}
local Event001BlackBase = {}
local libPlatformListener1 = { }

function libPlatformListener1:onPlayMovieEnd(listener)
    if not listener then return end
    GameUtil:setPlayMovieVisible(true)
    GamePrecedure:getInstance():closeMovie()
    local mainContainer = tolua.cast(MainFrame:getInstance(), "CCBContainer")
    local backNode = mainContainer:getCCNodeFromCCB("mNodeMid")
    backNode:setVisible(true)
    PageManager.pushPage("Event001Page")
    PageManager.popPage(thisPageName)
    --libPlatformListener = { }
end



function Event001BlackBase:onEnter(container)
     SoundManager:getInstance():stopMusic()
     NodeHelper:setStringForLabel(container,{mTxt = ""})
     PageManager.pushPage("TransScenePopUp")
     local video = ConfigManager.getEvent001ActionCfg()[99999901].spine
     LibPlatformScriptListener:new(libPlatformListener1)
     GamePrecedure:getInstance():playMovie(video, 0, 0)
     GameUtil:setPlayMovieVisible(false)
     local mainContainer = tolua.cast(MainFrame:getInstance(), "CCBContainer")
     local backNode = mainContainer:getCCNodeFromCCB("mNodeMid")
     backNode:setVisible(false)
end
function Event001BlackBase:setSpine(container)
    
end

local CommonPage = require("CommonPage")
local Event001Black = CommonPage.newSub(Event001BlackBase, thisPageName, option)

return Event001Black
