
----------------------------------------------------------------------------------
local thisPageName = "AnnouncementPopPageNew"
local ConfigManager = require("ConfigManager");
local AnnounceDownLoad = require("AnnounceDownLoad")
local NodeHelper = require("NodeHelper")
local HP_pb = require("HP_pb")
local Bulletin = require("Bulletin_pb")
require("Util.LockManager")
local AnnouncementPopPageBase = {}
local opcodes ={
    BULLETIN_TITLE_LIST_S=HP_pb.BULLETIN_TITLE_LIST_S,
    BULLETIN_CONTENT_SYNC_S=HP_pb.BULLETIN_CONTENT_SYNC_S
}
local option = {
	ccbiFile = "AnnouncementPage.ccbi",
	handlerMap = {
	onClose 		= "onClose",
    onNormal        = "onNormal",
    onAct           = "onAct",
    onSelect        = "onSelect",
    onBack          = "onBack",
    toAct           = "toAct"
	},
    opcode = opcodes
};

local BuildItem={ [2] = "AnnouncementPageContentA.ccbi",
                  [1] = "AnnouncementPageContentB.ccbi"}

local ActItem={}
local StrItem={}

local AllInfo = { }
local nowTag = 2
local isOpen = false
local OpenList = { }
local ReadyToGetMainSceneData = false

local AnnouncementPopConfg={}

local AnnoCfg = ConfigManager.getAnnounceCfg()

local ToActFun={
    [1] = { Fun = function()  end},
    [2] = { Fun = 
            function()
                local closeR18 = VaribleManager:getInstance():getSetting("IsCloseR18")
                if tonumber(closeR18) == 1 then
                    MessageBoxPage:Msg_Box(common:getLanguageString("@ComingSoon"))
                    return
                end
                if LockManager_getShowLockByPageName(GameConfig.LOCK_PAGE_KEY.GLORY_HOLE) then
                    MessageBoxPage:Msg_Box(LockManager_getLockStringByPageName(GameConfig.LOCK_PAGE_KEY.GLORY_HOLE))
                else
                    local Activity5_pb = require("Activity5_pb")
                    local msg=Activity5_pb.GloryHoleReq()
                    msg.action=0
                    common:sendPacket(HP_pb.ACTIVITY175_GLORY_HOLE_C, msg, true)     
                end           
            end ,
            ActId = 175
            },
    [3] = { Fun = 
            function() 
                PageManager.pushPage("DailyBundlePage")
            end ,
            ActId = 160
            },
    [4] = { Fun = 
            function ()
                if LockManager_getShowLockByPageName(GameConfig.LOCK_PAGE_KEY.MONTHLY_CARD) then
                   MessageBoxPage:Msg_Box(LockManager_getLockStringByPageName(GameConfig.LOCK_PAGE_KEY.MONTHLY_CARD))
                else
                   require("IAP.IAPPage"):setEntrySubPage("MonthCard")
                   PageManager.pushPage("IAP.IAPPage")
                end
            end},
      [5] = { Fun = 
                function (txt)
	            	if txt == nil then 
	            		 MessageBoxPage:Msg_Box("URL EMPTY")
	            	end
	               common:openURL(txt)
	         end },
       [8] = { Fun = 
            function ()
                if LockManager_getShowLockByPageName(GameConfig.LOCK_PAGE_KEY.Event001) then
                   MessageBoxPage:Msg_Box(LockManager_getLockStringByPageName(GameConfig.LOCK_PAGE_KEY.Event001))
                else
                    local TimeTxt = CCUserDefault:sharedUserDefault():getStringForKey("ACT191_"..UserInfo.playerInfo.playerId)
                    local event001Page = require "Event001Page"
                    if TimeTxt == "" or event001Page:getStageInfo().startTime ~= tonumber(TimeTxt) then
                        PageManager.pushPage("Event001VideoBlack")
                    else
                        PageManager.pushPage("Event001Page")
                    end
                end
            end},

}

function AnnouncementPopPageBase:onEnter(container)	
    AnnouncementPopPageBase.container = container
    --BtnState
    NodeHelper:setNodesVisible(container,{ mTag1 = (nowTag == 2), mTag2 = (nowTag == 1),mBack = false})
    self:registerPacket(container)
    common:sendEmptyPacket(HP_pb.BULLETIN_TITLE_LIST_C, true)
    isOpen = true
