Skill_50034 = Skill_50034 or { }

require("Battle.NewBattleConst")
require("Battle.NewBattleUtil")
require("Battle.NgBattleDataManager")
require("Battle.NewSkill.SkillUtil")
local aliveIdTable = { }
-------------------------------------------------------
--[[
�ۨ������z���ˮ`�ɡA�ᤩ�ۨ������O�Ӷˮ`100%(params1)���@��
]]--
-------------------------------------------------------
function Skill_50034:castSkill(chaNode, skillType, skillId)
    --����skill data
    local skillCfg = ConfigManager:getSkillCfg()[skillId]
    chaNode.skillData[skillType][skillId]["COUNT"] = chaNode.skillData[skillType][skillId]["COUNT"] + 1
    chaNode.skillData[skillType][skillId]["CD"] = tonumber(skillCfg.cd)
end
-- ���e�p��ޯ�ؼХ� ���ϥήɦ^��nil
function Skill_50034:calSkillTarget(chaNode, skillId)
    return nil
end
function Skill_50034:runSkill(chaNode, skillId, resultTable, allPassiveTable, targetTable, attack_params)
    local skillCfg = ConfigManager:getSkillCfg()[skillId]
    local skillLevel = skillId % 10
    local params = common:split(skillCfg.values, ",")
    
    local target = self:getSkillTarget(chaNode, skillId)

    local shield = targetTable.dmg or 0
    shield = shield * tonumber(params[1])

    -- ���[Buff
    if resultTable[NewBattleConst.LogDataType.SP_FUN_TAR] then
        table.insert(resultTable[NewBattleConst.LogDataType.SP_FUN_CLASS], NewBattleConst.FunClassType.NG_BATTLE_CHARACTER_UTIL)
        table.insert(resultTable[NewBattleConst.LogDataType.SP_FUN_NAME], "addShield")
        table.insert(resultTable[NewBattleConst.LogDataType.SP_FUN_PARAM], { chaNode, target[1], shield, skillId })
        table.insert(resultTable[NewBattleConst.LogDataType.SP_FUN_TAR], target[1])
    else
        resultTable[NewBattleConst.LogDataType.SP_FUN_CLASS] = { NewBattleConst.FunClassType.NG_BATTLE_CHARACTER_UTIL }
        resultTable[NewBattleConst.LogDataType.SP_FUN_NAME] = { "addShield" }
        resultTable[NewBattleConst.LogDataType.SP_FUN_PARAM] = { { chaNode, target[1], shield, skillId } }
        resultTable[NewBattleConst.LogDataType.SP_FUN_TAR] = { target[1] }
    end

    return resultTable
end

function Skill_50034:isUsable(chaNode, skillType, skillId, triggerType)
    if triggerType ~= NewBattleConst.PASSIVE_TRIGGER_TYPE.BE_CRI_HIT then
        return false
    end
    if not chaNode.skillData[skillType][skillId]["CD"] or chaNode.skillData[skillType][skillId]["CD"] > 0 then
        return false
    end
    return true
end

function Skill_50034:getSkillTarget(chaNode, skillId)
    return { chaNode }
end

return Skill_50034