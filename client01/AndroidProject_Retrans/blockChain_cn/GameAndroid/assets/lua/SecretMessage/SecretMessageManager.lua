-- 模組初始化
local SecretMessageManager = { isLangInit = false }
local secretCfg = ConfigManager.getSecretMessageCfg()
local AlbumCfg = ConfigManager.getAlbumData()

local SecretMessageData = {
    messageQueue = {},
    allHeroData = {},
    power = 0,
}

-- 通用：取得對應角色的圖鑑條目
local function getRoleTable(_id, _type)
    local RoleTable = {}
    _type = _type or 1
    local cfg = _type == 1 and AlbumCfg or ConfigManager.getRoleGrowthUnlock()

    for _, v in pairs(cfg) do
        if v.itemId == _id then
            table.insert(RoleTable, v)
        end
    end
    table.sort(RoleTable, function(a, b) return a.id < b.id end)
    return RoleTable
end

-- 初始化語言包
function SecretMessageManager_initLanguage()
    if not SecretMessageManager.isLangInit then
        if CC_TARGET_PLATFORM_LUA ~= common.platform.CC_PLATFORM_WIN32 then
            local userType = CCUserDefault:sharedUserDefault():getIntegerForKey("LanguageType")
            if userType == kLanguageChinese then
                Language:getInstance():addLanguageFile("Lang/Language_Secret.lang")
            elseif userType == kLanguageCH_TW then
                Language:getInstance():addLanguageFile("Lang/Language_SecretTW.lang")
            else
                Language:getInstance():addLanguageFile("Lang/Language_Secret.lang")
            end
        end
        SecretMessageManager.isLangInit = true
    end
end

-- 設定伺服器回傳資料
function SecretMessageManager_setServerData(msg)
    if msg.action == 3 then
        SecretMessageData.power = msg.syncMsg.power
        require("SecretMessage.SecretMessagePage")
        SecretMessagePage_RefreshBar()
        return
    end

    SecretMessageData.messageQueue = {}
    SecretMessageData.heroData = {}

    local function createLookupTable(list)
        local tbl = {}
        for _, id in ipairs(list) do
            tbl[tonumber(id)] = true
        end
        return tbl
    end

    for _, hero in ipairs(msg.heroInfo) do
        local itemId = hero.heroId
        local data = {
            intimacyPoint = hero.intimacy,
            AllPoint = hero.Favorability,
            favorabilityPoint = hero.Favorability,
            Unlock = {},
            Free = {},
            Cost = {},
            sexyPoint = hero.sexy,
            history = {},
            pic = hero.pic
        }

        for i = 1, 7 do
            data.Unlock[i], data.Free[i], data.Cost[i] = false, false, false
        end

        local roleTable = getRoleTable(itemId)
        local unlockMap = createLookupTable(hero.unlockCfgId)
        local freeMap = createLookupTable(hero.freeCfgId)
        local costMap = createLookupTable(hero.costCfgId)

        for idx, cfg in ipairs(roleTable) do
            if unlockMap[cfg.id] then
                data.favorabilityPoint = data.favorabilityPoint - cfg.Score
                data.Unlock[idx] = true
            end
            if freeMap[cfg.id] then data.Free[idx] = true end
            if costMap[cfg.id] then data.Cost[idx] = true end
        end

        for _, hist in ipairs(hero.history) do
            local cfg = secretCfg[hist.qution]
            if cfg then
                if hist.answer ~= -1 then
                    table.insert(data.history, {
                        itemId = itemId,
                        questionStr = cfg.QuestionStr,
                        ansStr = (hist.answer == 0) and cfg.AnsStr1 or cfg.AnsStr2,
                        endStr = (hist.answer == 0) and cfg.EndStr1 or cfg.EndStr2,
                        pic = hist.pic or 0
                    })
                else
                    SecretMessageData.messageQueue[#SecretMessageData.messageQueue + 1] = {
                        itemId = itemId,
                        questId = hist.qution,
                        questionStr = cfg.QuestionStr,
                        ansStr1 = cfg.AnsStr1,
                        ansStr2 = cfg.AnsStr2,
                        endStr1 = cfg.EndStr1,
                        endStr2 = cfg.EndStr2
                    }
                end
            end
        end

        SecretMessageData.allHeroData[itemId] = data
    end

    SecretMessageData.power = msg.power
