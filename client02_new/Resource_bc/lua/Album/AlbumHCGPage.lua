--[[聖女Spine入口]]

local HP_pb = require("HP_pb")
require("SecretMessage.SecretMessageManager")
local thisPageName = "Album.AlbumHCGPage"
local AlbumStoryDisplayPage=require('AlbumStoryDisplayPage')
----------------------------------------------------------
-- CONST
local FILTER_WIDTH = 500
local FILTER_OPEN_HEIGHT = 142
local FILTER_CLOSE_HEIGHT = 74
local filterOpenSize = CCSize(FILTER_WIDTH, FILTER_OPEN_HEIGHT)
local filterCloseSize = CCSize(FILTER_WIDTH, FILTER_CLOSE_HEIGHT)
local ALBUM_ITEM_SIZE = CCSize(214, 302)
----------------------------------------------------------
local opcodes = {
    SECRET_MESSAGE_ACTION_S = HP_pb.SECRET_MESSAGE_ACTION_S
}

local option = {
    ccbiFile = "Album.ccbi",
    handlerMap =
    {
        onReturn = "onReturn",
        onFilter = "onFilter",
    },
    opcode = opcodes
}
for i = 0, 5 do
    option.handlerMap["onElement" .. i] = "onElement"
end
for i = 0, 4 do
    option.handlerMap["onClass" .. i] = "onClass"
end
----------------------------------------------------------
local AlbumMainPage = { }
local AlbumItems = { }
local AlbumSideStory = {}
local StoryCfg=ConfigManager.getStoryData()

local heroCfg = ConfigManager.getNewHeroCfg()
local element = 0
local class = 0

local nowType = 1
local nowId = 0
local BuildTable = {}

local mainContainer = nil

local HeroData=nil
----------------------------------------------------------
-- MAIN PAGE ITEM
local AlbumItem = {
    ccbiFile = "AlbumContent.ccbi",
}
function AlbumItem:new(o)
    o = o or { }
    setmetatable(o, self)
    self.__index = self
    return o
end


function AlbumItem:onRefreshContent(ccbRoot)
    self.container = ccbRoot:getCCBFileNode()
    self:refresh()
end

function AlbumItem:getCCBFileNode()
    return self.ccbiFile:getCCBFileNode()
end

function AlbumItem:refresh()
    if self.container == nil then
        return
    end
    if self.itemId~=990 then
        NodeHelper:setSpriteImage(self.container, { mImg = "UI/RoleShowCards/Hero_" .. string.format("%02d", self.itemId) .. "000.png" })
        NodeHelper:setStringForLabel(self.container, { mName = common:getLanguageString("@HeroName_" .. self.itemId)})
    else
        NodeHelper:setSpriteImage(self.container, { mImg = "UI/RoleShowCards/Hero_" ..  self.itemId .. "000.png" })
        NodeHelper:setStringForLabel(self.container, { mName = common:getLanguageString("@HeroName_" .. self.itemId)})
    end
end

----------------------------------------------------------
function AlbumMainPage:new(o)
    o = o or { }
    setmetatable(o, self)
    self.__index = self
    return o
end

function AlbumMainPage:createPage(_parentPage)
    
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

function AlbumMainPage:onEnter(container)
    mainContainer = container
    self:registerPacket(container)
    NodeHelper:setNodesVisible(mainContainer,{mElementNode=false})
    container.mScrollView = container:getVarScrollView("mContent")
   self:initScrollView(container)
end
function AlbumMainPage:setType(_type,id)
    nowType = _type
    nowId = id