end

function AnnouncementPopPageBase:isFinish(Str)
    if not Str then return false end
    local val = common:split(Str,"_")
    local ActId = tonumber (val[1])
    if ToActFun[ActId] and ToActFun[ActId].ActId == 160 then -- DailyBundle
         local DailyBundleData = require ("Activity.DailyBundleData")
         if DailyBundleData:isGetAll() then return true end
    end
    return false
end

function AnnouncementPopPageBase:onReceivePacket(container)
    local opcode = container:getRecPacketOpcode()
    local msgBuff = container:getRecPacketBuffer()
    if opcode == opcodes.BULLETIN_TITLE_LIST_S then
        local msg = Bulletin.BulletinTitleInfo()
        msg:ParseFromString(msgBuff)
       local TmpInfo = {}
       OpenList = {}
       AllInfo = { }
        for i, info in ipairs(msg.allInfo) do
            if info.show and not self:isFinish(info.titleStr) then
                table.insert(AllInfo, {
                    id = info.id,
                    kind = info.kind,
                    titleStr = info.titleStr,
                    updateTime = info.updateTime,
                    sort = info.sort
                })
                table.insert(OpenList,tostring (info.id)..".txt")
            end
        end
        AnnouncementPopPageBase:delNonUseFile()
        table.sort(AllInfo, function(a, b) return a.sort < b.sort end)
        self:buildScrollView(AnnouncementPopPageBase.container)
    end
    if opcode == opcodes.BULLETIN_CONTENT_SYNC_S then
        local msg = Bulletin.BulletinContentRsp()
        msg:ParseFromString(msgBuff)
        local id = msg.id
        local lastRefreshTime=0
        local DownloadTxt = msg.txturl
        local Table = common:split(DownloadTxt,"/")
        local fileName = Table[#Table]

        for i = 1 , #AllInfo do
            if AllInfo[i].id == id then
                lastRefreshTime = AllInfo[i].updateTime
            end
        end
        local Path = ""
        for i = 1 , # Table do
            if i~=1 and i~=2 then
                Path=Path.."/"..Table[i]
            end
        end
        local ErrorCode = msg.errorCode
        local Site = ""  
        if UserInfo.serverId ~= 9 then
            Site = VaribleManager:getInstance():getSetting("AnnouncementURL") .. Path 
        else
            Site = "http://backend.quantagalaxies.com:34567" ..  DownloadTxt
        end
        AnnounceDownLoad.setData(Site,fileName,lastRefreshTime)
        AnnounceDownLoad.start()
        --print (Site)
    end
end

function AnnouncementPopPageBase:delNonUseFile()
   local CCFileUtils = CCFileUtils:sharedFileUtils()

   -- ?�A?�����C��???�r��A�H�K�_�d��
   local serverFileDict = {}
   for _, fileName in ipairs(OpenList) do
       serverFileDict[fileName] = true
   end
   -- ���w���a�s?��󪺥�?
   local directoryPath = CCFileUtils:getWritablePath() .. "Annoucement/"

    -- ?��?��?����󪺨�?
    deleteExpiredFiles(directoryPath, serverFileDict)
end
-- �C�X��?�����Ҧ� .txt ���
function listTxtFiles(directoryPath)
    local fileList = {}

    -- �ϥ� io.popen ??��t?�R�O�C�X���
    local command = 'ls "' .. directoryPath .. '"'
    if package.config:sub(1,1) == '\\' then
        command = 'dir "' .. directoryPath .. '" /b'  -- Windows �ϥ� 'dir /b'
    end

    local pfile = io.popen(command)
    
    if pfile then
        for file in pfile:lines() do
            -- �u���� .txt ���
            if file:sub(-4) == ".txt" then
                table.insert(fileList, file)
            end
        end
        pfile:close()
    end
    
    return fileList
end

-- ?�����W����?�A��Τ_ Windows �M Unix ?���?
function getFileName(filePath)
    -- ??�ǰt Unix ?�檺��?�]�ϥΥ��ק� /�^
    local fileName = filePath:match("^.+/(.+)$")
    
    -- �p�G?�G�O nil�A???�ǰt Windows ?�檺��?�]�ϥΤϱק� \�^
    if not fileName then
        fileName = filePath:match("^.+\\(.+)$")
    end
    
    return fileName
end

