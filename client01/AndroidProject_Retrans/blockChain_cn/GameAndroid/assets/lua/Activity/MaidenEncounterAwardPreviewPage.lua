
local thisPageName = "MaidenEncounterAwardPreviewPage";
local NodeHelper = require("NodeHelper");
local UserInfo = require("PlayerInfo.UserInfo");
local suitCfg = ConfigManager.getSuitCfg()

local option = {
    ccbiFile = "Act_TimeLimitGirlsMeetIllustratedContent.ccbi",
    handlerMap =
    {
        onClose = "onClose"
    }
};

local showItemType = {
    exclusive = 1,--专属奖励
    stage1 = 2,--阶段1
    stage2 = 3,--阶段2
    stage3 = 4,--阶段3
    base = 5,--基础奖励
}

local MaidenEncounterAwardPreviewBase = {};

local SuitShowList = {}
local ConstCountNumberItem = 10;--最多十个
local SelectIndex = 1--选中的道具
local scrollView = nil
local containerRef = nil
-----------------------------------------------------------------------
function MaidenEncounterAwardPreviewBase:onEnter(container)
    NodeHelper:initScrollView(container, 'mContent', 10)
    scrollView = container.mScrollView
    containerRef = container
    self:getReadTxtInfo()
    self:refreshPage(container)
end

--读取配置文件信息
function MaidenEncounterAwardPreviewBase:getReadTxtInfo()
    SuitShowList = {}
    SuitShowList.cfg = ConfigManager.getMaidenEncounterRewardCfg()
    for i = 1,#SuitShowList.cfg do
        if SuitShowList["list"..SuitShowList.cfg[i].type] == nil then
            SuitShowList["list"..SuitShowList.cfg[i].type] = {}
        end
       table.insert( SuitShowList["list"..SuitShowList.cfg[i].type] , SuitShowList.cfg[i]);
    end
end

function MaidenEncounterAwardPreviewBase:onExecute(container)
end

function MaidenEncounterAwardPreviewBase:onExit(container)
    NodeHelper:deleteScrollView(container);
    onUnload(thisPageName, container);
end

function MaidenEncounterAwardPreviewBase:refreshPage(container)
      self:refreshButton(container)
      self:rebuildAllItem(container)
end

function MaidenEncounterAwardPreviewBase:refreshButton(container)

end

-------------------------------------------------------------------------
----------------click event------------------------

function MaidenEncounterAwardPreviewBase:onClose(container)
	  PageManager.popPage(thisPageName)
end

----------------scrollview item-------------------------

local SuitsItem = {
    ccbiFile = 'Act_TimeLimitGirlsMeetIllustratedListContent.ccbi'
}

function SuitsItem.onFunction(eventName, container)
	if eventName == "luaRefreshItemView" then
		  SuitsItem.onRefreshItemView(container)
    elseif string.sub(eventName,1,7)=="onFrame" then
        SuitsItem.showItemInfo(container, eventName)
	end  
end
local isref = true

function MaidenEncounterAwardPreviewBase:buildScrollView(container, size, ccbiFile, funcCallback, notOffset)
	if size == 0 or ccbiFile == nil or ccbiFile == '' or funcCallback == nil then return end
	local iMaxNode = container.m_pScrollViewFacade:getMaxDynamicControledItemViewsNum()
	local iCount = 0
	local fOneItemHeight = 0
	local fOneItemWidth = 0

	for i=size, 1, -1 do
		local pItemData = CCReViSvItemData:new_local()
		pItemData.mID = i
		pItemData.m_iIdx = i
        local listRewards = SuitShowList["list"..i]
		if iCount < iMaxNode then
			local pItem = ScriptContentBase:create(ccbiFile)
            if #listRewards <= 5 then--小于5个只有一行
               pItem:setContentSize(CCSizeMake(pItem:getContentSize().width,pItem:getContentSize().height - 105));
            end
        
            pItem.id = iCount
			pItem:registerFunctionHandler(funcCallback)
            pItemData.m_ptPosition = ccp(0, fOneItemHeight)
			local OneItemHeight = pItem:getContentSize().height
            fOneItemHeight = fOneItemHeight + OneItemHeight;
            
			if fOneItemWidth < pItem:getContentSize().width then
				fOneItemWidth = pItem:getContentSize().width
			end
			container.m_pScrollViewFacade:addItem(pItemData, pItem.__CCReViSvItemNodeFacade__)
		else
			container.m_pScrollViewFacade:addItem(pItemData)
		end
		iCount = iCount + 1
	end

	local size = CCSizeMake(fOneItemWidth, fOneItemHeight)
	container.mScrollView:setContentSize(size)
	if not notOffset then
		container.mScrollView:setContentOffset(ccp(0, container.mScrollView:getViewSize().height - container.mScrollView:getContentSize().height * container.mScrollView:getScaleY()))
	end
	container.m_pScrollViewFacade:setDynamicItemsStartPosition(iCount-1);
	container.mScrollView:forceRecaculateChildren();
	ScriptMathToLua:setSwallowsTouches(container.mScrollView)
