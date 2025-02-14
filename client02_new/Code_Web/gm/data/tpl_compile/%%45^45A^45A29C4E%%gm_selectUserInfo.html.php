<?php /* Smarty version 2.6.18, created on 2015-04-25 18:36:14
         compiled from gm_selectUserInfo.html */ ?>
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

<style>

input[type=checkbox].ace, input[type=radio].ace {
opacity: 0;
position: absolute;
z-index: 12;
width: 18px;
height: 38px;
cursor: pointer;
}

.table-header {
background-color: #307ecc;
color: #FFF;
font-size: 14px;
line-height: 35px;
padding-left: 12px;
margin-bottom: 1px;
padding-bottom:2px;
}

.comments {  
 width:100%;/*自动适应父布局宽度*/  
 overflow:auto;  
 word-break:break-all; 
 border-color:#307ecc;
 float:left;
 }
 
.table th, .table td { 
	text-align: center; 
}
</style>
<div class="main-content">
<div class="breadcrumbs" id="breadcrumbs"><script
	type="text/javascript">
	try {
		ace.settings.check('breadcrumbs', 'fixed')
	} catch (e) {
	}
</script>

<ul class="breadcrumb">
	<li><i class="icon-home home-icon"></i> <a
		href="index.php">首页</a></li>
</ul>
<!-- .breadcrumb --></div>

<div class="page-content">
<div class="col-xs-12">
<center>
<div style="width:60%;" class="alert alert-info">
<form class="form-horizontal" role="form">
<div class="row">
<div class="col-sm-6">
<div class="row">
<label class="col-sm-6 control-label no-padding-right" for="form-field-5">游戏</label>
<div class="col-sm-3"><select id="selectGame">
	<option value="" >游戏</option>
	<?php if ($this->_tpl_vars['selectGames']): ?> <?php $_from = $this->_tpl_vars['selectGames']; if (!is_array($_from) && !is_object($_from)) { settype($_from, 'array'); }if (count($_from)):
    foreach ($_from as $this->_tpl_vars['key'] => $this->_tpl_vars['value']):
?>
	<?php if ($this->_tpl_vars['nowGame'] == $this->_tpl_vars['value']): ?>
	<option value="<?php echo $this->_tpl_vars['value']; ?>
" selected><?php echo $this->_tpl_vars['value']; ?>
</option>
	<?php else: ?>
	<option value="<?php echo $this->_tpl_vars['value']; ?>
"><?php echo $this->_tpl_vars['value']; ?>
</option>
	<?php endif; ?> <?php endforeach; endif; unset($_from); ?> <?php endif; ?>
</select>
</div>
</div>
</div>

<div class="col-sm-6">
<div class="row">
<label class="col-sm-3 control-label no-padding-right" for="form-field-5">区服</label>
<div class="col-sm-3">
<select id="selectServer">
	<option value="" id="server">区服</option>
	
	<?php if ($this->_tpl_vars['serverLists']): ?> <?php $_from = $this->_tpl_vars['serverLists']; if (!is_array($_from) && !is_object($_from)) { settype($_from, 'array'); }if (count($_from)):
    foreach ($_from as $this->_tpl_vars['key'] => $this->_tpl_vars['serverList']):
?>
	<?php if ($this->_tpl_vars['nowServer'] == $this->_tpl_vars['serverList']['server']): ?>
	<option value="<?php echo $this->_tpl_vars['serverList']['server']; ?>
" selected><?php echo $this->_tpl_vars['serverList']['server']; ?>
</option>
	<?php else: ?>
	<option value="<?php echo $this->_tpl_vars['serverList']['server']; ?>
"><?php echo $this->_tpl_vars['serverList']['server']; ?>
</option>
	<?php endif; ?> <?php endforeach; endif; unset($_from); ?> <?php endif; ?>
	
</select>
</div>
</div>
</div>
</div>
</form>
</div>
</center>
</div>

<div align="center"  class="col-xs-12">
<div align="left" style="width:60%" id ="servers2" class="table-header">
<button type="button" onClick="view1();"
	class="width-10 btn btn-sm btn-primary">信息修改
</button>

<button type="button" onClick="view2();"
	class="width-10 btn btn-sm btn-primary">用户操作
</button>

<button type="button" onClick="view3();"
	class="width-10 btn btn-sm btn-primary">服务器操作
</button>
</div>
</div>

<div id="view4" style="display:none" class="col-xs-12">

<center>
<table style="width:60%;" id="sample-table-1" class="table table-striped table-bordered table-hover">

<?php if ($this->_tpl_vars['channel_0']): ?>
<tr>
<td>
<div align="left" class="form-group">
<label class="col-sm-2 control-label no-padding-right" for="form-field-5">平台：<?php echo $this->_tpl_vars['channel_0']; ?>
</label>
	<input  name="checkboxs_all" type="checkbox" class="ace ace-checkbox-2" id="<?php echo $this->_tpl_vars['channel_0']; ?>
_selectAll"   value = "全选" />
	<label style="width:250px;" class="lbl" for="ace-settings-navbar">&nbsp;全选/反选</label>
	
