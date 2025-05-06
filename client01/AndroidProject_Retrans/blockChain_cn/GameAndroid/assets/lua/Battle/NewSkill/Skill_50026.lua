Skill_50026 = Skill_50026 or { }

require("Battle.NewBattleConst")
require("Battle.NewBattleUtil")
require("Battle.NgBattleDataManager")
require("Battle.NewSkill.SkillUtil")
local aliveIdTable = { }
-------------------------------------------------------
--[[
���H���@�W�Ĥ�ؼнᤩ"����I/����I/����II/����II/����III/����III/����III"(params2)4/4/6/6/6/6/8��(params3)
�p���V��(params1)�s���ɡA�אּ�ᤩ�����ĤH
]]--
-------------------------------------------------------
function Skill_50026:castSkill(chaNode, skillType, skillId)
    --����skill data
    local skillCfg = ConfigManager:getSkillCfg()[skillId]
    chaNode.skillData[skillType][skillId]["COUNT"] = chaNode.skillData[skillType][skillId]["COUNT"] + 1
    chaNode.skillData[skillType][skillId]["CD"] = tonumber(skillCfg.cd)
end
-- ���e�p��ޯ�ؼХ� ���ϥήɦ^��nil
function Skill_50026:calSkillTarget(chaNode, skillId)
    return nil
end
function Skill_50026:runSkill(chaNode, skillId, resultTable, allPassiveTable, targetTable, attack_params)
    local skillCfg = ConfigManager:getSkillCfg()[skillId]
    local skillLevel = skillId % 10
    local params = common:split(skillCfg.values, ",")
    
    local targetFriend = self:getTargetFriend(chaNode, params[1])
    local allTarget = #targetFriend > 0 and self:getSkillTarget(chaNode, skillId) or self:getSkillTarget2(chaNode, skillId)

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
    end

    return resultTable
end

function Skill_50026:isUsable(chaNode, skillType, skillId, triggerType)
    if not chaNode.skillData[skillType][skillId]["CD"] or chaNode.skillData[skillType][skillId]["CD"] > 0 then
        return false
    end
    return true
end

function Skill_50026:getSkillTarget(chaNode, skillId)
    local enemyList = NgBattleDataManager_getEnemyList(chaNode)
    aliveIdTable = NewBattleUtil:initAliveTable(NgBattleDataManager_getEnemyList(chaNode))
    return SkillUtil:getRandomTarget(chaNode, enemyList, 1)
end

function Skill_50026:getSkillTarget2(chaNode, skillId)
    local enemyList = NgBattleDataManager_getEnemyList(chaNode)
    aliveIdTable = NewBattleUtil:initAliveTable(NgBattleDataManager_getEnemyList(chaNode))
    return SkillUtil:getSkillTarget(chaNode, enemyList, aliveIdTable, SkillUtil.AREA_TYPE.ALL, { })
end

function Skill_50026:getTargetFriend(chaNode, targetSpineName)
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

return Skill_50026