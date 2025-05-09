Skill_60003 = Skill_60003 or { }

require("Battle.NewBattleConst")
require("Battle.NewBattleUtil")
local aliveIdTable = { }
-------------------------------------------------------
--[[
戰鬥開始時，賦予敵我雙方坦克職業(params1)"脆弱III"(params2)；賦予敵我雙方戰士職業(params3)"蠻勇III"(params4)；
賦予敵我雙方補師職業(params5)"逆風III"(params6)；賦予敵我雙方法師職業(params7)"順風III"(params8)；
]]--
-------------------------------------------------------
function Skill_60003:castSkill(chaNode, skillType, skillId)
    --紀錄skill data
    --if not triggerTable[chaNode.idx] or triggerTable[chaNode.idx] ~= NewBattleConst.PASSIVE_TRIGGER_TYPE.START_BATTLE then
    --    local skillCfg = ConfigManager:getSkillCfg()[skillId]
    --    chaNode.skillData[skillType][skillId]["COUNT"] = chaNode.skillData[skillType][skillId]["COUNT"] + 1
    --    chaNode.skillData[skillType][skillId]["CD"] = tonumber(skillCfg.cd)
    --end
end
-- 提前計算技能目標用 不使用時回傳nil
function Skill_60003:calSkillTarget(chaNode, skillId)
    return nil
end
function Skill_60003:runSkill(chaNode, skillId, resultTable, allPassiveTable, targetTable, attack_params)
    local skillCfg = ConfigManager:getSkillCfg()[skillId]
    local skillLevel = skillId % 10
    local params = common:split(skillCfg.values, ",")

    --Get Buff
    local buffTable = { }
    local buffTarTable = { }
    local buffTimeTable = { }
    local buffCountTable = { }

    --Get Buff
    local target = chaNode
    local buffId = self:calSkillBuff(skillId, target.otherData[NewBattleConst.OTHER_DATA.CFG].Job)
    if buffId > 0 then
        table.insert(buffTable, buffId)
        table.insert(buffTarTable, target)
        table.insert(buffTimeTable, 999000 * 1000)
        table.insert(buffCountTable, 1)
    end

    resultTable[NewBattleConst.LogDataType.BUFF] = buffTable
    resultTable[NewBattleConst.LogDataType.BUFF_TAR] = buffTarTable
    resultTable[NewBattleConst.LogDataType.BUFF_TIME] = buffTimeTable
    resultTable[NewBattleConst.LogDataType.BUFF_COUNT] = buffCountTable

    return resultTable
end

function Skill_60003:isUsable(chaNode, skillType, skillId, triggerType)
    if triggerType == NewBattleConst.PASSIVE_TRIGGER_TYPE.AURA_START_BATTLE then
        return true
    end
    return false
end

function Skill_60003:calSkillBuff(skillId, job)
    local skillCfg = ConfigManager:getSkillCfg()[skillId]
    local params = common:split(skillCfg.values, ",")
    if not job or not skillCfg then
        return 0
    end
    if job == tonumber(params[1]) then
        return tonumber(params[2])
    end
    if job == tonumber(params[3]) then
        return tonumber(params[4])
    end
    if job == tonumber(params[5]) then
        return tonumber(params[6])
    end
    if job == tonumber(params[7]) then
        return tonumber(params[8])
    end
    return 0
end

return Skill_60003