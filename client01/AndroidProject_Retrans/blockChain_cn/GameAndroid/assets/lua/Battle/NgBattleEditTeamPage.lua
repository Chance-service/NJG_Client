local thisPageName = "NgBattleEditTeamPage"
local NgFightSceneHelper = require("Battle.NgFightSceneHelper")
local UserMercenaryManager = require("UserMercenaryManager")
local CONST = require("Battle.NewBattleConst")
local NgHeadIconItem_Small = require("NgHeadIconItem_Small")
local HP_pb = require("HP_pb")
local EventDataMgr = require("Event001DataMgr")
require("Battle.NewBattleUtil")
require("Battle.NgBattleDataManager")
local NgBattleEditTeamPage = { }

local option = {
    ccbiFile = "BattlePageEditTeam.ccbi",
    handlerMap = {
        onFilter = "onFilter",
        onReturn = "onReturn",
        onConfirm = "onConfirm",
        onTeamInfo = "onTeamInfo",
        onExitInfo = "onExitInfo"
    },
    opcodes = {
        EDIT_FORMATION_S = HP_pb.EDIT_FORMATION_S,
    }
}
local MAX_TEAM_NUM = 5

local FILTER_WIDTH = 500
local FILTER_OPEN_HEIGHT = 142
local FILTER_CLOSE_HEIGHT = 74
local filterOpenSize = CCSize(FILTER_WIDTH, FILTER_OPEN_HEIGHT)
local filterCloseSize = CCSize(FILTER_WIDTH, FILTER_CLOSE_HEIGHT)
local HEAD_SCALE = 0.91
local headIconSize = CCSize(139 * HEAD_SCALE, 139 * HEAD_SCALE)

local allTeamContent = {}

local pageContainer = nil
local nowTeamRoleIds = { }  -- 當前選擇的隊伍roleId
local allSelectNode = { }   -- 選擇框spine node
local selectId = 0          -- 選擇中的位置id

local currentElement = 0
local currentClass = 0

local items = { }
local roleSortInfos = { }
local mInfos = nil
local heroCfg = ConfigManager.getNewHeroCfg()

local MonsterInfoContent = {ccbiFile = "ChapterMonsterList_Content.ccbi"}

for i = 1, MAX_TEAM_NUM do
    option.handlerMap["onHero" .. i] = "onHero"
end
for i = 0, 5 do
    option.handlerMap["onElement" .. i] = "onElement"
end
for i = 0, 4 do
    option.handlerMap["onClass" .. i] = "onClass"
end
-- 在指定位置加入隊伍成員，並更新畫面與選擇狀態
local function addMember(index, node)
    local teamCount = NgBattleEditTeamPage:getTeamCount(nowTeamRoleIds)-- - table.count(nowTeamRoleIds, 0)
    if NgBattleDataManager.battleType == CONST.SCENE_TYPE.PUZZLE then
        if teamCount >= NgBattleEditTeamPage.limitGirlCount then
        MessageBoxPage:Msg_Box(common:getLanguageString("@PuzzleBattle_LimitPeopleCount",NgBattleEditTeamPage.limitGirlCount))
            return
        end
    end
    nowTeamRoleIds[index] = node.roleId
    local parentNode = pageContainer:getVarNode("mSpine" .. index)
    parentNode:removeAllChildrenWithCleanup(true)
    local info = mInfos[node.roleId]
    local spinePath, spineName = unpack(common:split(heroCfg[info.itemId].Spine, ","))
    if info.skinId > 0 then
        spineName = string.format("NG_%05d", info.skinId)
    else
        spineName = spineName .. string.format("%03d", 0)
    end
    local spine = SpineContainer:create(spinePath, spineName)
    spine:runAnimation(1, CONST.ANI_ACT.WAIT, -1)
    local sNode = tolua.cast(spine, "CCNode")
    parentNode:addChild(sNode)
    parentNode:setVisible(true)
    NgHeadIconItem_Small:setIsChoose(node, true)
end
function table.count(tbl, value)
    local count = 0
    for _, v in pairs(tbl) do
        if v == value then
            count = count + 1
        end
    end
    return count
end
function NgBattleEditTeamPage.onHeadCallback(itemNode)
    if NgBattleDataManager.battleType == CONST.SCENE_TYPE.PUZZLE then
        for _, info in pairs(NgBattleEditTeamPage.heroLimit) do
            if info.id and info.id == itemNode.itemId and info.pos ~= 0 then
                MessageBoxPage:Msg_Box(common:getLanguageString("@PuzzleBattle_LimitPos"))
                return
            end
        end
    end

    -- 移除指定位置的隊伍成員，並更新畫面與選擇狀態
    local function removeMember(index, node)
        local parentNode = pageContainer:getVarNode("mSpine" .. index)
        parentNode:removeAllChildrenWithCleanup(true)
        parentNode:setVisible(false)
        NgHeadIconItem_Small:setIsChoose(node, false)
        nowTeamRoleIds[index] = 0
    end

    -- 交換或搬移隊伍成員
  local function swapMembers(index1, index2)
    local parent1 = pageContainer:getVarNode("mSpine" .. index1)
    local parent2 = pageContainer:getVarNode("mSpine" .. index2)

    -- 取得節點內容（這邊不要再調用任何 child 方法）
    local children1 = parent1:getChildren()
    local children2 = parent2:getChildren()

    local node1 = children1 and children1:count() > 0 and children1:objectAtIndex(0)
    local node2 = children2 and children2:count() > 0 and children2:objectAtIndex(0)

    -- 先移除兩邊
    parent1:removeAllChildrenWithCleanup(false)
    parent2:removeAllChildrenWithCleanup(false)

    -- 重新加入
    if node1 and not tolua.isnull(node1) then
        parent2:addChild(node1)
        parent2:setVisible(true)
    end

    if node2 and not tolua.isnull(node2) then
        parent1:addChild(node2)
        parent1:setVisible(true)
    end

    -- 交換資料
    nowTeamRoleIds[index1], nowTeamRoleIds[index2] = nowTeamRoleIds[index2], nowTeamRoleIds[index1]
