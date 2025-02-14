<?php
require_once dirname(__FILE__) . '/config.inc.php';
require_once dirname(__FILE__) . '/lib.interface.php';

class MooUT {
	var $interface = array();
	
	/**
	 * 单元测试入口
	 */
	function start() {
		if ($_GET) {
			header("Content-type: text/html; charset=utf-8");
			echo $this->run($_GET['obj'] . '.php');
			exit;
		} else {
			// 读取object目录下的所有方法
			$this->readDir(MOOOBJ_OBJ_DIR);
			
			// 输出html头部
			echo $this->getHeader();
			
			// 开始循环处理各个方法
			$div = '';
			$arr = 'var interface = Array();';
			$i = 0;
			foreach ($this->interface as $interface) {
				$objArr = explode('_', $interface);
				$objPath = MOOOBJ_UNITTEST_DIR . '/' . '/' . $interface;
				
				$interface = substr($interface, 0, strpos($interface, '.'));
				if (!MooFile::isExists($objPath)) {
					$noUnit = "<span style='color:#CCC'>无单元测试</span>";
				} else {
					$noUnit = '';
					$arr .= "interface[$i] = '$interface';";
					$i++;
				}
				$div .= "
				<div style='clear:both' onmouseover='changeBg(\"{$interface}\", \"#EEE\")'  onmouseout='changeBg(\"{$interface}\", \"#FFF\")'>
					<div style='float:left'><a id='{$interface}_L' href='?obj={$interface}' style='color:#333' target='_blank'>{$interface}</a></div>
					<div style='float:right' id='{$interface}'>{$noUnit}</div>
				</div>
				<div style='clear:both;display:none' id='{$interface}_UT'></div>";
			}
			
			echo $div;
			echo "<script>$arr;\ncallServer(interface[0])</script>";
			echo "</body></html>";
		}
	}
	
	/**
	 * 开始执行测试文件
	 * @param $obj
	 * @return string
	 */
	function run($obj) {
		$objPath = MOOOBJ_UNITTEST_DIR . '/' . $obj;
		if (!MooFile::isExists($objPath)) {
			return "<span style='color:#CCC'>无单元测试</span>END";
		}
		
		// 加载单元测试文件
		require_once $objPath;
		
		// 
		$objName = str_replace('.php', '', $obj);
		$objName = explode('/', $objName);
		$func = array_pop($objName);array_pop($objName);
		$objName = 'UT_' . join('_', $objName) . '_' . $func;
		$obj = new $objName();
		if ($obj->main()) {
			return "<span><a href='###' style='color:green' onclick='showHidden(\"{$objName}\")'>测试通过</a></span>END";
		} else {
			return "<span><a href='###' style='color:red' onclick='showHidden(\"{$objName}\")'>测试失败</a></span>END" . $this->diffResult(MooUnitTest::diffResult());
		}
	}

	function diffResult($diff) {
		$a = $diff[0];
		$b = $diff[1];
		
		$a = var_export($a, 1);
		$b = var_export($b, 1);
		$arrA = explode("\n", $a);
		$arrB = explode("\n", $b);
		foreach ($arrA as $k => $str) {
			if (trim($str) != trim($arrB[$k])) {
				$a = str_replace($str, "<span style='color:red'>" . $str . '</span>', $a);
			}
		}
		foreach ($arrB as $k => $str) {
			if (trim($str) != trim($arrA[$k])) {
				$b = str_replace($str, "<span style='color:red'>" . $str . '</span>', $b);
			}
		}
		return "<div style='width: 100%; clear: both; margin-top: 20px'>
		<div style='float:left;width:49%;border:1px #CCC solid'><pre>$a</pre></div>
		<div style='float:left;width:49%;border:1px #CCC solid'><pre>$b</pre></div>
		</div>";
	}
	
	/**
	 * 读取目录下的方法文件
	 * @param $dir
	 */
	function readDir($dir) {
		while (false !== $file = MooFile::readDir($dir)) {
			if (strpos($file, '.svn') || strpos($file, '.obj')) {
				continue;
			}
			
			if (MooFile::isDir($file)) {
				$this->readDir($file);
			} else {
				$this->interface[] = str_replace(MOOOBJ_OBJ_DIR . '/', '', $file);
			}
		}
	}
	
	function getHeader() {
		return
		"<html xmlns='http://www.w3.org/1999/xhtml'>
		<head><meta http-equiv='content-type' content='text/html; charset=UTF-8'></head>
		<script>
			function showHidden(Id) {
				display = document.getElementById(Id).style.display;
				if (display != 'block') {
					document.getElementById(Id).style.display = 'block'
				} else {
					document.getElementById(Id).style.display = 'none'
				}
			}
			var xmlHttp = false;
			if (!xmlHttp && typeof XMLHttpRequest != 'undefined') {
			  xmlHttp = new XMLHttpRequest();
			}
			
			var theObj = '';
			var i = 0;
			function callServer(obj) {
			  i++;
			  theObj = obj;
			  var url = '?obj=' + obj;
			  xmlHttp.open('GET', url, true);
			  xmlHttp.onreadystatechange = updatePage;
			  xmlHttp.send(null);
			}
			
			function updatePage() {
				if (xmlHttp.readyState == 4) {
				    var response = xmlHttp.responseText;
				    stats = response.substring(0, response.indexOf('END'));
				    sql = response.substring(response.indexOf('END') + 3, response.length);
				    
				    document.getElementById(theObj).innerHTML = stats;
				    document.getElementById(theObj + '_UT').innerHTML = sql;
				    if (i < interface.length) {
				    	callServer(interface[i]);
				    }
				}
			}
			
			function changeBg(theId, color) {
					document.getElementById(theId).style.background=color
					document.getElementById(theId + '_L').style.background=color
			}
		</script>
		<body>";
	}
}

class MooUnitTest {
	
	function diffResult($a = '', $b = '') {
		static $diff;
		
		if ($diff) {
			$tmp = $diff;
			$diff = '';
			return $tmp;
		}
		
		$diff = array($a, $b);
		return $rs;
	}
}