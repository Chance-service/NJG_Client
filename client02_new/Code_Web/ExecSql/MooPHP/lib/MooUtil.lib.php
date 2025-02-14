<?php
require_once dirname(__FILE__) . '/config.inc.php';
require_once dirname(__FILE__) . '/lib.interface.php';

/**
 * @desc 普通工具类
 *
 */
class MooUtil {
	/**
	 * 重定向
	 *
	 * @param string $url
	 */
	static function redirect($url, $script = false) {
		if (!$script) {
			header('Location: ' . $url);
		} else {
			echo "<script>location.href='{$url}'</script>";
		}
		exit();
	}

	/**
	 * 获取真实ip
	 *
	 * @return string
	 */
	static function realIp() {
		static $realip = NULL;
		if ($realip !== NULL) {
			return $realip;
		}

		if (isset($_SERVER)) {
			if (isset($_SERVER['HTTP_X_FORWARDED_FOR'])) {
				$arr = explode(',', $_SERVER['HTTP_X_FORWARDED_FOR']);

				//取X-Forwarded-for中第一个非unknown的有效Ip字符串
				foreach ($arr as $ip) {
					$ip = trim($ip);
					if ($ip != 'unknown') {
						$realip = $ip;
						break;
					}
				}
			} elseif (isset($_SERVER['HTTP_CLIENT_IP'])) {
				$realip = $_SERVER['HTTP_CLIENT_IP'];
			} else {
				if (isset($_SERVER['REMOTE_ADDR'])) {
					$realip = $_SERVER['REMOTE_ADDR'];
				} else {
					$realip = '0.0.0.0';
				}
			}
		} else {
			if (getenv('HTTP_X_FORWARDED_FOR')) {
				$realip = getenv('HTTP_X_FORWARDED_FOR');
			} elseif (getenv('HTTP_CLIENT_IP')) {
				$realip = getenv('HTTP_CLIENT_IP');
			} else {
				$realip = getenv('REMOTE_ADDR');
			}
		}

		$onlineip = null;
		preg_match("/[\d\.]{7,15}/", $realip, $onlineip);
		$realip = !empty($onlineip[0]) ? $onlineip[0] : '0.0.0.0';
		return $realip;
	}

	/**
	 * 获取顶级域名
	 * @param string $domain 域名
	 */
	static function getTopDomain($domain) {
		$domainroots = array('ac', 'ac.cn', 'ac.jp', 'ac.uk', 'ad.jp', 'adm.br', 'adv.br', 'aero', 'ag', 'agr.br', 'ah.cn', 'al', 'am.br', 'arq.br', 'at', 'au', 'art.br', 'as', 'asn.au', 'ato.br', 'be', 'bg', 'bio.br', 'biz', 'bj.cn', 'bmd.br', 'br', 'ca', 'cc', 'cd', 'ch', 'cim.br', 'ck', 'cl', 'cn', 'cng.br', 'cnt.br', 'com', 'com.au', 'com.br', 'com.cn', 'com.eg', 'com.hk', 'com.mx', 'com.ru', 'com.tw', 'conf.au', 'co.jp', 'co.uk', 'cq.cn', 'csiro.au', 'cx', 'cz', 'de', 'dk', 'ecn.br', 'ee', 'edu', 'edu.au', 'edu.br', 'eg', 'es', 'esp.br', 'etc.br', 'eti.br', 'eun.eg', 'emu.id.au', 'eng.br', 'far.br', 'fi', 'fj', 'fj.cn', 'fm.br', 'fnd.br', 'fo', 'fot.br', 'fst.br', 'fr', 'g12.br', 'gd.cn', 'ge', 'ggf.br', 'gl', 'gr', 'gr.jp', 'gs', 'gs.cn', 'gov.au', 'gov.br', 'gov.cn', 'gov.hk', 'gob.mx', 'gs', 'gz.cn', 'gx.cn', 'he.cn', 'ha.cn', 'hb.cn', 'hi.cn', 'hl.cn', 'hn.cn', 'hm', 'hk', 'hk.cn', 'hu', 'id.au', 'ie', 'ind.br', 'imb.br', 'inf.br', 'info', 'info.au', 'it', 'idv.tw', 'int', 'is', 'il', 'jl.cn', 'jor.br', 'jp', 'js.cn', 'jx.cn', 'kr', 'la', 'lel.br', 'li', 'lk', 'ln.cn', 'lt', 'lu', 'lv', 'ltd.uk', 'mat.br', 'mc', 'med.br', 'mil', 'mil.br', 'mn', 'mo.cn', 'ms', 'mus.br', 'mx', 'name', 'ne.jp', 'net', 'net.au', 'net.br', 'net.cn', 'net.eg', 'net.hk', 'net.lu', 'net.mx', 'net.uk', 'net.ru', 'net.tw', 'nl', 'nm.cn', 'no', 'nom.br', 'not.br', 'ntr.br', 'nx.cn', 'nz', 'plc.uk', 'odo.br', 'oop.br', 'or.jp', 'org', 'org.au', 'org.br', 'org.cn', 'org.hk', 'org.lu', 'org.ru', 'org.tw', 'org.uk', 'pl', 'pp.ru', 'ppg.br', 'pro.br', 'psi.br', 'psc.br', 'pt', 'qh.cn', 'qsl.br', 'rec.br', 'ro', 'ru', 'sc.cn', 'sd.cn', 'se', 'sg', 'sh', 'sh.cn', 'si', 'sk', 'slg.br', 'sm', 'sn.cn', 'srv.br', 'st', 'sx.cn', 'tc', 'th', 'tj.cn', 'tmp.br', 'to', 'tr', 'trd.br', 'tur.br', 'tv', 'tv.br', 'tw', 'tw.cn', 'uk', 'va', 'vet.br', 'vg', 'wattle.id.au', 'ws', 'xj.cn', 'xz.cn', 'yn.cn', 'zlg.br', 'zj.cn', 'my', 'me', 'us', 'asia', 'vc', 'pro', 'museum', 'coop', 'idv');
		$domains = explode('.', $domain);
		$count = count($domains);
		$dotnum = $count - 1;
		if (!$dotnum) {
			return FALSE;
		} elseif ($dotnum == 1) {
			return $domain;
		}
		if (in_array($domains[$dotnum - 1] . '.' . $domains[$dotnum], $domainroots)) {
			return $domains[$dotnum - 2] . '.' . $domains[$dotnum - 1] . '.' . $domains[$dotnum];
		} elseif (in_array($domains[$dotnum], $domainroots)) {
			return $domains[$dotnum - 1] . '.' . $domains[$dotnum];
		} else {
			return FALSE;
		}
	}

