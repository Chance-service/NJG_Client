Skill_50024 = Skill_50024 or { }

require("Battle.NewBattleConst")
require("Battle.NewBattleUtil")
local aliveIdTable = { }
local triggerTable = { }
-------------------------------------------------------
--[[
自身存活時，敵我雙方擁有"順風"(params1)的Buff時，攻擊力上升30/35/40/45/50/55/60%(params2)
]]--
-------------------------------------------------------
function Skill_50024:castSkill(chaNode, skillType, skillId)
    --紀錄skill data
    if not triggerTable[chaNode.idx] or triggerTable[chaNode.idx] ~= NewBattleConst.PASSIVE_TRIGGER_TYPE.START_BATTLE then
        local skillCfg = ConfigManager:getSkillCfg()[skillId]
        chaNode.skillData[skillType][skillId]["COUNT"] = chaNode.skillData[skillType][skillId]["COUNT"] + 1
        chaNode.skillData[skillType][skillId]["CD"] = tonumber(skillCfg.cd)
    end
end
-- 提前計算技能目標用 不使用時回傳nil
function Skill_50024:calSkillTarget(chaNode, skillId)
    return nil
end
function Skill_50024:runSkill(chaNode, skillId, resultTable, allPassiveTable, targetTable, attack_params)
    local skillCfg = ConfigManager:getSkillCfg()[skillId]
    local skillLevel = skillId % 10
    local params = common:split(skillCfg.values, ",")

    return resultTable
end

function Skill_50024:isUsable(chaNode, skillType, skillId, triggerType)
    return true
end

function Skill_50024:calSkillSpecialParams(skillId, option)
    local skillCfg = ConfigManager:getSkillCfg()[skillId]
    local params = common:split(skillCfg.values, ",")
    if not option then
        return { 0 }
    end
    if option.auraType == NewBattleConst.PASSIVE_TRIGGER_TYPE.AURA_ATK_BY_BUFF then
        if not option.buff then
            return { 0 }
        end
        local haveBuff = false
        for k, v in pairs(option.buff) do
            local mainBuffId = math.floor(k / 100) % 1000
            if mainBuffId == tonumber(params[1]) then
                haveBuff = true
                break
            end
        end
        if haveBuff then
            return { tonumber(params[2]) }
        end
    end
    return { 0 }
end

return Skill_50024