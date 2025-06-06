--[[ 
    name: 大廳 跑馬燈橫幅
    author: youzi
    description: 顯示大廳活動橫幅，支援多平台與活動檢查邏輯
--]]

require("Util.LockManager")
local CommMarqueeBanner = require("CommComp.CommMarqueeBanner")
local NodeHelper = require("NodeHelper")
local TimeDateUtil = require("Util.TimeDateUtil")
require("Activity.ActivityInfo")

local BANNER_WIDTH = 680

-- 平台識別
local function getCurrentPlatformID()
    if Golb_Platform_Info.is_h365 then return 1 end
    if Golb_Platform_Info.is_r18 then return 2 end
    if Golb_Platform_Info.is_kuso then return 6 end
    if Golb_Platform_Info.is_erolabs then return 7 end
    if Golb_Platform_Info.is_op then return 8 end
    if Golb_Platform_Info.is_aplus then return 9 end
    return 1
end

-- 檢查平台是否允許顯示
local function isPlatformAllowed(offList, platformID)
    for _, p in ipairs(common:split(offList or "", ",")) do
        if tonumber(p) == platformID then return false end
    end
    return true
end

-- 檢查活動是否啟用與特例
local function isActivityOpen(cfg)
    local now = os.time()
    local open = (cfg.startTime and now >= cfg.startTime and now <= cfg.endTime)
              or (cfg.endTime and cfg.endTime == 0)

    if cfg.activityId == 159 then
        open = open and not require("Activity.DailyBundleData"):isGetAll()
    elseif cfg.activityId == 179 then
        open = open and not require("IAP.IAPSubPage_StepBundle"):isBuyAll()
    end

    return open
end
--跳過
local function shouldSkipBanner(cfg, platformID)
    if cfg.group ~= 0 then return true end
    if not isActivityOpen(cfg) then return true end
    if not isPlatformAllowed(cfg.offPlateform, platformID) then return true end
    if not Activity2BannerSetting[cfg.activityId] then return true end
    return false
end