-- ��?�G?�����b�A?���C�������
function deleteExpiredFiles(directoryPath, serverFileDict)
    -- ?����?�����Ҧ����C��
    local fileList = listTxtFiles(directoryPath)
    -- �M?�C?���
    for _, filePath in ipairs(fileList) do
        -- ?�����W
        local fileName = getFileName(directoryPath..filePath)

        -- ?�d���O�_�s�b�_�A?�����C��
        if not serverFileDict[fileName] then
            -- ��󤣦b�A?���C���A?����
            local result = os.remove(directoryPath..filePath)
            if result then
                print("Deleted expired file: " .. filePath)
            else
                print("Failed to delete file: " .. filePath)
            end
        end
    end
end



function AnnouncementPopPageBase:buildScrollView(container)
    --BtnState
    NodeHelper:setNodesVisible(container,{ mTag1 = (nowTag == 2), mTag2 = (nowTag == 1),mBack = false})

    local Scrollview = container:getVarScrollView("mAnnMsgContent")
    Scrollview:removeAllCell()
    for key , data in pairs (AllInfo) do
        if data.kind == nowTag then
            local cell = CCBFileCell:create()
            cell:setCCBFile(BuildItem[nowTag])
            local handler
            if nowTag == 2 then
                handler = common:new({id = data.id }, ActItem)
            else
                handler = common:new({id = data.id }, StrItem)
            end
            cell:registerFunctionHandler(handler)
            Scrollview:addCell(cell)
        end
    end
    Scrollview:setTouchEnabled(true)
    Scrollview:orderCCBFileCells()
end

function AnnouncementPopPageBase:onNormal()
    if nowTag == 1 then return end
    nowTag=1
    AnnouncementPopPageBase:buildScrollView(AnnouncementPopPageBase.container)
end

function AnnouncementPopPageBase:onAct()
    if nowTag == 2 then return end
    nowTag=2
    AnnouncementPopPageBase:buildScrollView(AnnouncementPopPageBase.container)
end

function AnnouncementPopPageBase:onBack()
  AnnouncementPopPageBase:buildScrollView(AnnouncementPopPageBase.container)
end

function AnnouncementPopPageBase:onClose(container)
    AnnouncementPopPageBase:removePacket(container)
    AllInfo = { }
    PageManager.popPage(thisPageName)
    --if ReadyToGetMainSceneData then
    --    ReadyToGetMainSceneData = false
    --    local  MainScenePageInfo = require "MainScenePage"
    --    MainScenePageInfo.onEnter(MainScenePageInfo.container)
    --end
   isOpen = false
end

function AnnouncementPopPageBase:SetMessage(dataCfg)
    local container = AnnouncementPopPageBase.container
    AnnouncementPopConfg = dataCfg
    AnnouncementPopPageBase:buildHtml(container)
    NodeHelper:setNodesVisible(container,{mBack = true})
end
function AnnouncementPopPageBase:buildHtml(container)
    local _scrollviewContent = container:getVarScrollView("mAnnMsgContent")
    local size = _scrollviewContent:getViewSize()
    _scrollviewContent:removeAllCell()

    -- �إ� HTML ���e
    local htmlText = CCHTMLLabel:createWithString(AnnouncementPopConfg, size, "Helvetica")
    -- ���o���e����
    local height = htmlText:getContentSize().height

    -- ��l��m�]�m�b�u�ʵ��ϩ����~���A�]�m�������z��
    htmlText:setPosition(ccp(0, -50))

    -- �K�[��u�ʵ��Ϥ�
    _scrollviewContent:addChild(htmlText)

    -- �]�m�u�ʵ��Ϫ����e�ؤo
    _scrollviewContent:setContentSize(CCSizeMake(_scrollviewContent:getContentSize().width, height))

    -- �ʵe�G�q�����H�J�ò��ʨ�i���ϰ�
    local targetPosition = ccp(0, 0)  -- �̲צ�m
    local moveAction = CCMoveTo:create(0.5, targetPosition)  -- 0.5���q�������ʨ�ؼЦ�m
    htmlText:runAction(moveAction)

    -- �]�m�u�ʵ��Ϫ�����
    _scrollviewContent:setContentOffset(ccp(0, size.height - height))
end

