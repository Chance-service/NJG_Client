Skill_50032 = Skill_50032 or {}

require("Battle.NewBattleConst")
require("Battle.NewBattleUtil")
require("Battle.NgBattleDataManager")
require("Battle.NewSkill.SkillUtil")
local aliveIdTable = {}
-------------------------------------------------------
--[[ NEW
對隨機1名敵方造成200/240/280/320/360/400/440%(params1)傷害，並賦予"暈眩"(params2)8秒(params3)
]]--
-------------------------------------------------------
function Skill_50032:castSkill(chaNode, skillType, skillId)
    --紀錄skill data
    local skillCfg = ConfigManager:getSkillCfg()[skillId]
    chaNode.skillData[skillType][skillId]["COUNT"] = chaNode.skillData[skillType][skillId]["COUNT"] + 1
    chaNode.skillData[skillType][skillId]["CD"] = tonumber(skillCfg.cd)
end
-- 提前計算技能目標用 不使用時回傳nil
function Skill_50032:calSkillTarget(chaNode, skillId)
    return nil
end
function Skill_50032:runSkill(chaNode, skillId, resultTable, allPassiveTable, targetTable, attack_params)
    local skillCfg = ConfigManager:getSkillCfg()[skillId]
    local skillLevel = skillId % 10
    local params = common:split(skillCfg.values, ",")
    local attackParams = attack_params or chaNode.ATTACK_PARAMS
    local hitMaxNum = tonumber(attackParams["hit_num"]) or 1
    local hitNum = tonumber(attackParams["hit_count"]) or 1
    --初始化table
    aliveIdTable = NewBattleUtil:initAliveTable(NgBattleDataManager_getEnemyList(chaNode))
    local allTarget = targetTable or self:getSkillTarget(chaNode, skillId)

    for i = 1, #allTarget do
        local target = allTarget[i]
        --減傷
        local reduction = NewBattleUtil:calReduction(chaNode, target)
        --攻擊力
        local atk = NewBattleUtil:calAtk(chaNode, target)
        --屬性加成
        local elementRate = NewBattleUtil:calElementRate(chaNode, target)
        --基礎傷害
        local buffValue, auraValue, markValue = BuffManager:checkAllDmgBuffValue(chaNode, target, 
                                                                                 chaNode.battleData[NewBattleConst.BATTLE_DATA.IS_PHY], 
                                                                                 skillCfg.actionName)
        local baseDmg = atk * (1 - reduction) * elementRate * tonumber(params[1]) / hitMaxNum * buffValue * auraValue * markValue

        local isCri = false
        local weakType = (elementRate > 1 and 1) or (elementRate < 1 and -1) or 0
        if NewBattleUtil:calIsHit(chaNode, target) then
            --爆傷
            local criRate = 1
            isCri = NewBattleUtil:calIsCri(chaNode, target)
            if isCri then
                criRate = NewBattleUtil:calFinalCriDmgRate(chaNode, target)
            end
            --最終傷害(四捨五入)
            local dmg = math.floor(baseDmg * criRate + 0.5)
            --最終結果
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
            -- 附加Buff
            if resultTable[NewBattleConst.LogDataType.BUFF_TAR] then
                table.insert(resultTable[NewBattleConst.LogDataType.BUFF], tonumber(params[2]))
                table.insert(resultTable[NewBattleConst.LogDataType.BUFF_TAR], target)
                table.insert(resultTable[NewBattleConst.LogDataType.BUFF_TIME], tonumber(params[3]) * 1000)
                table.insert(resultTable[NewBattleConst.LogDataType.BUFF_COUNT], 1)
            else
                resultTable[NewBattleConst.LogDataType.BUFF] = { tonumber(params[2]) }
                resultTable[NewBattleConst.LogDataType.BUFF_TAR] = { target }
                resultTable[NewBattleConst.LogDataType.BUFF_TIME] = { tonumber(params[3]) * 1000 }
                resultTable[NewBattleConst.LogDataType.BUFF_COUNT] = { 1 }
            end
        else
            --最終結果
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

    return resultTable
end
function Skill_50032:isUsable(chaNode, skillType, skillId, triggerType)
    if not chaNode.skillData[skillType][skillId]["CD"] or chaNode.skillData[skillType][skillId]["CD"] > 0 then
        return false
    end
    return true
end

function Skill_50032:getSkillTarget(chaNode, skillId)
    local skillCfg = ConfigManager:getSkillCfg()[skillId]
    local skillLevel = skillId % 10
    local params = common:split(skillCfg.values, ",")
    local enemyList = NgBattleDataManager_getEnemyList(chaNode)
    aliveIdTable = NewBattleUtil:initAliveTable(NgBattleDataManager_getEnemyList(chaNode))
    return SkillUtil:getRandomTarget(chaNode, enemyList, 1)
end

return Skill_50032