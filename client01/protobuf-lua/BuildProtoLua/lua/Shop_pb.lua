-- Generated By protoc-gen-lua Do not Edit
local protobuf = require "protobuf"
local Reward_pb = require("Reward_pb")
local Const_pb = require("Const_pb")
module('Shop_pb')


SHOPITEMINFOINIT = protobuf.Descriptor();
local SHOPITEMINFOINIT_ID_FIELD = protobuf.FieldDescriptor();
local SHOPITEMINFOINIT_ITEMID_FIELD = protobuf.FieldDescriptor();
local SHOPITEMINFOINIT_ITEMTYPE_FIELD = protobuf.FieldDescriptor();
local SHOPITEMINFOINIT_COUNT_FIELD = protobuf.FieldDescriptor();
local SHOPITEMINFOINIT_DATATYPE_FIELD = protobuf.FieldDescriptor();
local SHOPITEMINFOINIT_PRICE_FIELD = protobuf.FieldDescriptor();
local SHOPITEMINFOINIT_DISCONT_FIELD = protobuf.FieldDescriptor();
local SHOPITEMINFOINIT_ISPURPLE_FIELD = protobuf.FieldDescriptor();
DISPLAYDATA = protobuf.Descriptor();
local DISPLAYDATA_DATATYPE_FIELD = protobuf.FieldDescriptor();
local DISPLAYDATA_AMOUNT_FIELD = protobuf.FieldDescriptor();
SHOPITEMINFOREQUEST = protobuf.Descriptor();
local SHOPITEMINFOREQUEST_TYPE_FIELD = protobuf.FieldDescriptor();
local SHOPITEMINFOREQUEST_SHOPTYPE_FIELD = protobuf.FieldDescriptor();
SHOPITEMINFORESPONSE = protobuf.Descriptor();
local SHOPITEMINFORESPONSE_SHOPTYPE_FIELD = protobuf.FieldDescriptor();
local SHOPITEMINFORESPONSE_DATA_FIELD = protobuf.FieldDescriptor();
local SHOPITEMINFORESPONSE_ITEMINFO_FIELD = protobuf.FieldDescriptor();
local SHOPITEMINFORESPONSE_REFRESHPRICE_FIELD = protobuf.FieldDescriptor();
BUYSHOPITEMSREQUEST = protobuf.Descriptor();
local BUYSHOPITEMSREQUEST_TYPE_FIELD = protobuf.FieldDescriptor();
local BUYSHOPITEMSREQUEST_SHOPTYPE_FIELD = protobuf.FieldDescriptor();
local BUYSHOPITEMSREQUEST_ID_FIELD = protobuf.FieldDescriptor();
local BUYSHOPITEMSREQUEST_AMOUNT_FIELD = protobuf.FieldDescriptor();
local BUYSHOPITEMSREQUEST_BUYTYPE_FIELD = protobuf.FieldDescriptor();
BUYSHOPITEMSRESPONSE = protobuf.Descriptor();
local BUYSHOPITEMSRESPONSE_SHOPTYPE_FIELD = protobuf.FieldDescriptor();
local BUYSHOPITEMSRESPONSE_ITEMINFO_FIELD = protobuf.FieldDescriptor();
local BUYSHOPITEMSRESPONSE_DATA_FIELD = protobuf.FieldDescriptor();
PUSHSHOPREDPOINT = protobuf.Descriptor();
local PUSHSHOPREDPOINT_SHOPTYPE_FIELD = protobuf.FieldDescriptor();
local PUSHSHOPREDPOINT_SHOWREDPOINT_FIELD = protobuf.FieldDescriptor();
HONEYPREQUEST = protobuf.Descriptor();
local HONEYPREQUEST_TOKEN_FIELD = protobuf.FieldDescriptor();
HONEYPRESPONSE = protobuf.Descriptor();
local HONEYPRESPONSE_COINS_FIELD = protobuf.FieldDescriptor();
HONEYPBUYREQUEST = protobuf.Descriptor();
local HONEYPBUYREQUEST_TOKEN_FIELD = protobuf.FieldDescriptor();
local HONEYPBUYREQUEST_PID_FIELD = protobuf.FieldDescriptor();
HONEYPBUYRESPONSE = protobuf.Descriptor();
local HONEYPBUYRESPONSE_RESULT_FIELD = protobuf.FieldDescriptor();
local HONEYPBUYRESPONSE_REFNO_FIELD = protobuf.FieldDescriptor();
JGGGETGOODS = protobuf.Descriptor();
local JGGGETGOODS_ORDERID_FIELD = protobuf.FieldDescriptor();
JGGORDERNOTICE = protobuf.Descriptor();
local JGGORDERNOTICE_ORDERID_FIELD = protobuf.FieldDescriptor();
local JGGORDERNOTICE_STATUS_FIELD = protobuf.FieldDescriptor();

SHOPITEMINFOINIT_ID_FIELD.name = "id"
SHOPITEMINFOINIT_ID_FIELD.full_name = ".ShopItemInfoInit.id"
SHOPITEMINFOINIT_ID_FIELD.number = 1
SHOPITEMINFOINIT_ID_FIELD.index = 0
SHOPITEMINFOINIT_ID_FIELD.label = 2
SHOPITEMINFOINIT_ID_FIELD.has_default_value = false
SHOPITEMINFOINIT_ID_FIELD.default_value = 0
SHOPITEMINFOINIT_ID_FIELD.type = 5
SHOPITEMINFOINIT_ID_FIELD.cpp_type = 1

