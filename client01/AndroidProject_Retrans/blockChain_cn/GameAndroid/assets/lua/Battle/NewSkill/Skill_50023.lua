Skill_50023 = Skill_50023 or { }

require("Battle.NewBattleConst")
require("Battle.NewBattleUtil")
require("Battle.NgBattleDataManager")
require("Battle.NewSkill.SkillUtil")
local aliveIdTable = { }
local triggerTable = { }
-------------------------------------------------------
--[[
當陽努斯(params1)死亡時，賦予陰努斯(params2)"物防100%"(params3)30秒(params5)，
當陰努斯(params2)死亡時，賦予陽努斯(params1)"魔防100%"(params4)30秒(params5)
]]--
-------------------------------------------------------
function Skill_50023:castSkill(chaNode, skillType, skillId)
    --紀錄skill data
    local skillCfg = ConfigManager:getSkillCfg()[skillId]
    chaNode.skillData[skillType][skillId]["COUNT"] = chaNode.skillData[skillType][skillId]["COUNT"] + 1
    chaNode.skillData[skillType][skillId]["CD"] = tonumber(skillCfg.cd)
end
-- 提前計算技能目標用 不使用時回傳nil
function Skill_50023:calSkillTarget(chaNode, skillId)
    return nil
end
function Skill_50023:runSkill(chaNode, skillId, resultTable, allPassiveTable, targetTable, attack_params)
    local skillCfg = ConfigManager:getSkillCfg()[skillId]
    local skillLevel = skillId % 10
    local params = common:split(skillCfg.values, ",")
    
    local allTarget = self:getTargetFriend(chaNode, triggerTable[chaNode.idx].target)

    for i = 1, #allTarget do
        local target = allTarget[i]
        -- 附加Buff
        if resultTable[NewBattleConst.LogDataType.BUFF_TAR] then
            table.insert(resultTable[NewBattleConst.LogDataType.BUFF], triggerTable[chaNode.idx].buff)
            table.insert(resultTable[NewBattleConst.LogDataType.BUFF_TAR], target)
            table.insert(resultTable[NewBattleConst.LogDataType.BUFF_TIME], tonumber(params[5]) * 1000)
            table.insert(resultTable[NewBattleConst.LogDataType.BUFF_COUNT], 1)
        else
            resultTable[NewBattleConst.LogDataType.BUFF] = { triggerTable[chaNode.idx].buff }
            resultTable[NewBattleConst.LogDataType.BUFF_TAR] = { target }
            resultTable[NewBattleConst.LogDataType.BUFF_TIME] = { tonumber(params[5]) * 1000 }
            resultTable[NewBattleConst.LogDataType.BUFF_COUNT] = { 1 }
        end
    end

    return resultTable
end
function Skill_50023:isUsable(chaNode, skillType, skillId, triggerType, targetTable)
    if triggerType == NewBattleConst.PASSIVE_TRIGGER_TYPE.FRIEND_DEAD then
        local skillCfg = ConfigManager:getSkillCfg()[skillId]
        local skillLevel = skillId % 10
        local params = common:split(skillCfg.values, ",")
        if targetTable[1].otherData[NewBattleConst.OTHER_DATA.SPINE_NAME] == params[1] then
            triggerTable[chaNode.idx] = { target = params[2], buff = tonumber(params[3]) }
            return true
        elseif targetTable[1].otherData[NewBattleConst.OTHER_DATA.SPINE_NAME] == params[2] then
            triggerTable[chaNode.idx] = { target = params[1], buff = tonumber(params[4]) }
            return true
        else
            return false
        end
        return true
    end
    return false
end

function Skill_50023:getTargetFriend(chaNode, targetSpineName)
    local friendList = NgBattleDataManager_getFriendList(chaNode)
    aliveIdTable = NewBattleUtil:initAliveTable(friendList)
    local targetIdTable = { }
    for i = 1, #aliveIdTable do
        if friendList[aliveIdTable[i]] and friendList[aliveIdTable[i]].otherData[NewBattleConst.OTHER_DATA.SPINE_NAME] == targetSpineName then
            table.insert(targetIdTable, friendList[aliveIdTable[i]])
        end
    end
    return targetIdTable
end

return Skill_50023