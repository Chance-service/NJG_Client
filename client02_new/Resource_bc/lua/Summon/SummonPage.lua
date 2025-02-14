--[[ 
    name: SummonPage
    desc: 召喚頁面
    author: youzi
    update: 2023/10/02 16:10
    description: 
--]]

--[[ 字典 ]] -- (若有將該.lang檔轉寫入Language.lang中可移除此處與該.lang檔)
-- __lang_loaded = __lang_loaded or {}
-- if not __lang_loaded["Lang/Summon.lang"] then
--    __lang_loaded["Lang/Summon.lang"] = true
--    Language:getInstance():addLanguageFile("Lang/Summon.lang")
-- end

--[[ 通用 分頁列 容器 頁面 ]]
local CommTabStoragePage = require("Comm.CommTabStoragePage")

--[[ 資料管理 ]]
local SummonDataMgr = require("Summon.SummonDataMgr")

--[[ 頁面名稱 ]]
local PAGE_NAME = "Summon.SummonPage"
--[[ 函式對照 ]]
local HANDLER_MAP = nil
--[[ 協定 ]]
local OPCODES = nil

local page = CommTabStoragePage:generateCommPage(PAGE_NAME, HANDLER_MAP, OPCODES, function ()

    local cfgs = {}

    for idx, val in ipairs(SummonDataMgr.SubPageCfgs) do while true do

        -- 若 為 活動
        if val.activityID ~= nil then
            -- 若 非開啟 則 忽略
            if ActivityInfo:getActivityIsOpenById(val.activityID) == false then
                break -- continue
            end
        end

        cfgs[#cfgs+1] = val

    break end end

    return cfgs
end)

local base_onExit = page.onExit
page.onExit = function (container)
    base_onExit(container)
    require("Summon.SummonResultPage"):releaseStaticRewardItemPool()

    PageManager.setIsInSummonPage(false)
    setCCBMenuAnimation("mBackpackPageBtn", "Normal")
    local currPage = MainFrame:getInstance():getCurShowPageName()
    if currPage == "NgBattlePage" then
        local sceneHelper = require("Battle.NgFightSceneHelper")
        sceneHelper:setGameBgm()
    else
        SoundManager:getInstance():playGeneralMusic()
    end
end

return page