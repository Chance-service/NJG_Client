local thisPageName = "NgBattleResultPage"
local basePage = require("BasePage")
local NodeHelper = require("NodeHelper")
local pageManager = require("PageManager")
local ConfigManager = require("ConfigManager")
local GameConfig = require("GameConfig")
local UserInfo = require("PlayerInfo.UserInfo")
local ResManager = require("ResManagerForLua")
local Const_pb = require("Const_pb")
local HP_pb  = require("HP_pb")
local common = require("common")
local CONST = require("Battle.NewBattleConst")
local PageJumpMange = require("PageJumpMange")
local UserMercenaryManager = require("UserMercenaryManager")
local ALFManager = require("Util.AsyncLoadFileManager")
require("Battle.NgBattleDetailPage")
require("Battle.NgBattleDataManager")
require("Battle.NgBattleResultManager")
local option = {
    ccbiFile = "BattleWinOrLosePopUp_1.ccbi",
    handlerMap =
    {
        onTunkScreenContinue = "onClose",
        onDetail = "onDetail",
        onUpgradeEquipment = "onUpgradeEquipment",
        onMercenaryCulture = "onMercenaryCulture",
        onShopping = "onShopping",
        onClickGuide = "onClose",

        onLoseBtn = "onLoseBtn",
        onWinBtn = "onWinBtn",
        onNextBtn = "onNextBtn",
        onGuideLoseBtn = "onGuideLoseBtn",

        onHeroPage = "onHeroPage",
        onShopPage = "onShopPage",
        onBountyPage = "onBountyPage",

        onTestLog = "onTestLog",
        onTestDps = "onTestDps",
    }
}
local ItemContentUI = {
    ccbiFile = "GoodsItem.ccbi"
}
local NgBattleResultPage = basePage:new(option, thisPageName)

local rewardItemInfo = { [1] = { type = 30000, itemId = 101001, count = 1 }, [2] = { type = 10000, itemId = 1004, count = 1000 }, [3] = { type = 40000, itemId = 1008, count = 2 } }
NgBattleResultPage.isLevelUP = false
local task = nil

local opcodes = {
    BATTLE_FORMATION_S = HP_pb.BATTLE_FORMATION_S
}

function NgBattleResultPage:resetData()
    rewardItemInfo = { }
    NgBattleResultPage.isLevelUP = false
    if task then
        ALFManager:cancel(task)
        task = nil
    end
end

