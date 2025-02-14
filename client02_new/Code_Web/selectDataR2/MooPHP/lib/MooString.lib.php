<?php
require_once dirname(__FILE__) . '/config.inc.php';
require_once dirname(__FILE__) . '/lib.interface.php';

/**
 * @desc 字符串操作类
 *
 */
class MooString {
	/**
	 * 字符串截取函数
	 *
	 * @param string $string
	 * @param int $length
	 * @param string $dot
	 * @return string
	 */
	public static function cutstr($string, $length, $dot = ' ...') {
		if (strlen($string) <= $length) {
			return $string;
		}
		$strcut = '';
		$n = $tn = $noc = 0;
		while ($n < strlen($string)) {
			$t = ord($string[$n]);
			if ($t == 9 || $t == 10 || (32 <= $t && $t <= 126)) {
				$tn = 1;
				$n++;
				$noc++;
			} elseif (194 <= $t && $t <= 223) {
				$tn = 2;
				$n += 2;
				$noc += 2;
			} elseif (224 <= $t && $t < 239) {
				$tn = 3;
				$n += 3;
				$noc += 2;
			} elseif (240 <= $t && $t <= 247) {
				$tn = 4;
				$n += 4;
				$noc += 2;
			} elseif (248 <= $t && $t <= 251) {
				$tn = 5;
				$n += 5;
				$noc += 2;
			} elseif ($t == 252 || $t == 253) {
				$tn = 6;
				$n += 6;
				$noc += 2;
			} else {
				$n++;
			}
			if ($noc >= $length) {
				break;
			}
		}
		if ($noc > $length) {
			$n -= $tn;
		}
		$strcut = substr($string, 0, $n);
		return $strcut . $dot;
	}

	/**
	 * 过滤字符串中的乱码
	 *
	 * @param string $str
	 * @return string
	 */
	public static function escape($str) {
		$esc_ascii_table = array(chr(0), chr(1), chr(2), chr(3), chr(4), chr(5), chr(6), chr(7), chr(8), chr(11), chr(12), chr(14), chr(15), chr(16), chr(17), chr(18), chr(19), chr(20), chr(21), chr(22), chr(23), chr(24), chr(25), chr(26), chr(27), chr(28), chr(29), chr(30), chr(31));

		$str = str_replace($esc_ascii_table, '', $str);
		return $str;
	}

	/**
	 * 文本转HTML
	 *
	 * @param string $txt;
	 * return string;
	 */
	function Text2Html($txt){
		$txt = str_replace("  ","　",$txt);
		$txt = str_replace("<","&lt;",$txt);
		$txt = str_replace(">","&gt;",$txt);
		$txt = preg_replace("/[\r\n]{1,}/isU","<br/>\r\n",$txt);
		return $txt;
	}

}