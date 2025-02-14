Skill_3140 = Skill_3140 or { }

require("Battle.NewBattleConst")
require("Battle.NewBattleUtil")
local aliveIdTable = { }
-------------------------------------------------------
--[[
�}���ɽᤩ�Ĥ��H���ؼ�"�ԳN��wI/�ԳN��wI/�ԳN��wI/�ԳN��wI"(params1)
]]--
-------------------------------------------------------
function Skill_3140:castSkill(chaNode, skillType, skillId)
    --����skill data
    local skillCfg = ConfigManager:getSkillCfg()[skillId]
    chaNode.skillData[skillType][skillId]["COUNT"] = chaNode.skillData[skillType][skillId]["COUNT"] + 1
    chaNode.skillData[skillType][skillId]["CD"] = tonumber(skillCfg.cd)
end
-- ���e�p��ޯ�ؼХ� ���ϥήɦ^��nil
function Skill_3140:calSkillTarget(chaNode, skillId)
    return nil
end
function Skill_3140:runSkill(chaNode, skillId, resultTable, allPassiveTable, targetTable, attack_params)
    local skillCfg = ConfigManager:getSkillCfg()[skillId]
    local skillLevel = skillId % 10
    local params = common:split(skillCfg.values, ",")
    local eList = NgBattleDataManager_getEnemyList(chaNode)
    --�H���ؼ�
    local target = SkillUtil:getRandomTarget(chaNode, eList, 1)
    local buffTable = { }
    local buffTarTable = { }
    local buffTimeTable = { }
    local buffCountTable = { }
    --Get Buff
    if #target > 0 then
        table.insert(buffTable, tonumber(params[1]))
        table.insert(buffTarTable, target[1])
        table.insert(buffTimeTable, 999000 * 1000)
        table.insert(buffCountTable, 1)
    end

    resultTable[NewBattleConst.LogDataType.BUFF] = buffTable
    resultTable[NewBattleConst.LogDataType.BUFF_TAR] = buffTarTable
    resultTable[NewBattleConst.LogDataType.BUFF_TIME] = buffTimeTable
    resultTable[NewBattleConst.LogDataType.BUFF_COUNT] = buffCountTable
    return resultTable
end

function Skill_3140:isUsable(chaNode, skillType, skillId, triggerType)
    if not chaNode.skillData[skillType][skillId]["COUNT"] or chaNode.skillData[skillType][skillId]["COUNT"] > 0 then
        return false
    end
    return true
end

return Skill_3140