	// 加密解决函数
	//字符串解密加密
	static function authcode($string, $operation = 'DECODE', $key = '', $expiry = 0) {

		$ckey_length = 4;	// 随机密钥长度 取值 0-32;
		// 加入随机密钥，可以令密文无任何规律，即便是原文和密钥完全相同，加密结果也会每次不同，增大破解难度。
		// 取值越大，密文变动规律越大，密文变化 = 16 的 $ckey_length 次方
		// 当此值为 0 时，则不产生随机密钥

		$key = md5($key ? $key : UC_KEY);
		$keya = md5(substr($key, 0, 16));
		$keyb = md5(substr($key, 16, 16));
		$keyc = $ckey_length ? ($operation == 'DECODE' ? substr($string, 0, $ckey_length): substr(md5(microtime()), -$ckey_length)) : '';

		$cryptkey = $keya.md5($keya.$keyc);
		$key_length = strlen($cryptkey);

		$string = $operation == 'DECODE' ? base64_decode(substr($string, $ckey_length)) : sprintf('%010d', $expiry ? $expiry + time() : 0).substr(md5($string.$keyb), 0, 16).$string;
		$string_length = strlen($string);

		$result = '';
		$box = range(0, 255);

		$rndkey = array();
		for($i = 0; $i <= 255; $i++) {
			$rndkey[$i] = ord($cryptkey[$i % $key_length]);
		}

		for($j = $i = 0; $i < 256; $i++) {
			$j = ($j + $box[$i] + $rndkey[$i]) % 256;
			$tmp = $box[$i];
			$box[$i] = $box[$j];
			$box[$j] = $tmp;
		}

		for($a = $j = $i = 0; $i < $string_length; $i++) {
			$a = ($a + 1) % 256;
			$j = ($j + $box[$a]) % 256;
			$tmp = $box[$a];
			$box[$a] = $box[$j];
			$box[$j] = $tmp;
			$result .= chr(ord($string[$i]) ^ ($box[($box[$a] + $box[$j]) % 256]));
		}

		if($operation == 'DECODE') {
			if((substr($result, 0, 10) == 0 || substr($result, 0, 10) - time() > 0) && substr($result, 10, 16) == substr(md5(substr($result, 26).$keyb), 0, 16)) {
				return substr($result, 26);
			} else {
				return '';
			}
		} else {
			return $keyc.str_replace('=', '', base64_encode($result));
		}
	}
	
