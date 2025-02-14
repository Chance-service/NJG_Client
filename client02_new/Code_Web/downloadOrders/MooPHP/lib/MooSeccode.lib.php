<?php
require_once dirname(__FILE__) . '/config.inc.php';
require_once dirname(__FILE__) . '/lib.interface.php';

class MooSeccode {
	//note:生成的验证码
	var $cecCode = '';
	//note:生成的图片
	var $codeImage = '';
	//note:干扰素
	var $disturColor = '';
	//note:验证码的图片宽度
	var $codeImageWidth = 80;
	//note:验证码的图片高度
	var $codeImageHeight  = 20;
	//note:验证码位数
	var $cecCodeNum = 4;
	
	/**
	 * 输出头部
	 *
	 * @return void
	 */
	private function outHeader() {
		header("content-type: image/png");
	}
	
	/**
	 * 生成验证码
	 *
	 * @return void
	 */
	private function createCode() {
		$this->cecCode = strtoupper(substr(md5(rand()), 0, $this->cecCodeNum));
		return $this->cecCode;
	}

	/**
	 * 生成验证码图片
	 *
	 * @return void
	 */
	private function createImage() {
		$this->codeImage = @imagecreate($this->codeImageWidth, $this->codeImageHeight);
		imagecolorallocate($this->codeImage, 200, 200, 200);
		return $this->codeImage;
	}
	
	/**
	 * 加入图片干拢素
	 *
	 * @return void
	 */
	private function setDisturbColor() {
		for ($i = 0; $i <= 128; $i++) {
			$this->disturColor = imagecolorallocate($this->codeImage, rand(0, 255), rand(0, 255), rand(0, 255));
			imagesetpixel($this->codeImage, rand(2, 128),rand(2, 38), $this->disturColor);
		}
	}

	/**
	 * 设置验证码图片的大小
	 *
	 * @param integer $width：
	 * @param integer $height：
	 * @return boolean;
	 */
	private function setCodeImage($width, $height) {
		if($width == '' || $height == '') {
			return false;
		}
		$this->codeImageWidth = $width;
		$this->codeImageHeight = $height;
		return true;
	}

	/**
	 * 在图片上写入验证码
	 *
	 * @param integer $num
	 */
	private function writeCodeToImage($num = '') {
		if($num != '') {
			$this->cecCodeNum = $num;
		}
		for($i = 0; $i <= $this->cecCodeNum; $i++) {
			$bgColor = imagecolorallocate ($this->codeImage, rand(0, 255), rand(0, 128), rand(0, 255));
			$x = floor($this->codeImageWidth / $this->cecCodeNum) * $i;
			$y = rand(0, $this->codeImageHeight - 15);
			imagechar($this->codeImage, 5, $x, $y, $this->cecCode[$i], $bgColor);
		}
	}
	
	/**
	 * 把验证码的值写入session
	 *
	 * @param string $sessionName
	 */
	private function writeSession($sessionName) {
		session_start();
		session_register($sessionName);
		$_SESSION[$sessionName] = md5($this->cecCode);
	}

	/**
	 * 输出验证码图片
	 *
	 * @param integer $width
	 * @param integer $height
	 * @param integer $num
	 * @param string $sessionName
	 */
	function outCodeImage($width = '', $height = '' ,$num = '', $sessionName = 'MooCode') {
		if($width != '' || $height != '') {
			$this->setCodeImage($width, $height);
		}
		$this->outHeader();
		$this->createCode();
		$this->createImage();
		$this->setDisturbColor();
		$this->writeCodeToImage($num);
		$this->writeSession($sessionName);
		imagepng($this->codeImage);
		imagedestroy($this->codeImage);
	}
}