SHOPITEMINFOINIT_ITEMID_FIELD.name = "itemId"
SHOPITEMINFOINIT_ITEMID_FIELD.full_name = ".ShopItemInfoInit.itemId"
SHOPITEMINFOINIT_ITEMID_FIELD.number = 2
SHOPITEMINFOINIT_ITEMID_FIELD.index = 1
SHOPITEMINFOINIT_ITEMID_FIELD.label = 2
SHOPITEMINFOINIT_ITEMID_FIELD.has_default_value = false
SHOPITEMINFOINIT_ITEMID_FIELD.default_value = 0
SHOPITEMINFOINIT_ITEMID_FIELD.type = 5
SHOPITEMINFOINIT_ITEMID_FIELD.cpp_type = 1

SHOPITEMINFOINIT_ITEMTYPE_FIELD.name = "itemType"
SHOPITEMINFOINIT_ITEMTYPE_FIELD.full_name = ".ShopItemInfoInit.itemType"
SHOPITEMINFOINIT_ITEMTYPE_FIELD.number = 3
SHOPITEMINFOINIT_ITEMTYPE_FIELD.index = 2
SHOPITEMINFOINIT_ITEMTYPE_FIELD.label = 2
SHOPITEMINFOINIT_ITEMTYPE_FIELD.has_default_value = false
SHOPITEMINFOINIT_ITEMTYPE_FIELD.default_value = 0
SHOPITEMINFOINIT_ITEMTYPE_FIELD.type = 5
SHOPITEMINFOINIT_ITEMTYPE_FIELD.cpp_type = 1

SHOPITEMINFOINIT_COUNT_FIELD.name = "count"
SHOPITEMINFOINIT_COUNT_FIELD.full_name = ".ShopItemInfoInit.count"
SHOPITEMINFOINIT_COUNT_FIELD.number = 4
SHOPITEMINFOINIT_COUNT_FIELD.index = 3
SHOPITEMINFOINIT_COUNT_FIELD.label = 2
SHOPITEMINFOINIT_COUNT_FIELD.has_default_value = false
SHOPITEMINFOINIT_COUNT_FIELD.default_value = 0
SHOPITEMINFOINIT_COUNT_FIELD.type = 5
SHOPITEMINFOINIT_COUNT_FIELD.cpp_type = 1

SHOPITEMINFOINIT_DATATYPE_FIELD.name = "dataType"
SHOPITEMINFOINIT_DATATYPE_FIELD.full_name = ".ShopItemInfoInit.dataType"
SHOPITEMINFOINIT_DATATYPE_FIELD.number = 5
SHOPITEMINFOINIT_DATATYPE_FIELD.index = 4
SHOPITEMINFOINIT_DATATYPE_FIELD.label = 2
SHOPITEMINFOINIT_DATATYPE_FIELD.has_default_value = false
SHOPITEMINFOINIT_DATATYPE_FIELD.default_value = nil
SHOPITEMINFOINIT_DATATYPE_FIELD.enum_type = CONST_PB_CHANGETYPE
SHOPITEMINFOINIT_DATATYPE_FIELD.type = 14
SHOPITEMINFOINIT_DATATYPE_FIELD.cpp_type = 8

SHOPITEMINFOINIT_PRICE_FIELD.name = "price"
SHOPITEMINFOINIT_PRICE_FIELD.full_name = ".ShopItemInfoInit.price"
SHOPITEMINFOINIT_PRICE_FIELD.number = 6
SHOPITEMINFOINIT_PRICE_FIELD.index = 5
SHOPITEMINFOINIT_PRICE_FIELD.label = 2
SHOPITEMINFOINIT_PRICE_FIELD.has_default_value = false
SHOPITEMINFOINIT_PRICE_FIELD.default_value = 0
SHOPITEMINFOINIT_PRICE_FIELD.type = 5
SHOPITEMINFOINIT_PRICE_FIELD.cpp_type = 1

SHOPITEMINFOINIT_DISCONT_FIELD.name = "discont"
SHOPITEMINFOINIT_DISCONT_FIELD.full_name = ".ShopItemInfoInit.discont"
SHOPITEMINFOINIT_DISCONT_FIELD.number = 7
SHOPITEMINFOINIT_DISCONT_FIELD.index = 6
SHOPITEMINFOINIT_DISCONT_FIELD.label = 2
SHOPITEMINFOINIT_DISCONT_FIELD.has_default_value = false
SHOPITEMINFOINIT_DISCONT_FIELD.default_value = 0
SHOPITEMINFOINIT_DISCONT_FIELD.type = 5
SHOPITEMINFOINIT_DISCONT_FIELD.cpp_type = 1

