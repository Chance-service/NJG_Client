
----------------------------------------------------------------------------------
local NodeHelper = require("NodeHelper")
local thisPageName = 'FriendSearchPopPage'
local FriendSearchBase = { }
local FriendManager = require("FriendManager")
local FriendSearchResult = require("FriendSearchResult")
local isOpenKeyBoard = true
-- 搜索id最大值，与后端一致
local FriendSearchIdMax = 100000000

FriendSearchPageCallback = nil
local onMaxLimit = 20 -- 名字搜索显示的文字上限
local inputType = 0  -- 0 id 搜索  name 名字搜索
local mClickIdSearch = true
local mClickNameSearch = false

local option = {
    ccbiFile = "FriendSearchPopUp.ccbi",
    handlerMap =
    {
        onClose = 'onClose',
        onSearch = 'onSearch',
        onInPutBtn = 'onInPutBtn',
        luaInputboxEnter = 'onInputboxEnter',
        luaonCloseKeyboard = "luaonCloseKeyboard",
        onChoiceIDBtn = "onChoiceIDBtn",
        onChoiceNameBtn = "onChoiceNameBtn"
    },
    opcodes =
    {
        FRIEND_FIND_S = HP_pb.FRIEND_FIND_S,
    }
}

local idInput = ''

function FriendSearchBase:onLoad(container)
    container:loadCcbiFile(option.ccbiFile)
end

function FriendSearchBase:onEnter(container)
    self:registerPacket(container)
    container:registerLibOS()
    mClickIdSearch = true
    local mInputTotal = container:getVarNode("mInputTotal");
    if mInputTotal then
        -- mInputTotal:setPositionY(mInputTotal:getPositionY() + 30)
    end
    NodeHelper:setNodesVisible(container, { mFriendSearch = true, mIdChoice02 = mClickIdSearch })
    self:refreshPage(container)
    if BlackBoard:getInstance().PLATFORM_TYPE_FOR_LUA == 2 or Golb_Platform_Info.is_win32_platform then
        FriendSearchBase.editBox = NodeHelper:addEditBox(CCSize(470, 40), container:getVarNode("mDecisionTex"), function(eventType)
            if eventType == "began" then
                FriendSearchBase.editBox:setText(idInput)
                -- NodeHelper:cursorNode(container,"mDecisionTex",true)
                -- triggered when an edit box gains focus after keyboard is shown
            elseif eventType == "ended" then
                FriendSearchBase.onEditBoxReturn(container, FriendSearchBase.editBox, FriendSearchBase.editBox:getText())
                NodeHelper:setNodesVisible(container, { mDecisionTexHint = false })
                -- NodeHelper:cursorNode(container,"mDecisionTex",false)
                -- triggered when an edit box loses focus after keyboard is hidden.
            elseif eventType == "changed" then
                FriendSearchBase.onEditBoxReturn(container, FriendSearchBase.editBox, FriendSearchBase.editBox:getText(), true)
                -- NodeHelper:cursorNode(container,"mDecisionTex",true)
                -- triggered when the edit box text was changed.
            elseif eventType == "return" then
                FriendSearchBase.onEditBoxReturn(container, FriendSearchBase.editBox, FriendSearchBase.editBox:getText())
                -- triggered when the return button was pressed or the outside area of keyboard was touched.
            end
        end , ccp(-235, 0), common:getLanguageString('@FriendInputHintTex'))
        container:getVarNode("mDecisionTex"):setVisible(false)
        container:getVarNode("mDecisionTexHint"):setVisible(false)
        -- container:getVarNode("mDecisionTex"):setPosition(ccp(0, -340))
        -- container:getVarNode("mDecisionTex"):setAnchorPoint(ccp(0.5, 0.5))
        NodeHelper:setStringForTTFLabel(container, { mDecisionTex = "" })

        local color = StringConverter:parseColor3B("135 54 38")
        FriendSearchBase.editBox:setFontColor(color)
        FriendSearchBase.editBox:setText("")
        -- FriendSearchBase.editBox:setVisible(false)
        FriendSearchBase.editBox:setMaxLength(onMaxLimit)
        -- FriendSearchBase.editBox:setInputMode(2)

        NodeHelper:setMenuItemEnabled(container, "mInputBtn", false)
        -- NodeHelper:setNodesVisible(container, {mDecisionTexHint = false})
    end
    idInput = ""
