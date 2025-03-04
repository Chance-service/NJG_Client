// Generated by the protocol buffer compiler.  DO NOT EDIT!
// source: Status.proto

#define INTERNAL_SUPPRESS_PROTOBUF_FIELD_DEPRECATION
#include "Status.pb.h"

#include <algorithm>

#include <google/protobuf/stubs/common.h>
#include <google/protobuf/stubs/once.h>
#include <google/protobuf/io/coded_stream.h>
#include <google/protobuf/wire_format_lite_inl.h>
#include <google/protobuf/descriptor.h>
#include <google/protobuf/generated_message_reflection.h>
#include <google/protobuf/reflection_ops.h>
#include <google/protobuf/wire_format.h>
// @@protoc_insertion_point(includes)

namespace {

const ::google::protobuf::EnumDescriptor* error_descriptor_ = NULL;

}  // namespace


void protobuf_AssignDesc_Status_2eproto() {
  protobuf_AddDesc_Status_2eproto();
  const ::google::protobuf::FileDescriptor* file =
    ::google::protobuf::DescriptorPool::generated_pool()->FindFileByName(
      "Status.proto");
  GOOGLE_CHECK(file != NULL);
  error_descriptor_ = file->enum_type(0);
}

namespace {

GOOGLE_PROTOBUF_DECLARE_ONCE(protobuf_AssignDescriptors_once_);
inline void protobuf_AssignDescriptorsOnce() {
  ::google::protobuf::GoogleOnceInit(&protobuf_AssignDescriptors_once_,
                 &protobuf_AssignDesc_Status_2eproto);
}

void protobuf_RegisterTypes(const ::std::string&) {
  protobuf_AssignDescriptorsOnce();
}

}  // namespace

void protobuf_ShutdownFile_Status_2eproto() {
}

