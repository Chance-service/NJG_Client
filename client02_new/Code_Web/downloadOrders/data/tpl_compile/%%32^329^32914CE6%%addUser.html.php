<?php /* Smarty version 2.6.18, created on 2015-03-24 15:01:45
         compiled from addUser.html */ ?>
<?php $_smarty_tpl_vars = $this->_tpl_vars;
$this->_smarty_include(array('smarty_include_tpl_file' => "header.html", 'smarty_include_vars' => array()));
$this->_tpl_vars = $_smarty_tpl_vars;
unset($_smarty_tpl_vars);
 ?>
<?php $_smarty_tpl_vars = $this->_tpl_vars;
$this->_smarty_include(array('smarty_include_tpl_file' => "top.html", 'smarty_include_vars' => array()));
$this->_tpl_vars = $_smarty_tpl_vars;
unset($_smarty_tpl_vars);
 ?>
<?php $_smarty_tpl_vars = $this->_tpl_vars;
$this->_smarty_include(array('smarty_include_tpl_file' => "left.html", 'smarty_include_vars' => array()));
$this->_tpl_vars = $_smarty_tpl_vars;
unset($_smarty_tpl_vars);
 ?>
				<div class="main-content">
					<div class="breadcrumbs" id="breadcrumbs">
						<script type="text/javascript">
							try{ace.settings.check('breadcrumbs' , 'fixed')}catch(e){}
						</script>

						<ul class="breadcrumb">
							<li>
								<i class="icon-home home-icon"></i>
								<a href="#">权限管理</a>
							</li>
							<li class="active"><a href="javascript:void(0);">添加用户</a></li>
						</ul><!-- .breadcrumb -->
					</div>

				<div class="page-content">
						<div class="row">
							<div class="col-xs-12">
								<!-- PAGE CONTENT BEGINS -->
								
								<div class="row">
									<div class="col-sm-12">
										<div class="widget-box">
											<div class="widget-header header-color-blue2">
												<h4 class="lighter smaller"></h4>
											</div>

											<div class="widget-body">
												<div class="widget-main padding-8">
												
													<form class="form-horizontal" role="form">
														<br/>
											
														<div class="form-group">
															<label class="col-sm-4 control-label no-padding-right" for="form-field-5">用户名:</label>
															 

															<div class="col-sm-6">
																<input type="text" id="form-field-1" class="col-xs-3 col-sm-5">
															</div>
														</div>
														<div class="form-group">
															<label class="col-sm-4 control-label no-padding-right" for="form-field-5">密　码:</label>

															<div class="col-sm-6">
																<input type="text" id="form-field-2" class="col-xs-3 col-sm-5">
															</div>
														</div>
														
													 <div class="form-group">
															<label class="col-sm-4 control-label no-padding-right" for="form-field-5">姓　名:</label>

															<div class="col-sm-6">
																<input type="text" id="form-field-3" class="col-xs-3 col-sm-5">
															</div>
														</div>
														
													
													<div class="form-group">
													<label class="col-sm-4 control-label no-padding-right" for="form-field-5">角　色:</label>	
														
														<div class="col-sm-6">
														<select class="col-xs-10 col-sm-5" id="selectRole">
																<option value="">选择角色</option>
																<option value="0" >普通用户</option>
																<option value="1" >管理员</option>
															
														</select>
														</div>
													</div>	
												
																
												<div class="form-group">
															<label class="col-sm-4 control-label no-padding-right" for="form-field-5"></label>
															<div class="col-sm-6">
					<!--  
												<div class="form-group">
													<?php if ($this->_tpl_vars['game']): ?>
													<?php $_from = $this->_tpl_vars['game']; if (!is_array($_from) && !is_object($_from)) { settype($_from, 'array'); }if (count($_from)):
    foreach ($_from as $this->_tpl_vars['k'] => $this->_tpl_vars['game']):
?>
													
													<?php if ($this->_tpl_vars['k'] > 0 && $this->_tpl_vars['k']%4 == 0): ?>
													  <br/><br/>
													 <?php endif; ?>
													&nbsp;
													<input  name="checkboxs" type="checkbox" class="ace ace-checkbox-2" id="game_<?php echo $this->_tpl_vars['game']['game']; ?>
"   value = "<?php echo $this->_tpl_vars['game']['game']; ?>
" />
													<label style="width:80px;" class="lbl" for="ace-settings-navbar">&nbsp;<?php echo $this->_tpl_vars['game']['game']; ?>
</label>
													&nbsp;
													
													<?php endforeach; endif; unset($_from); ?>
													<?php endif; ?>	
						
												</div>
							-->					
																		
													</div>				
													</div>			
												
													</form>
													
													<h3 class="header smaller lighter green"></h3>
													<div class="clearfix">
														<label class="col-sm-5 control-label no-padding-right" for="form-field-5"></label>
															<button type="button" onclick = "addUser();" class="btn btn-info btn-success">
																<!--<i class="icon-bolt"></i>-->
																添加
															</button>
													
													</div>
												</div>
											</div>
										</div>
									</div>
								</div>
								
								<!-- PAGE CONTENT ENDS -->
							</div><!-- /.col -->
						</div><!-- /.row -->
					</div><!-- /.page-content -->
				</div><!-- /.main-content -->
				
				
				</div><!-- /.main-content -->
<?php $_smarty_tpl_vars = $this->_tpl_vars;
$this->_smarty_include(array('smarty_include_tpl_file' => "footer.html", 'smarty_include_vars' => array()));
$this->_tpl_vars = $_smarty_tpl_vars;
unset($_smarty_tpl_vars);
 ?>
