
--[[ 本體 ]]
local Inst = {}
Inst.originTb = {
     {
        -- 子頁面名稱 : 主頁
        subPageName = "MainScene",
        
        -- 分頁 相關
        scriptName = "Tower.TowerSubPage_MainScene",
        iconImg_normal = "SubBtn_Tower.png",
        iconImg_selected = "SubBtn_Tower_On.png",
        
        -- 標題
        title = common:getLanguageString("@BundleShopTitle"),
        
        -- 貨幣資訊
        currencyInfos = {{priceStr = "10000_1002_0"}, {priceStr = "10000_1001_0"}},
        
        -- 其他子頁資訊 ----------
        TopisVisible = false,
        activityID = Const_pb.ACTIVITY194_SeasonTower,
    },
    {
        -- 子頁面名稱 : 主頁
        subPageName = "Rank",
        
        -- 分頁 相關
        scriptName = "Tower.TowerSubPage_Rank",
        iconImg_normal = "SubBtn_Ranking.png",
        iconImg_selected = "SubBtn_Ranking_On.png",
        
        -- 標題
        title = common:getLanguageString("@BundleShopTitle"),
        
        -- 貨幣資訊
        currencyInfos = {{priceStr = "10000_1002_0"}, {priceStr = "10000_1001_0"}},
        
        -- 其他子頁資訊 ----------
        TopisVisible = false,

        activityID = Const_pb.ACTIVITY194_SeasonTower
    },
}
--[[ 子頁面 配置 ]]
Inst.SubPageCfgs = {
   
}

local function createPassConfig(groupId)
    return {
        _closePlusBtn = true,
        subPageName = "TowerPass" .. groupId,
        scriptName = "TowerPass.TowerPassSubPage_Base",
        iconImg_normal = string.sub(groupId,1,3) ~= "198" and "SubBtn_"..groupId..".png" or "SubBtn_19401.png",
        iconImg_selected = string.sub(groupId,1,3) ~= "198" and "SubBtn_"..groupId.."_On.png"or "SubBtn_19401_On.png",
        title = common:getLanguageString("@TowerPass" .. groupId),
        currencyInfos = {{priceStr = "10000_1002_0"}, {priceStr = "10000_1001_0"}},
        Help = "HELP_TOWER_PASS",
    }
end
function Inst:SetCfg()
    local MainCfg = ConfigManager.getTowerPassMainCfg()
    local SubCfg = ConfigManager.getTowerPassSubCfg()

    -- RechargeId -> SubData list 對應表
    local RechargeIdMap = {}
    for _, subData in pairs(SubCfg) do
        local id = subData.RechargeId
        RechargeIdMap[id] = RechargeIdMap[id] or {}
        table.insert(RechargeIdMap[id], subData)
    end

    local GroupTable = common:deepCopy(Inst.originTb)        -- 最終陣列，從 1 開始
    local groupIdToIndex = {}         -- groupId 對應 GroupTable 索引
    local groupIdToCounter = {}       -- groupId 對應 type 計數器（stage 編號）

    for _, MainData in pairs(MainCfg) do
        local groupId = MainData.groupId
        if tonumber(string.sub(groupId,1,3)) == 194 then
                -- 建立 group
            local groupIndex = groupIdToIndex[groupId]
            if not groupIndex then
                groupIndex = #GroupTable + 1
                groupIdToIndex[groupId] = groupIndex
                GroupTable[groupIndex] = {
                    configData = {},
                }
                GroupTable[groupIndex] = common:table_merge(GroupTable[groupIndex], createPassConfig(groupId))
                groupIdToCounter[groupId] = 0
            end

            -- 設定 type（從 1 開始遞增）
            groupIdToCounter[groupId] = groupIdToCounter[groupId] + 1
            MainData.type = groupIdToCounter[groupId]

            MainData.StageData = RechargeIdMap[MainData.RechargeId] or {}
            MainData._LimitType = tonumber(string.sub(groupId, -2))

            table.insert(GroupTable[groupIndex].configData, MainData)
        end
    end
   
    return GroupTable
end
--[[ 取得 子頁面 配置 ]]
function Inst:getSubPageCfg(subPageName)
    for idx, cfg in ipairs(Inst.SubPageCfgs) do
        if cfg.subPageName == subPageName then return cfg end
    end
    return nil
end


return Inst
