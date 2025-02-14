--[[ 
    name: SummonDataMgr
    desc: 召喚頁面 資料管理
    author: youzi
    update: 2023/10/2 16:12
    description: 
--]]

local InfoAccesser = require("Util.InfoAccesser")

--[[ 本體 ]]
local Inst = {}

Inst.RewardType = {
    HERO = 1,           -- type 7 英雄碎片
    AW_EQUIP = 2,       -- type 3 專武碎片
    ITEM = 3,           -- type 3 一般道具
    EQUIP = 4,          -- type 4 裝備
    PLAYER_ATTR = 5,    -- type 1 玩家屬性
    RUNE = 6,           -- type 9 符石
}

--[[ 完整的專武 需要多少碎片 ]]
Inst.FULL_EQUIP_REWARD_PIECE_COUNT = 50

--[[ 子頁面 配置 ]]
Inst.SubPageCfgs = {
   {
       subPageName = "PickUp",
   
       -- 分頁 相關
       scriptName = "Summon.SummonSubPage_PickUp",
       iconImg_normal = "Imagesetfile/i18n_Button/SubBtn_PickUp.png",
       iconImg_selected = "Imagesetfile/i18n_Button/SubBtn_PickUp_On.png",
       
       -- 標題
       title = "@Summon.PickUp.title",
   
       -- 貨幣資訊 
       currencyInfos = {
           { priceStr = "10000_1001_0" },
       },
       
       -- 其他子頁資訊 ----------
       ccbiFile = "Summon_Pickup.ccbi",
       
       spineSummon = "Spine/NGUI,NGUI_53_Gacha1Summon",
       spineBG = "Spine/NG2D,NG2D_01",
       
       spineAnimName_bg_idle = "animation",
       spineAnimName_bg_summon = "animation",
   
       spineAnimName_summon_idle = "wait",
       spineAnimName_summon_summon_list = {
           "summonN",
           "summonSR",
           "summonSSR",
       },
       
       isFreeSummonAble = true,
   
       --Help內容
       Help="HELP_PICKUPSUMMON",
   
       summonBgm = "pickup_summon_bgm.mp3",
   },
    {
        subPageName = "Premium2",

        -- 分頁 相關
        scriptName = "Summon.SummonSubPage_Normal2",
        iconImg_normal = "Imagesetfile/i18n_Button/SubBtn_HeroSummon.png",
        iconImg_selected = "Imagesetfile/i18n_Button/SubBtn_HeroSummon_On.png",
        
        -- 標題
        title = "@Summon.Premium.title",

        -- 貨幣資訊 
        currencyInfos = {
            { priceStr = "10000_1001_0" },
            { priceStr = "30000_6004_0" },
        },
        
        -- 其他子頁資訊 ----------
        ccbiFile = "Summon_Premium.ccbi",
        
        spineSummon = "Spine/NGUI,NGUI_53_Gacha1Summon",
        spineBG = "Spine/NGUI,NGUI_53_Gacha1Summon_BG",
        
        spineAnimName_bg_idle = "wait",
        spineAnimName_bg_summon = "summon",

        spineAnimName_summon_idle = "wait",
        spineAnimName_summon_summon_list = {
            "summonN",
            "summonSR",
            "summonSSR",
        },
        
        isFreeSummonAble = true,

        --Help內容
        Help="HELP_NORMALSUMMON",

        summonBgm = "normal_summon_bgm.mp3",

        isRedOn = function() return RedPointManager_getShowRedPoint(RedPointManager.PAGE_IDS.SUMMON_NORMAL_TAB) end,
    },
    {
        subPageName = "Premium",

        -- 分頁 相關
        scriptName = "Summon.SummonSubPage_Normal",
        iconImg_normal = "Imagesetfile/i18n_Button/SubBtn_HeroSummon.png",
        iconImg_selected = "Imagesetfile/i18n_Button/SubBtn_HeroSummon_On.png",
        
        -- 標題
        title = "@Summon.Premium.title",

        -- 貨幣資訊 
        currencyInfos = {
            { priceStr = "10000_1001_0" },
            { priceStr = "30000_6004_0" },
        },
        
        -- 其他子頁資訊 ----------
        ccbiFile = "Summon_Premium.ccbi",
        
        spineSummon = "Spine/NGUI,NGUI_53_Gacha1Summon",
        spineBG = "Spine/NGUI,NGUI_53_Gacha1Summon_BG",
        
        spineAnimName_bg_idle = "wait",
        spineAnimName_bg_summon = "summon",

        spineAnimName_summon_idle = "wait",
        spineAnimName_summon_summon_list = {
            "summonN",
            "summonSR",
            "summonSSR",
        },
        
        isFreeSummonAble = true,

        --Help內容
        Help="HELP_NORMALSUMMON",

        summonBgm = "normal_summon_bgm.mp3",

        isRedOn = function() return RedPointManager_getShowRedPoint(RedPointManager.PAGE_IDS.SUMMON_NORMAL_TAB) end,
    },

   --{
   --    -- 子頁面名稱 : 專武
   --    subPageName = "Arm",
   --
   --    -- 分頁 相關
   --    scriptName = "Summon.SummonSubPage_Arm",
   --    iconImg_normal = "SubBtn_SummonArms.png",
   --    iconImg_selected = "SubBtn_SummonArms_On.png",
   --    
   --    -- 標題
   --    title = "@Summon.Weapon.title",
   --    
   --    -- 貨幣資訊 
   --    currencyInfos = {
   --         { priceStr = "10000_1001_0" },
   --         { priceStr = "30000_6011_0" },
   --    },
   --    
   --    -- 其他子頁資訊 ----------
   --    ccbiFile = "Summon_Arms.ccbi",
   --    spineSummon = "Spine/NGUI,NGUI_92_SummonArms",
   --    spineBG = "Spine/NGUI,NGUI_92_SummonArms",
   --    
   --    spineAnimName_bg_idle = "idle2",
   --    spineAnimName_bg_summon = "animation",
   --
   --    spineAnimName_summon_idle = "idle2",
   --    spineAnimName_summon_summon_list = {
   --        "animation",
   --        "animation",
   --        "animation",
   --    },
   --    
   --    --Help內容
   --    Help="HELP_AW_SUMMON",
   --    -- 解鎖條件KEY
   --    LOCK_KEY = GameConfig.LOCK_PAGE_KEY.ANCIENT_WEAPON,
   --
   --    summonBgm = "friend_summon_bgm.mp3",
   --},
    {
        -- 子頁面名稱 : 友情
        subPageName = "Friend",

        -- 分頁 相關
        scriptName = "Summon.SummonSubPage_Friend",
        iconImg_normal = "Imagesetfile/i18n_Button/SubBtn_FriendSummon.png",
        iconImg_selected = "Imagesetfile/i18n_Button/SubBtn_FriendSummon_On.png",
        
        -- 標題
        title = "@Summon.Friend.title",
        
        -- 貨幣資訊 
        currencyInfos = {
            { priceStr = "10000_1025_0" },
        },
        
        -- 其他子頁資訊 ----------
        ccbiFile = "Summon_Friend.ccbi",
        spineSummon = "Spine/NGUI,NGUI_53_Gacha2Summon",
        spineBGs = {
            "Spine/Bg/LoginBG,LoginBG02",
            "Spine/Bg/LoginBG,LoginBG04",   
            "Spine/Bg/LoginBG,LoginBG05",
        },
        
        spineAnimName_bg_idle = "animation3",
        spineAnimName_bg_summon = "animation4",

        spineAnimName_summon_idle = "wait",
        spineAnimName_summon_summon = "sumon",

        --Help內容
        Help="HELP_FRIENDSUMMON",

        summonBgm = "friend_summon_bgm.mp3",
    },
    {
        -- 子頁面名稱 : 種族
        subPageName = "Faction",

        -- 分頁 相關
        scriptName = "Summon.SummonSubPage_Faction",
        iconImg_normal = "Imagesetfile/i18n_Button/SubBtn_FactSummon.png",
        iconImg_selected = "Imagesetfile/i18n_Button/SubBtn_FactSummon_On.png",
        
        -- 標題
        title = "@Summon.Faction.title",

        -- 貨幣資訊 
        currencyInfos = {
            { priceStr = "30000_6003_0" },
        },
        
        -- 其他子頁資訊 ----------
        ccbiFile = "Summon_Faction.ccbi",

        spineAnimName_idle = "wait",
        spineAnimName_select = "select",
        spineAnimName_summon = "summon",

        summonType2Times = {
            [1] = 1,
            [2] = 5,
        },

        summonType2Action = {
            [1] = 1,
            [2] = 2,
        },

        faction2PriceDatas = {
            [1] = {"30000_6003_1", "30000_6003_5"},
            [2] = {"30000_6003_1", "30000_6003_5"},
            [3] = {"30000_6003_1", "30000_6003_5"},
            [4] = {"30000_6003_1", "30000_6003_5"},
            [5] = {"30000_6003_1", "30000_6003_5"},
        },

        faction2Milestone = {
            [1] = 1000,
            [2] = 1000,
            [3] = 1000,
            [4] = 2000,
            [5] = 2000,
        },
        

        spineSummon = "Spine/NGUI,NGUI_53_Gacha3Summon",
        spineAnimName_select = "select",
        spineAnimName_summon = "summon",
	
	    Help="HELP_FACTIONSUMMON",
        -- 解鎖條件KEY
        LOCK_KEY = GameConfig.LOCK_PAGE_KEY.SUMMON_FACTION,

        summonBgm = "Faction_summon_bgm.mp3",
    },
}

--[[ 取得 子頁面 配置 ]]
function Inst:getSubPageCfg (subPageName)
    for idx, cfg in ipairs(Inst.SubPageCfgs) do
        if cfg.subPageName == subPageName then return cfg end
    end
    return nil
end

return Inst