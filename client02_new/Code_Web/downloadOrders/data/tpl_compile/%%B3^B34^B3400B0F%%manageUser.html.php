<?php /* Smarty version 2.6.18, created on 2015-03-24 15:03:03
         compiled from manageUser.html */ ?>
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
							<li>
								<a href="#">管理用户</a>
							</li>
						</ul><!-- .breadcrumb -->
					</div>

						<div class="page-content">

							<div class="row">
								<div class="col-xs-12">
									<!-- PAGE CONTENT BEGINS -->

									<div class="alert alert-info">
										<i class="icon-hand-right"></i>

										<strong class="red">请注意：</strong><i class="icon-pencil bigger-120"></i> 为编辑，<i class="icon-trash bigger-120"></i> 为删除
										<button class="close" data-dismiss="alert">
											<i class="icon-remove"></i>
										</button>
									</div>
									<div class="table-header">
									
										<a style="display:none" id="mkdir" href="index.php?mod=User&do=add"  class="pull-left"> -->
													<font class="white"><i class="icon-user-md"></i>&nbsp;添加用户 
													 </font>
								</a>
									
							  	<button class="btn btn-primary"  onclick="document.getElementById('mkdir').click();return false;" >
							<!--  		<a  href="index.php?mod=Bucket&do=makeDir&bucketId=<?php echo $this->_tpl_vars['bucketId']; ?>
&parentNodeId=<?php echo $this->_tpl_vars['parentNodeId']; ?>
"  class="pull-left"> -->
													<font class="white"><i class="icon-user-md"></i>&nbsp;添加用户   
													 </font>
							<!--		</a> -->
								</button>
									
									
									&nbsp;&nbsp;&nbsp;&nbsp;</div>

									<div class="table-responsive">
										<table id="sample-table-1" class="table table-striped table-bordered table-hover">
											<thead>
												<tr>
													<th>用户id</th>
													<th>登录名</th>
													<th >姓名</th>
													<th>用户角色</th>
													<th >添加时间</th>
													<th>操作</th>
												</tr>
											</thead>

											<tbody>
											<?php if ($this->_tpl_vars['userList']): ?>
											<?php $_from = $this->_tpl_vars['userList']; if (!is_array($_from) && !is_object($_from)) { settype($_from, 'array'); }if (count($_from)):
    foreach ($_from as $this->_tpl_vars['userId'] => $this->_tpl_vars['user']):
?>
												<tr>
													<td><?php echo $this->_tpl_vars['user']['user_id']; ?>
</td>
													<td><?php echo $this->_tpl_vars['user']['user_name']; ?>
</td>
													<td><?php echo $this->_tpl_vars['user']['user_real_name']; ?>
</td>
													
													<td class="hidden-480"><?php echo $this->_tpl_vars['user']['user_role']; ?>
</td>
													<td><?php echo $this->_tpl_vars['user']['create_time']; ?>
</td>
													<td>
														<div class="visible-md visible-lg hidden-sm hidden-xs action-buttons">
															<a class="green" href="index.php?mod=User&do=edit&user_id=<?php echo $this->_tpl_vars['user']['user_id']; ?>
" >
																<i class="icon-pencil bigger-130"></i>&nbsp;编辑
															</a>

															<a class="red" href="javascript:if(confirm('确认删除吗?'))window.location='index.php?mod=User&do=delete&user_id=<?php echo $this->_tpl_vars['user']['user_id']; ?>
'" >
																<i class="icon-trash bigger-130"></i>&nbsp;删除
															</a>
														</div>
														<div class="visible-xs visible-sm hidden-md hidden-lg">
															<div class="inline position-relative">
																<button class="btn btn-minier btn-yellow dropdown-toggle" data-toggle="dropdown">
																	<i class="icon-caret-down icon-only bigger-120"></i>
																</button>

																<ul class="dropdown-menu dropdown-only-icon dropdown-yellow pull-right dropdown-caret dropdown-close">
																	<li>
																		<a href="javascript:void(0);" class="tooltip-success" data-rel="tooltip" title="" data-original-title="Edit">
																			<span class="green">
																				<i class="icon-edit bigger-120"></i>
																			</span>
																		</a>
																	</li>

																	<li>
																		<a href="javascript:void(0);" class="tooltip-error" data-rel="tooltip" title="" data-original-title="Delete">
																			<span class="red">
																				<i class="icon-trash bigger-120"></i>
																			</span>
																		</a>
																	</li>
																</ul>
															</div>
														</div>
													</td>
												</tr>
												<?php endforeach; endif; unset($_from); ?>
												<?php endif; ?>
											</tbody>
										</table>
										<?php if ($this->_tpl_vars['msg']): ?>
											<?php echo $this->_tpl_vars['msg']; ?>

										<?php endif; ?>
									</div><!-- /.table-responsive -->
								</div>
							</div><!-- /.row -->
					</div><!-- /.page-content -->
				</div><!-- /.main-content -->
			
<?php $_smarty_tpl_vars = $this->_tpl_vars;
$this->_smarty_include(array('smarty_include_tpl_file' => "footer.html", 'smarty_include_vars' => array()));
$this->_tpl_vars = $_smarty_tpl_vars;
unset($_smarty_tpl_vars);
 ?>
