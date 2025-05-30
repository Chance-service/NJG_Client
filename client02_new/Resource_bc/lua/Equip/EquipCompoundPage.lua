----------------------------------------------------------------------------------

----------------------------------------------------------------------------------
local Const_pb 		= require("Const_pb");
local EquipOpr_pb 	= require("EquipOpr_pb");
local HP_pb			= require("HP_pb");
local UserInfo = require("PlayerInfo.UserInfo");
local NodeHelper = require("NodeHelper");
local GuideManager = require("Guide.GuideManager")
------------local variable for system api--------------------------------------
local tostring = tostring;
local tonumber = tonumber;
local string = string;
local pairs = pairs;
local table = table;
--------------------------------------------------------------------------------

local thisPageName 	= "EquipCompoundPage";
local sourceEquipId	= 0;
local targetEquipId = 0;
local attrStr_A, attrStr_B = '', '';

local opcodes = {
	EQUIP_COMPOUND_S	= HP_pb.EQUIP_COMPOUND_S
};

local option = {
	ccbiFile = "EquipmentGodFusionPopUp.ccbi",
	handlerMap = {
		onFusion	= "onCompound",
		onAHand		= "onSelectSRC",
		onBHand		= "onSelectDST",
		onHelp		= "onHelp",
		onClose		= "onClose",
		onConfirm   = "onClose",
	},
	opcode = opcodes
};

local EquipCompoundPageBase = {};

local EquipOprHelper = require("Equip.EquipOprHelper");
local PBHelper = require("PBHelper");
local ItemManager = require("Item.ItemManager");
local NewbieGuideManager = require("NewbieGuideManager")

local hasCompouned = false;
local lackInfo = {item = false, coin = false, rp = false};
local selfContainer = nil
-----------------------------------------------
--EquipCompoundPageBase页面中的事件处理
----------------------------------------------
function EquipCompoundPageBase:onEnter(container)
	NodeHelper:setStringForLabel(container, {mExplain = common:getLanguageString("@EquipCompoundExplain")});
	hasCompouned = false;
	self:registerPacket(container);
	self:refreshPage(container);
	selfContainer = container
	NewbieGuideManager.showHelpPage(GameConfig.HelpKey.HELP_COMPOUND)
	GuideManager.PageContainerRef ["EquipCompoundPage"] = container
end

function EquipCompoundPageBase:onExit(container)
	self:reset();
	self:removePacket(container);
end
----------------------------------------------------------------
function EquipCompoundPageBase:reset()
	hasCompouned = false;
	sourceEquipId = 0;
	targetEquipId = 0;
end

function EquipCompoundPageBase:refreshPage(container)
	self:showSourceEquipInfo(container);
	self:showTargetEquipInfo(container);
	self:showConsumeInfo(container);
end

--原装备展示
function EquipCompoundPageBase:showSourceEquipInfo(container)
	local lb2Str = {
		mALv  		= "",
		mLv1		= "",
		mALvNum		= "",
		mNeedGodAddAttribute	= ''
	};
	local sprite2Img = {
		--mAPic = GameConfig.Image.ClickToSelect,
		mAFrameShade = GameConfig.Image.BackQualityImg
	};
	local itemImg2Qulity = {
		mAHand = GameConfig.Default.Quality
	};
	local scaleMap = {mAPic = 1.0};
	local nodesVisible = {mNeedGodAddAttribute = true};
	local gemVisible = false;
	local aniVisible = false;
	
	if sourceEquipId and sourceEquipId > 0 then
		local userEquip = UserEquipManager:getUserEquipById(sourceEquipId);
	
		local equipId = userEquip.equipId;
		local level = EquipManager:getLevelById(equipId);
		local name	= EquipManager:getNameById(equipId);
		attrStr_A = UserEquipManager:getMainGodlyAttr(userEquip, true, nil, true);
		lb2Str = {
			mLv1 			= common:getR2LVL() .. level,
			mNeedGodAddAttribute 	= attrStr_A,
			mALvNum			= userEquip.strength == 0 and "" or "+" .. userEquip.strength
		};
		sprite2Img = {
			mAPic = EquipManager:getIconById(equipId),
			mAFrameShade = NodeHelper:getImageBgByQuality(EquipManager:getQualityById(equipId))
		};
		itemImg2Qulity = {
			mAHand = EquipManager:getQualityById(equipId)
		};
		
		aniVisible = UserEquipManager:isEquipGodly(userEquip);			
		local gemInfo = PBHelper:getGemInfo(userEquip.gemInfos);
		if table.maxn(gemInfo) > 0 then
			gemVisible = true;
			for i = 1, 4 do
				local gemId = gemInfo[i];
				nodesVisible["mAGemBG" .. i] = gemId ~= nil;
				local gemSprite = "mAGem0" .. i;
				nodesVisible[gemSprite] = false;
				if gemId ~= nil and gemId > 0 then
					local icon = ItemManager:getGemSmallIcon(gemId);
					if icon then
						nodesVisible[gemSprite] = true;
						sprite2Img[gemSprite] = icon;
					end
				end
			end
		end
	end
	
	nodesVisible["mAAni"]	= aniVisible;
	nodesVisible["mAGemNode"]	= gemVisible;
	NodeHelper:setNodesVisible(container, nodesVisible);
	NodeHelper:setStringForLabel(container, lb2Str);
	NodeHelper:setSpriteImage(container, sprite2Img, scaleMap);
	NodeHelper:setQualityFrames(container, itemImg2Qulity, nil, true);
	
	NodeHelper:addEquipAni(container, "mAAni", aniVisible, sourceEquipId);
