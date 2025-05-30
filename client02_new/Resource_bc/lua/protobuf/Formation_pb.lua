-- Generated By protoc-gen-lua Do not Edit
local protobuf = require "protobuf"
module('Formation_pb')


HPFORMATIONREQUEST = protobuf.Descriptor();
local HPFORMATIONREQUEST_TYPE_FIELD = protobuf.FieldDescriptor();
HPFORMATIONRESPONSE = protobuf.Descriptor();
local HPFORMATIONRESPONSE_TYPE_FIELD = protobuf.FieldDescriptor();
local HPFORMATIONRESPONSE_POSCOUNT_FIELD = protobuf.FieldDescriptor();
local HPFORMATIONRESPONSE_ROLENUMBERLIST_FIELD = protobuf.FieldDescriptor();
HPFORMATIONEDITINFOREQ = protobuf.Descriptor();
local HPFORMATIONEDITINFOREQ_INDEX_FIELD = protobuf.FieldDescriptor();
FORMATIONINFO = protobuf.Descriptor();
local FORMATIONINFO_INDEX_FIELD = protobuf.FieldDescriptor();
local FORMATIONINFO_NAME_FIELD = protobuf.FieldDescriptor();
local FORMATIONINFO_ROLEIDS_FIELD = protobuf.FieldDescriptor();
HPFORMATIONEDITINFORES = protobuf.Descriptor();
local HPFORMATIONEDITINFORES_FORMATIONS_FIELD = protobuf.FieldDescriptor();
HPFORMATIONEDITREQ = protobuf.Descriptor();
local HPFORMATIONEDITREQ_INDEX_FIELD = protobuf.FieldDescriptor();
local HPFORMATIONEDITREQ_ROLEIDS_FIELD = protobuf.FieldDescriptor();
HPFORMATIONEDITRES = protobuf.Descriptor();
local HPFORMATIONEDITRES_FORMATIONS_FIELD = protobuf.FieldDescriptor();
HPFORMATIONUSEREQ = protobuf.Descriptor();
local HPFORMATIONUSEREQ_INDEX_FIELD = protobuf.FieldDescriptor();
HPFORMATIONUSERES = protobuf.Descriptor();
local HPFORMATIONUSERES_INDEX_FIELD = protobuf.FieldDescriptor();
HPFORMATIONCHANGENAMEREQ = protobuf.Descriptor();
local HPFORMATIONCHANGENAMEREQ_INDEX_FIELD = protobuf.FieldDescriptor();
local HPFORMATIONCHANGENAMEREQ_NAME_FIELD = protobuf.FieldDescriptor();

HPFORMATIONREQUEST_TYPE_FIELD.name = "type"
HPFORMATIONREQUEST_TYPE_FIELD.full_name = ".HPFormationRequest.type"
HPFORMATIONREQUEST_TYPE_FIELD.number = 1
HPFORMATIONREQUEST_TYPE_FIELD.index = 0
HPFORMATIONREQUEST_TYPE_FIELD.label = 2
HPFORMATIONREQUEST_TYPE_FIELD.has_default_value = false
HPFORMATIONREQUEST_TYPE_FIELD.default_value = 0
HPFORMATIONREQUEST_TYPE_FIELD.type = 5
HPFORMATIONREQUEST_TYPE_FIELD.cpp_type = 1

HPFORMATIONREQUEST.name = "HPFormationRequest"
HPFORMATIONREQUEST.full_name = ".HPFormationRequest"
HPFORMATIONREQUEST.nested_types = {}
HPFORMATIONREQUEST.enum_types = {}
HPFORMATIONREQUEST.fields = {HPFORMATIONREQUEST_TYPE_FIELD}
HPFORMATIONREQUEST.is_extendable = false
HPFORMATIONREQUEST.extensions = {}
HPFORMATIONRESPONSE_TYPE_FIELD.name = "type"
HPFORMATIONRESPONSE_TYPE_FIELD.full_name = ".HPFormationResponse.type"
HPFORMATIONRESPONSE_TYPE_FIELD.number = 1
HPFORMATIONRESPONSE_TYPE_FIELD.index = 0
HPFORMATIONRESPONSE_TYPE_FIELD.label = 2
HPFORMATIONRESPONSE_TYPE_FIELD.has_default_value = false
HPFORMATIONRESPONSE_TYPE_FIELD.default_value = 0
HPFORMATIONRESPONSE_TYPE_FIELD.type = 5
HPFORMATIONRESPONSE_TYPE_FIELD.cpp_type = 1

