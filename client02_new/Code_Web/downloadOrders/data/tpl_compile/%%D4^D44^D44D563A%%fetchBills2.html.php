<?php /* Smarty version 2.6.18, created on 2015-03-25 12:13:11
         compiled from fetchBills2.html */ ?>
<?php $_smarty_tpl_vars = $this->_tpl_vars;
$this->_smarty_include(array('smarty_include_tpl_file' => "header.html", 'smarty_include_vars' => array()));
$this->_tpl_vars = $_smarty_tpl_vars;
unset($_smarty_tpl_vars);
 ?> <?php $_smarty_tpl_vars = $this->_tpl_vars;
$this->_smarty_include(array('smarty_include_tpl_file' => "top.html", 'smarty_include_vars' => array()));
$this->_tpl_vars = $_smarty_tpl_vars;
unset($_smarty_tpl_vars);
 ?> <?php $_smarty_tpl_vars = $this->_tpl_vars;
$this->_smarty_include(array('smarty_include_tpl_file' => "left.html", 'smarty_include_vars' => array()));
$this->_tpl_vars = $_smarty_tpl_vars;
unset($_smarty_tpl_vars);
 ?>
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




<div id="moveDevice" style="display:none" class="col-xs-12">
<div class="alert alert-info">
<form class="form-horizontal" role="form">
<div class="row">

<div class="col-sm-12">
<div class="row">
<label class="col-sm-6 control-label no-padding-right" for="form-field-5">海外挂机-韩国</label>
<!--  
<div class="col-sm-3"><select id="selectGame2">
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
-->
</div>
</div>

<div class="col-sm-12">
<div  class="row">
<label class="col-sm-5 control-label no-padding-right" for="form-field-5"></label>
</div>
</div>

<div class="col-sm-12">
<div class="row">
<label class="col-sm-5 control-label no-padding-right" for="form-field-5">区服</label>
<div class="col-sm-3">
<select id="channel2">
	<option value="" id="selectChannel2">全部</option>
	<?php if ($this->_tpl_vars['channels']): ?> <?php $_from = $this->_tpl_vars['channels']; if (!is_array($_from) && !is_object($_from)) { settype($_from, 'array'); }if (count($_from)):
    foreach ($_from as $this->_tpl_vars['key'] => $this->_tpl_vars['value']):
?>
	<?php if ($this->_tpl_vars['serverId'] == $this->_tpl_vars['value']): ?>
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

<div class="col-sm-12">
<div  class="row">
<label class="col-sm-5 control-label no-padding-right" for="form-field-5"></label>
</div>
</div>

<div class="col-sm-12">
<div class="row"><label
	class="col-sm-5 control-label no-padding-right" for="form-field-5">开始</label>
<div class="col-sm-3">
<div class="input-group"><span class="input-group-addon"> <i
	class="icon-calendar bigger-110"></i> </span> <input
	class="date-picker col-xs-12 col-sm-12" id="startTime2"
	value="<?php echo $this->_tpl_vars['startDate']; ?>
" type="text" data-date-format="yyyy-mm-dd" /></div>
</div>
</div>
</div>

<div class="col-sm-12">
<div  class="row">
<label class="col-sm-5 control-label no-padding-right" for="form-field-5"></label>
</div>
</div>

<div class="col-sm-12">
<div class="row"><label
	class="col-sm-5 control-label no-padding-right" for="form-field-5">结束</label>
<div class="col-sm-3">
<div class="input-group"><span class="input-group-addon"> <i
	class="icon-calendar bigger-110"></i> </span> <input
	class="date-picker col-xs-12 col-sm-12" id="endTime2"
	value="<?php echo $this->_tpl_vars['endDate']; ?>
" type="text" data-date-format="yyyy-mm-dd" /></div>
</div>
</div>
</div>

<div class="col-sm-12">
<div  class="row">
<label class="col-sm-5 control-label no-padding-right" for="form-field-5"></label>
</div>
</div>

<div class="col-sm-12">
<div class="row"><label
	class="col-sm-5 control-label no-padding-right" for="form-field-5">&nbsp;&nbsp;&nbsp;&nbsp;</label>
<div class="col-sm-2">
<center>
<button type="button" onClick="formSubmit('select', 'move');"
	class="width-50 btn btn-sm btn-primary">查询</button>
</center>
</div>
</div>
</div>

</div>
</form>
</div>
</div>

<div id="pcDevice" style="display:block" class="col-xs-12">
<div class="alert alert-info">
<form class="form-horizontal" role="form">
<div class="row">


<div class="col-sm-2">
<div class="row">
<label class="col-sm-5 control-label no-padding-right" for="form-field-5">海外挂机-韩国</label>
<!--  
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
-->

</div>
</div>


<div class="col-sm-2">
<div class="row">
<label class="col-sm-2 control-label no-padding-right" for="form-field-5">区服</label>
<div class="col-sm-3">
<select id="channel">
	<option value="" id="selectChannel2">全部</option>
	<?php if ($this->_tpl_vars['channels']): ?> <?php $_from = $this->_tpl_vars['channels']; if (!is_array($_from) && !is_object($_from)) { settype($_from, 'array'); }if (count($_from)):
    foreach ($_from as $this->_tpl_vars['key'] => $this->_tpl_vars['value']):
