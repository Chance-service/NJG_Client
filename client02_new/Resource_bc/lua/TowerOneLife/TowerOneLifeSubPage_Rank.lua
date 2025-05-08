local NodeHelper = require("NodeHelper")
local thisPageName = 'TowerOneLife.TowerOneLifeSubPage_Rank'
local TowerDataBase = require "Tower.TowerPageData"

local selfContainer
local TowerRankBase = {}
local nowType = 1

local RankRewardPopCCB = nil

local RankingContent = {
    ccbiFile = "Tower_RankingContent.ccbi",
}
local RankRewardContent={
    ccbiFile = "Tower_PopupContent.ccbi",
}

local TowerRankInfo = {}

local option = {
    ccbiFile = "Tower_Ranking.ccbi",
    handlerMap =
    {
        onDailyReward="onDailyReward",
        onDailyHelp = "onHelp",
        onClose="onClose",
        onRankingReward = "onRankingReward",
        onReturn = "onReturn"
    },
}

function TowerRankBase:onRankingReward(container)
   local parentNode = container:getVarNode("mPopUpNode")
   if parentNode then 
       parentNode:removeAllChildren()
       RankRewardPopCCB = ScriptContentBase:create("Tower_Popup")
       parentNode:addChild(RankRewardPopCCB)
       RankRewardPopCCB:registerFunctionHandler(RankRewardPopFunction)
       RankRewardPopCCB:setAnchorPoint(ccp(0.5,0.5))
       TowerRankBase:setRewardPopCCB(RankRewardPopCCB)
   end
end
function RankRewardPopFunction(eventName,container)
    if eventName == "onClose" then
        local parentNode = selfContainer:getVarNode("mPopUpNode")
        if parentNode then
            parentNode:removeAllChildren()
        end
    end
end
function TowerRankBase:setRewardPopCCB(container)
    local scrollview = container:getVarScrollView("mContent")
    local cfg =  ConfigManager.getFearTowerRewardCfg()
    for k,value in pairs (cfg) do
        if value.towerId == nowType then
            local cell = CCBFileCell:create()
            cell:setCCBFile(RankRewardContent.ccbiFile)
            local panel = common:new({data = value}, RankRewardContent)
            cell:registerFunctionHandler(panel)
            scrollview:addCell(cell)
        end
    end
    scrollview:orderCCBFileCells()
    scrollview:setTouchEnabled(true)
    NodeHelper:setStringForLabel(container,{mTitle = common:getLanguageString("@MineRankPrize") })
end
function RankRewardContent:onRefreshContent(content)
    local container = content:getCCBFileNode()
    local RewardCfg =  ConfigManager.getFearTowerRewardCfg()
    local stringTable = {}
    if self.data.id>1 and RewardCfg[self.data.id].minRank-RewardCfg[self.data.id-1].minRank >1 then
        stringTable["mTitleTxt"] = RewardCfg[self.data.id-1].minRank+1 .."-".. RewardCfg[self.data.id].minRank
    else
        stringTable["mTitleTxt"] = common:getLanguageString("@FishingRankingNumber", RewardCfg[self.data.id].minRank ) 
    end
    NodeHelper:setStringForLabel(container,stringTable)
    local Items = self.data.reward
    NodeHelper:setNodesVisible(container,{mPassed = false})
    for i = 1 ,4 do
         local parentNode=container:getVarNode("mPosition"..i)
         parentNode:removeAllChildren()
          if Items and Items[i] then
            local ItemNode = ScriptContentBase:create("CommItem")
            ItemNode:setScale(0.8)
            ItemNode.Reward= Items[i]
            ItemNode:registerFunctionHandler(function(eventName,container) 
                                                if eventName=="onHand1" then
                                                   GameUtil:showTip(container:getVarNode('mPic1'), container.Reward)
                                                end
                                            end)
            NodeHelper:setNodesVisible(ItemNode,{selectedNode=false,mStarNode=false,nameBelowNode=false, mPoint = false})
            local resInfo = ResManagerForLua:getResInfoByTypeAndId(Items[i].type, Items[i].itemId, Items[i].count)
            local normalImage = NodeHelper:getImageByQuality(resInfo.quality)
            local iconBg = NodeHelper:getImageBgByQuality(resInfo.quality)
            NodeHelper:setMenuItemImage(ItemNode, {mHand1 = {normal = normalImage}})
            NodeHelper:setSpriteImage(ItemNode, {mPic1 = resInfo.icon, mFrameShade1 = iconBg})
            NodeHelper:setStringForLabel(ItemNode,{mNumber1_1=Items[i].count})
            parentNode:addChild(ItemNode)
        end
    end
end
function TowerRankBase:onReturn(container)
    PageManager.popPage(thisPageName)
end
function TowerRankBase:onEnter(container)
    selfContainer=container
    NodeHelper:setNodesVisible(container,{mTeam=false,mDaily=true})
  
    --Bg
    container:getVarNode("mBg"):setScale(NodeHelper:getScaleProportion())
    NodeHelper:setSpriteImage(container,{mBg = "BG/Tower/Tower_bg05.png"})
    NodeHelper:setStringForLabel(container,{mTitle = common:getLanguageString("@FearlessTower_RankTitle")})
    container.mScrollView=container:getVarScrollView("mContent")
    NodeHelper:autoAdjustResizeScrollview(container.mScrollView)
    TowerRankBase:refresh(container)
end
function TowerRankBase:setType(_type)
    nowType = _type
