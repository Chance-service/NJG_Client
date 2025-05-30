-- Generated By protoc-gen-lua Do not Edit
local protobuf = require "protobuf"
local Battle_pb = require("Battle_pb")
module('Arena_pb')


ARENAROLEINFO = protobuf.Descriptor();
local ARENAROLEINFO_ITEMID_FIELD = protobuf.FieldDescriptor();
local ARENAROLEINFO_STARLEVEL_FIELD = protobuf.FieldDescriptor();
local ARENAROLEINFO_SKINID_FIELD = protobuf.FieldDescriptor();
local ARENAROLEINFO_FIGHTVALUE_FIELD = protobuf.FieldDescriptor();
local ARENAROLEINFO_LEVEL_FIELD = protobuf.FieldDescriptor();
ARENAITEMINFO = protobuf.Descriptor();
local ARENAITEMINFO_IDENTITYTYPE_FIELD = protobuf.FieldDescriptor();
local ARENAITEMINFO_CFGITEMID_FIELD = protobuf.FieldDescriptor();
local ARENAITEMINFO_PLAYERID_FIELD = protobuf.FieldDescriptor();
local ARENAITEMINFO_LEVEL_FIELD = protobuf.FieldDescriptor();
local ARENAITEMINFO_NAME_FIELD = protobuf.FieldDescriptor();
local ARENAITEMINFO_PROF_FIELD = protobuf.FieldDescriptor();
local ARENAITEMINFO_RANK_FIELD = protobuf.FieldDescriptor();
local ARENAITEMINFO_FIGHTVALUE_FIELD = protobuf.FieldDescriptor();
local ARENAITEMINFO_RANKAWARDSSTR_FIELD = protobuf.FieldDescriptor();
local ARENAITEMINFO_SURPLUSCHALLENGETIMES_FIELD = protobuf.FieldDescriptor();
local ARENAITEMINFO_NEXTBUYPRICE_FIELD = protobuf.FieldDescriptor();
local ARENAITEMINFO_ALREADYBUYTIMES_FIELD = protobuf.FieldDescriptor();
local ARENAITEMINFO_ALLIANCENAME_FIELD = protobuf.FieldDescriptor();
local ARENAITEMINFO_ALLIANCEID_FIELD = protobuf.FieldDescriptor();
local ARENAITEMINFO_HEADICON_FIELD = protobuf.FieldDescriptor();
local ARENAITEMINFO_ROLEITEMINFO_FIELD = protobuf.FieldDescriptor();
HPARENADEFENDERLIST = protobuf.Descriptor();
local HPARENADEFENDERLIST_PLAYERID_FIELD = protobuf.FieldDescriptor();
HPARENADEFENDERLISTSYNCS = protobuf.Descriptor();
local HPARENADEFENDERLISTSYNCS_SELF_FIELD = protobuf.FieldDescriptor();
local HPARENADEFENDERLISTSYNCS_DEFENDER_FIELD = protobuf.FieldDescriptor();
local HPARENADEFENDERLISTSYNCS_LEFTTIME_FIELD = protobuf.FieldDescriptor();
HPREPLACEDEFENDERLIST = protobuf.Descriptor();
local HPREPLACEDEFENDERLIST_PLAYERID_FIELD = protobuf.FieldDescriptor();
HPREPLACEDEFENDERLISTRET = protobuf.Descriptor();
local HPREPLACEDEFENDERLISTRET_DEFENDER_FIELD = protobuf.FieldDescriptor();
HPBUYCHALLENGETIMES = protobuf.Descriptor();
local HPBUYCHALLENGETIMES_TIMES_FIELD = protobuf.FieldDescriptor();
HPBUYCHALLENGETIMESRET = protobuf.Descriptor();
local HPBUYCHALLENGETIMESRET_SURPLUSCHALLENGETIMES_FIELD = protobuf.FieldDescriptor();
local HPBUYCHALLENGETIMESRET_ALREADYBUYTIMES_FIELD = protobuf.FieldDescriptor();
local HPBUYCHALLENGETIMESRET_NEXTBUYPRICE_FIELD = protobuf.FieldDescriptor();
HPARENARANKINGLIST = protobuf.Descriptor();
HPARENARANKINGLISTRET = protobuf.Descriptor();
local HPARENARANKINGLISTRET_SELF_FIELD = protobuf.FieldDescriptor();
local HPARENARANKINGLISTRET_RANKINFO_FIELD = protobuf.FieldDescriptor();
HPCHALLENGEDEFENDER = protobuf.Descriptor();
local HPCHALLENGEDEFENDER_DEFENDERANK_FIELD = protobuf.FieldDescriptor();
local HPCHALLENGEDEFENDER_MONSTERID_FIELD = protobuf.FieldDescriptor();
local HPCHALLENGEDEFENDER_PLAYERID_FIELD = protobuf.FieldDescriptor();
HPCHALLENGEDEFENDERRET = protobuf.Descriptor();
local HPCHALLENGEDEFENDERRET_CHALLENGERESULT_FIELD = protobuf.FieldDescriptor();
local HPCHALLENGEDEFENDERRET_PREOFCHALLENGERANK_FIELD = protobuf.FieldDescriptor();
local HPCHALLENGEDEFENDERRET_AFTEROFCHALLENGERANK_FIELD = protobuf.FieldDescriptor();
HPRECORDMAXARENAMAILID = protobuf.Descriptor();
local HPRECORDMAXARENAMAILID_MAXMAILID_FIELD = protobuf.FieldDescriptor();
HPARENACHALLENGEREPORTRES = protobuf.Descriptor();
local HPARENACHALLENGEREPORTRES_BATTLEINFO_FIELD = protobuf.FieldDescriptor();
local HPARENACHALLENGEREPORTRES_VERSION_FIELD = protobuf.FieldDescriptor();
HPARENAREPORTREQ = protobuf.Descriptor();
local HPARENAREPORTREQ_REPORTID_FIELD = protobuf.FieldDescriptor();

ARENAROLEINFO_ITEMID_FIELD.name = "itemId"
ARENAROLEINFO_ITEMID_FIELD.full_name = ".ArenaRoleInfo.itemId"
ARENAROLEINFO_ITEMID_FIELD.number = 1
ARENAROLEINFO_ITEMID_FIELD.index = 0
ARENAROLEINFO_ITEMID_FIELD.label = 2
ARENAROLEINFO_ITEMID_FIELD.has_default_value = false
ARENAROLEINFO_ITEMID_FIELD.default_value = 0
ARENAROLEINFO_ITEMID_FIELD.type = 5
ARENAROLEINFO_ITEMID_FIELD.cpp_type = 1

