<?php
/**
 * More & Original PHP Framwork
 * Copyright (c) 2009 - 2010 IsMole Inc.
 * document ConfMaker 配置生成模块
 * $Id: ConfMaker_demo.php starten $
 */
class Control_ExcelConfMaker_demo {
	var $theConf 	= array();
	var $fileName 	= 'demo.conf.xls';
	var $jsonFiles 	= array('demoConf.json');
	var $tpl 		= ''; // 生成配置文件的模板
	var $confPHPTpl = '';
	
	public function demo() {		
		// 是否有上传文件
		if ($this->OBJ->showUpload($this->fileName)) {
			$this->setConf();
			MooView::set('isNew', '<span style="color:red;"><em>（isNew）</em></span>');
		}
		
		// 程序内部直接生成配置文件
		if (defined('EXCEL_CONF_MAKER_DEMCIA') && EXCEL_CONF_MAKER_DEMCIA) {
			$this->setConf(false);
			return true;
		}
		
		// 直接生成配置文件
		if (MooForm::request('setC')) {
			$this->setConf();
			MooView::set('isNew', '<span style="color:red;"><em>（isNew）</em></span>');
		}
		
		MooView::set('title', 'demo配置');
		MooView::set('jsonFiles', $this->jsonFiles);
		MooView::render('conf_maker');
	}
	
	// 处理
	public function setConf() {
		$replace = array();
		$replace[] = '{name}';
		$replace[] = '{confId}';
		
		$file 	= ROOT_PATH . $this->OBJ->excelDir . $this->fileName;
		$rs 	= MooObj::get('Control_ExcelConfMaker_Excel')->read($file, 'UTF-8', 0);
		$list 	= array();
		
		//
		foreach ($rs as $k => $v) {

			// 最终替换的结果
			$replaceArr = array();
			$replaceArr[] = $v['name'];
			$replaceArr[] = $v['confId'];
			
			$tmpDemo = str_replace($replace, $replaceArr, $this->tpl);
			$list[] = $tmpDemo;
			
			// 
			$CONF = array();
			eval($tmpDemo);
			$this->theConf[$v['confId']] = $CONF[$v['confId']];
		}
		
		$confTpl = $this->confPHPTpl . join('', $list);
		MooFile::write(NAV_CONF_PATH . '/demo.conf.php', $confTpl);
		MooView::set('confTpl', highlight_string($confTpl, true));
		
		//$this->setJsonConf();
	}
	
	// 生成json 数据
	function setJsonConf() {
		$confD = $this->theConf;
		$data = array();
		foreach ($confD as $b) {
			$tmp = $b;
			$data[] = $tmp;
		}
		$jsonStr = json_encode($data);
		MooFile::write(SET_JSON_PATH . 'demoConf.json', $jsonStr);
		return true;
	}
}