end
-- ScrollView初始化
function AlbumMainPage:initScrollView(container)
    if nowType == 1 then
        local BuildTable=AlbumSideStory:StoryState(container)
        for key,value in pairs (BuildTable) do
            local mID=  string.sub(value[1].id, 5, 6)
            cell = CCBFileCell:create()
            cell:setCCBFile("AlbumSideStoryContent.ccbi")
            local panel = common:new({id = key,itemId=mID}, AlbumSideStory)
            cell:registerFunctionHandler(panel)
            container.mScrollView:addCell(cell)
        end
    elseif nowType == 2 then
        local cfg = ConfigManager.getRoleGrowthUnlock()
        BuildTable = {}
        for _,value in pairs (cfg) do
            if value.itemId == nowId then
                table.insert(BuildTable,value)
            end
        end
        table.sort(BuildTable,function(a,b) return a.id < b.id end)
        NodeHelper:buildCellScrollView(container.mScrollView, #BuildTable, "AlbumSideStoryContent.ccbi" , AlbumSideStory)
    end
    container.mScrollView:setTouchEnabled(true)
    container.mScrollView:orderCCBFileCells()

end
-- 顯示刷新
function AlbumMainPage:onRefreshPage(container)
end
-- 建議在模組最上方就 require 好，避免每次刷新都重複載入
local SecretMessageManager = require("SecretMessage.SecretMessageManager")

function AlbumSideStory:onRefreshContent(content)
    local container = content:getCCBFileNode()

    -- type1: 顯示回憶錄封面
    if nowType == 1 then
        local bgPath = ("UI/HeroMemories/PhotounCH%03d.png"):format(self.itemId)
        local titleKey = ("@memoriestitle990%03d"):format(self.itemId)
        NodeHelper:setSpriteImage(container, { mBg = bgPath })
        NodeHelper:setStringForLabel(container, { mTxt = common:getLanguageString(titleKey) })
        NodeHelper:setNodesVisible(container,{ mStarNode  = false, mLevelNode = false})
        self:StoryState(container, self.id)
        return
    end

    -- type2
    local data = BuildTable[self.id]
    -- 背景和標題
    NodeHelper:setSpriteImage(container, {
        mBg = ("UI/Common/Album/Memories/%s.jpg"):format(data.Img)
    })
    NodeHelper:setStringForLabel(container, {
        mTxt = common:getLanguageString(data.Title)
    })

    -- 判斷鎖定狀態
    local achieved = SecretMessageManager_LimitAchiveCount(data.itemId)
    local isLocked = self.id > achieved
    self.isLock = isLocked
    -- 解析 lockType / lockValue
    local types = common:split(data.lockType, ",")
    local vals  = common:split(data.lockValue, ",")
    local lockStar, lockLevel
    for i, t in ipairs(types) do
        if t == "0" then
            lockStar  = tonumber(vals[i])
        elseif t == "1" then
            lockLevel = tonumber(vals[i])
        end
    end

    local starNode  = container:getVarNode("mStarNode")
    local levelNode = container:getVarNode("mLevelNode")
    local yOffset   = (#types == 2) and 20 or 0
    starNode:setPositionY( yOffset )
    levelNode:setPositionY( -yOffset )

    -- 一次性設定所有節點可見性
    local vis = {
        mMask      = isLocked,
        mLock      = false,
        mStarNode  = isLocked and lockStar  ~= nil,
        mLevelNode = isLocked and lockLevel ~= nil,
    }
    -- 星級圖示
    for i = 1, 13 do
        vis["mStar"..i] = (i == lockStar)
    end
    -- 稀有度圖示
    vis.mSr  = lockStar and lockStar  <=  5 or false
    vis.mSsr = lockStar and lockStar  >   5 and lockStar <= 10 or false
    vis.mUr  = lockStar and lockStar  >  10 or false

    NodeHelper:setNodesVisible(container, vis)
    -- 顯示等級文字
    NodeHelper:setStringForLabel(container, {  mLv = lockLevel or "" })
end

function AlbumSideStory:StoryState(container,mID)
    local mapCfg = ConfigManager.getNewMapCfg()
    mapId = mapCfg[UserInfo.stateInfo.curBattleMap] and UserInfo.stateInfo.curBattleMap or 
                  (mapCfg[UserInfo.stateInfo.passMapId] and UserInfo.stateInfo.passMapId or UserInfo.stateInfo.curBattleMap - 1)
    --取story的key
    groupedTables = {}
    local keys = {}
    for k, _ in pairs(StoryCfg) do
        table.insert(keys, k)
    end
    --key排序
    table.sort(keys)
    --用key賦值
    local sortedStoryCfg = {}
    for k, v in ipairs(keys) do
        table.insert(sortedStoryCfg,StoryCfg[v])
    end
    --用關卡分類
    local tmpTable={}
    for _, v in pairs(sortedStoryCfg) do
        local stagetype = tonumber(string.sub(v.id, 5, 6))
        if v.isHide == 0 then
            tmpTable[stagetype] = tmpTable[stagetype] or {}
            table.insert(tmpTable[stagetype], v)
        end
    end
    
    for _, tbl in pairs(tmpTable) do
        table.insert(groupedTables, tbl)
    end
     
    table.sort(groupedTables,function(a,b) return a[1].sort<b[1].sort end)
    if mID==nil then return groupedTables end
    local stage=groupedTables[mID][1].stage
    require("FlagData")
    local data=FlagDataBase_GetData()
    local  SpineId = groupedTables[mID][1].id
    local FlagId = tonumber (string.sub(SpineId, 5, 6))
    if stage>mapId or data[FlagId]==nil then
        NodeHelper:setNodesVisible(container,{mMask=true,mLock=true})
    else
         NodeHelper:setNodesVisible(container,{mMask=false,mLock=false})
    end
    return groupedTables[mID]
end
function AlbumSideStory_GuideStoryState(container)
    --取story的key
    groupedTables = {}
    local keys = {}
    for k, _ in pairs(StoryCfg) do
        table.insert(keys, k)
    end
    --key排序
    table.sort(keys)
    --用key賦值
    local sortedStoryCfg = {}
    for k, v in ipairs(keys) do
        table.insert(sortedStoryCfg,StoryCfg[v])
    end
    --用關卡分類
    local tmpTable={}
    for _, v in pairs(sortedStoryCfg) do
        local stagetype = tonumber(string.sub(v.id, 5, 6))
        if v.isHide == 1 then
            tmpTable[stagetype] = tmpTable[stagetype] or {}
            table.insert(tmpTable[stagetype], v)
        end
    end
    
    for _, tbl in pairs(tmpTable) do
        table.insert(groupedTables, tbl)
    end
     
    table.sort(groupedTables,function(a,b) return a[1].sort<b[1].sort end)
    if groupedTables[1] == nil then return groupedTables end

    return groupedTables[1]
end
function AlbumSideStory:onBtn(id,isAlbum)
    if nowType == 1 then
        local _id=id
        local _isAlbum=true
        if isAlbum~=nil then _isAlbum=isAlbum end
        if isAlbum==nil then _id=self.id end
        local stage=groupedTables[_id][1].stage
        if stage>mapId then 
            local txt="@memoriestitle9900"..self.itemId.."_error"
            MessageBoxPage:Msg_Box(common:getLanguageString(txt))
            return
        end
        
        AlbumStoryDisplayPage:setData(groupedTables[_id],_isAlbum)
        PageManager.popPage(thisPageName)
        PageManager.pushPage("AlbumStoryDisplayPage_Flip")
    elseif nowType == 2 then
        if self.isLock then
            --MessageBoxPage:Msg_Box(common:getLanguageString(txt))
            return
        end
         local data = BuildTable[self.id]
         NgBattleResultManager.showAlbum = true
         local AlbumStoryDisplayPage_Vertical=require('AlbumStoryDisplayPage_Vertical')
         if AlbumStoryDisplayPage_Vertical:setData(data.avgId) then
             PageManager.pushPage("AlbumStoryDisplayPage_Vertical")
         end
    end
end

function AlbumMainPage:onBtn(id)
    AlbumSideStory:onBtn(id,false)
end
function AlbumMainPage:onFilter(container)
    local isShowClass = container:getVarNode("mClassNode"):isVisible()
    local filterBg = container:getVarScale9Sprite("mFilterBg")
    if isShowClass then
        filterBg:setContentSize(filterCloseSize)
        NodeHelper:setNodesVisible(container, { mClassNode = false })
    else
        filterBg:setContentSize(filterOpenSize)
        NodeHelper:setNodesVisible(container, { mClassNode = true })
    end
end

function AlbumMainPage:onElement(container, eventName)
    element = tonumber(eventName:sub(-1))
    self:setFilterVisible(container)
    for i = 0, 5 do
        container:getVarSprite("mElement" .. i):setVisible(element == i)
    end
    container.mScrollView:orderCCBFileCells()
end

function AlbumMainPage:onClass(container, eventName)
    class = tonumber(eventName:sub(-1))
    self:setFilterVisible(container)
    for i = 0, 4 do
        container:getVarSprite("mClass" .. i):setVisible(class == i)
    end
    container.mScrollView:orderCCBFileCells()
end

function AlbumMainPage:setFilterVisible(container)
    for i = 1, #AlbumItems do
        local isVisible = (element == AlbumItems[i].cls.element or element == 0) and
                          (class == AlbumItems[i].cls.class or class == 0)
        AlbumItems[i].node:setVisible(isVisible)
        AlbumItems[i].node:setContentSize(isVisible and ALBUM_ITEM_SIZE or CCSize(0, 0))
    end
end

function AlbumMainPage:onReturn(container)
    PageManager.popPage(thisPageName)
end

function AlbumMainPage:onExit(container)
    AlbumItems = { }
    element = 0
    class = 0
    container.mScrollView:removeAllCell()
    HeroData=nil
    nowType = 1
    nowId = 0
end

-- Server回傳
function AlbumMainPage:onReceivePacket(packet)
    local opcode = packet.opcode
    local msgBuff = packet.msgBuff
    if opcode == HP_pb.SECRET_MESSAGE_ACTION_S then
        local msg = SecretMsg_pb.secretMsgResponse()
        msg:ParseFromString(msgBuff)
        HeroData= msg.syncMsg.heroInfo
    end
end

function AlbumMainPage:registerPacket(container)
    parentPage:registerPacket(opcodes)
end

function AlbumMainPage:removePacket(container)
     parentPage:removePacket(opcodes)
end

local CommonPage = require("CommonPage")
local AlbumMainPage = CommonPage.newSub(AlbumMainPage, thisPageName, option)

return AlbumMainPage 