void protobuf_AddDesc_Status_2eproto() {
  static bool already_here = false;
  if (already_here) return;
  already_here = true;
  GOOGLE_PROTOBUF_VERIFY_VERSION;

  ::google::protobuf::DescriptorPool::InternalAddGeneratedFile(
    "\n\014Status.proto*\377[\n\005error\022\020\n\014CONFIG_ERROR"
    "\020\001\022\024\n\020ONLINE_MAX_LIMIT\020\002\022\026\n\022REGISTER_MAX"
    "_LIMIT\020\003\022\030\n\024PLAYER_CREATE_FAILED\020\004\022\022\n\016PL"
    "AYER_KICKOUT\020\005\022\023\n\017MAIN_ROLE_EXIST\020\006\022\023\n\017R"
    "OLE_NAME_EXIST\020\007\022\026\n\022CREATE_ROLE_FAILED\020\010"
    "\022\025\n\021SERVER_GRAY_STATE\020\t\022\022\n\016PARAMS_INVALI"
    "D\020\n\022\024\n\020CONFIG_NOT_FOUND\020\013\022\022\n\016DATA_NOT_FO"
    "UND\020\014\022\024\n\020COINS_NOT_ENOUGH\020\r\022\023\n\017GOLD_NOT_"
    "ENOUGH\020\016\022\024\n\020PLAYER_FORBIDDEN\020\017\022\022\n\016VIP_NO"
    "T_ENOUGH\020\020\022\024\n\020PLAYER_NOT_FOUND\020\021\022\025\n\021HORN"
    "OR_NOT_ENOUGH\020\022\022\023\n\017LEVEL_NOT_LIMIT\020\023\022\031\n\025"
    "REPUTATION_NOT_ENOUGH\020\024\022\027\n\023MERCENARY_NOT"
    "_FOUND\020\025\022\032\n\026CLIENT_VERSION_NOT_FIT\020\026\022\026\n\022"
    "ELEMENT_NOI_ENOUGH\020\027\022\031\n\025RECHARGE_CDK_ONL"
    "Y_APP\020\030\022\026\n\022CRYSTAL_NOT_ENOUGH\020\031\022\026\n\022FEATH"
    "ER_NOI_ENOUGH\020\032\022\034\n\030SMALL_FEATHER_NOT_ENO"
    "UGH\020\033\022\022\n\016ROLE_MAX_LEVEL\020\034\022\022\n\016ROLE_MAX_FI"
    "GHT\020\035\022\033\n\027ROLE_BAPTIZE_ATTR_ERROR\020\036\022\021\n\rRO"
    "LE_MAX_STAR\020\037\022\021\n\rROLE_MAX_RANK\020 \022\024\n\020ROLE"
    "_NO_ALLIANCE\020!\022\022\n\016REGISTER_EXIST\020\"\022\026\n\022RE"
    "GISTER_NOT_EXIST\020#\022\022\n\016PASSWORD_ERROR\020$\022\024"
    "\n\017EQUIP_NOT_FOUND\020\211\'\022\027\n\022EQUIP_MAX_STRENG"
    "TH\020\212\'\022 \n\033EQUIP_PUNCH_MIN_LEVEL_LIMIT\020\213\'\022"
    "\036\n\031EQUIP_PUNCH_PRE_POS_LIMIT\020\214\'\022\034\n\027EQUIP"
    "_PUNCH_POS_PUNCHED\020\215\'\022 \n\033EQUIP_PUNCH_POS"
    "_NOT_PUNCHED\020\216\'\022\030\n\023EQUIP_STONE_DRESSED\020\217"
    "\'\022\034\n\027BAPTIZE_MIN_LEVEL_LIMIT\020\220\'\022\'\n\"EQUIP"
    "_SWALLOW_TARGET_MUST_BE_GODLY\020\221\'\022$\n\037EQUI"
    "P_EXTEND_FROM_NO_GOLDY_ATTR\020\222\'\022#\n\036EQUIP_"
    "EXTEND_TO_GOT_GOLDY_ATTR\020\223\'\022 \n\033EQUIP_GOD"
    "LY_SMELT_NOT_ALLOW\020\224\'\022(\n#EQUIP_CREATE_SM"
    "ELT_VALUE_NOT_ENOUGH\020\225\'\022\035\n\030EQUIP_STRENGT"
    "H_MAX_LEVEL\020\226\'\022\034\n\027ROLE_EQUIP_PART_DRESSE"
    "D\020\227\'\022 \n\033ROLE_EQUIP_PART_NOT_DRESSED\020\230\'\022 "
    "\n\033EQUIP_BAG_EXTEND_TIMES_FULL\020\231\'\022\026\n\021EQUI"
    "P_HAS_DRESSED\020\232\'\022\035\n\030EQUIP_SECONDLY_ATTR_"
    "ZERO\020\233\'\022\033\n\026EQUIP_PROFESSION_LIMIT\020\234\'\022\033\n\026"
    "EQUIP_ROLE_LEVEL_LIMIT\020\235\'\022!\n\034EQUIP_EXTEN"
    "D_SAME_PART_LIMIT\020\236\'\022\025\n\020GODLY_LEVEL_FULL"
    "\020\237\'\022\033\n\026EQUIP_GODLY_SELL_LIMIT\020\240\'\022!\n\034EQUI"
    "P_GEM_QUALITY_SAME_EXIST\020\241\'\022\031\n\024EQUIP_BAG"
    "_EXTEND_SUC\020\242\'\022\035\n\030EQUIP_COMPOUND_NOT_LIM"
    "IT\020\243\'\022\026\n\021ITEM_TYPE_NOT_FIT\020\244\'\022\026\n\021NO_SUIT"
    "_EQUIP_DEC\020\245\'\022\027\n\022NO_GODLY_EQUIP_DEC\020\222\004\022\036"
    "\n\031NO_EQUIP_EVOLUTION_TARGET\020\247\'\022\027\n\022NO_EQU"
    "IP_CAN_SMELT\020\251\'\022\034\n\027EQUIP_CAN_NOT_DECOMPO"
    "SE\020\252\'\022\023\n\016EQUIP_LOCK_MAX\020\253\'\022\025\n\020EQUIP_UNLO"
    "CK_MIN\020\254\'\022\025\n\020EQUIP_NO_ENCHANT\020\255\'\022\032\n\025NO_S"
    "UIT_EQUIP_SWALLOW\020\256\'\022\033\n\026NO_SUIT_EQUIP_CO"
    "MPOUND\020\257\'\022\031\n\024EQUIP_CANNOT_UPGRADE\020\260\'\022\032\n\025"
    "NOT_ENOUGH_ROLE_LEVEL\020\261\'\022\022\n\rEQUIP_HAS_GE"
    "M\020\262\'\022\035\n\030EQUIP_STRENGTH_ZERO_COST\020\263\'\022#\n\036E"
    "QUIP_STRENGTH_NOT_ENOUGH_COST\020\264\'\022\031\n\024EQUI"
    "P_EXTEND_NOT_GEM\020\265\'\022!\n\034EQUIP_EXTEND_OSSE"
    "SS_STRENGTH\020\266\'\022\031\n\024EQUIP_EXTEND_NO_MEET\020\267"
    "\'\022\023\n\016ROLE_NOT_FOUND\020\361.\022\031\n\024ROLE_SKILL_NOT"
    "_FOUND\020\362.\022\024\n\017HAS_NOT_BAPTIZE\020\363.\022\032\n\025STAR_"
    "STONE_NOT_ENOUGH\020\364.\022 \n\033STAR_STONE_TIMES_"
    "NOT_ENOUGH\020\365.\022\032\n\025RING_CONFIG_NOT_FOUND\020\366"
    ".\022\033\n\026ROLE_HAS_NOT_THIS_RING\020\367.\022 \n\033RING_A"
    "CTIVE_NEED_STAR_LIMIT\020\370.\022\024\n\017RING_HAS_ACT"
    "IVE\020\371.\022\032\n\025ROLE_RING_ACTIVE_SUCC\020\372.\022\037\n\032RI"
    "NG_STAR_LEVEL_NOT_ENOUGH\020\373.\022\024\n\017RING_NOT_"
    "ACTIVE\020\374.\022\031\n\024RING_LEVEL_REACH_TOP\020\375.\022 \n\033"
    "ROLE_RING_LVLUP_TIMES_LIMIT\020\376.\022\031\n\024ROLE_R"
    "ING_LVLUP_SUCC\020\377.\022\034\n\027SKILL_NOT_ENHANCE_L"
    "EVEL\020\200/\022\023\n\016ITEM_NOT_FOUND\020\271\027\022\024\n\017ITEM_NOT"
    "_ENOUGH\020\272\027\022\037\n\032ITEM_LEVEL_UP_TARGET_EMPTY"
    "\020\273\027\022\030\n\023ITEM_SELL_NOT_ALLOW\020\274\027\022!\n\034HOUR_CA"
    "RD_USER_COUNT_ONE_DAY\020\275\027\022\033\n\026FIGHT_VALUE_"
    "NOT_ENOUGH\020\301>\022#\n\036DEFENDER_NOT_IN_CHALLEN"
    "GE_LIST\020\302>\022\031\n\024SEE_PLAYER_INFO_FAIL\020\303>\022\027\n"
    "\022NO_CHALLENGE_TIMES\020\304>\022\030\n\023PLEASE_DONT_FU"
    "CK_ME\020\305>\022\035\n\030ARENA_IS_FIGHTING_TARGET\020\306>\022"
    "\032\n\025ARENA_REPORT_NOT_TIME\020\307>\022\027\n\022ALLIANCE_"
    "NAME_NULL\020\251F\022\025\n\020ALLIANCE_NO_MAIN\020\252F\022\025\n\020A"
    "LLIANCE_NO_JOIN\020\253F\022\031\n\024ALLIANCE_NONEXISTE"
    "NT\020\254F\022\032\n\025ALLIANCE_BOSS_ADDPROP\020\255F\022\032\n\025ALL"
    "IANCE_REPORT_ERROR\020\256F\022\035\n\030ALLIANCE_BOSS_O"
    "PEN_ERROR\020\257F\022 \n\033ALLIANCE_BOSS_NO_OPEN_ER"
    "ROR\020\260F\022\034\n\027ALLIANCE_SHOP_BUY_ERROR\020\261F\022\036\n\031"
    "ALLIANCE_NAME_EXIST_ERROR\020\263F\022\036\n\031ALLIANCE"
    "_NOT_CONTRIBUTION\020\264F\022\030\n\023ALLIANCE_EXIT_ER"
    "ROR\020\265F\022\030\n\023ALLIANCE_JOIN_ERROR\020\266F\022\032\n\025ALLI"
    "ANCE_CREATE_ERROR\020\267F\022\037\n\032ALLIANCE_CREATE_"
    "NAME_ERROR\020\270F\022\035\n\030ALLIANCE_FUN_LEVEL_ERRO"
    "R\020\271F\022\030\n\023ALLIANCE_FULL_ERROR\020\272F\022\032\n\025ALLIAN"
    "CE_NOTICE_ERROR\020\273F\022\037\n\032ALLIANCE_BOSS_HARM"
    "_ADD_SUC\020\274F\022\027\n\022BOSS_VITALITY_LACK\020\275F\022\024\n\017"
    "BOSS_OPEN_TIMES\020\276F\022\027\n\022ALLIANCE_TEAM_FULL"
    "\020\215G\022\030\n\023ALLIANCE_TEAM_EXIST\020\216G\022\025\n\020ALREADY"
    "_INVESTED\020\217G\022\027\n\022NO_LAST_STAGE_INFO\020\220G\022\033\n"
    "\026FIGHT_REPORT_NOT_EXIST\020\221G\022\037\n\032ALLIANCE_F"
    "IGHT_COUNT_LIMIT\020\222G\022\033\n\026ALLIANCE_NOT_IN_B"
    "ATTLE\020\223G\022\036\n\031ALLIANCE_BATTLE_NEXT_OPEN\020\224G"
    "\022#\n\036BATTLE_STATE_NOT_ALLOW_INSPIRE\020\225G\022!\n"
    "\034ALLIANCE_BATTLE_INSPIRE_FULL\020\226G\022 \n\033ALLI"
    "ANCE_BATTLE_INSPIRE_SUC\020\227G\022\"\n\035ALLIANCE_B"
    "ATTLE_DRAWTIME_FAIL\020\230G\022\036\n\031ALLIANCE_BATTL"
    "E_DATA_FAIL\020\231G\022!\n\034ALLIANCE_BATTLE_32_DAT"
    "A_FAIL\020\232G\022\037\n\032CHECK_BUTTON_ALLIANCE_FAIL\020"
    "\233G\022\"\n\035CHECK_NO_BUTTON_ALLIANCE_FAIL\020\234G\022\036"
    "\n\031APPLY_ALLIANCE_EXCEED_MAX\020\235G\022\037\n\032REPEAT"
    "_APPLY_ALLIANCE_FAIL\020\236G\022!\n\034NOPRESIDENT_N"
    "OTALLOW_OPERATE\020\237G\022 \n\033PLAYER_INIO_OTHTER"
    "_ALLIANCE\020\240G\022\034\n\027AGAIN_APPLY_ALLIANCE_CD\020"
    "\241G\022\032\n\025ALREADY_INTO_ALLIANCE\020\242G\022 \n\033APPLY_"
    "ADD_ALLIANCE_MAX_FAIL\020\243G\022\031\n\024ALLIANCE_HAD"
    "_DONATED\020\244G\022 \n\033ALLIANCE_NO_ENOUGH_VITALI"
    "TY\020\245G\022%\n ALLIANCE_HAVE_OCCUPY_REVIVEPOIN"
    "T\020\246G\022\037\n\032ALLIANCE_NO_TIME_BUYREVIVE\020\247G\022\033\n"
    "\026ALLIANCE_INVALID_PARAM\020\250G\022\021\n\014SHOP_ITEM_"
    "OK\020\220N\022\030\n\023SHOP_ITEM_NOT_FOUND\020\221N\022\027\n\022SHOP_"
    "BUY_GOLD_LESS\020\222N\022\032\n\025SHOP_REFASH_GOLD_LES"
    "S\020\223N\022\032\n\025SHOP_REFASH_COID_LESS\020\224N\022\025\n\020SHOP"
    "_BUY_COIN_OK\020\232N\022\034\n\027SHOP_BUY_COIN_GOLD_LE"
    "SS\020\233N\022\034\n\027SHOP_BUY_COIN_NUMS_LESS\020\234N\022&\n!B"
    "ATTLE_BOSS_FIGHT_TIME_NOT_ENOUGH\020\371U\022&\n!B"
    "ATTLE_FAST_FIGHT_TIME_NOT_ENOUGH\020\372U\022$\n\037F"
    "AST_FIGHT_BUY_TIMES_NOT_ENOUGH\020\373U\022$\n\037BOS"
    "S_FIGHT_BUY_TIMES_NOT_ENOUGH\020\374U\022\022\n\rMAP_N"
    "OT_EXIST\020\375U\022\025\n\020MAP_HAS_NOT_PASS\020\376U\022+\n&BA"
    "TTLE_ELITE_MAP_FIGHT_TIME_NOT_ENOUGH\020\377U\022"
    "&\n!BATTLE_ELITE_MAP_LIMIT_PROF_ERROR\020\200V\022"
    "\'\n\"BATTLE_ELITE_MAP_LIMIT_LEVEL_ERROR\020\201V"
    "\022&\n!BATTLE_ELITE_MAP_DEPEND_MAP_ERROR\020\202V"
    "\022#\n\036ELITE_MAP_BUY_TIMES_NOT_ENOUGH\020\203V\022#\n"
    "\035BATTLE_FAST_FIGHT_TIME_IS_MAX\020\271\205\006\022\030\n\023NO"
    "T_IN_ARENA_BATTLE\020\204V\022\033\n\026NOT_IN_PVE_BOSS_"
    "BATTLE\020\205V\022\030\n\023MISSION_BONUS_ERROR\020\341]\022#\n\036D"
    "AILY_NEWSER_GIFT_REWARD_LIMIT\020\342]\022!\n\034CAN_"
    "NOT_ACCOUNT_BOUND_REWARD\020\343]\022\023\n\016MAIL_NOT_"
    "FOUND\020\311e\022\025\n\020MAIL_CANNOT_READ\020\312e\022\027\n\022MAIL_"
    "CONTENT_COUNT\020\313e\022\030\n\023MAIL_SEND_NUM_ERROR\020"
    "\314e\022\026\n\021MAIL_SEND_SUCCESS\020\315e\022\022\n\rNO_PLAYER_"
    "MSG\020\261m\022\020\n\013CAN_NOT_MSG\020\262m\022\025\n\020DONT_MSG_TO_"
    "SELF\020\263m\022\030\n\023YOU_ARE_NOT_CAPTAIN\020\231u\022\024\n\017ALR"
    "EADY_IN_TEAM\020\232u\022\037\n\032TEAM_BATTLE_NOT_IN_PR"
    "EPARE\020\233u\022\030\n\023TEAM_BATTLE_STARTED\020\234u\022\037\n\032FE"
    "TCH_RECHARGE_LIST_FAILED\020\201}\022\027\n\021FRIEND_CO"
    "UNT_FULL\020\351\204\001\022\023\n\rTARGET_SHIELD\020\352\204\001\022#\n\035DAI"
    "LY_SEND_PLAYER_COUNT_LIMIT\020\353\204\001\022\026\n\020SHIELD"
    "_LIST_FULL\020\354\204\001\022\027\n\021ALREADY_ASKTICKET\020\355\204\001\022"
    "\024\n\016ALREADY_FRIEND\020\356\204\001\022\035\n\027FRIEND_APPLY_CO"
    "UNT_FULL\020\357\204\001\022\032\n\024ALREADY_APPLY_FRIEND\020\360\204\001"
    "\022\033\n\025ASKTICKET_COUNT_LIMIT\020\376\303\006\022\027\n\021FRIEND_"
    "IS_OFFLINE\020\377\303\006\022\032\n\024NOT_EXISTS_PROF_TYPE\020\321"
    "\214\001\022\026\n\020CAMPWAR_NOT_OPEN\020\211\244\001\022\032\n\024ALREADY_JO"
    "IN_CAMPWAR\020\212\244\001\022\035\n\027ENTER_BATTLE_FIELD_FAI"
    "L\020\213\244\001\022\026\n\020NOT_JOIN_CAMPWAR\020\214\244\001\022\031\n\023MAX_CAM"
    "PWAR_INSPIRE\020\215\244\001\022\034\n\026AUTO_CAMPWAR_GOLD_LA"
    "CK\020\216\244\001\022\027\n\021BOSS_ALREADY_DEAD\020\331\263\001\022\023\n\rBOSS_"
    "NOT_OPEN\020\332\263\001\022\025\n\017BOSS_REBIRTH_CD\020\333\263\001\022\032\n\024B"
    "OSS_NOT_RANDOM_BUFF\020\334\263\001\022\022\n\014BOSS_IS_OPEN\020"
    "\335\263\001\022\023\n\rKICK_OUT_ROOM\020\251\303\001\022\036\n\030MAX_MULTIELI"
    "TE_BUY_TIMES\020\252\303\001\022\033\n\025MULTIELITE_SCORE_LAC"
    "K\020\253\303\001\022\031\n\023MULTIELITE_CFG_NULL\020\254\303\001\022\025\n\017ALRE"
    "ADY_IN_ROOM\020\255\303\001\022\023\n\rWAITROOM_NULL\020\256\303\001\022\017\n\t"
    "ROOM_FULL\020\257\303\001\022\025\n\017IS_NOT_LANDLORD\020\260\303\001\022\021\n\013"
    "NOT_IN_ROOM\020\261\303\001\022\031\n\023ALREADY_POST_INVITE\020\262"
    "\303\001\022\024\n\016NO_CAN_IN_ROOM\020\263\303\001\022\030\n\022HISTORY_SCOR"
    "E_LACK\020\264\303\001\022\032\n\024ALREADY_START_BATTLE\020\265\303\001\022\026"
    "\n\020SERVER_ROOM_FULL\020\266\303\001\022\031\n\023NO_MULTIELITE_"
    "TIMES\020\267\303\001\022\026\n\020BATTLE_COUNTDOWN\020\270\303\001\022$\n\036NOT"
    "_FOUND_CAN_HIRE_PLAYER_DATA\020\271\303\001\022\035\n\027CAN_N"
    "OT_HIRE_THE_PLAYER\020\272\303\001\022\035\n\027THE_PLAYER_ALR"
    "EADY_HIRE\020\273\303\001\022\034\n\026MEMBER_ALREADY_IN_ROOM\020"
    "\274\303\001\022\034\n\026NOT_MULTI_ELITE_SETOUT\020\275\303\001\022\032\n\024MUL"
    "TI_ELITE_IS_CLOSE\020\276\303\001\022\033\n\025MULTI_ELITE_HAV"
    "E_TEAM\020\277\303\001\022!\n\033MULTI_ELITE_LEVEL_NOT_LIMI"
    "T\020\300\303\001\022!\n\033MULTI_ELITE_FRIEND_NO_TIMES\020\301\303\001"
    "\022 \n\032MULTI_ELITE_WRONG_PASSWORD\020\302\303\001\022\037\n\031CR"
    "OSS_SERVER_CONNECT_FAIL\020\221\313\001\022\024\n\016NO_FIGHT_"
    "TIMES\020\222\313\001\022\034\n\026BUY_BATTLE_TIMES_LIMIT\020\223\313\001\022"
    "\033\n\025CROSSCOINS_NOT_ENOUGH\020\224\313\001\022\031\n\023BATTLE_D"
    "ATA_INVALID\020\225\313\001\022\025\n\017SYNC_TIME_LIMIT\020\226\313\001\022\034"
    "\n\026ELEMENT_BAG_EXTEND_SUC\020\371\322\001\022\022\n\014PROF_NOT"
    "_FIT\020\372\322\001\022$\n\036ELEMENT_NOT_GREATE_THAN_PLAY"
    "ER\020\373\322\001\022\027\n\021ELEMENT_SIZE_NONE\020\374\322\001\022 \n\032NOT_A"
    "BLE_TO_CHALLENGE_BOSS\020\341\332\001\022\031\n\023NOT_REBIRTH"
    "_SUCCESS\020\342\332\001\022\035\n\027NOT_ENOUGH_FOR_LEVEL_UP\020"
    "\343\332\001\022\032\n\024NOT_LEVEL_OVER_LIMIT\020\344\332\001\022\035\n\027TALEN"
    "T_LEVEL_OVER_BOUND\020\345\332\001\022\036\n\030NOT_ABLE_TO_RE"
    "BIRTH_BOSS\020\346\332\001\022\027\n\021FEATHER_SIZE_NONE\020\347\332\001\022"
    "\034\n\026FEATHER_BAG_EXTEND_SUC\020\200\323\001\022\031\n\023NOT_ENO"
    "UGH_RECHARGE\020\261\352\001\022\021\n\013COUNT_ERROR\020\262\352\001\022\027\n\021T"
    "OKEN_LEVEL_LIMIT\020\231\362\001\022\032\n\024TOKEN_ENTITY_NOE"
    "XIST\020\232\362\001\022\034\n\026TOKEN_TASK_COUNT_LIMIT\020\233\362\001\022\027"
    "\n\021WING_LEAD_HAD_GOT\020\201\372\001\022\033\n\025WING_LEAD_GET"
    "_SUCCESS\020\202\372\001\022\030\n\022GVG_FUNCTION_CLOSE\020\351\201\002\022\022"
    "\n\014DECLARED_WAR\020\352\201\002\022\032\n\024NOT_ALLIANCE_MEMBE"
    "RS\020\353\201\002\022\027\n\021NOT_DECLARE_TIMES\020\354\201\002\022\027\n\021NOT_D"
    "ECLARE_PWOER\020\355\201\002\022\031\n\023CANNOT_DECLARED_WAR\020"
    "\356\201\002\022\024\n\016NOT_CHAIN_CITY\020\357\201\002\022\025\n\017NOT_CITY_RE"
    "WARD\020\360\201\002\022\033\n\025NOT_ENOUGH_COUNT_CITY\020\361\201\002\022\026\n"
    "\020NOT_DECLARED_WAR\020\362\201\002\022\025\n\017NOT_OCCUPY_CITY"
    "\020\363\201\002\022 \n\032NOT_DECLARED_BATTEL_STATUS\020\364\201\002\022\031"
    "\n\023NOT_STATUS_FIGHTING\020\365\201\002\022\024\n\016NOT_SEND_RO"
    "LDE\020\366\201\002\022\021\n\013ROLE_IN_USE\020\367\201\002\022\026\n\020NOT_ENOUGH"
    "_PWOER\020\370\201\002\022\021\n\013NOT_MY_CITY\020\371\201\002\022\026\n\020SEND_RO"
    "LDE_LIMIT\020\372\201\002\022\023\n\rGIFT_REWARDED\020\373\201\002\022\022\n\014NO"
    "T_CAN_JOIN\020\374\201\002\022\027\n\021MAIN_NOT_CAN_JOIN\020\375\201\002\022"
    "\033\n\025NEW_ROLE_NOT_CAN_JOIN\020\376\201\002\022\024\n\016GVG_PLAY"
    "_CLOSE\020\377\201\002\022\030\n\022FIGHTBACK_OVERTIME\020\200\202\002\022\023\n\r"
    "NOT_FIGHTBACK\020\201\202\002\022\027\n\021FIGHTBACK_PROTECT\020\202"
    "\202\002\022\035\n\027JOIN_ALLIANCE_AFTER_GVG\020\203\202\002\022*\n$NOT"
    "_CAN_EXCEED_ONETEAM_LESSTHANTHREE\020\204\202\002\022(\n"
    "\"NOT_CAN_EXCEED_ONETEAM_LESSTHANTWO\020\205\202\002\022"
    "\036\n\030NOT_HAVE_ENOUGH_VITALITY\020\207\202\002\022\033\n\025NOT_S"
    "TATION_SELF_CITY\020\210\202\002\022\032\n\024BRAVE_ENTITY_NOE"
    "XIST\020\321\211\002\022\027\n\021BRAVE_ENTITY_PASS\020\322\211\002\022\"\n\034BRA"
    "VE_RESET_COUNT_NOT_ENOUGH\020\323\211\002\022$\n\036BRAVE_I"
    "NSPIRE_COUNT_NOT_ENOUGH\020\324\211\002\022\016\n\010BRAVE_CD\020"
    "\325\211\002\022\017\n\tBRAVE_BAN\020\326\211\002\022\034\n\026BRAVE_COUNT_NOT_"
    "ENOUGH\020\327\211\002\022\035\n\027STAR_SOUL_GROUP_ILLEGAL\020\271\221"
    "\002\022\035\n\027STAR_SOUL_LEVEL_ILLEGAL\020\272\221\002\022\031\n\023NO_M"
    "ONTH_CARD_EXIST\020\345\361\004\022\030\n\022MONTH_CARD_BUY_SU"
    "C\020\346\361\004\022!\n\033MONTH_CARD_BUY_CONTINUE_SUC\020\347\361\004"
    "\022\024\n\016ACTIVITY_CLOSE\020\350\361\004\022\022\n\014ACTIVITY_END\020\351"
    "\361\004\022\027\n\021RECHARGE_NUM_LACK\020\352\361\004\022\035\n\027ACTIVITY_"
    "AWARDS_HAS_GOT\020\353\361\004\022\033\n\025ACC_CONSUME_NOT_RE"
    "ACH\020\354\361\004\022\027\n\021DAYLI_TIMES_LIMIT\020\355\361\004\022 \n\032RECH"
    "ARGE_STATUS_NOT_FINISH\020\356\361\004\022\026\n\020TODAY_REBA"
    "TE_GOT\020\357\361\004\022\023\n\rWEEK_CARD_SUC\020\225\373\004\022\022\n\014NO_WE"
    "EK_CARD\020\226\373\004\022\036\n\030WEEK_CARD_CANNOT_LEVELUP\020"
    "\227\373\004\022\034\n\026WEEK_CARD_LEVELUP_SUCC\020\230\373\004\022&\n TIM"
    "E_LIMIT_TODAY_BUY_TIMES_LIMIT\020\335\374\004\022-\n\'SER"
    "VER_TIME_LIMIT_TODAY_BUY_TIMES_LIMIT\020\336\374\004"
    "\022$\n\036TIME_LIMIT_ALL_BUY_TIMES_LIMIT\020\337\374\004\022+"
    "\n%SERVER_TIME_LIMIT_ALL_BUY_TIMES_LIMIT\020"
    "\340\374\004\022\031\n\023ACC_LOGIN_DAYS_LACK\020\301\375\004\022\027\n\021GEM_CF"
    "G_NOT_EXIST\020\245\376\004\022\031\n\023GEM_LEVEL_NOT_EQUAL\020\246"
    "\376\004\022\033\n\025GEM_COMPOUND_CFG_NULL\020\247\376\004\022\031\n\023GEM_E"
    "MBED_NOT_EQUIP\020\250\376\004\022&\n GEM_COMPOUND_RESOU"
    "RCE_NOT_ENOUGH\020\251\376\004\022*\n$GEM_COMPOUND_PLAYE"
    "R_LEVEL_NOT_ENOUGH\020\252\376\004\022\034\n\026GEM_EXCHANGE_E"
    "XCEPTION\020\253\376\004\022\031\n\023BUYCOUNT_NOT_ENOUGH\020\254\376\004\022"
    "\033\n\025GEM_VOLUME_NOT_ENOUGH\020\255\376\004\022\035\n\027GEM_VOLU"
    "ME_NOT_SHOP_BUY\020\256\376\004\022\031\n\023ROULETTE_TIMES_LA"
    "CK\020\211\377\004\022\033\n\025ROULETTE_CREDITS_LACK\020\212\377\004\022\037\n\031I"
    "NVITE_FRIEND_AMOUNT_LUCK\020\355\377\004\022\030\n\022EXCHANGE"
    "_CODE_FAIL\020\356\377\004\022\024\n\016TAXI_KEY_ERROR\020\357\377\004\022\033\n\025"
    "ALREADY_EXCHANGE_CODE\020\360\377\004\022\037\n\031SNOWFIELD_P"
    "HYC_NOT_ENOUTH\020\321\200\005\022\035\n\027SNOWFIELD_CELL_SEA"
    "RCHED\020\322\200\005\022!\n\033SNOWFIELD_ALREADY_EXCHANGED"
    "\020\323\200\005\022\034\n\026SEARCH_TIME_NOT_ENOUTH\020\265\201\005\022\'\n!CO"
    "MMENDATION_USE_COUNT_NOT_ENOUGH\020\231\202\005\022\036\n\030F"
    "ORTUNE_REWARD_TIME_FULL\020\375\202\005\022!\n\033FORTUNE_R"
    "ECHARGE_NOT_ENOUGH\020\376\202\005\022\032\n\024REACH_MAX_GRAB"
    "_TIMES\020\341\203\005\022\037\n\031SERVER_RED_ENVELOPE_EMPTY\020"
    "\342\203\005\022\025\n\017NO_RED_ENVELOPE\020\343\203\005\022!\n\033TODAY_FREE"
    "_RED_ENVELOPE_GOT\020\344\203\005\022\033\n\025CUR_HOUR_ALREAD"
    "Y_GRAB\020\345\203\005\022\034\n\026LIGHT_TIMES_NOT_ENOUGH\020\305\204\005"
    "\022#\n\035CAN_NOT_ACTIVATE_FOREVER_CARD\020\251\205\005\022*\n"
    "$TODAY_ALREADY_GET_FOREVER_CARD_AWARD\020\252\205"
    "\005\022\033\n\025SALE_PACKET_GET_AWARD\020\235\211\005\022\032\n\024VIP_PA"
    "CKET_GET_AWARD\020\236\211\005\022\035\n\027AUCTION_GOLD_NOT_E"
    "NOUGH\020\360\361\004\022\031\n\023AUCTION_PRICE_ERROR\020\361\361\004\022\035\n\027"
    "AUCTION_REFRESH_TIMEOUT\020\362\361\004\022\034\n\026AUCTION_N"
    "EED_MORE_COIN\020\363\361\004\022\024\n\016DISPATCH_COUNT\020\311\362\004\022"
    "\027\n\021TASK_STATUS_ERROR\020\312\362\004\022\027\n\021ROLE_STATUS_"
    "ERROR\020\313\362\004\022\033\n\025TASK_STAR_COUNT_ERROR\020\314\362\004\022\033"
    "\n\025TASK_ROLE_COUNT_ERROR\020\315\362\004\022\031\n\023NOT_ENOUG"
    "H_COST_BUY\020\255\363\004\022\024\n\016ROLE_SOUL_LACK\020\221\364\004\022\027\n\021"
    "FLOWER_NOT_ENOUGH\020\365\364\004\022#\n\035FAIRY_BLESS_PRO"
    "GRESS_COMPLETE\020\366\364\004\022\027\n\021FETTER_IS_ACTIVED\020"
    "\331\365\004\022\027\n\021AVATAR_IS_OVERDUE\020\332\365\004\022\036\n\030BASE_MER"
    "CENARY_NOT_FOUND\020\275\366\004\022\033\n\025BAPTIZE_MAX_ATTR"
    "IBUTE\020\276\366\004\022\027\n\021FIRST_FAST_BATTLE\020\277\366\004\022\031\n\023LO"
    "GIN_VERIFY_FAILED\020\220\277\005\022 \n\032ACC_LOGIN_SIGNE"
    "D_DAYS_LACK\020\241\367\004\022#\n\035ACC_LOGIN_SUPPLSIGNED"
    "_NOTIMES\020\242\367\004\022#\n\035ACC_LOGIN_SIGNED_NO_OPEN"
    "CHEST\020\243\367\004\022%\n\037ACC_LOGIN_SIGNED_HAVE_DAY_A"
    "WARD\020\244\367\004\022%\n\037ACC_LOGIN_SIGNED_HAVE_OPENCH"
    "EST\020\245\367\004\022\036\n\030ReleaseUR_CANNOT_LOTTERY\020\205\370\004\022"
    "\"\n\034ReleaseUR_NOT_ENOUGH_LOTTERY\020\206\370\004\022\033\n\025M"
    "ERCENARY_NOT_ACTIVIT\020\207\370\004\022\037\n\031RECHARGE_RET"
    "URN_TODAY_GOT\020\271\210\005\022\026\n\020HEAD_ICON_HASBUY\020\241\220"
    "\005\022\033\n\025SHOP_GEM_BUY_ONCE_MAX\020\211\230\005\022&\n FORMAT"
    "ION_CAN_NOT_USE_EXPEDITION\020\361\237\005\022#\n\035CLIMBI"
    "NGTOWER_EXCEED_MAXTIMES\020\331\247\005\022&\n EIGHTEENP"
    "RINCES_MERCENARY_NOTSET\020\301\257\005\022*\n$EIGHTEENP"
    "RINCES_MEDICALKIT_NOTENOUGH\020\302\257\005\022\'\n!EIGHT"
    "EENPRINCES_HELPREWARD_HASGET\020\303\257\005\022)\n#EIGH"
    "TEENPRINCES_MERCENARY_CANNOTUSE\020\304\257\005\022\035\n\027E"
    "IGHTEENPRINCES_NOTOPEN\020\305\257\005\022\'\n!EIGHTEENPR"
    "INCES_HELPREWARD_NOHAVE\020\306\257\005\0220\n*EIGHTEENP"
    "RINCES_HELPREWARD_CANNOTDOUBLEBUY\020\307\257\005\022\"\n"
    "\034BADGE_MAIN_ROLE_CANNOT_DRESS\020\251\267\005\022\035\n\027BAD"
    "GE_LOC_ALREADY_DRESS\020\252\267\005\022\031\n\023BADGE_LOC_NO"
    "T_DRESS\020\253\267\005\022\036\n\030BADGE_TYPE_ALREADY_DRESS\020"
    "\254\267\005\022\034\n\026BADGE_OTHER_ROLE_DRESS\020\255\267\005\022!\n\033BAD"
    "GE_BAG_EXTEND_TIMES_FULL\020\256\267\005\022 \n\032BADGE_BA"
    "G_EXTEND_SUC_VALUE\020\257\267\005\022\025\n\017BADGE_MAX_LEVE"
    "L\020\260\267\005\022\031\n\023BADGE_BAG_GRID_FULL\020\261\267\005B\031\n\027com."
    "guaji.game.protocol", 11819);
  ::google::protobuf::MessageFactory::InternalRegisterGeneratedFile(
    "Status.proto", &protobuf_RegisterTypes);
  ::google::protobuf::internal::OnShutdown(&protobuf_ShutdownFile_Status_2eproto);
}