end

--被融合掉的装备展示
function EquipCompoundPageBase:showTargetEquipInfo(container)
	local lb2Str = {
		mLv2		= "",
		mBLv  		= "",
		mBLvNum		= "",
		mAddAttribute	= ''
	};
	local sprite2Img = {
		mBPic = GameConfig.Image.ClickToSelect,
		mBFrameShade = GameConfig.Image.BackQualityImg
	};
	local itemImg2Qulity = {
		mBHand = GameConfig.Default.Quality
	};
	local scaleMap = {mBPic = 1.0};
	local nodesVisible = {mAddAttribute = true};
	local gemVisible = false;
	local aniVisible = false;
	
	if targetEquipId and targetEquipId > 0 then
		local userEquip = UserEquipManager:getUserEquipById(targetEquipId);
		if userEquip == nil or userEquip.id == nil then
			return;
		end
	
		local equipId = userEquip.equipId;
		local level = EquipManager:getLevelById(equipId);
		local name	= EquipManager:getNameById(equipId);
		attrStr_B = UserEquipManager:getMainGodlyAttr(userEquip, true, nil, true);
		lb2Str = {
			mBLv  		= "",
			mLv2 			= common:getR2LVL() .. level,
			mBLv  		= "",
			mAddAttribute		= attrStr_B.. "\n" .. attrStr_A,
			mBLvNum			= userEquip.strength == 0 and "" or "+" .. userEquip.strength
		};
		sprite2Img = {
			mBPic = EquipManager:getIconById(equipId),
			mBFrameShade = NodeHelper:getImageBgByQuality(EquipManager:getQualityById(equipId))
		};
		itemImg2Qulity = {
			mBHand = EquipManager:getQualityById(equipId)
		};
		
		aniVisible = UserEquipManager:isEquipGodly(userEquip);			
		local gemInfo = PBHelper:getGemInfo(userEquip.gemInfos);
		if table.maxn(gemInfo) > 0 then
			gemVisible = true;
			for i = 1, 4 do
				local gemId = gemInfo[i];
				nodesVisible["mBGemBG" .. i] = gemId ~= nil;
				local gemSprite = "mBGem0" .. i;
				nodesVisible[gemSprite] = false;
				if gemId ~= nil and gemId > 0 then
					local icon = ItemManager:getGemSmallIcon(gemId);
					if icon then
						nodesVisible[gemSprite] = true;
						sprite2Img[gemSprite] = icon;
					end
				end
			end
		end
	end
	
	nodesVisible["mBAni"]	= aniVisible;
	nodesVisible["mBGemNode"]	= gemVisible;
	NodeHelper:setNodesVisible(container, nodesVisible);
	NodeHelper:setStringForLabel(container, lb2Str);
	NodeHelper:setSpriteImage(container, sprite2Img, scaleMap);
	NodeHelper:setQualityFrames(container, itemImg2Qulity, nil, true);
	
	NodeHelper:addEquipAni(container, "mBAni", aniVisible, targetEquipId);
end

function EquipCompoundPageBase:clearResult(container)
	NodeHelper:setStringForLabel(container, {
		mLv 	= '',
		mLvNum	= ''
	});
	NodeHelper:setNodesVisible(container, {
		mPic = false,
		mAni = false,
		mGemNode = false
	});
	NodeHelper:setQualityFrames(container, {
		mHand = GameConfig.Default.Quality
	});
