-- Generated By protoc-gen-lua Do not Edit
local protobuf = require "protobuf"
local Attribute_pb = require("Attribute_pb")
module('Equip_pb')


EQUIPATTR = protobuf.Descriptor();
local EQUIPATTR_ATTRGRADE_FIELD = protobuf.FieldDescriptor();
local EQUIPATTR_ATTRDATA_FIELD = protobuf.FieldDescriptor();
GEMINFO = protobuf.Descriptor();
local GEMINFO_POS_FIELD = protobuf.FieldDescriptor();
local GEMINFO_GEMITEMID_FIELD = protobuf.FieldDescriptor();
EQUIPINFO = protobuf.Descriptor();
local EQUIPINFO_ID_FIELD = protobuf.FieldDescriptor();
local EQUIPINFO_EQUIPID_FIELD = protobuf.FieldDescriptor();
local EQUIPINFO_STRENGTH_FIELD = protobuf.FieldDescriptor();
local EQUIPINFO_STARLEVEL_FIELD = protobuf.FieldDescriptor();
local EQUIPINFO_STAREXP_FIELD = protobuf.FieldDescriptor();
local EQUIPINFO_GODLYATTRID_FIELD = protobuf.FieldDescriptor();
local EQUIPINFO_GEMINFOS_FIELD = protobuf.FieldDescriptor();
local EQUIPINFO_ATTRINFOS_FIELD = protobuf.FieldDescriptor();
local EQUIPINFO_STATUS_FIELD = protobuf.FieldDescriptor();
local EQUIPINFO_SCORE_FIELD = protobuf.FieldDescriptor();
local EQUIPINFO_LOCK_FIELD = protobuf.FieldDescriptor();
local EQUIPINFO_STARLEVEL2_FIELD = protobuf.FieldDescriptor();
local EQUIPINFO_STAREXP2_FIELD = protobuf.FieldDescriptor();
local EQUIPINFO_GODLYATTRID2_FIELD = protobuf.FieldDescriptor();
local EQUIPINFO_RELATESUITID_FIELD = protobuf.FieldDescriptor();
HPEQUIPINFOSYNC = protobuf.Descriptor();
local HPEQUIPINFOSYNC_EQUIPINFOS_FIELD = protobuf.FieldDescriptor();
local HPEQUIPINFOSYNC_ISREWARD_FIELD = protobuf.FieldDescriptor();

EQUIPATTR_ATTRGRADE_FIELD.name = "attrGrade"
EQUIPATTR_ATTRGRADE_FIELD.full_name = ".EquipAttr.attrGrade"
EQUIPATTR_ATTRGRADE_FIELD.number = 1
EQUIPATTR_ATTRGRADE_FIELD.index = 0
EQUIPATTR_ATTRGRADE_FIELD.label = 2
EQUIPATTR_ATTRGRADE_FIELD.has_default_value = false
EQUIPATTR_ATTRGRADE_FIELD.default_value = 0
EQUIPATTR_ATTRGRADE_FIELD.type = 5
EQUIPATTR_ATTRGRADE_FIELD.cpp_type = 1

EQUIPATTR_ATTRDATA_FIELD.name = "attrData"
EQUIPATTR_ATTRDATA_FIELD.full_name = ".EquipAttr.attrData"
EQUIPATTR_ATTRDATA_FIELD.number = 2
EQUIPATTR_ATTRDATA_FIELD.index = 1
EQUIPATTR_ATTRDATA_FIELD.label = 2
EQUIPATTR_ATTRDATA_FIELD.has_default_value = false
EQUIPATTR_ATTRDATA_FIELD.default_value = nil
EQUIPATTR_ATTRDATA_FIELD.message_type = ATTRIBUTE_PB_ATTR
EQUIPATTR_ATTRDATA_FIELD.type = 11
EQUIPATTR_ATTRDATA_FIELD.cpp_type = 10