// Force AddDescriptors() to be called at static initialization time.
struct StaticDescriptorInitializer_Status_2eproto {
  StaticDescriptorInitializer_Status_2eproto() {
    protobuf_AddDesc_Status_2eproto();
  }
} static_descriptor_initializer_Status_2eproto_;
const ::google::protobuf::EnumDescriptor* error_descriptor() {
  protobuf_AssignDescriptorsOnce();
  return error_descriptor_;
}
bool error_IsValid(int value) {
  switch(value) {
    case 1:
    case 2:
    case 3:
    case 4:
    case 5:
    case 6:
    case 7:
    case 8:
    case 9:
    case 10:
    case 11:
    case 12:
    case 13:
    case 14:
    case 15:
    case 16:
    case 17:
    case 18:
    case 19:
    case 20:
    case 21:
    case 22:
    case 23:
    case 24:
    case 25:
    case 26:
    case 27:
    case 28:
    case 29:
    case 30:
    case 31:
    case 32:
    case 33:
    case 34:
    case 35:
    case 36:
    case 530:
    case 3001:
    case 3002:
    case 3003:
    case 3004:
    case 3005:
    case 5001:
    case 5002:
    case 5003:
    case 5004:
    case 5005:
    case 5006:
    case 5007:
    case 5008:
    case 5009:
    case 5010:
    case 5011:
    case 5012:
    case 5013:
    case 5014:
    case 5015:
    case 5016:
    case 5017:
    case 5018:
    case 5019:
    case 5020:
    case 5021:
    case 5022:
    case 5023:
    case 5024:
    case 5025:
    case 5026:
    case 5027:
    case 5028:
    case 5029:
    case 5031:
    case 5033:
    case 5034:
    case 5035:
    case 5036:
    case 5037:
    case 5038:
    case 5039:
    case 5040:
    case 5041:
    case 5042:
    case 5043:
    case 5044:
    case 5045:
    case 5046:
    case 5047:
    case 6001:
    case 6002:
    case 6003:
    case 6004:
    case 6005:
    case 6006:
    case 6007:
    case 6008:
    case 6009:
    case 6010:
    case 6011:
    case 6012:
    case 6013:
    case 6014:
    case 6015:
    case 6016:
    case 8001:
    case 8002:
    case 8003:
    case 8004:
    case 8005:
    case 8006:
    case 8007:
    case 9001:
    case 9002:
    case 9003:
    case 9004:
    case 9005:
    case 9006:
    case 9007:
    case 9008:
    case 9009:
    case 9011:
    case 9012:
    case 9013:
    case 9014:
    case 9015:
    case 9016:
    case 9017:
    case 9018:
    case 9019:
    case 9020:
    case 9021:
    case 9022:
    case 9101:
    case 9102:
    case 9103:
    case 9104:
    case 9105:
    case 9106:
    case 9107:
    case 9108:
    case 9109:
    case 9110:
    case 9111:
    case 9112:
    case 9113:
    case 9114:
    case 9115:
    case 9116:
    case 9117:
    case 9118:
    case 9119:
    case 9120:
    case 9121:
    case 9122:
    case 9123:
    case 9124:
    case 9125:
    case 9126:
    case 9127:
    case 9128:
    case 10000:
    case 10001:
    case 10002:
    case 10003:
    case 10004:
    case 10010:
    case 10011:
    case 10012:
    case 11001:
    case 11002:
    case 11003:
    case 11004:
    case 11005:
    case 11006:
    case 11007:
    case 11008:
    case 11009:
    case 11010:
    case 11011:
    case 11012:
    case 11013:
    case 12001:
    case 12002:
    case 12003:
    case 13001:
    case 13002:
    case 13003:
    case 13004:
    case 13005:
    case 14001:
    case 14002:
    case 14003:
    case 15001:
    case 15002:
    case 15003:
    case 15004:
    case 16001:
    case 17001:
    case 17002:
    case 17003:
    case 17004:
    case 17005:
    case 17006:
    case 17007:
    case 17008:
    case 18001:
    case 21001:
    case 21002:
    case 21003:
    case 21004:
    case 21005:
    case 21006:
    case 23001:
    case 23002:
    case 23003:
    case 23004:
    case 23005:
    case 25001:
    case 25002:
    case 25003:
    case 25004:
    case 25005:
    case 25006:
    case 25007:
    case 25008:
    case 25009:
    case 25010:
    case 25011:
    case 25012:
    case 25013:
    case 25014:
    case 25015:
    case 25016:
    case 25017:
    case 25018:
    case 25019:
    case 25020:
    case 25021:
    case 25022:
    case 25023:
    case 25024:
    case 25025:
    case 25026:
    case 26001:
    case 26002:
    case 26003:
    case 26004:
    case 26005:
    case 26006:
    case 27001:
    case 27002:
    case 27003:
    case 27004:
    case 27008:
    case 28001:
    case 28002:
    case 28003:
    case 28004:
    case 28005:
    case 28006:
    case 28007:
    case 30001:
    case 30002:
    case 31001:
    case 31002:
    case 31003:
    case 32001:
    case 32002:
    case 33001:
    case 33002:
    case 33003:
    case 33004:
    case 33005:
    case 33006:
    case 33007:
    case 33008:
    case 33009:
    case 33010:
    case 33011:
    case 33012:
    case 33013:
    case 33014:
    case 33015:
    case 33016:
    case 33017:
    case 33018:
    case 33019:
    case 33020:
    case 33021:
    case 33022:
    case 33023:
    case 33024:
    case 33025:
    case 33026:
    case 33027:
    case 33028:
    case 33029:
    case 33031:
    case 33032:
    case 34001:
    case 34002:
    case 34003:
    case 34004:
    case 34005:
    case 34006:
    case 34007:
    case 35001:
    case 35002:
    case 80101:
    case 80102:
    case 80103:
    case 80104:
    case 80105:
    case 80106:
    case 80107:
    case 80108:
    case 80109:
    case 80110:
    case 80111:
    case 80112:
    case 80113:
    case 80114:
    case 80115:
    case 80201:
    case 80202:
    case 80203:
    case 80204:
    case 80205:
    case 80301:
    case 80401:
    case 80501:
    case 80502:
    case 80601:
    case 80602:
    case 80701:
    case 80702:
    case 80703:
    case 80801:
    case 80802:
    case 80803:
    case 80804:
    case 80805:
    case 80901:
    case 80902:
    case 80903:
    case 81301:
    case 81302:
    case 81303:
    case 81304:
    case 81501:
    case 81502:
    case 81503:
    case 81504:
    case 81601:
    case 81701:
    case 81702:
    case 81703:
    case 81704:
    case 81705:
    case 81706:
    case 81707:
    case 81708:
    case 81709:
    case 81710:
    case 81801:
    case 81802:
    case 81901:
    case 81902:
    case 81903:
    case 81904:
    case 82001:
    case 82002:
    case 82003:
    case 82101:
    case 82201:
    case 82301:
    case 82302:
    case 82401:
    case 82402:
    case 82403:
    case 82404:
    case 82405:
    case 82501:
    case 82601:
    case 82602:
    case 83001:
    case 83101:
    case 83102:
    case 84001:
    case 85001:
    case 86001:
    case 87001:
    case 88001:
    case 88002:
    case 88003:
    case 88004:
    case 88005:
    case 88006:
    case 88007:
    case 89001:
    case 89002:
    case 89003:
    case 89004:
    case 89005:
    case 89006:
    case 89007:
    case 89008:
    case 89009:
    case 90000:
    case 99001:
    case 107006:
    case 107007:
      return true;
    default:
      return false;
  }
}


// @@protoc_insertion_point(namespace_scope)

// @@protoc_insertion_point(global_scope)