</div>
</td>
</tr>
<tr>
<td>
<form>
	<div id="<?php echo $this->_tpl_vars['channel_0']; ?>
" align="left" class="form-group">
		<?php if ($this->_tpl_vars['serverLists']): ?>
		<?php $_from = $this->_tpl_vars['serverLists']; if (!is_array($_from) && !is_object($_from)) { settype($_from, 'array'); }if (count($_from)):
    foreach ($_from as $this->_tpl_vars['k'] => $this->_tpl_vars['server']):
?>
	  	<?php if ($this->_tpl_vars['server']['id'] > 0 && $this->_tpl_vars['server']['id']%10 == 0): ?>
		  <br/><br/>
		 <?php endif; ?>
		 
		 <?php if ($this->_tpl_vars['server']['platform'] == $this->_tpl_vars['channel_0']): ?>
		<input  name="checkboxs" type="checkbox" class="ace ace-checkbox-2" id="game_<?php echo $this->_tpl_vars['server']['server']; ?>
"   value = "<?php echo $this->_tpl_vars['server']['server']; ?>
" />
		<label style="width:200px;" class="lbl" for="ace-settings-navbar"><?php echo $this->_tpl_vars['server']['server']; ?>
</label>
		<?php endif; ?>
		
		<?php endforeach; endif; unset($_from); ?>
		<?php endif; ?>	
	</div>	
</form>
</td>
</tr>
<?php endif; ?>

<?php if ($this->_tpl_vars['channel_1']): ?>
<tr>
<td>
<div align="left" class="form-group">
<label class="col-sm-2 control-label no-padding-right" for="form-field-5">平台：<?php echo $this->_tpl_vars['channel_1']; ?>
</label>
	<input  name="checkboxs_all" type="checkbox" class="ace ace-checkbox-2" id="<?php echo $this->_tpl_vars['channel_1']; ?>
_selectAll"   value = "全选" />
	<label style="width:190px;" class="lbl" for="ace-settings-navbar">&nbsp;全选/反选</label>
</div>
</td>
</tr>
<tr>
<td>
<form>
	<div id="<?php echo $this->_tpl_vars['channel_1']; ?>
" align="left" class="form-group">
		<?php if ($this->_tpl_vars['serverLists']): ?>
		<?php $_from = $this->_tpl_vars['serverLists']; if (!is_array($_from) && !is_object($_from)) { settype($_from, 'array'); }if (count($_from)):
    foreach ($_from as $this->_tpl_vars['k'] => $this->_tpl_vars['server']):
?>
	  	<?php if ($this->_tpl_vars['server']['id'] > 0 && $this->_tpl_vars['server']['id']%10 == 0): ?>
		  <br/><br/>
		 <?php endif; ?>
		 
		 <?php if ($this->_tpl_vars['server']['platform'] == $this->_tpl_vars['channel_1']): ?>
		<input  name="checkboxs" type="checkbox" class="ace ace-checkbox-2" id="game_<?php echo $this->_tpl_vars['server']['server']; ?>
"   value = "<?php echo $this->_tpl_vars['server']['server']; ?>
" />
		<label style="width:160px;" class="lbl" for="ace-settings-navbar"><?php echo $this->_tpl_vars['server']['server']; ?>
</label>
		<?php endif; ?>
		
		<?php endforeach; endif; unset($_from); ?>
		<?php endif; ?>	
	</div>	
</form>
</td>
</tr>
<?php endif; ?>

<?php if ($this->_tpl_vars['channel_2']): ?>
<tr>
<td>
<div  align="left" class="form-group">
<label class="col-sm-1 control-label no-padding-right" for="form-field-5"><?php echo $this->_tpl_vars['channel_2']; ?>
</label>
		<input  name="checkboxs_all" type="checkbox" class="ace ace-checkbox-2" id="<?php echo $this->_tpl_vars['channel_2']; ?>
_selectAll"   value = "全选" />
	<label style="width:150px;" class="lbl" for="ace-settings-navbar">&nbsp;全选/反选</label>
</div>
</td>
</tr>
<tr>
<td>
<form>
	<div id="<?php echo $this->_tpl_vars['channel_2']; ?>
" align="left" class="form-group">
		<?php if ($this->_tpl_vars['serverLists']): ?>
		<?php $_from = $this->_tpl_vars['serverLists']; if (!is_array($_from) && !is_object($_from)) { settype($_from, 'array'); }if (count($_from)):
    foreach ($_from as $this->_tpl_vars['k'] => $this->_tpl_vars['server']):
?>
	  	<?php if ($this->_tpl_vars['server']['id'] > 0 && $this->_tpl_vars['server']['id']%10 == 0): ?>
		  <br/><br/> 
		 <?php endif; ?>
		 
		 <?php if ($this->_tpl_vars['server']['platform'] == $this->_tpl_vars['channel_2']): ?>
		<input  name="checkboxs" type="checkbox" class="ace ace-checkbox-2" id="game_<?php echo $this->_tpl_vars['server']['server']; ?>
