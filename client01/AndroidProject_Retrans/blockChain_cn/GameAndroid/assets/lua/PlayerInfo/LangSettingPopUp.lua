---
local LangSettingPopUp = { }

local thisPageName = "LangSettingPopUp"
local option = {
    ccbiFile = "LangSetUpPopUp.ccbi",
    handlerMap = {
        onClose = "onClose" ,
        onSaveSettings = "onSaveSettings",
    },
    opcodes = {
    },
}
for i = kLanguageEnglish, kLanguageTurkish do
    option.handlerMap["onSelect" .. i] = "onSelect"
end
local tempSelectId = kLanguageChinese
----
function LangSettingPopUp:onEnter(container)
    tempSelectId =  CCUserDefault:sharedUserDefault():getIntegerForKey("LanguageType")
	self:refreshPage(container)
end
function LangSettingPopUp:onSelect(container, eventName)
    local id = string.sub(eventName, 9, -1)
    tempSelectId = tonumber(id)
	self:refreshPage(container)
end

function LangSettingPopUp:onSaveSettings(container)
    CCUserDefault:sharedUserDefault():setIntegerForKey("LanguageType", tempSelectId)
    MessageBoxPage:Msg_Box(common:getLanguageString("@LangChangeTip"))
	self:onClose(container)
end

function LangSettingPopUp:refreshPage(container)
    local visible = { }
    for i = kLanguageEnglish, kLanguageTurkish do
        visible["mLangOn" .. i] = (i == tempSelectId)
	end
    NodeHelper:setNodesVisible(container, visible)
end

function LangSettingPopUp:onClose(container)
    PageManager.popPage(thisPageName)
end

local CommonPage = require("CommonPage")
LangSettingPopUp = CommonPage.newSub(LangSettingPopUp, thisPageName, option)

return LangSettingPopUp