end

function FriendSearchBase:onExit(container)
    idInput = ''
    container:removeLibOS()
end

function FriendSearchBase:refreshPage(container)
    local lb2Str = {
        mTitle = common:getLanguageString('@FriendSearch'),
        mDes = common:getLanguageString('@FriendSearchExplain'),
        mDecisionTexHint = common:getLanguageString("@FriendInputHintTex")
    }
    NodeHelper:setStringForLabel(container, lb2Str)

    local visibleMap = {
        mLastBtnNode = true,
        mSearch = true,
        mChangeNameNode = false
    }
    NodeHelper:setNodesVisible(container, visibleMap)
    -- NodeHelper:setStringForTTFLabel(container, { mFriendID = common:getLanguageString('@FriendInputSearchContent')})
end

function FriendSearchBase:onClose(container)
    PageManager.popPage(thisPageName)
end

function FriendSearchBase:onSearch(container)
    if mClickIdSearch then

        if idInput == "" then
            MessageBoxPage:Msg_Box("@FriendInputNoneTxt")
            return
        end

        local id = tonumber(idInput)

        if not id then
            CCLuaLog("FriendSearchBase----onSearch-----id-" .. id)
            MessageBoxPage:Msg_Box("@FriendInputNoneTxt")
            return
        end
        if FriendManager.getFriendInfoById(id).playerId then
            MessageBoxPage:Msg_Box("@AlreadyBeFriendTxt")
            return
        end
        FriendManager.searchFriendById(id)
    else

        if idInput == "" then
            MessageBoxPage:Msg_Box("@searchFriendByNameInput")
            return
        end
        local name = idInput
        --    if not id then
        --        CCLuaLog("FriendSearchBase----onSearch-----id-"..id)
        --        MessageBoxPage:Msg_Box("@FriendInputNoneTxt")
        --        return
        --    end
        if FriendManager.getFriendInfoByName(name).playerId then
            MessageBoxPage:Msg_Box("@AlreadyBeFriendTxt")
            return
        end
        FriendManager.searchFriendByName(name)
    end

    -- PageManager.popPage(thisPageName)
end
function FriendSearchBase.onEditBoxReturn(container, editBox, content, isChange)
    if mClickIdSearch then
        if (not tonumber(content)) then
            -- NodeHelper:setNodesVisible(container, {mDecisionTexHint = true})
            CCLuaLog("FriendSearchBase--onEditBoxReturn---content-" .. content)
            MessageBoxPage:Msg_Box('@FriendInputNoneTxt')
            if idInput then
                -- libOS:getInstance():setEditBoxText(idInput);
                idInput = ""
                editBox:setText(idInput)
                NodeHelper:setStringForTTFLabel(container, { mDecisionTex = "" })
                -- NodeHelper:cursorNode(container,"mDecisionTex",true)
            end
            return
        end
        local inputNumber = math.floor(tonumber(content))

        -- 检查id合法性
        if common:trim(content) == '' then
            -- NodeHelper:setNodesVisible(container, {mDecisionTexHint = true})
            -- CCLuaLog("FriendSearchBase----common:trim(content)-----content-" .. content)
            MessageBoxPage:Msg_Box('@FriendInputNoneTxt')
            return
        elseif (not inputNumber) or(inputNumber >= FriendSearchIdMax) then
            MessageBoxPage:Msg_Box('@GuildInputSearchNumber')
            return
        end
        idInput = tostring(inputNumber)
        -- editBox:setText(idInput)
        NodeHelper:setStringForTTFLabel(container, { mDecisionTex = idInput })
        NodeHelper:setNodesVisible(container, { mDecisionTexHint = false })
    else
        local length = GameMaths:calculateStringCharacters(content)
        -- CCLuaLog("FriendSearchBase---------length-" .. length)
        if length > onMaxLimit then
            editBox:setText("")
            MessageBoxPage:Msg_Box("@GuildAnnouncementTooLong")
            -- CCLuaLog("FriendSearchBase---------length-" .. onMaxLimit)
            return
        elseif GameMaths:isStringHasUTF8mb4(content) then
            -- editBox:setText("")
            -- CCLuaLog("FriendSearchBase---------length-" .. NameHaveForbbidenChar)
            MessageBoxPage:Msg_Box("@NameHaveForbbidenChar")
            return
        end
        -- CCLuaLog("FriendSearchBase---------length-" .. content)
        idInput = content
        -- editBox:setText(content)
        NodeHelper:setStringForTTFLabel(container, { mDecisionTex = idInput })
        NodeHelper:setNodesVisible(container, { mDecisionTexHint = false })
    end