"   value = "<?php echo $this->_tpl_vars['server']['server']; ?>
" />
		<label style="width:150px;" class="lbl" for="ace-settings-navbar"><?php echo $this->_tpl_vars['server']['server']; ?>
</label>
		<?php endif; ?>
		
		<?php endforeach; endif; unset($_from); ?>
		<?php endif; ?>	
	</div>	
</form>
</td>
</tr>
<?php endif; ?>

</table>
</center>
</div>

<form id="view5" class="form-horizontal" role="form">
<label class="col-sm-3 control-label no-padding-right" for="form-field-5"></label>
<div class="col-sm-12">
<center>
<table style="width:60%;" id="sample-table-1" class="table table-striped table-bordered table-hover">
	<thead>
		<tr>
			<th>查询条件</th>
			<th>查询信息</th>
			<th>操作</th>
		</tr>
	</thead>
	<tbody>
	
		<tr>
			<td>角色名</td>
			<td> 
			<div class="col-sm-12">
				<input type="text" id="user_role" placeholder="角色名"  class="col-xs-6 col-sm-9" value="<?php echo $this->_tpl_vars['role']; ?>
">
			</div>
			</td>	
			<td><center>
				<button valign="bottom" type="button" onclick="selectRole('role');" class="btn btn-info btn-success btn-sm" >
							查询
				</button>
				</center>
			</td>
		</tr>
		
				<tr>
			<td>Puid</td>
			<td> 
			<div class="col-sm-12">
				<input type="text" id="user_puid" placeholder="puid"  class="col-xs-6 col-sm-9" value="<?php echo $this->_tpl_vars['puid']; ?>
">
			</div>
			</td>	
			<td><center>
				<button valign="bottom" type="button" onclick="selectRole('puid');" class="btn btn-info btn-success btn-sm">
							查询
				</button>
				</center>
			</td>
		</tr>
		
				<tr>
			<td>用户id</td>
			<td> 
			<div class="col-sm-12">
				<input type="text" id="user_id" placeholder="playerId"  class="col-xs-6 col-sm-9" value="<?php echo $this->_tpl_vars['playerid']; ?>
">
			</div>
			</td>	
			<td><center>
				<button valign="bottom" type="button" onclick="selectRole('id');" class="btn btn-info btn-success btn-sm">
							查询
				</button>
				</center>
			</td>
		</tr>

	</tbody>
</table>
</center>
</div>
</form>

<div align="center"  class="col-xs-12">

<!-- 
<div align="left" style="width:60%" id ="servers2" class="table-header">

<button type="button" onClick="view1();"
	class="width-10 btn btn-sm btn-primary">信息修改
</button>

<button type="button" onClick="view2();"
	class="width-10 btn btn-sm btn-primary">用户操作
</button>

<button type="button" onClick="view3();"
	class="width-10 btn btn-sm btn-primary">服务器操作
</button>

</div>


style="height:650px;overflow-x:auto;overflow-y:auto;"
-->




<div  id="view1"  class="table-responsive">

<center>
<div  style="width:60%;" class="table-header"> 
用户信息查询
</div>
</center>

<center>
<table style="width:60%"  id="sample-table-1"
	class="table table-striped table-bordered table-hover">
	<thead>
		<tr>
			<th>keyMsg</th>
			<th>value</th>
			<th>修改值</th>
			<th>操作</th>
		</tr>
	</thead>
	<tbody>
		<?php $_from = $this->_tpl_vars['viewData']; if (!is_array($_from) && !is_object($_from)) { settype($_from, 'array'); }if (count($_from)):
    foreach ($_from as $this->_tpl_vars['viewData']):
?>
		<tr>
			<td  style="width:30%""><?php echo $this->_tpl_vars['viewData']['keyMsg']; ?>
</td>
			<td  style="width:30%"><input type="text" id="key_<?php echo $this->_tpl_vars['viewData']['key']; ?>
" value="<?php echo $this->_tpl_vars['viewData']['value']; ?>
" disabled="disabled" class="col-xs-6 col-sm-9"></td>
			
			<?php if ($this->_tpl_vars['viewData']['isChange'] == 1): ?>
			<td  style="width:20%"><input type="text" id="value_<?php echo $this->_tpl_vars['viewData']['key']; ?>
"  value="" class="col-xs-6 col-sm-9"></td>
			<td  style="width:20%">
				 <button valign="bottom" type="button" onclick="changeRoleInfo('<?php echo $this->_tpl_vars['viewData']['key']; ?>
','value_<?php echo $this->_tpl_vars['viewData']['key']; ?>
');" class="btn btn-info btn-success btn-sm">
							修改
				</button>
			</td>
			<?php else: ?>
			<td  style="width:20%">-</td>
			<td  style="width:20%">
							-
			</td>
			<?php endif; ?>	
		<?php endforeach; endif; unset($_from); ?>
	</tbody>
</table>
</center>
</div>

<div  id="view2"  style="display:none" class="table-responsive">
<center>
<div  style="width:60%;" class="table-header"> 
用户操作
</div>
</center>

