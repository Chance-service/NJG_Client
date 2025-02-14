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

-- �]�w�U�� URL �M�ɮצW��
function AnnounceDownLoad.setData(url, _fileName, _updateTime)
    URL = url
    fileName = _fileName
    UpdateTime = _updateTime
end

-- �ҰʤU�����ˬd�y�{
function AnnounceDownLoad.start(type)
    AnnounceDownLoad.requireConfig()
end

-- �����޿�]�ȮɵL�Ρ^
function AnnounceDownLoad.execute()
end

-- �ˬd�M�U���t�m�ɮ�
function AnnounceDownLoad.requireConfig()
    local CCFileUtils = CCFileUtils:sharedFileUtils()
    local savePath = ""
    local jsonFilePath = ""
    
    -- �]�m���|
    if CC_TARGET_PLATFORM_LUA == common.platform.CC_PLATFORM_WIN32 then
        savePath = CCFileUtils:getWritablePath() .. "/Annoucement/" .. fileName
        jsonFilePath = CCFileUtils:getWritablePath() .. "/Annoucement/update_info.json"
    else 
        savePath = CCFileUtils:getWritablePath() .. "hotUpdate/Annoucement/" .. fileName
        jsonFilePath = CCFileUtils:getWritablePath() .. "hotUpdate/Annoucement/update_info.json"
    end

    -- �ˬd�ɮ׬O�_�ݭn��s
    local updateRequired = isUpdateRequired(URL, jsonFilePath)
    if updateRequired then
        -- �U���ɮ�
        local result = downloadFile(URL, savePath)
        if result then
            CCLuaLog("File successfully downloaded and saved.")
            updateJsonFile(jsonFilePath, URL)
        else
            CCLuaLog("Failed to download the file.")
            return
        end
    end

    -- Ū���ɮפ��e
    local file = io.open(savePath, "r")
    if not file then
         return
    end

    local content = file:read("*a")
    file:close()

    -- �]�m�̤j���զ���
    local max_attempts = 50  -- ����50���A�C�����j0.2��A�`�@�j��10��
    local attempt_count = 0  -- ��e���զ���
    
    -- �ˬd�ɮפ��e
    if content == "" then
        lua_DownloadSchedulerId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(function(dt)
            -- �C������Ū���ɮסA�W�[���զ���
            attempt_count = attempt_count + 1

            -- ���ե��}�ɮ�
            local file = io.open(savePath, "r")
            if not file then
                print("Error: Cannot open file at " .. savePath)
                -- �ɮ׵L�k���}�A�����w�ɾ��ðh�X
                CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(lua_DownloadSchedulerId)
                lua_DownloadSchedulerId = nil
                return
            end
    
            -- Ū���ɮפ��e
            local content = file:read("*a")
            file:close()
    
            -- �ˬd�ɮפ��e�O�_���D�ťզr��
            if content:match("%S") then
                -- �p�GŪ���즳�Ĥ��e�A�����w�ɾ��óB�z���e
                CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(lua_DownloadSchedulerId)
                lua_DownloadSchedulerId = nil
                local AnnouncementPopPageBase = require("AnnouncementPopPageNew")
                AnnouncementPopPageBase:SetMessage(content)
            elseif attempt_count >= max_attempts then
                -- �W�L�̤j���զ��ơA�����w�ɾ��ÿ�X���~�H��
                CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(lua_DownloadSchedulerId)
                lua_DownloadSchedulerId = nil
                print("Error: Could not retrieve content after " .. max_attempts .. " attempts.")
            end
        end, 0.2, false)  -- �C0.2�����@��
        return
    end
    
    -- �p�G�ɮפ����šA�����]�m�T��
    local AnnouncementPopPageBase = require("AnnouncementPopPageNew")
    AnnouncementPopPageBase:SetMessage(content)
end

-- �U���ɮר��
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

-- �إ��ɮ�
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

-- �ˬd�O�_�ݭn��s
function isUpdateRequired(url, jsonFilePath)
    local data = readJsonFile(jsonFilePath)
    if not data or not data[fileName] then
        return true  -- �p�G JSON �ɮפ��s�b�ΨS���x�s�� URL ����s�ɶ��A�h�ݭn��s
    end

    -- �ˬd���A���W����s�ɶ��]�i�X�i�A���]�b JSON �ɮפ��x�s������� UNIX �ɶ��W�^
    local lastUpdateTime = data[fileName]
    return UpdateTime > lastUpdateTime  
end

-- ��s JSON �ɮ�
function updateJsonFile(jsonFilePath, url)
    local data = readJsonFile(jsonFilePath) or {}
    data[fileName] = UpdateTime  -- ��s��e URL ���̷s��s�ɶ�
    writeJsonFile(jsonFilePath, data)
end

-- Ū�� JSON �ɮרê�^��
function readJsonFile(filePath)
    local file = io.open(filePath, "r")
    if not file then
        return nil  -- �ɮפ��s�b
    end
    local content = file:read("*a")
    file:close()
    local decode = json.decode(content)  -- �N JSON ���e�ഫ����
    return  decode
end

-- ��ʮ榡�� JSON �r��
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

-- �N��g�J JSON �ɮרèϥ� formatJsonString
function writeJsonFile(filePath, data)
    CCLuaLog("writing: " .. filePath)
    local file = io.open(filePath, "w")
    if not file then
        CCLuaLog("Failed to open file for writing: " .. filePath)
        return false
    end

    -- �N���ഫ�� JSON �r��
    local jsonContent = json.encode(data)

    -- �榡�� JSON ���e
    jsonContent = formatJsonString(jsonContent)

    file:write(jsonContent)
    file:close()
    return true
end

return AnnounceDownLoad
