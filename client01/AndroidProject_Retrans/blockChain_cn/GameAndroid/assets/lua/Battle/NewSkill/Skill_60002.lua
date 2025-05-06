Skill_60002 = Skill_60002 or { }

require("Battle.NewBattleConst")
require("Battle.NewBattleUtil")
local aliveIdTable = { }
local triggerTable = { }
local counterTable = { }
-------------------------------------------------------
--[[
�ۨ��s���ɡA�Ҧ�����j�׭ȴ���200%(params1)�A���\�j�׮ɫ�_�ۨ������O100%(params2)�ͩR��
]]--
-------------------------------------------------------
function Skill_60002:castSkill(chaNode, skillType, skillId)
    --����skill data
    --if not triggerTable[chaNode.idx] or triggerTable[chaNode.idx] ~= NewBattleConst.PASSIVE_TRIGGER_TYPE.START_BATTLE then
    --    local skillCfg = ConfigManager:getSkillCfg()[skillId]
    --    chaNode.skillData[skillType][skillId]["COUNT"] = chaNode.skillData[skillType][skillId]["COUNT"] + 1
    --    chaNode.skillData[skillType][skillId]["CD"] = tonumber(skillCfg.cd)
    --end
end
-- ���e�p��ޯ�ؼХ� ���ϥήɦ^��nil
function Skill_60002:calSkillTarget(chaNode, skillId)
    return nil
end
function Skill_60002:runSkill(chaNode, skillId, resultTable, allPassiveTable, targetTable, attack_params)
    local skillCfg = ConfigManager:getSkillCfg()[skillId]
    local skillLevel = skillId % 10
    local params = common:split(skillCfg.values, ",")

    --Get Buff
    local buffTable = { }
    local buffTarTable = { }
    local buffTimeTable = { }
    local buffCountTable = { }
    local healTable = { }
    local healTarTable = { }
    local healCriTable = { }

    if triggerTable[chaNode.idx][NewBattleConst.PASSIVE_TRIGGER_TYPE.AURA_FRIEND_ATK] then
        local target = chaNode
        table.insert(buffTable, tonumber(params[4]))
        table.insert(buffTarTable, target)
        table.insert(buffTimeTable, 999000 * 1000)
        table.insert(buffCountTable, 1)
        resultTable[NewBattleConst.LogDataType.BUFF] = buffTable
        resultTable[NewBattleConst.LogDataType.BUFF_TAR] = buffTarTable
        resultTable[NewBattleConst.LogDataType.BUFF_TIME] = buffTimeTable
        resultTable[NewBattleConst.LogDataType.BUFF_COUNT] = buffCountTable
        triggerTable[chaNode.idx][NewBattleConst.PASSIVE_TRIGGER_TYPE.AURA_FRIEND_ATK] = false
    end
    if triggerTable[chaNode.idx][NewBattleConst.PASSIVE_TRIGGER_TYPE.AURA_DODGE] then
        local target = chaNode
        --�����O
        local atk = NewBattleUtil:calAtk(chaNode, target)
        --�I�k�̳y���v��buff
        local buffValue = BuffManager:checkHealBuffValue(chaNode.buffData)
        --�ؼШ���v��buff
        local buffValue2 = BuffManager:checkBeHealBuffValue(target)
        --��¦�ˮ`
        local baseDmg = atk * tonumber(params[2]) * buffValue * buffValue2

        local isCri = false
        --�z��
        local criRate = 1
        isCri = NewBattleUtil:calIsCri(chaNode, target, true)
        if isCri then
            criRate = NewBattleUtil:calFinalCriDmgRate(chaNode, target)
        end
        --�̲׶ˮ`(�|�ˤ��J)
        local dmg = math.floor(baseDmg * criRate + 0.5)

        table.insert(healTable, dmg)
        table.insert(healTarTable, target)
        table.insert(healCriTable, isCri)
        resultTable[NewBattleConst.LogDataType.HEAL] = healTable
        resultTable[NewBattleConst.LogDataType.HEAL_TAR] = healTarTable
        resultTable[NewBattleConst.LogDataType.HEAL_CRI] = healCriTable
        triggerTable[chaNode.idx][NewBattleConst.PASSIVE_TRIGGER_TYPE.AURA_DODGE] = false
    end

    return resultTable
end

function Skill_60002:isUsable(chaNode, skillType, skillId, triggerType)
    local skillCfg = ConfigManager:getSkillCfg()[skillId]
    local params = common:split(skillCfg.values, ",")
    if triggerType == NewBattleConst.PASSIVE_TRIGGER_TYPE.AURA_FRIEND_ATK then
        counterTable[chaNode.idx] = counterTable[chaNode.idx] and counterTable[chaNode.idx] + 1 or 1
        if counterTable[chaNode.idx] >= tonumber(params[3]) then
            triggerTable[chaNode.idx] = triggerTable[chaNode.idx] or { }
            triggerTable[chaNode.idx][triggerType] = true
            counterTable[chaNode.idx] = 0
            return true
        else
            triggerTable[chaNode.idx] = triggerTable[chaNode.idx] or { }
            triggerTable[chaNode.idx][triggerType] = false
            return false
        end
    elseif triggerType == NewBattleConst.PASSIVE_TRIGGER_TYPE.AURA_DODGE_VALUE then
        return true
    elseif triggerType == NewBattleConst.PASSIVE_TRIGGER_TYPE.AURA_DODGE then
        triggerTable[chaNode.idx] = triggerTable[chaNode.idx] or { }
        triggerTable[chaNode.idx][triggerType] = true
        return true
    elseif triggerType == NewBattleConst.PASSIVE_TRIGGER_TYPE.AURA_START_BATTLE then    -- �}���ɲM�Ŭ���
        counterTable = { }
        triggerTable = { }
        return false
    else
        return false
    end
end

function Skill_60002:calSkillSpecialParams(skillId, option)
    local skillCfg = ConfigManager:getSkillCfg()[skillId]
    local params = common:split(skillCfg.values, ",")
    if not option then
        return { }
    end
    if (option.auraType == NewBattleConst.PASSIVE_TRIGGER_TYPE.AURA_DODGE_VALUE) then
        return { tonumber(params[1]) }
    end
    return { }
end

return Skill_60002