<center>
<table  style="width:60%;"  id="sample-table-1"
	class="table table-striped table-bordered table-hover">
	<thead>
		<tr>
			<th colspan="6">用户充值(根据商品id)</th>
		</tr>
	</thead>
	<tbody>
		<tr>
			
				
			<td>
				<select id="selectChannel1">
	<option value="" >渠道</option>
		<?php if ($this->_tpl_vars['channelInfo']): ?> <?php $_from = $this->_tpl_vars['channelInfo']; if (!is_array($_from) && !is_object($_from)) { settype($_from, 'array'); }if (count($_from)):
    foreach ($_from as $this->_tpl_vars['key'] => $this->_tpl_vars['value']):
?>
		<?php if ($this->_tpl_vars['nowChannel'] == $this->_tpl_vars['value']): ?>
		<option value="<?php echo $this->_tpl_vars['value']; ?>
" selected><?php echo $this->_tpl_vars['value']; ?>
</option>
		<?php else: ?>
		<option value="<?php echo $this->_tpl_vars['value']; ?>
"><?php echo $this->_tpl_vars['value']; ?>
</option>
		<?php endif; ?> <?php endforeach; endif; unset($_from); ?> <?php endif; ?>
	</select>
			</td>
			
			<td colspan="4">
				 <input type="text" id="goodsId" placeholder="goodsId" class="col-xs-6 col-sm-6">
			</td>
			
			<td>
				 <button valign="bottom" type="button" onclick="recharge('id');" class="btn btn-info btn-success btn-sm">
							充值
				</button>
			</td>
	</tr>
	
	<thead>
	<tr>
			<th colspan="6">用户充值(任意金额)</th>
	</tr>
	</thead>
	<tr>
			
				
			<td>
				<select id="selectChannel2">
	<option value="" >渠道</option>
		<?php if ($this->_tpl_vars['channelInfo']): ?> <?php $_from = $this->_tpl_vars['channelInfo']; if (!is_array($_from) && !is_object($_from)) { settype($_from, 'array'); }if (count($_from)):
    foreach ($_from as $this->_tpl_vars['key'] => $this->_tpl_vars['value']):
?>
		<?php if ($this->_tpl_vars['nowChannel'] == $this->_tpl_vars['value']): ?>
		<option value="<?php echo $this->_tpl_vars['value']; ?>
" selected><?php echo $this->_tpl_vars['value']; ?>
</option>
		<?php else: ?>
		<option value="<?php echo $this->_tpl_vars['value']; ?>
"><?php echo $this->_tpl_vars['value']; ?>
</option>
		<?php endif; ?> <?php endforeach; endif; unset($_from); ?> <?php endif; ?>
	</select>
			</td>
			
			<td colspan="2">
				 <input type="text" id="orderId" placeholder="订单号" class="col-xs-6 col-sm-9">
			</td>
			
			<td colspan="2">
				 <input type="text" id="rechargeMoney" placeholder="充值金额" class="col-xs-6 col-sm-9">
			</td>
			
			<td>
				 <button valign="bottom" type="button" onclick="recharge('order');" class="btn btn-info btn-success btn-sm">
							充值
				</button>
			</td>
	</tr>
	
	
	
	
	
	<thead>
	<tr>
			<th colspan="6">发送奖励</th>
	</tr>
	</thead>
	<tr>
			<td colspan="1">
				 <select id="selectChannel3">
	<option value="" >渠道</option>
		<?php if ($this->_tpl_vars['channelInfo']): ?> <?php $_from = $this->_tpl_vars['channelInfo']; if (!is_array($_from) && !is_object($_from)) { settype($_from, 'array'); }if (count($_from)):
    foreach ($_from as $this->_tpl_vars['key'] => $this->_tpl_vars['value']):
?>
		<?php if ($this->_tpl_vars['nowChannel'] == $this->_tpl_vars['value']): ?>
		<option value="<?php echo $this->_tpl_vars['value']; ?>
" selected><?php echo $this->_tpl_vars['value']; ?>
</option>
		<?php else: ?>
		<option value="<?php echo $this->_tpl_vars['value']; ?>
"><?php echo $this->_tpl_vars['value']; ?>
</option>
		<?php endif; ?> <?php endforeach; endif; unset($_from); ?> <?php endif; ?>
	</select>
			</td>
			
			<td colspan="2">
				 <input type="text" id="awardMsg" placeholder="消息" class="col-xs-6 col-sm-9">
			</td>
	
			<td colspan="2">
				 <input type="text" id="awardInfo" placeholder="奖励内容" class="col-xs-6 col-sm-9">
			</td>
			
			<td>
				 <button valign="bottom" type="button" onclick="sendAward();" class="btn btn-info btn-success btn-sm">
							发送
				</button>
			</td>
	</tr>	
	
	
	<thead>
	<tr>
			<th colspan="6">添加装备</th>
	</tr>
	</thead>
	<tr>
			
			<td colspan="2">
				 <input type="text" id="equipId" placeholder="装备id" class="col-xs-6 col-sm-9">
			</td>
	
			<td>
				 <input type="text" id="equipNum" placeholder="装备数量" class="col-xs-6 col-sm-9">
			</td>
			
			<td>
				 <input type="text" id="starlevel1" placeholder="starlevel1" class="col-xs-6 col-sm-9">
			</td>
			
			<td>
				 <input type="text" id="starlevel2" placeholder="starlevel2" class="col-xs-6 col-sm-9">
			</td>
			
			<td>
				 <button valign="bottom" type="button" onclick="addEquip();" class="btn btn-info btn-success btn-sm">
							添加
				</button>
			</td>
	</tr>
	
	</tbody>
