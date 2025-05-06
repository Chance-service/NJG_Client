
--[[ 本體 ]]
local Inst = {}

--[[ 子頁面 配置 ]]
Inst.SubPageCfgs = {
   
    {
        -- 子頁面名稱 : 活動禮包
        subPageName = "CycleGift",
        
        -- 分頁 相關
        scriptName = "IAP_Act.ActSubPage_Gift",
        iconImg_normal = "SubBtn_StoryBundle.png",
        iconImg_selected = "SubBtn_StoryBundle_On.png",
        
        -- 標題
        title = common:getLanguageString("@StoryBundle"),
        
        -- 貨幣資訊
        currencyInfos = {{priceStr = "10000_1002_0"}, {priceStr = "10000_1001_0"}},
        
        -- 其他子頁資訊 ----------
        TopisVisible = true,
        LOCK_KEY = GameConfig.LOCK_PAGE_KEY.DAILY_BUNDLE,

        --isRedOn = function() return RedPointManager_getShowRedPoint(RedPointManager.PAGE_IDS.PACKAGE_GOODS_TAB) end,
        activityID = 187,
        gift_Type = GameConfig.GIFT_TYPE.CYCLE_GIFT,
        callFun = function() 
            require("IAP_Act.ActSubPage_Gift"):setEnterIdx(GameConfig.GIFT_TYPE.CYCLE_GIFT)
        end
    }, 
     {
        -- 子頁面名稱 : 召喚禮包
        subPageName = "SummonGift",
        
        -- 分頁 相關
        scriptName = "IAP_Act.ActSubPage_Gift",
        iconImg_normal = "SubBtn_GachaBbundle.png",
        iconImg_selected = "SubBtn_GachaBbundle_On.png",
        
        -- 標題
        title = common:getLanguageString("@GachaBundle"),
        
        -- 貨幣資訊
        currencyInfos = {{priceStr = "10000_1002_0"}, {priceStr = "10000_1001_0"}},
        
        -- 其他子頁資訊 ----------
        TopisVisible = true,
        LOCK_KEY = GameConfig.LOCK_PAGE_KEY.DAILY_BUNDLE,

        --isRedOn = function() return RedPointManager_getShowRedPoint(RedPointManager.PAGE_IDS.PACKAGE_GOODS_TAB) end,
        activityID = 187,
        gift_Type = GameConfig.GIFT_TYPE.SUMMON_GIFT,
        callFun = function() 
            require("IAP_Act.ActSubPage_Gift"):setEnterIdx(GameConfig.GIFT_TYPE.SUMMON_GIFT)
        end
    }, 
     {
        -- 子頁面名稱 : 許願輪禮包
        subPageName = "WishBundle",
        
        -- 分頁 相關
        scriptName = "IAP_Act.ActSubPage_Gift",
        iconImg_normal = "SubBtn_SummonFactionBundle.png",
        iconImg_selected = "SubBtn_SummonFactionBundle_On.png",
        
        -- 標題
        title = common:getLanguageString("@WishingBundle"),
        
        -- 貨幣資訊
        currencyInfos = {{priceStr = "10000_1002_0"}, {priceStr = "10000_1001_0"}},
        
        -- 其他子頁資訊 ----------
        TopisVisible = true,
        LOCK_KEY = GameConfig.LOCK_PAGE_KEY.DAILY_BUNDLE,

        --isRedOn = function() return RedPointManager_getShowRedPoint(RedPointManager.PAGE_IDS.PACKAGE_GOODS_TAB) end,
        activityID = 187,
        gift_Type = GameConfig.GIFT_TYPE.WISHINGWHEEL_GIFT,
        callFun = function() 
            require("IAP_Act.ActSubPage_Gift"):setEnterIdx(GameConfig.GIFT_TYPE.WISHINGWHEEL_GIFT)
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
