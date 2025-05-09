Skill_60000 = Skill_60000 or { }

require("Battle.NewBattleConst")
require("Battle.NewBattleUtil")
local aliveIdTable = { }
local triggerTable = { }
-------------------------------------------------------
--[[
戰鬥開始時，敵方戰士職業(params1)生命值提升100%(params2)、普攻吸血提升30%(params3)；自身存活時，敵方所有職業受到治療量下降40%(params4)
]]--
-------------------------------------------------------
function Skill_60000:castSkill(chaNode, skillType, skillId)
    --紀錄skill data
    if not triggerTable[chaNode.idx] or triggerTable[chaNode.idx] ~= NewBattleConst.PASSIVE_TRIGGER_TYPE.START_BATTLE then
        local skillCfg = ConfigManager:getSkillCfg()[skillId]
        chaNode.skillData[skillType][skillId]["COUNT"] = chaNode.skillData[skillType][skillId]["COUNT"] + 1
        chaNode.skillData[skillType][skillId]["CD"] = tonumber(skillCfg.cd)
    end
end
-- 提前計算技能目標用 不使用時回傳nil
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
    if (option.auraType == NewBattleConst.PASSIVE_TRIGGER_TYPE.AURA_ENENY_MAX_HP) and   -- 最大HP
       (option.job == tonumber(params[1])) then   -- 戰士職業
        return { tonumber(params[2]) }
    elseif (option.auraType == NewBattleConst.PASSIVE_TRIGGER_TYPE.AURA_ENENY_RECOVER_HP) and   -- 普攻吸血
           (option.job == tonumber(params[1])) then   -- 戰士職業
        return { tonumber(params[3]) }
    elseif option.auraType == NewBattleConst.PASSIVE_TRIGGER_TYPE.AURA_ENENY_HEALTH then    -- 受到治療
        return { tonumber(params[4]) }
    end
    return { 0 }
end

return Skill_60000