</table>

<table  style="width:60%;"  id="sample-table-1"
	class="table table-striped table-bordered table-hover">
	<thead>
		<tr>
			<th colspan="<?php echo $this->_tpl_vars['num']; ?>
">单个用户操作</th>
		</tr>
	</thead>
	<tbody>
		<tr>
		
		<?php if ($this->_tpl_vars['userOperation']): ?>
		<?php $_from = $this->_tpl_vars['userOperation']; if (!is_array($_from) && !is_object($_from)) { settype($_from, 'array'); }if (count($_from)):
    foreach ($_from as $this->_tpl_vars['userOperation']):
?> 
			<td>
				 <button valign="bottom" type="button" onclick="userOperation(<?php echo $this->_tpl_vars['userOperation']['id']; ?>
);" class="btn btn-info btn-success btn-sm">
							<?php echo $this->_tpl_vars['userOperation']['desc']; ?>

				</button>
			</td>
		<?php endforeach; endif; unset($_from); ?>
		<?php endif; ?>
	</tbody>
</table>
</center>
</div>


<div  id="view3"  style="display:none" class="table-responsive">
<center>
<div  style="width:60%;" class="table-header"> 
服务器操作
</div>
</center>


<center>
<table  style="width:60%;"  id="sample-table-1"
	class="table table-striped table-bordered table-hover">
	<thead>
		<tr>
			<th colspan="3">全服邮件</th>
		</tr>
	</thead>
		<tr>
			<td >
				 <input type="text" id="server_awardMsg" placeholder="消息" class="col-xs-6 col-sm-9">
			</td>
	
			<td >
				 <input type="text" id="server_awardInfo" placeholder="奖励内容" class="col-xs-6 col-sm-9">
			</td>
			
			<td>
				 <button valign="bottom" type="button" onclick="sendServerAward();" class="btn btn-info btn-success btn-sm">
							发送
				</button>
			</td>
			
        </tr>

	<thead>
		<tr>
			<th colspan="3">全服聊天公告</th>
		</tr>
	</thead>
		<tr>
			<td colspan="2">
				 <input type="text" id="broadcast_chat" placeholder="聊天公告" class="col-xs-6 col-sm-12">
			</td>
	
			<td>
				 <button valign="bottom" type="button" onclick="broadcast('chat');" class="btn btn-info btn-success btn-sm">
							发送
				</button>
			</td>
			
        </tr>		
	
		<thead>
		<tr>
			<th colspan="3">全服广播公告</th>
		</tr>
	</thead>
		<tr>
			<td colspan="2">
				 <input type="text" id="broadcast_broad" placeholder="广播公告" class="col-xs-6 col-sm-12">
			</td>
	
			<td>
				 <button valign="bottom" type="button" onclick="broadcast('broad');" class="btn btn-info btn-success btn-sm">
							发送
				</button>
			</td>
			
        </tr>	
	
	<thead>
		<tr>
			<th colspan="<?php echo $this->_tpl_vars['num2']; ?>
">服务器操作</th>
		</tr>
	</thead>
	<tbody>
		<tr>
		
		<?php if ($this->_tpl_vars['serverOperation']): ?>
		<?php $_from = $this->_tpl_vars['serverOperation']; if (!is_array($_from) && !is_object($_from)) { settype($_from, 'array'); }if (count($_from)):
    foreach ($_from as $this->_tpl_vars['serverOperation']):
?> 
			<td>
				 <button valign="bottom" type="button" onclick="serverOperation(<?php echo $this->_tpl_vars['serverOperation']['id']; ?>
);" class="btn btn-info btn-success btn-sm">
							<?php echo $this->_tpl_vars['serverOperation']['desc']; ?>

				</button>
			</td>
		<?php endforeach; endif; unset($_from); ?>
		<?php endif; ?>
		</tr>
		<tr>
		<td colspan="<?php echo $this->_tpl_vars['num2']; ?>
" style="width:100%;"> <textarea placeholder="执行结果" id="result" class="comments" rows="2" name="s1" cols="50" onpropertychange="this.style.posHeight=this.scrollHeight"></textarea>
		</td>
		</tr>
	</tbody>
</table>

</center>
</div>


</div>

