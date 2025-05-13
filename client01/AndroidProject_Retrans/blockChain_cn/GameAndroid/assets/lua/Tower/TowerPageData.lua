local NodeHelper   = require("NodeHelper")
local Activity6_pb = require("Activity6_pb")
local HP_pb        = require("HP_pb")

local TowerDataBase = {}

-- �O�s������ƻP�Ʀ���
local TowerPageData = {}
local TowerRankData = {}

-- �p���禡�G��l�� Base ���
local function initBaseInfo(data, id, giftType, _idx)
    local baseInfo = data.baseInfo
    local idx = _idx or 1
    -- ��l�� TowerPageData[id] �P TowerPageData[id][giftType]�]�C�������s�إ߸Ӫ�^
    TowerPageData[id] = TowerPageData[id] or {}
    TowerPageData[id][giftType] = {}
    local pInfo = TowerPageData[id][giftType]

    -- �]�w���ݩʡA�ùw�]�^�h��
    pInfo.MaxFloor  = baseInfo.MaxFloor or (baseInfo[idx] and (baseInfo[idx].DoneFloor or baseInfo[idx].passFloor)) or 0
    pInfo.curFloor  = baseInfo.currFloor or baseInfo[idx] and baseInfo[idx].currFloor
    pInfo.nowMorale = baseInfo.nowMorale or baseInfo[idx] and baseInfo[idx].nowMorale
    pInfo.maxMorale = baseInfo.maxMorale or baseInfo[idx] and baseInfo[idx].maxMorale
    pInfo.endTime   = baseInfo.endTime or data.endTime
    if baseInfo.chooseFloor then
        pInfo.canChooseFloor = baseInfo.chooseFloor
    end

    -- �B�z takeId�BcommodityList �P buffList
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

-- �p���禡�G��l�� Rank ���
local function initTowerRankData(data, id, giftType, idx)
    local rankingInfo
    if idx and type(idx) == "number" then
        rankingInfo = data.rankingInfo[idx] or data.rankingInfo
    else
        rankingInfo = data.rankingInfo
    end

    -- ��l�� TowerRankData[id] �P TowerRankData[id][giftType]
    TowerRankData[id] = TowerRankData[id] or {}
    TowerRankData[id][giftType] = {}
    local rInfo = TowerRankData[id][giftType]

    -- �B�z�ۤv���ƦW���
    local selfItem = rankingInfo.selfRankItem
    if selfItem then
        rInfo.selfRank     = selfItem.rank
        rInfo.selfFloor    = selfItem.MaxFloor or selfItem.passFloor % 1000
        rInfo.selfName     = selfItem.name
        rInfo.selfHead     = selfItem.headIcon
        rInfo.selfSkin     = selfItem.skin
        rInfo.selfDoneTime = selfItem.doneTime
    end

    -- �B�z�䥦�������ƦW���
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

-- ���@���f�G�ھ� action �P�_�եά�������l�ƨ禡
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

-- ���@���f�G���o Base ���
function TowerDataBase:getData(id, t)
    return id and TowerPageData[id] and TowerPageData[id][t or 1] or TowerPageData
end

-- ���@���f�G���o Rank ���
function TowerDataBase:getRank(id, t)
    return id and TowerRankData[id] and TowerRankData[id][t or 1] or TowerRankData
end

-- ���@���f�G���o�t�m�C�̷� _giftType �L�o�ñƧǡA�p�G���� _id�A�h���ӧǸ������
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
-- �إߤl�����]�z�L CommonPage �s�ؼҲա^
local CommonPage = require('CommonPage')
local TowerData = CommonPage.newSub(TowerDataBase, "TowerDataMgr", { handlerMap = {} })

return TowerData