EQUIPATTR.name = "EquipAttr"
EQUIPATTR.full_name = ".EquipAttr"
EQUIPATTR.nested_types = {}
EQUIPATTR.enum_types = {}
EQUIPATTR.fields = {EQUIPATTR_ATTRGRADE_FIELD, EQUIPATTR_ATTRDATA_FIELD}
EQUIPATTR.is_extendable = false
EQUIPATTR.extensions = {}
GEMINFO_POS_FIELD.name = "pos"
GEMINFO_POS_FIELD.full_name = ".GemInfo.pos"
GEMINFO_POS_FIELD.number = 1
GEMINFO_POS_FIELD.index = 0
GEMINFO_POS_FIELD.label = 2
GEMINFO_POS_FIELD.has_default_value = false
GEMINFO_POS_FIELD.default_value = 0
GEMINFO_POS_FIELD.type = 5
GEMINFO_POS_FIELD.cpp_type = 1

GEMINFO_GEMITEMID_FIELD.name = "gemItemId"
GEMINFO_GEMITEMID_FIELD.full_name = ".GemInfo.gemItemId"
GEMINFO_GEMITEMID_FIELD.number = 2
GEMINFO_GEMITEMID_FIELD.index = 1
GEMINFO_GEMITEMID_FIELD.label = 1
GEMINFO_GEMITEMID_FIELD.has_default_value = false
GEMINFO_GEMITEMID_FIELD.default_value = 0
GEMINFO_GEMITEMID_FIELD.type = 5
GEMINFO_GEMITEMID_FIELD.cpp_type = 1

GEMINFO.name = "GemInfo"
GEMINFO.full_name = ".GemInfo"
GEMINFO.nested_types = {}
GEMINFO.enum_types = {}
GEMINFO.fields = {GEMINFO_POS_FIELD, GEMINFO_GEMITEMID_FIELD}
GEMINFO.is_extendable = false
GEMINFO.extensions = {}
EQUIPINFO_ID_FIELD.name = "id"
EQUIPINFO_ID_FIELD.full_name = ".EquipInfo.id"
EQUIPINFO_ID_FIELD.number = 1
EQUIPINFO_ID_FIELD.index = 0
EQUIPINFO_ID_FIELD.label = 2
EQUIPINFO_ID_FIELD.has_default_value = false
EQUIPINFO_ID_FIELD.default_value = 0
EQUIPINFO_ID_FIELD.type = 3
EQUIPINFO_ID_FIELD.cpp_type = 2

EQUIPINFO_EQUIPID_FIELD.name = "equipId"
EQUIPINFO_EQUIPID_FIELD.full_name = ".EquipInfo.equipId"
EQUIPINFO_EQUIPID_FIELD.number = 2
EQUIPINFO_EQUIPID_FIELD.index = 1
EQUIPINFO_EQUIPID_FIELD.label = 2
EQUIPINFO_EQUIPID_FIELD.has_default_value = false
EQUIPINFO_EQUIPID_FIELD.default_value = 0
EQUIPINFO_EQUIPID_FIELD.type = 5
EQUIPINFO_EQUIPID_FIELD.cpp_type = 1

EQUIPINFO_STRENGTH_FIELD.name = "strength"
EQUIPINFO_STRENGTH_FIELD.full_name = ".EquipInfo.strength"
EQUIPINFO_STRENGTH_FIELD.number = 3
EQUIPINFO_STRENGTH_FIELD.index = 2
EQUIPINFO_STRENGTH_FIELD.label = 2
EQUIPINFO_STRENGTH_FIELD.has_default_value = false
EQUIPINFO_STRENGTH_FIELD.default_value = 0
EQUIPINFO_STRENGTH_FIELD.type = 5
EQUIPINFO_STRENGTH_FIELD.cpp_type = 1