end
function TowerRankBase:refresh(container)
    if container==nil then return end    
    TowerRankInfo=TowerDataBase:getRank(199,nowType)

    if container and container.mScrollView then
        TowerRankBase:initScrollView(container)
    end
    local SelfTable=TowerRankInfo
    local StringTable={}
    local VisableTable={}
    local SpriteImg=GameConfig.ArenaRankingIcon[1]
    if SelfTable.selfRank==2 then
        SpriteImg=GameConfig.ArenaRankingIcon[2]
    elseif SelfTable.selfRank==3 then
        SpriteImg=GameConfig.ArenaRankingIcon[3]
    end
    NodeHelper:setSpriteImage(container,{mRankSprite=SpriteImg})
    VisableTable["mRankSprite"]=(SelfTable.selfRank<4 and SelfTable.selfRank~=0)
    StringTable["mRankText"]=SelfTable.selfRank
    if SelfTable.selfRank==0 then
        StringTable["mSelfRankText"]="-"
    end
    StringTable["mPlayerScore"]=SelfTable.selfFloor
    StringTable["mPlayerName"]=SelfTable.selfName
    StringTable["mSelfTxt"]= common:getLanguageString("@SeasonTowerXstage",SelfTable.selfFloor) .." ".. os.date("%Y/%m/%d %H:%M:%S", math.floor(SelfTable.selfDoneTime/1000))
    if SelfTable.selfFloor == 0 then
        StringTable["mSelfTxt"] = "-"
        VisableTable["mRankSprite"] = false
        StringTable["mRankText"]="-"
    end
    NodeHelper:setStringForLabel(container,StringTable)
    NodeHelper:setNodesVisible(container,VisableTable)

    local NewHeadIconItem = require("NewHeadIconItem")
    local parentNode = container:getVarNode("mSelfHeadNode")
    parentNode:removeAllChildrenWithCleanup(true)
    local headNode = ScriptContentBase:create("FormationTeamContent.ccbi")
    headNode:setAnchorPoint(ccp(0.5, 0.5))
    parentNode:addChild(headNode)
    NodeHelper:setNodesVisible(headNode, { mClass = false, mElement = false, mMarkFighting = false, mMarkChoose = false, 
                                                mMarkSelling = false, mMask = false, mSelectFrame = false, mStageImg = false ,mLvNode=false})
     local icon = common:getPlayeIcon(1,SelfTable.selfHead)
     if NodeHelper:isFileExist(icon) then
         NodeHelper:setSpriteImage(headNode, { mHead = icon })
     end
end
function TowerRankBase:initScrollView(container)
    local RankTable = TowerRankInfo.otherItem
    if RankTable== nil then return end
    for i=1 ,#RankTable do
        local info=RankTable[i]
        local cell = CCBFileCell:create()
        cell:setCCBFile(RankingContent.ccbiFile)
        local handler = common:new({data = info,id = i}, RankingContent)
        cell:registerFunctionHandler(handler)
        container.mScrollView:addCell(cell)
    end
    
    container.mScrollView:orderCCBFileCells()
end
function RankingContent:onRefreshContent(ccbRoot)
    local container = ccbRoot:getCCBFileNode()
    local VisableTable={}
    local StringTable={}
    local PosY = container:getPositionY()
    container:setPositionX(600*self.data.rank)
    local array = CCArray:create()
    array:addObject(CCMoveTo:create(0.3, ccp(0,PosY)))
    container:runAction(CCSequence:create(array))
    local SpriteImg=GameConfig.ArenaRankingIcon[1]
    if self.data.rank==2 then
        SpriteImg=GameConfig.ArenaRankingIcon[2]
    elseif self.data.rank==3 then
        SpriteImg=GameConfig.ArenaRankingIcon[3]
    end
    VisableTable["mRankSprite"]=(self.data.rank<4)
    StringTable["mRankText"]=self.data.rank
    StringTable["mPlayerName"]=self.data.name
    local timeTxt = common:getLanguageString("@SeasonTowerXstage",self.data.MaxFloor) .." "..os.date("%Y/%m/%d %H:%M:%S", math.floor(self.data.doneTime/1000))
     if self.data.MaxFloor -1 == 0 then
       timeTxt = "-"
    end
    StringTable["mDesc"]= timeTxt
    NodeHelper:setStringForLabel(container,StringTable)
    NodeHelper:setNodesVisible(container,VisableTable)
    NodeHelper:setSpriteImage(container,{mRankSprite=SpriteImg})

    local NewHeadIconItem = require("NewHeadIconItem")
    if container==nil then return end
    local parentNode = container:getVarNode("mHeadNode")
    parentNode:removeAllChildrenWithCleanup(true)
    local headNode = ScriptContentBase:create("FormationTeamContent.ccbi")
    headNode:setAnchorPoint(ccp(0.5, 0.5))
    parentNode:addChild(headNode)
    NodeHelper:setNodesVisible(headNode, { mClass = false, mElement = false, mMarkFighting = false, mMarkChoose = false, 
                                                mMarkSelling = false, mMask = false, mSelectFrame = false, mStageImg = false ,mLvNode=false})
     local icon = common:getPlayeIcon(1,self.data.headIcon)
     if NodeHelper:isFileExist(icon) then
         NodeHelper:setSpriteImage(headNode, { mHead = icon })
     end
end
function TowerRankBase:setTime(txt)
   if selfContainer and txt then
        NodeHelper:setStringForLabel(selfContainer,{mCountDown = common:getLanguageString("@FearlessTower_RankResetTime")..txt})
   end
end

-- 說明頁
function TowerRankBase:onHelp(container)
    PageManager.showHelp(GameConfig.HelpKey.HELP_GLORY_HOLE_RANKING)
end

local CommonPage = require('CommonPage')
TowerRankPage = CommonPage.newSub(TowerRankBase, thisPageName, option)
return TowerRankPage
