
--[[ 本體 ]]
local Inst = {}

--[[ 子頁面 配置 ]]
Inst.SubPageCfgs = {
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

--[[ 取得 子頁面 配置 ]]
function Inst:getSubPageCfg(subPageName)
    for idx, cfg in ipairs(Inst.SubPageCfgs) do
        if cfg.subPageName == subPageName then return cfg end
    end
    return nil
end


return Inst
