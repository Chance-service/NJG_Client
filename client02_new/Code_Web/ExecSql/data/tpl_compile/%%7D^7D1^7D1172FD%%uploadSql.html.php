<?php /* Smarty version 2.6.18, created on 2015-03-18 11:10:20
         compiled from uploadSql.html */ ?>
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
								<a href="#">Home</a>
							</li>

							<li>
								<a href="#">Forms</a>
							</li>
							<li class="active">Dropzone File Upload</li>
						</ul><!-- .breadcrumb -->

						<div class="nav-search" id="nav-search">
							<form class="form-search">
								<span class="input-icon">
									<input type="text" placeholder="Search ..." class="nav-search-input" id="nav-search-input" autocomplete="off" />
									<i class="icon-search nav-search-icon"></i>
								</span>
							</form>
						</div><!-- #nav-search -->
					</div>

					<div class="page-content">
						<div class="page-header">
							<h1>
								更新SQL
								<small>
									<i class="icon-double-angle-right"></i>
									上传SQL
								</small>
							</h1>
						</div><!-- /.page-header -->

						<div class="row">
							<div class="col-xs-12">
								<!-- PAGE CONTENT BEGINS -->

								<div class="alert alert-info">
									<i class="icon-hand-right"></i>

									如<?php echo $this->_tpl_vars['gameName']; ?>
游戏数据库有变化,请上传<?php echo $this->_tpl_vars['fileName']; ?>
最新文件,覆盖旧文件。
									<button class="close" data-dismiss="alert">
										<i class="icon-remove"></i>
									</button>
								</div>

								<div id="dropzone">
								
								<form name ="myForm" class="dropzone" action="index.php?mod=ExecSql&do=uploadSql&gameId=<?php echo $this->_tpl_vars['gameId']; ?>
" method="post" enctype="multipart/form-data">
									<label for="file">请上传<?php echo $this->_tpl_vars['fileName']; ?>
文件</label>
									<div class="fallback">
									<input type="file" name="file" id="file" />
									</div> 
									<br />
									<div class="clearfix">
									<input type="submit" name="submit" value="上传SQL" class="btn btn-info btn-success"/>
									</div>
									<br/>
									<br/>
									<?php if ($this->_tpl_vars['message']): ?>
									<div class="clearfix">
										<label for="file"><?php echo $this->_tpl_vars['message']; ?>
</label>
									</div>
								<?php endif; ?>
								</form>
								
								
		
								</div><!-- PAGE CONTENT ENDS -->
							</div><!-- /.col -->
						</div><!-- /.row -->
					</div><!-- /.page-content -->
				</div><!-- /.main-content -->
<?php $_smarty_tpl_vars = $this->_tpl_vars;
$this->_smarty_include(array('smarty_include_tpl_file' => "footer.html", 'smarty_include_vars' => array()));
$this->_tpl_vars = $_smarty_tpl_vars;
unset($_smarty_tpl_vars);
 ?>
<script language="javascript">

jQuery(function($){
	
	try {
	  $(".dropzone").dropzone({
	    paramName: "file", // The name that will be used to transfer the file
	    maxFilesize: 0.5, // MB
	  
		addRemoveLinks : true,
		dictDefaultMessage :
		'<span class="bigger-150 bolder"><i class="icon-caret-right red"></i> Drop files</span> to upload \
		<span class="smaller-80 grey">(or click)</span> <br /> \
		<i class="upload-icon icon-cloud-upload blue icon-3x"></i>'
	,
		dictResponseError: 'Error while uploading file!',
		
		//change the previewTemplate to use Bootstrap progress bars
		previewTemplate: "<div class=\"dz-preview dz-file-preview\">\n  <div class=\"dz-details\">\n    <div class=\"dz-filename\"><span data-dz-name></span></div>\n    <div class=\"dz-size\" data-dz-size></div>\n    <img data-dz-thumbnail />\n  </div>\n  <div class=\"progress progress-small progress-striped active\"><div class=\"progress-bar progress-bar-success\" data-dz-uploadprogress></div></div>\n  <div class=\"dz-success-mark\"><span></span></div>\n  <div class=\"dz-error-mark\"><span></span></div>\n  <div class=\"dz-error-message\"><span data-dz-errormessage></span></div>\n</div>"
	  });
	} catch(e) {
//		alert('Dropzone.js does not support older browsers!');
	}
	
	});
</script>


