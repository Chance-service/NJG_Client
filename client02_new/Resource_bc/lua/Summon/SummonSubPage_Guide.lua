
--[[ 
    name: SummonSubPage_Guide
    desc: 召喚 子頁面 新手召喚
    author: youzi
    update: 2023/10/24 14:52
    description: 
--]]

local HP_pb = require("HP_pb") -- 包含协议id文件
local Activity4_pb = require("Activity4_pb")
local Activity6_pb = require("Activity6_pb")

local NodeHelper = require("NodeHelper")
local NodeHelperUZ = require("Util.NodeHelperUZ")
local InfoAccesser = require("Util.InfoAccesser")
local TimeDateUtil = require("Util.TimeDateUtil")
local ALFManager = require("Util.AsyncLoadFileManager")

local SummonDataMgr = require("Summon.SummonDataMgr")

local PRICE_ITEM_WITHOUT_COUNT_STR = "10000_1001_"
local VOUCHER_ITEM_STR = "30000_6004_0"

--[[ 測試資料模式 ]]
local IS_MOCK = false

local thisPageName = "SummonSubPage_Guide"


--[[ 本體 ]]

--[[ 本體 ]]
local Inst = require("Summon.SummonSubPage_Base"):new()
function Inst:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    return o
end


-- ##     ##    ###    ########  ####    ###    ########  ##       ######## 
-- ##     ##   ## ##   ##     ##  ##    ## ##   ##     ## ##       ##       
-- ##     ##  ##   ##  ##     ##  ##   ##   ##  ##     ## ##       ##       
-- ##     ## ##     ## ########   ##  ##     ## ########  ##       ######   
--  ##   ##  ######### ##   ##    ##  ######### ##     ## ##       ##       
--   ## ##   ##     ## ##    ##   ##  ##     ## ##     ## ##       ##       
--    ###    ##     ## ##     ## #### ##     ## ########  ######## ######## 


--[[ 協定 ]]
Inst.opcodes["ACTIVITY172_PICKUP_INFO_S"] = HP_pb.ACTIVITY172_PICKUP_INFO_S
Inst.opcodes["ACTIVITY172_PICKUP_DRAW_S"] = HP_pb.ACTIVITY172_PICKUP_DRAW_S

--[[ 請求冷卻幀數 ]]
Inst.requestCooldownFrame = 180
--[[ 請求冷卻剩餘 ]]
Inst.requestCooldownLeft = Inst.requestCooldownFrame

--[[ Spine ]]
Inst.spineBG = nil
Inst.spineSummon = nil
Inst.spineSummonNode = nil

Inst.orin_summonPriceStr = nil
Inst.orin_summon10PriceStr = nil

Inst.rewards = nil

-- #### ##    ## ######## ######## ########  ########    ###     ######  ######## 
--  ##  ###   ##    ##    ##       ##     ## ##         ## ##   ##    ## ##       
--  ##  ####  ##    ##    ##       ##     ## ##        ##   ##  ##       ##       
--  ##  ## ## ##    ##    ######   ########  ######   ##     ## ##       ######   
--  ##  ##  ####    ##    ##       ##   ##   ##       ######### ##       ##       
--  ##  ##   ###    ##    ##       ##    ##  ##       ##     ## ##    ## ##       
-- #### ##    ##    ##    ######## ##     ## ##       ##     ##  ######  ######## 


--[[ 當 收到封包 ]]
Inst.base_onReceivePacket = Inst.onReceivePacket
function Inst:onReceivePacket(packet)
    local slf = self

    self:base_onReceivePacket(packet)

    if self:handleSummonError(packet, HP_pb.ACTIVITY172_CHOSEN_DRAW_C) == true then return end

    if packet.opcode == HP_pb.ACTIVITY172_PICKUP_INFO_S or
       packet.opcode == HP_pb.ACTIVITY172_PICKUP_DRAW_S then
        local msg = Activity6_pb.NewbieCallInfo()
        msg:ParseFromString(packet.msgBuff)
        packet.msg = msg

        self:handleResponseInfo(packet.msg, packet.opcode)
    end
end

