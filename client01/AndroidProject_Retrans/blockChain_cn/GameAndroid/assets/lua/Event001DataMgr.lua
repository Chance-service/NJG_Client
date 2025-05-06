local Const = require('Const_pb')
local Event001DataMgr =  { 
    [Const_pb.ACTIVITY191_CycleStage] = {
        MAINPAGE_CCB = "NGEvent_001_Main.ccbi",
        BATTLEPAGE_CCB = "NGEvent_001_Page.ccbi",
        BATTLEPAGE_CONTENT_CCB = "NGEvent_001_PageContent.ccbi",
        MISSION_CONTENT_CCB = "NGEvent_001_EventMissionContent.ccbi",   -- �@��
        MISSION_TREASURE_CONTENT_NAME = "NGEvent_001_DailyContent",
        BATTLE_BG_IMG = "BG/NGEvent_001/Event001_Img02_02.png",
        STORY_BG_IMG = "BG/NGEvent_001/AlbumReview_001_Event.png",
        MAIN_ENTRY_IMG = "Lobby_BannerE001.png",
        TOKEN_ID = 7002,  -- �`������2�N��ID
        CHALLANGE_ID = 7003,  -- �`������2�D����OID
        STAGE_CFG = ConfigManager:get191StageCfg(),
        FETTER_CONTROL_CFG = ConfigManager:getEvent001ControlCfg(),
        FETTER_MOVEMENT_CFG = ConfigManager:getEvent001ActionCfg(),
        MAIN_SPINE = "NGEvent_01_E001Title",
        REWARD_EQUIP_ID = 12801,
        AVG_KEY = "@Activitystory",
        AVG_TITLE_KEY = "@ActivitystoryTitle",
        --
        openTouchLayer = false,
        isCommonUI = false,
    },
    [Const_pb.ACTIVITY196_CycleStage_Part2] = {
        MAINPAGE_CCB = "NGEvent_003_Main.ccbi",
        BATTLEPAGE_CCB = "NGEvent_003_Page.ccbi",
        BATTLEPAGE_CONTENT_CCB = "NGEvent_002_PageContent.ccbi",
        MISSION_CONTENT_CCB = "NGEvent_001_EventMissionContent.ccbi",   -- �@��
        MISSION_TREASURE_CONTENT_NAME = "NGEvent_002_DailyContent",
        BATTLE_BG_IMG = "BG/NGEvent/Event03_Img_Memu04_2.png",
        STORY_BG_IMG = "BG/NGEvent/AlbumReview_003_Event.png",
        MAIN_ENTRY_IMG = "Lobby_BannerE003.png",
        TOKEN_ID = 6999,  -- �`�����ʥN��ID
        CHALLANGE_ID = 7000,  -- �`�����ʬD����OID
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