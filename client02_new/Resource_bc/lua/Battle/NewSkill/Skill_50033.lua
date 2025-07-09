Skill_50033 = Skill_50033 or { }

require("Battle.NewBattleConst")
require("Battle.NewBattleUtil")
require("Battle.NgBattleDataManager")
require("Battle.NewSkill.SkillUtil")
local aliveIdTable = { }
-------------------------------------------------------
--[[
自身血量低於50%(params3)時，每秒對自身中心橢圓形區域(w:240(params1), h:150(params2))內敵人造成15%(params4)無視防禦傷害
]]--
-------------------------------------------------------
function Skill_50033:castSkill(chaNode, skillType, skillId)
    --紀錄skill data
    local skillCfg = ConfigManager:getSkillCfg()[skillId]
    chaNode.skillData[skillType][skillId]["COUNT"] = chaNode.skillData[skillType][skillId]["COUNT"] + 1
    chaNode.skillData[skillType][skillId]["CD"] = tonumber(skillCfg.cd)
end
-- 提前計算技能目標用 不使用時回傳nil
function Skill_50033:calSkillTarget(chaNode, skillId)
    return nil
end
function Skill_50033:runSkill(chaNode, skillId, resultTable, allPassiveTable, targetTable, attack_params)
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
        local reduction = 0
        --攻擊力
        local atk = NewBattleUtil:calAtk(chaNode, target)
        --屬性加成
        local elementRate = NewBattleUtil:calElementRate(chaNode, target)
        --基礎傷害
        local buffValue, auraValue, markValue = BuffManager:checkAllDmgBuffValue(chaNode, target, 
                                                                                 chaNode.battleData[NewBattleConst.BATTLE_DATA.IS_PHY], 
                                                                                 skillCfg.actionName)
        local baseDmg = atk * (1 - reduction) * elementRate * tonumber(params[4]) / hitMaxNum * buffValue * auraValue * markValue

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

function Skill_50033:isUsable(chaNode, skillType, skillId, triggerType)
    if not chaNode.skillData[skillType][skillId]["CD"] or chaNode.skillData[skillType][skillId]["CD"] > 0 then
        return false
    end
    local skillCfg = ConfigManager:getSkillCfg()[skillId]
    local hpPercent = chaNode.battleData[NewBattleConst.BATTLE_DATA.HP] / chaNode.battleData[NewBattleConst.BATTLE_DATA.MAX_HP]
    local params = common:split(skillCfg.values, ",")
    if hpPercent > tonumber(params[3]) then
        return false
    end
    return true
end

function Skill_50033:getSkillTarget(chaNode, skillId)
    local skillCfg = ConfigManager:getSkillCfg()[skillId]
    local params = common:split(skillCfg.values, ",")
    local enemyList = NgBattleDataManager_getEnemyList(chaNode)

    return SkillUtil:getSkillTarget(chaNode, enemyList, aliveIdTable, SkillUtil.AREA_TYPE.ELLIPSE_2, { x = tonumber(params[1]), y = tonumber(params[2]) })
end

return Skill_50033