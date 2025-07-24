Skill_10606 = Skill_10606 or { }

require("Battle.NewBattleConst")
require("Battle.NewBattleUtil")
require("Battle.NgBattleDataManager")
require("Battle.NewSkill.SkillUtil")
local aliveIdTable = { }
-------------------------------------------------------
--[[
�����ڤ����"�~��"(params1)�A�C����1�h�~���A�H����Ĥ�2�W(params2)�ؼгy��15%/20%/25%(params3)�L�����m�ˮ`
]]--
-------------------------------------------------------
function Skill_10606:castSkill(chaNode, skillType, skillId)
    --����skill data
    local skillCfg = ConfigManager:getSkillCfg()[skillId]
    chaNode.skillData[skillType][skillId]["COUNT"] = chaNode.skillData[skillType][skillId]["COUNT"] + 1
    chaNode.skillData[skillType][skillId]["CD"] = tonumber(skillCfg.cd)
end
-- ���e�p��ޯ�ؼХ� ���ϥήɦ^��nil
function Skill_10606:calSkillTarget(chaNode, skillId)
    return nil
end
function Skill_10606:runSkill(chaNode, skillId, resultTable, allPassiveTable, targetTable, attack_params)
    local skillCfg = ConfigManager:getSkillCfg()[skillId]
    local skillLevel = skillId % 10
    local params = common:split(skillCfg.values, ",")
    
    local allTarget = self:getSkillTarget(chaNode, skillId)

    local count = 0
    for i = 1, #allTarget do
        local target = allTarget[i]

        local buffId, buffCount = self:getRemoveBuffId(target, skillId)
        if buffId > 0 then
            count = count + buffCount
            -- ����Buff
            if resultTable[NewBattleConst.LogDataType.SP_FUN_TAR] then
                table.insert(resultTable[NewBattleConst.LogDataType.SP_FUN_CLASS], NewBattleConst.FunClassType.NEW_BATTLE_UTIL)
                table.insert(resultTable[NewBattleConst.LogDataType.SP_FUN_NAME], "removeBuff")
                table.insert(resultTable[NewBattleConst.LogDataType.SP_FUN_PARAM], { target, buffId, false })
                table.insert(resultTable[NewBattleConst.LogDataType.SP_FUN_TAR], target)
            else
                resultTable[NewBattleConst.LogDataType.SP_FUN_CLASS] = { NewBattleConst.FunClassType.NEW_BATTLE_UTIL }
                resultTable[NewBattleConst.LogDataType.SP_FUN_NAME] = { "removeBuff" }
                resultTable[NewBattleConst.LogDataType.SP_FUN_PARAM] = { { target, buffId, false } }
                resultTable[NewBattleConst.LogDataType.SP_FUN_TAR] = { target }
            end
        end
    end
    for i = 1, count do
        local targets = self:getSkillTarget2(chaNode, skillId)
        for i = 1, #targets do
            local target = targets[i]

            --�����O
            local atk = NewBattleUtil:calAtk(chaNode, target)
            --�ݩʥ[��
            local elementRate = NewBattleUtil:calElementRate(chaNode, target)
            --��¦�ˮ`
            local buffValue, auraValue, markValue = BuffManager:checkAllDmgBuffValue(chaNode, target, 
                                                                                     chaNode.battleData[NewBattleConst.BATTLE_DATA.IS_PHY], 
                                                                                     skillCfg.actionName)
            local baseDmg = atk * elementRate * tonumber(params[3]) * buffValue * auraValue * markValue

            local isCri = false
            local weakType = (elementRate > 1 and 1) or (elementRate < 1 and -1) or 0
            if NewBattleUtil:calIsHit(chaNode, target) then
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
            else
                --�̲׵��G
                if resultTable[NewBattleConst.LogDataType.DMG_TAR] then
                    table.insert(resultTable[NewBattleConst.LogDataType.DMG], 0)
                    table.insert(resultTable[NewBattleConst.LogDataType.DMG_TAR], target)
                    table.insert(resultTable[NewBattleConst.LogDataType.DMG_CRI], false)
                    table.insert(resultTable[NewBattleConst.LogDataType.DMG_WEAK], 0)
                else
                    resultTable[NewBattleConst.LogDataType.DMG] = { 0 }
                    resultTable[NewBattleConst.LogDataType.DMG_TAR] = { target }
                    resultTable[NewBattleConst.LogDataType.DMG_CRI] = { false }
                    resultTable[NewBattleConst.LogDataType.DMG_WEAK] = { 0 }
                end
            end
        end
    end

    return resultTable
end
function Skill_10606:isUsable(chaNode, skillType, skillId, triggerType)
    if not chaNode.skillData[skillType][skillId]["CD"] or chaNode.skillData[skillType][skillId]["CD"] > 0 then
        return false
    end
    return true
end

function Skill_10606:getSkillTarget(chaNode, skillId)
    local skillCfg = ConfigManager:getSkillCfg()[skillId]
    local friendList = NgBattleDataManager_getFriendList(chaNode)
    aliveIdTable = NewBattleUtil:initAliveTable(NgBattleDataManager_getFriendList(chaNode))
    return SkillUtil:getSkillTarget(chaNode, friendList, aliveIdTable, SkillUtil.AREA_TYPE.ALL, { })
end

function Skill_10606:getSkillTarget2(chaNode, skillId)
    local skillCfg = ConfigManager:getSkillCfg()[skillId]
    local enemyList = NgBattleDataManager_getEnemyList(chaNode)
    aliveIdTable = NewBattleUtil:initAliveTable(NgBattleDataManager_getEnemyList(chaNode))
    return SkillUtil:getRandomTarget(chaNode, enemyList, 2)
end

function Skill_10606:getRemoveBuffId(chaNode, skillId)
    local skillCfg = ConfigManager:getSkillCfg()[skillId]
    local skillLevel = skillId % 10
    local params = common:split(skillCfg.values, ",")

    local buff = chaNode.buffData  -- �ؼЪ�Buff
    if buff then
        for fullBuffId, buffData in pairs(buff) do
            local mainBuffId = math.floor(fullBuffId / 100) % 1000
            if mainBuffId == tonumber(params[1]) then  -- �~��
                return fullBuffId, buffData[NewBattleConst.BUFF_DATA.COUNT]
            end
        end
    end
    return 0, 0
end

return Skill_10606