ARENAROLEINFO_STARLEVEL_FIELD.name = "starLevel"
ARENAROLEINFO_STARLEVEL_FIELD.full_name = ".ArenaRoleInfo.starLevel"
ARENAROLEINFO_STARLEVEL_FIELD.number = 2
ARENAROLEINFO_STARLEVEL_FIELD.index = 1
ARENAROLEINFO_STARLEVEL_FIELD.label = 1
ARENAROLEINFO_STARLEVEL_FIELD.has_default_value = false
ARENAROLEINFO_STARLEVEL_FIELD.default_value = 0
ARENAROLEINFO_STARLEVEL_FIELD.type = 5
ARENAROLEINFO_STARLEVEL_FIELD.cpp_type = 1

ARENAROLEINFO_SKINID_FIELD.name = "skinId"
ARENAROLEINFO_SKINID_FIELD.full_name = ".ArenaRoleInfo.skinId"
ARENAROLEINFO_SKINID_FIELD.number = 3
ARENAROLEINFO_SKINID_FIELD.index = 2
ARENAROLEINFO_SKINID_FIELD.label = 1
ARENAROLEINFO_SKINID_FIELD.has_default_value = false
ARENAROLEINFO_SKINID_FIELD.default_value = 0
ARENAROLEINFO_SKINID_FIELD.type = 5
ARENAROLEINFO_SKINID_FIELD.cpp_type = 1

ARENAROLEINFO_FIGHTVALUE_FIELD.name = "fightValue"
ARENAROLEINFO_FIGHTVALUE_FIELD.full_name = ".ArenaRoleInfo.fightValue"
ARENAROLEINFO_FIGHTVALUE_FIELD.number = 4
ARENAROLEINFO_FIGHTVALUE_FIELD.index = 3
ARENAROLEINFO_FIGHTVALUE_FIELD.label = 1
ARENAROLEINFO_FIGHTVALUE_FIELD.has_default_value = false
ARENAROLEINFO_FIGHTVALUE_FIELD.default_value = 0
ARENAROLEINFO_FIGHTVALUE_FIELD.type = 5
ARENAROLEINFO_FIGHTVALUE_FIELD.cpp_type = 1

ARENAROLEINFO_LEVEL_FIELD.name = "level"
ARENAROLEINFO_LEVEL_FIELD.full_name = ".ArenaRoleInfo.level"
ARENAROLEINFO_LEVEL_FIELD.number = 5
ARENAROLEINFO_LEVEL_FIELD.index = 4
ARENAROLEINFO_LEVEL_FIELD.label = 1
ARENAROLEINFO_LEVEL_FIELD.has_default_value = false
ARENAROLEINFO_LEVEL_FIELD.default_value = 0
ARENAROLEINFO_LEVEL_FIELD.type = 5
ARENAROLEINFO_LEVEL_FIELD.cpp_type = 1

ARENAROLEINFO.name = "ArenaRoleInfo"
ARENAROLEINFO.full_name = ".ArenaRoleInfo"
ARENAROLEINFO.nested_types = {}
ARENAROLEINFO.enum_types = {}
ARENAROLEINFO.fields = {ARENAROLEINFO_ITEMID_FIELD, ARENAROLEINFO_STARLEVEL_FIELD, ARENAROLEINFO_SKINID_FIELD, ARENAROLEINFO_FIGHTVALUE_FIELD, ARENAROLEINFO_LEVEL_FIELD}
ARENAROLEINFO.is_extendable = false
ARENAROLEINFO.extensions = {}
ARENAITEMINFO_IDENTITYTYPE_FIELD.name = "identityType"
ARENAITEMINFO_IDENTITYTYPE_FIELD.full_name = ".ArenaItemInfo.identityType"
ARENAITEMINFO_IDENTITYTYPE_FIELD.number = 1
ARENAITEMINFO_IDENTITYTYPE_FIELD.index = 0
ARENAITEMINFO_IDENTITYTYPE_FIELD.label = 2
ARENAITEMINFO_IDENTITYTYPE_FIELD.has_default_value = false
ARENAITEMINFO_IDENTITYTYPE_FIELD.default_value = 0
ARENAITEMINFO_IDENTITYTYPE_FIELD.type = 5
ARENAITEMINFO_IDENTITYTYPE_FIELD.cpp_type = 1

ARENAITEMINFO_CFGITEMID_FIELD.name = "cfgItemId"
ARENAITEMINFO_CFGITEMID_FIELD.full_name = ".ArenaItemInfo.cfgItemId"
ARENAITEMINFO_CFGITEMID_FIELD.number = 2
ARENAITEMINFO_CFGITEMID_FIELD.index = 1
ARENAITEMINFO_CFGITEMID_FIELD.label = 2
ARENAITEMINFO_CFGITEMID_FIELD.has_default_value = false
ARENAITEMINFO_CFGITEMID_FIELD.default_value = 0
ARENAITEMINFO_CFGITEMID_FIELD.type = 5
ARENAITEMINFO_CFGITEMID_FIELD.cpp_type = 1

ARENAITEMINFO_PLAYERID_FIELD.name = "playerId"
ARENAITEMINFO_PLAYERID_FIELD.full_name = ".ArenaItemInfo.playerId"
ARENAITEMINFO_PLAYERID_FIELD.number = 3
ARENAITEMINFO_PLAYERID_FIELD.index = 2
ARENAITEMINFO_PLAYERID_FIELD.label = 1
ARENAITEMINFO_PLAYERID_FIELD.has_default_value = false
ARENAITEMINFO_PLAYERID_FIELD.default_value = 0
ARENAITEMINFO_PLAYERID_FIELD.type = 5
ARENAITEMINFO_PLAYERID_FIELD.cpp_type = 1

ARENAITEMINFO_LEVEL_FIELD.name = "level"
ARENAITEMINFO_LEVEL_FIELD.full_name = ".ArenaItemInfo.level"
ARENAITEMINFO_LEVEL_FIELD.number = 4
ARENAITEMINFO_LEVEL_FIELD.index = 3
ARENAITEMINFO_LEVEL_FIELD.label = 2
ARENAITEMINFO_LEVEL_FIELD.has_default_value = false
ARENAITEMINFO_LEVEL_FIELD.default_value = 0
ARENAITEMINFO_LEVEL_FIELD.type = 5
ARENAITEMINFO_LEVEL_FIELD.cpp_type = 1

