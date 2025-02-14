--
-- 数据库: `downloadOrder`
--

-- --------------------------------------------------------

--
-- 表的结构 `do_user`
--

CREATE TABLE IF NOT EXISTS `do_user` (
  `user_id` int(11) NOT NULL AUTO_INCREMENT COMMENT '用户id',
  `user_name` varchar(64) NOT NULL COMMENT '用户登录名',
  `user_password` varchar(64) NOT NULL COMMENT '密码',
  `user_real_name` varchar(64) NOT NULL COMMENT '真实姓名',
  `user_role` tinyint(2) NOT NULL DEFAULT '0' COMMENT '0普通,1管理员',
  `user_games` varchar(512) NOT NULL COMMENT '用户权限组',
  `create_time` int(11) NOT NULL COMMENT '创建时间',
  PRIMARY KEY (`user_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=utf8 COMMENT='用户表';

--
-- 导出表中的数据 `cs_user` 账号 admin 密码 admin@888
--

INSERT INTO `do_user` (`user_id`, `user_name`, `user_password`, `user_real_name`, `user_role`, `user_games`, `create_time`) VALUES
(1, 'admin', '3c9e24da54081a18c7fec702b4df5a00', '管理员', 1, 'hwgj', 1419579323);

INSERT INTO `do_user` (`user_id`, `user_name`, `user_password`, `user_real_name`, `user_role`, `user_games`, `create_time`) VALUES
(2, 'test', 'e10adc3949ba59abbe56e057f20f883e', '管理员', 1, 'hwgj', 1419579323);