end

-- 取得圖鑑資料
function SecretMessageManager_getAlbumData(_id, _type)
    local AlbumData = {
        RoleId = _id,
        ImgCount = 0,
        UnLockCount = 0,
        NowLimit = 0,
        NowLimitDesc = "",
    }

    _type = _type or 1
    local cfg = _type == 1 and AlbumCfg or ConfigManager.getRoleGrowthUnlock()

    for _, v in pairs(cfg) do
        if v.itemId == _id then
            AlbumData.ImgCount = AlbumData.ImgCount + 1
        end
    end

    local RoleTable = getRoleTable(_id, _type)

    if SecretMessageData.allHeroData[_id] and _type == 1 then
        for _, isUnlock in pairs(SecretMessageData.allHeroData[_id].Unlock) do
            if isUnlock then
                AlbumData.UnLockCount = AlbumData.UnLockCount + 1
            end
        end
        AlbumData.NowLimit = RoleTable[AlbumData.UnLockCount + 1] and RoleTable[AlbumData.UnLockCount + 1].Score or 0

    elseif _type == 2 then
        AlbumData.UnLockCount = SecretMessageManager_LimitAchiveCount(_id)
        local nextData = RoleTable[AlbumData.UnLockCount + 1]
        if nextData then
            local typeList = common:split(nextData.lockType, ",")
            local valList = common:split(nextData.lockValue, ",")
            local limit = { star = nil, level = nil }
            local desc = {}

            for i = 1, #typeList do
                local t, v = tonumber(typeList[i]), tonumber(valList[i])
                if t == 0 then
                    limit.star = v
                    table.insert(desc, "StarAchive " .. v)
                elseif t == 1 then
                    limit.level = v
                    table.insert(desc, "LevelAchive " .. v)
                end
            end

            AlbumData.NowLimit = limit
            AlbumData.NowLimitDesc = table.concat(desc, " and ")
        end
    end

    return AlbumData
end

-- 取得符合條件的解鎖數量
function SecretMessageManager_LimitAchiveCount(_id)
    local UserMercenaryManager = require("UserMercenaryManager")
    local count = 0
    local mInfoSorts = UserMercenaryManager:getMercenaryStatusInfos()
    local MercenaryId = 0

    for _, v in ipairs(mInfoSorts) do
        if v.itemId == _id then
            MercenaryId = v.roleId
            break
        end
    end

    local cur = UserMercenaryManager:getUserMercenaryById(MercenaryId)
    if cur then
        local cfg = getRoleTable(_id, 2)
        for _, v in ipairs(cfg) do
            local typeList = common:split(v.lockType, ",")
            local valList = common:split(v.lockValue, ",")
            local lockStar, lockLevel = nil, nil

            for i = 1, #typeList do
                local t, val = tonumber(typeList[i]), tonumber(valList[i])
                if t == 0 then lockStar = val end
                if t == 1 then lockLevel = val end
            end

            local starOk = (not lockStar or cur.starLevel >= lockStar)
            local levelOk = (not lockLevel or cur.level >= lockLevel)
            if starOk and levelOk then
                count = count + 1
            end
        end
    end

    return count
end

function SecretMessageManager_getMessageQueue()
    return SecretMessageData.messageQueue
end

function SecretMessageManager_getFirstMessageByItemId(itemId)
    for _, v in ipairs(SecretMessageData.messageQueue) do
        if v.itemId == itemId then
            return v
        end
    end
    return nil
end

function SecretMessageManager_getAllHeroData()
    return SecretMessageData.allHeroData
end

function SecretMessageManager_getPower()
    return SecretMessageData.power
end

function SecretMessageManager_getHistoryMessageByItemId(itemId)
    return SecretMessageData.allHeroData[itemId] and SecretMessageData.allHeroData[itemId].history or nil
end
