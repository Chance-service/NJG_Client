Skill_11301 = Skill_11301 or { }

require("Battle.NewBattleConst")
require("Battle.NewBattleUtil")
require("Battle.NgBattleDataManager")
require("Battle.NewSkill.SkillUtil")
local buffConfig = ConfigManager:getNewBuffCfg()
local aliveIdTable = { }
-------------------------------------------------------
--[[
當敵方單體有2種(params1)以上"毒"狀態時，賦予該目標"超猛毒I/超猛毒II/超猛毒III"(params2)4秒(params3)
]]--
-------------------------------------------------------
function Skill_11301:castSkill(chaNode, skillType, skillId)
    --紀錄skill data
    local skillCfg = ConfigManager:getSkillCfg()[skillId]
    chaNode.skillData[skillType][skillId]["COUNT"] = chaNode.skillData[skillType][skillId]["COUNT"] + 1
    chaNode.skillData[skillType][skillId]["CD"] = tonumber(skillCfg.cd)
end
-- 提前計算技能目標用 不使用時回傳nil
function Skill_11301:calSkillTarget(chaNode, skillId)
    return nil
end
function Skill_11301:runSkill(chaNode, skillId, resultTable, allPassiveTable, targetTable, attack_params)
    local skillCfg = ConfigManager:getSkillCfg()[skillId]
    local skillLevel = skillId % 10
    local params = common:split(skillCfg.values, ",")
    
    local allTarget = self:getSkillTarget(chaNode, skillId)
    for i = 1, #allTarget do
        local target = allTarget[i]

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
    end

    return resultTable
end
function Skill_11301:isUsable(chaNode, skillType, skillId, triggerType)
    if not chaNode.skillData[skillType][skillId]["CD"] or chaNode.skillData[skillType][skillId]["CD"] > 0 then
        return false
    end
    local allTarget = self:getSkillTarget(chaNode, skillId)
    if #allTarget <= 0 then
        return false
    end
    return true
end

function Skill_11301:getSkillTarget(chaNode, skillId)
    local skillCfg = ConfigManager:getSkillCfg()[skillId]
    local params = common:split(skillCfg.values, ",")
    local enemyList = NgBattleDataManager_getEnemyList(chaNode)
    aliveIdTable = NewBattleUtil:initAliveTable(NgBattleDataManager_getEnemyList(chaNode))
    local targets = { }
    for i = 1, #aliveIdTable do
        local posionCount = 0
        local buff = enemyList[aliveIdTable[i]].buffData
        if buff then
            for fullBuffId, buffData in pairs(buff) do
                if buffConfig[fullBuffId] then
                    local mainBuffId = math.floor(fullBuffId / 100) % 1000
                    -- 毒類型Buff
                    if mainBuffId == NewBattleConst.BUFF.POISON or
                       mainBuffId == NewBattleConst.BUFF.SOUL_OF_POISON or
                       mainBuffId == NewBattleConst.BUFF.TOXIN_OF_POISON or
                       mainBuffId == NewBattleConst.BUFF.SNAKE_OF_POISON or
                       mainBuffId == NewBattleConst.BUFF.HYPER_OF_POISON then
                        posionCount = posionCount + 1
                    end
                end
            end
            if posionCount >= tonumber(params[1]) then
                table.insert(targets, enemyList[aliveIdTable[i]])
            end
        end
    end
    return targets
end

return Skill_11301