--[[ 當 頁面 進入 ]]
function Inst:onEnter_content ()
    local slf = self
    self.parentPage.tabStorage:setHelpBtn(true)


    -- 設置 Spine動畫
    if self.subPageCfg.spineBG ~= nil then

        local spineFolderAndName = common:split(self.subPageCfg.spineBG, ",")
        self.spineBG = SpineContainer:create(spineFolderAndName[1], spineFolderAndName[2])
        self.spineBG:registerFunctionHandler("SELF_EVENT", function(unknownArg, tag, eventName)
            if eventName == "end" or eventName == "End" then
                if slf.onSummonAnimDone_fn ~= nil then 
                    local temp = slf.onSummonAnimDone_fn
                    slf.onSummonAnimDone_fn = nil
                    temp()
                end
            end
        end)
        local spineBGNode = tolua.cast(self.spineBG, "CCNode")
        NodeHelperUZ:fitBGSpine(spineBGNode, {
            -- 目標中心點
            pivot = ccp(0.5, 0),
        })

        self.spineBG:setToSetupPose()
        self.spineBG:runAnimation(1, self.subPageCfg.spineAnimName_bg_idle, -1)
        
        self.container:getVarNode("spineBGNode"):addChild(spineBGNode)
    end

    NodeHelper:setStringForLabel(self.container,{ summonPittyLeftDescTxt = "", 
                                                  mSuitTenTimes = common:getLanguageString("@Summon.Result.resummon", 10) })
    if self.subPageCfg.isEntryAnim then

    end
    self.parentPage.container:registerMessage(MSG_REFRESH_REDPOINT)
end

--[[ 當 頁面 執行 ]]
function Inst:onExecute(selfContainer, parentPage)
  
    if Inst.JumpAnim then
        NodeHelper:setSpriteImage(self.container,{mSwitch="common_switch1_on.png"})
    else
        NodeHelper:setSpriteImage(self.container,{mSwitch="common_switch1.png"})
    end

    -- 若 仍在冷卻 則 冷卻
    if self.requestCooldownLeft > 0 then
        self.requestCooldownLeft = self.requestCooldownLeft - 1
    end

    local isNeedRequestInfo = false

    if isNeedRequestInfo then
        -- 若 已結束冷卻
        if self.requestCooldownLeft <= 0 then
            -- 開始冷卻
            self.requestCooldownLeft = self.requestCooldownFrame
            -- 請求 被動刷新
            self:sendRequestInfo()
        end
    end

end

--[[ 當 頁面 離開 ]]
Inst.base_onExit = Inst.onExit
function Inst:onExit(selfContainer, parentPage)

    self:base_onExit(selfContainer, parentPage)
    
    self.spineBG = nil
    self.spineSummon = nil
    self.spineSummonNode = nil
    self.isSummoning = false
    if self.task then
        ALFManager:cancel(self.task)
        self.task = nil
    end
    self.parentPage.container:removeMessage(MSG_REFRESH_REDPOINT)
end

-- ########  ##     ## ########  ##       ####  ######  
-- ##     ## ##     ## ##     ## ##        ##  ##    ## 
-- ##     ## ##     ## ##     ## ##        ##  ##       
-- ########  ##     ## ########  ##        ##  ##       
-- ##        ##     ## ##     ## ##        ##  ##       
-- ##        ##     ## ##     ## ##        ##  ##    ## 
-- ##         #######  ########  ######## ####  ######  

--[[ 載入 召喚Spine ]]
function Inst:loadSummonSpine ()
    -- 設置 Spine動畫
    if self.spineSummon == nil and self.subPageCfg.spineSummon ~= nil then
        CCLuaLog("--------loadSummonSpine1")
        local spineFolderAndName = common:split(self.subPageCfg.spineSummon, ",")
        self.spineSummon = SpineContainer:create(spineFolderAndName[1], spineFolderAndName[2])
        CCLuaLog("--------loadSummonSpine2")
        self.spineSummon:registerFunctionHandler("SELF_EVENT", function(unknownArg, tag, eventName)
            if eventName == "end" or eventName == "End" then
                if self.onSummonAnimDone_fn ~= nil then 
                    local temp = self.onSummonAnimDone_fn
                    self.onSummonAnimDone_fn = nil
                    temp()
                end
            end
        end)
        local spineSummonNode = tolua.cast(self.spineSummon, "CCNode")
        spineSummonNode:retain()
        NodeHelperUZ:fitBGSpine(spineSummonNode, {
            -- 目標中心點
            pivot = ccp(0.5, 0),
        })

        self.spineSummon:setToSetupPose()
        self.spineSummon:runAnimation(1, self.subPageCfg.spineAnimName_summon_idle, -1)
        
        self.container:getVarNode("spineSummonNode"):addChild(spineSummonNode)
        CCLuaLog("--------loadSummonSpine3")
    end
end

