<?php /* Smarty version 2.6.18, created on 2015-04-25 18:34:45
         compiled from header.html */ ?>
<!DOCTYPE html>
<html>
	<head>
		<meta charset="utf-8" />
		<title>gm管理系统</title>
		<meta name="viewport" content="width=device-width, initial-scale=1.0" />

		<link rel="stylesheet" href="<?php echo $this->_tpl_vars['staticUrl']; ?>
css/bootstrap.min.css" />
		<link rel="stylesheet" href="<?php echo $this->_tpl_vars['staticUrl']; ?>
css/font-awesome.min.css" />
		<link rel="stylesheet" href="<?php echo $this->_tpl_vars['staticUrl']; ?>
css/ace.min.css" />
		<link rel="stylesheet" href="<?php echo $this->_tpl_vars['staticUrl']; ?>
css/ace-rtl.min.css" />
		<link rel="stylesheet" href="<?php echo $this->_tpl_vars['staticUrl']; ?>
css/ace-skins.min.css" />
		<link rel="stylesheet" href="<?php echo $this->_tpl_vars['staticUrl']; ?>
/css/dropzone.css" />
		<link rel="stylesheet" href="<?php echo $this->_tpl_vars['staticUrl']; ?>
css/jquery-ui-1.10.3.custom.min.css" />
 		<script type="text/javascript" src="<?php echo $this->_tpl_vars['staticUrl']; ?>
js/jquery-1.9.1.min.js"></script>
		<script type="text/javascript" src="<?php echo $this->_tpl_vars['staticUrl']; ?>
js/jquery.cookie.js"></script>
		<script type="text/javascript" src="<?php echo $this->_tpl_vars['staticUrl']; ?>
js/jquery-ui-1.10.3.custom.min.js"></script> 
		
<!--  		<script type="text/javascript" src="<?php echo $this->_tpl_vars['staticUrl']; ?>
js/flot/jquery.js"></script> <script src="<?php echo $this->_tpl_vars['staticUrl']; ?>
js/chart/themes/grid-light.js"></script>
-->		
		<script type="text/javascript" src="<?php echo $this->_tpl_vars['staticUrl']; ?>
js/flot/jquery.flot.js"></script>
		
		<script src="<?php echo $this->_tpl_vars['staticUrl']; ?>
/js/ace-extra.min.js"></script>
		<script type="text/javascript" src="<?php echo $this->_tpl_vars['staticUrl']; ?>
js/ZeroClipboard.js"></script>
		
		<script src="<?php echo $this->_tpl_vars['staticUrl']; ?>
js/chart/highcharts.js"></script>
		<script src="<?php echo $this->_tpl_vars['staticUrl']; ?>
js/chart/modules/exporting.js"></script>
		<script src="<?php echo $this->_tpl_vars['staticUrl']; ?>
js/chart/themes/grid.js"></script>
		
		<style>
		a:hover  {
		    text-decoration: none;
		}

		select {
		// width:105px;
		}

		</style>
		
		<script type="text/javascript">
			$(document).ready(function(){
				<?php if ($this->_tpl_vars['openNode'] == 1): ?>
					$("#<?php echo $this->_tpl_vars['parentNode']; ?>
").addClass("active");
					$("#<?php echo $this->_tpl_vars['parentNode']; ?>
").addClass("open");				
					$("#<?php echo $this->_tpl_vars['childNode']; ?>
").addClass("active"); 				
				<?php endif; ?>				
				<?php if ($this->_tpl_vars['display'] == 1): ?>
				$("#<?php echo $this->_tpl_vars['parentNode2']; ?>
").addClass("active");
				$("#<?php echo $this->_tpl_vars['parentNode2']; ?>
").addClass("open");
				$("#<?php echo $this->_tpl_vars['childNode']; ?>
").addClass("open"); 
				<?php endif; ?>				
			});
		</script>
	</head>