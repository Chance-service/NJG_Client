Skill_1071 = Skill_1071 or { }

require("Battle.NewBattleConst")
require("Battle.NewBattleUtil")
require("Battle.NgBattleDataManager")
require("Battle.NewSkill.SkillUtil")
local aliveIdTable = { }
-------------------------------------------------------
--[[ NEW
對隨機敵方1/2/3名(params1)單體賦予"嘲諷"(params2)3/4/5秒(params3)、"逆風I"(params4)3/4/5秒(params5)
*優先選擇非嘲諷中目標
]]--
--[[ OLD
賦予自身"勢不可擋"(params1)及"守護II/守護III/守護IV"(params2)5/5/7秒(params3)
]]--
-------------------------------------------------------
function Skill_1071:castSkill(chaNode, skillType, skillId)
    --紀錄skill data
    local skillCfg = ConfigManager:getSkillCfg()[skillId]
    chaNode.skillData[skillType][skillId]["COUNT"] = chaNode.skillData[skillType][skillId]["COUNT"] + 1
    chaNode.skillData[skillType][skillId]["CD"] = tonumber(skillCfg.cd)
end
-- 提前計算技能目標用 不使用時回傳nil
function Skill_1071:calSkillTarget(chaNode, skillId)
    local enemyList = NgBattleDataManager_getEnemyList(chaNode)
    aliveIdTable = NewBattleUtil:initAliveTable(enemyList)
    local allTarget = self:getSkillTarget(chaNode, skillId)
    return allTarget
end
function Skill_1071:runSkill(chaNode, skillId, resultTable, allPassiveTable, targetTable, attack_params)
    local skillCfg = ConfigManager:getSkillCfg()[skillId]
    local skillLevel = skillId % 10
    local params = common:split(skillCfg.values, ",")
    local attackParams = attack_params or chaNode.ATTACK_PARAMS
    local hitMaxNum = tonumber(attackParams["hit_num"]) or 1
    local hitNum = tonumber(attackParams["hit_count"]) or 1
    --初始化table
    aliveIdTable = NewBattleUtil:initAliveTable(NgBattleDataManager_getEnemyList(chaNode))
    local allTarget = targetTable or self:getSkillTarget(chaNode, skillId)

    resultTable = { }
    local buffTable = { }
    local buffTarTable = { }
    local buffTimeTable = { }
    local buffCountTable = { }
    for i = 1, #allTarget do
        local target = allTarget[i]

        table.insert(buffTable, tonumber(params[2]))
        table.insert(buffTarTable, target)
        table.insert(buffTimeTable, tonumber(params[3]) * 1000)
        table.insert(buffCountTable, 1)
        table.insert(buffTable, tonumber(params[4]))
        table.insert(buffTarTable, target)
        table.insert(buffTimeTable, tonumber(params[5]) * 1000)
        table.insert(buffCountTable, 1)
    end

    resultTable[NewBattleConst.LogDataType.BUFF] = buffTable
    resultTable[NewBattleConst.LogDataType.BUFF_TAR] = buffTarTable
    resultTable[NewBattleConst.LogDataType.BUFF_TIME] = buffTimeTable
    resultTable[NewBattleConst.LogDataType.BUFF_COUNT] = buffCountTable

    return resultTable
end
function Skill_1071:isUsable(chaNode, skillType, skillId, triggerType)
    if triggerType ~= NewBattleConst.SKILL1_TRIGGER_TYPE.NORMAL then
        return false
    end
    if not chaNode.skillData[skillType][skillId]["CD"] or chaNode.skillData[skillType][skillId]["CD"] > 0 then
        return false
    end
    return true
end

function Skill_1071:getSkillTarget(chaNode, skillId)
    local skillCfg = ConfigManager:getSkillCfg()[skillId]
    local params = common:split(skillCfg.values, ",")
    local enemyList = NgBattleDataManager_getEnemyList(chaNode)
    return SkillUtil:getRandomTarget(chaNode, enemyList, tonumber(params[1]), NewBattleConst.SKILL_TARGET_CONDITION.WITHOUT_BUFF_TAUNT)
end

return Skill_1071