HPFORMATIONRESPONSE_POSCOUNT_FIELD.name = "posCount"
HPFORMATIONRESPONSE_POSCOUNT_FIELD.full_name = ".HPFormationResponse.posCount"
HPFORMATIONRESPONSE_POSCOUNT_FIELD.number = 2
HPFORMATIONRESPONSE_POSCOUNT_FIELD.index = 1
HPFORMATIONRESPONSE_POSCOUNT_FIELD.label = 2
HPFORMATIONRESPONSE_POSCOUNT_FIELD.has_default_value = false
HPFORMATIONRESPONSE_POSCOUNT_FIELD.default_value = 0
HPFORMATIONRESPONSE_POSCOUNT_FIELD.type = 5
HPFORMATIONRESPONSE_POSCOUNT_FIELD.cpp_type = 1

HPFORMATIONRESPONSE_ROLENUMBERLIST_FIELD.name = "roleNumberList"
HPFORMATIONRESPONSE_ROLENUMBERLIST_FIELD.full_name = ".HPFormationResponse.roleNumberList"
HPFORMATIONRESPONSE_ROLENUMBERLIST_FIELD.number = 3
HPFORMATIONRESPONSE_ROLENUMBERLIST_FIELD.index = 2
HPFORMATIONRESPONSE_ROLENUMBERLIST_FIELD.label = 3
HPFORMATIONRESPONSE_ROLENUMBERLIST_FIELD.has_default_value = false
HPFORMATIONRESPONSE_ROLENUMBERLIST_FIELD.default_value = {}
HPFORMATIONRESPONSE_ROLENUMBERLIST_FIELD.type = 5
HPFORMATIONRESPONSE_ROLENUMBERLIST_FIELD.cpp_type = 1

HPFORMATIONRESPONSE.name = "HPFormationResponse"
HPFORMATIONRESPONSE.full_name = ".HPFormationResponse"
HPFORMATIONRESPONSE.nested_types = {}
HPFORMATIONRESPONSE.enum_types = {}
HPFORMATIONRESPONSE.fields = {HPFORMATIONRESPONSE_TYPE_FIELD, HPFORMATIONRESPONSE_POSCOUNT_FIELD, HPFORMATIONRESPONSE_ROLENUMBERLIST_FIELD}
HPFORMATIONRESPONSE.is_extendable = false
HPFORMATIONRESPONSE.extensions = {}
HPFORMATIONEDITINFOREQ_INDEX_FIELD.name = "index"
HPFORMATIONEDITINFOREQ_INDEX_FIELD.full_name = ".HPFormationEditInfoReq.index"
HPFORMATIONEDITINFOREQ_INDEX_FIELD.number = 1
HPFORMATIONEDITINFOREQ_INDEX_FIELD.index = 0
HPFORMATIONEDITINFOREQ_INDEX_FIELD.label = 2
HPFORMATIONEDITINFOREQ_INDEX_FIELD.has_default_value = false
HPFORMATIONEDITINFOREQ_INDEX_FIELD.default_value = 0
HPFORMATIONEDITINFOREQ_INDEX_FIELD.type = 5
HPFORMATIONEDITINFOREQ_INDEX_FIELD.cpp_type = 1

HPFORMATIONEDITINFOREQ.name = "HPFormationEditInfoReq"
HPFORMATIONEDITINFOREQ.full_name = ".HPFormationEditInfoReq"
HPFORMATIONEDITINFOREQ.nested_types = {}
HPFORMATIONEDITINFOREQ.enum_types = {}
HPFORMATIONEDITINFOREQ.fields = {HPFORMATIONEDITINFOREQ_INDEX_FIELD}
HPFORMATIONEDITINFOREQ.is_extendable = false
HPFORMATIONEDITINFOREQ.extensions = {}
FORMATIONINFO_INDEX_FIELD.name = "index"
FORMATIONINFO_INDEX_FIELD.full_name = ".FormationInfo.index"
FORMATIONINFO_INDEX_FIELD.number = 1
FORMATIONINFO_INDEX_FIELD.index = 0
FORMATIONINFO_INDEX_FIELD.label = 2
FORMATIONINFO_INDEX_FIELD.has_default_value = false
FORMATIONINFO_INDEX_FIELD.default_value = 0
FORMATIONINFO_INDEX_FIELD.type = 5
FORMATIONINFO_INDEX_FIELD.cpp_type = 1

