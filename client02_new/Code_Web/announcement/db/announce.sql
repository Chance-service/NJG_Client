--
-- Database: `announce`
--
CREATE DATABASE IF NOT EXISTS `announce` DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;
USE `announce`;

-- --------------------------------------------------------

--
-- 表的结构 `a_game`
--

CREATE TABLE IF NOT EXISTS `a_game` (
`game_id` int(11) NOT NULL COMMENT '游戏id',
  `game_tag` varchar(8) NOT NULL COMMENT '游戏标识',
  `game_name` varchar(16) NOT NULL COMMENT '游戏名称',
  `game_area` varchar(256) NOT NULL COMMENT '所属分类',
  `game_lang` varchar(512) DEFAULT NULL COMMENT '语种'
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COMMENT='游戏表' AUTO_INCREMENT=9 ;

--
-- 转存表中的数据 `a_game`
--

INSERT INTO `a_game` (`game_id`, `game_tag`, `game_name`, `game_area`, `game_lang`) VALUES
(2, 'hwgj', '海外挂机', 'efun,r2,jp,ethe', 'r2_English,French,German,Spanish,Portu,Turkish,Russian');

-- --------------------------------------------------------

--
-- 表的结构 `a_user`
--

CREATE TABLE IF NOT EXISTS `a_user` (
`user_id` int(11) NOT NULL COMMENT '用户id',
  `user_name` varchar(64) NOT NULL COMMENT '用户登录名',
  `user_password` varchar(64) NOT NULL COMMENT '密码',
  `user_real_name` varchar(64) NOT NULL COMMENT '真实姓名',
  `user_role` tinyint(2) NOT NULL DEFAULT '0' COMMENT '0普通,1管理员',
  `user_games` varchar(512) NOT NULL COMMENT '用户权限组',
  `user_areas` varchar(256) NOT NULL COMMENT 'areas "|"',
  `create_time` int(11) NOT NULL COMMENT '创建时间'
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COMMENT='用户表' AUTO_INCREMENT=7 ;

--
-- 转存表中的数据 `a_user`
--

INSERT INTO `a_user` (`user_id`, `user_name`, `user_password`, `user_real_name`, `user_role`, `user_games`, `user_areas`, `create_time`) VALUES
(1, 'admin', '3c9e24da54081a18c7fec702b4df5a00', '管理员', 1, 'hwgj', 'efun,r2,jp,ethe|0', 1419579323),
(6, 'test', 'e10adc3949ba59abbe56e057f20f883e', '测试', 1, 'hwgj,wow', 'efun,r2,jp,ethe|ios,app', 1426922307);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `a_game`
--
ALTER TABLE `a_game`
 ADD PRIMARY KEY (`game_id`), ADD KEY `game_tag` (`game_tag`);

--
-- Indexes for table `a_user`
--
ALTER TABLE `a_user`
 ADD PRIMARY KEY (`user_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `a_game`
--
ALTER TABLE `a_game`
MODIFY `game_id` int(11) NOT NULL AUTO_INCREMENT COMMENT '游戏id',AUTO_INCREMENT=9;
--
-- AUTO_INCREMENT for table `a_user`
--
ALTER TABLE `a_user`
MODIFY `user_id` int(11) NOT NULL AUTO_INCREMENT COMMENT '用户id',AUTO_INCREMENT=7;

