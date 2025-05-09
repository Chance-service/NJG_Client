local thisPageName = 'TowerPassData'

local TowerPassDataBase = {}

local option = {
    handlerMap = {},
}

local Info = {}

function TowerPass_SetInfo(msg)
    local id = msg.rechargeId
    Info[id] = Info[id] or {}
    local info = Info[id]

    info.rechargeId = id
    info.costFlag = msg.costFlag

    local PageCfg = require("TowerPass.TowerPassSubPage_Base"):getPageCfg()
    local stage = PageCfg

    local function buildStageMap(stageList)
        local map = {}
        for i = 1, #stage do
            map[i] = 0
        end
        for _, v in pairs(stageList or {}) do
            if type(v) == "number" then
                for id,data in pairs (stage) do
                    if data.PassStage == v then
                        map[id] = id
                    end
                end
            end
        end
        return map
    end

    info.freeStageId = buildStageMap(msg.freeStageId)
    info.costStageId = buildStageMap(msg.costStageId)
end


function TowerPassDataBase:getData(id)
    return Info[id]
end

local CommonPage = require('CommonPage')

return CommonPage.newSub(TowerPassDataBase, thisPageName, option)
