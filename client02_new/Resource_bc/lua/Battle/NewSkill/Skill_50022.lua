Skill_50022 = Skill_50022 or { }

require("Battle.NewBattleConst")
require("Battle.NewBattleUtil")
require("Battle.NgBattleDataManager")
require("Battle.NewSkill.SkillUtil")
local aliveIdTable = { }
-------------------------------------------------------
--[[
�ᤩ�ڤ��H��1�W���ͧ����O100/100/120/120/140/140/160%(params2)���@�ޡA
�p�G�ؼЬO���V��(params1)�A�אּ�ᤩ�����O200/200/240/240/280/280/320%(params3)���@��
]]--
-------------------------------------------------------
function Skill_50022:castSkill(chaNode, skillType, skillId)
    --����skill data
    local skillCfg = ConfigManager:getSkillCfg()[skillId]
    chaNode.skillData[skillType][skillId]["COUNT"] = chaNode.skillData[skillType][skillId]["COUNT"] + 1
    chaNode.skillData[skillType][skillId]["CD"] = tonumber(skillCfg.cd)
end
-- ���e�p��ޯ�ؼХ� ���ϥήɦ^��nil
function Skill_50022:calSkillTarget(chaNode, skillId)
    return nil
end
function Skill_50022:runSkill(chaNode, skillId, resultTable, allPassiveTable, targetTable, attack_params)
    local skillCfg = ConfigManager:getSkillCfg()[skillId]
    local skillLevel = skillId % 10
    local params = common:split(skillCfg.values, ",")
    
    local target = self:getSkillTarget(chaNode, skillId)
    --�����O
    local atk = NewBattleUtil:calAtk(chaNode, target[1])
    local shield = 0
    if target[1].otherData[NewBattleConst.OTHER_DATA.SPINE_NAME] == params[1] then
        shield = atk * tonumber(params[3])
    else
        shield = atk * tonumber(params[2])
    end

    local spClassTable = { }
    local spFuncTable = { }
    local spParamTable = { }
    local spTarTable = { }

    -- ���[Buff
    if resultTable[NewBattleConst.LogDataType.SP_FUN_TAR] then
        table.insert(resultTable[NewBattleConst.LogDataType.SP_FUN_CLASS], NewBattleConst.FunClassType.NG_BATTLE_CHARACTER_UTIL)
        table.insert(resultTable[NewBattleConst.LogDataType.SP_FUN_NAME], "addShield")
        table.insert(resultTable[NewBattleConst.LogDataType.SP_FUN_PARAM], { chaNode, target[1], shield, skillId })
        table.insert(resultTable[NewBattleConst.LogDataType.SP_FUN_TAR], target[1])
    else
        resultTable[NewBattleConst.LogDataType.SP_FUN_CLASS] = { NewBattleConst.FunClassType.NG_BATTLE_CHARACTER_UTIL }
        resultTable[NewBattleConst.LogDataType.SP_FUN_NAME] = { "addShield" }
        resultTable[NewBattleConst.LogDataType.SP_FUN_PARAM] = { { chaNode, target[1], shield, skillId } }
        resultTable[NewBattleConst.LogDataType.SP_FUN_TAR] = { target[1] }
    end

    return resultTable
end

function Skill_50022:isUsable(chaNode, skillType, skillId, triggerType)
    if not chaNode.skillData[skillType][skillId]["CD"] or chaNode.skillData[skillType][skillId]["CD"] > 0 then
        return false
    end
    return true
end

function Skill_50022:getSkillTarget(chaNode, skillId)
    local friendList = NgBattleDataManager_getFriendList(chaNode)
    aliveIdTable = NewBattleUtil:initAliveTable(NgBattleDataManager_getFriendList(chaNode))
    return SkillUtil:getRandomTarget(chaNode, friendList, 1, NewBattleConst.SKILL_TARGET_CONDITION.WITHOUT_SELF)
end

return Skill_50022