Skill_60001 = Skill_60001 or { }

require("Battle.NewBattleConst")
require("Battle.NewBattleUtil")
local aliveIdTable = { }
local triggerTable = { }
-------------------------------------------------------
--[[
�԰��}�l�ɡA�ᤩ�ħ�����"�r�rI"(params1)�F�C���z����A�ۨ���"�r�r"(params2)���Ŵ���1(params3)(���W�S���r�r�ɷ|��o"�r�rI")�A�̰�lv3(params4)
�ɮv¾�~(params5)�K�̬r(���r/�r�r/�P�r/�D�r(params6~9))Debuff
]]--
-------------------------------------------------------
function Skill_60001:castSkill(chaNode, skillType, skillId)
    --����skill data
    --if not triggerTable[chaNode.idx] or triggerTable[chaNode.idx] ~= NewBattleConst.PASSIVE_TRIGGER_TYPE.START_BATTLE then
    --    local skillCfg = ConfigManager:getSkillCfg()[skillId]
    --    chaNode.skillData[skillType][skillId]["COUNT"] = chaNode.skillData[skillType][skillId]["COUNT"] + 1
    --    chaNode.skillData[skillType][skillId]["CD"] = tonumber(skillCfg.cd)
    --end
end
-- ���e�p��ޯ�ؼХ� ���ϥήɦ^��nil
function Skill_60001:calSkillTarget(chaNode, skillId)
    return nil
end
function Skill_60001:runSkill(chaNode, skillId, resultTable, allPassiveTable, targetTable, attack_params)
    local skillCfg = ConfigManager:getSkillCfg()[skillId]
    local skillLevel = skillId % 10
    local params = common:split(skillCfg.values, ",")

    --Get Buff
    local buffTable = { }
    local buffTarTable = { }
    local buffTimeTable = { }
    local buffCountTable = { }

    if triggerTable[chaNode.idx] == NewBattleConst.PASSIVE_TRIGGER_TYPE.AURA_START_BATTLE then
        local target = chaNode
        table.insert(buffTable, tonumber(params[1]))
        table.insert(buffTarTable, target)
        table.insert(buffTimeTable, 999000 * 1000)
        table.insert(buffCountTable, 1)
    elseif triggerTable[chaNode.idx] == NewBattleConst.PASSIVE_TRIGGER_TYPE.AURA_CRI_HIT then
        local target = chaNode
        local buffId = self:getSkillBuff(target, skillId)
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

function Skill_60001:isUsable(chaNode, skillType, skillId, triggerType)
    if triggerType == NewBattleConst.PASSIVE_TRIGGER_TYPE.AURA_START_BATTLE then
        triggerTable[chaNode.idx] = triggerType
        return true
    end
    if triggerType == NewBattleConst.PASSIVE_TRIGGER_TYPE.AURA_CRI_HIT then
        triggerTable[chaNode.idx] = triggerType
        return true
    end
    if triggerType == NewBattleConst.PASSIVE_TRIGGER_TYPE.AURA_IMMUNITY_BUFF then
        return true
    end
    return false
end

function Skill_60001:calSkillSpecialParams(skillId, option)
    local skillCfg = ConfigManager:getSkillCfg()[skillId]
    local params = common:split(skillCfg.values, ",")
    if not option then
        return { }
    end
    if (option.auraType == NewBattleConst.PASSIVE_TRIGGER_TYPE.AURA_IMMUNITY_BUFF) and
       (option.job == tonumber(params[5])) then   -- �ɮv¾�~
        return { tonumber(params[6]), tonumber(params[7]), tonumber(params[8]), tonumber(params[9]) }
    end
    return { }
end

function Skill_60001:getSkillBuff(chaNode, skillId)
    local skillCfg = ConfigManager:getSkillCfg()[skillId]
    local params = common:split(skillCfg.values, ",")
    local buff = chaNode.buffData
    local buffId = 0
    if buff then
        for fullBuffId, buffData in pairs(buff) do
            local mainBuffId = math.floor(fullBuffId / 100) % 1000
            if mainBuffId == tonumber(params[2]) then
                havePosion = true
                local oldLevel = tonumber(fullBuffId % 10)
                local newLevel = math.max(1, math.min(oldLevel + tonumber(params[3]), tonumber(params[4])))
                buffId = tonumber(math.floor(fullBuffId / 10) .. newLevel)
            end
        end
    end
    if buffId == 0 then
        buffId = tonumber(params[1])
    end
    return buffId
end

return Skill_60001