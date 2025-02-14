<?php
class Mod_MooGame_PlatForm_decrypt {
	/**
	 * 对加密串进行解密
	 *
	 * @param String $encryptStr 加密过的字符串
	 * @param String $key 密钥
	 * @return 
	 */
	public function decrypt($str, $key = '') {
		// 是否自定义密钥
		empty($key) && $key = 'moophpmodplatform@#$&!';
		
		$str = base64_decode($str);
		$str = base64_decode($str);
		$td = mcrypt_module_open('des','','ecb',''); //使用MCRYPT_DES算法,cbc模式
		$iv = @mcrypt_create_iv(mcrypt_enc_get_iv_size($td), MCRYPT_RAND);
		$ks = mcrypt_enc_get_key_size($td);
		@mcrypt_generic_init($td, $key, $iv); //初始处理
		$str = mdecrypt_generic($td, $str); //解密
		mcrypt_generic_deinit($td); //结束
		mcrypt_module_close($td);
		$enStr = $this->pkcs5_unpad($str);
		$rs = json_decode($enStr, true);
		return $rs; 
	}
	
	private function pkcs5_unpad($text) {
		$pad = ord($text{strlen($text)-1});
		if ($pad > strlen($text)) {
			return false;
		}
		if (strspn($text, chr($pad), strlen($text) - $pad) != $pad) {
			return false;
		}
		return substr($text, 0, -1 * $pad);
	}
	
	private function authCode($input, $key = '') {
	
		// 加密数据转成字符串
		empty($key) && $key = 'moophpmodplatform@#$&!';
	
		// Input must be of even length.
		if (strlen($input) % 2) {
			//$input .= '0';
		}
	
		// Keys longer than the input will be truncated.
		if (strlen($key) > strlen($input)) {
			$key = substr($key, 0, strlen($input));
		}
	
		// Keys shorter than the input will be padded.
		if (strlen($key) < strlen($input)) {
			$key = str_pad($key, strlen($input), '0', STR_PAD_RIGHT);
		}
	
		/*
		 * Now the key and input are the same length.
		* Zero is used for any trailing padding required.
		*
		* Simple XOR'ing, each input byte with each key byte.
		*/
		$result = '';
		for ($i = 0; $i < strlen($input); $i++) {
			$result .= $input{$i} ^ $key{$i};
		}
		
		// 加密数据转成字符串
		$inputStrArr = explode('||', $result);
		
		$data = array();
		foreach ($inputStrArr as $value) {
			$dataStrArr = explode('::', $result);
			$data[$dataStrArr[0]] = $dataStrArr[1];
		}
	
		return $data;
	}
}