end


    -- 清除指定位置舊的選擇狀態
    local function clearOldSelection(slot)
        for _, v in pairs(items) do
            if v.handler.roleId == nowTeamRoleIds[slot] then
                NgHeadIconItem_Small:setIsChoose(v.handler, false)
            end
        end
    end

    -- 最後統一重置選擇狀態並更新戰鬥/增益資訊
    local function finalize()
        selectId = 0
        NgBattleEditTeamPage:setFightAndBuff()
    end

    -- 有選擇位置的情況
    if selectId > 0 and selectId <= MAX_TEAM_NUM then
        allSelectNode[selectId]:setVisible(false)

        for i = 1, MAX_TEAM_NUM do
            if nowTeamRoleIds[i] == itemNode.roleId then
                if i == selectId then
                    removeMember(i, itemNode)
                else
                    swapMembers(selectId, i)
                end
                finalize()
                return
            end
        end

        -- 加入新成員
        clearOldSelection(selectId)
        addMember(selectId, itemNode)
        finalize()
    else
        -- 沒有選擇位置的備援邏輯
        for i = 1, MAX_TEAM_NUM do
            if nowTeamRoleIds[i] == itemNode.roleId then
                removeMember(i, itemNode)
                NgBattleEditTeamPage:setFightAndBuff()
                return
            end
        end

        for i = 1, MAX_TEAM_NUM do
            if not nowTeamRoleIds[i] or nowTeamRoleIds[i] == 0 then
                addMember(i, itemNode)
                NgBattleEditTeamPage:setFightAndBuff()
                return
            end
        end
        local teamCount = NgBattleEditTeamPage:getTeamCount(nowTeamRoleIds)
        if selectId == 0 and teamCount < MAX_TEAM_NUM then
            for i = 1, MAX_TEAM_NUM do
                if not nowTeamRoleIds[i] or nowTeamRoleIds[i] == 0 then
                    selectId = i
                    NgBattleEditTeamPage.onHeadCallback(itemNode)
                    break
                end
            end
        else
            MessageBoxPage:Msg_Box_Lan("@OrgTeamFull")
        end
    end
end



function NgBattleEditTeamPage:setFightAndBuff()
    NgBattleEditTeamPage:calTeamFight()
    NgBattleEditTeamPage:refreshTeamBuff()
end
function NgBattleEditTeamPage:calTeamFight()
    local nAllFight = 0  
    for _,v in pairs(nowTeamRoleIds) do
        --local info = mInfosDisorder[groupInfos.roleIds[i]]
        local info = UserMercenaryManager:getUserMercenaryById(v)
        if info then
            nAllFight = nAllFight + info.fight
        end
    end
    NodeHelper:setStringForLabel(pageContainer,{mSelfFightingNum = nAllFight})
    if not NgBattleDataManager.battleType == CONST.SCENE_TYPE.EDIT_DEFEND_TEAM then
         UserInfo.roleInfo.marsterFight = nAllFight
    end
end
function NgBattleEditTeamPage:refreshTeamBuff()
    local elementTable = { [1] = 0, [2] = 0, [3] = 0, [4] = 0, [5] = 0 }
    local buffTable = { }
    local teamBuffCfg = ConfigManager.getTeamBuffCfg()
    for _, id in pairs(nowTeamRoleIds) do
        local roleInfo = UserMercenaryManager:getUserMercenaryById(id)
        if roleInfo then
            local heroCfg = ConfigManager.getNewHeroCfg()[roleInfo.itemId]
            local element = roleInfo.elements
            elementTable[element] = elementTable[element] + 1
        end
    end
    for element = 1, #elementTable do
        if elementTable[element] > 0 then
            for id = 1, #teamBuffCfg do
                if teamBuffCfg[id].Attr == element and teamBuffCfg[id].Num == elementTable[element] then
                    local buffs = common:split(teamBuffCfg[id].Buff, ",")
                    for idx = 1, #buffs do
                        local buffId, _type, num = unpack(common:split(buffs[idx], "_"))
                        buffId = tonumber(buffId)
                        _type = tonumber(_type)
                        num = tonumber(num)
                        buffTable[buffId] = buffTable[buffId] or { }
                        buffTable[buffId][_type] = buffTable[buffId][_type] and buffTable[buffId][_type] + num or num
                    end
                    break
                end
            end
        end
    end
    local sortTable = { }
    for buffId, v in pairs(buffTable) do
        table.insert(sortTable, { buffId = buffId, data = v })
    end
    table.sort(sortTable, function(data1, data2)
        if not data1 or not data2 then
            return false
        end
        if data1.buffId ~= data2.buffId then
            return data1.buffId < data2.buffId
        end
        return false
    end)
    local str = ""
    local count = 1
    for i = 1, #sortTable do
        for _type, num in pairs(sortTable[i].data) do
            local str0 = ""
            if count ~= 1 then
                str0 = ", "
            else
                str = ""
            end
            local str1 = common:getLanguageString("@AttrName_" .. sortTable[i].buffId)
            local str2 = ""
            if _type == 1 then
                num = num / 100
                str2 = "%"
            end
            str = str .. str0 .. str1 .. " +" .. num .. str2
            count = count + 1
        end
    end
    local imgStr = "TeamBuff_"
    local bonusCount = 0
    for i = 1, #elementTable do
        if elementTable[i] > 1 then
            imgStr = imgStr .. i
            bonusCount = bonusCount + 1
        end
    end
    if bonusCount > 0 then
        imgStr = imgStr .. ".png"
    else
        imgStr = "TeamBuff_6.png"
    end
    NodeHelper:setSpriteImage(pageContainer, { mBonusImg = imgStr })
    NodeHelper:setStringForLabel(pageContainer, { mBonusTxt = str })
end

function NgBattleEditTeamPage:onLoad(container)
	container:loadCcbiFile(option.ccbiFile)
end

