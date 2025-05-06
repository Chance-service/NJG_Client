Skill_60000 = Skill_60000 or { }

require("Battle.NewBattleConst")
require("Battle.NewBattleUtil")
local aliveIdTable = { }
local triggerTable = { }
-------------------------------------------------------
--[[
�԰��}�l�ɡA�Ĥ�Ԥh¾�~(params1)�ͩR�ȴ���100%(params2)�B����l�崣��30%(params3)�F�ۨ��s���ɡA�Ĥ�Ҧ�¾�~����v���q�U��40%(params4)
]]--
-------------------------------------------------------
function Skill_60000:castSkill(chaNode, skillType, skillId)
    --����skill data
    if not triggerTable[chaNode.idx] or triggerTable[chaNode.idx] ~= NewBattleConst.PASSIVE_TRIGGER_TYPE.START_BATTLE then
        local skillCfg = ConfigManager:getSkillCfg()[skillId]
        chaNode.skillData[skillType][skillId]["COUNT"] = chaNode.skillData[skillType][skillId]["COUNT"] + 1
        chaNode.skillData[skillType][skillId]["CD"] = tonumber(skillCfg.cd)
    end
end
-- ���e�p��ޯ�ؼХ� ���ϥήɦ^��nil
function Skill_60000:calSkillTarget(chaNode, skillId)
    return nil
end
function Skill_60000:runSkill(chaNode, skillId, resultTable, allPassiveTable, targetTable, attack_params)
    local skillCfg = ConfigManager:getSkillCfg()[skillId]
    local skillLevel = skillId % 10
    local params = common:split(skillCfg.values, ",")

    return resultTable
end

function Skill_60000:isUsable(chaNode, skillType, skillId, triggerType)
    return true
end

function Skill_60000:calSkillSpecialParams(skillId, option)
    local skillCfg = ConfigManager:getSkillCfg()[skillId]
    local params = common:split(skillCfg.values, ",")
    if not option then
        return { 0 }
    end
    if (option.auraType == NewBattleConst.PASSIVE_TRIGGER_TYPE.AURA_ENENY_MAX_HP) and   -- �̤jHP
       (option.job == tonumber(params[1])) then   -- �Ԥh¾�~
        return { tonumber(params[2]) }
    elseif (option.auraType == NewBattleConst.PASSIVE_TRIGGER_TYPE.AURA_ENENY_RECOVER_HP) and   -- ����l��
           (option.job == tonumber(params[1])) then   -- �Ԥh¾�~
        return { tonumber(params[3]) }
    elseif option.auraType == NewBattleConst.PASSIVE_TRIGGER_TYPE.AURA_ENENY_HEALTH then    -- ����v��
        return { tonumber(params[4]) }
    end
    return { 0 }
end

return Skill_60000