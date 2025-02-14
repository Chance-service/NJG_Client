---- 符文合成選擇頁面
local FateDataManager = require("FateDataManager")
local runePage = require("RunePage")
local RuneBuildSelectPage = { }

local thisPageName = "RuneBuildSelectPage"
local option = {
    ccbiFile = "RuneBuildSelectPopUp.ccbi",
    handlerMap = {
        onClose = "onClose" ,
        onCancel = "onClose",
        onConfirm = "onConfirm",
    },
    opcodes = {
    },
}
local ROW_COUNT = 2
local LINE_COUNT = 5
local MAX_SELECT_NUM = 5
local IllItemContent = {
    ccbiFile = "EquipmentItem_RuneBuild.ccbi"
}
local pageContainer = nil
local nonWearRuneTable = { }    -- 未穿戴的符文
local nonWearRuneItems = { }    -- scrollview內的物件
local runeTouchLayer = { }      -- scrollview內的物件觸碰層
local selectRuneInfos = { }     -- 選擇中的符文資訊
local selectState = { }         -- 符文的選擇狀態&資訊
local nowSelectRank = 0         -- 選擇中的階級
local nowSelectNum = 0          -- 選擇中的數量
----
local TOUCH_DATA = {
    TOUCH_ID = 0,
    TOUCH_TIMECOUNT = 0,
    TOUCH_TIMEINTERVAL = 2,
    TOUCH_MAX_TIMEINTERVAL = 5,
    IS_TOUCHING = false,
    MOVE_X = 0,
    MOVE_Y = 0,
}

function RuneBuildSelectPage:onEnter(container)
    pageContainer = container
    self:initData(container)
    self:initUI(container)
    self:refreshPage(container)
end

function RuneBuildSelectPage:initData(container)
    nonWearRuneTable = FateDataManager:getNotWearFateList()
    nonWearRuneItems = { }
    runeTouchLayer = { }
    selectState = { }
    nowSelectRank = 0
    self:clearTouchData(container)
    self:DataSort()
end

function RuneBuildSelectPage:initUI(container)
    NodeHelper:initScrollView(container, "mContent", 30)
end

function RuneBuildSelectPage:onConfirm(container)
    selectRuneInfos = { }
    local index = 1
    for k, v in pairs(selectState) do
        if v.isSelect then
            selectRuneInfos[index] = v.info
            index = index + 1
        end
    end
    selectState = { }
    RunePageBase_setSelectInfo(selectRuneInfos)
    self:onClose(container)
end