function NgBattleEditTeamPage:onEnter(container)
    pageContainer = container
    mInfos = UserMercenaryManager:getUserMercenaryInfos()
    local mapId = NgBattleDataManager.battleMapId or 1
    local bgPath = ""
    self:registerPacket(container)
    roleSortInfos = { }
    items = { }
    nowTeamRoleIds = { }
    allSelectNode = { }
    selectId = 0
    allTeamContent = { }

    -- 生成選擇框
    for i = 1, 5 do
        local selectNode = container:getVarNode("mSelectNode" .. i)
        selectNode:removeAllChildrenWithCleanup(true)
        local spriteContainter = ScriptContentBase:create("BattlePageEditTeamSelect.ccbi")
        selectNode:addChild(spriteContainter)
        spriteContainter:runAnimation("Select Timeline")
        selectNode:setVisible(false)
        allSelectNode[i] = selectNode
        spriteContainter:release()
    end
    -- 設定過濾按鈕
    --local filterBg = container:getVarScale9Sprite("mFilterBg")
    --filterBg:setContentSize(filterCloseSize)
    --NodeHelper:setNodesVisible(container, { mClassNode = false })

    --NodeHelper:initScrollView(container, "mContentHero", 3)
    if NgBattleDataManager.battleType == CONST.SCENE_TYPE.PUZZLE then
        self:setPuzzleLimitData(container)
    elseif NgBattleDataManager.battleType == CONST.SCENE_TYPE.LIMIT_TOWER then
        self:setLimitTowerData(container)
    elseif NgBattleDataManager.battleType == CONST.SCENE_TYPE.FEAR_TOWER then
       self:setFearTowerData(container)
    end
    self:refreshPage(container)
    self:initEnemy(container)
    if NgBattleDataManager.battleType ~= CONST.SCENE_TYPE.PUZZLE and
       NgBattleDataManager.battleType ~= CONST.SCENE_TYPE.LIMIT_TOWER then
        self:onElement(container, "onElement0") 
        self:onClass(container, "onClass0")
    end

    --新手教學
    local GuideManager = require("Guide.GuideManager")
    GuideManager.PageContainerRef["NgBattleEditTeamPage"] = container
    if GuideManager.isInGuide then
        PageManager.pushPage("NewbieGuideForcedPage")
    end
    -- 放入預設隊伍
    if allTeamContent[0] then
        allTeamContent[0].content:onSelectTeam(allTeamContent[0].container)
    else
        if allTeamContent[1] then
            allTeamContent[1].content:onSelectTeam(allTeamContent[1].container)
        end
    end

    NgBattleEditTeamPage:setFightAndBuff()

    NodeHelper:setNodesVisible(container,{mArenaTeam = false,mTeamInfo = true})
    if NgBattleDataManager.battleType == CONST.SCENE_TYPE.AFK or NgBattleDataManager.battleType == CONST.SCENE_TYPE.BOSS then
        local mapCfg = ConfigManager.getNewMapCfg()
        if mapId == 0 then mapId = 1 end
        local chapter = mapCfg[mapId].Chapter
        local mainCh, childCh = unpack(common:split(chapter, "-"))
        bgPath = "BG/Battle/battle_bg_" .. string.format("%03d", mainCh) .. ".png"
        SoundManager:getInstance():playMusic("Battle_" .. string.format("%02d", chapter) .. ".mp3")
    elseif NgBattleDataManager.battleType == CONST.SCENE_TYPE.MULTI then
        local cfg = ConfigManager:getMultiEliteCfg()
        local fileName = cfg[NgBattleDataManager.dungeonId].bgFileName
        bgPath = "BG/Battle/" .. fileName .. ".png"
        SoundManager:getInstance():playMusic("Dungeon.mp3")
    elseif NgBattleDataManager.battleType == CONST.SCENE_TYPE.PVP then
        bgPath = "BG/Battle/role_bg_mul01.png"
        SoundManager:getInstance():playMusic("Arena.mp3")
         NodeHelper:setNodesVisible(container,{mArenaTeam = true,mTeamInfo = false})
        local content = container:getVarNode("mArenaTeamContent")
        if content then
            local child = ReadyToFightTeam
            child:setPosition(ccp(30,10))
            if not child then return end
            content:removeAllChildren()
            content:addChild(child)
            ReadyToFightTeam = nil
        end
    elseif NgBattleDataManager.battleType == CONST.SCENE_TYPE.WORLD_BOSS then
        bgPath = "BG/Battle/role_bg_mul01.png"
        SoundManager:getInstance():playMusic("WorldBoss_Bg.mp3")
    elseif NgBattleDataManager.battleType == CONST.SCENE_TYPE.DUNGEON then
        local cfg = ConfigManager:getMultiElite2Cfg()
        local fileName = cfg[NgBattleDataManager.dungeonId].bgFileName
        bgPath = "BG/Battle/" .. fileName .. ".png"
        SoundManager:getInstance():playMusic("Dungeon.mp3")
    elseif NgBattleDataManager.battleType == CONST.SCENE_TYPE.TEST_BATTLE then
        bgPath = "BG/Battle/battle_bg_001.png"
    elseif NgBattleDataManager.battleType == CONST.SCENE_TYPE.EDIT_FIGHT_TEAM then
        local mapCfg = ConfigManager.getNewMapCfg()
        if mapId == 0 then mapId = 1 end
        local chapter = mapCfg[mapId].Chapter
        local mainCh, childCh = unpack(common:split(chapter, "-"))
        bgPath = "BG/Battle/battle_bg_" .. string.format("%03d", mainCh) .. ".png"
    elseif NgBattleDataManager.battleType == CONST.SCENE_TYPE.EDIT_DEFEND_TEAM then
        bgPath = "BG/Battle/role_bg_mul01.png"
        NodeHelper:setSpriteImage(container,{ mFightNumBg = "BattleTeam_Img02_2.png" })
    elseif NgBattleDataManager.battleType == CONST.SCENE_TYPE.CYCLE_TOWER then
        local cfg = EventDataMgr[EventDataMgr.nowActivityId].STAGE_CFG
        local fileName = cfg[NgBattleDataManager.dungeonId].battleBg
        bgPath = "BG/Battle/"..fileName..".png"
        NodeHelper:setSpriteImage(container,{ mFightNumBg = "BattleTeam_Img02_2.png" })
    elseif NgBattleDataManager.battleType == CONST.SCENE_TYPE.SINGLE_BOSS or
           NgBattleDataManager.battleType == CONST.SCENE_TYPE.SINGLE_BOSS_SIM then
        local cfg = ConfigManager.getSingleBoss()[tonumber(NgBattleDataManager.SingleBossId)]
        local fileName = cfg.BattleBg
        bgPath = "BG/Battle/"..fileName..".png"
        NodeHelper:setSpriteImage(container,{ mFightNumBg = "BattleTeam_Img02_2.png" })
    elseif NgBattleDataManager.battleType == CONST.SCENE_TYPE.SEASON_TOWER then
        local cfg = ConfigManager.getTowerData()
        local fileName = cfg[NgBattleDataManager.dungeonId].battleBg
        bgPath = "BG/Battle/"..fileName..".png"
    elseif NgBattleDataManager.battleType == CONST.SCENE_TYPE.LIMIT_TOWER then
        local TowerDataBase = require "Tower.TowerPageData"
        local cfg = TowerDataBase:getLimitCfg(NgBattleDataManager.dungeonId,NgBattleDataManager.limitType)
        local fileName = cfg.battleBg
        bgPath = "BG/Battle/"..fileName..".png"
     elseif NgBattleDataManager.battleType == CONST.SCENE_TYPE.FEAR_TOWER then
        local TowerDataBase = require "Tower.TowerPageData"
        local _type = NgBattleDataManager.dungeonId
        
        local data = TowerDataBase:getData(199, _type) or {}
        local floor = math.max(tonumber(string.sub(data.curFloor,2,4)),1)
        
        local id = tonumber(string.format("%d%03d", _type, floor))
        
        local cfg = TowerDataBase:getFearCfg(id)
        local fileName = cfg.battleBg
        bgPath = "BG/Battle/"..fileName..".png"
     elseif NgBattleDataManager.battleType == CONST.SCENE_TYPE.PUZZLE then
        local cfg = ConfigManager.getSubPuzzleCfg()
        local fileName = cfg[NgBattleDataManager.dungeonId].battleBg
        bgPath = fileName
    end
    local VisibleMap = {}
    VisibleMap["mPuzzleNode"] = NgBattleDataManager.battleType == CONST.SCENE_TYPE.PUZZLE
    
    VisibleMap["mFilterBtn"] = not (
    NgBattleDataManager.battleType == CONST.SCENE_TYPE.PUZZLE or 
    NgBattleDataManager.battleType == CONST.SCENE_TYPE.LIMIT_TOWER)

   
    NodeHelper:setNodesVisible(container,VisibleMap)
	NodeHelper:setSpriteImage(container, { mBg = bgPath })
    local GuideManager = require("Guide.GuideManager")
    if not GuideManager.isInGuide then
        container:runAnimation("OpenAni")
    end
end

function NgBattleEditTeamPage:refreshPage(container)
    self:setInfoPage(container)

    container.mScrollView = container:getVarScrollView("mContentHero")
    container.mScrollView:removeAllCell()
    self:buildScrollView(container)
    if NgBattleDataManager.battleType ~= CONST.SCENE_TYPE.PUZZLE then
        self:buildDefaultTeam(container)
    end