SHOPITEMINFOINIT_ISPURPLE_FIELD.name = "isPurple"
SHOPITEMINFOINIT_ISPURPLE_FIELD.full_name = ".ShopItemInfoInit.isPurple"
SHOPITEMINFOINIT_ISPURPLE_FIELD.number = 8
SHOPITEMINFOINIT_ISPURPLE_FIELD.index = 7
SHOPITEMINFOINIT_ISPURPLE_FIELD.label = 1
SHOPITEMINFOINIT_ISPURPLE_FIELD.has_default_value = false
SHOPITEMINFOINIT_ISPURPLE_FIELD.default_value = false
SHOPITEMINFOINIT_ISPURPLE_FIELD.type = 8
SHOPITEMINFOINIT_ISPURPLE_FIELD.cpp_type = 7

SHOPITEMINFOINIT.name = "ShopItemInfoInit"
SHOPITEMINFOINIT.full_name = ".ShopItemInfoInit"
SHOPITEMINFOINIT.nested_types = {}
SHOPITEMINFOINIT.enum_types = {}
SHOPITEMINFOINIT.fields = {SHOPITEMINFOINIT_ID_FIELD, SHOPITEMINFOINIT_ITEMID_FIELD, SHOPITEMINFOINIT_ITEMTYPE_FIELD, SHOPITEMINFOINIT_COUNT_FIELD, SHOPITEMINFOINIT_DATATYPE_FIELD, SHOPITEMINFOINIT_PRICE_FIELD, SHOPITEMINFOINIT_DISCONT_FIELD, SHOPITEMINFOINIT_ISPURPLE_FIELD}
SHOPITEMINFOINIT.is_extendable = false
SHOPITEMINFOINIT.extensions = {}
DISPLAYDATA_DATATYPE_FIELD.name = "dataType"
DISPLAYDATA_DATATYPE_FIELD.full_name = ".DisplayData.dataType"
DISPLAYDATA_DATATYPE_FIELD.number = 1
DISPLAYDATA_DATATYPE_FIELD.index = 0
DISPLAYDATA_DATATYPE_FIELD.label = 2
DISPLAYDATA_DATATYPE_FIELD.has_default_value = false
DISPLAYDATA_DATATYPE_FIELD.default_value = nil
DISPLAYDATA_DATATYPE_FIELD.enum_type = CONST_PB_DATATYPE
DISPLAYDATA_DATATYPE_FIELD.type = 14
DISPLAYDATA_DATATYPE_FIELD.cpp_type = 8

DISPLAYDATA_AMOUNT_FIELD.name = "amount"
DISPLAYDATA_AMOUNT_FIELD.full_name = ".DisplayData.amount"
DISPLAYDATA_AMOUNT_FIELD.number = 2
DISPLAYDATA_AMOUNT_FIELD.index = 1
DISPLAYDATA_AMOUNT_FIELD.label = 2
DISPLAYDATA_AMOUNT_FIELD.has_default_value = false
DISPLAYDATA_AMOUNT_FIELD.default_value = 0
DISPLAYDATA_AMOUNT_FIELD.type = 3
DISPLAYDATA_AMOUNT_FIELD.cpp_type = 2

DISPLAYDATA.name = "DisplayData"
DISPLAYDATA.full_name = ".DisplayData"
DISPLAYDATA.nested_types = {}
DISPLAYDATA.enum_types = {}
DISPLAYDATA.fields = {DISPLAYDATA_DATATYPE_FIELD, DISPLAYDATA_AMOUNT_FIELD}
DISPLAYDATA.is_extendable = false
DISPLAYDATA.extensions = {}
SHOPITEMINFOREQUEST_TYPE_FIELD.name = "type"
SHOPITEMINFOREQUEST_TYPE_FIELD.full_name = ".ShopItemInfoRequest.type"
SHOPITEMINFOREQUEST_TYPE_FIELD.number = 1
SHOPITEMINFOREQUEST_TYPE_FIELD.index = 0
SHOPITEMINFOREQUEST_TYPE_FIELD.label = 2
SHOPITEMINFOREQUEST_TYPE_FIELD.has_default_value = false
SHOPITEMINFOREQUEST_TYPE_FIELD.default_value = 0
SHOPITEMINFOREQUEST_TYPE_FIELD.type = 5
SHOPITEMINFOREQUEST_TYPE_FIELD.cpp_type = 1

SHOPITEMINFOREQUEST_SHOPTYPE_FIELD.name = "shopType"
SHOPITEMINFOREQUEST_SHOPTYPE_FIELD.full_name = ".ShopItemInfoRequest.shopType"
SHOPITEMINFOREQUEST_SHOPTYPE_FIELD.number = 2
SHOPITEMINFOREQUEST_SHOPTYPE_FIELD.index = 1
SHOPITEMINFOREQUEST_SHOPTYPE_FIELD.label = 2
SHOPITEMINFOREQUEST_SHOPTYPE_FIELD.has_default_value = false
SHOPITEMINFOREQUEST_SHOPTYPE_FIELD.default_value = nil
SHOPITEMINFOREQUEST_SHOPTYPE_FIELD.enum_type = CONST_PB_SHOPTYPE
SHOPITEMINFOREQUEST_SHOPTYPE_FIELD.type = 14
SHOPITEMINFOREQUEST_SHOPTYPE_FIELD.cpp_type = 8