end

--ÈÚºÏºó×°±¸Õ¹Ê¾
function EquipCompoundPageBase:showResult(container)
	local userEquip = UserEquipManager:getUserEquipById(sourceEquipId);
	if userEquip == nil or userEquip.id == nil then
		return;
	end
	
	local equipId = userEquip.equipId;
	local level = EquipManager:getLevelById(equipId);
	local name	= EquipManager:getNameById(equipId);
	local lb2Str = {
		mLv 		= UserEquipManager:getMainGodlyAttr(userEquip, true, nil, true),
		mLvNum		= userEquip.strength == 0 and "" or "+" .. userEquip.strength
	};
	local sprite2Img = {
		mPic = EquipManager:getIconById(equipId)
	};
	local itemImg2Qulity = {
		mHand = EquipManager:getQualityById(equipId)
	};
	local scaleMap = {mPic = GameConfig.EquipmentIconScale};
	
	local nodesVisible = {mPic = true};
	local gemVisible = false;
	local aniVisible = UserEquipManager:isEquipGodly(userEquip);			
	local gemInfo = PBHelper:getGemInfo(userEquip.gemInfos);
	if table.maxn(gemInfo) > 0 then
		gemVisible = true;
		for i = 1, 4 do
			local gemId = gemInfo[i];
			nodesVisible["mGemBG" .. i] = gemId ~= nil;
			local gemSprite = "mGem0" .. i;
			nodesVisible[gemSprite] = false;
			if gemId ~= nil and gemId > 0 then
			local icon = ItemManager:getGemSmallIcon(gemId);
			if icon then
				nodesVisible[gemSprite] = true;
				sprite2Img[gemSprite] = icon;
				scaleMap[gemSprite] = 1
				end
			end
		end
	end
	nodesVisible["mAni"]	= aniVisible;
	nodesVisible["mGemNode"]	= gemVisible;
	NodeHelper:setNodesVisible(container, nodesVisible);
	
	NodeHelper:setStringForLabel(container, lb2Str);
	NodeHelper:setSpriteImage(container, sprite2Img, scaleMap);
	NodeHelper:setQualityFrames(container, itemImg2Qulity);
	
	NodeHelper:addEquipAni(container, "mAni", aniVisible, sourceEquipId);
end	

function EquipCompoundPageBase:showConsumeInfo(container)
	lackInfo.coin = false;
	lackInfo.item = false;
	lackInfo.rp	  = false;
	
	local showConsume = false;
	if not hasCompouned
		and sourceEquipId and sourceEquipId > 0
		and targetEquipId and targetEquipId > 0
	then
		showConsume = true;
		local coinCostStr, rpCostStr = "--", '--';
		local coinCost, itemCost = UserEquipManager:getCompoundCost(sourceEquipId, targetEquipId);
		UserInfo.syncPlayerInfo();
		-- coinCostStr = common:getLanguageString("@CurrentOwnInfo", coinCost, UserInfo.playerInfo.coin);
		 lackInfo.coin = coinCost > UserInfo.playerInfo.coin;
		local rpCost = GameConfig.Cost.CompoundEquip or "--";
		-- rpCostStr = common:getLanguageString("@CurrentOwnInfo", rpCost, UserInfo.playerInfo.reputationValue);
		 lackInfo.rp = rpCost > UserInfo.playerInfo.reputationValue;
	--[[
	--注灵之石不消耗了
		if itemCost and itemCost > 0 then
			local UserItemManager = require("Item.UserItemManager");
			local ownNum = UserItemManager:getCountByItemId(GameConfig.ItemId.GodlyEquipStone);
			itemCostStr = ownNum .. "/" .. itemCost;
			lackInfo.item = itemCost > ownNum;
		end
	-]]
		local lb2Str = {
			mGold1 				= common:getLanguageString("@NeedGold") ..  coinCost,
			mGold2 				= common:getLanguageString("@CurrentGold") ..  UserInfo.playerInfo.coin,
			mReputationNum1 	= common:getLanguageString("@NeedReputation") .. rpCost,
			mReputationNum2 	= common:getLanguageString("@CurrentReputation") ..  UserInfo.playerInfo.reputationValue,
			-- mAddAttribute	= attrStr_B .. "\n" .. attrStr_A
		};
		NodeHelper:setStringForLabel(container, lb2Str);
			
		-- local colorMap = {
		-- 	mGold 			= common:getColorFromConfig(lackInfo.coin and "Lack" or "Own"),
		-- 	mReputationNum	= common:getColorFromConfig(lackInfo.rp and "Lack" or "Own")
		-- };
		-- NodeHelper:setColor3BForLabel(container, colorMap);
	end
	
	NodeHelper:setNodesVisible(container, {mNeedNode = showConsume});
