<?php
class Control_Announce_save {
	function save() {
		
		  $game		= MooForm::request('game');
		  $area		= MooForm::request('area');
		  $lang		= MooForm::request('lang');
		  $fileName	= MooForm::request('file');
		  
		  $data = json_encode($_REQUEST);
		  
		  if($lang) {
		  	$namePre = $game. "_" . $area . "_" . $lang;
		  } else {
		  	$namePre = $game. "_" . $area;
		  }
		  $date = date('Y-m-d_H_i_s');
		  
		  $content 	= MooForm::request('content');
		 
		  if(!$fileName) {
		  	 $fileName = $namePre . "_" . $date;
		  	 $filePath = ROOT_PATH . "/notices/" . $fileName . ".txt";
		  } else {
		  	$filePath = ROOT_PATH . "/notices/" . $fileName;
		  }
		  
		  $content	= 	str_replace("\n",' ', $content);
		  
		  $content	= 	str_replace("|","'", $content);
		  
		  $rs = MooFile::write($filePath, $content);
		  if ($rs) {
		  	exit("编辑公告成功!");
		  } else {
		  	exit("编辑公告失败");
		  }
		  
	}
}