ARENAITEMINFO_NAME_FIELD.name = "name"
ARENAITEMINFO_NAME_FIELD.full_name = ".ArenaItemInfo.name"
ARENAITEMINFO_NAME_FIELD.number = 5
ARENAITEMINFO_NAME_FIELD.index = 4
ARENAITEMINFO_NAME_FIELD.label = 2
ARENAITEMINFO_NAME_FIELD.has_default_value = false
ARENAITEMINFO_NAME_FIELD.default_value = ""
ARENAITEMINFO_NAME_FIELD.type = 9
ARENAITEMINFO_NAME_FIELD.cpp_type = 9

ARENAITEMINFO_PROF_FIELD.name = "prof"
ARENAITEMINFO_PROF_FIELD.full_name = ".ArenaItemInfo.prof"
ARENAITEMINFO_PROF_FIELD.number = 6
ARENAITEMINFO_PROF_FIELD.index = 5
ARENAITEMINFO_PROF_FIELD.label = 2
ARENAITEMINFO_PROF_FIELD.has_default_value = false
ARENAITEMINFO_PROF_FIELD.default_value = 0
ARENAITEMINFO_PROF_FIELD.type = 5
ARENAITEMINFO_PROF_FIELD.cpp_type = 1

ARENAITEMINFO_RANK_FIELD.name = "rank"
ARENAITEMINFO_RANK_FIELD.full_name = ".ArenaItemInfo.rank"
ARENAITEMINFO_RANK_FIELD.number = 7
ARENAITEMINFO_RANK_FIELD.index = 6
ARENAITEMINFO_RANK_FIELD.label = 2
ARENAITEMINFO_RANK_FIELD.has_default_value = false
ARENAITEMINFO_RANK_FIELD.default_value = 0
ARENAITEMINFO_RANK_FIELD.type = 5
ARENAITEMINFO_RANK_FIELD.cpp_type = 1

ARENAITEMINFO_FIGHTVALUE_FIELD.name = "fightValue"
ARENAITEMINFO_FIGHTVALUE_FIELD.full_name = ".ArenaItemInfo.fightValue"
ARENAITEMINFO_FIGHTVALUE_FIELD.number = 8
ARENAITEMINFO_FIGHTVALUE_FIELD.index = 7
ARENAITEMINFO_FIGHTVALUE_FIELD.label = 2
ARENAITEMINFO_FIGHTVALUE_FIELD.has_default_value = false
ARENAITEMINFO_FIGHTVALUE_FIELD.default_value = 0
ARENAITEMINFO_FIGHTVALUE_FIELD.type = 5
ARENAITEMINFO_FIGHTVALUE_FIELD.cpp_type = 1

ARENAITEMINFO_RANKAWARDSSTR_FIELD.name = "rankAwardsStr"
ARENAITEMINFO_RANKAWARDSSTR_FIELD.full_name = ".ArenaItemInfo.rankAwardsStr"
ARENAITEMINFO_RANKAWARDSSTR_FIELD.number = 9
ARENAITEMINFO_RANKAWARDSSTR_FIELD.index = 8
ARENAITEMINFO_RANKAWARDSSTR_FIELD.label = 2
ARENAITEMINFO_RANKAWARDSSTR_FIELD.has_default_value = false
ARENAITEMINFO_RANKAWARDSSTR_FIELD.default_value = ""
ARENAITEMINFO_RANKAWARDSSTR_FIELD.type = 9
ARENAITEMINFO_RANKAWARDSSTR_FIELD.cpp_type = 9

ARENAITEMINFO_SURPLUSCHALLENGETIMES_FIELD.name = "surplusChallengeTimes"
ARENAITEMINFO_SURPLUSCHALLENGETIMES_FIELD.full_name = ".ArenaItemInfo.surplusChallengeTimes"
ARENAITEMINFO_SURPLUSCHALLENGETIMES_FIELD.number = 10
ARENAITEMINFO_SURPLUSCHALLENGETIMES_FIELD.index = 9
ARENAITEMINFO_SURPLUSCHALLENGETIMES_FIELD.label = 1
ARENAITEMINFO_SURPLUSCHALLENGETIMES_FIELD.has_default_value = false
ARENAITEMINFO_SURPLUSCHALLENGETIMES_FIELD.default_value = 0
ARENAITEMINFO_SURPLUSCHALLENGETIMES_FIELD.type = 5
ARENAITEMINFO_SURPLUSCHALLENGETIMES_FIELD.cpp_type = 1

ARENAITEMINFO_NEXTBUYPRICE_FIELD.name = "nextBuyPrice"
ARENAITEMINFO_NEXTBUYPRICE_FIELD.full_name = ".ArenaItemInfo.nextBuyPrice"
ARENAITEMINFO_NEXTBUYPRICE_FIELD.number = 11
ARENAITEMINFO_NEXTBUYPRICE_FIELD.index = 10
ARENAITEMINFO_NEXTBUYPRICE_FIELD.label = 1
ARENAITEMINFO_NEXTBUYPRICE_FIELD.has_default_value = false
ARENAITEMINFO_NEXTBUYPRICE_FIELD.default_value = 0
ARENAITEMINFO_NEXTBUYPRICE_FIELD.type = 5
ARENAITEMINFO_NEXTBUYPRICE_FIELD.cpp_type = 1

ARENAITEMINFO_ALREADYBUYTIMES_FIELD.name = "alreadyBuyTimes"
ARENAITEMINFO_ALREADYBUYTIMES_FIELD.full_name = ".ArenaItemInfo.alreadyBuyTimes"
ARENAITEMINFO_ALREADYBUYTIMES_FIELD.number = 12
ARENAITEMINFO_ALREADYBUYTIMES_FIELD.index = 11
ARENAITEMINFO_ALREADYBUYTIMES_FIELD.label = 1
ARENAITEMINFO_ALREADYBUYTIMES_FIELD.has_default_value = false
ARENAITEMINFO_ALREADYBUYTIMES_FIELD.default_value = 0
ARENAITEMINFO_ALREADYBUYTIMES_FIELD.type = 5
ARENAITEMINFO_ALREADYBUYTIMES_FIELD.cpp_type = 1

ARENAITEMINFO_ALLIANCENAME_FIELD.name = "allianceName"
ARENAITEMINFO_ALLIANCENAME_FIELD.full_name = ".ArenaItemInfo.allianceName"
ARENAITEMINFO_ALLIANCENAME_FIELD.number = 13
ARENAITEMINFO_ALLIANCENAME_FIELD.index = 12
ARENAITEMINFO_ALLIANCENAME_FIELD.label = 1
ARENAITEMINFO_ALLIANCENAME_FIELD.has_default_value = false
ARENAITEMINFO_ALLIANCENAME_FIELD.default_value = ""
ARENAITEMINFO_ALLIANCENAME_FIELD.type = 9
ARENAITEMINFO_ALLIANCENAME_FIELD.cpp_type = 9

