Skill_60004 = Skill_60004 or { }

require("Battle.NewBattleConst")
require("Battle.NewBattleUtil")
local aliveIdTable = { }
local triggerTable = { }
-------------------------------------------------------
--[[
受到傷害時，賦予自身"業火I"(params1)；爆擊時，移除場上所有角色身上"業火"(params2)
]]--
-------------------------------------------------------
function Skill_60004:castSkill(chaNode, skillType, skillId)
    --紀錄skill data
    --if not triggerTable[chaNode.idx] or triggerTable[chaNode.idx] ~= NewBattleConst.PASSIVE_TRIGGER_TYPE.START_BATTLE then
    --    local skillCfg = ConfigManager:getSkillCfg()[skillId]
    --    chaNode.skillData[skillType][skillId]["COUNT"] = chaNode.skillData[skillType][skillId]["COUNT"] + 1
    --    chaNode.skillData[skillType][skillId]["CD"] = tonumber(skillCfg.cd)
    --end
end
-- 提前計算技能目標用 不使用時回傳nil
function Skill_60004:calSkillTarget(chaNode, skillId)
    return nil
end
function Skill_60004:runSkill(chaNode, skillId, resultTable, allPassiveTable, targetTable, attack_params)
    local skillCfg = ConfigManager:getSkillCfg()[skillId]
    local skillLevel = skillId % 10
    local params = common:split(skillCfg.values, ",")

    if triggerTable[chaNode.idx] == NewBattleConst.PASSIVE_TRIGGER_TYPE.AURA_BE_HIT then
        --Get Buff
        local buffTable = { }
        local buffTarTable = { }
        local buffTimeTable = { }
        local buffCountTable = { }

        local target = chaNode
        table.insert(buffTable, tonumber(params[1]))
        table.insert(buffTarTable, target)
        table.insert(buffTimeTable, 999000 * 1000)
        table.insert(buffCountTable, 1)

        resultTable[NewBattleConst.LogDataType.BUFF] = buffTable
        resultTable[NewBattleConst.LogDataType.BUFF_TAR] = buffTarTable
        resultTable[NewBattleConst.LogDataType.BUFF_TIME] = buffTimeTable
        resultTable[NewBattleConst.LogDataType.BUFF_COUNT] = buffCountTable
    elseif triggerTable[chaNode.idx] == NewBattleConst.PASSIVE_TRIGGER_TYPE.AURA_CRI_HIT then
        -- remove buff
        local spClassTable = { }
        local spFuncTable = { }
        local spParamTable = { }
        local spTarTable = { }

        local eList = NgBattleDataManager_getEnemyList(chaNode)
        aliveIdTable = NewBattleUtil:initAliveTable(eList)
        for i = 1, #aliveIdTable do
            local target = eList[aliveIdTable[i]]
            local buffId = self:getRemoveBuffId(target, skillId)
            if buffId > 0 then
                table.insert(spClassTable, NewBattleConst.FunClassType.NEW_BATTLE_UTIL)
                table.insert(spFuncTable, "removeBuff")
                table.insert(spParamTable, { target, buffId, false })
                table.insert(spTarTable, target)
            end
        end
        local fList = NgBattleDataManager_getFriendList(chaNode)
        aliveIdTable = NewBattleUtil:initAliveTable(fList)
        for i = 1, #aliveIdTable do
            local target = fList[aliveIdTable[i]]
            local buffId = self:getRemoveBuffId(target, skillId)
            if buffId > 0 then
                table.insert(spClassTable, NewBattleConst.FunClassType.NEW_BATTLE_UTIL)
                table.insert(spFuncTable, "removeBuff")
                table.insert(spParamTable, { target, buffId, false })
                table.insert(spTarTable, target)
            end
        end

        resultTable[NewBattleConst.LogDataType.SP_FUN_CLASS] = spClassTable
        resultTable[NewBattleConst.LogDataType.SP_FUN_NAME] = spFuncTable
        resultTable[NewBattleConst.LogDataType.SP_FUN_PARAM] = spParamTable
        resultTable[NewBattleConst.LogDataType.SP_FUN_TAR] = spTarTable
    end

    return resultTable
end

function Skill_60004:isUsable(chaNode, skillType, skillId, triggerType)
    if triggerType == NewBattleConst.PASSIVE_TRIGGER_TYPE.AURA_CRI_HIT then
        triggerTable[chaNode.idx] = triggerType
        return true
    end
    if triggerType == NewBattleConst.PASSIVE_TRIGGER_TYPE.AURA_BE_HIT then
        triggerTable[chaNode.idx] = triggerType
        return true
    end
    return false
end

function Skill_60004:getRemoveBuffId(chaNode, skillId)
    local skillCfg = ConfigManager:getSkillCfg()[skillId]
    local skillLevel = skillId % 10
    local params = common:split(skillCfg.values, ",")

    local buff = chaNode.buffData  -- 目標的Buff
    if buff then
        for fullBuffId, buffData in pairs(buff) do
            local mainBuffId = math.floor(fullBuffId / 100) % 1000
            if mainBuffId == tonumber(params[2]) then  -- 業火
                return fullBuffId
            end
        end
    end
    return 0
end

return Skill_60004