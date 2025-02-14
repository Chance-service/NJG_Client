<?php /* Smarty version 2.6.18, created on 2015-05-11 12:16:19
         compiled from left.html */ ?>
		<div class="main-container" id="main-container">
			<script type="text/javascript">
				try{ace.settings.check('main-container' , 'fixed')}catch(e){}
			</script>

			<div class="main-container-inner">
		 
				<a class="menu-toggler" id="menu-toggler" href="javascript:void(0);">
					<span class="menu-text"></span>
				</a>
		
				<div class="sidebar" id="sidebar">
					<script type="text/javascript">
						try{ace.settings.check('sidebar' , 'fixed')}catch(e){}
					</script>

					<div class="sidebar-shortcuts" id="sidebar-shortcuts">
<!--  					<div class="sidebar-shortcuts-large" id="sidebar-shortcuts-large">
							<button class="btn btn-success">
								<i class="icon-signal"></i>
							</button>

							<button class="btn btn-info">
								<i class="icon-pencil"></i>
							</button>

							<button class="btn btn-warning">
								<i class="icon-group"></i>
							</button>

							<button class="btn btn-danger">
								<i class="icon-cogs"></i>
							</button>
						</div>
-->
						<div class="sidebar-shortcuts-mini" id="sidebar-shortcuts-mini">
							<span class="btn btn-success"></span>

							<span class="btn btn-info"></span>

							<span class="btn btn-warning"></span>

							<span class="btn btn-danger"></span>
						</div>
					</div><!-- #sidebar-shortcuts -->

					<ul class="nav nav-list">
						<li class="active">
							<a href="index.php">
								<i class="icon-dashboard"></i>
								<span class="menu-text"> 首页 </span>
							</a>
						</li>
					
						<li id="data">
							<a href="javascript:void(0);" class="dropdown-toggle">
								<i class="icon-hdd"></i>
								<span class="menu-text">数据查询 </span>

								<b class="arrow icon-angle-down"></b>
							</a>
						
							<ul class="submenu"  style="display:block;">
									<li id="data_showStatData">
									<a href="index.php?mod=Data&do=showStatData">
										<i class="icon-double-angle-right"></i>
										历史数据查询
									</a>
								</li>	
								<li id="data_showData">
									<a href="index.php?mod=Data&amp;do=showData">
										<i class="icon-double-angle-right"></i>
										实时数据查询
									</a>
								</li>
								
								<li id="data_showHistory">
									<a href="index.php?mod=Data&do=showHistory">
										<i class="icon-double-angle-right"></i>
										历史数据重算
									</a>
								</li>
								
								<li id="data_getPlatformData">
									<a href="index.php?mod=Data&do=getPlatformData">
										<i class="icon-double-angle-right"></i>
										分类数据查询
									</a>
								</li>
								
							</ul>
						</li>
					
					<li id="recharge">
							<a href="javascript:void(0);" class="dropdown-toggle">
								<i class="icon-list-alt"></i>
								<span class="menu-text">订单查询 </span>

								<b class="arrow icon-angle-down"></b>
							</a>
						
							<ul class="submenu"  style="display:block;">
										
								<li id="recharge_fetchOrder">
									<a href="index.php?mod=Recharge&do=fetchOrder">
										<i class="icon-double-angle-right"></i>
										单个订单查询
									</a>
								</li>
								
								
								<li id="recharge_fetchRecharge">
									<a href="index.php?mod=Recharge&do=fetchOrderByPuid">
										<i class="icon-double-angle-right"></i>
										用户订单查询
									</a>
								</li>
						
							
								<li id="recharge_fetchBills">
									<a href="index.php?mod=Recharge&do=fetchBills">
										<i class="icon-double-angle-right"></i>
										渠道订单查询
									</a>
								</li>
					
										
							</ul>
						</li>
						
					<li id="cdk">
							<a href="javascript:void(0);" class="dropdown-toggle">
								<i class="icon-key"></i>
								<span class="menu-text">CDK操作 </span>

								<b class="arrow icon-angle-down"></b>
							</a>
						
							<ul class="submenu"  style="display:block;">
										
								<li id="cdk_create">
									<a href="index.php?mod=Cdk&do=create">
										<i class="icon-double-angle-right"></i>
										生成CDK
									</a>
								</li>
								
								
								<li id="cdk_select">
									<a href="index.php?mod=Cdk&do=cdkOperate">
										<i class="icon-double-angle-right"></i>
										CDK操作
									</a>
								</li>
						
							
								<li id="cdk_cdkUse">
									<a href="index.php?mod=Cdk&do=cdkUse">
										<i class="icon-double-angle-right"></i>
										CDK查询
									</a>
								</li>
								
					
										
							</ul>
						</li>
						
						<li id="DataAnalysis">
							<a href="javascript:void(0);" class="dropdown-toggle">
								<i class="icon-align-justify"></i>
								<span class="menu-text">数据分析 </span>

								<b class="arrow icon-angle-down"></b>
							</a>
						
							<ul class="submenu"  style="display:block;">
									<li id="goldSource">
									<a href="index.php?mod=DataAnalysis&do=goldSource&action=0">
										<i class="icon-double-angle-right"></i>
										钻石来源分布
									</a>
								</li>	
								<li id="goldUse">
									<a href="index.php?mod=DataAnalysis&do=goldUse&action=0">
										<i class="icon-double-angle-right"></i>
										钻石消耗分布
									</a>
								</li>
								
								<li id="tutorialStep">
									<a href="index.php?mod=DataAnalysis&do=tutorialStep&action=0">
										<i class="icon-double-angle-right"></i>
										新手步骤分布
									</a>
								</li>
								
								<li id="tutorialLevel">
									<a href="index.php?mod=DataAnalysis&do=tutorialLevel&action=0">
										<i class="icon-double-angle-right"></i>
										新手等级分布
									</a>
								</li>
								
							</ul>
						</li>
						<li id="Gm">
							<a href="javascript:void(0);" class="dropdown-toggle">
								<i class="icon-cog"></i>
								<span class="menu-text"> GM相关 </span>

								<b class="arrow icon-angle-down"></b>
							</a>
						
							<ul class="submenu"  style="display:block;">
				
								<li id="Gm_selectUserInfo">
									<a href="index.php?mod=Gm&do=selectUserInfo&action=1&game=<?php echo $this->_tpl_vars['nowGame']; ?>
