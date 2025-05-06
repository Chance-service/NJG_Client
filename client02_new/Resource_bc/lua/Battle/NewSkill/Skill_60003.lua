Skill_60003 = Skill_60003 or { }

require("Battle.NewBattleConst")
require("Battle.NewBattleUtil")
local aliveIdTable = { }
-------------------------------------------------------
--[[
�԰��}�l�ɡA�ᤩ�ħ�����Z�J¾�~(params1)"�ܮzIII"(params2)�F�ᤩ�ħ�����Ԥh¾�~(params3)"�Z�iIII"(params4)�F
�ᤩ�ħ�����ɮv¾�~(params5)"�f��III"(params6)�F�ᤩ�ħ�����k�v¾�~(params7)"����III"(params8)�F
]]--
-------------------------------------------------------
function Skill_60003:castSkill(chaNode, skillType, skillId)
    --����skill data
    --if not triggerTable[chaNode.idx] or triggerTable[chaNode.idx] ~= NewBattleConst.PASSIVE_TRIGGER_TYPE.START_BATTLE then
    --    local skillCfg = ConfigManager:getSkillCfg()[skillId]
    --    chaNode.skillData[skillType][skillId]["COUNT"] = chaNode.skillData[skillType][skillId]["COUNT"] + 1
    --    chaNode.skillData[skillType][skillId]["CD"] = tonumber(skillCfg.cd)
    --end
end
-- ���e�p��ޯ�ؼХ� ���ϥήɦ^��nil
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