?>
	<?php if ($this->_tpl_vars['serverId'] == $this->_tpl_vars['value']): ?>
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


<div class="col-sm-2">
<div class="row"><label
	class="col-sm-2 control-label no-padding-right" for="form-field-5">开始</label>
<div class="col-sm-9">
<div class="input-group"><span class="input-group-addon"> <i
	class="icon-calendar bigger-110"></i> </span> <input
	class="date-picker col-xs-12 col-sm-12" id="startTime"
	value="<?php echo $this->_tpl_vars['startDate']; ?>
" type="text" data-date-format="yyyy-mm-dd" /></div>
</div>
</div>
</div>

<div class="col-sm-2">
<div class="row"><label
	class="col-sm-2 control-label no-padding-right" for="form-field-5">结束</label>
<div class="col-sm-9">
<div class="input-group"><span class="input-group-addon"> <i
	class="icon-calendar bigger-110"></i> </span> <input
	class="date-picker col-xs-12 col-sm-12" id="endTime"
	value="<?php echo $this->_tpl_vars['endDate']; ?>
" type="text" data-date-format="yyyy-mm-dd" /></div>
</div>
</div>
</div>


<div class="col-sm-2">
<div class="row"><label
	class="col-sm-2 control-label no-padding-right" for="form-field-5">&nbsp;&nbsp;&nbsp;&nbsp;</label>
<div class="col-sm-9">
<center>
<button type="button" onClick="formSubmit('select', 'pc');"
	class="width-50 btn btn-sm btn-primary">查询</button>
</center>
</div>
</div>
</div>

</div>
</form>
</div>
</div>



<div class="col-xs-12">
<div class="table-header">

<button type="button" 
	class="width-10 btn btn-sm btn-primary">订单信息
</button>

<button type="button"  onClick="formSubmit('daochu', 'pc');"
	class="width-10 btn btn-sm btn-primary">导出结果
</button>

</div>



<div id="view"  class="table-responsive">
<table id="sample-table-4"
	class="table table-striped table-bordered table-hover">
	<thead>
	
		<tr>
			<th>区服</th>
	
			<th>订单号</th>
			<th>puid</th>
			<th>钻石</th>
			<th>金额(韩币)</th>
			<th>时间</th>

		</tr>
	<thead>
	<thead>
	<tbody>
		<?php $_from = $this->_tpl_vars['data']; if (!is_array($_from) && !is_object($_from)) { settype($_from, 'array'); }if (count($_from)):
    foreach ($_from as $this->_tpl_vars['data']):
?>
		<tr>
			<td><?php echo $this->_tpl_vars['data'][0]; ?>
</td>

			<td><?php echo $this->_tpl_vars['data'][2]; ?>
</td>
			<td><?php echo $this->_tpl_vars['data'][3]; ?>
</td>	
			<td><?php echo $this->_tpl_vars['data'][4]; ?>
</td>
			<td><?php echo $this->_tpl_vars['data'][5]; ?>
</td>
			<td><?php echo $this->_tpl_vars['data'][6]; ?>
</td>
		</tr>
		<?php endforeach; endif; unset($_from); ?>

	</tbody>
</table>
</div>


<!-- /.table-responsive --></div>
</div>
<!-- /.page-content --></div>
<!-- /.main-content -->
<script type="text/javascript">


	jQuery(function($) {
		$('.date-picker').datepicker({
			autoclose : true
		}).next().on(ace.click_event, function() {
			$(this).prev().focus();
		});

		var oTable1 = $('#sample-table-4').dataTable({
			"aoColumns" : [ {
				"bSortable" : false
			}, {
				"bSortable" : false
			}, {
				"bSortable" : false
			}, {
				"bSortable" : false
			}, {
				"bSortable" : false
			}, {
				"bSortable" : false
			}, {
				"bSortable" : false
			}
			]
		});
	});

	
	function formSubmit(type, device) {
		if(device == "pc") {
			var serverId = $('#channel').val();
			var startTime = $('#startTime').val();
			var endTime = $('#endTime').val();
		} else if(device == "move") {
			var serverId = $('#channel2').val();
			var startTime = $('#startTime2').val();
			var endTime = $('#endTime2').val();
		}
		
		if (!startTime || !endTime) {
			alert('请将信息填写完整！');
		} else {
				url = "index.php?mod=Recharge&do=fetchBills"
					+ "&serverId="
					+ serverId
					+ "&startTime="
					+ startTime
					+ "&endTime="
					+ endTime
					+ "&type="
					+ type;
			window.location.href = url;
		}
	}
	
	
	window.onload = function(){
		
		var width = document.documentElement.clientWidth;
		if(width < 1700) {
			$('#pcDevice').css("display", "none");
			$('#moveDevice').css("display", "block");
		} else if(width > 1700) {
			$('#pcDevice').css("display", "block");
			$('#moveDevice').css("display", "none");
		}
	
	} 
	
</script>
<?php $_smarty_tpl_vars = $this->_tpl_vars;
$this->_smarty_include(array('smarty_include_tpl_file' => "footer.html", 'smarty_include_vars' => array()));
$this->_tpl_vars = $_smarty_tpl_vars;
unset($_smarty_tpl_vars);
 ?>