end
function NgBattleEditTeamPage:setInfoPage(container)
    container.InfoScroll = container:getVarScrollView("mInfoContent")
    NodeHelper:autoAdjustResizeScrollview(container.InfoScroll)
    NodeHelper:autoAdjustResizeScale9Sprite(container:getVarScale9Sprite("mInfoBg"))
    local offsetY = NodeHelper:calcAdjustResolutionOffY()
    container:getVarNode("mInfoTitle"):setPositionY(970 + offsetY)
    container:getVarNode("mUpperExit"):setPositionY(1020 + offsetY)
    NodeHelper:setNodesVisible(container,{mChapterInfo = false})
end
function NgBattleEditTeamPage:initEnemy(container)
    if not NgBattleDataManager.serverEnemyInfo then return end
    for i = 1, CONST.ENEMY_COUNT do
        if NgBattleDataManager.serverEnemyInfo[i] then
            local spineNode = container:getVarNode("mSpine" .. NgBattleDataManager.serverEnemyInfo[i].posId)
            if spineNode then
                spineNode:removeAllChildrenWithCleanup(true)
                -- 判斷是什麼類型的敵人
                if NgBattleDataManager.serverEnemyInfo[i].type == Const_pb.MERCENARY or   -- Hero
                       NgBattleDataManager.serverEnemyInfo[i].type == Const_pb.RETINUE then   -- Free Hero
                    local cfg = heroCfg[tonumber(NgBattleDataManager.serverEnemyInfo[i].itemId)]
                    if cfg then
                        local spinePath, spineName = unpack(common:split(cfg.Spine, ","))
                        if NgBattleDataManager.serverEnemyInfo[i].skinId > 0 then
                            spineName = string.format("NG_%05d", NgBattleDataManager.serverEnemyInfo[i].skinId)
                        else
                            spineName = spineName .. string.format("%03d", 0)
                        end
                        local spine = SpineContainer:create(spinePath, spineName)
                        spine:runAnimation(1, CONST.ANI_ACT.WAIT, -1)
                        local sNode = tolua.cast(spine, "CCNode")
                        spineNode:addChild(sNode)
                    end
                elseif NgBattleDataManager.serverEnemyInfo[i].type == Const_pb.MONSTER or   -- Monster
                       NgBattleDataManager.serverEnemyInfo[i].type == Const_pb.WORLDBOSS then   -- WorldBoss
                    local monsterCfg = ConfigManager.getNewMonsterCfg()
                    local spinePath, spineName = unpack(common:split(monsterCfg[NgBattleDataManager.serverEnemyInfo[i].roleId].Spine, ","))
                    local enemySpine = SpineContainer:create(spinePath, spineName)
                    if monsterCfg[NgBattleDataManager.serverEnemyInfo[i].roleId].Skin then
                        enemySpine:setSkin("skin" .. string.format("%02d", monsterCfg[NgBattleDataManager.serverEnemyInfo[i].roleId].Skin))
                    end
                    enemySpine:runAnimation(1, CONST.ANI_ACT.WAIT, -1)
                    local sNode = tolua.cast(enemySpine, "CCNode")
                    if monsterCfg[NgBattleDataManager.serverEnemyInfo[i].roleId].Reflect == 1 then
                        sNode:setScaleX(-1)
                    end
                    spineNode:addChild(sNode)
                end
            end
        end
    end
end

function NgBattleEditTeamPage:buildScrollView(container)
    roleSortInfos = self:getSortMercenaryInfos()
    local count = 0
    for i = 1, #roleSortInfos do
        if roleSortInfos[i] and roleSortInfos[i].roleStage == 1 then
            count = count + 1
        end
    end
    count = #roleSortInfos

    if count <= 10 then
        container.mScrollView:setTouchEnabled(false)
    else
        container.mScrollView:setTouchEnabled(true)
    end

    for i = 1, count, 1 do
        local roleId = roleSortInfos[i].roleId
        local iconItem = NgHeadIconItem_Small:createCCBFileCell(roleId, i, container.mScrollView, GameConfig.NgHeadIconSmallType.BATTLE_EDITTEAM_PAGE, 
                                                                HEAD_SCALE, NgBattleEditTeamPage.onHeadCallback,{isLock = roleSortInfos[i].isLock})
        iconItem.handler.itemId = roleSortInfos[i].itemId
        local GuideManager = require("Guide.GuideManager")
        if roleSortInfos[i].itemId == 1 then
            GuideManager.PageContainerRef["NgBattleEditTeamFire1_cell"] = iconItem.cell
        end
        if roleSortInfos[i].itemId == 2 then
            GuideManager.PageContainerRef["NgBattleEditTeamFire2_cell"] = iconItem.cell
        end
        if roleSortInfos[i].itemId == 17 then
            GuideManager.PageContainerRef["NgBattleEditTeamWind5_cell"] = iconItem.cell
        end
        table.insert(items, iconItem) 
    end
   
    container.mScrollView:orderCCBFileCells()
    if NgBattleDataManager.battleType == CONST.SCENE_TYPE.PUZZLE or
       NgBattleDataManager.battleType == CONST.SCENE_TYPE.LIMIT_TOWER then
            NgBattleEditTeamPage:setLimit(container)
    end
end

