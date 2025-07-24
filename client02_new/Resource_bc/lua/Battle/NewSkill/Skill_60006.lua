Skill_60006 = Skill_60006 or { }

require("Battle.NewBattleConst")
require("Battle.NewBattleUtil")
local aliveIdTable = { }
local triggerTable = { }
local counterTable = { }
-------------------------------------------------------
--[[
�ۨ��s���ɡA�Ҧ��Ԥh¾�~(params1)�z���v�ܬ�100%(params2)�A���\�z���ɳy���ۨ��̤j��q2%(params3)�ˮ`
]]--
-------------------------------------------------------
function Skill_60006:castSkill(chaNode, skillType, skillId)
    --����skill data
    --if not triggerTable[chaNode.idx] or triggerTable[chaNode.idx] ~= NewBattleConst.PASSIVE_TRIGGER_TYPE.START_BATTLE then
    --    local skillCfg = ConfigManager:getSkillCfg()[skillId]
    --    chaNode.skillData[skillType][skillId]["COUNT"] = chaNode.skillData[skillType][skillId]["COUNT"] + 1
    --    chaNode.skillData[skillType][skillId]["CD"] = tonumber(skillCfg.cd)
    --end
end
-- ���e�p��ޯ�ؼХ� ���ϥήɦ^��nil
function Skill_60006:calSkillTarget(chaNode, skillId)
    return nil
end
function Skill_60006:runSkill(chaNode, skillId, resultTable, allPassiveTable, targetTable, attack_params)
    local skillCfg = ConfigManager:getSkillCfg()[skillId]
    local skillLevel = skillId % 10
    local params = common:split(skillCfg.values, ",")

    --Get Buff
    local dmgTable = { }
    local tarTable = { }
    local criTable = { }
    local weakTable = { }

    if triggerTable[chaNode.idx][NewBattleConst.PASSIVE_TRIGGER_TYPE.AURA_CRI_HIT] then
        local target = chaNode
        --��¦�ˮ`
        local baseDmg = target.battleData[NewBattleConst.BATTLE_DATA.MAX_HP] * tonumber(params[3])

        --�̲׶ˮ`(�|�ˤ��J)
        local dmg = math.floor(baseDmg + 0.5)

        table.insert(dmgTable, dmg)
        table.insert(tarTable, target)
        table.insert(criTable, false)
        table.insert(weakTable, 0)
        resultTable[NewBattleConst.LogDataType.DMG] = dmgTable
        resultTable[NewBattleConst.LogDataType.DMG_TAR] = tarTable
        resultTable[NewBattleConst.LogDataType.DMG_CRI] = criTable
        resultTable[NewBattleConst.LogDataType.DMG_WEAK] = weakTable

        triggerTable[chaNode.idx][NewBattleConst.PASSIVE_TRIGGER_TYPE.AURA_CRI_HIT] = false
    end

    return resultTable
end

function Skill_60006:isUsable(chaNode, skillType, skillId, triggerType)
    local skillCfg = ConfigManager:getSkillCfg()[skillId]
    local params = common:split(skillCfg.values, ",")
    if triggerType == NewBattleConst.PASSIVE_TRIGGER_TYPE.AURA_SET_CRI_PER then
        if chaNode.otherData[NewBattleConst.OTHER_DATA.CFG].Job == tonumber(params[1]) then
            return true
        else
            return false
        end
    elseif triggerType == NewBattleConst.PASSIVE_TRIGGER_TYPE.AURA_CRI_HIT then
        triggerTable[chaNode.idx] = triggerTable[chaNode.idx] or { }
        triggerTable[chaNode.idx][triggerType] = true
        return true
    else
        return false
    end
end

function Skill_60006:calSkillSpecialParams(skillId, option)
    local skillCfg = ConfigManager:getSkillCfg()[skillId]
    local params = common:split(skillCfg.values, ",")
    if not option then
        return { }
    end
    if (option.auraType == NewBattleConst.PASSIVE_TRIGGER_TYPE.AURA_SET_CRI_PER) then
        if option.job == tonumber(params[1]) then
            return { tonumber(params[2]) }
        else
            return { }
        end
    end
    return { }
end

return Skill_60006