end
----------------click event------------------------
function EquipCompoundPageBase_onSelectSRC()
	EquipCompoundPageBase:onSelectSRC(selfContainer)
end
function EquipCompoundPageBase:onSelectSRC(container)
	if hasCompouned then
		self:reset();
	end
	local selectedIds = sourceEquipId and sourceEquipId > 0 and {sourceEquipId} or {};
	EquipSelectPage_multiSelect(selectedIds, 1, function(ids)
        for k,v in pairs(ids) do
		    sourceEquipId = k
            break
        end
		self:refreshPage(container);
	end, targetEquipId, EquipFilterType.CompoundSRC);
	PageManager.pushPage("EquipSelectPage");
end

function EquipCompoundPageBase:onSelectDST(container)
	if hasCompouned then
		self:reset();
	end
	--if not sourceEquipId or sourceEquipId <= 0 then return; end
	
	local selectedIds = targetEquipId and targetEquipId > 0 and {targetEquipId} or {};
	EquipSelectPage_multiSelect(selectedIds, 1, function(ids)
		for k,v in pairs(ids) do
		    targetEquipId = k
            break
        end
		self:refreshPage(container);
	--	self:showTargetEquipInfo(container);
	--	self:showConsumeInfo(container);
	end, sourceEquipId, EquipFilterType.CompoundDST);
	PageManager.pushPage("EquipSelectPage");
end
function EquipCompoundPageBase_onCompound()
	EquipOprHelper:compoundEquip(sourceEquipId, targetEquipId);
end

function EquipCompoundPageBase:onCompound(container)
	if sourceEquipId and sourceEquipId > 0 
		and targetEquipId and targetEquipId > 0 
	then
		if hasCompouned then return; end
		
		if lackInfo.item then
			MessageBoxPage:Msg_Box_Lan("@GodlyEquipStoneNotEnough");
			return;
		elseif lackInfo.rp then
			MessageBoxPage:Msg_Box_Lan("@ReputationNotEnough");
			return;
		elseif lackInfo.coin then
			PageManager.notifyLackCoin();
			return;
		end
		EquipOprHelper:compoundEquip(sourceEquipId, targetEquipId);
	elseif sourceEquipId and sourceEquipId > 0 then
		MessageBoxPage:Msg_Box("@PlzSelectCompoundTarget");
	else
		MessageBoxPage:Msg_Box("@PlzSelectCompoundSource");
	end
end

function EquipCompoundPageBase:onHelp(container)
	PageManager.showHelp(GameConfig.HelpKey.HELP_COMPOUND);
end	

function EquipCompoundPageBase:onClose(container)
	PageManager.popPage(thisPageName);
end

--回包处理
function EquipCompoundPageBase:onReceivePacket(container)
	local opcode = container:getRecPacketOpcode()
	--local msgBuff = container:getRecPacketBuffer()

	if opcode == opcodes.EQUIP_COMPOUND_S then
		hasCompouned = true;
		common:popString(common:getLanguageString('@CompoundSuccess'), 'COLOR_GREEN');
		NodeHelper:setStringForLabel(container, {--20: char per line
			mConfirmText	= common:getLanguageString("@EquipGodMerge"), });
		NodeHelper:setNodesVisible(container,{mGoldFuse = false,mConfirm = true})
		self:refreshPage(container);
		PageManager.refreshPage("ArenaPage");
		PageManager.refreshPage("MeltPage");
		PageManager.refreshPage("EquipLeadPage")
        PageManager.refreshPage("EquipMercenaryPage");
		return
	end
end

function EquipCompoundPageBase:registerPacket(container)
	for key, opcode in pairs(opcodes) do
		if string.sub(key, -1) == "S" then
			container:registerPacket(opcode)
		end
	end
end

function EquipCompoundPageBase:removePacket(container)
	for key, opcode in pairs(opcodes) do
		if string.sub(key, -1) == "S" then
			container:removePacket(opcode)
		end
	end
end
-------------------------------------------------------------------------
local CommonPage = require("CommonPage");
EquipCompoundPage = CommonPage.newSub(EquipCompoundPageBase, thisPageName, option);


function EquipCompoundPage_setEquipId(equipId)
	targetEquipId = equipId;
end
