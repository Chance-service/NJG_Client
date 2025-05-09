SkillManager = SkillManager or { }

local CONST = require("Battle.NewBattleConst")
local LOG_UTIL = require("Battle.NgBattleLogUtil")
local skillCfg = ConfigManager:getSkillCfg()
require("NodeHelper")
-------------------------------------------------------------------------------------------
-- SKILL
-------------------------------------------------------------------------------------------
function SkillManager:isSkillUsable(chaNode, skillType, skillId, triggerType, targetTable)
    if not skillId then
        return false
    end
    if not ConfigManager:getSkillCfg()[skillId] then
        return false
    end
    local baseSkillId = math.floor(skillId / 10)
    local scripe = require("Battle.NewSkill.Skill_" .. ConfigManager:getSkillCfg()[skillId].script)
    return scripe["isUsable"] and scripe:isUsable(chaNode, skillType, skillId, triggerType, targetTable)
end
function SkillManager:castSkill(chaNode, skillType, skillId)
    if not skillId then
        return
    end
    if not ConfigManager:getSkillCfg()[skillId] then
        return false
    end
    local baseSkillId = math.floor(skillId / 10)
    LOG_UTIL:addTestLog(LOG_UTIL.TestLogType.CAST_SKILL, chaNode, nil, skillId, false, false, 0)
    local scripe = require("Battle.NewSkill.Skill_" .. ConfigManager:getSkillCfg()[skillId].script)
    return scripe["castSkill"] and scripe:castSkill(chaNode, skillType, skillId)
end
function SkillManager:runBuff(chaNode, fullBuffId, resultTable, allPassiveTable, targetTable)
    if not fullBuffId then
        return { }
    end
    local baseBuffId = math.floor(fullBuffId / 100) % 100
    local scripe = require("Battle.NewSkill.Skill_" .. baseBuffId)
    return scripe:runSkill(chaNode, fullBuffId, resultTable, allPassiveTable, targetTable)
end
function SkillManager:runSkill(chaNode, skillId, resultTable, allPassiveTable, targetTable, params)
    if not skillId then
        return { }
    end
    if not ConfigManager:getSkillCfg()[skillId] then
        return false
    end
    local baseSkillId = math.floor(skillId / 10)
    local scripe = require("Battle.NewSkill.Skill_" .. ConfigManager:getSkillCfg()[skillId].script)
    return scripe:runSkill(chaNode, skillId, resultTable, allPassiveTable, targetTable, params)
end
function SkillManager:calSkillTarget(skillId, chaNode)
    if not skillId then
        return { }
    end
    if not ConfigManager:getSkillCfg()[skillId] then
        return false
    end
    local baseId = math.floor(skillId / 10)
    local scripe = require("Battle.NewSkill.Skill_" .. ConfigManager:getSkillCfg()[skillId].script)
    return scripe:calSkillTarget(chaNode, skillId)
end
function SkillManager:setSkillTarget(skillId, chaNode, targetTable)
    if not skillId then
        return
    end
    if not ConfigManager:getSkillCfg()[skillId] then
        return false
    end
    local baseId = math.floor(skillId / 10)
    local scripe = require("Battle.NewSkill.Skill_" .. ConfigManager:getSkillCfg()[skillId].script)
    return scripe["setSkillTarget"] and scripe:setSkillTarget(chaNode, skillId, targetTable)
end
function SkillManager:calSkillSpecialParams(skillId, option)
    if not skillId then
        return { 0 }
    end
    if not ConfigManager:getSkillCfg()[skillId] then
        return false
    end
    local baseId = math.floor(skillId / 10)
    local scripe = require("Battle.NewSkill.Skill_" .. ConfigManager:getSkillCfg()[skillId].script)
    return scripe:calSkillSpecialParams(skillId, option)
end

return SkillManager