function NgBattleResultPage:onEnter(container)
    -- 同步角色資訊
    UserInfo.syncRoleInfo()
    self:registerPacket(container)   
    -- 計算玩家 MVP（詳細實作在 NgBattleDetailPage_calculateMvp 內）
    NgBattleDetailPage_calculateMvp(container)
    
    -- 註冊 LibOS，並根據 Debug 狀態顯示相關節點
    container:registerLibOS()
    local isDebug = libOS:getInstance():getIsDebug()
    NodeHelper:setNodesVisible(container, {
        mTestDpsNode = isDebug,
        mTestLogNode = isDebug,
    })
    
    -- 如果是 單人 Boss 或 單人 Boss 模擬模式，直接跳頁到 SingleBossPopResult
    local bt = NgBattleDataManager.battleType
    if bt == CONST.SCENE_TYPE.SINGLE_BOSS or bt == CONST.SCENE_TYPE.SINGLE_BOSS_SIM then
        PageManager.pushPage("SingleBoss.SingleBossPopResult")
    end
    
    -- 預設「下一關」按鈕為可用，稍後再依據不同場景判斷是否要禁用
    NodeHelper:setMenuItemEnabled(container, "mNextBtn", true)
    
    -- 統一判斷不同 battleType 下，是否要禁用「下一關」按鈕
    local function disableNextIf(cond)
        if cond then
            NodeHelper:setMenuItemEnabled(container, "mNextBtn", false)
        end
    end
    NodeHelper:setStringForLabel(container,{mNextTxt = common:getLanguageString("@NextStageAttr")})
    if bt == CONST.SCENE_TYPE.BOSS then
        local cfg = ConfigManager.getNewMapCfg()
        local nextID = cfg[NgBattleDataManager.battleMapId].NextID
        NodeHelper:setStringForLabel(container,{mNextTxt = common:getLanguageString("@ConfirmandContinue")})
        -- 如果 NextID == 0，表示沒有下一關
        disableNextIf(nextID == 0 )
    
    elseif bt == CONST.SCENE_TYPE.SEASON_TOWER then
        local cfg = ConfigManager.getTowerData()
        local nextStage = cfg[NgBattleDataManager.TowerId].nextStage
        disableNextIf(nextStage == 0)
    
    elseif bt == CONST.SCENE_TYPE.FEAR_TOWER then
        local cfg = ConfigManager.getFearTowerSubCfg()
        -- 由 TowerPageData 取得當前最高樓層資訊
        local TowerDataBase = require "Tower.TowerPageData"
        local PageInfo = TowerDataBase:getData(199, NgBattleDataManager.TowerId)
        local stageId = math.max(PageInfo.MaxFloor, 1000 * NgBattleDataManager.TowerId + 1)
        local nextStage = cfg[stageId].nextId
        NodeHelper:setStringForLabel(container,{mNextTxt = common:getLanguageString("@ConfirmandContinue")})
        -- 如果下一關為 0，或下一關類型為 1（表示特殊類型），則禁用下一關
        disableNextIf(nextStage == 0 or cfg[nextStage].Type == 1)
    
    elseif bt == CONST.SCENE_TYPE.LIMIT_TOWER then
        local TowerDataBase = require "Tower.TowerPageData"
        local PageInfo = TowerDataBase:getData(198, NgBattleDataManager.limitType)
        local stageId = math.max(PageInfo.MaxFloor, 1)
        local nextStage = TowerDataBase:getLimitCfg(stageId, NgBattleDataManager.limitType).nextStage
        disableNextIf(nextStage == 0)
    
    elseif bt == CONST.SCENE_TYPE.DUNGEON then
        local cfg = ConfigManager.getMultiElite2Cfg()
        local nextId = NgBattleDataManager.dungeonId + 1
        -- 如果 cfg 中沒有 nextId，代表沒有下一關
        disableNextIf(not cfg[nextId])
    end
    
    -- 根據戰鬥結果及類型，顯示勝利或失敗畫面
    local langType = CCUserDefault:sharedUserDefault():getIntegerForKey("LanguageType")
    local isWin = NgBattleDataManager.battleResult == CONST.FIGHT_RESULT.WIN
    local isWorldOrSingle = (bt == CONST.SCENE_TYPE.WORLD_BOSS or bt == CONST.SCENE_TYPE.SINGLE_BOSS or bt == CONST.SCENE_TYPE.SINGLE_BOSS_SIM)
    
    if isWin or isWorldOrSingle then
        -- 顯示「勝利」節點，隱藏「敗北」與「引導失敗」節點
        NodeHelper:setNodesVisible(container, {
            mWinNode = true,
            mGuideLoseNode = false,
            mLoseNode = false,
        })
        
        -- 播放勝利 Spine 動畫
        ALFManager:loadSpineTask("Spine/NGUI/", "NGUI_13_BattleWin", 30, function()
            local spineNode = container:getVarNode("mSpineWin")
            local spine1 = SpineContainer:create("Spine/NGUI", "NGUI_13_BattleWin")
            spine1:setSkin(langType)
            spine1:runAnimation(1, "victory1", 0)
            
            local sToNode1 = tolua.cast(spine1, "CCNode")
            spineNode:addChild(sToNode1)
            
            local seq = CCArray:create()
            seq:addObject(CCDelayTime:create(0))
            seq:addObject(CCCallFunc:create(function()
                spine1:runAnimation(1, "victory1", 0)
                spine1:addAnimation(1, "victory2", true)
                SoundManager:getInstance():playMusic("BattleBossWin.mp3", false)
            end))
            spineNode:runAction(CCSequence:create(seq))
        end)
        
        -- 處理經驗值顯示：從 rewardItemInfo 中移除經驗道具，並更新文字與進度
        local getExp = 0
        for i = 1, #rewardItemInfo do
            if rewardItemInfo[i] and rewardItemInfo[i].itemId == 1004 then
                getExp = rewardItemInfo[i].count
                table.remove(rewardItemInfo, i)
                break
            end
        end
        local mExpNum = container:getVarLabelTTF("mRewardExpNum")
        mExpNum:setString(common:getLanguageString("@RewardExp", tostring(getExp)))
        self:updateExp(container, getExp)
        
        -- 顯示玩家頭像
        local roleIconCfg = ConfigManager.getRoleIconCfg()
        local trueIcon = GameConfig.headIconNew or UserInfo.playerInfo.headIcon
        if roleIconCfg[trueIcon] then
            NodeHelper:setSpriteImage(container, { mHeadIcon = roleIconCfg[trueIcon].MainPageIcon })
        else
            local icon = common:getPlayeIcon(UserInfo.roleInfo.prof, trueIcon)
            NodeHelper:setSpriteImage(container, { mHeadIcon = icon })
        end
        
        -- 顯示 MVP 角色 Spine（若無 Spine 則改播 MP4）
        local mvpIndex = NgBattleDataManager.playerMvpIndex
        local mvpData = NgBattleDataManager.battleMineCharacter[mvpIndex]
        local mvpID = (mvpData and mvpData.otherData[CONST.OTHER_DATA.ITEM_ID]) or 1
        
        local spineNodeMvp = container:getVarNode("mSpine")
        local roleInfo = UserMercenaryManager:getUserMercenaryByItemId(mvpID)
        local spineName
        
        if roleInfo.skinId > 0 then
            spineName = "NG2D_" .. string.format("%05d", roleInfo.skinId)
            if not NodeHelper:isFileExist("Spine/NG2D/" .. spineName .. ".skel") then
                -- 若找不到 Spine 檔，就播放 MP4 動畫
                self:playMovie(container, roleInfo.skinId)
                return
            end
        else
            spineName = "NG2D_" .. string.format("%02d", mvpID)
        end
        
        local spineMvp = SpineContainer:create("NG2D", spineName)
        spineMvp:runAnimation(1, "animation", -1)
        local sToNodeMvp = tolua.cast(spineMvp, "CCNode")
        spineNodeMvp:setScale(NodeHelper:getScaleProportion())
        spineNodeMvp:addChild(sToNodeMvp)
        
        -- 若有獎勵道具，且非 PVP / PUZZLE 場景，就初始化滾動列表顯示
        if #rewardItemInfo > 0 and bt ~= CONST.SCENE_TYPE.PVP and bt ~= CONST.SCENE_TYPE.PUZZLE then
            self:initScroll(container)
        end
        
        -- 播放 MVP 語音
        NodeHelper:playEffect(mvpID .. "_31.mp3")
        
        -- 判斷要顯示哪種「勝利」布局節點
        local hideNormalMap = {
            [CONST.SCENE_TYPE.PVP]    = true,
            [CONST.SCENE_TYPE.MULTI]  = true,
            [CONST.SCENE_TYPE.PUZZLE] = true,
            [CONST.SCENE_TYPE.SINGLE_BOSS] = true,
            [CONST.SCENE_TYPE.SINGLE_BOSS_SIM] = true,
            [CONST.SCENE_TYPE.CYCLE_TOWER] = true
        }
        local isShowNormal = not hideNormalMap[bt]
        
        NodeHelper:setNodesVisible(container, {
            mNormalWinNode    = isShowNormal,
            mSingleBtn        = hideNormalMap[bt],
            mPvpWinNode       = (bt == CONST.SCENE_TYPE.PVP),
            mDungeonWinNode   = (bt == CONST.SCENE_TYPE.MULTI),
            mTowerWinNode     = (#rewardItemInfo == 0 and (bt == CONST.SCENE_TYPE.SEASON_TOWER or bt == CONST.SCENE_TYPE.LIMIT_TOWER)),
            mFearTowerWinNode = (#rewardItemInfo == 0 and bt == CONST.SCENE_TYPE.FEAR_TOWER),
            mPuzzleWinNode    = (bt == CONST.SCENE_TYPE.PUZZLE),
        })
        
        -- 如果是 PVP，顯示排名資訊
        if bt == CONST.SCENE_TYPE.PVP then
            local lastTimeRank, currentRank = ArenaPage_getRank()
            currentRank = math.min(lastTimeRank, currentRank)
            
            local function showRank(idx, rankValue)
                local bgSprite = container:getVarSprite("mRankBg_" .. idx)
                local labelKey = "mRankLabel_" .. idx
                if rankValue <= 3 then
                    bgSprite:setTexture(GameConfig.ArenaRankingIcon[rankValue])
                    NodeHelper:setStringForLabel(container, { [labelKey] = rankValue })
                    NodeHelper:setNodesVisible(container, { [labelKey] = false })
                else
                    bgSprite:setTexture(GameConfig.ArenaRankingIcon[4])
                    NodeHelper:setStringForLabel(container, { [labelKey] = rankValue })
                    NodeHelper:setNodesVisible(container, { [labelKey] = true })
                end
            end
            
            showRank(1, lastTimeRank)
            showRank(2, currentRank)
        end
        
    else
        -- 失敗或新手引導
        local GuideManager = require("Guide.GuideManager")
        if GuideManager.isInGuide and bt == CONST.SCENE_TYPE.GUIDE then
            -- 新手教學中但失敗：只顯示引導失敗畫面
            NodeHelper:setNodesVisible(container, {
                mWinNode = false,
                mGuideLoseNode = true,
                mLoseNode = false,
            })
        else
            -- 一般失敗畫面
            NodeHelper:setNodesVisible(container, {
                mWinNode = false,
                mGuideLoseNode = false,
                mLoseNode = true,
            })
            
            -- 播放失敗 Spine 動畫
            ALFManager:loadSpineTask("Spine/NGUI/", "NGUI_13_BattleLose", 30, function()
                local spineNode = container:getVarNode("mSpineLose")
                local spine1 = SpineContainer:create("Spine/NGUI", "NGUI_13_BattleLose")
                spine1:setSkin(langType)
                spine1:runAnimation(1, "defeated1", 0)
                
                local sToNode1 = tolua.cast(spine1, "CCNode")
                spineNode:addChild(sToNode1)
                
                local seq = CCArray:create()
                seq:addObject(CCDelayTime:create(0))
                seq:addObject(CCCallFunc:create(function()
                    spine1:runAnimation(1, "defeated1", 0)
                    spine1:addAnimation(1, "defeated2", true)
                end))
                spineNode:runAction(CCSequence:create(seq))
                SoundManager:getInstance():playMusic("BattleBossLose.mp3", false)
            end)
        end
    end
    
    -- 通用後續操作
    UserInfo.sync()
    PageManager.setAllNotice()
    
    -- 新手教學頁面註冊
    local GuideManager = require("Guide.GuideManager")
    GuideManager.PageContainerRef["NgBattleResultPage"] = container
    if GuideManager.isInGuide then
        GuideManager.forceNextNewbieGuide()
    else
        if bt == CONST.SCENE_TYPE.BOSS then -- 只在主線通關檢查
            -- 檢查準備觸發新手教學, 強制點擊返回
            local isTrigger = false
            isTrigger = GuideManager.isTriggerOtherGuide(GuideManager.guideType.DUNGEON) or isTrigger
            isTrigger = GuideManager.isTriggerOtherGuide(GuideManager.guideType.MISSION) or isTrigger
            isTrigger = GuideManager.isTriggerOtherGuide(GuideManager.guideType.SUMMON) or isTrigger
            isTrigger = GuideManager.isTriggerOtherGuide(GuideManager.guideType.RUNE) or isTrigger
            isTrigger = GuideManager.isTriggerOtherGuide(GuideManager.guideType.ARENA) or isTrigger
            isTrigger = GuideManager.isTriggerOtherGuide(GuideManager.guideType.BOUNTY) or isTrigger
            isTrigger = GuideManager.isTriggerOtherGuide(GuideManager.guideType.FUSION) or isTrigger
            isTrigger = GuideManager.isTriggerOtherGuide(GuideManager.guideType.GRAIL) or isTrigger
            isTrigger = GuideManager.isTriggerOtherGuide(GuideManager.guideType.DUNGEON_2) or isTrigger
            isTrigger = GuideManager.isTriggerOtherGuide(GuideManager.guideType.ANCIENT_WEAPON) or isTrigger
            isTrigger = GuideManager.isTriggerOtherGuide(GuideManager.guideType.SECRET_MESSAGE) or isTrigger
            isTrigger = GuideManager.isTriggerOtherGuide(GuideManager.guideType.FAST_BATTLE) or isTrigger
            if isTrigger then
                local lightNode = ScriptContentBase:create("guideBtnItem")
                lightNode:setTag(1001)
                local handNode = ScriptContentBase:create("A_Shou5")
                handNode:setTag(1002)
                local winBtn = container:getVarMenuItem("mWinBtn")
                if winBtn then
                    local parent = winBtn:getParent():getParent()
                    local parentNode = tolua.cast(parent, "CCNode")
                    parentNode:removeChildByTag(1001, true)
                    parentNode:removeChildByTag(1002, true)
                    parentNode:addChild(lightNode)
                    parentNode:addChild(handNode)
                end
            end
        end
    end
    
    -- 最後，如果是 PVP 或 PUZZLE，跳出獎勵彈窗
    if bt == CONST.SCENE_TYPE.PVP and #rewardItemInfo > 0 then
        local CommonRewardPage = require("CommPop.CommItemReceivePage")
        CommonRewardPage:setData(rewardItemInfo, common:getLanguageString("@ItemObtainded"), nil)
        PageManager.pushPage("CommPop.CommItemReceivePage")
    elseif bt == CONST.SCENE_TYPE.PUZZLE and #rewardItemInfo > 0 then
        local puzzlePage = require("PuzzlePage")
        puzzlePage:setReward(rewardItemInfo)
    end
end


function NgBattleResultPage:initScroll(container)
    NodeHelper:initScrollView(container, "mBattleRewardItem", #rewardItemInfo)
    container.scrollview = container:getVarScrollView("mBattleRewardItem")
    NodeHelper:clearScrollView(container)
    local size = #rewardItemInfo

    NodeHelper:buildScrollViewHorizontal(container, size, "CommonRewardContent.ccbi", NgBattleResultPage.onFunctionCall, 0)

    if size < 4 then
        local node = container:getVarNode("mBattleRewardItem")
        local x = node:getPositionX()
        node:setPositionX(x + (544 - size * 136) / 2)
        node:setTouchEnabled(false)
    end
end

function NgBattleResultPage.onFunctionCall(eventName, container)
    if eventName == "luaRefreshItemView" then
        local contentId = container:getItemDate().mID
        local i = contentId
        -- 當前的index
        local node = container:getVarNode("mItem")
        local itemNode = ScriptContentBase:create("GoodsItem.ccbi")
        local ResManager = require "ResManagerForLua"
        local resInfo = ResManagerForLua:getResInfoByTypeAndId(rewardItemInfo[i].type, rewardItemInfo[i].itemId, rewardItemInfo[i].count)
        NodeHelper:setStringForLabel(itemNode, { mName = "" })
        local lb2Str = {
            mNumber = GameUtil:formatNumber(rewardItemInfo[i].count)
        }
        local showName = ""
        if rewardItemInfo[i].type == 40000 then
            for i = 1, 6 do
                NodeHelper:setNodesVisible(itemNode, { ["mStar" .. i] = i == resInfo.star })
            end
        end
        NodeHelper:setNodesVisible(itemNode, { mNumber = rewardItemInfo[i].type ~= 40000, mStarNode = rewardItemInfo[i].type == 40000 })
        NodeHelper:setStringForLabel(itemNode, lb2Str)
        NodeHelper:setSpriteImage(itemNode, { mPic = resInfo.icon }, { mPic = GameConfig.EquipmentIconScale })
        NodeHelper:setQualityFrames(itemNode, { mHand = resInfo.quality })

        node:addChild(itemNode)
        itemNode:registerFunctionHandler(NgBattleResultPage.onFunctionCall)
        itemNode.id = contentId
        itemNode:release()
    elseif eventName == "onHand" then
        -- 點擊物品跳說明
        local id = container.id
        GameUtil:showTip(container:getVarNode("mHand"), rewardItemInfo[id])
        return
    end
end

function NgBattleResultPage:onTestLog()
    PageManager.pushPage("BattleLogPage")
end

function NgBattleResultPage:onTestDps()
    PageManager.pushPage("BattleLogDpsPage")
end

function NgBattleResultPage:onDetail()
    PageManager.pushPage("NgBattleDetailPage")
end
function NgBattleResultPage:onUpgradeEquipment()
    registerScriptPage("EquipIntegrationPage")
    EquipIntegrationPage_CloseHandler(MainFrame_onMainPageBtn())
    EquipIntegrationPage_SetCurrentPageIndex(true)
    PageManager.changePage("EquipIntegrationPage")
    PageManager.popPage(thisPageName)
end
function NgBattleResultPage:onShopping()
    pageManager.changePage("ShopControlPage")
    PageManager.popPage(thisPageName)
end
function NgBattleResultPage:onHeroPage()
    MainFrame_onLeaderPageBtn()
    local mainContainer = tolua.cast(MainFrame:getInstance(), "CCBContainer")
    local mainButtons = mainContainer:getCCNodeFromCCB("mMainFrameButtons")
    mainButtons:setVisible(true)
    PageManager.popPage(thisPageName)
end
function NgBattleResultPage:onShopPage()
    PageManager.changePage("ShopControlPage")
    local mainContainer = tolua.cast(MainFrame:getInstance(), "CCBContainer")
    local mainButtons = mainContainer:getCCNodeFromCCB("mMainFrameButtons")
    mainButtons:setVisible(true)
    resetMenu("mMainPageBtn", true)
    PageManager.popPage(thisPageName)
end
function NgBattleResultPage:onBountyPage()
    PageManager.changePage("MercenaryExpeditionPage")
    local mainContainer = tolua.cast(MainFrame:getInstance(), "CCBContainer")
    local mainButtons = mainContainer:getCCNodeFromCCB("mMainFrameButtons")
    mainButtons:setVisible(true)
    resetMenu("mMainPageBtn", true)
    PageManager.popPage(thisPageName)
end
function NgBattleResultPage:onMercenaryCulture()
    if UserInfo.roleInfo.level < GameConfig.LevelLimit.MecenaryOpenLevel then
        MessageBoxPage:Msg_Box("@MercenaryLevelNotEnough")
        return
    else
        PageJumpMange._IsPageJump = true
        PageJumpMange._CurJumpCfgInfo = PageJumpMange._JumpCfg[25]
        PageManager.changePage("EquipmentPage")
    end
    pageManager.popPage(thisPageName)
end

function NgBattleResultPage:updateExp(container, getExp)
    local mExpBar = container:getVarScale9Sprite("mExpBar")
    local mExpTxt = container:getVarLabelTTF("mExpTxt")

    local currentExp = UserInfo.roleInfo.exp-- + getExp
    local roleExpCfg = ConfigManager.getRoleLevelExpCfg()
    local percent = 0
    local nextLevelExp = 0
    local curLevel = UserInfo.roleInfo.level
    if currentExp ~= nil and roleExpCfg ~= nil then
        nextLevelExp = roleExpCfg[UserInfo.roleInfo.level] and roleExpCfg[UserInfo.roleInfo.level]["exp"] or 0
        if nextLevelExp == 0 then   -- 表格沒有資料
            percent = 1.0
            nextLevelExp = 99999999
        else
            percent = math.min(1, currentExp / nextLevelExp)
        end
        -- 重設9宮格點位(避免數值太小時變形)
        mExpBar:setInsetLeft((500 * percent > 9 * 2) and 9 or (500 * percent / 2))
        mExpBar:setInsetRight((500 * percent > 9 * 2) and 9 or (500 * percent / 2))

        mExpBar:setContentSize(CCSize(500 * percent, 21))
        mExpTxt:setString(currentExp .. "/" .. nextLevelExp)
    end
    -- 等級顯示
    local mLevel = container:getVarLabelTTF("mLevel")
    mLevel:setString("Lv. " .. curLevel)
end

function NgBattleResultPage:onExit(container)
    self:resetData()
    self:closeMovie(container)
end

function NgBattleResultPage:onWinBtn(container)
    NgBattleDataManager_clearBattleData()
    local nextShowType = NgBattleResultManager.playType.NONE
    if NgBattleDataManager.battleType == CONST.SCENE_TYPE.BOSS then
        NgBattleResultManager.isNextStage = false
        nextShowType = NgBattleResultManager_playNextResult()
    elseif NgBattleDataManager.battleType == CONST.SCENE_TYPE.MULTI then
        PageJumpMange.JumpPageById(48)
    elseif NgBattleDataManager.battleType == CONST.SCENE_TYPE.PVP then
        PageJumpMange.JumpPageById(21)
    elseif NgBattleDataManager.battleType == CONST.SCENE_TYPE.WORLD_BOSS then
        PageJumpMange.JumpPageById(45)
    elseif NgBattleDataManager.battleType == CONST.SCENE_TYPE.DUNGEON then
        PageJumpMange.JumpPageById(49)
    elseif NgBattleDataManager.battleType == CONST.SCENE_TYPE.CYCLE_TOWER then
         if (NgBattleDataManager.battleResult == CONST.FIGHT_RESULT.WIN) then
            NgBattleResultManager.showMainStory = NgFightSceneHelper:StorySync(2)--1:戰鬥前 2:戰鬥後
            pageManager.popPage(thisPageName)
            if NgBattleResultManager.showMainStory then return end
         end
         PageJumpMange.JumpPageById(51)
    elseif NgBattleDataManager.battleType == CONST.SCENE_TYPE.SINGLE_BOSS or
           NgBattleDataManager.battleType == CONST.SCENE_TYPE.SINGLE_BOSS_SIM then
           PageJumpMange.JumpPageById(52)
     elseif NgBattleDataManager.battleType == CONST.SCENE_TYPE.SEASON_TOWER then     
        PageJumpMange.JumpPageById(53)
        needNewTowerData = false
     elseif NgBattleDataManager.battleType == CONST.SCENE_TYPE.LIMIT_TOWER then
        needNewTowerData = false
        local TabName = {[2] = {"Fire","Water","Wood","Light_and_Dark"},
                         [3] = {"Shield","Sword","Heal","Magic"}  
        }
        local limitType = NgBattleDataManager.limitType
        local tabIndex, subIndex

        if limitType < 10 then
            tabIndex = 2
            subIndex = limitType
            PageJumpMange._JumpCfg[55]._ThirdFunc = "onType2"
        else
            tabIndex = 3
            subIndex = limitType - 10
            PageJumpMange._JumpCfg[55]._ThirdFunc = "onType3"
        end

        local subPage = TabName[tabIndex][subIndex]
        require("TowerLimit.TowerLimitPage"):setEntrySubPage(subPage)
        PageJumpMange.JumpPageById(55)
     elseif NgBattleDataManager.battleType == CONST.SCENE_TYPE.FEAR_TOWER then
        PageJumpMange.JumpPageById(56)
     elseif NgBattleDataManager.battleType == CONST.SCENE_TYPE.PUZZLE then
       local PageJumpMange = require("PageJumpMange")
       PageJumpMange.JumpPageById(54)
       local puzzlePage = require("PuzzlePage")
       puzzlePage:setPassState(true)
    else
        require("Battle.NgBattlePage")
        NgBattlePageInfo_restartAfk(NgBattleDataManager.battlePageContainer)
    end
    
    PageManager.popPage(thisPageName)
end
function NgBattleResultPage_onGuideWinBtn(container)
    NgBattleResultPage:onWinBtn(container)
end
function NgBattleResultPage:onNextBtn(container)
    NgBattleDataManager_clearBattleData()
    local msg = Battle_pb.NewBattleFormation()
    msg.type = CONST.FORMATION_PROTO_TYPE.REQUEST_ENEMY
    msg.battleType = NgBattleDataManager.battleType
    if NgBattleDataManager.battleType == CONST.SCENE_TYPE.BOSS then
        NgBattleResultManager.isNextStage = true
        nextShowType = NgBattleResultManager_playNextResult()
        return
    elseif NgBattleDataManager.battleType == CONST.SCENE_TYPE.SEASON_TOWER then
        msg.mapId = tostring(NgBattleDataManager.TowerId + 1)
    elseif NgBattleDataManager.battleType == CONST.SCENE_TYPE.FEAR_TOWER then
        msg.mapId = tostring(NgBattleDataManager.TowerId)
    elseif NgBattleDataManager.battleType == CONST.SCENE_TYPE.LIMIT_TOWER then
        msg.limitType = NgBattleDataManager.limitType
        msg.mapId = tostring(NgBattleDataManager.TowerId + 1)
    elseif NgBattleDataManager.battleType == CONST.SCENE_TYPE.DUNGEON then
        msg.mapId = tostring(NgBattleDataManager.dungeonId + 1)
    end
    common:sendPacket(HP_pb.BATTLE_FORMATION_C, msg, true)
end

function NgBattleResultPage:onLoseBtn(container)
    NgBattleDataManager_clearBattleData()
    if NgBattleDataManager.battleType == CONST.SCENE_TYPE.BOSS then
        require("Battle.NgBattlePage")
        NgBattlePageInfo_restartAfk(NgBattleDataManager.battlePageContainer)
        NgBattleResultManager_playNextResult(true)
    elseif NgBattleDataManager.battleType == CONST.SCENE_TYPE.MULTI then

        PageJumpMange.JumpPageById(48)
    elseif NgBattleDataManager.battleType == CONST.SCENE_TYPE.PVP then

        PageJumpMange.JumpPageById(21)
    elseif NgBattleDataManager.battleType == CONST.SCENE_TYPE.WORLD_BOSS then

        PageJumpMange.JumpPageById(45)
    elseif NgBattleDataManager.battleType == CONST.SCENE_TYPE.DUNGEON then

        PageJumpMange.JumpPageById(49)
    elseif NgBattleDataManager.battleType == CONST.SCENE_TYPE.CYCLE_TOWER then

        PageJumpMange.JumpPageById(51)
    elseif NgBattleDataManager.battleType == CONST.SCENE_TYPE.SEASON_TOWER then

        PageJumpMange.JumpPageById(53)
    elseif NgBattleDataManager.battleType == CONST.SCENE_TYPE.LIMIT_TOWER then
        local TabName = {[2] = {"Fire","Water","Wood","Light_and_Dark"},
                         [3] = {"Shield","Sword","Heal","Magic"}  
        }
        local limitType = NgBattleDataManager.limitType
        local tabIndex, subIndex

        if limitType < 10 then
            tabIndex = 2
            subIndex = limitType
            PageJumpMange._JumpCfg[55]._ThirdFunc = "onType2"
        else
            tabIndex = 3
            subIndex = limitType - 10
            PageJumpMange._JumpCfg[55]._ThirdFunc = "onType3"
        end

        local subPage = TabName[tabIndex][subIndex]
        require("TowerLimit.TowerLimitPage"):setEntrySubPage(subPage)
        PageJumpMange.JumpPageById(55)
    elseif NgBattleDataManager.battleType == CONST.SCENE_TYPE.FEAR_TOWER then
        PageJumpMange.JumpPageById(56)
    elseif NgBattleDataManager.battleType == CONST.SCENE_TYPE.PUZZLE then
        PageJumpMange.JumpPageById(54)
    elseif NgBattleDataManager.battleType == CONST.SCENE_TYPE.SINGLE_BOSS or
           NgBattleDataManager.battleType == CONST.SCENE_TYPE.SINGLE_BOSS_SIM then

        PageJumpMange.JumpPageById(52)
    else
        require("Battle.NgBattlePage")
        NgBattlePageInfo_restartAfk(NgBattleDataManager.battlePageContainer)
    end
    PageManager.popPage(thisPageName)
end

function NgBattleResultPage:setAward(awardInfo)
    rewardItemInfo = awardInfo
end

-- 播放mp4
function NgBattleResultPage:playMovie(container, skinId)
    -- 播放影片
    if skinId ~= 0 then
        local fileName = "Hero/Hero" .. string.format("%05d", skinId)
        local isFileExist =  NodeHelper:isFileExist("Video/" .. fileName .. ".mp4")
        if isFileExist then
            GamePrecedure:getInstance():playMovie(thisPageName, fileName, 1, 0)
            NodeHelper:setNodesVisible(container, { mSpine = false, mMask = false })
        end
    end
end
-- 關閉影片
function NgBattleResultPage:closeMovie(container)
    CCLuaLog("NgBattleResultPage:closeMovie")
    NodeHelper:setNodesVisible(container, { mSpine = true, mMask = true })
    GamePrecedure:getInstance():closeMovie(thisPageName)
end
function NgBattleResultPage:onReceivePacket(container)
    local opcode = container:getRecPacketOpcode();
	local msgBuff = container:getRecPacketBuffer();
    if opcode == HP_pb.BATTLE_FORMATION_S then
        local msg = Battle_pb.NewBattleFormation()
        msg:ParseFromString(msgBuff)
        if msg.type == NewBattleConst.FORMATION_PROTO_TYPE.REQUEST_ENEMY then
            local battlePage = require("NgBattlePage")
            resetMenu("mBattlePageBtn", true)
            require("NgBattleDataManager")
            NgBattleDataManager_setDungeonId(tonumber(msg.mapId))
            PageManager.changePage("NgBattlePage")
            if NgBattleDataManager.battleType == CONST.SCENE_TYPE.SEASON_TOWER then
                CONST.IS_BATTLE_NEXT = true
                PageManager.pushPage("TransScenePopUp")
                battlePage:onSeasonTower(selfContainer, msg.resultInfo, msg.battleId, msg.battleType, tonumber(msg.mapId))
            elseif NgBattleDataManager.battleType == CONST.SCENE_TYPE.FEAR_TOWER then
                battlePage:onFearTower(selfContainer, msg.resultInfo, msg.battleId, msg.battleType, tonumber(msg.mapId))
            elseif NgBattleDataManager.battleType == CONST.SCENE_TYPE.LIMIT_TOWER then
                CONST.IS_BATTLE_NEXT = true
                PageManager.pushPage("TransScenePopUp")
                battlePage:onLimitTower(selfContainer, msg.resultInfo, msg.battleId, msg.battleType, tonumber(msg.mapId),NgBattleDataManager.limitType)
            elseif NgBattleDataManager.battleType == CONST.SCENE_TYPE.DUNGEON then
               CONST.IS_BATTLE_NEXT = true
               PageManager.pushPage("TransScenePopUp")
               battlePage:onDungeon(selfContainer, msg.resultInfo, msg.battleId, msg.battleType, tonumber(msg.mapId))
            end
             PageManager.popPage(thisPageName)
        end
    end
end
function NgBattleResultPage:registerPacket(container)
    for key, opcode in pairs(opcodes) do
        if string.sub(key, -1) == "S" then
            container:registerPacket(opcode)
        end
    end
end

return NgBattleResultPage