ARENAITEMINFO_ALLIANCEID_FIELD.name = "allianceId"
ARENAITEMINFO_ALLIANCEID_FIELD.full_name = ".ArenaItemInfo.allianceId"
ARENAITEMINFO_ALLIANCEID_FIELD.number = 14
ARENAITEMINFO_ALLIANCEID_FIELD.index = 13
ARENAITEMINFO_ALLIANCEID_FIELD.label = 1
ARENAITEMINFO_ALLIANCEID_FIELD.has_default_value = false
ARENAITEMINFO_ALLIANCEID_FIELD.default_value = 0
ARENAITEMINFO_ALLIANCEID_FIELD.type = 5
ARENAITEMINFO_ALLIANCEID_FIELD.cpp_type = 1

ARENAITEMINFO_HEADICON_FIELD.name = "headIcon"
ARENAITEMINFO_HEADICON_FIELD.full_name = ".ArenaItemInfo.headIcon"
ARENAITEMINFO_HEADICON_FIELD.number = 15
ARENAITEMINFO_HEADICON_FIELD.index = 14
ARENAITEMINFO_HEADICON_FIELD.label = 1
ARENAITEMINFO_HEADICON_FIELD.has_default_value = false
ARENAITEMINFO_HEADICON_FIELD.default_value = 0
ARENAITEMINFO_HEADICON_FIELD.type = 5
ARENAITEMINFO_HEADICON_FIELD.cpp_type = 1

ARENAITEMINFO_ROLEITEMINFO_FIELD.name = "roleItemInfo"
ARENAITEMINFO_ROLEITEMINFO_FIELD.full_name = ".ArenaItemInfo.roleItemInfo"
ARENAITEMINFO_ROLEITEMINFO_FIELD.number = 16
ARENAITEMINFO_ROLEITEMINFO_FIELD.index = 15
ARENAITEMINFO_ROLEITEMINFO_FIELD.label = 3
ARENAITEMINFO_ROLEITEMINFO_FIELD.has_default_value = false
ARENAITEMINFO_ROLEITEMINFO_FIELD.default_value = {}
ARENAITEMINFO_ROLEITEMINFO_FIELD.message_type = ARENAROLEINFO
ARENAITEMINFO_ROLEITEMINFO_FIELD.type = 11
ARENAITEMINFO_ROLEITEMINFO_FIELD.cpp_type = 10

ARENAITEMINFO.name = "ArenaItemInfo"
ARENAITEMINFO.full_name = ".ArenaItemInfo"
ARENAITEMINFO.nested_types = {}
ARENAITEMINFO.enum_types = {}
ARENAITEMINFO.fields = {ARENAITEMINFO_IDENTITYTYPE_FIELD, ARENAITEMINFO_CFGITEMID_FIELD, ARENAITEMINFO_PLAYERID_FIELD, ARENAITEMINFO_LEVEL_FIELD, ARENAITEMINFO_NAME_FIELD, ARENAITEMINFO_PROF_FIELD, ARENAITEMINFO_RANK_FIELD, ARENAITEMINFO_FIGHTVALUE_FIELD, ARENAITEMINFO_RANKAWARDSSTR_FIELD, ARENAITEMINFO_SURPLUSCHALLENGETIMES_FIELD, ARENAITEMINFO_NEXTBUYPRICE_FIELD, ARENAITEMINFO_ALREADYBUYTIMES_FIELD, ARENAITEMINFO_ALLIANCENAME_FIELD, ARENAITEMINFO_ALLIANCEID_FIELD, ARENAITEMINFO_HEADICON_FIELD, ARENAITEMINFO_ROLEITEMINFO_FIELD}
ARENAITEMINFO.is_extendable = false
ARENAITEMINFO.extensions = {}
HPARENADEFENDERLIST_PLAYERID_FIELD.name = "playerId"
HPARENADEFENDERLIST_PLAYERID_FIELD.full_name = ".HPArenaDefenderList.playerId"
HPARENADEFENDERLIST_PLAYERID_FIELD.number = 1
HPARENADEFENDERLIST_PLAYERID_FIELD.index = 0
HPARENADEFENDERLIST_PLAYERID_FIELD.label = 2
HPARENADEFENDERLIST_PLAYERID_FIELD.has_default_value = false
HPARENADEFENDERLIST_PLAYERID_FIELD.default_value = 0
HPARENADEFENDERLIST_PLAYERID_FIELD.type = 5
HPARENADEFENDERLIST_PLAYERID_FIELD.cpp_type = 1

HPARENADEFENDERLIST.name = "HPArenaDefenderList"
HPARENADEFENDERLIST.full_name = ".HPArenaDefenderList"
HPARENADEFENDERLIST.nested_types = {}
HPARENADEFENDERLIST.enum_types = {}
HPARENADEFENDERLIST.fields = {HPARENADEFENDERLIST_PLAYERID_FIELD}
HPARENADEFENDERLIST.is_extendable = false
HPARENADEFENDERLIST.extensions = {}
HPARENADEFENDERLISTSYNCS_SELF_FIELD.name = "self"
HPARENADEFENDERLISTSYNCS_SELF_FIELD.full_name = ".HPArenaDefenderListSyncS.self"
HPARENADEFENDERLISTSYNCS_SELF_FIELD.number = 1
HPARENADEFENDERLISTSYNCS_SELF_FIELD.index = 0
HPARENADEFENDERLISTSYNCS_SELF_FIELD.label = 2
HPARENADEFENDERLISTSYNCS_SELF_FIELD.has_default_value = false
HPARENADEFENDERLISTSYNCS_SELF_FIELD.default_value = nil
HPARENADEFENDERLISTSYNCS_SELF_FIELD.message_type = ARENAITEMINFO
HPARENADEFENDERLISTSYNCS_SELF_FIELD.type = 11
HPARENADEFENDERLISTSYNCS_SELF_FIELD.cpp_type = 10

HPARENADEFENDERLISTSYNCS_DEFENDER_FIELD.name = "defender"
HPARENADEFENDERLISTSYNCS_DEFENDER_FIELD.full_name = ".HPArenaDefenderListSyncS.defender"
HPARENADEFENDERLISTSYNCS_DEFENDER_FIELD.number = 2
HPARENADEFENDERLISTSYNCS_DEFENDER_FIELD.index = 1
HPARENADEFENDERLISTSYNCS_DEFENDER_FIELD.label = 3
HPARENADEFENDERLISTSYNCS_DEFENDER_FIELD.has_default_value = false
HPARENADEFENDERLISTSYNCS_DEFENDER_FIELD.default_value = {}
HPARENADEFENDERLISTSYNCS_DEFENDER_FIELD.message_type = ARENAITEMINFO
HPARENADEFENDERLISTSYNCS_DEFENDER_FIELD.type = 11
HPARENADEFENDERLISTSYNCS_DEFENDER_FIELD.cpp_type = 10

