local HP_pb = require("HP_pb")
local Activity6_pb = require("Activity6_pb")
local thisPageName = "Album.AlbumPuzzlePage"

----------------------------------------------------------
local opcodes = {
    ACTIVITY195_PUZZLE_BATTLE_S = HP_pb.ACTIVITY195_PUZZLE_BATTLE_S
}

local option = {
    ccbiFile = "Album.ccbi",
    handlerMap =
    {
        onReturn = "onReturn",
        onFilter = "onFilter",
        onExitImg = "onExitImg",
        onPlus = "onPlus",
        onMinus = "onMinus"
    },
    opcode = opcodes
}
----------------------------------------------------------
local AlbumPuzzlePage = { }
local AlbumPuzzleContent = {ccbiFile = "AlbumPuzzleContent.ccbi"}
local mainContainer = nil
local Passedlevel = {}
local mainPuzzleConfig    = ConfigManager.getMainPuzzleCfg()
local CardPress = false
local spriteTable = {}
local spriteIdx = 1
----------------------------------------------------------
local function removeDuplicates(t)
    local seen = {}
    local result = {}
    for _, value in ipairs(t) do
        if not seen[value] then
            seen[value] = true
            table.insert(result, value)
        end
    end
    return result
end

local function mergeTables(target, source)
    for _, v in ipairs(source) do
        table.insert(target, tonumber(v))
    end
    table.sort(target) 
    return removeDuplicates(target)
end

----------------------------------------------------------
function AlbumPuzzlePage:new(o)
    o = o or { }
    setmetatable(o, self)
    self.__index = self
    return o
end

function AlbumPuzzlePage:createPage(_parentPage)
    
    local slf = self
    
    parentPage = _parentPage
    
    local container = ScriptContentBase:create(option.ccbiFile)
    
    -- 註冊 呼叫行為
    container:registerFunctionHandler(function(eventName, container)
        local funcName = option.handlerMap[eventName]
        local func = slf[funcName]
        if func then
            func(slf, container,eventName)
        end
    end)
    
    return container
end

function AlbumPuzzlePage:onExecute(container)
end

function AlbumPuzzlePage:onEnter(container)
    mainContainer = container
    self:registerPacket(container)
    NodeHelper:setNodesVisible(mainContainer,{mElementNode=false})
    --container.mScrollView = container:getVarScrollView("mContent")
    --NodeHelper:autoAdjustResizeScrollview(container.mScrollView)
    self:sendInfoRequest()
    
end
function AlbumPuzzlePage:sendInfoRequest()
    local msg = Activity6_pb.PuzzleBattleReq()
    msg.action = 0
    common:sendPacket(HP_pb.ACTIVITY195_PUZZLE_BATTLE_C, msg, false)
end

function AlbumPuzzlePage:onReturn(container)
    container.mScrollView:removeAllCell()
    PageManager.popPage(thisPageName)
end
function AlbumPuzzlePage:tableSort()
    local heroTable = {}
    for _,value in pairs (mainPuzzleConfig) do
        if not heroTable[value.groupId] then
            heroTable[value.groupId] = {}
        end
        table.insert(heroTable[value.groupId],value.id)
    end
    return heroTable