-- 活動進入設定
local Activity2BannerSetting = {
    [Const_pb.ACTIVITY146_CHOSEN_ONE] = {
        getEndTime = function() return nil end,
        onEnter = function()
            if LockManager_getShowLockByPageName(GameConfig.LOCK_PAGE_KEY.SUMMON) then
                MessageBoxPage:Msg_Box(LockManager_getLockStringByPageName(GameConfig.LOCK_PAGE_KEY.SUMMON))
            else
                require("Summon.SummonPage"):setEntrySubPage(1)
                PageManager.pushPage("Summon.SummonPage")
            end
        end
    },
    [Const_pb.ACTIVITY161_SUPPORT_CALENDER] = {
        getEndTime = function() return nil end,
        onEnter = function()
            if LockManager_getShowLockByPageName(GameConfig.LOCK_PAGE_KEY.CALENDAR) then
                MessageBoxPage:Msg_Box(LockManager_getLockStringByPageName(GameConfig.LOCK_PAGE_KEY.CALENDAR))
            else
                require("IAP.IAPPage"):setEntrySubPage("Calendar")
                PageManager.pushPage("IAP.IAPPage")
            end
        end
    },
    [Const_pb.ACTIVITY163_GROWTH_CH] = {
        onEnter = function()
            if LockManager_getShowLockByPageName(GameConfig.LOCK_PAGE_KEY.GROWTH_BUNDLE) then
                MessageBoxPage:Msg_Box(LockManager_getLockStringByPageName(GameConfig.LOCK_PAGE_KEY.GROWTH_BUNDLE))
            else
                require("IAP.IAPPage"):setEntrySubPage("LevelFound")
                PageManager.pushPage("IAP.IAPPage")
            end
        end
    },
    [159] = {
        onEnter = function()
            if LockManager_getShowLockByPageName(GameConfig.LOCK_PAGE_KEY.DAILY_RECHARGE) then
                MessageBoxPage:Msg_Box(LockManager_getLockStringByPageName(GameConfig.LOCK_PAGE_KEY.DAILY_RECHARGE))
            else
                PageManager.pushPage("DailyBundlePage")
            end
        end
    },
    [160] = {
        onEnter = function()
            if LockManager_getShowLockByPageName(GameConfig.LOCK_PAGE_KEY.FIRST_RECHARGE) then
                MessageBoxPage:Msg_Box(LockManager_getLockStringByPageName(GameConfig.LOCK_PAGE_KEY.FIRST_RECHARGE))
            else
                require("MainScenePage").onJumpFirstRecharge()
            end
        end
    },
    [179] = {
        onEnter = function()
            if LockManager_getShowLockByPageName(GameConfig.LOCK_PAGE_KEY.STEPBUNDLE) then
                MessageBoxPage:Msg_Box(LockManager_getLockStringByPageName(GameConfig.LOCK_PAGE_KEY.STEPBUNDLE))
            else
                local StepBundle = require("IAP.IAPSubPage_StepBundle")
                if StepBundle:isBuyAll() then
                    MessageBoxPage:Msg_Box(common:getLanguageString("@ERRORCODE_10000"))
                else
                    require("IAP.IAPPage"):setEntrySubPage("StepBundle")
                    PageManager.pushPage("IAP.IAPPage")
                end
            end
        end
    },
    -- 999 : 水晶商城 > 月卡
    [999] = {
        onEnter = function()
            if LockManager_getShowLockByPageName(GameConfig.LOCK_PAGE_KEY.MONTHLY_CARD) then
                MessageBoxPage:Msg_Box(LockManager_getLockStringByPageName(GameConfig.LOCK_PAGE_KEY.MONTHLY_CARD))
            else
                require("IAP.IAPPage"):setEntrySubPage("MonthCard")
                PageManager.pushPage("IAP.IAPPage")
            end
        end
    },
    [147] = {
        onEnter = function()
            if LockManager_getShowLockByPageName(GameConfig.LOCK_PAGE_KEY.WISHING_WELL) then
                MessageBoxPage:Msg_Box(LockManager_getLockStringByPageName(GameConfig.LOCK_PAGE_KEY.WISHING_WELL))
            else
                PageManager.pushPage("WishingWell.WishingWellPage")
            end
        end
    },
    [172] = { onEnter = function() MainFrame_onBackpackPageBtn("PickUp") end },
    [173] = { onEnter = function() MainFrame_onBackpackPageBtn("PickUp2") end },
    -- 循環活動191
    [Const_pb.ACTIVITY191_CycleStage] = {
        onEnter = function (_page)
            if not ActivityInfo:getActivityIsOpenById(Const_pb.ACTIVITY191_CycleStage) then
                MessageBoxPage:Msg_Box(common:getLanguageString("@CurrentActivityIsClosed"))
                return
            end
            if LockManager_getShowLockByPageName(GameConfig.LOCK_PAGE_KEY.Event001) then
                MessageBoxPage:Msg_Box(LockManager_getLockStringByPageName(GameConfig.LOCK_PAGE_KEY.Event001))
            else
                local MainScenePage = require("MainScenePage")
                MainScenePage.onFunction("onActivity", nil)
                PageManager.popAllPage()
            end
        end,
    },
    -- 循環活動196
    [Const_pb.ACTIVITY196_CycleStage_Part2] = {
        onEnter = function (_page)
            if not ActivityInfo:getActivityIsOpenById(Const_pb.ACTIVITY196_CycleStage_Part2) then
                MessageBoxPage:Msg_Box(common:getLanguageString("@CurrentActivityIsClosed"))
                return
            end
            if LockManager_getShowLockByPageName(GameConfig.LOCK_PAGE_KEY.Event001) then
                MessageBoxPage:Msg_Box(LockManager_getLockStringByPageName(GameConfig.LOCK_PAGE_KEY.Event001))
            else
                local MainScenePage = require("MainScenePage")
                MainScenePage.onFunction("onActivity", nil)
                PageManager.popAllPage()
            end
        end,
    },
    [197] = {
        onEnter = function(page)
            if type(page) == "string" then
                require("Summon.SummonPage"):setEntrySubPage(page)
            end
            MainFrame_onBackpackPageBtn()
        end
    },
    [998] = {
        onEnter = function(_, url)
            if not url then
                MessageBoxPage:Msg_Box("URL EMPTY")
            else
                common:openURL(url)
            end
        end
    },
    -- 997 : 商店 > 皮膚商店
    [997] = {
        onEnter = function ()
            if LockManager_getShowLockByPageName(GameConfig.LOCK_PAGE_KEY.SHOP) then
                MessageBoxPage:Msg_Box(LockManager_getLockStringByPageName(GameConfig.LOCK_PAGE_KEY.SHOP))
            else
                require("ShopControlPage")
                ShopTypeContainer_SetSubPageType(16)
                PageManager.pushPage("ShopControlPage")
            end
        end,
    },
    [9999] = { onEnter = function() end }
}