HPARENADEFENDERLISTSYNCS_LEFTTIME_FIELD.name = "leftTime"
HPARENADEFENDERLISTSYNCS_LEFTTIME_FIELD.full_name = ".HPArenaDefenderListSyncS.leftTime"
HPARENADEFENDERLISTSYNCS_LEFTTIME_FIELD.number = 3
HPARENADEFENDERLISTSYNCS_LEFTTIME_FIELD.index = 2
HPARENADEFENDERLISTSYNCS_LEFTTIME_FIELD.label = 2
HPARENADEFENDERLISTSYNCS_LEFTTIME_FIELD.has_default_value = false
HPARENADEFENDERLISTSYNCS_LEFTTIME_FIELD.default_value = 0
HPARENADEFENDERLISTSYNCS_LEFTTIME_FIELD.type = 5
HPARENADEFENDERLISTSYNCS_LEFTTIME_FIELD.cpp_type = 1

HPARENADEFENDERLISTSYNCS.name = "HPArenaDefenderListSyncS"
HPARENADEFENDERLISTSYNCS.full_name = ".HPArenaDefenderListSyncS"
HPARENADEFENDERLISTSYNCS.nested_types = {}
HPARENADEFENDERLISTSYNCS.enum_types = {}
HPARENADEFENDERLISTSYNCS.fields = {HPARENADEFENDERLISTSYNCS_SELF_FIELD, HPARENADEFENDERLISTSYNCS_DEFENDER_FIELD, HPARENADEFENDERLISTSYNCS_LEFTTIME_FIELD}
HPARENADEFENDERLISTSYNCS.is_extendable = false
HPARENADEFENDERLISTSYNCS.extensions = {}
HPREPLACEDEFENDERLIST_PLAYERID_FIELD.name = "playerId"
HPREPLACEDEFENDERLIST_PLAYERID_FIELD.full_name = ".HPReplaceDefenderList.playerId"
HPREPLACEDEFENDERLIST_PLAYERID_FIELD.number = 1
HPREPLACEDEFENDERLIST_PLAYERID_FIELD.index = 0
HPREPLACEDEFENDERLIST_PLAYERID_FIELD.label = 2
HPREPLACEDEFENDERLIST_PLAYERID_FIELD.has_default_value = false
HPREPLACEDEFENDERLIST_PLAYERID_FIELD.default_value = 0
HPREPLACEDEFENDERLIST_PLAYERID_FIELD.type = 5
HPREPLACEDEFENDERLIST_PLAYERID_FIELD.cpp_type = 1

HPREPLACEDEFENDERLIST.name = "HPReplaceDefenderList"
HPREPLACEDEFENDERLIST.full_name = ".HPReplaceDefenderList"
HPREPLACEDEFENDERLIST.nested_types = {}
HPREPLACEDEFENDERLIST.enum_types = {}
HPREPLACEDEFENDERLIST.fields = {HPREPLACEDEFENDERLIST_PLAYERID_FIELD}
HPREPLACEDEFENDERLIST.is_extendable = false
HPREPLACEDEFENDERLIST.extensions = {}
HPREPLACEDEFENDERLISTRET_DEFENDER_FIELD.name = "defender"
HPREPLACEDEFENDERLISTRET_DEFENDER_FIELD.full_name = ".HPReplaceDefenderListRet.defender"
HPREPLACEDEFENDERLISTRET_DEFENDER_FIELD.number = 2
HPREPLACEDEFENDERLISTRET_DEFENDER_FIELD.index = 0
HPREPLACEDEFENDERLISTRET_DEFENDER_FIELD.label = 3
HPREPLACEDEFENDERLISTRET_DEFENDER_FIELD.has_default_value = false
HPREPLACEDEFENDERLISTRET_DEFENDER_FIELD.default_value = {}
HPREPLACEDEFENDERLISTRET_DEFENDER_FIELD.message_type = ARENAITEMINFO
HPREPLACEDEFENDERLISTRET_DEFENDER_FIELD.type = 11
HPREPLACEDEFENDERLISTRET_DEFENDER_FIELD.cpp_type = 10

HPREPLACEDEFENDERLISTRET.name = "HPReplaceDefenderListRet"
HPREPLACEDEFENDERLISTRET.full_name = ".HPReplaceDefenderListRet"
HPREPLACEDEFENDERLISTRET.nested_types = {}
HPREPLACEDEFENDERLISTRET.enum_types = {}
HPREPLACEDEFENDERLISTRET.fields = {HPREPLACEDEFENDERLISTRET_DEFENDER_FIELD}
HPREPLACEDEFENDERLISTRET.is_extendable = false
HPREPLACEDEFENDERLISTRET.extensions = {}
HPBUYCHALLENGETIMES_TIMES_FIELD.name = "times"
HPBUYCHALLENGETIMES_TIMES_FIELD.full_name = ".HPBuyChallengeTimes.times"
HPBUYCHALLENGETIMES_TIMES_FIELD.number = 1
HPBUYCHALLENGETIMES_TIMES_FIELD.index = 0
HPBUYCHALLENGETIMES_TIMES_FIELD.label = 2
HPBUYCHALLENGETIMES_TIMES_FIELD.has_default_value = false
HPBUYCHALLENGETIMES_TIMES_FIELD.default_value = 0
HPBUYCHALLENGETIMES_TIMES_FIELD.type = 5
HPBUYCHALLENGETIMES_TIMES_FIELD.cpp_type = 1

HPBUYCHALLENGETIMES.name = "HPBuyChallengeTimes"
HPBUYCHALLENGETIMES.full_name = ".HPBuyChallengeTimes"
HPBUYCHALLENGETIMES.nested_types = {}
HPBUYCHALLENGETIMES.enum_types = {}
HPBUYCHALLENGETIMES.fields = {HPBUYCHALLENGETIMES_TIMES_FIELD}
HPBUYCHALLENGETIMES.is_extendable = false
HPBUYCHALLENGETIMES.extensions = {}
HPBUYCHALLENGETIMESRET_SURPLUSCHALLENGETIMES_FIELD.name = "surplusChallengeTimes"
HPBUYCHALLENGETIMESRET_SURPLUSCHALLENGETIMES_FIELD.full_name = ".HPBuyChallengeTimesRet.surplusChallengeTimes"
HPBUYCHALLENGETIMESRET_SURPLUSCHALLENGETIMES_FIELD.number = 1
HPBUYCHALLENGETIMESRET_SURPLUSCHALLENGETIMES_FIELD.index = 0
HPBUYCHALLENGETIMESRET_SURPLUSCHALLENGETIMES_FIELD.label = 2
HPBUYCHALLENGETIMESRET_SURPLUSCHALLENGETIMES_FIELD.has_default_value = false
HPBUYCHALLENGETIMESRET_SURPLUSCHALLENGETIMES_FIELD.default_value = 0
HPBUYCHALLENGETIMESRET_SURPLUSCHALLENGETIMES_FIELD.type = 5
HPBUYCHALLENGETIMESRET_SURPLUSCHALLENGETIMES_FIELD.cpp_type = 1

