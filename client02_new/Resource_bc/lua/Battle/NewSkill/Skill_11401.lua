Skill_11401 = Skill_11401 or { }

require("Battle.NewBattleConst")
require("Battle.NewBattleUtil")
require("Battle.NgBattleDataManager")
require("Battle.NewSkill.SkillUtil")
local aliveIdTable = { }
-------------------------------------------------------
--[[
移除我方全體"恐懼"(params1)，並使我方全體獲得"戰意I/戰意II/戰意III"(params2)6/7/8秒(params3)
]]--
-------------------------------------------------------
function Skill_11401:castSkill(chaNode, skillType, skillId)
    --紀錄skill data
    local skillCfg = ConfigManager:getSkillCfg()[skillId]
    chaNode.skillData[skillType][skillId]["COUNT"] = chaNode.skillData[skillType][skillId]["COUNT"] + 1
    chaNode.skillData[skillType][skillId]["CD"] = tonumber(skillCfg.cd)
end
-- 提前計算技能目標用 不使用時回傳nil
function Skill_11401:calSkillTarget(chaNode, skillId)
    return nil
end
function Skill_11401:runSkill(chaNode, skillId, resultTable, allPassiveTable, targetTable, attack_params)
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
        -- 移除Buff
        if resultTable[NewBattleConst.LogDataType.SP_FUN_TAR] then
            table.insert(resultTable[NewBattleConst.LogDataType.SP_FUN_CLASS], NewBattleConst.FunClassType.NEW_BATTLE_UTIL)
            table.insert(resultTable[NewBattleConst.LogDataType.SP_FUN_NAME], "removeBuff")
            table.insert(resultTable[NewBattleConst.LogDataType.SP_FUN_PARAM], { target, tonumber(params[1]), false })
            table.insert(resultTable[NewBattleConst.LogDataType.SP_FUN_TAR], target)
        else
            resultTable[NewBattleConst.LogDataType.SP_FUN_CLASS] = { NewBattleConst.FunClassType.NEW_BATTLE_UTIL }
            resultTable[NewBattleConst.LogDataType.SP_FUN_NAME] = { "removeBuff" }
            resultTable[NewBattleConst.LogDataType.SP_FUN_PARAM] = { { target, tonumber(params[1]), false } }
            resultTable[NewBattleConst.LogDataType.SP_FUN_TAR] = { target }
        end
    end

    return resultTable
end
function Skill_11401:isUsable(chaNode, skillType, skillId, triggerType)
    if triggerType ~= NewBattleConst.PASSIVE_TRIGGER_TYPE.CD then
        return false
    end
    return true
end

function Skill_11401:getSkillTarget(chaNode, skillId)
    local skillCfg = ConfigManager:getSkillCfg()[skillId]
    local friendList = NgBattleDataManager_getFriendList(chaNode)
    aliveIdTable = NewBattleUtil:initAliveTable(NgBattleDataManager_getFriendList(chaNode))
    return SkillUtil:getSkillTarget(chaNode, friendList, aliveIdTable, SkillUtil.AREA_TYPE.ALL, { })
end

return Skill_11401