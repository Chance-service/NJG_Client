Skill_11406 = Skill_11406 or { }

require("Battle.NewBattleConst")
require("Battle.NewBattleUtil")
require("Battle.NgBattleDataManager")
require("Battle.NewSkill.SkillUtil")
local aliveIdTable = { }
-------------------------------------------------------
--[[
�����ڤ����"����"(params1)�A�èϧڤ������o"�ԷNI/�ԷNII/�ԷNIII"(params2)6/7/8��(params3)
]]--
-------------------------------------------------------
function Skill_11406:castSkill(chaNode, skillType, skillId)
    --����skill data
    local skillCfg = ConfigManager:getSkillCfg()[skillId]
    chaNode.skillData[skillType][skillId]["COUNT"] = chaNode.skillData[skillType][skillId]["COUNT"] + 1
    chaNode.skillData[skillType][skillId]["CD"] = tonumber(skillCfg.cd)
end
-- ���e�p��ޯ�ؼХ� ���ϥήɦ^��nil
function Skill_11406:calSkillTarget(chaNode, skillId)
    return nil
end
function Skill_11406:runSkill(chaNode, skillId, resultTable, allPassiveTable, targetTable, attack_params)
    local skillCfg = ConfigManager:getSkillCfg()[skillId]
    local skillLevel = skillId % 10
    local params = common:split(skillCfg.values, ",")
    
    local allTarget = self:getSkillTarget(chaNode, skillId)
    for i = 1, #allTarget do
        local target = allTarget[i]

        -- ���[Buff
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
        local buffId = self:getRemoveBuffId(target, skillId)
        if buffId > 0 then
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

    return resultTable
end
function Skill_11406:isUsable(chaNode, skillType, skillId, triggerType)
    if not chaNode.skillData[skillType][skillId]["CD"] or chaNode.skillData[skillType][skillId]["CD"] > 0 then
        return false
    end
    return true
end

function Skill_11406:getSkillTarget(chaNode, skillId)
    local skillCfg = ConfigManager:getSkillCfg()[skillId]
    local friendList = NgBattleDataManager_getFriendList(chaNode)
    aliveIdTable = NewBattleUtil:initAliveTable(NgBattleDataManager_getFriendList(chaNode))
    return SkillUtil:getSkillTarget(chaNode, friendList, aliveIdTable, SkillUtil.AREA_TYPE.ALL, { })
end


function Skill_11406:getRemoveBuffId(chaNode, skillId)
    local skillCfg = ConfigManager:getSkillCfg()[skillId]
    local skillLevel = skillId % 10
    local params = common:split(skillCfg.values, ",")

    local buff = chaNode.buffData  -- �ؼЪ�Buff
    if buff then
        for fullBuffId, buffData in pairs(buff) do
            local mainBuffId = math.floor(fullBuffId / 100) % 1000
            if mainBuffId == tonumber(params[1]) then  -- ����
                return fullBuffId
            end
        end
    end
    return 0
end

return Skill_11406