HPBUYCHALLENGETIMESRET_ALREADYBUYTIMES_FIELD.name = "alreadyBuyTimes"
HPBUYCHALLENGETIMESRET_ALREADYBUYTIMES_FIELD.full_name = ".HPBuyChallengeTimesRet.alreadyBuyTimes"
HPBUYCHALLENGETIMESRET_ALREADYBUYTIMES_FIELD.number = 3
HPBUYCHALLENGETIMESRET_ALREADYBUYTIMES_FIELD.index = 1
HPBUYCHALLENGETIMESRET_ALREADYBUYTIMES_FIELD.label = 2
HPBUYCHALLENGETIMESRET_ALREADYBUYTIMES_FIELD.has_default_value = false
HPBUYCHALLENGETIMESRET_ALREADYBUYTIMES_FIELD.default_value = 0
HPBUYCHALLENGETIMESRET_ALREADYBUYTIMES_FIELD.type = 5
HPBUYCHALLENGETIMESRET_ALREADYBUYTIMES_FIELD.cpp_type = 1

HPBUYCHALLENGETIMESRET_NEXTBUYPRICE_FIELD.name = "nextBuyPrice"
HPBUYCHALLENGETIMESRET_NEXTBUYPRICE_FIELD.full_name = ".HPBuyChallengeTimesRet.nextBuyPrice"
HPBUYCHALLENGETIMESRET_NEXTBUYPRICE_FIELD.number = 2
HPBUYCHALLENGETIMESRET_NEXTBUYPRICE_FIELD.index = 2
HPBUYCHALLENGETIMESRET_NEXTBUYPRICE_FIELD.label = 2
HPBUYCHALLENGETIMESRET_NEXTBUYPRICE_FIELD.has_default_value = false
HPBUYCHALLENGETIMESRET_NEXTBUYPRICE_FIELD.default_value = 0
HPBUYCHALLENGETIMESRET_NEXTBUYPRICE_FIELD.type = 5
HPBUYCHALLENGETIMESRET_NEXTBUYPRICE_FIELD.cpp_type = 1

HPBUYCHALLENGETIMESRET.name = "HPBuyChallengeTimesRet"
HPBUYCHALLENGETIMESRET.full_name = ".HPBuyChallengeTimesRet"
HPBUYCHALLENGETIMESRET.nested_types = {}
HPBUYCHALLENGETIMESRET.enum_types = {}
HPBUYCHALLENGETIMESRET.fields = {HPBUYCHALLENGETIMESRET_SURPLUSCHALLENGETIMES_FIELD, HPBUYCHALLENGETIMESRET_ALREADYBUYTIMES_FIELD, HPBUYCHALLENGETIMESRET_NEXTBUYPRICE_FIELD}
HPBUYCHALLENGETIMESRET.is_extendable = false
HPBUYCHALLENGETIMESRET.extensions = {}
HPARENARANKINGLIST.name = "HPArenaRankingList"
HPARENARANKINGLIST.full_name = ".HPArenaRankingList"
HPARENARANKINGLIST.nested_types = {}
HPARENARANKINGLIST.enum_types = {}
HPARENARANKINGLIST.fields = {}
HPARENARANKINGLIST.is_extendable = false
HPARENARANKINGLIST.extensions = {}
HPARENARANKINGLISTRET_SELF_FIELD.name = "self"
HPARENARANKINGLISTRET_SELF_FIELD.full_name = ".HPArenaRankingListRet.self"
HPARENARANKINGLISTRET_SELF_FIELD.number = 1
HPARENARANKINGLISTRET_SELF_FIELD.index = 0
HPARENARANKINGLISTRET_SELF_FIELD.label = 2
HPARENARANKINGLISTRET_SELF_FIELD.has_default_value = false
HPARENARANKINGLISTRET_SELF_FIELD.default_value = nil
HPARENARANKINGLISTRET_SELF_FIELD.message_type = ARENAITEMINFO
HPARENARANKINGLISTRET_SELF_FIELD.type = 11
HPARENARANKINGLISTRET_SELF_FIELD.cpp_type = 10

HPARENARANKINGLISTRET_RANKINFO_FIELD.name = "rankInfo"
HPARENARANKINGLISTRET_RANKINFO_FIELD.full_name = ".HPArenaRankingListRet.rankInfo"
HPARENARANKINGLISTRET_RANKINFO_FIELD.number = 2
HPARENARANKINGLISTRET_RANKINFO_FIELD.index = 1
HPARENARANKINGLISTRET_RANKINFO_FIELD.label = 3
HPARENARANKINGLISTRET_RANKINFO_FIELD.has_default_value = false
HPARENARANKINGLISTRET_RANKINFO_FIELD.default_value = {}
HPARENARANKINGLISTRET_RANKINFO_FIELD.message_type = ARENAITEMINFO
HPARENARANKINGLISTRET_RANKINFO_FIELD.type = 11
HPARENARANKINGLISTRET_RANKINFO_FIELD.cpp_type = 10

HPARENARANKINGLISTRET.name = "HPArenaRankingListRet"
HPARENARANKINGLISTRET.full_name = ".HPArenaRankingListRet"
HPARENARANKINGLISTRET.nested_types = {}
HPARENARANKINGLISTRET.enum_types = {}
HPARENARANKINGLISTRET.fields = {HPARENARANKINGLISTRET_SELF_FIELD, HPARENARANKINGLISTRET_RANKINFO_FIELD}
HPARENARANKINGLISTRET.is_extendable = false
HPARENARANKINGLISTRET.extensions = {}
HPCHALLENGEDEFENDER_DEFENDERANK_FIELD.name = "defendeRank"
HPCHALLENGEDEFENDER_DEFENDERANK_FIELD.full_name = ".HPChallengeDefender.defendeRank"
HPCHALLENGEDEFENDER_DEFENDERANK_FIELD.number = 1
HPCHALLENGEDEFENDER_DEFENDERANK_FIELD.index = 0
HPCHALLENGEDEFENDER_DEFENDERANK_FIELD.label = 2
HPCHALLENGEDEFENDER_DEFENDERANK_FIELD.has_default_value = false
HPCHALLENGEDEFENDER_DEFENDERANK_FIELD.default_value = 0
HPCHALLENGEDEFENDER_DEFENDERANK_FIELD.type = 5
HPCHALLENGEDEFENDER_DEFENDERANK_FIELD.cpp_type = 1