end
function AlbumPuzzlePage:buildScrollview(container)
   local ScrollView = container:getVarScrollView("mContent")
    local cfg =  AlbumPuzzlePage:tableSort()
    for StageId,value in pairs (cfg) do
        local cell = CCBFileCell:create()
        cell:setCCBFile(AlbumPuzzleContent.ccbiFile)
        local panel = common:new({ ids = value }, AlbumPuzzleContent)
        cell:registerFunctionHandler(panel)
        ScrollView:addCell(cell)
    end
    ScrollView:orderCCBFileCells()
    ScrollView:setTouchEnabled(#cfg > 3)
end
function AlbumPuzzleContent:onRefreshContent(content)
    local container = content:getCCBFileNode()
    local passCount = 0
    for i = 1,7 do
        if not self.ids[i] then return end
        if  Passedlevel[self.ids[i]] then
            NodeHelper:setSpriteImage(container,{["mSprite"..i] = mainPuzzleConfig[self.ids[i]].SmallImg})
            passCount = passCount + 1
        else
            NodeHelper:setSpriteImage(container,{["mSprite"..i] = "Puzzle_Card_Album.png"})
        end
    end

    local data = mainPuzzleConfig[self.ids[1]]
    local FinalTxt = string.format("%s  %d / %d", common:getLanguageString("@HeroName_" .. string.sub(data.groupId, 1, 2)), passCount, 7)
    NodeHelper:setStringForLabel(container, { mAlbumName = FinalTxt })
end

local function onCard(container, idTable, idx)
    if CardPress then return end

    CardPress = true
    container:runAction(CCSequence:createWithTwoActions(
        CCDelayTime:create(0.5),
        CCCallFunc:create(function() CardPress = false end)
    ))

    
    local selectedId = tonumber(idTable[idx])
    if not Passedlevel[selectedId] then
        MessageBoxPage:Msg_Box(common:getLanguageString("@PuzzleBattle_Locked"))
        return
    end

    -- 組出有效的圖片表
    local tempSpriteTable = {}
    for _, id in pairs(idTable) do
        id = tonumber(id)
        if Passedlevel[id] then
            tempSpriteTable[id] = mainPuzzleConfig[id].image
        end
    end

    if next(tempSpriteTable) == nil then
        return -- 沒有任何已解鎖的圖片，保險處理
    end

    -- 初始化圖片播放邏輯
    AlbumPuzzlePage:initSpriteTable(tempSpriteTable, selectedId)

    local realId = AlbumPuzzlePage.spriteIndexList[AlbumPuzzlePage.spriteCurrentIdx]
    NodeHelper:setSpriteImage(container, { mSprite = tempSpriteTable[realId] })
    NodeHelper:setNodesVisible(container, { mPop = true })
    container:runAnimation("PhotoPop")
end



function AlbumPuzzlePage:initSpriteTable(spriteTable, startId)
    self.spriteTable = spriteTable
    self.spriteIndexList = {}

    for k in pairs(spriteTable) do
        table.insert(self.spriteIndexList, k)
    end
    table.sort(self.spriteIndexList)

    -- 找到 startId 對應的位置
    self.spriteCurrentIdx = 1
    if startId then
        for i, id in ipairs(self.spriteIndexList) do
            if id == startId then
                self.spriteCurrentIdx = i
                break
            end
        end
    end
end


function AlbumPuzzlePage:onPlus(container)
    local indexList = self.spriteIndexList
    local spriteTable = self.spriteTable
    if not indexList or #indexList == 0 then return end

    self.spriteCurrentIdx = self.spriteCurrentIdx + 1
    if self.spriteCurrentIdx > #indexList then
        self.spriteCurrentIdx = 1
    end

    local realIndex = indexList[self.spriteCurrentIdx]
    NodeHelper:setSpriteImage(container, { mSprite = spriteTable[realIndex] })
    container:runAnimation("PhotoPop")
end

function AlbumPuzzlePage:onMinus(container)
    local indexList = self.spriteIndexList
    local spriteTable = self.spriteTable
    if not indexList or #indexList == 0 then return end

    self.spriteCurrentIdx = self.spriteCurrentIdx - 1
    if self.spriteCurrentIdx < 1 then
        self.spriteCurrentIdx = #indexList
    end

    local realIndex = indexList[self.spriteCurrentIdx]
    NodeHelper:setSpriteImage(container, { mSprite = spriteTable[realIndex] })
    container:runAnimation("PhotoPop")
end

function AlbumPuzzlePage:onExitImg(container)
    NodeHelper:setNodesVisible(container,{mPop = false})
end

function AlbumPuzzleContent:onCard1(container)
    onCard(mainContainer,self.ids,1)
end
function AlbumPuzzleContent:onCard2(container)
    onCard(mainContainer,self.ids,2)
end
function AlbumPuzzleContent:onCard3(container)
    onCard(mainContainer,self.ids,3)
end

function AlbumPuzzleContent:onCard4(container)
    onCard(mainContainer,self.ids,4)
end
function AlbumPuzzleContent:onCard5(container)
    onCard(mainContainer,self.ids,5)
end

function AlbumPuzzleContent:onCard6(container)
    onCard(mainContainer,self.ids,6)
end

function AlbumPuzzleContent:onCard7(container)
    onCard(mainContainer,self.ids,7)
end


-- Server回傳
function AlbumPuzzlePage:onReceivePacket(packet)
    local opcode = packet.opcode
    local msgBuff = packet.msgBuff
    if opcode == opcodes.ACTIVITY195_PUZZLE_BATTLE_S then
        local msg = Activity6_pb.PuzzleBattleResp()
        msg:ParseFromString(msgBuff)
        for k,v in pairs (msg.passId) do
           if type(v) == "number" then
               Passedlevel[v] = true
           end
        end
       AlbumPuzzlePage:buildScrollview(mainContainer)
    end
end

function AlbumPuzzlePage:registerPacket(container)
    parentPage:registerPacket(opcodes)
end

function AlbumPuzzlePage:removePacket(container)
     parentPage:removePacket(opcodes)
end

local CommonPage = require("CommonPage")
local AlbumPuzzlePage = CommonPage.newSub(AlbumPuzzlePage, thisPageName, option)

return AlbumPuzzlePage 