-- 主模組
local LobbyMarqueeBanner = {}
local LobbyMarqueeBannerContent = {}

function LobbyMarqueeBanner:new()
    local Inst = {}

    Inst._isInited = false
    Inst.commMarqueeBanner = nil

    function Inst:init()
        if self._isInited then return self end

        local cfgList = {}
        for _, v in pairs(ConfigManager:getBannerCfg()) do
            if v.group == 0 then table.insert(cfgList, v) end
        end

        self.commMarqueeBanner = CommMarqueeBanner:new():init({
            contentScript = LobbyMarqueeBannerContent,
            objPoolSize = math.min(#cfgList * 2, 2),
            displayCount = 2
        })

        self:updateBanners()
        ActivityInfo.onUpdate:on(function() self:updateBanners() end)

        self._isInited = true
        return self
    end

    function Inst:updateBanners()
        local bannerInfos = {}
        local bannerCfgs = ConfigManager:getBannerCfg()
        local platformID = getCurrentPlatformID()

        for _, cfg in ipairs(bannerCfgs) do
            local shouldSkip = false

            if cfg.group ~= 0 then shouldSkip = true end
            if not isActivityOpen(cfg) then shouldSkip = true end
            if not isPlatformAllowed(cfg.offPlateform, platformID) then shouldSkip = true end

            local setting = Activity2BannerSetting[cfg.activityId]
            if not setting then shouldSkip = true end

            if not shouldSkip then
                local info = {
                    pos = #bannerInfos * BANNER_WIDTH,
                    bg = (cfg.Image or "") .. ".png",
                    url = cfg.url,
                    onEnter = setting.onEnter
                }

                if cfg.activityId == 197 then
                    info.PageName = "PickUp" .. (cfg.Page or "")
                end

                if setting.getEndTime then
                    local endTime = setting.getEndTime()
                    if endTime then
                        info.counter = {
                            endTime = endTime,
                            offset = setting.counterOffset,
                        }
                    end
                end

                table.insert(bannerInfos, info)
            end
        end

        self.commMarqueeBanner:setBannerInfos(bannerInfos, #bannerInfos * BANNER_WIDTH)
    end

    function Inst:getContainer()
        return self.commMarqueeBanner.container
    end

    function Inst:exit()
        if self.commMarqueeBanner then
            self.commMarqueeBanner:clear()
        end
    end

    return Inst
end

function LobbyMarqueeBanner:jumpActivityById(id)
    local setting = Activity2BannerSetting[id]
    setting.onEnter()
end

-- 內容腳本
function LobbyMarqueeBannerContent:new()
    local inst = {
        container = nil,
        counterEndTime = nil,
        timeNode = nil
    }

    function inst:init()
        self.container = ScriptContentBase:create("CommMarqueeBannerContent.ccbi")
        self.timeNode = self.container:getVarNode("timeNode")
        return self
    end

    function inst:execute()
        if not self.counterEndTime then return end
        local left = self.counterEndTime - os.time()
        local d = TimeDateUtil:utcTime2Date(left)
        d.day = d.day - 1
        local str = string.format("%02dD:%02dH:%02dM", d.day, d.hour, d.min)
        NodeHelper:setStringForLabel(self.container, { timeTxt = str })
    end

    function inst:getContainer()
        return self.container
    end

    function inst:setData(data)
        data = data or {}
        self:setCounter(data.counter)
        NodeHelper:setSpriteImage(self.container, {
            bgImg = data.bg or "Image_Empty.png"
        })
    end

    function inst:setCounter(counter)
        local show = true
        if not counter then
            show = false
        else
            if counter.endTime then
                self.counterEndTime = counter.endTime
            end
            if counter.offset then
                self.timeNode:setPosition(ccp(counter.offset.x, counter.offset.y))
            end
        end
        if not self.counterEndTime then show = false end
        self.timeNode:setVisible(show)
    end

    return inst
end

return LobbyMarqueeBanner