HPCHALLENGEDEFENDER_MONSTERID_FIELD.name = "monsterId"
HPCHALLENGEDEFENDER_MONSTERID_FIELD.full_name = ".HPChallengeDefender.monsterId"
HPCHALLENGEDEFENDER_MONSTERID_FIELD.number = 2
HPCHALLENGEDEFENDER_MONSTERID_FIELD.index = 1
HPCHALLENGEDEFENDER_MONSTERID_FIELD.label = 2
HPCHALLENGEDEFENDER_MONSTERID_FIELD.has_default_value = false
HPCHALLENGEDEFENDER_MONSTERID_FIELD.default_value = 0
HPCHALLENGEDEFENDER_MONSTERID_FIELD.type = 5
HPCHALLENGEDEFENDER_MONSTERID_FIELD.cpp_type = 1

HPCHALLENGEDEFENDER_PLAYERID_FIELD.name = "playerId"
HPCHALLENGEDEFENDER_PLAYERID_FIELD.full_name = ".HPChallengeDefender.playerId"
HPCHALLENGEDEFENDER_PLAYERID_FIELD.number = 3
HPCHALLENGEDEFENDER_PLAYERID_FIELD.index = 2
HPCHALLENGEDEFENDER_PLAYERID_FIELD.label = 1
HPCHALLENGEDEFENDER_PLAYERID_FIELD.has_default_value = false
HPCHALLENGEDEFENDER_PLAYERID_FIELD.default_value = 0
HPCHALLENGEDEFENDER_PLAYERID_FIELD.type = 5
HPCHALLENGEDEFENDER_PLAYERID_FIELD.cpp_type = 1

HPCHALLENGEDEFENDER.name = "HPChallengeDefender"
HPCHALLENGEDEFENDER.full_name = ".HPChallengeDefender"
HPCHALLENGEDEFENDER.nested_types = {}
HPCHALLENGEDEFENDER.enum_types = {}
HPCHALLENGEDEFENDER.fields = {HPCHALLENGEDEFENDER_DEFENDERANK_FIELD, HPCHALLENGEDEFENDER_MONSTERID_FIELD, HPCHALLENGEDEFENDER_PLAYERID_FIELD}
HPCHALLENGEDEFENDER.is_extendable = false
HPCHALLENGEDEFENDER.extensions = {}
HPCHALLENGEDEFENDERRET_CHALLENGERESULT_FIELD.name = "challengeResult"
HPCHALLENGEDEFENDERRET_CHALLENGERESULT_FIELD.full_name = ".HPChallengeDefenderRet.challengeResult"
HPCHALLENGEDEFENDERRET_CHALLENGERESULT_FIELD.number = 1
HPCHALLENGEDEFENDERRET_CHALLENGERESULT_FIELD.index = 0
HPCHALLENGEDEFENDERRET_CHALLENGERESULT_FIELD.label = 2
HPCHALLENGEDEFENDERRET_CHALLENGERESULT_FIELD.has_default_value = false
HPCHALLENGEDEFENDERRET_CHALLENGERESULT_FIELD.default_value = 0
HPCHALLENGEDEFENDERRET_CHALLENGERESULT_FIELD.type = 5
HPCHALLENGEDEFENDERRET_CHALLENGERESULT_FIELD.cpp_type = 1

HPCHALLENGEDEFENDERRET_PREOFCHALLENGERANK_FIELD.name = "preOfChallengeRank"
HPCHALLENGEDEFENDERRET_PREOFCHALLENGERANK_FIELD.full_name = ".HPChallengeDefenderRet.preOfChallengeRank"
HPCHALLENGEDEFENDERRET_PREOFCHALLENGERANK_FIELD.number = 2
HPCHALLENGEDEFENDERRET_PREOFCHALLENGERANK_FIELD.index = 1
HPCHALLENGEDEFENDERRET_PREOFCHALLENGERANK_FIELD.label = 2
HPCHALLENGEDEFENDERRET_PREOFCHALLENGERANK_FIELD.has_default_value = false
HPCHALLENGEDEFENDERRET_PREOFCHALLENGERANK_FIELD.default_value = 0
HPCHALLENGEDEFENDERRET_PREOFCHALLENGERANK_FIELD.type = 5
HPCHALLENGEDEFENDERRET_PREOFCHALLENGERANK_FIELD.cpp_type = 1

HPCHALLENGEDEFENDERRET_AFTEROFCHALLENGERANK_FIELD.name = "afterOfChallengeRank"
HPCHALLENGEDEFENDERRET_AFTEROFCHALLENGERANK_FIELD.full_name = ".HPChallengeDefenderRet.afterOfChallengeRank"
HPCHALLENGEDEFENDERRET_AFTEROFCHALLENGERANK_FIELD.number = 3
HPCHALLENGEDEFENDERRET_AFTEROFCHALLENGERANK_FIELD.index = 2
HPCHALLENGEDEFENDERRET_AFTEROFCHALLENGERANK_FIELD.label = 2
HPCHALLENGEDEFENDERRET_AFTEROFCHALLENGERANK_FIELD.has_default_value = false
HPCHALLENGEDEFENDERRET_AFTEROFCHALLENGERANK_FIELD.default_value = 0
HPCHALLENGEDEFENDERRET_AFTEROFCHALLENGERANK_FIELD.type = 5
HPCHALLENGEDEFENDERRET_AFTEROFCHALLENGERANK_FIELD.cpp_type = 1

