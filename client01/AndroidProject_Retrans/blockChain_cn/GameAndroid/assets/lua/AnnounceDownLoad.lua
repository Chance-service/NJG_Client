local json = require('json')
local socket = require("socket.socket")
local http = require("socket.http")
local ltn12 = require("ltn12")
--local CCFileUtils = CCFileUtils:sharedFileUtils()

local AnnounceDownLoad = {
    firstEnterGame = false
}

local URL = ""
local fileName = ""
local UpdateTime = ""
local jsonFilePath = CCFileUtils:sharedFileUtils():getWritablePath() .. "/Annoucement/update_info.json"

local lua_DownloadSchedulerId = nil

-- 設定下載 URL 和檔案名稱
function AnnounceDownLoad.setData(url, _fileName, _updateTime)
    URL = url
    fileName = _fileName
    UpdateTime = _updateTime
end

-- 啟動下載或檢查流程
function AnnounceDownLoad.start(type)
    AnnounceDownLoad.requireConfig()
end

-- 執行邏輯（暫時無用）
function AnnounceDownLoad.execute()
end

-- 檢查和下載配置檔案
function AnnounceDownLoad.requireConfig()
    local CCFileUtils = CCFileUtils:sharedFileUtils()
    local savePath = ""
    local jsonFilePath = ""
    
    -- 設置路徑
    if CC_TARGET_PLATFORM_LUA == common.platform.CC_PLATFORM_WIN32 then
        savePath = CCFileUtils:getWritablePath() .. "/Annoucement/" .. fileName
        jsonFilePath = CCFileUtils:getWritablePath() .. "/Annoucement/update_info.json"
    else 
        savePath = CCFileUtils:getWritablePath() .. "hotUpdate/Annoucement/" .. fileName
        jsonFilePath = CCFileUtils:getWritablePath() .. "hotUpdate/Annoucement/update_info.json"
    end

    -- 檢查檔案是否需要更新
    local updateRequired = isUpdateRequired(URL, jsonFilePath)
    if updateRequired then
        -- 下載檔案
        local result = downloadFile(URL, savePath)
        if result then
            CCLuaLog("File successfully downloaded and saved.")
            updateJsonFile(jsonFilePath, URL)
        else
            CCLuaLog("Failed to download the file.")
            return
        end
    end

    -- 讀取檔案內容
    local file = io.open(savePath, "r")
    if not file then
         return
    end

    local content = file:read("*a")
    file:close()

    -- 設置最大嘗試次數
    local max_attempts = 50  -- 嘗試50次，每次間隔0.2秒，總共大約10秒
    local attempt_count = 0  -- 當前嘗試次數
    
    -- 檢查檔案內容
    if content == "" then
        lua_DownloadSchedulerId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(function(dt)
            -- 每次嘗試讀取檔案，增加嘗試次數
            attempt_count = attempt_count + 1

            -- 嘗試打開檔案
            local file = io.open(savePath, "r")
            if not file then
                print("Error: Cannot open file at " .. savePath)
                -- 檔案無法打開，取消定時器並退出
                CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(lua_DownloadSchedulerId)
                lua_DownloadSchedulerId = nil
                return
            end
    
            -- 讀取檔案內容
            local content = file:read("*a")
            file:close()
    
            -- 檢查檔案內容是否有非空白字符
            if content:match("%S") then
                -- 如果讀取到有效內容，取消定時器並處理內容
                CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(lua_DownloadSchedulerId)
                lua_DownloadSchedulerId = nil
                local AnnouncementPopPageBase = require("AnnouncementPopPageNew")
                AnnouncementPopPageBase:SetMessage(content)
            elseif attempt_count >= max_attempts then
                -- 超過最大嘗試次數，取消定時器並輸出錯誤信息
                CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(lua_DownloadSchedulerId)
                lua_DownloadSchedulerId = nil
                print("Error: Could not retrieve content after " .. max_attempts .. " attempts.")
            end
        end, 0.2, false)  -- 每0.2秒執行一次
        return
    end
    
    -- 如果檔案不為空，直接設置訊息
    local AnnouncementPopPageBase = require("AnnouncementPopPageNew")
    AnnouncementPopPageBase:SetMessage(content)
end

-- 下載檔案函數
function downloadFile(url, savePath)

    CurlDownload:getInstance():downloadFile(url, savePath)
    CurlDownload:getInstance():update(1)
    return true
    --if success and status_code == 200 then
    --    local content = table.concat(response_body)
    --    createFile(savePath, content)
    --    return true
    --else
    --    CCLuaLog("Download failed with status code: " .. status_code)
    --    return false
    --end
end

-- 建立檔案
function createFile(savePath, content)
    local file = io.open(savePath, "w")
    if not file then
        CCLuaLog("Failed to create file: " .. savePath)
        return false
    end

    file:write(content)
    file:close()
    CCLuaLog("File created and content written: " .. savePath)
    return true
end

-- 檢查是否需要更新
function isUpdateRequired(url, jsonFilePath)
    local data = readJsonFile(jsonFilePath)
    if not data or not data[fileName] then
        return true  -- 如果 JSON 檔案不存在或沒有儲存此 URL 的更新時間，則需要更新
    end

    -- 檢查伺服器上的更新時間（可擴展，假設在 JSON 檔案中儲存的日期為 UNIX 時間戳）
    local lastUpdateTime = data[fileName]
    return UpdateTime > lastUpdateTime  
end

-- 更新 JSON 檔案
function updateJsonFile(jsonFilePath, url)
    local data = readJsonFile(jsonFilePath) or {}
    data[fileName] = UpdateTime  -- 更新當前 URL 的最新更新時間
    writeJsonFile(jsonFilePath, data)
end

-- 讀取 JSON 檔案並返回表
function readJsonFile(filePath)
    local file = io.open(filePath, "r")
    if not file then
        return nil  -- 檔案不存在
    end
    local content = file:read("*a")
    file:close()
    local decode = json.decode(content)  -- 將 JSON 內容轉換為表
    return  decode
end

-- 手動格式化 JSON 字串
function formatJsonString(jsonString)
    
    local formatted = ""
    local indentLevel = 0
    local inQuote = false

    for i = 1, #jsonString do
        local char = jsonString:sub(i, i)

        if char == "\"" and jsonString:sub(i - 1, i - 1) ~= "\\" then
            inQuote = not inQuote
        end

        if not inQuote then
            if char == "{" or char == "[" then
                indentLevel = indentLevel + 1
                formatted = formatted .. char .. "\n" .. string.rep("    ", indentLevel)
            elseif char == "}" or char == "]" then
                indentLevel = indentLevel - 1
                formatted = formatted .. "\n" .. string.rep("    ", indentLevel) .. char
            elseif char == "," then
                formatted = formatted .. char .. "\n" .. string.rep("    ", indentLevel)
            else
                formatted = formatted .. char
            end
        else
            formatted = formatted .. char
        end
    end

    return formatted
end

-- 將表寫入 JSON 檔案並使用 formatJsonString
function writeJsonFile(filePath, data)
    CCLuaLog("writing: " .. filePath)
    local file = io.open(filePath, "w")
    if not file then
        CCLuaLog("Failed to open file for writing: " .. filePath)
        return false
    end

    -- 將表轉換為 JSON 字串
    local jsonContent = json.encode(data)

    -- 格式化 JSON 內容
    jsonContent = formatJsonString(jsonContent)

    file:write(jsonContent)
    file:close()
    return true
end

return AnnounceDownLoad