function ActItem:onRefreshContent(content)
    local container = content:getCCBFileNode()
    local data = AnnouncementPopPageBase:GetDetial(self.id)
    if not data then return end
    local val = common:split(data.titleStr,"_")
    self.ActId = tonumber (val[1])
    if val[2] then
        self.txt = val [2] or ""
    end
    local Img = ""
    if AnnoCfg[self.ActId] then
        Img = AnnoCfg[self.ActId].Banner
        NodeHelper:setNodesVisible(container,{mBtn = (AnnoCfg[self.ActId].isJump == 1)})
    end
    if Img ~= "" then
        NodeHelper:setSpriteImage(container,{ bannerImg= Img })
    end
    if self.ActId == 5 then
        NodeHelper:setStringForLabel(container,{mTxt=common:getLanguageString("@GoToHttp")})
    else
        NodeHelper:setStringForLabel(container,{mTxt=common:getLanguageString("@GoToActivity")})
    end
end

function ActItem:onBannerClick()
     local msg = Bulletin.BulletinContentRet()
     msg.id = self.id 
     common:sendPacket(HP_pb.BULLETIN_CONTENT_SYNC_C, msg, true)
end

function ActItem:toAct(container)
    local id = self.ActId
    local txt = nil
    if id == 5 then --discord
        txt=self.txt
    end
    if ToActFun[id] then
        ToActFun[id].Fun(self.txt)
    end
    PageManager.popPage(thisPageName)
end

function StrItem:onRefreshContent(content)
    local container = content:getCCBFileNode()
    local data = AnnouncementPopPageBase:GetDetial(self.id)
    if not data then return end
     NodeHelper:setStringForLabel(container,{titleText=data.titleStr})
end

function StrItem:onBannerClick()
     local msg = Bulletin.BulletinContentRet()
     msg.id = self.id 
     common:sendPacket(HP_pb.BULLETIN_CONTENT_SYNC_C, msg, true)
end

function AnnouncementPopPageBase:GetDetial(_id)
    for k,v in pairs (AllInfo) do
        if v.id==_id then
            return v
        end
    end
    return nil
end

function AnnouncementPopPageBase:removePacket(container)
    for key, opcode in pairs(opcodes) do
        if string.sub(key, -1) == "S" then
            container:removePacket(opcode)
        end
    end
end

function AnnouncementPopPageBase:registerPacket(container)
    for key, opcode in pairs(opcodes) do
        if string.sub(key, -1) == "S" then
            container:registerPacket(opcode)
        end
    end
end

 local function getCurrentDateString()
    local dateTable = os.date("*t")
    local year = dateTable.year
    local month = string.format("%02d", dateTable.month)  -- Ensure two digits
    local day = string.format("%02d", dateTable.day)      -- Ensure two digits
    return year .. "_" .. month .. "_" .. day
end

 local function markAnnouncementShownToday()
     local key = "ANN_ACT_" .. UserInfo.playerInfo.playerId
     local todayDate = getCurrentDateString()
     ReadyToGetMainSceneData = true
     -- Store today's date to indicate that the announcement was shown
     CCUserDefault:sharedUserDefault():setStringForKey(key, todayDate)
     CCUserDefault:sharedUserDefault():flush()  -- Ensure the data is saved
 end

function AnnouncementPopPageBase_isShowToday()
    local closeR18 = VaribleManager:getInstance():getSetting("IsCloseR18")
    if tonumber(closeR18) == 1 then
        return true
    end
    local key = "ANN_ACT_" .. UserInfo.playerInfo.playerId
    local storedValue = CCUserDefault:sharedUserDefault():getStringForKey(key)

    local todayDate = getCurrentDateString()  -- Get today's date as string

    -- If stored value is today's date, skip showing announcement
    if storedValue == todayDate then
        return true  -- Already shown today
    end

    return false  -- Not shown today
end

function AnnouncementPopPageBase_isPageOpen()
    return isOpen 
end

function AnnouncementPopPageBase_ShowSync()
    if AnnouncementPopPageBase_isShowToday() then
        -- Skip showing the announcement today
        --print("Announcement already shown today. Skipping.")
        return false
    else
        PageManager.pushPage(thisPageName)
        -- Mark that the announcement has been shown today

        markAnnouncementShownToday()
        return true
    end
end

local CommonPage = require("CommonPage");
local AnnouncementPopPage = CommonPage.newSub(AnnouncementPopPageBase, thisPageName, option);

return AnnouncementPopPage