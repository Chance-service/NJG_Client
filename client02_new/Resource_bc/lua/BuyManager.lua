local BuyManager = {}
local NowBuyInfo = nil 
local UserInfo = require("PlayerInfo.UserInfo");
local TapDBManager = require("TapDBManager")
local NewID = ""
function BuyManager.Buy(playerId, buyInfo)
     if (Golb_Platform_Info.is_h365) or (Golb_Platform_Info.is_jgg) or (Golb_Platform_Info.is_kuso) or (Golb_Platform_Info.is_aplus) or (Golb_Platform_Info.is_op) or (Golb_Platform_Info.is_gp) then --H365, jgg ,kuso
        libPlatformManager:getPlatform():buyGoods(buyInfo)
        CCLuaLog("-------------------------"..buyInfo)
     elseif (Golb_Platform_Info.is_r18) or (Golb_Platform_Info.is_erolabs) then --R18 , erolabs
        local title = Language:getInstance():getString("@SDK3")
        local message = ""
        local yesStr = ""

        local openBindGameCallback = function (BindGameResult)
            CCLuaLog("BindGameResult1")
            CCLuaLog("isSuccess = " .. tostring(BindGameResult.isSuccess))
            CCLuaLog("result: " .. BindGameResult.result)
            if BindGameResult.isSuccess == true then
                local userID = BindGameResult.user_id
                local token = EcchiGamerSDK.getToken()
                CCLuaLog("userID: " .. userID)
                CCLuaLog("token: " .. token)
                --libPlatformManager:getPlatform():setIsGuest(0)
                -- to server bind --
                local AccountBound_pb = require("AccountBound_pb")
                local msg = AccountBound_pb.HPAccountBoundConfirm()
                msg.userId = userID
                msg.wallet = ""
                NewID = userID
                common:sendPacket(HP_pb.ACCOUNT_BOUND_REWARD_C, msg, false)
            else
                CCLuaLog("BindGameResult2")
                if BindGameResult.exception ~= "" then
                    CCLuaLog("exception: " .. BindGameResult.exception)
                end
                CCLuaLog("errorCode: " .. BindGameResult.result)
                MessageBoxPage:Msg_Box_Lan("@ERRORCODE_12003")
            end
            CCLuaLog("BindGameResult3")
        end
        local IsGuest = libPlatformManager:getPlatform():getIsGuest() 
        if (IsGuest == 0) then
            -- EROLABS刷新ECoin
            if (Golb_Platform_Info.is_erolabs) then
                local playtoken =  CCUserDefault:sharedUserDefault():getStringForKey("ecchigamer.token")
                if (playtoken ~= "") then
                    local msg = Shop_pb.ECoinRequest()
                    msg.token = playtoken
                    common:sendPacket(HP_pb.SHOP_ECOIN_C, msg, true)
                end
            end
            -- 工口刷新honeyP
            if (Golb_Platform_Info.is_r18) then
                local playtoken =  CCUserDefault:sharedUserDefault():getStringForKey("ecchigamer.token")
                local IsGuest = libPlatformManager:getPlatform():getIsGuest() 
                if (playtoken ~= "")  then
                    local msg = Shop_pb.HoneyPRequest()
                    msg.token = playtoken
                    common:sendPacket(HP_pb.SHOP_HONEYP_C, msg, true)
                end
            end
            BuyManager.callbackBuyInfo = buyInfo
            BuyManager.openBuyGoodsCallback = function(buyInfo)
                local coin = libPlatformManager:getPlatform():getHoneyP()
                CCLuaLog("HoneyP or ECoin : " .. coin)
                if (coin < buyInfo.productPrice) then -- coin not enough
                    if (Golb_Platform_Info.is_r18) then
			    	    message = Language:getInstance():getString("@SDK4")
                    elseif (Golb_Platform_Info.is_erolabs) then
                        message = Language:getInstance():getString("@SDK13")
                    end
			    	yesStr = Language:getInstance():getString("@SDK5")
                
                    local openPayment = function(bool)
                        if bool then
                        --
                            EcchiGamerSDK:openPayment()
                        --
                        end
                    end
                
			        PageManager.showConfirm(title, message, openPayment, true, yesStr)
			    else -- enough
			         local buyShopItem = function(bool)
                        if bool then
                        --
                            local playtoken =  CCUserDefault:sharedUserDefault():getStringForKey("ecchigamer.token")
                            if (playtoken ~= "")
                            then
                                if (Golb_Platform_Info.is_r18) then
                                    local msg = Shop_pb.HoneyPBuyRequest()
                                    msg.token = playtoken
                                    msg.pid = tonumber(buyInfo.productId)
                                    common:sendPacket(HP_pb.SHOP_HONEYP_BUY_C, msg, true);
                                elseif (Golb_Platform_Info.is_erolabs) then
                                    local msg = Shop_pb.ECoinBuyRequest()
                                    msg.token = playtoken
                                    msg.pid = tonumber(buyInfo.productId)
                                    common:sendPacket(HP_pb.SHOP_ECOIN_BUY_C, msg, true);
                                end
                            end
                        --
                        end
                    end
                    if (Golb_Platform_Info.is_r18) then
			    	    message = common:fill(Language:getInstance():getString("@SDK6"), tostring(coin))
                    elseif (Golb_Platform_Info.is_erolabs) then
                        message = common:fill(Language:getInstance():getString("@SDK14"), tostring(coin))
                    end
			    	NowBuyInfo = buyInfo
			    	PageManager.showConfirm(title, message, buyShopItem, true)
			    end
            end
		else
            local GotoBindCheck = function(bool)
                if bool then
                    --
                    EcchiGamerSDK:openAccountBindGame(UserInfo.playerInfo.playerId, openBindGameCallback)
                    --
                end
            end
            if (Golb_Platform_Info.is_r18) then
				message = Language:getInstance():getString("@SDK9")
            elseif (Golb_Platform_Info.is_erolabs) then
                message = Language:getInstance():getString("@SDK15")
            end
			yesStr = Language:getInstance():getString("@SDK10")

			PageManager.showConfirm(title, message, GotoBindCheck, true, yesStr)
		end
     end       