SHOPITEMINFOREQUEST.name = "ShopItemInfoRequest"
SHOPITEMINFOREQUEST.full_name = ".ShopItemInfoRequest"
SHOPITEMINFOREQUEST.nested_types = {}
SHOPITEMINFOREQUEST.enum_types = {}
SHOPITEMINFOREQUEST.fields = {SHOPITEMINFOREQUEST_TYPE_FIELD, SHOPITEMINFOREQUEST_SHOPTYPE_FIELD}
SHOPITEMINFOREQUEST.is_extendable = false
SHOPITEMINFOREQUEST.extensions = {}
SHOPITEMINFORESPONSE_SHOPTYPE_FIELD.name = "shopType"
SHOPITEMINFORESPONSE_SHOPTYPE_FIELD.full_name = ".ShopItemInfoResponse.shopType"
SHOPITEMINFORESPONSE_SHOPTYPE_FIELD.number = 1
SHOPITEMINFORESPONSE_SHOPTYPE_FIELD.index = 0
SHOPITEMINFORESPONSE_SHOPTYPE_FIELD.label = 2
SHOPITEMINFORESPONSE_SHOPTYPE_FIELD.has_default_value = false
SHOPITEMINFORESPONSE_SHOPTYPE_FIELD.default_value = nil
SHOPITEMINFORESPONSE_SHOPTYPE_FIELD.enum_type = CONST_PB_SHOPTYPE
SHOPITEMINFORESPONSE_SHOPTYPE_FIELD.type = 14
SHOPITEMINFORESPONSE_SHOPTYPE_FIELD.cpp_type = 8

SHOPITEMINFORESPONSE_DATA_FIELD.name = "data"
SHOPITEMINFORESPONSE_DATA_FIELD.full_name = ".ShopItemInfoResponse.data"
SHOPITEMINFORESPONSE_DATA_FIELD.number = 2
SHOPITEMINFORESPONSE_DATA_FIELD.index = 1
SHOPITEMINFORESPONSE_DATA_FIELD.label = 3
SHOPITEMINFORESPONSE_DATA_FIELD.has_default_value = false
SHOPITEMINFORESPONSE_DATA_FIELD.default_value = {}
SHOPITEMINFORESPONSE_DATA_FIELD.message_type = DISPLAYDATA
SHOPITEMINFORESPONSE_DATA_FIELD.type = 11
SHOPITEMINFORESPONSE_DATA_FIELD.cpp_type = 10

SHOPITEMINFORESPONSE_ITEMINFO_FIELD.name = "itemInfo"
SHOPITEMINFORESPONSE_ITEMINFO_FIELD.full_name = ".ShopItemInfoResponse.itemInfo"
SHOPITEMINFORESPONSE_ITEMINFO_FIELD.number = 3
SHOPITEMINFORESPONSE_ITEMINFO_FIELD.index = 2
SHOPITEMINFORESPONSE_ITEMINFO_FIELD.label = 3
SHOPITEMINFORESPONSE_ITEMINFO_FIELD.has_default_value = false
SHOPITEMINFORESPONSE_ITEMINFO_FIELD.default_value = {}
SHOPITEMINFORESPONSE_ITEMINFO_FIELD.message_type = SHOPITEMINFOINIT
SHOPITEMINFORESPONSE_ITEMINFO_FIELD.type = 11
SHOPITEMINFORESPONSE_ITEMINFO_FIELD.cpp_type = 10

SHOPITEMINFORESPONSE_REFRESHPRICE_FIELD.name = "refreshPrice"
SHOPITEMINFORESPONSE_REFRESHPRICE_FIELD.full_name = ".ShopItemInfoResponse.refreshPrice"
SHOPITEMINFORESPONSE_REFRESHPRICE_FIELD.number = 4
SHOPITEMINFORESPONSE_REFRESHPRICE_FIELD.index = 3
SHOPITEMINFORESPONSE_REFRESHPRICE_FIELD.label = 1
SHOPITEMINFORESPONSE_REFRESHPRICE_FIELD.has_default_value = false
SHOPITEMINFORESPONSE_REFRESHPRICE_FIELD.default_value = 0
SHOPITEMINFORESPONSE_REFRESHPRICE_FIELD.type = 5
SHOPITEMINFORESPONSE_REFRESHPRICE_FIELD.cpp_type = 1

SHOPITEMINFORESPONSE.name = "ShopItemInfoResponse"
SHOPITEMINFORESPONSE.full_name = ".ShopItemInfoResponse"
SHOPITEMINFORESPONSE.nested_types = {}
SHOPITEMINFORESPONSE.enum_types = {}
SHOPITEMINFORESPONSE.fields = {SHOPITEMINFORESPONSE_SHOPTYPE_FIELD, SHOPITEMINFORESPONSE_DATA_FIELD, SHOPITEMINFORESPONSE_ITEMINFO_FIELD, SHOPITEMINFORESPONSE_REFRESHPRICE_FIELD}
SHOPITEMINFORESPONSE.is_extendable = false
SHOPITEMINFORESPONSE.extensions = {}
BUYSHOPITEMSREQUEST_TYPE_FIELD.name = "type"
BUYSHOPITEMSREQUEST_TYPE_FIELD.full_name = ".BuyShopItemsRequest.type"
BUYSHOPITEMSREQUEST_TYPE_FIELD.number = 1
BUYSHOPITEMSREQUEST_TYPE_FIELD.index = 0
BUYSHOPITEMSREQUEST_TYPE_FIELD.label = 2
BUYSHOPITEMSREQUEST_TYPE_FIELD.has_default_value = false
BUYSHOPITEMSREQUEST_TYPE_FIELD.default_value = 0
BUYSHOPITEMSREQUEST_TYPE_FIELD.type = 5
BUYSHOPITEMSREQUEST_TYPE_FIELD.cpp_type = 1

