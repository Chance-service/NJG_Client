<?php
class Mod_MooGame_PlatForm_encrypt {
	/**
	 * 对指定数据进行加密
	 *
	 * @param String OR Array $data 要加密的数据
	 * @param String $key 加密密钥
	 * @return String
	 */
	public function encrypt($data, $key = '') {
		
		// 加密数据转成字符串
		$str = json_encode($data);
		empty($key) && $key = 'moophpmodplatform@#$&!';
		
		// 本函数用来取得编码方式的区块大小
		$size = mcrypt_get_block_size('des', 'ecb');
		$str = $this->pkcs5_pad($str, $size);
		$td = mcrypt_module_open('des', '', 'ecb', '');
		$iv = @mcrypt_create_iv(mcrypt_enc_get_iv_size($td), MCRYPT_RAND);
		@mcrypt_generic_init($td, $key, $iv);
		$str = mcrypt_generic($td, $str);
		mcrypt_generic_deinit($td);
		mcrypt_module_close($td);
		$str = base64_encode($str);
		$str = base64_encode($str);
		return $str; 
	} 
	
	private function pkcs5_pad($text, $blocksize) {	
		$pad = $blocksize - (strlen($text) % $blocksize);	
		return $text . str_repeat(chr($pad), $pad); 
	}
	
	private function authCode($data, $key = '') {
		
		$dataStrArr = array();
		foreach ($data as $key => $value) {
			$dataStrArr[] = "{$key}::{$value}";
		}
		
		// 加密数据转成字符串
		$input = implode('||', $dataStrArr);
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
		
		return $result;
	}
}