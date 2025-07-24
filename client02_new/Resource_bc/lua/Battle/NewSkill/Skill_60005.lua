Skill_60005 = Skill_60005 or { }

require("Battle.NewBattleConst")
require("Battle.NewBattleUtil")
local aliveIdTable = { }
local triggerTable = { }
-------------------------------------------------------
--[[
�靈�@�ު��ĤH�y���ˮ`����200%(params1)�F
�y���v���ĪG����50%(params2)
]]--
-------------------------------------------------------
function Skill_60005:castSkill(chaNode, skillType, skillId)
    --����skill data
    --if not triggerTable[chaNode.idx] or triggerTable[chaNode.idx] ~= NewBattleConst.PASSIVE_TRIGGER_TYPE.START_BATTLE then
    --    local skillCfg = ConfigManager:getSkillCfg()[skillId]
    --    chaNode.skillData[skillType][skillId]["COUNT"] = chaNode.skillData[skillType][skillId]["COUNT"] + 1
    --    chaNode.skillData[skillType][skillId]["CD"] = tonumber(skillCfg.cd)
    --end
end
-- ���e�p��ޯ�ؼХ� ���ϥήɦ^��nil
function Skill_60005:calSkillTarget(chaNode, skillId)
    return nil
end
function Skill_60005:runSkill(chaNode, skillId, resultTable, allPassiveTable, targetTable, attack_params)
    local skillCfg = ConfigManager:getSkillCfg()[skillId]
    local skillLevel = skillId % 10
    local params = common:split(skillCfg.values, ",")

    return resultTable
end

function Skill_60005:isUsable(chaNode, skillType, skillId, triggerType)
    return true
end

function Skill_60005:calSkillSpecialParams(skillId, option)
    local skillCfg = ConfigManager:getSkillCfg()[skillId]
    local params = common:split(skillCfg.values, ",")
    if not option then
        return { 0 }
    end
    if option.auraType == NewBattleConst.PASSIVE_TRIGGER_TYPE.AURA_HEALTH then    -- ����v��
        return { tonumber(params[2]) }
    elseif option.auraType == NewBattleConst.PASSIVE_TRIGGER_TYPE.AURA_DMG then    -- �y���ˮ`
        if option.chaNode then
            if option.chaNode.battleData[NewBattleConst.BATTLE_DATA.SHIELD] > 0 then
                return { tonumber(params[1]) }
            else
                return { 0 }
            end
        else
            return { 0 }
        end
    end
    return { 0 }
end

return Skill_60005