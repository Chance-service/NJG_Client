<?php
/**
 * @desc debug数据计息累
 * 
 * expample:
 * 实力化这个对象即可。本类所有方法无须手工调用。
 * 
 */
final class MooDebugParse {

	/**
	 * 解析数据
	 * $data = array();
	 * $data['main']
	 * $data['cache']
	 * $data['database']
	 * $data['request']
	 * $data['file']
	 * @param mixed	$data
	 * @return void
	 */
	public static function parse($data = array(), $isEcho = false){
		global $_MooPHP;

		$_MooPHP['debug']['main']['memory'] = $memory = memory_get_usage(true) / 1024 / 1024;
		$_MooPHP['debug']['main']['cacheNum'] = count($data['cache']);
		if (defined('STARTTIME') && STARTTIME) {
			list($Moousec, $Moosec) = explode(" ", microtime());
			$_MooPHP['debug']['main']['time'] = sprintf('%0.6f', ((float)$Moousec + (float)$Moosec - STARTTIME));
		} else {
			$_MooPHP['debug']['main']['time'] = '<font color="red">PLEASE DEFINE STARTTIME</font>';
		}

		$_MooPHP['debug']['request'] = $_REQUEST;

		$htmlContent = self::htmlContent();
		$htmlContent .= self::parseMainInfo($data['main']);
		$htmlContent .= self::parseCacheInfo($data['cache']);
		$htmlContent .= self::parseDBInfo($data['database']);
		$htmlContent .= self::parseRequestInfo($data['request']);
		$htmlContent .= self::parseFileInfo($data['file']);

		if($isEcho) {
			echo $htmlContent;
		} else {
			return $htmlContent;
		}
	}

	/**
	 * 解析file数据
	 * $data = array();
	 * @param mixed	$data
	 * @return string
	 */
	private function parseMainInfo($data) {

		
		if($data) {
			$returnData = '<table cellspacing="0" class="moodebugtable">';
			$returnData .= '<tr><td width="70" class="bold">DeBugInfo</td><td>Processed in '.$data['time'].' seconds, '.$data['sqlNum'].' queries, '.$data['cacheNum'].' cacheItems, '.$data['memory'].'(M) memory.</td></tr>';
			$returnData .= '</table>';
		}

		return $returnData;
	}

	/**
	 * 解析request数据
	 * $data = array();
	 * @param mixed	$data
	 * @return string
	 */
	private function parseRequestInfo($data) {
		$returnData = '<table cellspacing="0" class="moodebugtable">';
		foreach((array)$data as $key => $value) {
			$returnData .= '<tr><th width="20">2</th><td width="250">$_REQUEST[\''.$key.'\']</td><td style="overflow:hidden;">'.$value.'</td></tr>';
		}
		$returnData .= '</table>';

		return $returnData;
	}

	/**
	 * 解析database数据
	 * $data = array();
	 * @param mixed	$data
	 * @return string
	 */
	private function parseDBInfo($data) {
		$returnData = '<table cellspacing="0" class="moodebugtable">';
		$i = 1;
		foreach((array)$data as $value) {
			$returnData .= $value;
			$i++;
		}
		$returnData .= '</table>';

		return $returnData;
	}

	/**
	 * 解析cache数据
	 * $data = array();
	 * @param mixed	$data
	 * @return string
	 */
	private function parseCacheInfo($data) {

		$returnData = '<table cellspacing="0" class="moodebugtable2">';

		$i = 1;
		foreach((array)$data as $key => $value) {
			$returnData .= '<tr><th width="20">'.$i.'</th><td width="25">'.$value['type'].'</td><td width="60">'.$value['time'].' ms</td><td width="80">'.$value['size'].' Byte</td><td width="250"><b>Server'.$value['serverId'].':</b>'.$value['server'].'</td><td>'.$key.'</td></tr>';
			$i++;
		}

		$returnData .= '</table>';


		return $returnData;
	}

	/**
	 * 解析file数据
	 * $data = array();
	 * @param mixed	$data
	 * @return string
	 */
	private function parseFileInfo($files) {

		if($files) {
			$returnData = '<table cellspacing="0" class="moodebugtable2">';
			foreach ($files as $key => $file) {
				$returnData .= '<tr><th width="30">'.($key+1).'</th><td>'.$file.'</td></tr>';
			}
			$returnData .= '</table>';
		}

		return $returnData;
	}

	/**
	 * 解析cache数据
	 * @return string
	 */
	private function htmlContent() {
		return <<<END
<style type="text/css">
.moodebugtable, .moodebugtable2 {
    text-align: left;
    width: 99%;
    border: 0;
    border-collapse: collapse;
    margin-bottom: 15px;
    margin-top: 15px;
    table-layout: fixed;
    background: #FFF;
}
 
.moodebugtable table, .moodebugtable2 table {
    width: 100%;
    border: 0;
    table-layout: fixed;
}
 
.moodebugtable table td, .moodebugtable2 table td {
    border-bottom: 0;
    border-right: 0;
    border-color: #ADADAD;
}
 
.moodebugtable th, .moodebugtable2 th {
    border: 1px solid #000;
    background: #CCC;
    padding: 2px;
    font-size: 12px;
}
 
.moodebugtable td, .moodebugtable2 td {
    border: 1px solid #000;
    background: #EFF5D9;
    padding: 2px;
    font-size: 12px;
}
 
.moodebugtable2 th {
    background: #E5EAD1;
}
 
.moodebugtable2 td {
    background: #FFFFFF;
}
 
.firsttr td {
    border-top: 0;
}
 
.firsttd {
    border-left: none !important;
}
 
.bold {
    font-weight: bold;
}
</style>
END;

	}

}