function RuneBuildSelectPage:DataSort()
    table.sort(nonWearRuneTable, function(v1, v2)
        local cfg1 = ConfigManager.getFateDressCfg()[v1.itemId]
        local cfg2 = ConfigManager.getFateDressCfg()[v2.itemId]
        if v1.rare ~= v2.rare then
            return v1.rare < v2.rare
        end
        if v1.star ~= v2.star then
            return v1.star < v2.star
        end
        local attrInfo1, attrInfo2 = { }, { }
        local basicInfo1, basicInfo2 = common:split(cfg1.basicAttr, ","), common:split(cfg2.basicAttr, ",")
        local randInfo1, randInfo2 = common:split(v1.attr, ","), common:split(v2.attr, ",")
        for i = 1, math.max(#basicInfo1, #basicInfo2) do
            table.insert(attrInfo1, basicInfo1[i])
            table.insert(attrInfo2, basicInfo2[i])
        end
        for i = 1, math.max(#randInfo1, #randInfo2) do
            if string.find(randInfo1[i], "_") then
                table.insert(attrInfo1, randInfo1[i])
            end
            if string.find(randInfo2[i], "_") then
                table.insert(attrInfo2, randInfo2[i])
            end
        end
        for i = 1, math.max(#attrInfo1, #attrInfo2) do
            if attrInfo1[i] and not attrInfo2[i] then
                return true
            elseif not attrInfo1[i] and attrInfo2[i] then
                return false
            else
                local attr1, value1 = unpack(common:split(attrInfo1[i], "_"))
                local attr2, value2 = unpack(common:split(attrInfo2[i], "_"))
                if tonumber(attr1) ~= tonumber(attr2) then
                    return tonumber(attr1) < tonumber(attr2)
                end
                if tonumber(value1) ~= tonumber(value2) then
                    return tonumber(value1) < tonumber(value2)
                end
            end
        end
        if v1.skill ~= v2.skill then
            return v1.skill < v2.skill
        end
        return false
    end)
end

function RuneBuildSelectPage:refreshPage(container)
    self:clearAndReBuildAllItem(container)
end

function RuneBuildSelectPage:clearAndReBuildAllItem(container)
    local selectInfos = RunePageBase_getSelectInfo()
    container.mScrollView:removeAllCell()
    nonWearRuneItems = { }
    nowSelectRank = 0
    nowSelectNum = 0
    ---
    local showCount = 0
    for i = 1, #nonWearRuneTable do
        cell = CCBFileCell:create()
        cell:setCCBFile(IllItemContent.ccbiFile)
        local info = nonWearRuneTable[i]
        if info:getConf().afterId ~= -1 then  -- afterId = -1無法合成
            local handler = IllItemContent:new( { id = i, runeInfo = info })
            cell:registerFunctionHandler(handler)
            container.mScrollView:addCell(cell)
            nonWearRuneItems[info.id] = { cls = handler, node = cell }
            local isSelect = false
            for idx = 1, #selectInfos do
                if selectInfos[idx].id == info.id then
                    local conf = info:getConf()
                    nowSelectRank = conf.rank
                    nowSelectNum = math.min(nowSelectNum + 1, MAX_SELECT_NUM)
                    isSelect = true
                    break
                end
            end
            selectState[info.id] = { isSelect = isSelect, info = info }
            showCount = showCount + 1
        end
    end
    --container.mScrollView:setTouchEnabled(showCount > ROW_COUNT * LINE_COUNT)
    container.mScrollView:orderCCBFileCells()

    NodeHelper:setStringForLabel(container, { mSelectTxt = common:getLanguageString("@RuneSelected", nowSelectNum) })
end
------------------------------------------------
function IllItemContent:new(o)
    o = o or { }
    setmetatable(o, self)
    self.__index = self
    return o
end

function IllItemContent:onRefreshContent(ccbRoot)
    local container = ccbRoot:getCCBFileNode()
    self.container = container
    if self.runeInfo then
        self.cfg = ConfigManager.getFateDressCfg()[self.runeInfo.itemId]
        NodeHelper:setNodesVisible(container, { mCheckNode = true, mCheckImg = selectState[self.runeInfo.id].isSelect, mStarNode = true, mSkill= self.runeInfo.skill~=0 })
        NodeHelper:setSpriteImage(container, { mPic = self.cfg.icon, mFrame = NodeHelper:getImageByQuality(self.cfg.rare), 
                                               mFrameShade = NodeHelper:getImageBgByQuality(self.cfg.rare),
                                               mSkill="skill/S_".. string.sub(self.runeInfo.skill,1,4)..".png" })
        for star = 1, 6 do
            NodeHelper:setNodesVisible(container, { ["mStar" .. star] = (star == self.cfg.star) })
        end
        local attrInfo = { }
        local basicInfo = common:split(self.cfg.basicAttr, ",")
        local randInfo = common:split(self.runeInfo.attr, ",")
        for i = 1, #basicInfo do
            table.insert(attrInfo, basicInfo[i])
        end
        for i = 1, #randInfo do
            if string.find(randInfo[i], "_") then
                table.insert(attrInfo, randInfo[i])
            end
        end
        for i = 1, 2 do
            if attrInfo[i] then
                NodeHelper:setNodesVisible(container, { ["mAttrNode" .. i] = true })
                local attrId, attrNum = unpack(common:split(attrInfo[i], "_"))
                local txt=common:getLanguageString("@Combatattr_"..attrId)
                NodeHelper:setSpriteImage(container, { ["mAttrIcon" .. i] = "attri_" .. attrId .. ".png" })
                NodeHelper:setStringForLabel(container, { ["mAttrNum" .. i] = ("+" .. attrNum),["mAttrTxt" .. i]=txt })
            else
                NodeHelper:setNodesVisible(container, { ["mAttrNode" .. i] = false })
            end
            
        end
        self:initTrainTouchLayer(container)
    end
    
end
-- 建立TouchLayer
function IllItemContent:initTrainTouchLayer(container)
    local bg = container:getVarScale9Sprite("mBg")
    local parent = container:getVarNode("mTouchNode")
    if self.runeInfo then
        parent:removeAllChildrenWithCleanup(true)
        if runeTouchLayer[self.runeInfo.id] then
            --runeTouchLayer[self.runeInfo.id]:removeFromParentAndCleanup(true)
            runeTouchLayer[self.runeInfo.id] = nil
        end
        local layer = CCLayer:create()
        parent:addChild(layer)
        local size = bg:getContentSize()
        layer:setContentSize(size)
        layer:registerScriptTouchHandler(function(eventName, pTouch)
            if eventName == "began" then
                return IllItemContent:onTouchBegin(container, eventName, pTouch, self.runeInfo.id)
            elseif eventName == "moved" then
                return IllItemContent:onTouchMove(container, eventName, pTouch, self.runeInfo.id)
            elseif eventName == "ended" then
                return IllItemContent:onTouchEnd(container, eventName, pTouch, self.runeInfo.id)
            elseif eventName == "cancelled" then
                return IllItemContent:onTouchCancel(container, eventName, pTouch, self.runeInfo.id)
            end
        end
        , false, 0, false)
        layer:setTouchEnabled(true)
        runeTouchLayer[self.runeInfo.id] = layer
    end
end
-- 按鈕事件
function IllItemContent:onTouchBegin(container, eventName, pTouch, id)
    local rect = GameConst:getInstance():boundingBox(runeTouchLayer[id])
    local point = runeTouchLayer[id]:convertToNodeSpace(pTouch:getLocation())
    if GameConst:getInstance():isContainsPoint(rect, point) then
        RuneBuildSelectPage:clearTouchData(container)
        TOUCH_DATA.TOUCH_ID = id
        CCLuaLog("onTouchBegin TOUCH_ID : " .. id)
        TOUCH_DATA.IS_TOUCHING = true
        return true
    end
    return false 
end
function IllItemContent:onTouchMove(container, eventName, pTouch, id)
    if id == TOUCH_DATA.TOUCH_ID then
        local dis = pTouch:getDelta()
        TOUCH_DATA.MOVE_X = TOUCH_DATA.MOVE_X + math.abs(dis.x)
        TOUCH_DATA.MOVE_Y = TOUCH_DATA.MOVE_Y + math.abs(dis.y)
        if TOUCH_DATA.MOVE_Y > 10 then
            RuneBuildSelectPage:clearTouchData(container)
        end
    end
end
function IllItemContent:onTouchEnd(container, eventName, pTouch, id)
    local itemNode = nonWearRuneItems[TOUCH_DATA.TOUCH_ID]
    if itemNode and TOUCH_DATA.TOUCH_TIMECOUNT <= 1 / TOUCH_DATA.TOUCH_TIMEINTERVAL then
        local isSelect = not selectState[TOUCH_DATA.TOUCH_ID].isSelect
        if isSelect then    -- 選擇
            local conf = selectState[TOUCH_DATA.TOUCH_ID].info:getConf()
            if nowSelectNum >= MAX_SELECT_NUM then  -- 數量到上限
                --MessageBoxPage:Msg_Box_Lan("123456789")
            elseif nowSelectRank == 0 or nowSelectRank == conf.rank then -- 品質相同
                NodeHelper:setNodesVisible(itemNode.cls.container, { mCheckImg = isSelect })
                selectState[TOUCH_DATA.TOUCH_ID].isSelect = isSelect
                nowSelectRank = conf.rank
                nowSelectNum = math.min(nowSelectNum + 1, MAX_SELECT_NUM)
                NodeHelper:setStringForLabel(pageContainer, { mSelectTxt = common:getLanguageString("@RuneSelected", nowSelectNum) })
            else
                MessageBoxPage:Msg_Box_Lan(common:getLanguageString("@ERRORCODE_81702"))
            end
        else    -- 取消選擇
            nowSelectNum = math.max(nowSelectNum - 1, 0)
            if nowSelectNum <= 0 then
                nowSelectRank = 0
            end
            NodeHelper:setNodesVisible(itemNode.cls.container, { mCheckImg = isSelect })
            selectState[TOUCH_DATA.TOUCH_ID].isSelect = isSelect
            NodeHelper:setStringForLabel(pageContainer, { mSelectTxt = common:getLanguageString("@RuneSelected", nowSelectNum) })
        end
    end
    RuneBuildSelectPage:clearTouchData(container)
end
function IllItemContent:onTouchCancel(container, eventName, pTouch, id)
    IllItemContent:onTouchEnd(container, eventName, pTouch)
end
function IllItemContent:onPreLoad(ccbRoot)
end
function IllItemContent:onUnLoad(ccbRoot)
end
function IllItemContent:onHand(container)
end
------------------------------------------------
function RuneBuildSelectPage:onExecute(container)
    if TOUCH_DATA.IS_TOUCHING then
        local dt = GamePrecedure:getInstance():getFrameTime()
        TOUCH_DATA.TOUCH_TIMECOUNT = TOUCH_DATA.TOUCH_TIMECOUNT + dt
        if TOUCH_DATA.TOUCH_TIMECOUNT > 1 / TOUCH_DATA.TOUCH_TIMEINTERVAL then
            require("RuneInfoPage")
            RuneInfoPage_setPageInfo(GameConfig.RuneInfoPageType.FUSION, TOUCH_DATA.TOUCH_ID)
            PageManager.pushPage("RuneInfoPage")
            self:clearTouchData(container)
        end
    end
end

function RuneBuildSelectPage:clearTouchData(container)
    TOUCH_DATA.TOUCH_ID = 0
    TOUCH_DATA.TOUCH_TIMECOUNT = 0
    TOUCH_DATA.TOUCH_TIMEINTERVAL = 1
    TOUCH_DATA.IS_TOUCHING = false
    TOUCH_DATA.MOVE_X = 0
    TOUCH_DATA.MOVE_Y = 0
end

function RuneBuildSelectPage:onClose()
    PageManager.popPage(thisPageName)
end

local CommonPage = require("CommonPage")
RuneBuildSelectPage = CommonPage.newSub(RuneBuildSelectPage, thisPageName, option)

return RuneBuildSelectPage