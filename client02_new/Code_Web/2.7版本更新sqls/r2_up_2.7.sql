SET FOREIGN_KEY_CHECKS=0;
ALTER TABLE `alliance` ADD COLUMN `luckyScore`  int(11) NOT NULL DEFAULT 0 AFTER `bossVitality`;
ALTER TABLE `alliance` ADD COLUMN `lastResetLuckyScoreTime`  bigint(20) NOT NULL DEFAULT 0 AFTER `luckyScore`;
ALTER TABLE `alliance_battle_info` MODIFY COLUMN `battleResultStr`  blob NULL AFTER `allianceItemsStr`;
ALTER TABLE `alliance_battle_item` ADD COLUMN `teamMapStr`  varchar(2048) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL AFTER `battleResult`;
ALTER TABLE `alliance_battle_item` ADD COLUMN `allianceName`  varchar(2048) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL AFTER `teamMapStr`;
ALTER TABLE `alliance_battle_item` ADD COLUMN `allianceLevel`  int(11) NULL DEFAULT 0 AFTER `allianceName`;
ALTER TABLE `alliance_battle_item` ADD COLUMN `captainName`  varchar(2048) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL AFTER `allianceLevel`;
ALTER TABLE `alliance_battle_item` ADD COLUMN `memberListStr`  varchar(2048) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL AFTER `captainName`;
ALTER TABLE `alliance_battle_item` ADD COLUMN `inspireInfoMapStr`  varchar(4096) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '{}' AFTER `memberListStr`;
ALTER TABLE `alliance_battle_item` ADD COLUMN `streakTimes`  int(11) NULL DEFAULT 0 AFTER `inspireInfoMapStr`;
ALTER TABLE `alliance_battle_item` ADD COLUMN `buffId`  int(11) NULL DEFAULT NULL AFTER `invalid`;
ALTER TABLE `alliance_fight_unit` MODIFY COLUMN `fightReport`  mediumblob NULL AFTER `state`;
ALTER TABLE `alliance_fight_versus` ADD COLUMN `investLeftStr`  text CHARACTER SET utf8 COLLATE utf8_general_ci NULL AFTER `winId`;
ALTER TABLE `alliance_fight_versus` ADD COLUMN `investRightStr`  text CHARACTER SET utf8 COLLATE utf8_general_ci NULL AFTER `investLeftStr`;
ALTER TABLE `alliance_fight_versus` ADD COLUMN `isRewardInvest`  int(11) NOT NULL DEFAULT 0 AFTER `investRightStr`;
ALTER TABLE `alliance_fight_versus` MODIFY COLUMN `updateTime`  timestamp NOT NULL DEFAULT '0000-00-00 00:00:00' ON UPDATE CURRENT_TIMESTAMP AFTER `createTime`;
ALTER TABLE `ip_addr` ENGINE=InnoDB,
ROW_FORMAT=Compact;
CREATE TABLE `login` (
`id`  bigint(20) NOT NULL AUTO_INCREMENT ,
`playerId`  int(11) NOT NULL DEFAULT 0 ,
`playerName`  varchar(255) CHARACTER SET utf8 COLLATE utf8_bin NULL DEFAULT NULL ,
`puid`  varchar(255) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL ,
`period`  int(11) NOT NULL DEFAULT 0 ,
`date`  varchar(64) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL DEFAULT '' ,
`createTime`  timestamp NOT NULL DEFAULT '0000-00-00 00:00:00' ,
`updateTime`  timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP ,
`invalid`  int(11) NOT NULL DEFAULT 0 ,
PRIMARY KEY (`id`),
UNIQUE INDEX `unique_login` (`puid`, `date`) USING BTREE ,
INDEX `playerId_index` (`playerId`) USING BTREE ,
INDEX `playerName_index` (`playerName`) USING BTREE ,
INDEX `puid_index` (`puid`) USING BTREE ,
INDEX `date_index` (`date`) USING BTREE 
)
ENGINE=InnoDB
DEFAULT CHARACTER SET=utf8 COLLATE=utf8_bin
ROW_FORMAT=Compact
;
ALTER TABLE `map` MODIFY COLUMN `state`  varchar(8192) CHARACTER SET utf8 COLLATE utf8_bin NULL DEFAULT NULL AFTER `playerId`;
CREATE TABLE `multi_elite_report` (
`id`  int(10) UNSIGNED NOT NULL AUTO_INCREMENT ,
`battleResult`  blob NOT NULL ,
`createTime`  timestamp NOT NULL DEFAULT '0000-00-00 00:00:00' ,
`updateTime`  timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP ,
`invalid`  int(11) NOT NULL DEFAULT 0 ,
PRIMARY KEY (`id`)
)
ENGINE=InnoDB
DEFAULT CHARACTER SET=utf8 COLLATE=utf8_bin
ROW_FORMAT=Compact
;
CREATE TABLE `multi_elite_room` (
`serverRoomId`  int(11) NOT NULL ,
`multiEliteId`  int(11) NOT NULL ,
`roomMemberIds`  varchar(32) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL DEFAULT '' ,
`isAutoStart`  int(11) NOT NULL ,
`minFightValue`  int(11) NOT NULL ,
`playerCreateTime`  bigint(20) NOT NULL DEFAULT 0 ,
`startBattleTime`  int(11) NOT NULL ,
`isOnBattle`  int(11) NOT NULL ,
`createTime`  timestamp NOT NULL DEFAULT '0000-00-00 00:00:00' ,
`updateTime`  timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP ,
`invalid`  int(11) NOT NULL DEFAULT 0 ,
PRIMARY KEY (`serverRoomId`)
)
ENGINE=InnoDB
DEFAULT CHARACTER SET=utf8 COLLATE=utf8_bin
ROW_FORMAT=Compact
;
ALTER TABLE `player` ADD COLUMN `skillEnhanceOpen`  int(11) NOT NULL DEFAULT 0 AFTER `reputationValue`;
ALTER TABLE `player` MODIFY COLUMN `puid`  varchar(128) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL AFTER `id`;
ALTER TABLE `player` MODIFY COLUMN `name`  varchar(118) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL AFTER `puid`;
ALTER TABLE `player` MODIFY COLUMN `vipLevel`  int(11) NOT NULL DEFAULT 0 AFTER `recharge`;
ALTER TABLE `player` MODIFY COLUMN `smeltValue`  int(11) NOT NULL DEFAULT 0 AFTER `vipLevel`;
ALTER TABLE `player` MODIFY COLUMN `honorValue`  int(11) NOT NULL DEFAULT 0 AFTER `smeltValue`;
ALTER TABLE `player` MODIFY COLUMN `reputationValue`  int(11) NOT NULL DEFAULT 0 AFTER `honorValue`;
ALTER TABLE `player` MODIFY COLUMN `fightValue`  int(11) NOT NULL DEFAULT 0 AFTER `skillEnhanceOpen`;
ALTER TABLE `player` MODIFY COLUMN `prof`  int(11) NOT NULL DEFAULT 0 AFTER `fightValue`;
ALTER TABLE `player` MODIFY COLUMN `signature`  varchar(256) CHARACTER SET utf8 COLLATE utf8_bin NULL DEFAULT NULL AFTER `prof`;
ALTER TABLE `player` MODIFY COLUMN `device`  varchar(256) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL DEFAULT '' AFTER `signature`;
ALTER TABLE `player` MODIFY COLUMN `platform`  varchar(256) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL DEFAULT '' AFTER `device`;
ALTER TABLE `player` MODIFY COLUMN `phoneInfo`  varchar(256) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL DEFAULT '' AFTER `platform`;
ALTER TABLE `player` MODIFY COLUMN `forbidenTime`  timestamp NULL DEFAULT NULL AFTER `phoneInfo`;
ALTER TABLE `player` MODIFY COLUMN `silentTime`  timestamp NULL DEFAULT NULL AFTER `forbidenTime`;
ALTER TABLE `player` MODIFY COLUMN `loginTime`  timestamp NULL DEFAULT NULL AFTER `silentTime`;
ALTER TABLE `player` MODIFY COLUMN `logoutTime`  timestamp NULL DEFAULT NULL AFTER `loginTime`;
ALTER TABLE `player` MODIFY COLUMN `resetTime`  timestamp NULL DEFAULT NULL AFTER `logoutTime`;
ALTER TABLE `player` MODIFY COLUMN `createTime`  timestamp NOT NULL DEFAULT '0000-00-00 00:00:00' AFTER `resetTime`;
ALTER TABLE `player` MODIFY COLUMN `updateTime`  timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP AFTER `createTime`;
ALTER TABLE `player` MODIFY COLUMN `invalid`  int(11) NOT NULL DEFAULT 0 AFTER `updateTime`;
ALTER TABLE `player` MODIFY COLUMN `webRecharge`  tinyint(2) NOT NULL DEFAULT 0 COMMENT 'web首充' AFTER `invalid`;
ALTER TABLE `player` MODIFY COLUMN `gameRecharge`  tinyint(2) NOT NULL DEFAULT 0 COMMENT '游戏内首充' AFTER `webRecharge`;
ALTER TABLE `player_alliance` ADD COLUMN `luckyScore`  int(11) NOT NULL DEFAULT 0 AFTER `shopTime`;
ALTER TABLE `player_alliance` ADD COLUMN `refreshShopCount`  int(11) NOT NULL DEFAULT 0 AFTER `luckyScore`;
ALTER TABLE `player_alliance` ADD COLUMN `shopItemsStr`  varchar(2048) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL AFTER `refreshShopCount`;
ALTER TABLE `player_alliance` ADD COLUMN `vitality`  int(11) NULL DEFAULT 0 AFTER `joinTime`;
CREATE TABLE `player_world_boss` (
`id`  int(11) NOT NULL AUTO_INCREMENT ,
`worldBossId`  int(11) NOT NULL ,
`playerId`  int(11) NULL DEFAULT 0 ,
`rebirthTimes`  int(11) NULL DEFAULT 0 ,
`harm`  int(11) NULL DEFAULT 0 ,
`lastAttackTime`  timestamp NOT NULL DEFAULT '0000-00-00 00:00:00' ,
`lastRebirthAttackTime`  timestamp NOT NULL DEFAULT '0000-00-00 00:00:00' ,
`rebirthType`  int(11) NULL DEFAULT 0 ,
`offlineActionTimes`  int(11) NULL DEFAULT 0 ,
`attackTimes`  int(11) NULL DEFAULT 0 ,
`createTime`  timestamp NOT NULL DEFAULT '0000-00-00 00:00:00' ,
`updateTime`  timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP ,
`invalid`  int(11) NOT NULL DEFAULT 0 ,
PRIMARY KEY (`id`),
INDEX `worldBossId` (`worldBossId`) USING BTREE 
)
ENGINE=InnoDB
DEFAULT CHARACTER SET=utf8 COLLATE=utf8_bin
ROW_FORMAT=Compact
;
ALTER TABLE `serverdata` ENGINE=MyISAM,
ROW_FORMAT=Dynamic;
ALTER TABLE `serverdata` ADD COLUMN `statusStr`  varchar(4096) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL AFTER `id`;
ALTER TABLE `serverdata` MODIFY COLUMN `id`  int(11) NOT NULL FIRST ;
ALTER TABLE `serverdata` DROP COLUMN `lastGrantProfRankRewardTime`;
ALTER TABLE `skill` ADD COLUMN `exp`  int(11) NOT NULL DEFAULT 0 AFTER `status`;
ALTER TABLE `status` ADD COLUMN `onlyText`  int(11) NOT NULL DEFAULT 0 AFTER `resetTimeMapStr`;
ALTER TABLE `status` ADD COLUMN `worldBossAutoJoin`  int(11) NULL DEFAULT 0 AFTER `onlyText`;
ALTER TABLE `status` ADD COLUMN `passMaxMultiEliteId`  int(11) NOT NULL DEFAULT 0 AFTER `worldBossAutoJoin`;
ALTER TABLE `status` ADD COLUMN `multiEliteTimes`  int(11) NOT NULL DEFAULT 0 AFTER `passMaxMultiEliteId`;
ALTER TABLE `status` ADD COLUMN `todayBuyMultiEliteTimes`  int(11) NOT NULL DEFAULT 0 AFTER `multiEliteTimes`;
ALTER TABLE `status` ADD COLUMN `lastRefreshMultiEliteTime`  bigint(20) NOT NULL DEFAULT 0 AFTER `todayBuyMultiEliteTimes`;
ALTER TABLE `status` ADD COLUMN `multiEliteScore`  int(11) NOT NULL DEFAULT 0 AFTER `lastRefreshMultiEliteTime`;
ALTER TABLE `status` ADD COLUMN `multiEliteHistoryScore`  int(11) NOT NULL DEFAULT 0 AFTER `multiEliteScore`;
ALTER TABLE `status` ADD COLUMN `lastShowMultiEliteResultId`  int(11) NOT NULL DEFAULT 0 AFTER `multiEliteHistoryScore`;
ALTER TABLE `status` ADD COLUMN `askTickIds`  varchar(1024) CHARACTER SET utf8 COLLATE utf8_bin NULL DEFAULT NULL AFTER `lastShowMultiEliteResultId`;
CREATE TABLE `world_boss` (
`id`  int(11) NOT NULL AUTO_INCREMENT ,
`startDate`  timestamp NOT NULL DEFAULT '0000-00-00 00:00:00' ,
`bossNpcId`  int(11) NULL DEFAULT 0 ,
`name`  varchar(255) CHARACTER SET utf8 COLLATE utf8_bin NULL DEFAULT NULL ,
`level`  int(11) NULL DEFAULT 1 ,
`clonePlayerId`  int(11) NULL DEFAULT 0 ,
`arenaNpcId`  int(11) NULL DEFAULT 0 ,
`currBossHp`  bigint(20) NULL DEFAULT 0 ,
`maxBossHp`  bigint(20) NULL DEFAULT 0 ,
`deadTime`  bigint(20) NULL DEFAULT 0 ,
`lastKillPlayerId`  int(11) NULL DEFAULT 0 ,
`hpMultiple`  int(11) NULL DEFAULT 0 ,
`createTime`  timestamp NOT NULL DEFAULT '0000-00-00 00:00:00' ,
`updateTime`  timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP ,
`invalid`  int(11) NOT NULL DEFAULT 0 ,
PRIMARY KEY (`id`),
INDEX `startDate` (`startDate`) USING BTREE 
)
ENGINE=InnoDB
DEFAULT CHARACTER SET=utf8 COLLATE=utf8_bin
ROW_FORMAT=Compact
;
SET FOREIGN_KEY_CHECKS=1;