end
function FriendSearchBase:onInPutBtn(container)
    -- libOS:getInstance():showInputbox(false,idInput)
    libOS:getInstance():showInputbox(false, "")
    -- 2 数字键盘
    NodeHelper:setNodesVisible(container, { mDecisionTexHint = false })
    NodeHelper:cursorNode(container, "mDecisionTex", true)
end
function FriendSearchBase:luaonCloseKeyboard(container)
    CCLuaLog(" ChangeNamePageBase:luaonCloseKeyboard")
    NodeHelper:cursorNode(container, "mDecisionTex", false)
    isOpenKeyBoard = true
end
function FriendSearchBase:onInputboxEnter(container)
    if mClickIdSearch then
        local content = container:getInputboxContent()
        if (not tonumber(content)) then
            idInput = content
            NodeHelper:setStringForTTFLabel(container, { mDecisionTex = idInput })
            NodeHelper:setNodesVisible(container, { mDecisionTexHint = false })
            NodeHelper:cursorNode(container, "mDecisionTex", true)
            isOpenKeyBoard = false
        --    NodeHelper:setNodesVisible(container, { mDecisionTexHint = true })
        --    CCLuaLog("FriendSearchBase----onInputboxEnter-----content-" .. content)
        --    MessageBoxPage:Msg_Box('@FriendInputNoneTxt')
        --    if idInput then
        --        -- libOS:getInstance():setEditBoxText(idInput);
        --        idInput = ""
        --        NodeHelper:setStringForTTFLabel(container, { mDecisionTex = "" })
        --        NodeHelper:cursorNode(container, "mDecisionTex", true)
        --    end
            return
        end
        local inputNumber = math.floor(tonumber(content))

        -- 检查id合法性
        if common:trim(content) == '' then
            NodeHelper:setNodesVisible(container, { mDecisionTexHint = true })
            CCLuaLog("FriendSearchBase----onInputboxEnter-----common:trim(content)-" .. content)
            MessageBoxPage:Msg_Box('@FriendInputNoneTxt')
            return
        elseif (not inputNumber) or(inputNumber >= FriendSearchIdMax) then
            libOS:getInstance():setEditBoxText(idInput);
            MessageBoxPage:Msg_Box('@GuildInputSearchNumber')
            return
        end
        idInput = tostring(inputNumber)
        NodeHelper:setStringForTTFLabel(container, { mDecisionTex = idInput })
        NodeHelper:setNodesVisible(container, { mDecisionTexHint = false })
        NodeHelper:cursorNode(container, "mDecisionTex", true)
        isOpenKeyBoard = false
    else
        local content = container:getInputboxContent()
        --        if not isOpenKeyBoard then
        --            NodeHelper:setNodesVisible(container, { mDecisionTexHint = true })
        --            CCLuaLog("FriendSearchBase----onInputboxEnter-----content-" .. content)
        --            MessageBoxPage:Msg_Box('@@searchFriendByNameHint')
        --            if idInput then
        --                -- libOS:getInstance():setEditBoxText(idInput);
        --                idInput = ""
        --                NodeHelper:setStringForTTFLabel(container, { mDecisionTex = "" })
        --                NodeHelper:cursorNode(container, "mDecisionTex", true)
        --            end
        --            return
        --        end
        local length = GameMaths:calculateStringCharacters(content)
        -- 检查id合法性
        if length >= onMaxLimit then
            libOS:getInstance():setEditBoxText("");
            MessageBoxPage:Msg_Box('@GuildAnnouncementTooLong')
            return
        end
        idInput = content
        NodeHelper:setStringForTTFLabel(container, { mDecisionTex = idInput })
        NodeHelper:setNodesVisible(container, { mDecisionTexHint = false })
        NodeHelper:cursorNode(container, "mDecisionTex", true)
        isOpenKeyBoard = false

    end