FORMATIONINFO_NAME_FIELD.name = "name"
FORMATIONINFO_NAME_FIELD.full_name = ".FormationInfo.name"
FORMATIONINFO_NAME_FIELD.number = 2
FORMATIONINFO_NAME_FIELD.index = 1
FORMATIONINFO_NAME_FIELD.label = 2
FORMATIONINFO_NAME_FIELD.has_default_value = false
FORMATIONINFO_NAME_FIELD.default_value = ""
FORMATIONINFO_NAME_FIELD.type = 9
FORMATIONINFO_NAME_FIELD.cpp_type = 9

FORMATIONINFO_ROLEIDS_FIELD.name = "roleIds"
FORMATIONINFO_ROLEIDS_FIELD.full_name = ".FormationInfo.roleIds"
FORMATIONINFO_ROLEIDS_FIELD.number = 3
FORMATIONINFO_ROLEIDS_FIELD.index = 2
FORMATIONINFO_ROLEIDS_FIELD.label = 3
FORMATIONINFO_ROLEIDS_FIELD.has_default_value = false
FORMATIONINFO_ROLEIDS_FIELD.default_value = {}
FORMATIONINFO_ROLEIDS_FIELD.type = 5
FORMATIONINFO_ROLEIDS_FIELD.cpp_type = 1

FORMATIONINFO.name = "FormationInfo"
FORMATIONINFO.full_name = ".FormationInfo"
FORMATIONINFO.nested_types = {}
FORMATIONINFO.enum_types = {}
FORMATIONINFO.fields = {FORMATIONINFO_INDEX_FIELD, FORMATIONINFO_NAME_FIELD, FORMATIONINFO_ROLEIDS_FIELD}
FORMATIONINFO.is_extendable = false
FORMATIONINFO.extensions = {}
HPFORMATIONEDITINFORES_FORMATIONS_FIELD.name = "formations"
HPFORMATIONEDITINFORES_FORMATIONS_FIELD.full_name = ".HPFormationEditInfoRes.formations"
HPFORMATIONEDITINFORES_FORMATIONS_FIELD.number = 1
HPFORMATIONEDITINFORES_FORMATIONS_FIELD.index = 0
HPFORMATIONEDITINFORES_FORMATIONS_FIELD.label = 2
HPFORMATIONEDITINFORES_FORMATIONS_FIELD.has_default_value = false
HPFORMATIONEDITINFORES_FORMATIONS_FIELD.default_value = nil
HPFORMATIONEDITINFORES_FORMATIONS_FIELD.message_type = FORMATIONINFO
HPFORMATIONEDITINFORES_FORMATIONS_FIELD.type = 11
HPFORMATIONEDITINFORES_FORMATIONS_FIELD.cpp_type = 10

HPFORMATIONEDITINFORES.name = "HPFormationEditInfoRes"
HPFORMATIONEDITINFORES.full_name = ".HPFormationEditInfoRes"
HPFORMATIONEDITINFORES.nested_types = {}
HPFORMATIONEDITINFORES.enum_types = {}
HPFORMATIONEDITINFORES.fields = {HPFORMATIONEDITINFORES_FORMATIONS_FIELD}
HPFORMATIONEDITINFORES.is_extendable = false
HPFORMATIONEDITINFORES.extensions = {}
HPFORMATIONEDITREQ_INDEX_FIELD.name = "index"
HPFORMATIONEDITREQ_INDEX_FIELD.full_name = ".HPFormationEditReq.index"
HPFORMATIONEDITREQ_INDEX_FIELD.number = 1
HPFORMATIONEDITREQ_INDEX_FIELD.index = 0
HPFORMATIONEDITREQ_INDEX_FIELD.label = 2
HPFORMATIONEDITREQ_INDEX_FIELD.has_default_value = false
HPFORMATIONEDITREQ_INDEX_FIELD.default_value = 0
HPFORMATIONEDITREQ_INDEX_FIELD.type = 5
HPFORMATIONEDITREQ_INDEX_FIELD.cpp_type = 1