end

function SuitsItem.onRefreshItemView(container)
    local index = container:getItemDate().mID;
    local listRewards = SuitShowList["list"..index]
    if not listRewards then return end
    local cfg = {};
    local lb2Str = {};
    local sprite2Img = {};
    local menu2Quality = {};
    local idx = 1;
    --如果小于等于5个，显示下面一排，并改变高度
    if (#listRewards) > 5 then -- 上一排是从6-10，下一排1-5
        idx = 6;
    end
    --mFrameShade1 mPic1 mHand1 mName1 mNumber1 mGoodsAni1 
    for i = 1, ConstCountNumberItem do
        cfg = listRewards[i]
        if cfg then--改变数据
            local resInfo = ResManagerForLua:getResInfoByTypeAndId(cfg.rewards[1].type, cfg.rewards[1].itemId, cfg.rewards[1].count);
            sprite2Img["mPic" .. idx]         = resInfo.icon;
            sprite2Img["mFrameShade".. idx]   = NodeHelper:getImageBgByQuality(resInfo.quality);
            lb2Str["mNumber" .. idx]          = "x" .. GameUtil:formatNumber( cfg.rewards[1].count );
            lb2Str["mName" .. idx]            = resInfo.name;
            menu2Quality["mFrame" .. idx]      = resInfo.quality
            NodeHelper:setSpriteImage(container, sprite2Img);
            NodeHelper:setQualityFrames(container, menu2Quality);
            NodeHelper:setStringForLabel(container, lb2Str);
            if string.sub(resInfo.icon, 1, 7) == "UI/Role" then 
                NodeHelper:setNodeScale(container, "mPic" .. idx, 0.84, 0.84)
            else
                NodeHelper:setNodeScale(container, "mPic" .. idx, 1, 1)
            end
        else--隐藏多余的
            container:getVarNode("mRewardNode" .. idx):setVisible( false )
        end
        idx = idx + 1
        if idx > 10 then
            idx = 1;
        end
    end
    NodeHelper:setStringForLabel(container, {mRewardTitleTxt = common:getLanguageString(listRewards[1].title)});
    if (#listRewards) <= 5 then--小于5个只有一行
        container:getVarNode("mRewardTitleTxt"):setPositionY(container:getVarNode("mRewardTitleTxt"):getPositionY()-105);
        container:getVarNode("m9S1"):setContentSize(CCSizeMake(container:getVarNode("m9S1"):getContentSize().width,container:getVarNode("m9S1"):getContentSize().height - 105));
        container:getVarNode("m9S2"):setContentSize(CCSizeMake(container:getVarNode("m9S2"):getContentSize().width,container:getVarNode("m9S2"):getContentSize().height - 105));
    end

end	

function SuitsItem.showItemInfo(container, eventName)
    local index = container:getItemDate().mID;
    local listRewards = SuitShowList["list"..index];
    local index_child = tonumber(eventName:sub(8))
    local idx = index_child;
    if (#listRewards) > 5 then -- 上一排是从6-10，下一排1-5
        if index_child > 5 then
            idx = index_child - 5;
        else
            idx = index_child + 5;
        end
    end
    local info = listRewards[idx].rewards[1]
    GameUtil:showTip(container:getVarNode("mPic"..index_child), info)
end

----------------scrollview-------------------------
function MaidenEncounterAwardPreviewBase:rebuildAllItem(container)
    self:clearAllItem(container)
    self:buildItem(container)
end

function MaidenEncounterAwardPreviewBase:clearAllItem(container)
	NodeHelper:clearScrollView(container)
end

function MaidenEncounterAwardPreviewBase:buildItem(container)
    NodeHelper:clearScrollView(container)  ---这里是清空滚动层
    MaidenEncounterAwardPreviewBase:buildScrollView(container, 5, SuitsItem.ccbiFile, SuitsItem.onFunction);
end
----------------------------------------------------------------
local CommonPage = require("CommonPage");
local MaidenEncounterAwardPreviewPage = CommonPage.newSub(MaidenEncounterAwardPreviewBase, thisPageName, option)
