-- Generated By protoc-gen-lua Do not Edit
local protobuf = require "protobuf"
module('GuildBuff_pb')


GUILDBUFFREQ = protobuf.Descriptor();
local GUILDBUFFREQ_ACTION_FIELD = protobuf.FieldDescriptor();
local GUILDBUFFREQ_ID_FIELD = protobuf.FieldDescriptor();
TALENTBUFFINFO = protobuf.Descriptor();
local TALENTBUFFINFO_ID_FIELD = protobuf.FieldDescriptor();
local TALENTBUFFINFO_LV_FIELD = protobuf.FieldDescriptor();
GUILDBUFFRES = protobuf.Descriptor();
local GUILDBUFFRES_ACTION_FIELD = protobuf.FieldDescriptor();
local GUILDBUFFRES_TBINFO_FIELD = protobuf.FieldDescriptor();

GUILDBUFFREQ_ACTION_FIELD.name = "action"
GUILDBUFFREQ_ACTION_FIELD.full_name = ".GuildBuffReq.action"
GUILDBUFFREQ_ACTION_FIELD.number = 1
GUILDBUFFREQ_ACTION_FIELD.index = 0
GUILDBUFFREQ_ACTION_FIELD.label = 2
GUILDBUFFREQ_ACTION_FIELD.has_default_value = false
GUILDBUFFREQ_ACTION_FIELD.default_value = 0
GUILDBUFFREQ_ACTION_FIELD.type = 5
GUILDBUFFREQ_ACTION_FIELD.cpp_type = 1

GUILDBUFFREQ_ID_FIELD.name = "id"
GUILDBUFFREQ_ID_FIELD.full_name = ".GuildBuffReq.id"
GUILDBUFFREQ_ID_FIELD.number = 2
GUILDBUFFREQ_ID_FIELD.index = 1
GUILDBUFFREQ_ID_FIELD.label = 1
GUILDBUFFREQ_ID_FIELD.has_default_value = false
GUILDBUFFREQ_ID_FIELD.default_value = 0
GUILDBUFFREQ_ID_FIELD.type = 5
GUILDBUFFREQ_ID_FIELD.cpp_type = 1

GUILDBUFFREQ.name = "GuildBuffReq"
GUILDBUFFREQ.full_name = ".GuildBuffReq"
GUILDBUFFREQ.nested_types = {}
GUILDBUFFREQ.enum_types = {}
GUILDBUFFREQ.fields = {GUILDBUFFREQ_ACTION_FIELD, GUILDBUFFREQ_ID_FIELD}
GUILDBUFFREQ.is_extendable = false
GUILDBUFFREQ.extensions = {}
TALENTBUFFINFO_ID_FIELD.name = "id"
TALENTBUFFINFO_ID_FIELD.full_name = ".TalentBuffInfo.id"
TALENTBUFFINFO_ID_FIELD.number = 1
TALENTBUFFINFO_ID_FIELD.index = 0
TALENTBUFFINFO_ID_FIELD.label = 2
TALENTBUFFINFO_ID_FIELD.has_default_value = false
TALENTBUFFINFO_ID_FIELD.default_value = 0
TALENTBUFFINFO_ID_FIELD.type = 5
TALENTBUFFINFO_ID_FIELD.cpp_type = 1

TALENTBUFFINFO_LV_FIELD.name = "lv"
TALENTBUFFINFO_LV_FIELD.full_name = ".TalentBuffInfo.lv"
TALENTBUFFINFO_LV_FIELD.number = 2
TALENTBUFFINFO_LV_FIELD.index = 1
TALENTBUFFINFO_LV_FIELD.label = 2
TALENTBUFFINFO_LV_FIELD.has_default_value = false
TALENTBUFFINFO_LV_FIELD.default_value = 0
TALENTBUFFINFO_LV_FIELD.type = 5
TALENTBUFFINFO_LV_FIELD.cpp_type = 1

TALENTBUFFINFO.name = "TalentBuffInfo"
TALENTBUFFINFO.full_name = ".TalentBuffInfo"
TALENTBUFFINFO.nested_types = {}
TALENTBUFFINFO.enum_types = {}
TALENTBUFFINFO.fields = {TALENTBUFFINFO_ID_FIELD, TALENTBUFFINFO_LV_FIELD}
TALENTBUFFINFO.is_extendable = false
TALENTBUFFINFO.extensions = {}
GUILDBUFFRES_ACTION_FIELD.name = "action"
GUILDBUFFRES_ACTION_FIELD.full_name = ".GuildBuffRes.action"
GUILDBUFFRES_ACTION_FIELD.number = 1
GUILDBUFFRES_ACTION_FIELD.index = 0
GUILDBUFFRES_ACTION_FIELD.label = 2
GUILDBUFFRES_ACTION_FIELD.has_default_value = false
GUILDBUFFRES_ACTION_FIELD.default_value = 0
GUILDBUFFRES_ACTION_FIELD.type = 5
GUILDBUFFRES_ACTION_FIELD.cpp_type = 1

GUILDBUFFRES_TBINFO_FIELD.name = "TBInfo"
GUILDBUFFRES_TBINFO_FIELD.full_name = ".GuildBuffRes.TBInfo"
GUILDBUFFRES_TBINFO_FIELD.number = 2
GUILDBUFFRES_TBINFO_FIELD.index = 1
GUILDBUFFRES_TBINFO_FIELD.label = 3
GUILDBUFFRES_TBINFO_FIELD.has_default_value = false
GUILDBUFFRES_TBINFO_FIELD.default_value = {}
GUILDBUFFRES_TBINFO_FIELD.message_type = TALENTBUFFINFO
GUILDBUFFRES_TBINFO_FIELD.type = 11
GUILDBUFFRES_TBINFO_FIELD.cpp_type = 10

GUILDBUFFRES.name = "GuildBuffRes"
GUILDBUFFRES.full_name = ".GuildBuffRes"
GUILDBUFFRES.nested_types = {}
GUILDBUFFRES.enum_types = {}
GUILDBUFFRES.fields = {GUILDBUFFRES_ACTION_FIELD, GUILDBUFFRES_TBINFO_FIELD}
GUILDBUFFRES.is_extendable = false
GUILDBUFFRES.extensions = {}

GuildBuffReq = protobuf.Message(GUILDBUFFREQ)
GuildBuffRes = protobuf.Message(GUILDBUFFRES)
TalentBuffInfo = protobuf.Message(TALENTBUFFINFO)