EQUIPINFO_STARLEVEL_FIELD.name = "starLevel"
EQUIPINFO_STARLEVEL_FIELD.full_name = ".EquipInfo.starLevel"
EQUIPINFO_STARLEVEL_FIELD.number = 4
EQUIPINFO_STARLEVEL_FIELD.index = 3
EQUIPINFO_STARLEVEL_FIELD.label = 2
EQUIPINFO_STARLEVEL_FIELD.has_default_value = false
EQUIPINFO_STARLEVEL_FIELD.default_value = 0
EQUIPINFO_STARLEVEL_FIELD.type = 5
EQUIPINFO_STARLEVEL_FIELD.cpp_type = 1

EQUIPINFO_STAREXP_FIELD.name = "starExp"
EQUIPINFO_STAREXP_FIELD.full_name = ".EquipInfo.starExp"
EQUIPINFO_STAREXP_FIELD.number = 5
EQUIPINFO_STAREXP_FIELD.index = 4
EQUIPINFO_STAREXP_FIELD.label = 2
EQUIPINFO_STAREXP_FIELD.has_default_value = false
EQUIPINFO_STAREXP_FIELD.default_value = 0
EQUIPINFO_STAREXP_FIELD.type = 5
EQUIPINFO_STAREXP_FIELD.cpp_type = 1

EQUIPINFO_GODLYATTRID_FIELD.name = "godlyAttrId"
EQUIPINFO_GODLYATTRID_FIELD.full_name = ".EquipInfo.godlyAttrId"
EQUIPINFO_GODLYATTRID_FIELD.number = 6
EQUIPINFO_GODLYATTRID_FIELD.index = 5
EQUIPINFO_GODLYATTRID_FIELD.label = 2
EQUIPINFO_GODLYATTRID_FIELD.has_default_value = false
EQUIPINFO_GODLYATTRID_FIELD.default_value = 0
EQUIPINFO_GODLYATTRID_FIELD.type = 5
EQUIPINFO_GODLYATTRID_FIELD.cpp_type = 1

EQUIPINFO_GEMINFOS_FIELD.name = "gemInfos"
EQUIPINFO_GEMINFOS_FIELD.full_name = ".EquipInfo.gemInfos"
EQUIPINFO_GEMINFOS_FIELD.number = 7
EQUIPINFO_GEMINFOS_FIELD.index = 6
EQUIPINFO_GEMINFOS_FIELD.label = 3
EQUIPINFO_GEMINFOS_FIELD.has_default_value = false
EQUIPINFO_GEMINFOS_FIELD.default_value = {}
EQUIPINFO_GEMINFOS_FIELD.message_type = GEMINFO
EQUIPINFO_GEMINFOS_FIELD.type = 11
EQUIPINFO_GEMINFOS_FIELD.cpp_type = 10

EQUIPINFO_ATTRINFOS_FIELD.name = "attrInfos"
EQUIPINFO_ATTRINFOS_FIELD.full_name = ".EquipInfo.attrInfos"
EQUIPINFO_ATTRINFOS_FIELD.number = 8
EQUIPINFO_ATTRINFOS_FIELD.index = 7
EQUIPINFO_ATTRINFOS_FIELD.label = 3
EQUIPINFO_ATTRINFOS_FIELD.has_default_value = false
EQUIPINFO_ATTRINFOS_FIELD.default_value = {}
EQUIPINFO_ATTRINFOS_FIELD.message_type = EQUIPATTR
EQUIPINFO_ATTRINFOS_FIELD.type = 11
EQUIPINFO_ATTRINFOS_FIELD.cpp_type = 10

EQUIPINFO_STATUS_FIELD.name = "status"
EQUIPINFO_STATUS_FIELD.full_name = ".EquipInfo.status"
EQUIPINFO_STATUS_FIELD.number = 9
EQUIPINFO_STATUS_FIELD.index = 8
EQUIPINFO_STATUS_FIELD.label = 2
EQUIPINFO_STATUS_FIELD.has_default_value = false
EQUIPINFO_STATUS_FIELD.default_value = 0
EQUIPINFO_STATUS_FIELD.type = 5
EQUIPINFO_STATUS_FIELD.cpp_type = 1