HPCHALLENGEDEFENDERRET.name = "HPChallengeDefenderRet"
HPCHALLENGEDEFENDERRET.full_name = ".HPChallengeDefenderRet"
HPCHALLENGEDEFENDERRET.nested_types = {}
HPCHALLENGEDEFENDERRET.enum_types = {}
HPCHALLENGEDEFENDERRET.fields = {HPCHALLENGEDEFENDERRET_CHALLENGERESULT_FIELD, HPCHALLENGEDEFENDERRET_PREOFCHALLENGERANK_FIELD, HPCHALLENGEDEFENDERRET_AFTEROFCHALLENGERANK_FIELD}
HPCHALLENGEDEFENDERRET.is_extendable = false
HPCHALLENGEDEFENDERRET.extensions = {}
HPRECORDMAXARENAMAILID_MAXMAILID_FIELD.name = "maxMailId"
HPRECORDMAXARENAMAILID_MAXMAILID_FIELD.full_name = ".HPRecordMaxArenaMailId.maxMailId"
HPRECORDMAXARENAMAILID_MAXMAILID_FIELD.number = 1
HPRECORDMAXARENAMAILID_MAXMAILID_FIELD.index = 0
HPRECORDMAXARENAMAILID_MAXMAILID_FIELD.label = 2
HPRECORDMAXARENAMAILID_MAXMAILID_FIELD.has_default_value = false
HPRECORDMAXARENAMAILID_MAXMAILID_FIELD.default_value = 0
HPRECORDMAXARENAMAILID_MAXMAILID_FIELD.type = 5
HPRECORDMAXARENAMAILID_MAXMAILID_FIELD.cpp_type = 1

HPRECORDMAXARENAMAILID.name = "HPRecordMaxArenaMailId"
HPRECORDMAXARENAMAILID.full_name = ".HPRecordMaxArenaMailId"
HPRECORDMAXARENAMAILID.nested_types = {}
HPRECORDMAXARENAMAILID.enum_types = {}
HPRECORDMAXARENAMAILID.fields = {HPRECORDMAXARENAMAILID_MAXMAILID_FIELD}
HPRECORDMAXARENAMAILID.is_extendable = false
HPRECORDMAXARENAMAILID.extensions = {}
HPARENACHALLENGEREPORTRES_BATTLEINFO_FIELD.name = "battleInfo"
HPARENACHALLENGEREPORTRES_BATTLEINFO_FIELD.full_name = ".HPArenaChallengeReportRes.battleInfo"
HPARENACHALLENGEREPORTRES_BATTLEINFO_FIELD.number = 1
HPARENACHALLENGEREPORTRES_BATTLEINFO_FIELD.index = 0
HPARENACHALLENGEREPORTRES_BATTLEINFO_FIELD.label = 1
HPARENACHALLENGEREPORTRES_BATTLEINFO_FIELD.has_default_value = false
HPARENACHALLENGEREPORTRES_BATTLEINFO_FIELD.default_value = nil
HPARENACHALLENGEREPORTRES_BATTLEINFO_FIELD.message_type = Battle_pb.BattleInfo
HPARENACHALLENGEREPORTRES_BATTLEINFO_FIELD.type = 11
HPARENACHALLENGEREPORTRES_BATTLEINFO_FIELD.cpp_type = 10

HPARENACHALLENGEREPORTRES_VERSION_FIELD.name = "version"
HPARENACHALLENGEREPORTRES_VERSION_FIELD.full_name = ".HPArenaChallengeReportRes.version"
HPARENACHALLENGEREPORTRES_VERSION_FIELD.number = 2
HPARENACHALLENGEREPORTRES_VERSION_FIELD.index = 1
HPARENACHALLENGEREPORTRES_VERSION_FIELD.label = 1
HPARENACHALLENGEREPORTRES_VERSION_FIELD.has_default_value = true
HPARENACHALLENGEREPORTRES_VERSION_FIELD.default_value = 1
HPARENACHALLENGEREPORTRES_VERSION_FIELD.type = 5
HPARENACHALLENGEREPORTRES_VERSION_FIELD.cpp_type = 1

HPARENACHALLENGEREPORTRES.name = "HPArenaChallengeReportRes"
HPARENACHALLENGEREPORTRES.full_name = ".HPArenaChallengeReportRes"
HPARENACHALLENGEREPORTRES.nested_types = {}
HPARENACHALLENGEREPORTRES.enum_types = {}
HPARENACHALLENGEREPORTRES.fields = {HPARENACHALLENGEREPORTRES_BATTLEINFO_FIELD, HPARENACHALLENGEREPORTRES_VERSION_FIELD}
HPARENACHALLENGEREPORTRES.is_extendable = false
HPARENACHALLENGEREPORTRES.extensions = {}
HPARENAREPORTREQ_REPORTID_FIELD.name = "reportId"
HPARENAREPORTREQ_REPORTID_FIELD.full_name = ".HPArenaReportReq.reportId"
HPARENAREPORTREQ_REPORTID_FIELD.number = 1
HPARENAREPORTREQ_REPORTID_FIELD.index = 0
HPARENAREPORTREQ_REPORTID_FIELD.label = 2
HPARENAREPORTREQ_REPORTID_FIELD.has_default_value = false
HPARENAREPORTREQ_REPORTID_FIELD.default_value = 0
HPARENAREPORTREQ_REPORTID_FIELD.type = 5
HPARENAREPORTREQ_REPORTID_FIELD.cpp_type = 1

HPARENAREPORTREQ.name = "HPArenaReportReq"
HPARENAREPORTREQ.full_name = ".HPArenaReportReq"
HPARENAREPORTREQ.nested_types = {}
HPARENAREPORTREQ.enum_types = {}
HPARENAREPORTREQ.fields = {HPARENAREPORTREQ_REPORTID_FIELD}
HPARENAREPORTREQ.is_extendable = false
HPARENAREPORTREQ.extensions = {}

ArenaItemInfo = protobuf.Message(ARENAITEMINFO)
ArenaRoleInfo = protobuf.Message(ARENAROLEINFO)
HPArenaChallengeReportRes = protobuf.Message(HPARENACHALLENGEREPORTRES)
HPArenaDefenderList = protobuf.Message(HPARENADEFENDERLIST)
HPArenaDefenderListSyncS = protobuf.Message(HPARENADEFENDERLISTSYNCS)
HPArenaRankingList = protobuf.Message(HPARENARANKINGLIST)
HPArenaRankingListRet = protobuf.Message(HPARENARANKINGLISTRET)
HPArenaReportReq = protobuf.Message(HPARENAREPORTREQ)
HPBuyChallengeTimes = protobuf.Message(HPBUYCHALLENGETIMES)
HPBuyChallengeTimesRet = protobuf.Message(HPBUYCHALLENGETIMESRET)
HPChallengeDefender = protobuf.Message(HPCHALLENGEDEFENDER)
HPChallengeDefenderRet = protobuf.Message(HPCHALLENGEDEFENDERRET)
HPRecordMaxArenaMailId = protobuf.Message(HPRECORDMAXARENAMAILID)
HPReplaceDefenderList = protobuf.Message(HPREPLACEDEFENDERLIST)
HPReplaceDefenderListRet = protobuf.Message(HPREPLACEDEFENDERLISTRET)