BUYSHOPITEMSREQUEST_SHOPTYPE_FIELD.name = "shopType"
BUYSHOPITEMSREQUEST_SHOPTYPE_FIELD.full_name = ".BuyShopItemsRequest.shopType"
BUYSHOPITEMSREQUEST_SHOPTYPE_FIELD.number = 2
BUYSHOPITEMSREQUEST_SHOPTYPE_FIELD.index = 1
BUYSHOPITEMSREQUEST_SHOPTYPE_FIELD.label = 2
BUYSHOPITEMSREQUEST_SHOPTYPE_FIELD.has_default_value = false
BUYSHOPITEMSREQUEST_SHOPTYPE_FIELD.default_value = nil
BUYSHOPITEMSREQUEST_SHOPTYPE_FIELD.enum_type = CONST_PB_SHOPTYPE
BUYSHOPITEMSREQUEST_SHOPTYPE_FIELD.type = 14
BUYSHOPITEMSREQUEST_SHOPTYPE_FIELD.cpp_type = 8

BUYSHOPITEMSREQUEST_ID_FIELD.name = "id"
BUYSHOPITEMSREQUEST_ID_FIELD.full_name = ".BuyShopItemsRequest.id"
BUYSHOPITEMSREQUEST_ID_FIELD.number = 3
BUYSHOPITEMSREQUEST_ID_FIELD.index = 2
BUYSHOPITEMSREQUEST_ID_FIELD.label = 1
BUYSHOPITEMSREQUEST_ID_FIELD.has_default_value = false
BUYSHOPITEMSREQUEST_ID_FIELD.default_value = 0
BUYSHOPITEMSREQUEST_ID_FIELD.type = 5
BUYSHOPITEMSREQUEST_ID_FIELD.cpp_type = 1

BUYSHOPITEMSREQUEST_AMOUNT_FIELD.name = "amount"
BUYSHOPITEMSREQUEST_AMOUNT_FIELD.full_name = ".BuyShopItemsRequest.amount"
BUYSHOPITEMSREQUEST_AMOUNT_FIELD.number = 4
BUYSHOPITEMSREQUEST_AMOUNT_FIELD.index = 3
BUYSHOPITEMSREQUEST_AMOUNT_FIELD.label = 1
BUYSHOPITEMSREQUEST_AMOUNT_FIELD.has_default_value = false
BUYSHOPITEMSREQUEST_AMOUNT_FIELD.default_value = 0
BUYSHOPITEMSREQUEST_AMOUNT_FIELD.type = 5
BUYSHOPITEMSREQUEST_AMOUNT_FIELD.cpp_type = 1

BUYSHOPITEMSREQUEST_BUYTYPE_FIELD.name = "buyType"
BUYSHOPITEMSREQUEST_BUYTYPE_FIELD.full_name = ".BuyShopItemsRequest.buyType"
BUYSHOPITEMSREQUEST_BUYTYPE_FIELD.number = 5
BUYSHOPITEMSREQUEST_BUYTYPE_FIELD.index = 4
BUYSHOPITEMSREQUEST_BUYTYPE_FIELD.label = 1
BUYSHOPITEMSREQUEST_BUYTYPE_FIELD.has_default_value = false
BUYSHOPITEMSREQUEST_BUYTYPE_FIELD.default_value = 0
BUYSHOPITEMSREQUEST_BUYTYPE_FIELD.type = 5
BUYSHOPITEMSREQUEST_BUYTYPE_FIELD.cpp_type = 1

BUYSHOPITEMSREQUEST.name = "BuyShopItemsRequest"
BUYSHOPITEMSREQUEST.full_name = ".BuyShopItemsRequest"
BUYSHOPITEMSREQUEST.nested_types = {}
BUYSHOPITEMSREQUEST.enum_types = {}
BUYSHOPITEMSREQUEST.fields = {BUYSHOPITEMSREQUEST_TYPE_FIELD, BUYSHOPITEMSREQUEST_SHOPTYPE_FIELD, BUYSHOPITEMSREQUEST_ID_FIELD, BUYSHOPITEMSREQUEST_AMOUNT_FIELD, BUYSHOPITEMSREQUEST_BUYTYPE_FIELD}
BUYSHOPITEMSREQUEST.is_extendable = false
BUYSHOPITEMSREQUEST.extensions = {}
BUYSHOPITEMSRESPONSE_SHOPTYPE_FIELD.name = "shopType"
BUYSHOPITEMSRESPONSE_SHOPTYPE_FIELD.full_name = ".BuyShopItemsResponse.shopType"
BUYSHOPITEMSRESPONSE_SHOPTYPE_FIELD.number = 1
BUYSHOPITEMSRESPONSE_SHOPTYPE_FIELD.index = 0
BUYSHOPITEMSRESPONSE_SHOPTYPE_FIELD.label = 2
BUYSHOPITEMSRESPONSE_SHOPTYPE_FIELD.has_default_value = false
BUYSHOPITEMSRESPONSE_SHOPTYPE_FIELD.default_value = nil
BUYSHOPITEMSRESPONSE_SHOPTYPE_FIELD.enum_type = CONST_PB_SHOPTYPE
BUYSHOPITEMSRESPONSE_SHOPTYPE_FIELD.type = 14
BUYSHOPITEMSRESPONSE_SHOPTYPE_FIELD.cpp_type = 8