</div>
<!-- /.page-content --></div>
<!-- /.main-content -->
<script type="text/javascript">
	<?php if ($this->_tpl_vars['channel_0']): ?>
	//全选
	$("#<?php echo $this->_tpl_vars['channel_0']; ?>
_selectAll").click(function(){
		if(this.checked) {
			$("#<?php echo $this->_tpl_vars['channel_0']; ?>
 :checkbox").prop("checked", true); 
		} else {
			$("#<?php echo $this->_tpl_vars['channel_0']; ?>
 :checkbox").prop("checked", false);  
		}
	}); 

	// 反选
	$("#<?php echo $this->_tpl_vars['channel_0']; ?>
_unSelect").click(function () {//全不选  
	     $("#<?php echo $this->_tpl_vars['channel_0']; ?>
 :checkbox").each(function(){
	    	 if(!$(this).is(":checked")) {
	    		 $("#<?php echo $this->_tpl_vars['channel_0']; ?>
 :checkbox").prop("checked", true); 
	    	 } else {
	    		 $("#<?php echo $this->_tpl_vars['channel_0']; ?>
 :checkbox").prop("checked", false); 
	    	 }
	     })
	});
	<?php endif; ?>
	
	<?php if ($this->_tpl_vars['channel_1']): ?>
	//全选
	$("#<?php echo $this->_tpl_vars['channel_1']; ?>
_selectAll").click(function(){
		if(this.checked) {
			$("#<?php echo $this->_tpl_vars['channel_1']; ?>
 :checkbox").prop("checked", true); 
		} else {
			$("#<?php echo $this->_tpl_vars['channel_1']; ?>
 :checkbox").prop("checked", false);  
		}
	}); 

	// 反选
	$("#<?php echo $this->_tpl_vars['channel_1']; ?>
_unSelect").click(function () {//全不选  
	     $("#<?php echo $this->_tpl_vars['channel_1']; ?>
 :checkbox").prop("checked", false); 
	});
	<?php endif; ?>
	
	<?php if ($this->_tpl_vars['channel_2']): ?>
	//全选
		$("#<?php echo $this->_tpl_vars['channel_2']; ?>
_selectAll").click(function(){
		if(this.checked) {
			$("#<?php echo $this->_tpl_vars['channel_2']; ?>
 :checkbox").prop("checked", true); 
		} else {
			$("#<?php echo $this->_tpl_vars['channel_2']; ?>
 :checkbox").prop("checked", false);  
		}
	}); 

	// 反选
	$("#<?php echo $this->_tpl_vars['channel_2']; ?>
_unSelect").click(function () {//全不选  
	     $("#<?php echo $this->_tpl_vars['channel_2']; ?>
 :checkbox").prop("checked", false); 
	});
	<?php endif; ?>
	
	function view1() {
		$('#view1').css("display", "block");
		$('#view2').css("display", "none");
		$('#view3').css("display", "none");
		$('#view4').css("display", "none");
		$('#view5').css("display", "block");
	}
	
	function view2() {
		$('#view1').css("display", "none");
		$('#view2').css("display", "block");
		$('#view3').css("display", "none");
		$('#view4').css("display", "none");
		$('#view5').css("display", "block");
	}
	
	function view3() {
		$('#view1').css("display", "none");
		$('#view2').css("display", "none");
		$('#view3').css("display", "block");
		$('#view4').css("display", "block");
		$('#view5').css("display", "none");
	}
	
//全选
$("#selectAll").click(function(){
	if(($(this).attr("checked"))) {
		 $("#servers :checkbox").prop("checked", true); 
	} else {
		$("#servers :checkbox").prop("checked", false); 
	}
	
}); 
// 反选
$("#unSelect").click(function () {//全不选  
     $("#servers :checkbox").prop("checked", false); 
});  	
	
	jQuery(function($) {
		$('.date-picker').datepicker({
			autoclose : true
		}).next().on(ace.click_event, function() {
			$(this).prev().focus();
		});

		var oTable1 = $('#sample-table-2').dataTable({
			"aoColumns" : [ {
				"bSortable" : false
			}, {
				"bSortable" : false
			}, {
				"bSortable" : false
			}
			]
		});
		

	});
	
	
	
	function formSubmit() {
		var game = $('#selectGame').val();
		var platform = $('#platform').val();
		var timeout = $('#timeout').val();
		var command = $('#command').val();
		
		var servers=''; 
		$("input[name='checkboxs']:checked").each(function(){ 
			servers += $(this).val()+','; 
		});
		
		if (!game || !timeout || !command || !servers) {
			alert('请将信息填写完整！');
		} else {
			url = "index.php?mod=Shell&do=showServerList&game="+game+"&platform="+platform+"&servers="+servers+"&command="+command+"&timeout="+timeout;
			window.location.href = url;
		}

	}
	
	function changeRoleInfo(type, id) {
		valueId = "#"+id;
		changeValue = $(valueId).val();
		var game = $('#selectGame').val();
		var selectServer = $('#selectServer').val(); 
		
		
		var param = {};
		param['mod'] = 'Gm';
		param['do']  = 'changePlayerInfo';
		
		param['game']  	= game;
		param['key']  	= type;
		param['value']  = changeValue;
		param['serverUrl']  = selectServer;
		
		$.ajax({
			type:'POST',
			url:'index.php',
			data:param,
			dataType:'html',
			success:function(data) {
				var dataObj = eval("(" + data + ")");//转换为json对象
				if (dataObj.code != 1) {
					alert(dataObj.msg);
				} else {
					alert(dataObj.msg);
					// window.location.href = "index.php";
					window.location.href=window.location.href; // 刷新当前页面
				}
		
			}
		});
		
	}
	
	
	function selectRole(type) {
		var key = "";
		var value = "";
		if(type == "role") {
			key = "role";
			value = $('#user_role').val();
		} else if(type == "puid") {
			key = "puid";
			value = $('#user_puid').val();
		} else if(type == "id") {
			key = "id";
			value = $('#user_id').val();
		}
		
		var game = $('#selectGame').val();
		var selectServer = $('#selectServer').val(); 
		if(!game) {
			alert("请选择游戏");
		}else if(!selectServer) {
			alert("请选择服");
		} else {
			url = "index.php?mod=Gm&do=selectUserInfo&action=1&game="+game+"&"+key+"="+value+"&serverUrl="+selectServer+"&type="+type;
			window.location.href = url;  
		}
	}
	
	// 用户操作
	function userOperation(actionId) {
		
		var game = $('#selectGame').val();
		var selectServer = $('#selectServer').val(); 
		var param = {};
		param['mod'] = 'Gm';
		param['do']  = 'userOperation';
		
		param['actionId']  		= actionId;
		param['game']  			= game;
		param['serverUrl']  	= selectServer;
		
		$.ajax({
			type:'POST',
			url:'index.php',
			data:param,
			dataType:'html',
			success:function(data) {
				var dataObj = eval("(" + data + ")");//转换为json对象
				if (dataObj.code != 1) {
					alert(dataObj.msg);
				} else {
					alert(dataObj.msg);
				}
			}
		});

	}
	
	function serverOperation(actionId) {
		var game = $('#selectGame').val();
		//var selectServer = $('#selectServer').val(); 
		
		var servers=''; 
		$("input[name='checkboxs']:checked").each(function(){
				servers += $(this).val()+','
		});
		
		var param = {};
		param['mod'] = 'Gm';
		param['do']  = 'serverOperation';
		
		param['actionId']  		= actionId;
		param['game']  			= game;
		param['servers']  	= servers;
		
		if(!game) {
			alert("请选择游戏");
		} else if(!servers) {
			alert("请选择服");
		} else {
			$.ajax({
				type:'POST',
				url:'index.php',
				data:param,
				dataType:'html',
				success:function(data) {
					$('#result').html(data);
					alert("ok");
					/*
					var dataObj = eval("(" + data + ")");//转换为json对象
					if (dataObj.code != 1) {
						alert(dataObj.msg);
					} else {
						alert(dataObj.msg);
					}
					*/
				}
			});
		}
	}
	// 充值
	function recharge(type) {
		
		var game = $('#selectGame').val();
		var selectServer = $('#selectServer').val(); 
		var selectChannel1 = $('#selectChannel1').val();
		var selectChannel2 = $('#selectChannel2').val();
		var goodsId = $('#goodsId').val();
		
		var orderId = $('#orderId').val();
		var rechargeMoney = $('#rechargeMoney').val();
		
		if(!game) {
			alert("请选择游戏");
		} else if(!selectServer) {
			alert("请选择服");
		} else if((type == 'id') && !goodsId) {
			alert("请输入商品id");
		} else if((type == 'order') && !rechargeMoney)  {
			alert("请输入充值金额");
		} else {
			var param = {};
			param['mod'] = 'Gm';
			param['do']  = 'recharge';
			
			param['game']  			= game;
			param['serverUrl']  	= selectServer;
			if(type == 'id') {
				param['channel']  		= selectChannel1;
				param['goodsId']  		= goodsId;
			} else if(type == 'order') {
				param['channel']  		= selectChannel2;
				param['orderId']  		= orderId;
				param['rechargeMoney']  		= rechargeMoney;
			}
			
			$.ajax({
				type:'POST',
				url:'index.php',
				data:param,
				dataType:'html',
				success:function(data) {
					var dataObj = eval("(" + data + ")");//转换为json对象
					if (dataObj.code != 1) {
						alert(dataObj.msg);
					} else {
						alert(dataObj.msg);
					}
				}
			});
		}
	}
	
	// 添加装备
	function addEquip() {
		var game = $('#selectGame').val();
		var selectServer = $('#selectServer').val(); 
		var equipId = $('#equipId').val();
		var equipNum = $('#equipNum').val();
		var starlevel1 = $('#starlevel1').val();
		var starlevel2 = $('#starlevel2').val();
		
		var param = {};
		param['mod'] = 'Gm';
		param['do']  = 'addEquip';
		
		param['game']  			= game;
		param['serverUrl']  	= selectServer;
		param['equipId']  		= equipId;
		param['equipNum']  		= equipNum;
		param['starlevel1']  	= starlevel1;
		param['starlevel2']  	= starlevel2;
	
		if(!game) {
			alert("请选择游戏");
		} else if(!selectServer) {
			alert("请选择服");
		} else  if(!equipId) {
			alert("请输入装备Id");
		} else if(!equipNum) {
			alert("请输入装备数量");
		} else if(!starlevel1) {
			alert("请输入starlevel1");
		} else if(!starlevel2) {
			alert("请输入starlevel1");
		} else {
			$.ajax({
				type:'POST',
				url:'index.php',
				data:param,
				dataType:'html',
				success:function(data) {
					var dataObj = eval("(" + data + ")");//转换为json对象
					if (dataObj.code != 1) {
						alert(dataObj.msg);
					} else {
						alert(dataObj.msg);
					}
				}
			});
		}
	}
	
	// 发送奖励
	function sendAward() {
		var game = $('#selectGame').val();
		var selectServer = $('#selectServer').val(); 
		var selectChannel3 = $('#selectChannel3').val();
		var awardMsg = $('#awardMsg').val();
		var awardInfo = $('#awardInfo').val();
		
		var param = {};
		param['mod'] = 'Gm';
		param['do']  = 'sendAward';
		
		param['game']  			= game;
		param['serverUrl']  	= selectServer;
		param['awardMsg']  		= awardMsg;
		param['awardInfo']  	= awardInfo;
		param['selectChannel']  	= selectChannel3;
		
		if(!game) {
			alert("请选择游戏");
		} else if(!selectServer) {
			alert("请选择服");
		} else  if(!awardInfo) {
			alert("请输入奖励内容");
		} else {
			$.ajax({
				type:'POST',
				url:'index.php',
				data:param,
				dataType:'html',
				success:function(data) {
					var dataObj = eval("(" + data + ")");//转换为json对象
					if (dataObj.code != 1) {
						alert(dataObj.msg);
					} else {
						alert(dataObj.msg);
					}
				}
			});
		}
		
	}
	
	// 发送全服奖励
	function sendServerAward() {
		var game = $('#selectGame').val();
		var selectServer = $('#selectServer').val(); 
		var awardMsg = $('#server_awardMsg').val();
		var awardInfo = $('#server_awardInfo').val();
		
		var servers=''; 
		$("input[name='checkboxs']:checked").each(function(){
				servers += $(this).val()+','
		});
		
		var param = {};
		param['mod'] = 'Gm';
		param['do']  = 'sendServerAward';
		
		param['game']  			= game;
		param['servers']  		= servers;
		param['awardMsg']  		= awardMsg;
		param['awardInfo']  	= awardInfo;
		
		if(!game) {
			alert("请选择游戏");
		} else if(!servers) {
			alert("请选择服");
		} else  if(!awardInfo) {
			alert("请输入奖励内容");
		} else {
			$.ajax({
				type:'POST',
				url:'index.php',
				data:param,
				dataType:'html',
				success:function(data) {
					$('#result').html(data);
					alert("ok");
				}
			});
		}
	}
	
	function broadcast(type) {
		
		var game = $('#selectGame').val();
		var servers=''; 
		$("input[name='checkboxs']:checked").each(function(){
				servers += $(this).val()+','
		});
		
	//	var selectServer = $('#selectServer').val(); 
		
		if(type == "chat") {
			var message = $('#broadcast_chat').val();	
		} else if(type == "broad") {
			var message = $('#broadcast_broad').val();	
		}
	
		var param = {};
		param['mod'] = 'Gm';
		param['do']  = 'broadcast';
		
		param['game']  			= game;
		param['servers']  		= servers;
		param['message']  		= message;
		param['type']  			= type;
		
		if(!game) {
			alert("请选择游戏");
		} else if(!servers) {
			alert("请选择服");
		} else  if(!message) {
			alert("请输入广播内容");
		} else {
			$.ajax({
				type:'POST',
				url:'index.php',
				data:param,
				dataType:'html',
				success:function(data) {
					$('#result').html(data);
					alert("ok");	
				/*	
					var dataObj = eval("(" + data + ")");//转换为json对象
					if (dataObj.code != 1) {
						alert(dataObj.msg);
					} else {
						alert(dataObj.msg);
					}
				*/	
				}
			});
		}
	}
	
	window.onload = function(){
	    var select = document.getElementById('selectGame');
	    select.onchange = function(){
	        // 更改值后执行的代码
	       var gameName = jQuery("#selectGame  option:selected").text();
	       var game = $('#selectGame').val();
			url = "index.php?mod=Gm&do=selectUserInfo&action=1&game="+game;
			window.location.href = url;  
	    }
	} 
	
</script>
<?php $_smarty_tpl_vars = $this->_tpl_vars;
$this->_smarty_include(array('smarty_include_tpl_file' => "footer.html", 'smarty_include_vars' => array()));
$this->_tpl_vars = $_smarty_tpl_vars;
unset($_smarty_tpl_vars);
 ?>