	/***************************************************************************
	* CvIp.php
	* ------------------------------
	* Date : Sep 7, 2007
	* Copyright : [Discuz!] (C) Comsenz Inc.
	* Mail :
	* Desc. : IP地址获取真实地址函数
	* History :
	* Date :
	* Author :
	* Modif. :
	* Usage Example :
	echo CvIp('218.56.198.104');
	//返回 山东省济南市 网通ADSL
	//如果参数为空则自动获取ip
	***************************************************************************/
	static function cvIp($ip='') {
		if(empty($ip)) $ip = self::_Cv_Get_Ip();
		if(!preg_match("/^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/", $ip)) { return false; }
		if ($fd = @fopen(LIB_PATH . '/QQWry.Dat', 'rb')) {
			$ip = explode('.', $ip);
			$ipNum = $ip[0]*16777216 + $ip[1]*65536 + $ip[2]*256 + $ip[3];
			$DataBegin = fread($fd, 4);
			$DataEnd = fread($fd, 4);
			$ipbegin = implode('', unpack('L', $DataBegin));

			if ($ipbegin < 0) $ipbegin += pow(2, 32);
			$ipend = implode('', unpack('L', $DataEnd));
			if($ipend < 0) $ipend += pow(2, 32);
			$ipAllNum = ($ipend - $ipbegin) / 7 + 1;
			$BeginNum = 0;
			$EndNum = $ipAllNum;

			while($ip1num > $ipNum || $ip2num < $ipNum) {
				$Middle= intval(($EndNum + $BeginNum) / 2);

				fseek($fd, $ipbegin + 7 * $Middle);
				$ipData1 = fread($fd, 4);
				if(strlen($ipData1) < 4) {
					fclose($fd);
					return 'System Error';
				}

				$ip1num = implode('', unpack('L', $ipData1));
				if($ip1num < 0) $ip1num += pow(2, 32);

				if($ip1num > $ipNum) {
					$EndNum = $Middle;
					continue;
				}

				$DataSeek = fread($fd, 3);
				if(strlen($DataSeek) < 3) {
					fclose($fd);
					return 'System Error';
				}

				$DataSeek = implode('', unpack('L', $DataSeek.chr(0)));
				fseek($fd, $DataSeek);
				$ipData2 = fread($fd, 4);
				if(strlen($ipData2) < 4) {
					fclose($fd);
					return 'System Error';
				}

				$ip2num = implode('', unpack('L', $ipData2));
				if($ip2num < 0) $ip2num += pow(2, 32);
				if($ip2num < $ipNum) {
					if($Middle == $BeginNum) {
						fclose($fd);
						return 'Unknown';
					}
					$BeginNum = $Middle;
				}
			}

			$ipFlag = fread($fd, 1);
			if($ipFlag == chr(1)) {
				$ipSeek = fread($fd, 3);
				if(strlen($ipSeek) < 3) {
					fclose($fd);
					return 'System Error';
				}

				$ipSeek = implode('', unpack('L', $ipSeek.chr(0)));
				fseek($fd, $ipSeek);
				$ipFlag = fread($fd, 1);
			}

			if($ipFlag == chr(2)) {
				$AddrSeek = fread($fd, 3);
				if(strlen($AddrSeek) < 3) {
					fclose($fd);
					return 'System Error';
				}
				$ipFlag = fread($fd, 1);
				if($ipFlag == chr(2)) {
					$AddrSeek2 = fread($fd, 3);
					if(strlen($AddrSeek2) < 3) {
						fclose($fd);
						return 'System Error';
					}
					$AddrSeek2 = implode('', unpack('L', $AddrSeek2.chr(0)));
					fseek($fd, $AddrSeek2);
				} else {
					fseek($fd, -1, SEEK_CUR);
				}

				while(($char = fread($fd, 1)) != chr(0))
				$ipAddr2 .= $char;

				$AddrSeek = implode('', unpack('L', $AddrSeek.chr(0)));
				fseek($fd, $AddrSeek);

				while(($char = fread($fd, 1)) != chr(0))
				$ipAddr1 .= $char;
			} else {
				fseek($fd, -1, SEEK_CUR);
				while(($char = fread($fd, 1)) != chr(0))
				$ipAddr1 .= $char;

				$ipFlag = fread($fd, 1);
				if($ipFlag == chr(2)) {
					$AddrSeek2 = fread($fd, 3);
					if(strlen($AddrSeek2) < 3) {
						fclose($fd);
						return 'System Error';
					}
					$AddrSeek2 = implode('', unpack('L', $AddrSeek2.chr(0)));
					fseek($fd, $AddrSeek2);
				} else {
					fseek($fd, -1, SEEK_CUR);
				}
				while(($char = fread($fd, 1)) != chr(0))
				$ipAddr2 .= $char;
			}
			fclose($fd);

			if(preg_match('/http/i', $ipAddr2)) {
				$ipAddr2 = '';
			}

			$ipaddr = "$ipAddr1 $ipAddr2";
			$ipaddr = preg_replace('/CZ88\.NET/is', '', $ipaddr);
			$ipaddr = preg_replace('/^\s*/is', '', $ipaddr);
			$ipaddr = preg_replace('/\s*$/is', '', $ipaddr);
			if(preg_match('/http/i', $ipaddr) || $ipaddr == '') {
				$ipaddr = 'Unknown';
			}

			$ipaddr = explode(' ', $ipaddr);
			return iconv('gbk', 'utf-8//IGNORE', trim($ipaddr[0]));
		}
	}

	function _Cv_Get_Ip() {
		$_IpArray = array($_SERVER['HTTP_X_FORWARDED_FOR'], $_SERVER['HTTP_CLIENT_IP'], $_SERVER['REMOTE_ADDR'], getenv('REMOTE_ADDR'));
		rsort($_IpArray);
		reset($_IpArray);
		return $_IpArray[0];
	}
}