BUYSHOPITEMSRESPONSE_ITEMINFO_FIELD.name = "itemInfo"
BUYSHOPITEMSRESPONSE_ITEMINFO_FIELD.full_name = ".BuyShopItemsResponse.itemInfo"
BUYSHOPITEMSRESPONSE_ITEMINFO_FIELD.number = 2
BUYSHOPITEMSRESPONSE_ITEMINFO_FIELD.index = 1
BUYSHOPITEMSRESPONSE_ITEMINFO_FIELD.label = 3
BUYSHOPITEMSRESPONSE_ITEMINFO_FIELD.has_default_value = false
BUYSHOPITEMSRESPONSE_ITEMINFO_FIELD.default_value = {}
BUYSHOPITEMSRESPONSE_ITEMINFO_FIELD.message_type = SHOPITEMINFOINIT
BUYSHOPITEMSRESPONSE_ITEMINFO_FIELD.type = 11
BUYSHOPITEMSRESPONSE_ITEMINFO_FIELD.cpp_type = 10

BUYSHOPITEMSRESPONSE_DATA_FIELD.name = "data"
BUYSHOPITEMSRESPONSE_DATA_FIELD.full_name = ".BuyShopItemsResponse.data"
BUYSHOPITEMSRESPONSE_DATA_FIELD.number = 3
BUYSHOPITEMSRESPONSE_DATA_FIELD.index = 2
BUYSHOPITEMSRESPONSE_DATA_FIELD.label = 3
BUYSHOPITEMSRESPONSE_DATA_FIELD.has_default_value = false
BUYSHOPITEMSRESPONSE_DATA_FIELD.default_value = {}
BUYSHOPITEMSRESPONSE_DATA_FIELD.message_type = DISPLAYDATA
BUYSHOPITEMSRESPONSE_DATA_FIELD.type = 11
BUYSHOPITEMSRESPONSE_DATA_FIELD.cpp_type = 10

BUYSHOPITEMSRESPONSE.name = "BuyShopItemsResponse"
BUYSHOPITEMSRESPONSE.full_name = ".BuyShopItemsResponse"
BUYSHOPITEMSRESPONSE.nested_types = {}
BUYSHOPITEMSRESPONSE.enum_types = {}
BUYSHOPITEMSRESPONSE.fields = {BUYSHOPITEMSRESPONSE_SHOPTYPE_FIELD, BUYSHOPITEMSRESPONSE_ITEMINFO_FIELD, BUYSHOPITEMSRESPONSE_DATA_FIELD}
BUYSHOPITEMSRESPONSE.is_extendable = false
BUYSHOPITEMSRESPONSE.extensions = {}
PUSHSHOPREDPOINT_SHOPTYPE_FIELD.name = "shopType"
PUSHSHOPREDPOINT_SHOPTYPE_FIELD.full_name = ".PushShopRedPoint.shopType"
PUSHSHOPREDPOINT_SHOPTYPE_FIELD.number = 1
PUSHSHOPREDPOINT_SHOPTYPE_FIELD.index = 0
PUSHSHOPREDPOINT_SHOPTYPE_FIELD.label = 2
PUSHSHOPREDPOINT_SHOPTYPE_FIELD.has_default_value = false
PUSHSHOPREDPOINT_SHOPTYPE_FIELD.default_value = nil
PUSHSHOPREDPOINT_SHOPTYPE_FIELD.enum_type = CONST_PB_SHOPTYPE
PUSHSHOPREDPOINT_SHOPTYPE_FIELD.type = 14
PUSHSHOPREDPOINT_SHOPTYPE_FIELD.cpp_type = 8

PUSHSHOPREDPOINT_SHOWREDPOINT_FIELD.name = "showRedPoint"
PUSHSHOPREDPOINT_SHOWREDPOINT_FIELD.full_name = ".PushShopRedPoint.showRedPoint"
PUSHSHOPREDPOINT_SHOWREDPOINT_FIELD.number = 2
PUSHSHOPREDPOINT_SHOWREDPOINT_FIELD.index = 1
PUSHSHOPREDPOINT_SHOWREDPOINT_FIELD.label = 2
PUSHSHOPREDPOINT_SHOWREDPOINT_FIELD.has_default_value = false
PUSHSHOPREDPOINT_SHOWREDPOINT_FIELD.default_value = false
PUSHSHOPREDPOINT_SHOWREDPOINT_FIELD.type = 8
PUSHSHOPREDPOINT_SHOWREDPOINT_FIELD.cpp_type = 7

