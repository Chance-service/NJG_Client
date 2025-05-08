
--[[ 本體 ]]
local Inst = {}

--[[ 子頁面 配置 ]]
Inst.SubPageCfgs = { }

--[[ 子頁面 配置 ]]
Inst.originTb = {
   {
        -- 子頁面名稱 : 
        subPageName = "Fire",
        limitType = 1,
        -- 分頁 相關
        scriptName = "TowerLimit.TowerLimitSubPage_MainScene",
        iconImg_normal = "SubBtn_TowerElemet_01.png",
        iconImg_selected = "SubBtn_TowerElemet_01_On.png",
        
        -- 標題
        title = common:getLanguageString("@BundleShopTitle"),
        
        -- 貨幣資訊
        currencyInfos = {{priceStr = "10000_1002_0"}, {priceStr = "10000_1001_0"}},
        
        -- 其他子頁資訊 ----------
        TopisVisible = false,
        activityID = Const_pb.ACTIVITY198_LIMIT_TOWER,
        callFun = function() 
                     require("TowerLimit.TowerLimitSubPage_MainScene"):setType(1)
                  end
    },
    {
        -- 子頁面名稱 : 
        subPageName = "Water",
        limitType = 2,
        -- 分頁 相關
        scriptName = "TowerLimit.TowerLimitSubPage_MainScene",
        iconImg_normal = "SubBtn_TowerElemet_02.png",
        iconImg_selected = "SubBtn_TowerElemet_02_On.png",
        
        -- 標題
        title = common:getLanguageString("@BundleShopTitle"),
        
        -- 貨幣資訊
        currencyInfos = {{priceStr = "10000_1002_0"}, {priceStr = "10000_1001_0"}},
        
        -- 其他子頁資訊 ----------
        TopisVisible = false,
        activityID = Const_pb.ACTIVITY198_LIMIT_TOWER,
        callFun = function() 
                     require("TowerLimit.TowerLimitSubPage_MainScene"):setType(2)
                  end
    },
    {
        -- 子頁面名稱 : 
        subPageName = "Wood",
        limitType = 3,
        -- 分頁 相關
        scriptName = "TowerLimit.TowerLimitSubPage_MainScene",
        iconImg_normal = "SubBtn_TowerElemet_03.png",
        iconImg_selected = "SubBtn_TowerElemet_03_On.png",
        
        -- 標題
        title = common:getLanguageString("@BundleShopTitle"),
        
        -- 貨幣資訊
        currencyInfos = {{priceStr = "10000_1002_0"}, {priceStr = "10000_1001_0"}},
        
        -- 其他子頁資訊 ----------
        TopisVisible = false,
        activityID = Const_pb.ACTIVITY198_LIMIT_TOWER,
        callFun = function() 
                     require("TowerLimit.TowerLimitSubPage_MainScene"):setType(3)
                  end
    },
    {
        -- 子頁面名稱 : 
        subPageName = "Light_and_Dark",
        limitType = 4,
        -- 分頁 相關
        scriptName = "TowerLimit.TowerLimitSubPage_MainScene",
        iconImg_normal = "SubBtn_TowerElemet_04.png",
        iconImg_selected = "SubBtn_TowerElemet_04_On.png",
        
        -- 標題
        title = common:getLanguageString("@BundleShopTitle"),
        
        -- 貨幣資訊
        currencyInfos = {{priceStr = "10000_1002_0"}, {priceStr = "10000_1001_0"}},
        
        -- 其他子頁資訊 ----------
        TopisVisible = false,
        activityID = Const_pb.ACTIVITY198_LIMIT_TOWER,
        callFun = function() 
                     require("TowerLimit.TowerLimitSubPage_MainScene"):setType(4)
                  end
    },
    {
        -- 子頁面名稱 : 
        subPageName = "Shield",
        limitType = 11,
        -- 分頁 相關
        scriptName = "TowerLimit.TowerLimitSubPage_MainScene",
        iconImg_normal = "SubBtn_TowerOccupation_01.png",
        iconImg_selected = "SubBtn_TowerOccupation_01_On.png",
        
        -- 標題
        title = common:getLanguageString("@BundleShopTitle"),
        
        -- 貨幣資訊
        currencyInfos = {{priceStr = "10000_1002_0"}, {priceStr = "10000_1001_0"}},
        
        -- 其他子頁資訊 ----------
        TopisVisible = false,
        activityID = Const_pb.ACTIVITY198_LIMIT_TOWER,
        callFun = function() 
                     require("TowerLimit.TowerLimitSubPage_MainScene"):setType(11)
                  end
    },
    {
        -- 子頁面名稱 : 
        subPageName = "Sword",
        limitType = 12,
        -- 分頁 相關
        scriptName = "TowerLimit.TowerLimitSubPage_MainScene",
        iconImg_normal = "SubBtn_TowerOccupation_02.png",
        iconImg_selected = "SubBtn_TowerOccupation_02_On.png",
        
        -- 標題
        title = common:getLanguageString("@BundleShopTitle"),
        
        -- 貨幣資訊
        currencyInfos = {{priceStr = "10000_1002_0"}, {priceStr = "10000_1001_0"}},
        
        -- 其他子頁資訊 ----------
        TopisVisible = false,
        activityID = Const_pb.ACTIVITY198_LIMIT_TOWER,
        callFun = function() 
                     require("TowerLimit.TowerLimitSubPage_MainScene"):setType(12)
                  end
    },
    {
        -- 子頁面名稱 : 
        subPageName = "Heal",
        limitType = 13,
        -- 分頁 相關
        scriptName = "TowerLimit.TowerLimitSubPage_MainScene",
        iconImg_normal = "SubBtn_TowerOccupation_03.png",
        iconImg_selected = "SubBtn_TowerOccupation_03_On.png",
        
        -- 標題
        title = common:getLanguageString("@BundleShopTitle"),
        
        -- 貨幣資訊
        currencyInfos = {{priceStr = "10000_1002_0"}, {priceStr = "10000_1001_0"}},
        
        -- 其他子頁資訊 ----------
        TopisVisible = false,
        activityID = Const_pb.ACTIVITY198_LIMIT_TOWER,
        callFun = function() 
                     require("TowerLimit.TowerLimitSubPage_MainScene"):setType(13)
                  end
    },
    {
        -- 子頁面名稱 : 
        subPageName = "Magic",
        limitType = 14,
        -- 分頁 相關
        scriptName = "TowerLimit.TowerLimitSubPage_MainScene",
        iconImg_normal = "SubBtn_TowerOccupation_04.png",
        iconImg_selected = "SubBtn_TowerOccupation_04_On.png",
        
        -- 標題
        title = common:getLanguageString("@BundleShopTitle"),
        
        -- 貨幣資訊
        currencyInfos = {{priceStr = "10000_1002_0"}, {priceStr = "10000_1001_0"}},
        
        -- 其他子頁資訊 ----------
        TopisVisible = false,
        activityID = Const_pb.ACTIVITY198_LIMIT_TOWER,
        callFun = function() 
                     require("TowerLimit.TowerLimitSubPage_MainScene"):setType(14)
                  end
    },
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

    local GroupTable = common:deepCopy(Inst.originTb)          -- 最終陣列，從 1 開始
    local groupIdToIndex = {}         -- groupId 對應 GroupTable 索引
    local groupIdToCounter = {}       -- groupId 對應 type 計數器（stage 編號）

    for _, MainData in pairs(MainCfg) do
        local groupId = MainData.groupId
        if tonumber(string.sub(groupId,1,3)) == 198 then
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
