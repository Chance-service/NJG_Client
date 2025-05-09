local NodeHelper   = require("NodeHelper")
local Activity6_pb = require("Activity6_pb")
local HP_pb        = require("HP_pb")

local TowerDataBase = {}

-- 保存頁面資料與排行資料
local TowerPageData = {}
local TowerRankData = {}

-- 私有函式：初始化 Base 資料
local function initBaseInfo(data, id, giftType, _idx)
    local baseInfo = data.baseInfo
    local idx = _idx or 1
    -- 初始化 TowerPageData[id] 與 TowerPageData[id][giftType]（每次都重新建立該表）
    TowerPageData[id] = TowerPageData[id] or {}
    TowerPageData[id][giftType] = {}
    local pInfo = TowerPageData[id][giftType]

    -- 設定基本屬性，並預設回退值
    pInfo.MaxFloor  = baseInfo.MaxFloor or (baseInfo[idx] and (baseInfo[idx].DoneFloor or baseInfo[idx].passFloor)) or 0
    pInfo.curFloor  = baseInfo.currFloor or baseInfo[idx] and baseInfo[idx].currFloor
    pInfo.nowMorale = baseInfo.nowMorale or baseInfo[idx] and baseInfo[idx].nowMorale
    pInfo.maxMorale = baseInfo.maxMorale or baseInfo[idx] and baseInfo[idx].maxMorale
    pInfo.endTime   = baseInfo.endTime or data.endTime
    if baseInfo.chooseFloor then
        pInfo.canChooseFloor = baseInfo.chooseFloor
    end

    -- 處理 takeId、commodityList 與 buffList
    local keys = {"takeId", "commodityList", "SkillList","brought"}
    for _, key in ipairs(keys) do
        local cfg = baseInfo[key] or baseInfo[idx] and baseInfo[idx][key]
        if cfg then
            pInfo[key] = {}
            for k, v in pairs(cfg) do
                if type(k) == "number" then
                    pInfo[key][k] = v
                end
            end
        end
    end
end

-- 私有函式：初始化 Rank 資料
local function initTowerRankData(data, id, giftType, idx)
    local rankingInfo
    if idx and type(idx) == "number" then
        rankingInfo = data.rankingInfo[idx] or data.rankingInfo
    else
        rankingInfo = data.rankingInfo
    end

    -- 初始化 TowerRankData[id] 與 TowerRankData[id][giftType]
    TowerRankData[id] = TowerRankData[id] or {}
    TowerRankData[id][giftType] = {}
    local rInfo = TowerRankData[id][giftType]

    -- 處理自己的排名資料
    local selfItem = rankingInfo.selfRankItem
    if selfItem then
        rInfo.selfRank     = selfItem.rank
        rInfo.selfFloor    = selfItem.MaxFloor or selfItem.passFloor % 1000
        rInfo.selfName     = selfItem.name
        rInfo.selfHead     = selfItem.headIcon
        rInfo.selfSkin     = selfItem.skin
        rInfo.selfDoneTime = selfItem.doneTime
    end

    -- 處理其它成員的排名資料
    rInfo.otherItem = {}
    if rankingInfo.otherRankItem then
        for key, otherItem in pairs(rankingInfo.otherRankItem) do
            if type(key) == "number" then
                rInfo.otherItem[key] = {
                    rank     = otherItem.rank,
                    MaxFloor = otherItem.MaxFloor or otherItem.passFloor % 1000,
                    name     = otherItem.name,
                    headIcon = otherItem.headIcon,
                    skin     = otherItem.skin,
                    doneTime = otherItem.doneTime,
                }
            end
        end
    end
end

-- 公共接口：根據 action 判斷調用相應的初始化函式
function TowerDataBase_SetInfo(data, id, _giftType, idx)
    if not data or not data.action then return end
    local giftType = _giftType or 1
    if data.action ~= 1 then
        initBaseInfo(data, id, giftType, idx)
    end
    if data.action == 1 then
        initTowerRankData(data, id, giftType, idx)
    end
end

-- 公共接口：取得 Base 資料
function TowerDataBase:getData(id, t)
    return id and TowerPageData[id] and TowerPageData[id][t or 1] or TowerPageData
end

-- 公共接口：取得 Rank 資料
function TowerDataBase:getRank(id, t)
    return id and TowerRankData[id] and TowerRankData[id][t or 1] or TowerRankData
end

-- 公共接口：取得配置。依照 _giftType 過濾並排序，如果提供 _id，則取該序號的資料
function TowerDataBase:getLimitCfg(_id, _giftType)
    local cfgList = ConfigManager.getLimitTowerCfg()
    if not _giftType then return cfgList end

    local filteredList = {}
    for _, data in pairs(cfgList) do
        if data.type == _giftType then
            table.insert(filteredList, data)
        end
    end

    table.sort(filteredList, function(a, b)
        return a.id < b.id
    end)

    if _id then
        return filteredList[_id]
    else
        return filteredList
    end
end

function TowerDataBase:getFearCfg(_id,_giftType)
    local cfgList = ConfigManager.getFearTowerSubCfg()

    local giftType = _giftType or tonumber(string.sub(_id,1,1))

    local filteredList = {}
    for _, data in pairs(cfgList) do
        if tonumber(string.sub(data.id,1,1)) == giftType then
            table.insert(filteredList, data)
        end
    end

    table.sort(filteredList, function(a, b)
        return a.id < b.id
    end)

    if _id then       
        return cfgList[_id] 
    else
        return filteredList
    end
end
-- 建立子頁面（透過 CommonPage 新建模組）
local CommonPage = require('CommonPage')
local TowerData = CommonPage.newSub(TowerDataBase, "TowerDataMgr", { handlerMap = {} })

return TowerData