function NgBattleEditTeamPage:AddSpine(container, group)
    for i = 1, math.min(#group.roleIds, MAX_TEAM_NUM) do
        local roleId = group.roleIds[i]
        local parentNode = container:getVarNode("mSpine" .. i)

        -- 清空節點內容
        parentNode:removeAllChildrenWithCleanup(true)
        parentNode:setVisible(false)

        if roleId and roleId > 0 then
            -- 取得角色資訊
            local info = mInfos[roleId]
            local spinePath, spineName = unpack(common:split(heroCfg[info.itemId].Spine, ","))

            -- 替換皮膚
            if info.skinId > 0 then
                spineName = string.format("NG_%05d", info.skinId)
            else
                spineName = spineName .. "000"
            end

            -- 建立 Spine 並加入畫面
            local spine = SpineContainer:create(spinePath, spineName)
            spine:setToSetupPose()
            spine:runAnimation(1, CONST.ANI_ACT.WAIT, -1)

            parentNode:addChild(tolua.cast(spine, "CCNode"))
            parentNode:setVisible(true)

            -- 更新隊伍資料
            nowTeamRoleIds[i] = roleId
        end
    end
end


function NgBattleEditTeamPage:buildDefaultTeam(container)
    -- 預設隊伍
    local team = 1
    if NgBattleDataManager.battleType == CONST.SCENE_TYPE.EDIT_FIGHT_TEAM then
        team = 1
    elseif NgBattleDataManager.battleType == CONST.SCENE_TYPE.EDIT_DEFEND_TEAM then
        team = 8
    end
    local groupStr = CCUserDefault:sharedUserDefault():getStringForKey("GROUP_INFOS_"..team.."_" .. UserInfo.playerInfo.playerId)
    local defaultTeamInfo = { } 
    defaultTeamInfo.roleIds = { }
    if groupStr and groupStr ~= "" then
        local groupInfo = common:split(groupStr, "_")
        for i = 2, #groupInfo - 1 do    -- 1是隊伍名稱
            defaultTeamInfo.roleIds[i - 1] = tonumber(groupInfo[i])
        end
    end

    if NgBattleDataManager.battleType == CONST.SCENE_TYPE.LIMIT_TOWER or 
        NgBattleDataManager.battleType == CONST.SCENE_TYPE.FEAR_TOWER then
        for pos,id in pairs (nowTeamRoleIds) do
             defaultTeamInfo.roleIds[pos] = id
        end
    end

    -- 重設全部hero選擇狀態
    nowTeamRoleIds = { }
    if allSelectNode[selectId] then
        allSelectNode[selectId]:setVisible(false)
    end
    selectId = 0
   
    NgBattleEditTeamPage:AddSpine(container, defaultTeamInfo)

    for i = 1, #items do
        local inTeamIdx = self:isInTeam(container, items[i].handler.roleId)
        NgHeadIconItem_Small:setIsChoose(items[i].handler, inTeamIdx > 0)
    end
end

function NgBattleEditTeamPage:isInTeam(container, roleId)
    for i = 1, MAX_TEAM_NUM do
        if nowTeamRoleIds[i] == roleId then
            return i
        end
    end
    return 0
end

function NgBattleEditTeamPage:onHero(container, eventName)
    -- 解析索引值
    local idx = tonumber(eventName:match("%d+$"))  -- 取 eventName 最後的數字
    if not idx or idx < 1 or idx > MAX_TEAM_NUM then
        print("Error: Invalid idx", eventName)
        return
    end

    -- 確保 selectId 已定義
    if selectId == nil then
        selectId = 0
    end

    -- 檢查是否在 heroLimit 限制內
    if NgBattleDataManager.battleType == CONST.SCENE_TYPE.PUZZLE then
        for _, info in pairs(NgBattleEditTeamPage.heroLimit) do
            if info.pos and info.pos == idx then
                MessageBoxPage:Msg_Box(common:getLanguageString("@PuzzleBattle_LimitPos"))
                return
            end
        end
    end

    if selectId > 0 and selectId <= MAX_TEAM_NUM then  -- 已有選擇過 --> 交換位置
        if allSelectNode[selectId] then
            allSelectNode[selectId]:setVisible(false)
        end
        if selectId ~= idx then
            -- 確保 parentNode 存在
            local parentNode1 = container:getVarNode("mSpine" .. selectId)
            local parentNode2 = container:getVarNode("mSpine" .. idx)
            if not parentNode1 or not parentNode2 then
                print("Error: parentNode is nil", selectId, idx)
                selectId = 0
                return
            end

            -- 取得子節點
            local child1 = parentNode1:getChildrenCount() > 0 and parentNode1:getChildren():objectAtIndex(0) or nil
            local child2 = parentNode2:getChildrenCount() > 0 and parentNode2:getChildren():objectAtIndex(0) or nil

            -- 交換場景顯示
            if child1 and tolua.cast(child1, "CCNode") then 
                child1:retain()
                if child1:getParent() then
                    child1:getParent():removeChild(child1, false)
                end
                parentNode2:addChild(child1)
                parentNode2:setVisible(true)
                child1:release()
            else
                parentNode2:setVisible(false)
            end
            if child2 and tolua.cast(child2, "CCNode") then 
                child2:retain()
                if child2:getParent() then
                    child2:getParent():removeChild(child2, false)
                end
                parentNode1:addChild(child2)
                parentNode1:setVisible(true)
                child2:release()
            else
                parentNode1:setVisible(false)
            end


            -- 交換隊伍資訊
            if selectId <= MAX_TEAM_NUM and idx <= MAX_TEAM_NUM then
                nowTeamRoleIds[selectId], nowTeamRoleIds[idx] = nowTeamRoleIds[idx], nowTeamRoleIds[selectId]
            else
                print("Error: nowTeamRoleIds index out of range", selectId, idx)
            end
        end
        selectId = 0
    else  -- 沒有選擇過 --> 開啟選擇框
        selectId = idx
        if allSelectNode[selectId] then
            allSelectNode[selectId]:setVisible(true)
        end
    end
end


function NgBattleEditTeamPage:onReturn(container)
    local PageJumpMange = require("PageJumpMange")
    if NgBattleDataManager.battleType == CONST.SCENE_TYPE.BOSS then
        NgBattleDataManager_setBattleType(CONST.SCENE_TYPE.AFK)
        NgFightSceneHelper:EnterState(NgBattleDataManager.battlePageContainer, CONST.FIGHT_STATE.INIT)
        PageManager.popPage(thisPageName)
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
    elseif NgBattleDataManager.battleType == CONST.SCENE_TYPE.SINGLE_BOSS or
        NgBattleDataManager.battleType == CONST.SCENE_TYPE.SINGLE_BOSS_SIM then
        PageJumpMange.JumpPageById(52)
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
    else
        PageManager.popPage(thisPageName)
    end
    --PageManager.popPage(thisPageName)
end

function NgBattleEditTeamPage:onConfirm(container)
    require("NgBattlePage")
    local teamInfo = { }
    local saveInfo = { }
    local teamCount = 0
    saveInfo.roleIds = { }
    saveInfo.name = ""
    if not self:IsTeamValid() and NgBattleDataManager.battleType == CONST.SCENE_TYPE.PUZZLE then 
        return 
    end
    for i = 1, MAX_TEAM_NUM do
        if nowTeamRoleIds[i] then
            if nowTeamRoleIds[i] > 0 then
                teamInfo[#teamInfo + 1] = nowTeamRoleIds[i] .. "_" .. i -- TODO 精靈也要加入隊伍資訊
                if i <= MAX_TEAM_NUM then
                    teamCount = teamCount + 1
                end
            end
            saveInfo.roleIds[i] = nowTeamRoleIds[i]
        else
            saveInfo.roleIds[i] = 0
        end
    end
    if teamCount <= 0 then
        MessageBoxPage:Msg_Box_Lan("@OrgTeamNumLimit")
        return
    end
    if NgBattleDataManager.battleType ~= CONST.SCENE_TYPE.PUZZLE and
       NgBattleDataManager.battleType ~= CONST.SCENE_TYPE.LIMIT_TOWER and
       NgBattleDataManager.battleType ~= CONST.SCENE_TYPE.FEAR_TOWER  then
        self:saveDefaultTeamInfo(saveInfo)
        NgBattleDataManager_setServerGroupInfo(saveInfo)
    end
    if NgBattleDataManager.battleType == CONST.SCENE_TYPE.LIMIT_TOWER then
        local nowType = NgBattleDataManager.limitType
        local TowerTeamKey = "LIMIT_TOWER_TEAM_" ..nowType.."_".. UserInfo.playerInfo.playerId
        local groupStr = ""
        for pos,Id in pairs(nowTeamRoleIds) do
            groupStr = groupStr..Id.."_"..pos..","
        end
        CCUserDefault:sharedUserDefault():setStringForKey(TowerTeamKey,groupStr)
    elseif NgBattleDataManager.battleType == CONST.SCENE_TYPE.FEAR_TOWER then
        local nowType = NgBattleDataManager.limitType
        local TowerTeamKey = "FEAR_TOWER_TEAM_" .. UserInfo.playerInfo.playerId
        local groupStr = ""
        for pos,Id in pairs(nowTeamRoleIds) do
            groupStr = groupStr..Id.."_"..pos..","
        end
        CCUserDefault:sharedUserDefault():setStringForKey(TowerTeamKey,groupStr)
    end

    NgBattlePageInfo_sendTeamInfoToServer(teamInfo)
    local HP_pb = require("HP_pb")
    common:sendEmptyPacket(HP_pb.ROLE_PANEL_INFOS_C, false)
end
function NgBattleEditTeamPage:IsTeamValid()
    local ids = {}
    local function getItemId(_RoleId)
        for k, v in pairs(items) do
            if v.handler.roleId == _RoleId then
                return v.handler.itemId
            end
        end
    end
    
    -- 記錄當前隊伍成員的 itemId -> pos
    for pos, RoleId in pairs(nowTeamRoleIds) do
        if RoleId ~= 0 then
            local itemId = getItemId(RoleId)
            if itemId then
                ids[itemId] = pos
            end
        end
    end

    -- 記錄限制條件的 itemId -> 限制的位置
    local limits = {}
    if NgBattleDataManager.battleType == CONST.SCENE_TYPE.PUZZLE then
        for _, info in pairs(NgBattleEditTeamPage.heroLimit) do
            if info.id then
                limits[info.id] = info.pos -- pos=0 代表無限制
            end
        end
    end

    -- 檢查是否包含所有限制條件
    for itemId, requiredPos in pairs(limits) do
        local actualPos = ids[itemId]

        if requiredPos == 0 then
            -- 只需 itemId 存在，不檢查位置
            if not actualPos then
                MessageBoxPage:Msg_Box(common:getLanguageString("@Public_LimitError"))
                return false
            end
        else
            -- 需要 itemId 存在且位置符合
            if not actualPos or actualPos ~= requiredPos then
                 MessageBoxPage:Msg_Box(common:getLanguageString("@Public_LimitError"))
                return false
            end
        end
    end
    return true
end


-- 展開/收起過濾按鈕
function NgBattleEditTeamPage:onFilter(container)
    local isShowClass = container:getVarNode("mFilter"):isVisible()
    --local filterBg = container:getVarScale9Sprite("mFilterBg")
    if isShowClass then
        NodeHelper:setNodesVisible(container,{mFilter = false})
    else
        NodeHelper:setNodesVisible(container,{mFilter = true})
    end
end
-- 過濾職業
function NgBattleEditTeamPage:onClass(container, eventName)
    currentClass = tonumber(eventName:sub(-1))
    if items then
        for i = 1, #items do
            local isVisible = (currentElement == items[i].handler.element or currentElement == 0) and
                              (currentClass == items[i].handler.class or currentClass == 0)
            items[i].cell:setVisible(isVisible)
            items[i].cell:setContentSize(isVisible and headIconSize or CCSize(0, 0))
        end
    end
    for i = 0, 4 do
        container:getVarSprite("mClass" .. i):setVisible(currentClass == i)
    end
    container.mScrollView:orderCCBFileCells()
end
-- 過濾屬性
function NgBattleEditTeamPage:onElement(container, eventName)
    currentElement = tonumber(eventName:sub(-1))
    if items then
        for i = 1, #items do
            local isVisible = (currentElement == items[i].handler.element or currentElement == 0) and
                              (currentClass == items[i].handler.class or currentClass == 0)
            items[i].cell:setVisible(isVisible)
            items[i].cell:setContentSize(isVisible and headIconSize or CCSize(0, 0))
        end
    end
    for i = 0, 5 do
        container:getVarSprite("mElement" .. i):setVisible(currentElement == i)
    end
    container.mScrollView:orderCCBFileCells()
end

function NgBattleEditTeamPage:onTeamInfo(container)
    if not NgBattleDataManager.serverEnemyInfo then return end
    NodeHelper:setNodesVisible(container,{mChapterInfo = true})
    if container.InfoScroll then
        container.InfoScroll:removeAllCell()
        for i = 1, CONST.ENEMY_COUNT do
            if NgBattleDataManager.serverEnemyInfo[i] then
                 local data = NgBattleDataManager.serverEnemyInfo[i]
                 local cell = CCBFileCell:create()
                 cell:setCCBFile(MonsterInfoContent.ccbiFile)
                 local panel = common:new({ info = data }, MonsterInfoContent)
                 cell:registerFunctionHandler(panel)
                 container.InfoScroll:addCell(cell)
            end
        end
        container.InfoScroll:orderCCBFileCells()
        container.InfoScroll:setTouchEnabled(true)
        end
end

-- 檔案最上方預先快取
local PBHelper = require("PBHelper")
local monCfg  = ConfigManager.getNewMonsterCfg()

function MonsterInfoContent:onRefreshContent(content)
    local container = content:getCCBFileNode()
    local info      = self.info
    local attrTbl   = info.attribute.attribute
    local skills    = info.skills or {}
    local element   = info.elements
    local cls       = info.prof
    local pos       = info.posId - 10
    local roleType  = info.type

    -- 屬性 ID 列表
    local attrIds = {
        Const_pb.ATTACK_attr,
        Const_pb.MAGIC_attr,
        Const_pb.HP,
        Const_pb.PHYDEF,
        Const_pb.MAGDEF
    }

    -- 預設要顯示的節點
    local visibleMap = {
        mElement = true,
        mClass   = true,
        mSprite  = true
    }

    -- 圖片資源表
    local imgTable = {
        mElement = GameConfig.MercenaryElementImg[element],
        mClass   = GameConfig.MercenaryClassImg[cls],
    }
    if roleType == CONST.CHARACTER_TYPE.HERO then   
        local skinId = info.skinId
        local iconId = skinId > 0 and string.format("%05d", skinId) or string.format("%02d000", info.itemId)
        imgTable["mSprite"] = "UI/RoleIcon/Icon_" .. iconId .. ".png"
    elseif roleType == CONST.CHARACTER_TYPE.MONSTER or roleType == CONST.CHARACTER_TYPE.WORLDBOSS then
        imgTable["mSprite"] = monCfg[info.itemId].Icon
    end
    local tmpTb = {}
    for _,skl in pairs (skills) do
        local sklCfg = ConfigManager.getSkillCfg()
        if (skl ~= nil) and  type(skl) == "number" and sklCfg[skl].isShowInfo == 1 then
            table.insert(tmpTb,skl)
        end
    end
    skills = tmpTb
    -- 文字資源表
    local strTable = {}
    self.skillId = {}
    -- 依序處理 5 個屬性 + 技能
    for i, attrId in ipairs(attrIds) do
        -- 屬性文字
        strTable["mAttrTxt"..i] = PBHelper:getAttrById(attrTbl, attrId)

        -- 技能是否存在
        local skl = skills[i]
        local hasSkill = (skl ~= nil)
        visibleMap["mSkill"..i]   = hasSkill

        if hasSkill then
            -- 技能圖片與等級
            imgTable["Skill"..i]       = ("S_%d.png"):format(math.floor(skl / 10))
            strTable["mSkillLv"..i]    = tostring(skl % 10)
            self.skillId[i] = skl
        else
            imgTable["Skill"..i]       = ""
            strTable["mSkillLv"..i]    = "0"
            self.skillId[i]            = 0
        end
    end
    strTable["mPos"] = pos
    -- 一次性更新所有節點
    NodeHelper:setNodesVisible(container, visibleMap)
    NodeHelper:setStringForLabel  (container, strTable)
    NodeHelper:setSpriteImage     (container, imgTable)
end

local function _showSkillTip(self, container, idx)
    local sid = (self.skillId or {})[idx] or 0
    if sid > 0 then
        local node = container:getVarNode("Skill"..idx)
        GameUtil:showSkillTip(node, sid)
    end
end

for i = 1, 5 do
    MonsterInfoContent["onSkill"..i] = function(self, container)
        _showSkillTip(self, container, i)
    end
end

function NgBattleEditTeamPage:onExitInfo(container)
    NodeHelper:setNodesVisible(container,{mChapterInfo = false})
end

function NgBattleEditTeamPage:saveDefaultTeamInfo(groupInfo)
    local groupStr = groupInfo.name .. "_"
    for i = 1, #groupInfo.roleIds do
        groupStr = groupStr .. groupInfo.roleIds[i] .. "_"
    end
    local team = 1
    if NgBattleDataManager.battleType == CONST.SCENE_TYPE.EDIT_FIGHT_TEAM then
        team = 1
    elseif NgBattleDataManager.battleType == CONST.SCENE_TYPE.EDIT_DEFEND_TEAM then
        team = 8
    end
    CCUserDefault:sharedUserDefault():setStringForKey("GROUP_INFOS_"..team.."_" .. UserInfo.playerInfo.playerId, groupStr)
end

function NgBattleEditTeamPage:getSortMercenaryInfos()
    local infos = UserMercenaryManager:getMercenaryStatusInfos()
    local tblsort = { }
    local tbldisorder = { }
    local index = 1
    for k, v in pairs(infos) do
        if v.type ~= Const_pb.RETINUE and v.roleStage == Const_pb.IS_ACTIVITE then 
            table.insert(tblsort, v)
            tbldisorder[v.roleId] = v
            tbldisorder[v.roleId].index = index
            index = index + 1
        end
    end

    if #tblsort > 0 then
        table.sort(tblsort, function(info1, info2)
            if info1 == nil or info2 == nil then
                return false
            end
            local mInfo = UserMercenaryManager:getUserMercenaryInfos()
            local mInfo1 = mInfo[info1.roleId]
            local mInfo2 = mInfo[info2.roleId]
            if mInfo1 == nil then
                return false
            end
            if mInfo2 == nil then
                return true
            end
            if (info1.status == Const_pb.FIGHTING or info1.status == Const_pb.MIXTASK) and (info2.status ~= Const_pb.FIGHTING and info2.status ~= Const_pb.MIXTASK) then
                return true
            elseif (info1.status ~= Const_pb.FIGHTING and info1.status ~= Const_pb.MIXTASK) and (info2.status == Const_pb.FIGHTING or info2.status == Const_pb.MIXTASK) then
                return false
            elseif mInfo1.level ~= mInfo2.level then
                return mInfo1.level > mInfo2.level
            elseif mInfo1.starLevel ~= mInfo2.starLevel then
                return mInfo1.starLevel > mInfo2.starLevel
            elseif mInfo1.fight ~= mInfo2.fight then
                return mInfo1.fight > mInfo2.fight
            elseif mInfo1.singleElement ~= mInfo2.singleElement then
                return mInfo1.singleElement < mInfo2.singleElement
            end
            return false
        end )
    end
    local function moveToFront(tbl, index)
        if index > 1 and index <= #tbl then
            local value = table.remove(tbl, index) -- 移除該索引的元素
            table.insert(tbl, 1, value) -- 插入到第一個位置
        end
    end
    local function getIdx(_itemId)
        for idx,data in pairs (tblsort) do
            if data.itemId == _itemId then
                data.isLock = true
                return idx
            end
        end
    end
    local function resetLockState()
        for idx,data in pairs (tblsort) do
            data.isLock = false
        end
    end
    if NgBattleDataManager.battleType == CONST.SCENE_TYPE.PUZZLE  then
        resetLockState()
    	for _,data in pairs(self.heroLimit) do
        	if data.id then
        	   moveToFront(tblsort, getIdx(data.id))
        	end
    	end
    end
    return tblsort--, tbldisorder
end

function NgBattleEditTeamPage_getFirstTeamEmptyPosDesc()
    local pos = 1
    for i = 1, 5 do
        local truePos = ((i + 2) > 5) and (i - 3) or (i + 2)
        if not nowTeamRoleIds[truePos] or nowTeamRoleIds[truePos] == 0 then
            pos = truePos
            break
        end
    end
    return pos
end

function NgBattleEditTeamPage_getWind5TeamPosDesc()
    local pos = 1
    for i = 1, 5 do
        if nowTeamRoleIds[i] ~= 0 then
            local info = mInfos[nowTeamRoleIds[i]]
            if info.itemId == 17 then
                pos = i
                break
            end
        end
    end
    return pos
end

function NgBattleEditTeamPage:onReceivePacket(container)
    local opcode = container:getRecPacketOpcode()
    local msgBuff = container:getRecPacketBuffer()

    if opcode == HP_pb.EDIT_FORMATION_S then
        -- 編輯隊伍
        local msg = Formation_pb.HPFormationUseRes()
        msg:ParseFromString(msgBuff)
        MessageBoxPage:Msg_Box(common:getLanguageString("@OrgTeamFinish"))
        if NgBattleDataManager.battleType == CONST.SCENE_TYPE.EDIT_DEFEND_TEAM then
            require("ArenaPage")
            ArenaPage_Reset()
            local msg = MsgMainFrameRefreshPage:new()
            msg.pageName = "ArenaPage"
            msg.extraParam = "EditTeam"
            MessageManager:getInstance():sendMessageForScript(msg)
        end
         PageManager.popPage(thisPageName)
    end
end
function NgBattleEditTeamPage:registerPacket(container)
    for key, opcode in pairs(option.opcodes) do
        if string.sub(key, -1) == "S" then
            container:registerPacket(opcode)
        end
    end
end

function NgBattleEditTeamPage:setPuzzleLimitData(container)
    -- 重置隊伍角色 ID
    for i = 1, MAX_TEAM_NUM do
        nowTeamRoleIds[i] = 0
    end

    -- 獲取關卡配置
    local stageInfo = ConfigManager.getSubPuzzleCfg()[NgBattleDataManager.dungeonId]
    local heroLimitData = {}

    -- 解析英雄位置限制
    if stageInfo.limitPos and stageInfo.limitPos ~= "" then
        for _, value in ipairs(common:split(stageInfo.limitPos, ",")) do
            local girlInfo = common:split(value, "_")
            table.insert(heroLimitData, { id = tonumber(girlInfo[1]), pos = tonumber(girlInfo[2]) })
        end
    end

    -- 解析元素屬性限制
    for _, element in ipairs(common:split(stageInfo.limitElement, ",")) do
        local elementId = tonumber(element)
        if elementId then
            table.insert(heroLimitData, { element = elementId })
        end
    end

    -- 設置限制數量顯示
    NodeHelper:setStringForLabel(container, { mLimitCount = stageInfo.limitGirl })
    NgBattleEditTeamPage.limitGirlCount = stageInfo.limitGirl
    NgBattleEditTeamPage.heroLimit = heroLimitData

    -- 隱藏所有限制框
    for i = 1, 5 do
        NodeHelper:setNodesVisible(container, { ["mLimit_" .. i] = false })
    end

    -- 根據 heroLimitData 顯示對應限制
    for i, info in ipairs(heroLimitData) do
        local limitNodeName = "mLimit_" .. i
        if info.element and info.element == 0 then break end
        NodeHelper:setNodesVisible(container, { [limitNodeName] = true })

        local heroNode = ScriptContentBase:create("Puzzle_iconContentccb")
        container:getVarNode(limitNodeName):addChild(heroNode)

        if info.id then
            -- 設置英雄圖片與位置
            NodeHelper:setSpriteImage(heroNode, { mSprite = "UI/Role/Portrait_" .. string.format("%02d", info.id) .. "000.png" }, { mSprite = 0.9 })
            NodeHelper:setStringForLabel(heroNode, { mPos = info.pos })
            NodeHelper:setNodesVisible(heroNode, { mHeroNode = true, mPosNode = (info.pos ~= 0) })
        elseif info.element then
            -- 設置元素圖片
            NodeHelper:setNodesVisible(heroNode, { mHeroNode = false })
            NodeHelper:setSpriteImage(heroNode, { mSprite = "Attributes_elemet_" .. string.format("%02d", info.element) .. ".png" }, { mSprite = 1.44 })
        end
    end

    -- 調整背景大小
    local limitCount = 0
    for _,info in pairs (heroLimitData) do
        if info.id or info.element and info.element ~= 0 then
           limitCount = limitCount +1 
        end
    end
    local sprite = container:getVarScale9Sprite("mLimitBg")
    sprite:setContentSize(CCSizeMake(50 + limitCount * 50, 70))
    NodeHelper:setNodesVisible(container, { mLimitBg = limitCount > 0 })
end
function NgBattleEditTeamPage:setFearTowerData(container)
    for i = 1, MAX_TEAM_NUM do
        nowTeamRoleIds[i] = 0
    end

    -- 取得儲存的隊伍配置
    local playerId = UserInfo.playerInfo.playerId
    local teamKey = "FEAR_TOWER_TEAM_".. playerId
    local savedTeam = CCUserDefault:sharedUserDefault():getStringForKey(teamKey) or ""

    if savedTeam ~= "" then
        for _, info in ipairs(common:split(savedTeam, ",")) do
            local t = common:split(info, "_")
            local roleId, pos = tonumber(t[1]), tonumber(t[2])
            if roleId and pos then
                nowTeamRoleIds[pos] = roleId
            end
        end
    end
end
function NgBattleEditTeamPage:setLimitTowerData(container)
    -- 重置隊伍
    for i = 1, MAX_TEAM_NUM do
        nowTeamRoleIds[i] = 0
    end

    -- 取得儲存的隊伍配置
    local nowType = NgBattleDataManager.limitType
    local playerId = UserInfo.playerInfo.playerId
    local teamKey = "LIMIT_TOWER_TEAM_" .. nowType .. "_" .. playerId
    local savedTeam = CCUserDefault:sharedUserDefault():getStringForKey(teamKey) or ""

    if savedTeam ~= "" then
        for _, info in ipairs(common:split(savedTeam, ",")) do
            local t = common:split(info, "_")
            local roleId, pos = tonumber(t[1]), tonumber(t[2])
            if roleId and pos then
                nowTeamRoleIds[pos] = roleId
            end
        end
    end

    -- 處理限制條件
    local TowerDataBase = require "Tower.TowerPageData"
    local cfg = TowerDataBase:getLimitCfg(NgBattleDataManager.dungeonId, nowType)
    local limitTable = {}

    if cfg.type > 10 then
        table.insert(limitTable, { class = cfg.type - 10 })
    elseif cfg.type == 4 then
        table.insert(limitTable, { element = 4 })
        table.insert(limitTable, { element = 5 })
    else
        table.insert(limitTable, { element = cfg.type })
    end

    NgBattleEditTeamPage.heroLimit = limitTable
end

function NgBattleEditTeamPage:setLimit(container)
    local heroLimitData = NgBattleEditTeamPage.heroLimit

    local function syncLimit(itemId)
        for _,info in pairs (NgBattleEditTeamPage.heroLimit) do
            if info.id == itemId then
                return true
            end
        end
        return false
    end

    local function syncElement(element,itemId)
        if not next(NgBattleEditTeamPage.heroLimit) then return true end
        for _,info in pairs (NgBattleEditTeamPage.heroLimit) do
            if info.element then
                if info.element == 0 or element == info.element then 
                    return true 
                end
            end
        end
        return false
    end

    local function syncClass(_class)
        if not next(NgBattleEditTeamPage.heroLimit) then return true end
        for _,info in pairs (NgBattleEditTeamPage.heroLimit) do
            if info.class then
                if info.class == 0 or _class == info.class then 
                    return true 
                end
            end
        end
        return false
    end

     if items then
       for i = 1, #items do
           local data = items[i].handler
           local isLimit = syncLimit(data.itemId)
           local isElement = syncElement(data.element,data.itemId)
           local isClass = syncClass(data.class)
           local isVisible = isElement or isLimit or isClass
           items[i].cell:setVisible(isVisible)
           items[i].visible = isVisible
           items[i].cell:setContentSize(isVisible and headIconSize or CCSize(0, 0))
       end

       
       container.mScrollView:orderCCBFileCells()


        local function getRoleData(itemId)
            for i = 1, #items do
                if items[i].handler.itemId == itemId then
                    return items[i].handler
                end
            end
        end
        for i = 1, #heroLimitData do
            local info = heroLimitData[i]
            if info.id then
                local data = getRoleData(info.id)
                if info.pos ~= 0 then
                    addMember(info.pos,data)
                end
            end
        end
    end
end

function NgBattleEditTeamPage:getTeamCount(teamIds)
    local num = 0
    for k, v in pairs(teamIds) do
        if v > 0 and k <= MAX_TEAM_NUM then
            num = num + 1
        end
    end
    return num
end
----------------------------------------------------------------------------------
local CommonPage = require("CommonPage")
local editTeamPage = CommonPage.newSub(NgBattleEditTeamPage, thisPageName, option)

return editTeamPage