HPFORMATIONEDITREQ_ROLEIDS_FIELD.name = "roleIds"
HPFORMATIONEDITREQ_ROLEIDS_FIELD.full_name = ".HPFormationEditReq.roleIds"
HPFORMATIONEDITREQ_ROLEIDS_FIELD.number = 2
HPFORMATIONEDITREQ_ROLEIDS_FIELD.index = 1
HPFORMATIONEDITREQ_ROLEIDS_FIELD.label = 3
HPFORMATIONEDITREQ_ROLEIDS_FIELD.has_default_value = false
HPFORMATIONEDITREQ_ROLEIDS_FIELD.default_value = {}
HPFORMATIONEDITREQ_ROLEIDS_FIELD.type = 5
HPFORMATIONEDITREQ_ROLEIDS_FIELD.cpp_type = 1

HPFORMATIONEDITREQ.name = "HPFormationEditReq"
HPFORMATIONEDITREQ.full_name = ".HPFormationEditReq"
HPFORMATIONEDITREQ.nested_types = {}
HPFORMATIONEDITREQ.enum_types = {}
HPFORMATIONEDITREQ.fields = {HPFORMATIONEDITREQ_INDEX_FIELD, HPFORMATIONEDITREQ_ROLEIDS_FIELD}
HPFORMATIONEDITREQ.is_extendable = false
HPFORMATIONEDITREQ.extensions = {}
HPFORMATIONEDITRES_FORMATIONS_FIELD.name = "formations"
HPFORMATIONEDITRES_FORMATIONS_FIELD.full_name = ".HPFormationEditRes.formations"
HPFORMATIONEDITRES_FORMATIONS_FIELD.number = 1
HPFORMATIONEDITRES_FORMATIONS_FIELD.index = 0
HPFORMATIONEDITRES_FORMATIONS_FIELD.label = 2
HPFORMATIONEDITRES_FORMATIONS_FIELD.has_default_value = false
HPFORMATIONEDITRES_FORMATIONS_FIELD.default_value = nil
HPFORMATIONEDITRES_FORMATIONS_FIELD.message_type = FORMATIONINFO
HPFORMATIONEDITRES_FORMATIONS_FIELD.type = 11
HPFORMATIONEDITRES_FORMATIONS_FIELD.cpp_type = 10

HPFORMATIONEDITRES.name = "HPFormationEditRes"
HPFORMATIONEDITRES.full_name = ".HPFormationEditRes"
HPFORMATIONEDITRES.nested_types = {}
HPFORMATIONEDITRES.enum_types = {}
HPFORMATIONEDITRES.fields = {HPFORMATIONEDITRES_FORMATIONS_FIELD}
HPFORMATIONEDITRES.is_extendable = false
HPFORMATIONEDITRES.extensions = {}
HPFORMATIONUSEREQ_INDEX_FIELD.name = "index"
HPFORMATIONUSEREQ_INDEX_FIELD.full_name = ".HPFormationUseReq.index"
HPFORMATIONUSEREQ_INDEX_FIELD.number = 1
HPFORMATIONUSEREQ_INDEX_FIELD.index = 0
HPFORMATIONUSEREQ_INDEX_FIELD.label = 2
HPFORMATIONUSEREQ_INDEX_FIELD.has_default_value = false
HPFORMATIONUSEREQ_INDEX_FIELD.default_value = 0
HPFORMATIONUSEREQ_INDEX_FIELD.type = 5
HPFORMATIONUSEREQ_INDEX_FIELD.cpp_type = 1

HPFORMATIONUSEREQ.name = "HPFormationUseReq"
HPFORMATIONUSEREQ.full_name = ".HPFormationUseReq"
HPFORMATIONUSEREQ.nested_types = {}
HPFORMATIONUSEREQ.enum_types = {}
HPFORMATIONUSEREQ.fields = {HPFORMATIONUSEREQ_INDEX_FIELD}
HPFORMATIONUSEREQ.is_extendable = false
HPFORMATIONUSEREQ.extensions = {}
HPFORMATIONUSERES_INDEX_FIELD.name = "index"
HPFORMATIONUSERES_INDEX_FIELD.full_name = ".HPFormationUseRes.index"
HPFORMATIONUSERES_INDEX_FIELD.number = 1
HPFORMATIONUSERES_INDEX_FIELD.index = 0
HPFORMATIONUSERES_INDEX_FIELD.label = 2
HPFORMATIONUSERES_INDEX_FIELD.has_default_value = false
HPFORMATIONUSERES_INDEX_FIELD.default_value = 0
HPFORMATIONUSERES_INDEX_FIELD.type = 5
HPFORMATIONUSERES_INDEX_FIELD.cpp_type = 1