--[[ 播放 召喚Spine ]]
function Inst:playSummonSpine (rewardDatas)
    local animLevel = 1

    local heroCfgs = ConfigManager.getNewHeroCfg()
    local equipCfgs = ConfigManager.getEquipCfg()
    local isForBreak = false
    for idx, rewardData in ipairs(rewardDatas) do 

        while true do    
            --if rewardData.piece < 60 then break end -- continue   --碎片需求改為sr30 ssr60 專武50

            local newAnimLevel = animLevel
            
            if rewardData.type == SummonDataMgr.RewardType.HERO then
                local heroCfg = heroCfgs[rewardData.id]
                if heroCfg then
                    if heroCfg.Star < 6 then 
                        newAnimLevel = 2
                    else
                        newAnimLevel = 3
                    end
                end
            elseif rewardData.type == SummonDataMgr.RewardType.AW_EQUIP then
                local equipCfg = equipCfgs[rewardData.id]
                if equipCfg then
                    if equipCfg.quality < 6 then 
                        newAnimLevel = 2
                    else
                        newAnimLevel = 3
                    end
                end
            end

            if newAnimLevel > animLevel then
                animLevel = newAnimLevel
            end

        break end
        
        -- 目標為最高階動畫時不再檢查
        if animLevel >= 3 then break end
    end

    local summonAnimName = self.subPageCfg.spineAnimName_summon_summon_list[animLevel]

    if self.spineSummon ~= nil then
        self.spineSummon:setToSetupPose()
        self.spineSummon:runAnimation(1, summonAnimName, 0)
    end
    if self.spineBG ~= nil then
        self.spineBG:setToSetupPose()
        self.spineBG:runAnimation(1, self.subPageCfg.spineAnimName_bg_summon, 0)
    end
end

--[[ 送出 請求資訊 ]]
Inst.base_sendRequestInfo = Inst.sendRequestInfo
function Inst:sendRequestInfo (isShowLoading)
    if isShowLoading == nil then isShowLoading = true end
    if IS_MOCK then
        self:onReceivePacket({
            opcode = HP_pb.ACTIVITY172_PICKUP_INFO_S,
            msg = {
                freeTimes = 0,
                onceCostGold = 120,
                tenCostGold = 1200,
            }
        })
        return
    end
    self:base_sendRequestInfo(isShowLoading)
    common:sendEmptyPacket(HP_pb.ACTIVITY172_PICKUP_INFO_C, isShowLoading)
end


--[[ 處理 回傳 ]]
function Inst:handleResponseInfo (msgInfo, opcode)
    if msgInfo.actEnd then   -- 活動結束
        -- 紀錄結束狀態
        require("Activity.ActivityInfo")
        ActivityInfo:addTempCloseActivity(Const_pb.ACTIVITY172_PICKUP)
        PageManager.popPage("Summon.SummonPage")
        local GuideManager = require("Guide.GuideManager")
        if GuideManager.isInGuide then
            PageManager.popPage("NewbieGuideForcedPage")
        end
        PageManager.pushPage("Summon.SummonPage")
        PageManager.popPage("Summon.SummonGuideResultPage")
        return
    end
    local slf = self

    local priceData = {}

    dump(msgInfo, "msgInfo")
    for idx, val in ipairs(msgInfo.reward) do
        print(string.format("msgInfo.reward[%d] : %s", idx, tostring(val)))
    end

    -- 若有收到獎勵
    if msgInfo.reward and #msgInfo.reward ~= 0 then
        local itemStrs = msgInfo.reward
        if opcode == HP_pb.ACTIVITY172_PICKUP_DRAW_S then
            self:handleRewards(itemStrs, true)
        elseif opcode == HP_pb.ACTIVITY172_PICKUP_INFO_S then
            self:handleRewards(itemStrs, true, true)
        end
    end
end

--[[ 送出 十抽 ]]
function Inst:sendSummon10 ()
    if IS_MOCK then
        self:onReceivePacket({
            opcode = HP_pb.ACTIVITY172_PICKUP_DRAW_S,
            msg = {
                reward = "10000_1001_1,10000_1002_1,10000_1003_1,10000_1004_1,10000_1005_1,10000_1006_1,10000_1007_1,10000_1008_1,10000_1009_1,10000_1010_1",
            }
        })
        return
    end
    if self.isSummoning then
        return
    end
    self.isSummoning = true
    -- 載入 召喚Spine
    local spineFolderAndName = common:split(self.subPageCfg.spineSummon, ",")
    local texNum = self.spineSummon and 0 or 30
    self.task = ALFManager:loadSpineTask(spineFolderAndName[1] .. "/", spineFolderAndName[2], texNum, function() 
        if not Inst.JumpAnim then
            self:loadSummonSpine()
        end

        local msg = Activity4_pb.ActivityCallDraw()
        msg.times = 10
        common:sendPacket(HP_pb.ACTIVITY172_PICKUP_DRAW_C, msg, true)

        self.isSummoning = false
    end)
end

return Inst