PUSHSHOPREDPOINT.name = "PushShopRedPoint"
PUSHSHOPREDPOINT.full_name = ".PushShopRedPoint"
PUSHSHOPREDPOINT.nested_types = {}
PUSHSHOPREDPOINT.enum_types = {}
PUSHSHOPREDPOINT.fields = {PUSHSHOPREDPOINT_SHOPTYPE_FIELD, PUSHSHOPREDPOINT_SHOWREDPOINT_FIELD}
PUSHSHOPREDPOINT.is_extendable = false
PUSHSHOPREDPOINT.extensions = {}
HONEYPREQUEST_TOKEN_FIELD.name = "token"
HONEYPREQUEST_TOKEN_FIELD.full_name = ".HoneyPRequest.token"
HONEYPREQUEST_TOKEN_FIELD.number = 1
HONEYPREQUEST_TOKEN_FIELD.index = 0
HONEYPREQUEST_TOKEN_FIELD.label = 2
HONEYPREQUEST_TOKEN_FIELD.has_default_value = false
HONEYPREQUEST_TOKEN_FIELD.default_value = ""
HONEYPREQUEST_TOKEN_FIELD.type = 9
HONEYPREQUEST_TOKEN_FIELD.cpp_type = 9

HONEYPREQUEST.name = "HoneyPRequest"
HONEYPREQUEST.full_name = ".HoneyPRequest"
HONEYPREQUEST.nested_types = {}
HONEYPREQUEST.enum_types = {}
HONEYPREQUEST.fields = {HONEYPREQUEST_TOKEN_FIELD}
HONEYPREQUEST.is_extendable = false
HONEYPREQUEST.extensions = {}
HONEYPRESPONSE_COINS_FIELD.name = "coins"
HONEYPRESPONSE_COINS_FIELD.full_name = ".HoneyPResponse.coins"
HONEYPRESPONSE_COINS_FIELD.number = 1
HONEYPRESPONSE_COINS_FIELD.index = 0
HONEYPRESPONSE_COINS_FIELD.label = 2
HONEYPRESPONSE_COINS_FIELD.has_default_value = false
HONEYPRESPONSE_COINS_FIELD.default_value = 0
HONEYPRESPONSE_COINS_FIELD.type = 5
HONEYPRESPONSE_COINS_FIELD.cpp_type = 1

HONEYPRESPONSE.name = "HoneyPResponse"
HONEYPRESPONSE.full_name = ".HoneyPResponse"
HONEYPRESPONSE.nested_types = {}
HONEYPRESPONSE.enum_types = {}
HONEYPRESPONSE.fields = {HONEYPRESPONSE_COINS_FIELD}
HONEYPRESPONSE.is_extendable = false
HONEYPRESPONSE.extensions = {}
HONEYPBUYREQUEST_TOKEN_FIELD.name = "token"
HONEYPBUYREQUEST_TOKEN_FIELD.full_name = ".HoneyPBuyRequest.token"
HONEYPBUYREQUEST_TOKEN_FIELD.number = 1
HONEYPBUYREQUEST_TOKEN_FIELD.index = 0
HONEYPBUYREQUEST_TOKEN_FIELD.label = 2
HONEYPBUYREQUEST_TOKEN_FIELD.has_default_value = false
HONEYPBUYREQUEST_TOKEN_FIELD.default_value = ""
HONEYPBUYREQUEST_TOKEN_FIELD.type = 9
HONEYPBUYREQUEST_TOKEN_FIELD.cpp_type = 9

HONEYPBUYREQUEST_PID_FIELD.name = "pid"
HONEYPBUYREQUEST_PID_FIELD.full_name = ".HoneyPBuyRequest.pid"
HONEYPBUYREQUEST_PID_FIELD.number = 2
HONEYPBUYREQUEST_PID_FIELD.index = 1
HONEYPBUYREQUEST_PID_FIELD.label = 2
HONEYPBUYREQUEST_PID_FIELD.has_default_value = false
HONEYPBUYREQUEST_PID_FIELD.default_value = 0
HONEYPBUYREQUEST_PID_FIELD.type = 5
HONEYPBUYREQUEST_PID_FIELD.cpp_type = 1

HONEYPBUYREQUEST.name = "HoneyPBuyRequest"
HONEYPBUYREQUEST.full_name = ".HoneyPBuyRequest"
HONEYPBUYREQUEST.nested_types = {}
HONEYPBUYREQUEST.enum_types = {}
HONEYPBUYREQUEST.fields = {HONEYPBUYREQUEST_TOKEN_FIELD, HONEYPBUYREQUEST_PID_FIELD}
HONEYPBUYREQUEST.is_extendable = false
HONEYPBUYREQUEST.extensions = {}
HONEYPBUYRESPONSE_RESULT_FIELD.name = "result"
HONEYPBUYRESPONSE_RESULT_FIELD.full_name = ".HoneyPBuyResponse.result"
HONEYPBUYRESPONSE_RESULT_FIELD.number = 1
HONEYPBUYRESPONSE_RESULT_FIELD.index = 0
HONEYPBUYRESPONSE_RESULT_FIELD.label = 2
HONEYPBUYRESPONSE_RESULT_FIELD.has_default_value = false
HONEYPBUYRESPONSE_RESULT_FIELD.default_value = 0
HONEYPBUYRESPONSE_RESULT_FIELD.type = 5
HONEYPBUYRESPONSE_RESULT_FIELD.cpp_type = 1