EQUIPINFO_SCORE_FIELD.name = "score"
EQUIPINFO_SCORE_FIELD.full_name = ".EquipInfo.score"
EQUIPINFO_SCORE_FIELD.number = 10
EQUIPINFO_SCORE_FIELD.index = 9
EQUIPINFO_SCORE_FIELD.label = 2
EQUIPINFO_SCORE_FIELD.has_default_value = false
EQUIPINFO_SCORE_FIELD.default_value = 0
EQUIPINFO_SCORE_FIELD.type = 5
EQUIPINFO_SCORE_FIELD.cpp_type = 1

EQUIPINFO_LOCK_FIELD.name = "lock"
EQUIPINFO_LOCK_FIELD.full_name = ".EquipInfo.lock"
EQUIPINFO_LOCK_FIELD.number = 11
EQUIPINFO_LOCK_FIELD.index = 10
EQUIPINFO_LOCK_FIELD.label = 1
EQUIPINFO_LOCK_FIELD.has_default_value = false
EQUIPINFO_LOCK_FIELD.default_value = false
EQUIPINFO_LOCK_FIELD.type = 8
EQUIPINFO_LOCK_FIELD.cpp_type = 7

EQUIPINFO_STARLEVEL2_FIELD.name = "starLevel2"
EQUIPINFO_STARLEVEL2_FIELD.full_name = ".EquipInfo.starLevel2"
EQUIPINFO_STARLEVEL2_FIELD.number = 12
EQUIPINFO_STARLEVEL2_FIELD.index = 11
EQUIPINFO_STARLEVEL2_FIELD.label = 1
EQUIPINFO_STARLEVEL2_FIELD.has_default_value = false
EQUIPINFO_STARLEVEL2_FIELD.default_value = 0
EQUIPINFO_STARLEVEL2_FIELD.type = 5
EQUIPINFO_STARLEVEL2_FIELD.cpp_type = 1

EQUIPINFO_STAREXP2_FIELD.name = "starExp2"
EQUIPINFO_STAREXP2_FIELD.full_name = ".EquipInfo.starExp2"
EQUIPINFO_STAREXP2_FIELD.number = 13
EQUIPINFO_STAREXP2_FIELD.index = 12
EQUIPINFO_STAREXP2_FIELD.label = 1
EQUIPINFO_STAREXP2_FIELD.has_default_value = false
EQUIPINFO_STAREXP2_FIELD.default_value = 0
EQUIPINFO_STAREXP2_FIELD.type = 5
EQUIPINFO_STAREXP2_FIELD.cpp_type = 1

EQUIPINFO_GODLYATTRID2_FIELD.name = "godlyAttrId2"
EQUIPINFO_GODLYATTRID2_FIELD.full_name = ".EquipInfo.godlyAttrId2"
EQUIPINFO_GODLYATTRID2_FIELD.number = 14
EQUIPINFO_GODLYATTRID2_FIELD.index = 13
EQUIPINFO_GODLYATTRID2_FIELD.label = 1
EQUIPINFO_GODLYATTRID2_FIELD.has_default_value = false
EQUIPINFO_GODLYATTRID2_FIELD.default_value = 0
EQUIPINFO_GODLYATTRID2_FIELD.type = 5
EQUIPINFO_GODLYATTRID2_FIELD.cpp_type = 1

EQUIPINFO_RELATESUITID_FIELD.name = "relateSuitId"
EQUIPINFO_RELATESUITID_FIELD.full_name = ".EquipInfo.relateSuitId"
EQUIPINFO_RELATESUITID_FIELD.number = 15
EQUIPINFO_RELATESUITID_FIELD.index = 14
EQUIPINFO_RELATESUITID_FIELD.label = 1
EQUIPINFO_RELATESUITID_FIELD.has_default_value = false
EQUIPINFO_RELATESUITID_FIELD.default_value = 0
EQUIPINFO_RELATESUITID_FIELD.type = 5
EQUIPINFO_RELATESUITID_FIELD.cpp_type = 1

