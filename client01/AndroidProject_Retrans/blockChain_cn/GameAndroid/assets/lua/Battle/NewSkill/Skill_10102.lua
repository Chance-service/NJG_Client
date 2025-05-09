Skill_10102 = Skill_10102 or { }

require("Battle.NewBattleConst")
require("Battle.NewBattleUtil")
require("Battle.NgBattleDataManager")
require("Battle.NewSkill.SkillUtil")
local aliveIdTable = { }
local triggerTable = { }
-------------------------------------------------------
--[[
每4/3/2(params1)次普通攻擊，下一次普通攻擊必定爆擊，並賦予自身"夜半的絕色(減傷30%/40%/50%)"(params2)3層
]]--
-------------------------------------------------------
function Skill_10102:castSkill(chaNode, skillType, skillId)
    --紀錄skill data
    if not triggerTable[chaNode.idx] or triggerTable[chaNode.idx] == NewBattleConst.PASSIVE_TRIGGER_TYPE.ATK_MUST_CRI then
        local skillCfg = ConfigManager:getSkillCfg()[skillId]
        chaNode.skillData[skillType][skillId]["COUNT"] = chaNode.skillData[skillType][skillId]["COUNT"] + 1
        chaNode.skillData[skillType][skillId]["CD"] = tonumber(skillCfg.cd)
    end
end
-- 提前計算技能目標用 不使用時回傳nil
function Skill_10102:calSkillTarget(chaNode, skillId)
    return nil
end
function Skill_10102:runSkill(chaNode, skillId, resultTable, allPassiveTable, targetTable, attack_params)
    local skillCfg = ConfigManager:getSkillCfg()[skillId]
    local skillLevel = skillId % 10
    local params = common:split(skillCfg.values, ",")
    
    local target = self:getSkillTarget(chaNode, skillId)

    if triggerTable[chaNode.idx] == NewBattleConst.PASSIVE_TRIGGER_TYPE.ATK_ADD_BUFF then
        -- 附加Buff
        if resultTable[NewBattleConst.LogDataType.BUFF_TAR] then
            table.insert(resultTable[NewBattleConst.LogDataType.BUFF], tonumber(params[2]))
            table.insert(resultTable[NewBattleConst.LogDataType.BUFF_TAR], target)
            table.insert(resultTable[NewBattleConst.LogDataType.BUFF_TIME], 999000 * 1000)
            table.insert(resultTable[NewBattleConst.LogDataType.BUFF_COUNT], 3)
        else
            resultTable[NewBattleConst.LogDataType.BUFF] = { tonumber(params[2]) }
            resultTable[NewBattleConst.LogDataType.BUFF_TAR] = { target }
            resultTable[NewBattleConst.LogDataType.BUFF_TIME] = { 999000 * 1000 }
            resultTable[NewBattleConst.LogDataType.BUFF_COUNT] = { 3 }
        end
    end

    return resultTable
end
function Skill_10102:isUsable(chaNode, skillType, skillId, triggerType)
    local skillCfg = ConfigManager:getSkillCfg()[skillId]
    local skillLevel = skillId % 10
    local params = common:split(skillCfg.values, ",")
    if triggerType == NewBattleConst.PASSIVE_TRIGGER_TYPE.ATK_MUST_CRI then -- 先檢查必爆 counter+1
        chaNode.skillData[skillType][skillId]["COUNTER"] = chaNode.skillData[skillType][skillId]["COUNTER"] and 
                                                           chaNode.skillData[skillType][skillId]["COUNTER"] + 1 or 1
    end
    if chaNode.skillData[skillType][skillId]["COUNTER"] % (tonumber(params[1]) + 1) ~= 0 then
        return false
    end
    triggerTable[chaNode.idx] = triggerType
    return true
end

function Skill_10102:canPlaySpFx(chaNode)
    local data = chaNode.skillData[NewBattleConst.SKILL_DATA.PASSIVE]
    for k, v in pairs(data) do
        local baseSkillId = math.floor(k / 10)
        if baseSkillId == 10102 then
            local skillCfg = ConfigManager:getSkillCfg()[k]
            local params = common:split(skillCfg.values, ",")
            if v["COUNTER"] % (tonumber(params[1])) ~= 0 then
                return false
            else
                return true
            end
        end
    end
    return false
end

function Skill_10102:getSkillTarget(chaNode, skillId)
    return chaNode
end

return Skill_10102