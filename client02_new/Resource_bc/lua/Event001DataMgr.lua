local Const = require('Const_pb')
local Event001DataMgr =  { 
    [Const_pb.ACTIVITY191_CycleStage] = {
        MAINPAGE_CCB = "NGEvent_004_Main.ccbi",
        BATTLEPAGE_CCB = "NGEvent_004_Page.ccbi",
        BATTLEPAGE_CONTENT_CCB = "NGEvent_002_PageContent.ccbi",
        MISSION_CONTENT_CCB = "NGEvent_001_EventMissionContent.ccbi",   -- 共用
        MISSION_TREASURE_CONTENT_NAME = "NGEvent_002_DailyContent",
        BATTLE_BG_IMG = "BG/NGEvent/Event03_Img_Memu04_2.png",
        MAIN_ENTRY_IMG = "Lobby_BannerE003.png",
        TOKEN_ID = 7002,  -- 循環活動2代幣ID
        CHALLANGE_ID = 7003,  -- 循環活動2挑戰體力ID
        STAGE_CFG = ConfigManager:get191StageCfg(),
        FETTER_CONTROL_CFG = ConfigManager:getEvent001ControlCfg(),
        FETTER_MOVEMENT_CFG = ConfigManager:getEvent001ActionCfg(),
        MAIN_SPINE = "NGEvent_01_E001Title",
        REWARD_EQUIP_ID = 12901,
        AVG_KEY = "@Activitystory",
        AVG_TITLE_KEY = "@ActivitystoryTitle",
        --
        openTouchLayer = false,
        isCommonUI = true,
    },
    [Const_pb.ACTIVITY196_CycleStage_Part2] = {
        MAINPAGE_CCB = "NGEvent_003_Main.ccbi",
        BATTLEPAGE_CCB = "NGEvent_003_Page.ccbi",
        BATTLEPAGE_CONTENT_CCB = "NGEvent_002_PageContent.ccbi",
        MISSION_CONTENT_CCB = "NGEvent_001_EventMissionContent.ccbi",   -- 共用
        MISSION_TREASURE_CONTENT_NAME = "NGEvent_002_DailyContent",
        BATTLE_BG_IMG = "BG/NGEvent/Event03_Img_Memu04_2.png",
        MAIN_ENTRY_IMG = "Lobby_BannerE003.png",
        TOKEN_ID = 6999,  -- 循環活動代幣ID
        CHALLANGE_ID = 7000,  -- 循環活動挑戰體力ID
        STAGE_CFG = ConfigManager:get196StageCfg(),
        FETTER_CONTROL_CFG = ConfigManager:getEvent001Control196Cfg(),
        FETTER_MOVEMENT_CFG = ConfigManager:getEvent001Action196Cfg(),
        MAIN_SPINE = "NGEvent_02_E002Title",
        REWARD_EQUIP_ID = 12701,
        AVG_KEY = "@Activitystory2_",
        AVG_TITLE_KEY = "@ActivitystoryTitle2_",
        --
        openTouchLayer = false,
        isCommonUI = true,
    }
}
Event001DataMgr.nowActivityId = 0

return Event001DataMgr