end

function FriendSearchBase:onReceivePacket(container)
    local opcode = container:getRecPacketOpcode()
    local msgBuff = container:getRecPacketBuffer()

    if opcode == HP_pb.FRIEND_FIND_S then
        local msg = Friend_pb.FriendItem()
        msg:ParseFromString(msgBuff)
        FriendSearchResultBase_onSearchResult(msg)

        self:onClose(container)
    end
end
function FriendSearchBase:onChoiceIDBtn(container)
    mClickIdSearch = true
    mClickNameSearch = false
    idInput = ""
    if BlackBoard:getInstance().PLATFORM_TYPE_FOR_LUA == 2 or Golb_Platform_Info.is_win32_platform then
        FriendSearchBase.editBox:setText(idInput)
        FriendSearchBase.editBox:setPlaceHolder(common:getLanguageString('@FriendInputHintTex'))
    else

        NodeHelper:setStringForTTFLabel(container, { mDecisionTex = idInput, mDecisionTexHint = common:getLanguageString('@FriendInputHintTex') })
        NodeHelper:setNodesVisible(container, { mDecisionTexHint = true })
    end


    NodeHelper:setNodesVisible(container, { mIdChoice02 = mClickIdSearch })
    NodeHelper:setNodesVisible(container, { mNameChoice02 = mClickNameSearch })
end

function FriendSearchBase:onChoiceNameBtn(container)
    mClickNameSearch = true
    mClickIdSearch = false
    idInput = ""

    if BlackBoard:getInstance().PLATFORM_TYPE_FOR_LUA == 2 or Golb_Platform_Info.is_win32_platform then
        FriendSearchBase.editBox:setText(idInput)
        FriendSearchBase.editBox:setPlaceHolder(common:getLanguageString('@searchFriendByNameHint'))
    else

        NodeHelper:setStringForTTFLabel(container, { mDecisionTex = idInput, mDecisionTexHint = common:getLanguageString('@searchFriendByNameHint') })
        NodeHelper:setNodesVisible(container, { mDecisionTexHint = true })
    end

    NodeHelper:setNodesVisible(container, { mIdChoice02 = mClickIdSearch })
    NodeHelper:setNodesVisible(container, { mNameChoice02 = mClickNameSearch })
end
function FriendSearchBase:registerPacket(container)
    for key, opcode in pairs(option.opcodes) do
        if string.sub(key, -1) == "S" then
            container:registerPacket(opcode)
        end
    end
end

function FriendSearchBase:removePacket(container)
    for key, opcode in pairs(option.opcodes) do
        if string.sub(key, -1) == "S" then
            container:removePacket(opcode)
        end
    end
end


local CommonPage = require('CommonPage')
local FriendSearchPopPage = CommonPage.newSub(FriendSearchBase, thisPageName, option)
