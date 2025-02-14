<?php
//require_once ROOT_PATH . '/inc/excel/reader.php';
//require_once ROOT_PATH . '/inc/Classes/PHPExcel.php';
/**
 * More & Original PHP Framwork
 * Copyright (c) 2009 - 2010 IsMole Inc.
 * document ConfMaker 配置生成模块
 * $Id: ConfMaker.obj.php starten $
 */
class Control_ExcelConfMaker extends Control {
	public $excelDir = '/doc/excel/';
	public $excelExportDir = '/doc/excel_export/';
	
	// 下载上传
	public function downLoad() {
		if ($_GET['fn']) {
        	$configFileName = $_GET['fn'];
        } else {
        	echo 'error';	
        	exit;
		}
		
		// 文件不存在
		if (!MooFile::isExists(ROOT_PATH . '/conf/plist/' . $configFileName)) {
			exit('error: file not exists');	
		}
		
		$content = file_get_contents(ROOT_PATH . '/conf/plist/' . $configFileName);
		
		$filename = $configFileName;
		$encoded_filename = urlencode($filename);
		$encoded_filename = str_replace("+", "%20", $encoded_filename);
		
		$ua = $_SERVER['HTTP_USER_AGENT'];
		header('Content-Type: application/x-octet-stream;');
		if (preg_match("/MSIE/", $ua)) {
			header('Content-Disposition: attachment; filename="' . $encoded_filename . '"');
		} else if (preg_match("/Firefox/", $ua)) {
			header('Content-Disposition: attachment; filename*="utf8\'\'' . $filename . '"');
		} else {
			header('Content-Disposition: attachment; filename="' . $filename . '"');
		}
		
		echo $content;
	}
	
	// 文件上传
	public function showUpload($file) {
		MooView::set('fileName', $file);
		MooView::set('theDo', $_REQUEST['do']);
		
		// 是否提交
		if (MooForm::isSubmit()) {
			return $this->upload();
		}
		return false;
	}
	
	// 文件上传
	public function upload() {
		// 上传文件信息
        $images = $_FILES;
        $isUpload = 0;
        
        if (!$images) {
        	$msg = '没有选择上传文件';
        } else {
        
	        // 上传的图片们
	        $uploadImages = array();
	        $rsList = array();
	        
	        // 是否有文件上传
	        if (is_array($images)) {
	            foreach ($images as $k => $v) {
	                // 是批量上传
	                if (is_array($v['name'])) {
	                    foreach ($v['name'] as $nK => $nV) {
	                        $tmp = array();
	                        $tmp['name']        = $v['name'][$nK];
	        				$tmp['type']        = $v['type'][$nK];
	        				$tmp['error']       = $v['error'][$nK];
	        				$tmp['size']        = $v['size'][$nK];
	        				$tmp['tmp_name']    = $v['tmp_name'][$nK];
	        				$uploadImages[]     = $tmp;
	                    }
	                // 单个文件上传
	                } else {
	                    $uploadImages[] = $v;
	                }
	            }
	        }
	        
	        // 没有图片上传
	        if (!$uploadImages) {
	            $msg = '没有选择上传文件';
	        } else {
	        	// 文件传错了
	        	$upFileName = MooForm::request('fileName');
	        	if ($upFileName == 'wife_task_{wifeId}.conf.xls') {
	        		
	        	}
	        	
	        	if ($upFileName != $uploadImages[0]['name']) {
	        		$msg = '文件传错了，我需要【'. MooForm::request('fileName') . '】这个文件';
	        	} else {
	        	
		        	// 处理
			        foreach ($uploadImages as $image) {
			        	$rsList[] = $this->dealUpload($image);
			        }
			        
			        $msg = '上传文件成功';
			        $isUpload = 1;
	        	}
	        }
        }
		
        MooView::set('msg', $msg);
        MooView::set('rsList', $rsList);
        MooView::set('isUpload', $isUpload);
        return $isUpload;
	}
	
	// 上传到指定目录下
	private function dealUpload($image, $dir = '') {
	    $tmp       = array();
	    $type      = strtolower(pathinfo($image['name'], PATHINFO_EXTENSION));
	    $fileName  = $image['name'];
	    $upDir     = ROOT_PATH . $this->excelDir . $dir . $fileName;
	    
	    $name          = $image['name'];
	    $urlDir        = $dir . $fileName;
	    $time          = INTTIME;
	    $tmp['name']   = $image['name'];
	    $tmp['dir']    = $urlDir;
	    $tmp['status'] = 'ok';
	    
	    // 文件类型
	    if (!in_array($type, array('xls'))) {
	        $tmp['status'] = 'error';
	        return $tmp;
	    }
	    
	    // 目录不存在建立
	    if (!MooFIle::isExists(dirname($upDir))) {
			MooFile::mkDir(dirname($upDir));
		}
		
		// 目录确认失败
		if (!MooFIle::isExists(dirname($upDir))) {
		    $tmp['status'] = 'error';
	    	return $tmp;
		}

		// 开始上传
		if (!@move_uploaded_file($image['tmp_name'], $upDir)) {
		    $tmp['status'] = 'error';
	        return $tmp;
		}
		
	    return $tmp;
	}
}