end

function BuyManager:SendtogetHoneyP()
    local playtoken =  CCUserDefault:sharedUserDefault():getStringForKey("ecchigamer.token")
    CCLuaLog("SendtogetHoneyP1 token : " .. playtoken)
    if (playtoken ~= "") then
        local msg = Shop_pb.HoneyPRequest()
        msg.token = playtoken
        common:sendPacket(HP_pb.SHOP_HONEYP_C, msg, true);-- getHoneyP
        CCLuaLog("SendtogetHoneyP2")
    end
end

function BuyManager:SendtogetECoin()
    local playtoken =  CCUserDefault:sharedUserDefault():getStringForKey("ecchigamer.token")
    CCLuaLog("SendtogetECoin1 token : " .. playtoken)
    if (playtoken ~= "") then
        local msg = Shop_pb.ECoinRequest()
        msg.token = playtoken
        common:sendPacket(HP_pb.SHOP_ECOIN_C, msg, true);-- getECoin
        CCLuaLog("SendtogetECoin2")
    end
end

function BuyManager:onReceiveBuyPacket(opcode, msgBuff) --R18 or EROLABS USE
    CLuaLog("BuyManager:onReceiveBuyPacket : " .. opcode)
end

function BuyManager:onReceiveBoundAccount() --R18 or EROLABS USE
    CCLuaLog("----------Bind Success--------------")
    MessageBoxPage:Msg_Box_Lan("@SDK12")
    CCUserDefault:sharedUserDefault():setStringForKey("ecchigamer.token", EcchiGamerSDK.getToken())
    libPlatformManager:getPlatform():setIsGuest(0)
    
    local serverId = GamePrecedure:getInstance():getServerID()
    
    local oldId = GamePrecedure:getInstance():getUin()
    GamePrecedure:getInstance():setUin(NewID)
    
    TapDBManager.setUser(GamePrecedure:getInstance():getUin())
    TapDBManager.setName(tostring(UserInfo.roleInfo.name))
    TapDBManager.setServer(GamePrecedure:getInstance():getServerNameById(serverId))
    TapDBManager.setLevel(UserInfo.roleInfo.level)


    --if (Golb_Platform_Info.is_h365) then
    --    libPlatformManager:getPlatform():sendMessageG2P('G2P_REPORT_HANDLER',"2")
    --else
        local data ={}
        data['eventId'] = 2
        data['userId'] = GamePrecedure:getInstance():getUin()
        libPlatformManager:getPlatform():sendMessageG2P('G2P_REPORT_HANDLER',json.encode(data))
    --end

    CCLuaLog("----------Bind End--------------")
end

function BuyManager.buyGoodsErolabs(eventName, handler)
    if eventName == "luaReceivePacket" then
        local msg = Shop_pb.ECoinResponse()
        local msgbuff = handler:getRecPacketBuffer()
        msg:ParseFromString(msgbuff)
        local ECoin = msg.coins
        libPlatformManager:getPlatform():setHoneyP(ECoin)
        CCLuaLog("getECoin : " .. ECoin)
        if BuyManager.openBuyGoodsCallback and BuyManager.callbackBuyInfo then
            BuyManager.openBuyGoodsCallback(BuyManager.callbackBuyInfo)
            BuyManager.openBuyGoodsCallback = nil
            BuyManager.callbackBuyInf = nil
        end
    end
end
BuyManager.HPgetECoin = PacketScriptHandler:new(HP_pb.SHOP_ECOIN_S, BuyManager.buyGoodsErolabs)

function BuyManager.buyGoodsEroR18(eventName, handler)
    if eventName == "luaReceivePacket" then
        local msg = Shop_pb.HoneyPResponse()
        local msgbuff = handler:getRecPacketBuffer()
        msg:ParseFromString(msgbuff)
        local HoneyP = msg.coins
        libPlatformManager:getPlatform():setHoneyP(HoneyP)
        CCLuaLog("getHoneyP : " .. HoneyP)
        if BuyManager.openBuyGoodsCallback and BuyManager.callbackBuyInfo then
            BuyManager.openBuyGoodsCallback(BuyManager.callbackBuyInfo)
            BuyManager.openBuyGoodsCallback = nil
            BuyManager.callbackBuyInf = nil
        end
    end
end
BuyManager.HPgetECoin = PacketScriptHandler:new(HP_pb.SHOP_HONEYP_S, BuyManager.buyGoodsEroR18)

return BuyManager