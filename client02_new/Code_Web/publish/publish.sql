--
-- 数据库: `lol_publish`
--
CREATE DATABASE `lol_publish` DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;
USE `lol_publish`;

-- --------------------------------------------------------

--
-- 表的结构 `lp_game`
--

CREATE TABLE IF NOT EXISTS `lp_game` (
  `game_id` int(11) unsigned NOT NULL AUTO_INCREMENT COMMENT '游戏自增id',
  `game_name` varchar(50) NOT NULL COMMENT '游戏名称',
  `game_tag` varchar(50) NOT NULL COMMENT '游戏标识',
  `game_checkout_url` varchar(100) NOT NULL COMMENT '游戏代码简称地址',
  `game_svn_user_name` varchar(30) NOT NULL COMMENT '代码检出svn用户名',
  `game_svn_password` varchar(30) NOT NULL COMMENT '代码检出svn密码',
  `game_time` int(11) unsigned NOT NULL COMMENT '游戏添加时间',
  PRIMARY KEY (`game_id`),
  KEY `game_tag` (`game_tag`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COMMENT='游戏管理表';

-- --------------------------------------------------------
--
-- 导出表中的数据 `lp_game`			初始化 默认两个游戏
--

INSERT INTO `lp_game` (`game_id`, `game_name`, `game_tag`, `game_checkout_url`, `game_svn_user_name`, `game_svn_password`, `game_time`) VALUES
(1, 'LOL', 'lol', 'http://123.com', 'abc', '123', 1405510194);

--
-- 表的结构 `lp_group`
--

CREATE TABLE IF NOT EXISTS `lp_group` (
  `group_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT '用户组id',
  `group_name` char(20) NOT NULL COMMENT '用户组名称',
  `group_permission` text NOT NULL COMMENT '用户权限（序列化数据）',
  `group_dec` varchar(256) NOT NULL COMMENT '注释',
  PRIMARY KEY (`group_id`)
) ENGINE=MyISAM  DEFAULT CHARSET=gbk AUTO_INCREMENT=22 ;

-- --------------------------------------------------------

--
-- 表的结构 `lp_log`
--

CREATE TABLE IF NOT EXISTS `lp_log` (
  `log_id` int(11) unsigned NOT NULL AUTO_INCREMENT COMMENT '自增id',
  `log_game_name` varchar(50) NOT NULL COMMENT '发布的游戏名称',
  `log_platforms` varchar(200) NOT NULL COMMENT '发布的平台',
  `log_version` varchar(30) NOT NULL COMMENT '发布的版本',
  `log_server_id` int(11) unsigned NOT NULL COMMENT '发布服的id',
  `log_server_name` varchar(200) NOT NULL COMMENT '发布的服名称',
  `log_number` tinyint(5) unsigned NOT NULL COMMENT '当日发布的次数',
  `log_date` varchar(20) NOT NULL COMMENT '发布的日期',
  `log_time` int(11) unsigned NOT NULL COMMENT '发布的时间戳',
  `log_publish_user` varchar(50) NOT NULL COMMENT '发布人',
  PRIMARY KEY (`log_id`),
  KEY `log_game_id` (`log_game_name`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COMMENT='发布日志';

-- --------------------------------------------------------

--
-- 导出表中的数据 `lp_group` 默认 id 为 1 和 2的游戏 全局管理可以发布
--

INSERT INTO `lp_group` (`group_id`, `group_name`, `group_permission`, `group_dec`) VALUES
(1, '全局管理员权限', '{"manageUser":"1","manageGame":"1","manageServer":"1","managePlatform":"1"}', '最高权限超级管理员组');

--
-- 表的结构 `lp_platform`
--

CREATE TABLE IF NOT EXISTS `lp_platform` (
  `pl_id` int(11) unsigned NOT NULL AUTO_INCREMENT COMMENT '平台自增id',
  `pl_tag` varchar(50) NOT NULL COMMENT '平台标识',
  `pl_name` varchar(50) NOT NULL COMMENT '平台名字',
  `pl_time` int(11) NOT NULL COMMENT '添加时间',
  PRIMARY KEY (`pl_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COMMENT='平台表';

-- --------------------------------------------------------

--
-- 表的结构 `lp_server`
--

CREATE TABLE IF NOT EXISTS `lp_server` (
  `s_id` int(11) unsigned NOT NULL AUTO_INCREMENT COMMENT '服务器自增id',
  `s_game_id` int(11) NOT NULL COMMENT '所属游戏id',
  `s_platforms` varchar(200) NOT NULL COMMENT '所属平台',
  `s_tag` varchar(50) NOT NULL COMMENT '服务器标识',
  `s_name` varchar(50) NOT NULL COMMENT '服务器名称',
  `s_version` varchar(30) NOT NULL COMMENT '发布的版本',
  `s_online_dir` varchar(200) NOT NULL COMMENT '发布到线上服务器的目录',
  `s_ip` varchar(30) NOT NULL COMMENT '线上服务器ip',
  `s_user` varchar(50) NOT NULL COMMENT '线上服务器用户名',
  `s_port` varchar(30) NOT NULL COMMENT '线上服务器ssh登录端口',
  `s_time` int(11) NOT NULL COMMENT '添加时间',
  PRIMARY KEY (`s_id`),
  KEY `s_game_id` (`s_game_id`,`s_time`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COMMENT='发布服务器信息';

-- --------------------------------------------------------

--
-- 表的结构 `lp_user`
--

CREATE TABLE IF NOT EXISTS `lp_user` (
  `user_id` int(10) unsigned NOT NULL AUTO_INCREMENT COMMENT '用户id',
  `user_name` char(20) NOT NULL COMMENT '用户名字',
  `user_password` char(32) NOT NULL COMMENT '用户密码',
  `user_realName` varchar(128) NOT NULL COMMENT '用户真实姓名',
  `group_id` int(10) unsigned NOT NULL COMMENT '用户组',
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `user_name` (`user_name`)
) ENGINE=MyISAM  DEFAULT CHARSET=gbk;
INSERT INTO `lp_user` (`user_id`, `user_name`, `user_password`, `user_realName`, `group_id`) VALUES
(1, 'publishAdmin', 'af39f5a8510bcf13ca6028afe389cb2d','管理员', 1);

-- --------------------------------------------------------

--
-- 表的结构 `lp_onoff_log`
--

CREATE TABLE IF NOT EXISTS `lp_onoff_log` (
`log_id` int(11) unsigned NOT NULL COMMENT '自增id',
  `log_game_name` varchar(50) NOT NULL COMMENT '发布的游戏名称',
  `log_platforms` varchar(200) NOT NULL COMMENT '发布的平台',
  `log_version` varchar(30) NOT NULL COMMENT '发布的版本',
  `log_server_id` int(11) unsigned NOT NULL COMMENT '发布服的id',
  `log_server_name` varchar(200) NOT NULL COMMENT '发布的服名称',
  `log_type` varchar(20) NOT NULL COMMENT 'on表示开服，off 表示停服',
  `log_number` tinyint(5) unsigned NOT NULL COMMENT '当日发布的次数',
  `log_date` varchar(20) NOT NULL COMMENT '发布的日期',
  `log_time` int(11) unsigned NOT NULL COMMENT '发布的时间戳',
  `log_user` varchar(50) NOT NULL COMMENT '操作人'
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COMMENT='发布日志';

--
-- Indexes for dumped tables
--

--
-- Indexes for table `lp_onoff_log`
--
ALTER TABLE `lp_onoff_log`
 ADD PRIMARY KEY (`log_id`), ADD KEY `log_game_id` (`log_game_name`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `lp_onoff_log`
--
ALTER TABLE `lp_onoff_log`
MODIFY `log_id` int(11) unsigned NOT NULL AUTO_INCREMENT COMMENT '自增id',AUTO_INCREMENT=4;