">
										<i class="icon-double-angle-right"></i>
										用户操作相关
									</a>
								</li>
								<!-- 
								<li id="Gm_synthesisinfo">
									<a href="index.php?mod=Gm&do=synthesisinfo&action=0">
										<i class="icon-double-angle-right"></i>
										留存信息查询
									</a>
								</li>
								<li id="Gm_newly">
									<a href="index.php?mod=Gm&do=newly&action=0">
										<i class="icon-double-angle-right"></i>
										设备新增查询
									</a>
								</li>
								-->	
							</ul>
						</li>
<!--  						
					<?php if ($this->_tpl_vars['actionlogUrl']): ?>	
					 <li id="Action">
							<a href="javascript:void(0);" class="dropdown-toggle">
								<i class="icon-book"></i>
								<span class="menu-text"> 行为日志入口 </span>
								<b class="arrow icon-angle-down"></b>
							</a>
						
							<ul class="submenu"  style="display:block;">
									
							   <?php $_from = $this->_tpl_vars['actionlogUrl']; if (!is_array($_from) && !is_object($_from)) { settype($_from, 'array'); }if (count($_from)):
    foreach ($_from as $this->_tpl_vars['key'] => $this->_tpl_vars['value']):
?>	
								<li id="Action_selectUserInfo">
									<a target="_blank" href="<?php echo $this->_tpl_vars['value']; ?>
">
										<i class="icon-double-angle-right"></i>
										<?php echo $this->_tpl_vars['key']; ?>
行为日志
									</a>
								</li>
								<?php endforeach; endif; unset($_from); ?>
							</ul>
						</li>
					<?php endif; ?>	
-->						
			    <?php if ($this->_tpl_vars['userRole'] && $this->_tpl_vars['userRole'] == 1): ?>		
				
						<li id="power">
							<a href="javascript:void(0);" class="dropdown-toggle">
								<i class="icon-user"></i>
								<span class="menu-text"> 系统管理 </span>

								<b class="arrow icon-angle-down"></b>
							</a>
						
							<ul class="submenu"  style="display:block;">
				
									<li id="power_addUser">
									<a href="index.php?mod=User&do=add">
										<i class="icon-double-angle-right"></i>
										添加用户
									</a>
								</li>
								
								<li id="power_manageUser">
									<a href="index.php?mod=User&do=manage">
										<i class="icon-double-angle-right"></i>
										用户管理
									</a>
								</li> 
				<!--  		 		
								<li id="power_addGame">
									<a href="index.php?mod=Game&do=addGame">
										<i class="icon-double-angle-right"></i>
										添加游戏
									</a>
								</li>
								
								<li id="power_manageGame">
									<a href="index.php?mod=Game&do=showGameList">
										<i class="icon-double-angle-right"></i>
										游戏管理
									</a>
								</li>
					-->			
							</ul>
						</li>
					<?php endif; ?>	
							
					</ul><!-- /.nav-list -->

					<div class="sidebar-collapse" id="sidebar-collapse">
						<i class="icon-double-angle-left" data-icon1="icon-double-angle-left" data-icon2="icon-double-angle-right"></i>
					</div>

					<script type="text/javascript">
						try{ace.settings.check('sidebar' , 'collapsed')}catch(e){}
					</script>
				</div>