HPFORMATIONUSERES.name = "HPFormationUseRes"
HPFORMATIONUSERES.full_name = ".HPFormationUseRes"
HPFORMATIONUSERES.nested_types = {}
HPFORMATIONUSERES.enum_types = {}
HPFORMATIONUSERES.fields = {HPFORMATIONUSERES_INDEX_FIELD}
HPFORMATIONUSERES.is_extendable = false
HPFORMATIONUSERES.extensions = {}
HPFORMATIONCHANGENAMEREQ_INDEX_FIELD.name = "index"
HPFORMATIONCHANGENAMEREQ_INDEX_FIELD.full_name = ".HPFormationChangeNameReq.index"
HPFORMATIONCHANGENAMEREQ_INDEX_FIELD.number = 1
HPFORMATIONCHANGENAMEREQ_INDEX_FIELD.index = 0
HPFORMATIONCHANGENAMEREQ_INDEX_FIELD.label = 2
HPFORMATIONCHANGENAMEREQ_INDEX_FIELD.has_default_value = false
HPFORMATIONCHANGENAMEREQ_INDEX_FIELD.default_value = 0
HPFORMATIONCHANGENAMEREQ_INDEX_FIELD.type = 5
HPFORMATIONCHANGENAMEREQ_INDEX_FIELD.cpp_type = 1

HPFORMATIONCHANGENAMEREQ_NAME_FIELD.name = "name"
HPFORMATIONCHANGENAMEREQ_NAME_FIELD.full_name = ".HPFormationChangeNameReq.name"
HPFORMATIONCHANGENAMEREQ_NAME_FIELD.number = 2
HPFORMATIONCHANGENAMEREQ_NAME_FIELD.index = 1
HPFORMATIONCHANGENAMEREQ_NAME_FIELD.label = 2
HPFORMATIONCHANGENAMEREQ_NAME_FIELD.has_default_value = false
HPFORMATIONCHANGENAMEREQ_NAME_FIELD.default_value = ""
HPFORMATIONCHANGENAMEREQ_NAME_FIELD.type = 9
HPFORMATIONCHANGENAMEREQ_NAME_FIELD.cpp_type = 9

HPFORMATIONCHANGENAMEREQ.name = "HPFormationChangeNameReq"
HPFORMATIONCHANGENAMEREQ.full_name = ".HPFormationChangeNameReq"
HPFORMATIONCHANGENAMEREQ.nested_types = {}
HPFORMATIONCHANGENAMEREQ.enum_types = {}
HPFORMATIONCHANGENAMEREQ.fields = {HPFORMATIONCHANGENAMEREQ_INDEX_FIELD, HPFORMATIONCHANGENAMEREQ_NAME_FIELD}
HPFORMATIONCHANGENAMEREQ.is_extendable = false
HPFORMATIONCHANGENAMEREQ.extensions = {}

FormationInfo = protobuf.Message(FORMATIONINFO)
HPFormationChangeNameReq = protobuf.Message(HPFORMATIONCHANGENAMEREQ)
HPFormationEditInfoReq = protobuf.Message(HPFORMATIONEDITINFOREQ)
HPFormationEditInfoRes = protobuf.Message(HPFORMATIONEDITINFORES)
HPFormationEditReq = protobuf.Message(HPFORMATIONEDITREQ)
HPFormationEditRes = protobuf.Message(HPFORMATIONEDITRES)
HPFormationRequest = protobuf.Message(HPFORMATIONREQUEST)
HPFormationResponse = protobuf.Message(HPFORMATIONRESPONSE)
HPFormationUseReq = protobuf.Message(HPFORMATIONUSEREQ)
HPFormationUseRes = protobuf.Message(HPFORMATIONUSERES)