HONEYPBUYRESPONSE_REFNO_FIELD.name = "refno"
HONEYPBUYRESPONSE_REFNO_FIELD.full_name = ".HoneyPBuyResponse.refno"
HONEYPBUYRESPONSE_REFNO_FIELD.number = 2
HONEYPBUYRESPONSE_REFNO_FIELD.index = 1
HONEYPBUYRESPONSE_REFNO_FIELD.label = 2
HONEYPBUYRESPONSE_REFNO_FIELD.has_default_value = false
HONEYPBUYRESPONSE_REFNO_FIELD.default_value = ""
HONEYPBUYRESPONSE_REFNO_FIELD.type = 9
HONEYPBUYRESPONSE_REFNO_FIELD.cpp_type = 9

HONEYPBUYRESPONSE.name = "HoneyPBuyResponse"
HONEYPBUYRESPONSE.full_name = ".HoneyPBuyResponse"
HONEYPBUYRESPONSE.nested_types = {}
HONEYPBUYRESPONSE.enum_types = {}
HONEYPBUYRESPONSE.fields = {HONEYPBUYRESPONSE_RESULT_FIELD, HONEYPBUYRESPONSE_REFNO_FIELD}
HONEYPBUYRESPONSE.is_extendable = false
HONEYPBUYRESPONSE.extensions = {}
JGGGETGOODS_ORDERID_FIELD.name = "orderid"
JGGGETGOODS_ORDERID_FIELD.full_name = ".JggGetGoods.orderid"
JGGGETGOODS_ORDERID_FIELD.number = 1
JGGGETGOODS_ORDERID_FIELD.index = 0
JGGGETGOODS_ORDERID_FIELD.label = 2
JGGGETGOODS_ORDERID_FIELD.has_default_value = false
JGGGETGOODS_ORDERID_FIELD.default_value = ""
JGGGETGOODS_ORDERID_FIELD.type = 9
JGGGETGOODS_ORDERID_FIELD.cpp_type = 9

JGGGETGOODS.name = "JggGetGoods"
JGGGETGOODS.full_name = ".JggGetGoods"
JGGGETGOODS.nested_types = {}
JGGGETGOODS.enum_types = {}
JGGGETGOODS.fields = {JGGGETGOODS_ORDERID_FIELD}
JGGGETGOODS.is_extendable = false
JGGGETGOODS.extensions = {}
JGGORDERNOTICE_ORDERID_FIELD.name = "orderid"
JGGORDERNOTICE_ORDERID_FIELD.full_name = ".JggOrderNotice.orderid"
JGGORDERNOTICE_ORDERID_FIELD.number = 1
JGGORDERNOTICE_ORDERID_FIELD.index = 0
JGGORDERNOTICE_ORDERID_FIELD.label = 2
JGGORDERNOTICE_ORDERID_FIELD.has_default_value = false
JGGORDERNOTICE_ORDERID_FIELD.default_value = ""
JGGORDERNOTICE_ORDERID_FIELD.type = 9
JGGORDERNOTICE_ORDERID_FIELD.cpp_type = 9

JGGORDERNOTICE_STATUS_FIELD.name = "status"
JGGORDERNOTICE_STATUS_FIELD.full_name = ".JggOrderNotice.status"
JGGORDERNOTICE_STATUS_FIELD.number = 2
JGGORDERNOTICE_STATUS_FIELD.index = 1
JGGORDERNOTICE_STATUS_FIELD.label = 2
JGGORDERNOTICE_STATUS_FIELD.has_default_value = false
JGGORDERNOTICE_STATUS_FIELD.default_value = 0
JGGORDERNOTICE_STATUS_FIELD.type = 5
JGGORDERNOTICE_STATUS_FIELD.cpp_type = 1

JGGORDERNOTICE.name = "JggOrderNotice"
JGGORDERNOTICE.full_name = ".JggOrderNotice"
JGGORDERNOTICE.nested_types = {}
JGGORDERNOTICE.enum_types = {}
JGGORDERNOTICE.fields = {JGGORDERNOTICE_ORDERID_FIELD, JGGORDERNOTICE_STATUS_FIELD}
JGGORDERNOTICE.is_extendable = false
JGGORDERNOTICE.extensions = {}

BuyShopItemsRequest = protobuf.Message(BUYSHOPITEMSREQUEST)
BuyShopItemsResponse = protobuf.Message(BUYSHOPITEMSRESPONSE)
DisplayData = protobuf.Message(DISPLAYDATA)
HoneyPBuyRequest = protobuf.Message(HONEYPBUYREQUEST)
HoneyPBuyResponse = protobuf.Message(HONEYPBUYRESPONSE)
HoneyPRequest = protobuf.Message(HONEYPREQUEST)
HoneyPResponse = protobuf.Message(HONEYPRESPONSE)
JggGetGoods = protobuf.Message(JGGGETGOODS)
JggOrderNotice = protobuf.Message(JGGORDERNOTICE)
PushShopRedPoint = protobuf.Message(PUSHSHOPREDPOINT)
ShopItemInfoInit = protobuf.Message(SHOPITEMINFOINIT)
ShopItemInfoRequest = protobuf.Message(SHOPITEMINFOREQUEST)
ShopItemInfoResponse = protobuf.Message(SHOPITEMINFORESPONSE)

