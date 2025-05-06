Skill_10201 = Skill_10201 or { }

require("Battle.NewBattleConst")
require("Battle.NewBattleUtil")
require("Battle.NgBattleDataManager")
require("Battle.NewSkill.SkillUtil")
local aliveIdTable = { }
local triggerTable = { }
-------------------------------------------------------
--[[
���q����"�U�N"(params1)�����ؼЩR����A�y��"�U�N"�h��*�ۨ������O20%/40%/60%(params2)�L�����m�ˮ`�A�ò����ӥؼЪ�"�U�N"
]]--
-------------------------------------------------------
function Skill_10201:castSkill(chaNode, skillType, skillId)
    --����skill data
    local skillCfg = ConfigManager:getSkillCfg()[skillId]
    chaNode.skillData[skillType][skillId]["COUNT"] = chaNode.skillData[skillType][skillId]["COUNT"] + 1
    chaNode.skillData[skillType][skillId]["CD"] = tonumber(skillCfg.cd)
end
-- ���e�p��ޯ�ؼХ� ���ϥήɦ^��nil
function Skill_10201:calSkillTarget(chaNode, skillId)
    return nil
end
function Skill_10201:runSkill(chaNode, skillId, resultTable, allPassiveTable, targetTable, attack_params)
    local skillCfg = ConfigManager:getSkillCfg()[skillId]
    local skillLevel = skillId % 10
    local params = common:split(skillCfg.values, ",")

    allTarget = { chaNode.target }
    for i = 1, #allTarget do
        local target = allTarget[i]
        --���
        local reduction = 0--NewBattleUtil:calReduction(chaNode, target)
        --�����O
        local atk = NewBattleUtil:calAtk(chaNode, target)
        --�ݩʥ[��
        local elementRate = NewBattleUtil:calElementRate(chaNode, target)
        --��¦�ˮ`
        local buffValue, auraValue, markValue = BuffManager:checkAllDmgBuffValue(chaNode, target, 
                                                                                 chaNode.battleData[NewBattleConst.BATTLE_DATA.IS_PHY], 
                                                                                 skillCfg.actionName)
        local baseDmg = atk * (1 - reduction) * elementRate * tonumber(params[2]) * triggerTable[chaNode.idx].count * buffValue * auraValue * markValue

        local isCri = false
        local weakType = (elementRate > 1 and 1) or (elementRate < 1 and -1) or 0

        --�z��
        local criRate = 1
        isCri = NewBattleUtil:calIsCri(chaNode, target)
        if isCri then
            criRate = NewBattleUtil:calFinalCriDmgRate(chaNode, target)
        end
        --�̲׶ˮ`(�|�ˤ��J)
        local dmg = math.floor(baseDmg * criRate + 0.5)
        --�̲׵��G
        if resultTable[NewBattleConst.LogDataType.DMG_TAR] then
            table.insert(resultTable[NewBattleConst.LogDataType.DMG], dmg)
            table.insert(resultTable[NewBattleConst.LogDataType.DMG_TAR], target)
            table.insert(resultTable[NewBattleConst.LogDataType.DMG_CRI], isCri)
            table.insert(resultTable[NewBattleConst.LogDataType.DMG_WEAK], weakType)
        else
            resultTable[NewBattleConst.LogDataType.DMG] = { dmg }
            resultTable[NewBattleConst.LogDataType.DMG_TAR] = { target }
            resultTable[NewBattleConst.LogDataType.DMG_CRI] = { isCri }
            resultTable[NewBattleConst.LogDataType.DMG_WEAK] = { weakType }
        end
        -- ����buff
        if resultTable[NewBattleConst.LogDataType.SP_FUN_TAR] then
            table.insert(resultTable[NewBattleConst.LogDataType.SP_FUN_CLASS], NewBattleConst.FunClassType.NEW_BATTLE_UTIL)
            table.insert(resultTable[NewBattleConst.LogDataType.SP_FUN_NAME], "removeBuff")
            table.insert(resultTable[NewBattleConst.LogDataType.SP_FUN_PARAM], { target, triggerTable[chaNode.idx].buffId, false })
            table.insert(resultTable[NewBattleConst.LogDataType.SP_FUN_TAR], target)
        else
            resultTable[NewBattleConst.LogDataType.SP_FUN_CLASS] = { NewBattleConst.FunClassType.NEW_BATTLE_UTIL }
            resultTable[NewBattleConst.LogDataType.SP_FUN_NAME] = { "removeBuff" }
            resultTable[NewBattleConst.LogDataType.SP_FUN_PARAM] = { { target, triggerTable[chaNode.idx].buffId, false } }
            resultTable[NewBattleConst.LogDataType.SP_FUN_TAR] = { target }
        end
    end

    return resultTable
end
function Skill_10201:isUsable(chaNode, skillType, skillId, triggerType, targetTable)
    local skillCfg = ConfigManager:getSkillCfg()[skillId]
    local params = common:split(skillCfg.values, ",")
    if not chaNode.skillData[skillType][skillId]["CD"] or chaNode.skillData[skillType][skillId]["CD"] > 0 then
        return false
    end
    for i = 1, #targetTable do
        local target = targetTable[i]
        local buff = target.buffData  -- �ؼЪ�Buff
        if buff then
            for fullBuffId, buffData in pairs(buff) do
                local mainBuffId = math.floor(fullBuffId / 100) % 1000
                if mainBuffId == tonumber(params[1]) then  -- �U�N
                    triggerTable[chaNode.idx] = { count = buffData[NewBattleConst.BUFF_DATA.COUNT], buffId = fullBuffId }
                    return true
                end
            end
        end
    end
    return false
end

return Skill_10201