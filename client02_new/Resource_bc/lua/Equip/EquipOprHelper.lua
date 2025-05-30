local EquipOprHelper = { };
--------------------------------------------------------------------------------
------------local variable for system api--------------------------------------
local tostring = tostring;
local tonumber = tonumber;
local string = string;
local pairs = pairs;
--------------------------------------------------------------------------------
local EquipOpr_pb = require("EquipOpr_pb");

local Attribute_pb = require("Attribute_pb");
local HP_pb = require("HP_pb");

--------------------------------------------------------------------------------
-- 强化
function EquipOprHelper:enhanceEquip(equipId, _type)
    local msg = EquipOpr_pb.HPEquipEnhance();
    msg.equipId = equipId;
    msg.equipEnhanceType = _type
    common:sendPacket(HP_pb.EQUIP_ENHANCE_C, msg);
end	

-- 洗炼
function EquipOprHelper:baptizeEquip(equipId)
    local msg = EquipOpr_pb.HPEquipBaptize();
    msg.equipId = equipId;
    common:sendPacket(HP_pb.EQUIP_BAPTIZE_C, msg, true);
end	

-- 高级洗炼
function EquipOprHelper:SuperbaptizeEquip(equipId, lockAtrrList)
    local msg = EquipOpr_pb.HPEquipSuperBaptize();
    msg.equipId = equipId;
    for key, value in pairs(lockAtrrList) do
        local a = value
        msg.lockAttributeTypes:append(value);
    end
    common:sendPacket(HP_pb.EQUIP_SUPER_BAPTIZE_C, msg, false);
end	

-- 龄/叉/传杆称
function EquipOprHelper:dressAllEquip(equipIds, roleIds, _types)
    local msg = EquipOpr_pb.HPEquipOneKeyDress()
    for i = 1, #equipIds do
        local msgDress = msg.Dress:add() 
        msgDress.equipId = equipIds[i]
        msgDress.roleId = roleIds[i]
        msgDress.type = _types[i]
    end
    common:sendPacket(HP_pb.EQUIP_ONEKEY_DRESS_C, msg)
end	

-- /叉/传杆称
function EquipOprHelper:dressEquip(equipId, roleId, _type)
    local msg = EquipOpr_pb.HPEquipDress()
    msg.equipId = equipId
    msg.roleId = roleId
    msg.type = _type
    common:sendPacket(HP_pb.EQUIP_DRESS_C, msg)
end	

-- 吞噬
function EquipOprHelper:swallowEquip(equipId, swalledId)
    local UserItemManager = require("Item.UserItemManager")
    local msg = EquipOpr_pb.HPEquipSwallow();
    msg.equipId = equipId;
    for _, id in ipairs(swalledId) do
        if UserEquipManager:getUserEquipById(id).id ~= nil then
            msg.swallowedEquipId:append(id);
        else
            msg.swallowedItemId:append(UserItemManager:getUserItemById(id).itemId)
        end
    end
    common:sendPacket(HP_pb.EQUIP_SWALLOW_C, msg);
end	

-- 镶嵌
function EquipOprHelper:embedEquip(equipId, pos, stoneId)
    local msg = EquipOpr_pb.HPEquipStoneDress();
    msg.equipId = equipId;
    msg.punchPos = pos;
    msg.stoneId = stoneId;
    common:sendPacket(HP_pb.EQUIP_STONE_DRESS_C, msg);
end	

-- 膥┯杆称
function EquipOprHelper:extendEquip(equipId, extendedId)
    --local msg = EquipOpr_pb.HPEquipExtend();
    --msg.equipId = equipId;
    --msg.extendedEquipId = extendedId;
    --common:sendPacket(HP_pb.EQUIP_EXTEND_C, msg);
end

-- 打孔
function EquipOprHelper:punchEquip(equipId, pos, costType)
    local msg = EquipOpr_pb.HPEquipPunch();
    costType = costType or 1;
    msg.equipId = equipId;
    msg.punchPos = pos;
    msg.costType = costType;
    common:sendPacket(HP_pb.EQUIP_PUNCH_C, msg);
end	

-- 卸下宝石
function EquipOprHelper:unloadGem(equipId, pos)
    local msg = EquipOpr_pb.HPEquipStoneUndress();
    msg.equipId = equipId;
    msg.pos = pos;
    common:sendPacket(HP_pb.EQUIP_STONE_UNDRESS_C, msg);
end

-- 一键卸下宝石
function EquipOprHelper:unloadAllGem(equipId)
    self:unloadGem(equipId, -1);
    --[[
	local msg = EquipOpr_pb.HPEquipStoneUndress();
	msg.equipId = equipId;
	common:sendPacket(HP_pb.EQUIP_STONE_UNDRESS_C, msg);
	--]]
end

