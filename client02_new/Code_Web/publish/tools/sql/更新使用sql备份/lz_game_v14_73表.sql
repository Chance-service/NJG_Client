-- phpMyAdmin SQL Dump
-- version 3.1.3.1
-- http://www.phpmyadmin.net
--
-- 主机: localhost
-- 生成日期: 2014 年 11 月 01 日 09:04
-- 服务器版本: 5.1.33
-- PHP 版本: 5.2.9-2
--
-- 数据库: `lz_game`
--

-- --------------------------------------------------------

--
-- 表的结构 `activecode`
--

CREATE TABLE IF NOT EXISTS `activecode` (
  `active_code` varchar(64) COLLATE utf8_bin NOT NULL,
  `create_time` int(11) NOT NULL,
  `used_time` int(11) NOT NULL DEFAULT '0',
  `playerid` varchar(64) COLLATE utf8_bin NOT NULL DEFAULT '',
  `status` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`active_code`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

-- --------------------------------------------------------

--
-- 表的结构 `activitydeitycardrank`
--

CREATE TABLE IF NOT EXISTS `activitydeitycardrank` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `playerId` int(11) NOT NULL DEFAULT '0',
  `playerName` varchar(64) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL,
  `termId` int(11) NOT NULL DEFAULT '0',
  `activityScore` int(11) NOT NULL DEFAULT '0',
  `lastDrawTime` int(11) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 表的结构 `activityinfo`
--

CREATE TABLE IF NOT EXISTS `activityinfo` (
  `playerid` int(11) NOT NULL,
  `activityinfo` text COLLATE utf8_bin,
  `laseRefreshTime` int(11) NOT NULL,
  PRIMARY KEY (`playerid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

-- --------------------------------------------------------

--
-- 表的结构 `activityinfoserver`
--

CREATE TABLE IF NOT EXISTS `activityinfoserver` (
  `id` int(11) NOT NULL,
  `data` text COLLATE utf8_bin,
  `lastupdate` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

-- --------------------------------------------------------

--
-- 表的结构 `adventurefightrank`
--

CREATE TABLE IF NOT EXISTS `adventurefightrank` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `playerId` int(11) NOT NULL,
  `playerName` varchar(64) COLLATE utf8_bin NOT NULL,
  `playerLevel` int(11) DEFAULT NULL,
  `passBarrier` int(11) DEFAULT NULL,
  `obtainStar` int(11) DEFAULT '0',
  `continueInRankAmount` int(11) DEFAULT NULL,
  `rankTime` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `playerId_index` (`playerId`) USING BTREE,
  KEY `playerName_index` (`playerName`) USING BTREE
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

-- --------------------------------------------------------

--
-- 表的结构 `adventurefightstats`
--

CREATE TABLE IF NOT EXISTS `adventurefightstats` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `playerId` int(11) NOT NULL,
  `battlePanelType` int(11) NOT NULL,
  `battleAmount` int(11) NOT NULL,
  `yestBarrierLV` int(11) NOT NULL,
  `yestObtainStar` int(11) NOT NULL,
  `maxBarrierLV` int(11) NOT NULL,
  `maxObtainStar` int(11) NOT NULL,
  `currBarrierLV` int(11) NOT NULL DEFAULT '0',
  `currObtainStar` int(11) NOT NULL DEFAULT '0',
  `currSurplusStar` int(11) DEFAULT NULL,
  `extraRewardDetailInfo` varchar(255) CHARACTER SET utf8 DEFAULT NULL,
  `extraRewardConf` varchar(255) CHARACTER SET utf8 DEFAULT NULL,
  `obtainStarDetail` varchar(255) CHARACTER SET utf8 DEFAULT NULL,
  `proAdditionInfo` varchar(255) CHARACTER SET utf8 DEFAULT NULL,
  `additionSelDetail` varchar(255) CHARACTER SET utf8 DEFAULT NULL,
  `teamConfInfo` text CHARACTER SET utf8,
  `lastUpdateTime` int(11) NOT NULL,
  `lastOprTime` int(11) NOT NULL,
  `nextResetTime` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `playerId_index` (`playerId`) USING BTREE
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

-- --------------------------------------------------------

--
-- 表的结构 `adventurefinaltrial`
--

CREATE TABLE IF NOT EXISTS `adventurefinaltrial` (
  `playerid` int(11) NOT NULL,
  `currentlevel` int(11) NOT NULL,
  `currentchapter` int(11) NOT NULL,
  `currentcareer` int(11) NOT NULL,
  `levelstatus` text COLLATE utf8_bin,
  `chapterstatus` text COLLATE utf8_bin,
  `careerstatus` text COLLATE utf8_bin,
  `playcount` text COLLATE utf8_bin,
  `playroundtime` text COLLATE utf8_bin,
  `rewardinfo` text COLLATE utf8_bin,
  `refreshcount` text COLLATE utf8_bin,
  `termid` int(11) NOT NULL DEFAULT '0',
  `lastupdate` int(11) NOT NULL DEFAULT '0',
  `bossCanPlayTimesStr` varchar(512) COLLATE utf8_bin DEFAULT NULL,
  KEY `playerid_index` (`playerid`) USING BTREE
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

-- --------------------------------------------------------

--
-- 表的结构 `adventurelottery`
--

CREATE TABLE IF NOT EXISTS `adventurelottery` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `adventureid` int(11) DEFAULT NULL,
  `termid` int(11) DEFAULT NULL,
  `periodid` int(11) DEFAULT NULL,
  `playerid` int(11) DEFAULT NULL,
  `name` varchar(64) CHARACTER SET utf8 COLLATE utf8_bin DEFAULT NULL,
  `sselectnum` varchar(128) DEFAULT NULL,
  `selectnum` int(11) DEFAULT NULL,
  `rank` int(11) DEFAULT '-1',
  `buytime` int(11) DEFAULT NULL,
  `lastupdate` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `termid_index` (`termid`) USING BTREE,
  KEY `playerid_index` (`playerid`) USING BTREE,
  KEY `adventureid_index` (`adventureid`) USING BTREE
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 表的结构 `adventureluckyegg`
--

CREATE TABLE IF NOT EXISTS `adventureluckyegg` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `playerid` int(11) DEFAULT NULL,
  `termid` int(11) DEFAULT NULL,
  `items` text COLLATE utf8_bin,
  `status` int(11) DEFAULT '0',
  `poundtimes` int(11) DEFAULT NULL,
  `luckypoint` int(11) DEFAULT NULL,
  `currentpoint` int(11) DEFAULT NULL,
  `level` int(11) DEFAULT NULL,
  `gotrewards` text COLLATE utf8_bin,
  `gotboxrewards` text COLLATE utf8_bin,
  `limititems` text COLLATE utf8_bin NOT NULL,
  `refreshcount` int(11) DEFAULT '0',
  `deleteflag` int(11) DEFAULT NULL,
  `lastupdate` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `playerid_index` (`playerid`) USING BTREE,
  KEY `termid_index` (`termid`) USING BTREE
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

-- --------------------------------------------------------

--
-- 表的结构 `alliance`
--

CREATE TABLE IF NOT EXISTS `alliance` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) DEFAULT NULL COMMENT 'å¸®æ´¾åç§°',
  `level` int(11) DEFAULT NULL COMMENT 'å¸®æ´¾ç­‰çº§',
  `totalContribution` int(11) DEFAULT NULL COMMENT 'å¸®æ´¾æ€»è´¡çŒ®',
  `currentContribution` int(11) DEFAULT NULL COMMENT 'å½“å‰è´¡çŒ®',
  `playerId` int(11) DEFAULT NULL COMMENT 'å¸®ä¸»id',
  `notice` varchar(255) DEFAULT NULL COMMENT 'å¸®æ´¾å…¬å‘Š',
  `password` varchar(50) DEFAULT NULL COMMENT 'å†›å›¢å¯†ç ',
  `createTime` bigint(20) DEFAULT NULL COMMENT 'åˆ›å»ºæ—¶é—´',
  `useCanBaiCount` int(11) DEFAULT NULL COMMENT 'å…³å…¬æ®¿å‚æ‹œæ¬¡æ•°',
  `declaration` varchar(255) DEFAULT NULL COMMENT 'å†›å›¢å®£è¨€',
  `isDelete` int(11) DEFAULT '0' COMMENT 'æ˜¯å¦åˆ é™¤',
  `updateCanBaiTime` bigint(20) NOT NULL DEFAULT '0' COMMENT 'å‚æ‹œæ—¶é—´',
  `rescGalaxyLevelId` int(11) NOT NULL DEFAULT '0',
  `bossDamageAmount` int(10) unsigned NOT NULL DEFAULT '0',
  `allianceRescGalaxyId` int(11) DEFAULT '0',
  `battleOpenTimes` int(11) DEFAULT '0',
  `battleLastOpenTime` int(11) DEFAULT '0',
  `battleCloseTime` int(11) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC COMMENT='帮派';

-- --------------------------------------------------------

--
-- 表的结构 `alliance_apply`
--

CREATE TABLE IF NOT EXISTS `alliance_apply` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `allianceId` int(11) NOT NULL DEFAULT '0' COMMENT 'å†›å›¢id',
  `playerId` int(11) DEFAULT NULL COMMENT 'çŽ©å®¶id',
  `createTime` bigint(20) DEFAULT NULL COMMENT 'ç”³è¯·æ—¶é—´',
  `status` int(11) DEFAULT '0' COMMENT 'ç”³è¯·çŠ¶æ€ï¼š0æœªå®¡æ ¸ï¼Œ1é€šè¿‡ï¼Œ2æ‹’ç»',
  PRIMARY KEY (`id`),
  KEY `allianceId` (`allianceId`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 ROW_FORMAT=FIXED COMMENT='军团申请';

-- --------------------------------------------------------

--
-- 表的结构 `alliance_auction`
--

CREATE TABLE IF NOT EXISTS `alliance_auction` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `player_id` int(11) DEFAULT NULL,
  `auction` text,
  `auctionRefreshTime` bigint(20) DEFAULT '0',
  `exchange` text,
  `exchangeRefreshTime` bigint(20) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=COMPACT;

-- --------------------------------------------------------

--
-- 表的结构 `alliance_battle_spoil`
--

CREATE TABLE IF NOT EXISTS `alliance_battle_spoil` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `allianceId` int(11) DEFAULT NULL,
  `createTimeDate` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `battleId` int(11) DEFAULT NULL,
  `dealPrice` int(11) DEFAULT NULL,
  `status` int(11) DEFAULT NULL,
  `itemInfoStr` varchar(2048) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- 表的结构 `alliance_building`
--

CREATE TABLE IF NOT EXISTS `alliance_building` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `allianceId` int(11) NOT NULL COMMENT 'å¸®æ´¾id',
  `type` int(11) NOT NULL DEFAULT '0' COMMENT 'å»ºç­‘ç±»åž‹',
  `level` int(11) DEFAULT NULL COMMENT 'å»ºç­‘ç­‰çº§',
  PRIMARY KEY (`id`),
  KEY `allianceId` (`allianceId`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 ROW_FORMAT=FIXED COMMENT='帮派建筑';

-- --------------------------------------------------------

--
-- 表的结构 `alliance_dynamic`
--

CREATE TABLE IF NOT EXISTS `alliance_dynamic` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `allianceId` int(11) DEFAULT NULL COMMENT 'å¸®æ´¾id',
  `params` varchar(255) DEFAULT '' COMMENT 'åŠ¨æ€å‚æ•°ï¼Œæ ¼å¼ï¼šA_B_C',
  `createTime` bigint(20) DEFAULT NULL COMMENT 'åˆ›å»ºæ—¶é—´',
  `playerId` int(11) DEFAULT NULL COMMENT 'çŽ©å®¶id',
  `type` int(11) DEFAULT NULL COMMENT 'åŠ¨æ€ç±»åž‹',
  PRIMARY KEY (`id`),
  KEY `allianceId` (`allianceId`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC COMMENT='帮派动态';

-- --------------------------------------------------------

--
-- 表的结构 `astrology`
--

CREATE TABLE IF NOT EXISTS `astrology` (
  `playerId` int(11) NOT NULL,
  `targetStarStr` varchar(2048) DEFAULT NULL,
  `completeStarStr` varchar(2048) DEFAULT NULL,
  `totalStarValue` int(11) DEFAULT NULL,
  `rewardLevel` int(11) DEFAULT NULL,
  `currentStarStr` varchar(2048) DEFAULT NULL,
  `currentGroup` int(11) DEFAULT NULL,
  `astrologyCount` int(11) DEFAULT NULL,
  `refreshCount` int(11) DEFAULT NULL,
  `failRefreshCount` int(11) DEFAULT NULL,
  PRIMARY KEY (`playerId`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 表的结构 `bag`
--

CREATE TABLE IF NOT EXISTS `bag` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `playerid` int(11) NOT NULL,
  `itemid` int(11) NOT NULL,
  `count` int(11) NOT NULL,
  `source` int(11) NOT NULL,
  `create_time` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `playerid_index` (`playerid`) USING BTREE,
  KEY `itemid_index` (`itemid`) USING BTREE
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

-- --------------------------------------------------------

--
-- 表的结构 `battle`
--

CREATE TABLE IF NOT EXISTS `battle` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `playerId` int(11) NOT NULL,
  `discipleId` int(11) DEFAULT NULL,
  `itemId` int(11) DEFAULT NULL,
  `isMain` int(11) DEFAULT NULL,
  `sex` int(11) DEFAULT NULL,
  `level` int(11) DEFAULT NULL,
  `attack` int(11) DEFAULT NULL,
  `physics_defence` int(11) DEFAULT NULL,
  `theurgy_defence` int(11) DEFAULT NULL,
  `health` int(11) DEFAULT NULL,
  `hit` int(11) DEFAULT NULL,
  `miss` int(11) DEFAULT NULL,
  `crit` int(11) DEFAULT NULL,
  `anticrit` int(11) DEFAULT NULL,
  `block` int(11) DEFAULT NULL,
  `antiblock` int(11) DEFAULT NULL,
  `skill1` int(11) DEFAULT NULL,
  `skill1item` int(11) DEFAULT NULL,
  `skill1type` int(11) DEFAULT NULL,
  `skill2` int(11) DEFAULT NULL,
  `skill2item` int(11) DEFAULT NULL,
  `skill2Type` int(11) DEFAULT NULL,
  `weapon` int(11) DEFAULT NULL,
  `weaponitem` int(11) DEFAULT NULL,
  `jewelry` int(11) DEFAULT NULL,
  `jewelryitem` int(11) DEFAULT NULL,
  `helmet` int(11) DEFAULT NULL,
  `helmetitem` int(11) DEFAULT NULL,
  `book` int(11) DEFAULT NULL,
  `bookitem` int(11) DEFAULT NULL,
  `mount` int(11) DEFAULT NULL,
  `mountitem` int(11) DEFAULT NULL,
  `fates` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `fatesstatus` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `fightValue` int(11) DEFAULT '0',
  `addValueStr` varchar(512) COLLATE utf8_bin DEFAULT NULL,
  `stage` int(11) DEFAULT '0',
  `position` int(11) DEFAULT '0',
  `armor` int(11) DEFAULT '0',
  `armoritem` int(11) DEFAULT '0',
  `dragonSoulArrayStr` varchar(64) COLLATE utf8_bin NOT NULL DEFAULT '0_0_0_0_0_0_0_0',
  PRIMARY KEY (`id`),
  KEY `playerId_index` (`playerId`) USING BTREE,
  KEY `discipleId_index` (`discipleId`) USING BTREE,
  KEY `itemId_index` (`itemId`) USING BTREE,
  KEY `level_index` (`level`) USING BTREE
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

-- --------------------------------------------------------

--
-- 表的结构 `battlerecord`
--

CREATE TABLE IF NOT EXISTS `battlerecord` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `version` int(11) NOT NULL,
  `type` int(11) NOT NULL,
  `playerid1` int(11) NOT NULL,
  `playerid2` int(11) NOT NULL,
  `result` blob,
  `time` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 表的结构 `career`
--

CREATE TABLE IF NOT EXISTS `career` (
  `playerid` int(11) NOT NULL,
  `pointstate` text COLLATE utf8_bin,
  `pointcount` text COLLATE utf8_bin,
  `starreward` text COLLATE utf8_bin,
  PRIMARY KEY (`playerid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

-- --------------------------------------------------------

--
-- 表的结构 `cdkey`
--

CREATE TABLE IF NOT EXISTS `cdkey` (
  `cd_key` varchar(64) COLLATE utf8_bin NOT NULL,
  `create_time` int(11) NOT NULL,
  `used_time` int(11) NOT NULL DEFAULT '0',
  `playerid` int(11) NOT NULL DEFAULT '0',
  `status` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`cd_key`),
  KEY `playerid_index` (`playerid`) USING BTREE
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

-- --------------------------------------------------------

--
-- 表的结构 `cdk_test`
--

CREATE TABLE IF NOT EXISTS `cdk_test` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `cdk` varchar(100) DEFAULT NULL,
  `player_id` int(11) DEFAULT '0',
  `puid` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 表的结构 `challenge`
--

CREATE TABLE IF NOT EXISTS `challenge` (
  `playerid` int(11) NOT NULL,
  `highest_rank` int(11) NOT NULL,
  `hasgotreward` varchar(2048) COLLATE utf8_bin DEFAULT '',
  `lastsettletime` int(11) NOT NULL,
  `lastrefreshtime` int(11) NOT NULL,
  `dayExchangeAwards` varchar(2048) COLLATE utf8_bin DEFAULT '',
  `careerExchangeAwards` varchar(2048) COLLATE utf8_bin DEFAULT '',
  `recvRankAwards` varchar(2048) COLLATE utf8_bin DEFAULT '',
  PRIMARY KEY (`playerid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

-- --------------------------------------------------------

--
-- 表的结构 `disciple`
--

CREATE TABLE IF NOT EXISTS `disciple` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `playerid` int(11) NOT NULL,
  `itemid` int(11) NOT NULL,
  `isMain` int(11) NOT NULL,
  `sex` int(11) NOT NULL,
  `physique` int(11) NOT NULL,
  `strength` int(11) NOT NULL,
  `armor` int(11) NOT NULL,
  `level` int(11) NOT NULL,
  `exp` int(11) NOT NULL,
  `stage` int(11) NOT NULL,
  `attack` int(11) DEFAULT NULL,
  `physics_defence` int(11) DEFAULT NULL,
  `theurgy_defence` int(11) DEFAULT NULL,
  `health` int(11) DEFAULT NULL,
  `hit` int(11) DEFAULT NULL,
  `miss` int(11) DEFAULT NULL,
  `crit` int(11) DEFAULT NULL,
  `anticrit` int(11) DEFAULT NULL,
  `block` int(11) DEFAULT NULL,
  `antiblock` int(11) DEFAULT NULL,
  `upgradelevel` int(11) NOT NULL,
  `potentiality` int(11) NOT NULL,
  `skill1` int(11) NOT NULL,
  `skill2` int(11) NOT NULL,
  `battleid` int(11) NOT NULL,
  `expire_time` int(11) NOT NULL,
  `battle_status` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `playerid_index` (`playerid`) USING BTREE,
  KEY `itemid_index` (`itemid`) USING BTREE,
  KEY `level_index` (`level`) USING BTREE,
  KEY `stage_index` (`stage`) USING BTREE
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

-- --------------------------------------------------------

--
-- 表的结构 `distrial_rank`
--

CREATE TABLE IF NOT EXISTS `distrial_rank` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `fightValue` int(11) DEFAULT NULL COMMENT '战斗力',
  `playerId` int(11) DEFAULT NULL,
  `createTime` datetime DEFAULT NULL COMMENT '创建时间',
  `maxPoint` int(11) DEFAULT '0' COMMENT '最高关卡',
  `rank` int(11) DEFAULT NULL COMMENT '排行',
  `type` int(11) DEFAULT NULL COMMENT '类型：1关卡排行，2神秘排行',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 ROW_FORMAT=FIXED COMMENT='试炼排行';

-- --------------------------------------------------------

--
-- 表的结构 `dragonsoul`
--

CREATE TABLE IF NOT EXISTS `dragonsoul` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `playerid` int(11) NOT NULL,
  `itemid` int(11) NOT NULL,
  `level` int(11) NOT NULL,
  `exp` int(11) NOT NULL,
  `bagType` int(11) NOT NULL DEFAULT '0',
  `attrValueStr` varchar(512) COLLATE utf8_bin DEFAULT '',
  `type` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

-- --------------------------------------------------------

--
-- 表的结构 `dragonsoulextractinfo`
--

CREATE TABLE IF NOT EXISTS `dragonsoulextractinfo` (
  `playerid` int(11) NOT NULL,
  `dragonSoulStageId` int(11) NOT NULL DEFAULT '0',
  `firstInStatus` varchar(512) COLLATE utf8_bin NOT NULL DEFAULT '',
  `dragonSoulSiliverCost` int(11) NOT NULL DEFAULT '0',
  `inLuckyPoolBySiliverTimes` int(11) NOT NULL DEFAULT '0',
  `dragonSoulGoldCost` int(11) NOT NULL DEFAULT '0',
  `inLuckyPoolByGoldTimes` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`playerid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

-- --------------------------------------------------------

--
-- 表的结构 `equip`
--

CREATE TABLE IF NOT EXISTS `equip` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `playerid` int(11) NOT NULL,
  `itemid` int(11) NOT NULL,
  `type` int(11) NOT NULL,
  `level` int(11) NOT NULL,
  `refinexp` int(11) NOT NULL,
  `refinelevel` int(11) NOT NULL,
  `basicAttrValueStr` varchar(512) COLLATE utf8_bin DEFAULT '',
  `baptizeAttrValueStr` varchar(512) COLLATE utf8_bin DEFAULT '',
  `tempBaptizeAttrValueStr` varchar(512) COLLATE utf8_bin DEFAULT '',
  `sellSilver` varchar(512) COLLATE utf8_bin DEFAULT '0',
  `expire_time` int(11) NOT NULL,
  `diamondinfo` varchar(2048) COLLATE utf8_bin DEFAULT '{}',
  `baptizeCount` int(11) DEFAULT '0',
  `replaceCount` int(11) DEFAULT '0',
  `starStr` varchar(50) COLLATE utf8_bin DEFAULT 'none',
  PRIMARY KEY (`id`),
  KEY `playerid_index` (`playerid`) USING BTREE,
  KEY `itemid_index` (`itemid`) USING BTREE,
  KEY `type_index` (`type`) USING BTREE,
  KEY `level_index` (`level`) USING BTREE
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

-- --------------------------------------------------------

--
-- 表的结构 `formation`
--

CREATE TABLE IF NOT EXISTS `formation` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `playerId` int(11) DEFAULT NULL,
  `baseId` int(11) DEFAULT NULL,
  `openFormationPosNum` int(11) DEFAULT '0',
  `position` varchar(511) DEFAULT NULL,
  `posLevel` varchar(255) DEFAULT '0_0_0_0_0_0_0',
  PRIMARY KEY (`id`),
  KEY `playerId_index` (`playerId`) USING BTREE,
  KEY `baseId_index` (`baseId`) USING BTREE
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 表的结构 `fragment`
--

CREATE TABLE IF NOT EXISTS `fragment` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `playerId` int(11) NOT NULL DEFAULT '0',
  `itemId` int(11) NOT NULL DEFAULT '0',
  `quantity` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `playerId_index` (`playerId`) USING BTREE,
  KEY `itemId_index` (`itemId`) USING BTREE
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 表的结构 `friendgift`
--

CREATE TABLE IF NOT EXISTS `friendgift` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `playerid` int(11) NOT NULL DEFAULT '0',
  `presenter` int(11) NOT NULL DEFAULT '0',
  `givedate` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `playerid_index` (`playerid`) USING BTREE,
  KEY `presenter_index` (`presenter`) USING BTREE
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 表的结构 `guardrank`
--

CREATE TABLE IF NOT EXISTS `guardrank` (
  `id` int(11) NOT NULL,
  `playerid` int(11) NOT NULL,
  `rank` int(11) NOT NULL,
  `name` varchar(64) COLLATE utf8_bin NOT NULL,
  `guardTimes` int(11) NOT NULL,
  `ranktime` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `ranktime_index` (`ranktime`) USING BTREE,
  KEY `playerid_index` (`playerid`) USING BTREE,
  KEY `rank_index` (`rank`) USING BTREE
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

-- --------------------------------------------------------

--
-- 表的结构 `handbook`
--

CREATE TABLE IF NOT EXISTS `handbook` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `playerid` int(11) NOT NULL,
  `type` int(11) NOT NULL,
  `itemid` int(11) NOT NULL,
  `state` int(11) NOT NULL,
  `value` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `playerid_index` (`playerid`) USING BTREE,
  KEY `type_index` (`type`) USING BTREE,
  KEY `itemid_index` (`itemid`) USING BTREE
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

-- --------------------------------------------------------

--
-- 表的结构 `invitestatus`
--

CREATE TABLE IF NOT EXISTS `invitestatus` (
  `playerid` int(11) NOT NULL,
  `invitestatus` varchar(255) COLLATE utf8_bin NOT NULL DEFAULT '{}',
  `rewardstatus` varchar(255) COLLATE utf8_bin NOT NULL DEFAULT '{}',
  PRIMARY KEY (`playerid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

-- --------------------------------------------------------

--
-- 表的结构 `mapping`
--

CREATE TABLE IF NOT EXISTS `mapping` (
  `puid` varchar(64) COLLATE utf8_bin NOT NULL,
  `gameid` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(64) COLLATE utf8_bin NOT NULL,
  `passwd` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  `createTime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `forbidenTime` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`puid`),
  UNIQUE KEY `gameid_index` (`gameid`) USING BTREE,
  UNIQUE KEY `name_index` (`name`) USING BTREE,
  KEY `puid_index` (`puid`) USING BTREE
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

-- --------------------------------------------------------

--
-- 表的结构 `mission`
--

CREATE TABLE IF NOT EXISTS `mission` (
  `playerId` int(11) NOT NULL,
  `dailyMissionCount` int(11) NOT NULL DEFAULT '0',
  `dailyMissionStatus` text COLLATE utf8_bin NOT NULL,
  `dailyMissionRefreshTimes` int(11) NOT NULL DEFAULT '0',
  `lastDailyRefreshTime` int(11) NOT NULL DEFAULT '0',
  `completeMissions` text COLLATE utf8_bin NOT NULL,
  `growupMissionStatus` text COLLATE utf8_bin NOT NULL,
  `checkMissionPeriodId` int(11) NOT NULL DEFAULT '0',
  `checkMissionLevel` int(11) NOT NULL DEFAULT '0',
  `todayActivityPoint` int(11) NOT NULL DEFAULT '0',
  `todayGetActivityRewards` varchar(64) COLLATE utf8_bin NOT NULL DEFAULT '[]',
  PRIMARY KEY (`playerId`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

-- --------------------------------------------------------

--
-- 表的结构 `monthcard`
--

CREATE TABLE IF NOT EXISTS `monthcard` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `playerId` int(11) DEFAULT NULL,
  `startDate` timestamp NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  `rewardDateStr` varchar(2048) DEFAULT NULL,
  `configId` int(11) DEFAULT NULL,
  `status` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 表的结构 `mystery_shop`
--

CREATE TABLE IF NOT EXISTS `mystery_shop` (
  `playerId` int(11) NOT NULL DEFAULT '0',
  `handRefreshCount` int(11) DEFAULT NULL,
  `currentSellItemStr` varchar(255) DEFAULT NULL,
  `lastRefreshTime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `todayGoldRefreshCount` int(11) DEFAULT '0',
  `alreadySellItemStr` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`playerId`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 表的结构 `new_server_activity` lastAllianceBattleAuctionTime 字段为V1.4新增加字段 为防止出现日期0000-00-00 00:00:00 导致服务器无法启动 故写一个默认日期
--

CREATE TABLE IF NOT EXISTS `new_server_activity` (
  `id` int(11) NOT NULL,
  `isNewSerChallengeReward` int(11) DEFAULT NULL,
  `isNewSerLvlReward` int(11) DEFAULT NULL,
  `lastAllianceBattleAuctionTime` timestamp NOT NULL DEFAULT '2014-11-12 12:00:00',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

-- --------------------------------------------------------

--
-- 表的结构 `paybackstage`
--

CREATE TABLE IF NOT EXISTS `paybackstage` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `uid` varchar(64) COLLATE utf8_bin NOT NULL,
  `playerId` int(11) NOT NULL,
  `goodsId` int(11) NOT NULL,
  `goodsCount` int(11) NOT NULL,
  `goodsCost` int(11) NOT NULL,
  `amount` int(11) NOT NULL,
  `addnum` int(11) NOT NULL,
  `isFirstPay` int(11) NOT NULL,
  `create_time` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `playerId_index` (`playerId`) USING BTREE,
  KEY `goodsId_index` (`goodsId`) USING BTREE
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

-- --------------------------------------------------------

--
-- 表的结构 `personal_peak_war`
--

CREATE TABLE IF NOT EXISTS `personal_peak_war` (
  `exchangeInfo` blob,
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `playerId` int(11) DEFAULT NULL,
  `adventureServerId` int(11) DEFAULT NULL,
  `scoreInfo` blob,
  `winBattleInfo` blob,
  `isRankRewardGot` tinyint(1) NOT NULL DEFAULT '0',
  `exchangeScore` int(11) DEFAULT NULL,
  `lastExchangeDate` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `scoreChangeTime` bigint(15) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `playerId_index` (`playerId`) USING BTREE,
  KEY `adventureServerId_index` (`adventureServerId`) USING BTREE
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 表的结构 `personal_tournment`
--

CREATE TABLE IF NOT EXISTS `personal_tournment` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `playerId` int(11) DEFAULT NULL,
  `tournmentServerId` int(11) DEFAULT NULL,
  `enemyIdStr` varchar(2048) DEFAULT NULL,
  `isRewardSend` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `PSID_index` (`playerId`,`tournmentServerId`) USING BTREE
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 表的结构 `planet`
--

CREATE TABLE IF NOT EXISTS `planet` (
  `planetId` int(11) NOT NULL,
  `occupationPlayerId` int(11) NOT NULL DEFAULT '0',
  `occupationPeriod` int(10) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`planetId`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 表的结构 `player`
--

CREATE TABLE IF NOT EXISTS `player` (
  `id` int(11) NOT NULL,
  `puid` varchar(64) COLLATE utf8_bin NOT NULL,
  `password` varchar(64) COLLATE utf8_bin NOT NULL,
  `name` varchar(64) COLLATE utf8_bin NOT NULL,
  `level` int(11) NOT NULL,
  `exp` int(11) NOT NULL,
  `powerbytime` int(11) NOT NULL,
  `powerbychicken` int(11) NOT NULL,
  `poweraddtime` int(11) NOT NULL,
  `eatfoodtime` int(11) NOT NULL,
  `maxpower` int(11) NOT NULL,
  `todaychickennum` int(11) NOT NULL,
  `eatchickentime` int(11) NOT NULL,
  `vitality` int(11) NOT NULL,
  `vitalityaddtime` int(11) NOT NULL,
  `maxvitality` int(11) NOT NULL,
  `todaypelletnum` int(11) NOT NULL,
  `eatpellettime` int(11) NOT NULL,
  `viplevel` int(11) NOT NULL,
  `rechargeNum` float DEFAULT NULL,
  `silvercoins` bigint(11) NOT NULL,
  `sysgoldcoins` int(11) NOT NULL,
  `rechargegoldcoins` int(11) NOT NULL,
  `todayleavetimes` int(11) NOT NULL,
  `tentime` int(11) NOT NULL,
  `hundredtime` int(11) NOT NULL,
  `wanlitime` int(11) NOT NULL,
  `tutorialstep` int(11) NOT NULL,
  `registertime` int(11) NOT NULL,
  `origin` int(11) NOT NULL,
  `setting` varchar(64) COLLATE utf8_bin NOT NULL,
  `firstgain` varchar(255) COLLATE utf8_bin NOT NULL DEFAULT '{}',
  `lastlogin` int(11) NOT NULL,
  `invitedid` int(11) NOT NULL DEFAULT '0',
  `instructionFinishTime` int(11) NOT NULL DEFAULT '0',
  `todaybuychickennum` int(11) NOT NULL DEFAULT '0',
  `todaybuypelletnum` int(11) NOT NULL DEFAULT '0',
  `leaguaid` int(11) NOT NULL DEFAULT '0',
  `currentFormationId` int(11) DEFAULT '0',
  `reccontributiontime` int(11) DEFAULT NULL,
  `lastquittime` int(11) DEFAULT NULL,
  `skillBag` int(11) DEFAULT '1',
  `extEquipBagTimes` int(11) DEFAULT '0',
  `extEquipBookBagTimes` int(11) DEFAULT '0',
  `extTreasureBagTimes` int(11) DEFAULT '0',
  `extDiscipleBagTimes` int(11) DEFAULT '0',
  `discipleConvertTime` varchar(32) COLLATE utf8_bin DEFAULT NULL,
  `convertView` varchar(64) COLLATE utf8_bin DEFAULT '{"1":0,"2":0,"3":0,"4":0}',
  `heroSoul` int(11) DEFAULT '0',
  `soulJade` int(11) unsigned zerofill DEFAULT '00000000000',
  `challengeScore` int(11) DEFAULT NULL,
  `fightValue` int(11) DEFAULT '0',
  `osversion` varchar(2048) COLLATE utf8_bin DEFAULT NULL,
  `phonetype` varchar(2048) COLLATE utf8_bin DEFAULT NULL,
  `channel` varchar(2048) COLLATE utf8_bin DEFAULT NULL,
  `os` varchar(2048) COLLATE utf8_bin DEFAULT NULL,
  `deviceId` varchar(2048) COLLATE utf8_bin DEFAULT NULL,
  `levelGuideStep` int(11) DEFAULT '0',
  `dragonSoulFragment` int(11) NOT NULL DEFAULT '0',
  `isSilent` int(11) DEFAULT '0',
  `monthlyCardRechargeNum` int(11) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `puid_index` (`puid`) USING BTREE,
  KEY `name_index` (`name`) USING BTREE,
  KEY `level_index` (`level`) USING BTREE,
  KEY `deviceId_index` (`deviceId`(333))
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

-- --------------------------------------------------------

--
-- 表的结构 `playerfrom`
--

CREATE TABLE IF NOT EXISTS `playerfrom` (
  `puid` varchar(64) COLLATE utf8_bin NOT NULL,
  `playerid` int(11) NOT NULL,
  `platform` varchar(32) COLLATE utf8_bin DEFAULT NULL,
  `deviceid` varchar(128) COLLATE utf8_bin DEFAULT NULL,
  `createtime` int(11) NOT NULL,
  `idfa` varchar(64) COLLATE utf8_bin DEFAULT NULL,
  PRIMARY KEY (`puid`),
  KEY `playerid_index` (`playerid`) USING BTREE,
  KEY `platform_index` (`platform`) USING BTREE,
  KEY `deviceid_index` (`deviceid`) USING BTREE
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

-- --------------------------------------------------------

--
-- 表的结构 `player_alliance`
--

CREATE TABLE IF NOT EXISTS `player_alliance` (
  `playerId` int(11) NOT NULL AUTO_INCREMENT COMMENT 'çŽ©å®¶id',
  `allianceId` int(11) DEFAULT NULL COMMENT 'æ‰€å±žå¸®æ´¾id',
  `totalContribution` int(11) DEFAULT NULL COMMENT 'æ€»è´¡çŒ®åº¦',
  `currentContribution` int(11) DEFAULT NULL COMMENT 'å½“å‰è´¡çŒ®åº¦',
  `lastContributionTime` bigint(20) DEFAULT NULL COMMENT 'ä¸Šæ¬¡æçŒ®æ—¶é—´',
  `lastGuanGongTime` bigint(20) DEFAULT NULL COMMENT 'ä¸Šæ¬¡å‚æ‹œæ—¶é—´',
  `status` int(11) DEFAULT NULL COMMENT 'æ˜¯å¦åŠ å…¥å†›å›¢ä¸­æœªåŠ å…¥ï¼š0ï¼›å·²åŠ å…¥ï¼š1',
  `postion` int(11) DEFAULT NULL COMMENT 'å†›å›¢èŒä½',
  `exitAllianceTime` bigint(20) DEFAULT NULL COMMENT 'é€€å‡ºå†›å›¢æ—¶é—´',
  `jointTime` bigint(20) DEFAULT '0' COMMENT 'åŠ å…¥å†›å›¢æ—¶é—´',
  `playerDamageAmount` int(10) unsigned NOT NULL DEFAULT '0',
  `todayDamageTimes` int(10) unsigned NOT NULL DEFAULT '0',
  `lastDamageTime` int(10) unsigned NOT NULL DEFAULT '0',
  `auctionCount` int(11) DEFAULT '0',
  PRIMARY KEY (`playerId`),
  KEY `allianceId` (`allianceId`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 ROW_FORMAT=FIXED COMMENT='帮派成员';

-- --------------------------------------------------------

--
-- 表的结构 `player_alliance_battle_auction`
--

CREATE TABLE IF NOT EXISTS `player_alliance_battle_auction` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `allianceSpoilId` int(11) DEFAULT NULL,
  `auctionDate` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `playerId` int(11) DEFAULT NULL,
  `pay` int(11) DEFAULT NULL,
  `status` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1 ROW_FORMAT=FIXED;

-- --------------------------------------------------------

--
-- 表的结构 `player_distrial`
--

CREATE TABLE IF NOT EXISTS `player_distrial` (
  `playerId` int(11) NOT NULL AUTO_INCREMENT,
  `currentCount` int(11) DEFAULT NULL COMMENT '当前试炼次数',
  `currentPoint` int(11) DEFAULT NULL COMMENT '当前关卡',
  `maxPoint` int(11) DEFAULT '0' COMMENT '最高关卡',
  `npcId` int(11) DEFAULT NULL COMMENT '当前关卡的npcId',
  `historyMaxPoint` int(11) DEFAULT '0' COMMENT '历史最高层数',
  `lightSoul` int(11) DEFAULT '0' COMMENT '灯魂',
  `attack1` int(11) DEFAULT '0' COMMENT '攻击加成',
  `attack2` int(11) NOT NULL DEFAULT '0',
  `life1` int(11) DEFAULT '0' COMMENT '生命加成',
  `life2` int(11) DEFAULT '0',
  `defence1` int(11) DEFAULT '0' COMMENT '防御加成',
  `defence2` int(11) DEFAULT '0',
  `hidePoints` varchar(500) DEFAULT NULL COMMENT '通关的隐藏关卡',
  `currentHidePoint` int(11) DEFAULT '0' COMMENT '当前隐藏关卡',
  `hidePointTime` bigint(20) DEFAULT '0' COMMENT '隐藏关卡消失时间',
  `hidePointFightCount` int(11) DEFAULT '0' COMMENT '隐藏关卡挑战次数',
  `updateTime` date DEFAULT NULL COMMENT '上次操作时间',
  `buyLightSoulCount` int(11) NOT NULL DEFAULT '1' COMMENT '购买魂灯次数',
  `alreadyNpc` text COMMENT '已经打过的npc',
  `isAddAtrr` int(11) DEFAULT '0' COMMENT '是否已经加属性',
  `resetPoint` int(11) NOT NULL,
  PRIMARY KEY (`playerId`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='用户试炼';

-- --------------------------------------------------------

--
-- 表的结构 `player_snapshot`
--

CREATE TABLE IF NOT EXISTS `player_snapshot` (
  `playerId` int(11) NOT NULL DEFAULT '0',
  `snapshot` blob,
  PRIMARY KEY (`playerId`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 表的结构 `rank_info`
--

CREATE TABLE IF NOT EXISTS `rank_info` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `playerId` int(11) DEFAULT '0',
  `rank` int(11) DEFAULT '0',
  `score` int(11) DEFAULT '0',
  `level` int(11) NOT NULL DEFAULT '0',
  `termId` int(11) DEFAULT NULL,
  `type` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `playerId_index` (`playerId`) USING BTREE,
  KEY `rank_index` (`rank`) USING BTREE,
  KEY `level_index` (`level`) USING BTREE
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 表的结构 `recharge`
--

CREATE TABLE IF NOT EXISTS `recharge` (
  `CooOrderSerial` varchar(128) COLLATE utf8_bin NOT NULL,
  `ConsumeStreamId` varchar(128) COLLATE utf8_bin NOT NULL,
  `uid` varchar(64) COLLATE utf8_bin NOT NULL,
  `playerId` int(11) NOT NULL,
  `goodsId` int(11) NOT NULL,
  `goodsCount` int(11) NOT NULL,
  `goodsCost` float DEFAULT NULL,
  `amount` int(11) NOT NULL,
  `addnum` int(11) NOT NULL,
  `isFirstPay` int(11) NOT NULL,
  `request_time` varchar(64) COLLATE utf8_bin NOT NULL,
  `create_time` int(10) NOT NULL,
  `osversion` varchar(2048) COLLATE utf8_bin DEFAULT NULL,
  `channel` varchar(2048) COLLATE utf8_bin DEFAULT NULL,
  `os` varchar(2048) COLLATE utf8_bin DEFAULT NULL,
  `deviceId` varchar(2048) COLLATE utf8_bin DEFAULT NULL,
  `level` int(11) DEFAULT NULL,
  `phonetype` varchar(2048) COLLATE utf8_bin DEFAULT NULL,
  `currency` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  PRIMARY KEY (`CooOrderSerial`),
  KEY `playerId_index` (`playerId`) USING BTREE,
  KEY `goodsId_index` (`goodsId`) USING BTREE,
  KEY `deviceId_index` (`deviceId`(333))
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

-- --------------------------------------------------------

--
-- 表的结构 `relationship`
--

CREATE TABLE IF NOT EXISTS `relationship` (
  `playerid` int(11) NOT NULL,
  `friendids` text COLLATE utf8_bin,
  `enemyids` text COLLATE utf8_bin,
  `confirm` text COLLATE utf8_bin,
  `vialityids` text COLLATE utf8_bin,
  PRIMARY KEY (`playerid`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

-- --------------------------------------------------------

--
-- 表的结构 `repair_dragon_ball`
--

CREATE TABLE IF NOT EXISTS `repair_dragon_ball` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `playerId` int(11) NOT NULL,
  `playerName` varchar(64) NOT NULL,
  `termId` smallint(5) unsigned NOT NULL,
  `dragonBallCreditStr` varchar(255) NOT NULL,
  `rewardStateStr` varchar(255) NOT NULL DEFAULT '0',
  `totalCredit` int(10) unsigned NOT NULL DEFAULT '0',
  `totalCreditRefreshTime` bigint(20) unsigned NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 表的结构 `rewards`
--

CREATE TABLE IF NOT EXISTS `rewards` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `playerId` int(11) NOT NULL,
  `rewardType` int(11) NOT NULL,
  `rewardMsg` varchar(255) COLLATE utf8_bin DEFAULT NULL,
  `rewardInfo` varchar(512) COLLATE utf8_bin DEFAULT NULL,
  `rewardContent` varchar(4096) COLLATE utf8_bin DEFAULT NULL,
  `status` int(11) NOT NULL,
  `addTime` int(11) NOT NULL,
  `rewardTime` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `playerId_index` (`playerId`) USING BTREE,
  KEY `rewardType_index` (`rewardType`) USING BTREE
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

-- --------------------------------------------------------

--
-- 表的结构 `server_peak_war`
--

CREATE TABLE IF NOT EXISTS `server_peak_war` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `termId` int(11) DEFAULT NULL,
  `totalScore` int(11) DEFAULT NULL,
  `startTime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `currentStageId` int(11) DEFAULT NULL,
  `status` int(11) DEFAULT NULL,
  `scoreExchangeInfo` blob,
  `lastExchangeDate` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 表的结构 `server_tournment`
--

CREATE TABLE IF NOT EXISTS `server_tournment` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `startDate` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `isRefresh` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 表的结构 `skill`
--

CREATE TABLE IF NOT EXISTS `skill` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `playerid` int(11) NOT NULL,
  `itemid` int(11) NOT NULL,
  `type` int(11) NOT NULL,
  `level` int(11) NOT NULL,
  `quantity` float NOT NULL,
  `consume` int(11) NOT NULL,
  `battleid` int(11) NOT NULL,
  `isdefaultskill` int(11) NOT NULL,
  `expire_time` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `playerid_index` (`playerid`) USING BTREE,
  KEY `itemid_index` (`itemid`) USING BTREE
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

-- --------------------------------------------------------

--
-- 表的结构 `snatchfightinfo`
--

CREATE TABLE IF NOT EXISTS `snatchfightinfo` (
  `id` int(11) NOT NULL,
  `playerid` int(11) NOT NULL,
  `msgType` int(11) NOT NULL,
  `enemyId` int(11) NOT NULL,
  `enemyName` varchar(64) COLLATE utf8_bin NOT NULL,
  `enemyLevel` int(11) NOT NULL,
  `silverAmount` bigint(11) NOT NULL,
  `actionTime` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `playerid_index` (`playerid`) USING BTREE
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

-- --------------------------------------------------------

--
-- 表的结构 `snatchrank`
--

CREATE TABLE IF NOT EXISTS `snatchrank` (
  `id` int(11) NOT NULL,
  `playerid` int(11) NOT NULL,
  `rank` int(11) NOT NULL,
  `level` int(11) NOT NULL,
  `name` varchar(64) COLLATE utf8_bin NOT NULL,
  `scoreInLastWeek` int(11) NOT NULL,
  `rankTime` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `playerid_index` (`playerid`) USING BTREE
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

-- --------------------------------------------------------

--
-- 表的结构 `snatchstatus`
--

CREATE TABLE IF NOT EXISTS `snatchstatus` (
  `playerid` int(11) NOT NULL,
  `playerLevel` int(11) NOT NULL,
  `playerName` varchar(64) COLLATE utf8_bin NOT NULL,
  `todaySnatchAmount` bigint(11) NOT NULL,
  `snatchPlayerInfo` text COLLATE utf8_bin,
  `weekScore` int(11) NOT NULL,
  `lastWeekScore` int(11) NOT NULL,
  `snatchDate` int(11) NOT NULL,
  `fightStatus` int(11) NOT NULL,
  `scoreCheckTime` int(11) NOT NULL,
  PRIMARY KEY (`playerid`),
  KEY `playerid_index` (`playerid`) USING BTREE
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

-- --------------------------------------------------------

--
-- 表的结构 `soul`
--

CREATE TABLE IF NOT EXISTS `soul` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `itemid` int(11) NOT NULL,
  `playerid` int(11) NOT NULL,
  `count` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `playerid_index` (`playerid`) USING BTREE
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

-- --------------------------------------------------------

--
-- 表的结构 `statistics_daily`
--

CREATE TABLE IF NOT EXISTS `statistics_daily` (
  `date` varchar(32) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL,
  `totalUsers` int(11) NOT NULL DEFAULT '0',
  `totalDevice` int(11) NOT NULL DEFAULT '0',
  `totalPayUsers` int(11) NOT NULL DEFAULT '0',
  `totalPayDevice` int(11) NOT NULL DEFAULT '0',
  `totalPayMoney` int(11) NOT NULL DEFAULT '0',
  `newUsers` int(11) NOT NULL DEFAULT '0',
  `newDevice` int(11) NOT NULL DEFAULT '0',
  `dailyActiveUsers` int(11) NOT NULL DEFAULT '0',
  `userRetentionRate` float NOT NULL DEFAULT '0',
  `deviceRetentionRate` float NOT NULL DEFAULT '0',
  `payUsers` int(11) NOT NULL DEFAULT '0',
  `payDevice` int(11) NOT NULL DEFAULT '0',
  `payMoney` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`date`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 表的结构 `stats`
--

CREATE TABLE IF NOT EXISTS `stats` (
  `playerid` int(11) NOT NULL,
  `firstbaitime` int(11) NOT NULL DEFAULT '0',
  `firstwantime` int(11) NOT NULL DEFAULT '0',
  `buygifts` varchar(512) COLLATE utf8_bin NOT NULL,
  `discipleLucky` int(11) NOT NULL,
  `nextDisciple` int(11) NOT NULL,
  `discipleTimes` int(11) NOT NULL,
  `logincount` int(11) NOT NULL,
  `getreward` int(11) NOT NULL,
  `loginreward` varchar(64) COLLATE utf8_bin NOT NULL,
  `levelupreward` varchar(64) COLLATE utf8_bin DEFAULT '',
  `visitRewardCount` int(11) NOT NULL DEFAULT '0',
  `visitTimes` int(11) NOT NULL DEFAULT '0',
  `lastVisitTime` int(11) NOT NULL,
  `hasVisited` int(11) NOT NULL DEFAULT '0',
  `luckOne` int(11) NOT NULL,
  `luckTwo` int(11) NOT NULL,
  `treasureWorth` int(11) NOT NULL,
  `ameatfood` int(11) NOT NULL,
  `pmeatfood` int(11) NOT NULL,
  `challengetimes` int(11) NOT NULL,
  `luckPool` float NOT NULL,
  `adContinueInfo` varchar(128) COLLATE utf8_bin DEFAULT '{}',
  `cdkeyTypes` varchar(512) COLLATE utf8_bin DEFAULT NULL,
  `sysmsgTime` int(11) DEFAULT '0',
  `pieceskilltimes` int(11) NOT NULL DEFAULT '0',
  `getRebate` int(11) DEFAULT '0',
  `chargeHeap` int(11) DEFAULT '0',
  `chargeTerm` int(11) DEFAULT '0',
  `fortuneComeTimes` int(11) DEFAULT '0',
  `giveSoulTerm` int(11) DEFAULT '0',
  `giveSoulHeap2` int(11) DEFAULT '0',
  `giveSoulHeap3` int(11) DEFAULT '0',
  `giveSoulDifferTimes2` int(11) DEFAULT '0',
  `giveSoulDifferTimes3` int(11) DEFAULT '0',
  `fightEndTimes` int(11) DEFAULT '0',
  `luckyStarTermid` int(11) DEFAULT '0',
  `luckyStarDropTimes1` int(11) DEFAULT '0',
  `luckyStarDropTimes2` int(11) DEFAULT '0',
  `luckyStayHeap1` int(11) DEFAULT '0',
  `luckyStayHeap2` int(11) DEFAULT '0',
  `challengeActTermId` int(11) DEFAULT '0',
  `highestRankInAct` int(11) DEFAULT '0',
  `nextQuickCareerTime` int(11) DEFAULT '0',
  `deepWaterLastTimes` varchar(128) COLLATE utf8_bin DEFAULT '{}',
  `deepWaterHeap` varchar(128) COLLATE utf8_bin DEFAULT '{}',
  `deepWaterTermid` int(11) DEFAULT '0',
  `dwNextRefreshTime` int(11) DEFAULT '0',
  `wishtimes` int(11) DEFAULT '0',
  `lastselectdiscipleid` text COLLATE utf8_bin,
  `wishfirsttime` int(11) DEFAULT '0',
  `guardTimes` int(11) DEFAULT '0',
  `snatchTimes` int(11) DEFAULT '0',
  `luckydrawpoint` int(11) NOT NULL DEFAULT '0',
  `luckypointlastgottime` int(11) DEFAULT '0',
  `treasureLucky` text COLLATE utf8_bin NOT NULL,
  `discipleLucky2` int(11) DEFAULT '0',
  `discipleLucky3` int(11) DEFAULT '0',
  `badLuckyCount` int(11) DEFAULT '0',
  `snatchSkillInfo` text COLLATE utf8_bin,
  `vitalityfetchtimes` int(11) NOT NULL DEFAULT '0',
  `vitalityfetchlimit` int(11) NOT NULL DEFAULT '0',
  `isAlreadyBuyGrowthPlan` int(11) unsigned NOT NULL DEFAULT '0',
  `growthPlan` varchar(512) COLLATE utf8_bin DEFAULT '',
  `dailybuy` varchar(512) COLLATE utf8_bin DEFAULT '{}',
  `destiny` int(11) unsigned zerofill NOT NULL DEFAULT '00000000000',
  `snatchWarFreePeriod` int(11) unsigned NOT NULL DEFAULT '0',
  `onlineRewardStage` int(11) NOT NULL DEFAULT '0',
  `onlineRemainTime` int(11) NOT NULL DEFAULT '0',
  `wxLastShareTime` int(11) NOT NULL DEFAULT '0',
  `wxShareTimes` int(11) NOT NULL DEFAULT '0',
  `plunderMailBoxTime` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`playerid`),
  KEY `playerid_index` (`playerid`) USING BTREE
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

-- --------------------------------------------------------

--
-- 表的结构 `stronghold`
--

CREATE TABLE IF NOT EXISTS `stronghold` (
  `id` int(11) NOT NULL,
  `name` varchar(64) COLLATE utf8_bin NOT NULL,
  `ownerLeaguaId` int(11) NOT NULL,
  `ownerLeaguaMedal` int(11) NOT NULL,
  `ownerLeaguaName` varchar(64) COLLATE utf8_bin NOT NULL,
  `bid` text COLLATE utf8_bin NOT NULL,
  `attackLeagua` int(11) NOT NULL,
  `attackTotem` int(11) NOT NULL,
  `attackTotemlvl` int(11) NOT NULL,
  `attackScore` int(11) NOT NULL,
  `defenceLeagua` int(11) NOT NULL,
  `defenceTotem` int(11) NOT NULL,
  `defenceTotemlvl` int(11) NOT NULL,
  `defenceScore` int(11) NOT NULL,
  `battleMSG` varchar(512) COLLATE utf8_bin DEFAULT '{}',
  PRIMARY KEY (`id`),
  KEY `ownerLeaguaId_index` (`ownerLeaguaId`) USING BTREE
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

-- --------------------------------------------------------

--
-- 表的结构 `sysmsginfo`
--

CREATE TABLE IF NOT EXISTS `sysmsginfo` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `playerId` int(11) NOT NULL,
  `msgType` int(11) NOT NULL,
  `msgInfo` varchar(255) COLLATE utf8_bin DEFAULT '{}',
  `msgContent` text COLLATE utf8_bin,
  `status` int(11) NOT NULL DEFAULT '0',
  `addTime` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `UQ_sysmsginfo_id` (`id`) USING BTREE,
  KEY `playerId_index` (`playerId`) USING BTREE
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

-- --------------------------------------------------------

--
-- 表的结构 `treasure`
--

CREATE TABLE IF NOT EXISTS `treasure` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `playerId` int(11) NOT NULL,
  `itemId` int(11) NOT NULL,
  `type` int(11) NOT NULL,
  `level` int(11) NOT NULL,
  `exp` int(11) DEFAULT '0',
  `refineLevel` int(11) NOT NULL,
  `currentAttrValueStr` varchar(512) COLLATE utf8_bin DEFAULT '',
  `refineAttrValueStr` varchar(512) COLLATE utf8_bin DEFAULT '',
  PRIMARY KEY (`id`),
  KEY `playerid_index` (`playerId`) USING BTREE,
  KEY `itemId_index` (`itemId`) USING BTREE
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

-- --------------------------------------------------------

--
-- 表的结构 `treasurestate`
--

CREATE TABLE IF NOT EXISTS `treasurestate` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `playerId` int(11) NOT NULL DEFAULT '0',
  `luckType` int(11) NOT NULL DEFAULT '0',
  `luck` int(11) NOT NULL DEFAULT '0',
  `pool` int(11) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `playerid_index` (`playerId`) USING BTREE
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 表的结构 `warrior_challenge`
--

CREATE TABLE IF NOT EXISTS `warrior_challenge` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `playerId` int(11) DEFAULT '0',
  `fightTimes` int(11) DEFAULT NULL,
  `goldRefreshTimes` int(11) DEFAULT NULL,
  `termId` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=DYNAMIC;

-- --------------------------------------------------------

--
-- 表的结构 `worldboss`
--

CREATE TABLE IF NOT EXISTS `worldboss` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `totalHealth` bigint(20) NOT NULL,
  `leftHealth` bigint(20) NOT NULL,
  `killedTime` int(11) NOT NULL,
  `lastRefreshTime` int(11) NOT NULL,
  `killerId` int(11) NOT NULL,
  `killerName` varchar(64) COLLATE utf8_bin NOT NULL,
  `killerLevel` int(11) NOT NULL,
  `killerDamage` int(11) NOT NULL,
  `date` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `date_index` (`date`) USING BTREE
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

-- --------------------------------------------------------

--
-- 表的结构 `worldbossrank`
--

CREATE TABLE IF NOT EXISTS `worldbossrank` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `playerid` int(11) NOT NULL,
  `rank` int(11) NOT NULL,
  `level` int(11) NOT NULL,
  `name` varchar(64) COLLATE utf8_bin NOT NULL,
  `damage` int(11) NOT NULL,
  `ranktime` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `playerid_index` (`playerid`) USING BTREE,
  KEY `ranktime_index` (`ranktime`) USING BTREE
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

-- --------------------------------------------------------

--
-- 表的结构 `worldboss_alliance_rank`
--

CREATE TABLE IF NOT EXISTS `worldboss_alliance_rank` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `allianceId` int(11) NOT NULL,
  `damageAmount` int(11) NOT NULL,
  `damagePlayerIds` varchar(256) NOT NULL DEFAULT '',
  `rankTime` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- 表的结构 `worship`
--

CREATE TABLE IF NOT EXISTS `worship` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `player_id` int(11) DEFAULT '0',
  `worship_stamp` int(11) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `playerid_index` (`player_id`) USING BTREE
) ENGINE=MyISAM DEFAULT CHARSET=utf8;

--
-- 表的结构 `limittimerefresh`
--

CREATE TABLE IF NOT EXISTS `limittimerefresh` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `itemId` int(11) NOT NULL,
  `open` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8;