EQUIPINFO.name = "EquipInfo"
EQUIPINFO.full_name = ".EquipInfo"
EQUIPINFO.nested_types = {}
EQUIPINFO.enum_types = {}
EQUIPINFO.fields = {EQUIPINFO_ID_FIELD, EQUIPINFO_EQUIPID_FIELD, EQUIPINFO_STRENGTH_FIELD, EQUIPINFO_STARLEVEL_FIELD, EQUIPINFO_STAREXP_FIELD, EQUIPINFO_GODLYATTRID_FIELD, EQUIPINFO_GEMINFOS_FIELD, EQUIPINFO_ATTRINFOS_FIELD, EQUIPINFO_STATUS_FIELD, EQUIPINFO_SCORE_FIELD, EQUIPINFO_LOCK_FIELD, EQUIPINFO_STARLEVEL2_FIELD, EQUIPINFO_STAREXP2_FIELD, EQUIPINFO_GODLYATTRID2_FIELD, EQUIPINFO_RELATESUITID_FIELD}
EQUIPINFO.is_extendable = false
EQUIPINFO.extensions = {}
HPEQUIPINFOSYNC_EQUIPINFOS_FIELD.name = "equipInfos"
HPEQUIPINFOSYNC_EQUIPINFOS_FIELD.full_name = ".HPEquipInfoSync.equipInfos"
HPEQUIPINFOSYNC_EQUIPINFOS_FIELD.number = 1
HPEQUIPINFOSYNC_EQUIPINFOS_FIELD.index = 0
HPEQUIPINFOSYNC_EQUIPINFOS_FIELD.label = 3
HPEQUIPINFOSYNC_EQUIPINFOS_FIELD.has_default_value = false
HPEQUIPINFOSYNC_EQUIPINFOS_FIELD.default_value = {}
HPEQUIPINFOSYNC_EQUIPINFOS_FIELD.message_type = EQUIPINFO
HPEQUIPINFOSYNC_EQUIPINFOS_FIELD.type = 11
HPEQUIPINFOSYNC_EQUIPINFOS_FIELD.cpp_type = 10

HPEQUIPINFOSYNC_ISREWARD_FIELD.name = "isReward"
HPEQUIPINFOSYNC_ISREWARD_FIELD.full_name = ".HPEquipInfoSync.isReward"
HPEQUIPINFOSYNC_ISREWARD_FIELD.number = 2
HPEQUIPINFOSYNC_ISREWARD_FIELD.index = 1
HPEQUIPINFOSYNC_ISREWARD_FIELD.label = 1
HPEQUIPINFOSYNC_ISREWARD_FIELD.has_default_value = false
HPEQUIPINFOSYNC_ISREWARD_FIELD.default_value = false
HPEQUIPINFOSYNC_ISREWARD_FIELD.type = 8
HPEQUIPINFOSYNC_ISREWARD_FIELD.cpp_type = 7

HPEQUIPINFOSYNC.name = "HPEquipInfoSync"
HPEQUIPINFOSYNC.full_name = ".HPEquipInfoSync"
HPEQUIPINFOSYNC.nested_types = {}
HPEQUIPINFOSYNC.enum_types = {}
HPEQUIPINFOSYNC.fields = {HPEQUIPINFOSYNC_EQUIPINFOS_FIELD, HPEQUIPINFOSYNC_ISREWARD_FIELD}
HPEQUIPINFOSYNC.is_extendable = false
HPEQUIPINFOSYNC.extensions = {}

EquipAttr = protobuf.Message(EQUIPATTR)
EquipInfo = protobuf.Message(EQUIPINFO)
GemInfo = protobuf.Message(GEMINFO)
HPEquipInfoSync = protobuf.Message(HPEQUIPINFOSYNC)