-- 熔炼
function EquipOprHelper:smeltEquip(equipIds, isBatch, qualitys)
    local msg = EquipOpr_pb.HPEquipSmelt();
    if equipIds ~= nil and #equipIds > 0 then
        for _, id in ipairs(equipIds) do
            msg.equipId:append(id);
        end
    end
    msg.isMass = isBatch or 0
    if isBatch and qualitys ~= nil then
        for _, quality in ipairs(qualitys) do
            msg.massQuality:append(quality);
        end
    end
    common:sendPacket(HP_pb.EQUIP_SMELT_C, msg)
end

-- 熔炼后，宝石自动回背包
function EquipOprHelper:equipSmelted(msgBuff)
    local msg = EquipOpr_pb.HPEquipSmeltRet();
    msg:ParseFromString(msgBuff);
    if msg.gemUndress == 1 then
        MainFrame:getInstance():getMsgNodeForLua():runAction(
        CCSequence:createWithTwoActions(
        CCDelayTime:create(1.5),
        CCCallFunc:create( function()
            MessageBoxPage:Msg_Box_Lan("@GemAutoUnloaded");
        end )
        )
        );
        -- common:popString(common:getLanguageString("@GemAutoUnloaded"), "COLOR_RED");
    end
end

-- 打造
function EquipOprHelper:buildEquip(equipId)
    local msg = EquipOpr_pb.HPEquipCreate();
    msg.version = 1;
    common:sendPacket(HP_pb.EQUIP_SMELT_CREATE_C, msg);
    --MessageBoxPage:Msg_Box(common:getLanguageString('@RewardItem2'))
end

-- 出售
function EquipOprHelper:sellEquip(equipId)
    local msg = EquipOpr_pb.HPEquipSell();
    msg.equipId = equipId;
    common:sendPacket(HP_pb.EQUIP_SELL_C, msg);
end	

-- 批量出售
function EquipOprHelper:sellEquipsWithQuality(quality)
    local msg = EquipOpr_pb.HPEquipSell();
    msg.quality = quality;
    common:sendPacket(HP_pb.EQUIP_SELL_C, msg);
end	

-- 获取熔炼信息
function EquipOprHelper:getSmeltEquipInfo()
    local msg = EquipOpr_pb.HPEquipSmeltInfo();
    msg.version = 1;
    common:sendPacket(HP_pb.EQUIP_SMELT_INFO_C, msg);
end

-- 刷新打造信息
function EquipOprHelper:refreshEquipBulding()
    local msg = EquipOpr_pb.HPEquipCreateAvailableRefresh();
    msg.version = 1;
    common:sendPacket(HP_pb.EQUIP_SMELT_REFRESH_C, msg, false);
end	

-- 扩展背包
function EquipOprHelper:expandPackage()
    local msg = EquipOpr_pb.HPEquipBagExtend();
    msg.version = 1;
    common:sendPacket(HP_pb.EQUIP_BAG_EXTEND_C, msg, false);
end	

-- 神器特殊打造
function EquipOprHelper:buildGodlyEquip(cfgId, count)
    --    local msg = EquipOpr_pb.HPEquipSpecialCreate();
    --    msg.cfgId = tonumber(cfgId);
    --    common:sendPacket(HP_pb.EQUIP_SPECIAL_CREATE_C, msg);


    count = count or 1
    local msg = EquipOpr_pb.HPEquipSpecialCreate();
    msg.cfgId = tonumber(cfgId);
    msg.num = tonumber(count) or 1
    common:sendPacket(HP_pb.EQUIP_SPECIAL_CREATE_C, msg);

end

-- 神器合成
function EquipOprHelper:compoundEquip(fromId, toId)
    local msg = EquipOpr_pb.HPEquipCompound();
    msg.fromEquipId = fromId;
    msg.toEquipId = toId;
    common:sendPacket(HP_pb.EQUIP_COMPOUND_C, msg);
end

-- 同步熔炼打造信息
function EquipOprHelper:syncSMeltInfo(pbMsg)
    local UserInfo = require("PlayerInfo.UserInfo");
    local smeltInfo = EquipOpr_pb.HPEquipSmeltInfoRet();
    smeltInfo:ParseFromString(pbMsg);
    UserInfo.smeltInfo = smeltInfo;
end

function EquipOprHelper:syncEquipInfoFromMsg(pbMsg)
    local UserInfo = require("PlayerInfo.UserInfo");
    local Equip_pb = require("Equip_pb");
    if not UserEquipManager:hasInited() then return; end

    local syncInfo = Equip_pb.HPEquipInfoSync();
    syncInfo:ParseFromString(pbMsg);
    if not UserInfo.roleInfo.level then
        UserInfo.syncRoleInfo();
    end
    self:syncEquipInfos(syncInfo.equipInfos);
end

function EquipOprHelper:syncEquipInfos(equipInfos)
    for _, equipInfo in ipairs(equipInfos) do
        UserEquipManager:syncOneEquipInfo(equipInfo);
    end
end

function EquipOprHelper:deleteEquip(equipId)
    UserEquipManager:deleteEquip(equipId);
end
--------------------------------------------------------------------------------
return EquipOprHelper;