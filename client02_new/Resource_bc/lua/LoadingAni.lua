
local thisPageName = "LoadingAniPage"

local option = {
    ccbiFile = "LoadingAni.ccbi",
    handlerMap = {
    },
    opcode = opcodes
}

local LoadingAniPopUp = { }

function LoadingAniPopUp:onEnter(container)
   container:runAnimation("Default Timeline")
end

local CommonPage = require("CommonPage")
local LoadingAniPopUp = CommonPage.newSub(LoadingAniPopUp, thisPageName, option)

return LoadingAniPopUp
