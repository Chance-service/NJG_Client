<?php
require_once dirname(__FILE__) . '/config.inc.php';
require_once dirname(__FILE__) . '/lib.interface.php';

/**
 * 文件上传的类
 * @author 马顺仁
 * 
 * example:
 * 
 *	while ($file = MooUpload::parse()) {
 *		$rs = MooUpload::put($file);
 *		if (!$rs) {
 *			echo MooUpload::getError() . "\n";
 *		}
 *	}
 *
 */
final class MooUpload implements MooUploadInterface {
	private $allowType = array('jpg', 'jpeg', 'gif', 'png', 'bmp');
	private $maxSize = 2097152;
	private $totalSize = 0;
	private $fileDir = '';

	/**
	 * 构造
	 *
	 * @return Upload
	 */
	public function __construct() {
		// 如果没有定义则使用默认值
		$allowType ? $this->allowType = $allowType : false;
	}
	
	public function config($key, $value) {
		$upObj = self::_getInstance();
		$upObj->$key = $value;
	}

	/**
	 * 获取错误信息
	 *
	 * @return string
	 */
	static public function getError() {
		$upObj = self::_getInstance();
		return $upObj->errMsg;
	}

	/**
	 * 执行上传
	 *
	 * @param string $FILE
	 * @return mix
	 */
	static public function put($FILE) {
		$upObj = self::_getInstance();

		$name		= $FILE["name"]; // 文件名
		$tmpName	= $FILE["tmp_name"]; // 文件临时路径
		$error		= $FILE['error']; // 错误
		$hz			= strtolower(substr(strstr($name, '.'), 1)); // 文件后缀

		// 检查错误
		$upObj->errMsg = '';
		if (!$name || !$tmpName || $error != UPLOAD_ERR_OK) {
			$upObj->errMsg = "'{$name}'文件上传失败。";
		} elseif (!in_array($hz, $upObj->allowType)) {
			$upObj->errMsg = "'{$name}'上传失败，您只能上传以下类型的文件：" . implode(',', $upObj->allowType);
		} elseif ($upObj->totalSize > $upObj->maxSize) {
			$upObj->errMsg = "'{$name}'上传失败，文件大小总计不能超过" . round($upObj->maxSize / (1024 * 1024), 2) . '兆，但是当前已达到' . round($upObj->totalSize / (1024 * 1024), 2) . '兆';
		}

		if ($upObj->errMsg) {
			return false;
		}

		// 配置文件路径
		$time	= time();
		$txt	= substr(str_shuffle('abcdefghijklmnopqrstuvwxyz'), -6);
		$fileName	= date('ymdHis') . '_' . $txt . '.' . $hz;
		$firstDir	= date('Ym');
		$secDir		= $time % 256;
		$filePath	= "/{$firstDir}/$secDir/$fileName";
		$fileUrl	= "{$upObj->fileDir}{$filePath}";
		// 如果文件夹不存在则创建
		if (!MooFIle::isExists(dirname($fileUrl))) {
			MooFile::mkDir(dirname($fileUrl));
		}

		// 如果文件夹还不存在则返回错误
		if (!MooFIle::isExists(dirname($fileUrl))) {
			$upObj->errMsg = '上传文件时，文件夹建立失败。';
			return false;
		}

		// 开始上传
		$ok = @move_uploaded_file($tmpName, $fileUrl);
		return $ok ? $filePath : false;
	}

	/**
	 * 解析$_FILES
	 *
	 * @return mix
	 */
	static public function parse() {
		static $FILES = null;

		$upObj = self::_getInstance();
		if (!isset($FILES)) {
			$FILES = $_FILES;
		}

		if (!is_array($FILES)) {
			$FILES = null;
			return false;
		}

		$file = current($FILES);
		/**
		 * 如果是以file[]的方式批量上传，则需要重新定义数组结构。
		 */
		if (is_array($file['name'])) {
			$file['name'] = array_filter($file['name']);
			$FILES_TMP = array();
			foreach ($file['name'] as $k => $v) {
				$FILES_TMP[$k]['name'] = $v;
				$FILES_TMP[$k]['type'] = $file['type'][$k];
				$FILES_TMP[$k]['error'] = $file['error'][$k];
				$FILES_TMP[$k]['size'] = $file['size'][$k];
				$FILES_TMP[$k]['tmp_name'] = $file['tmp_name'][$k];
			}
			$FILES = $FILES_TMP;
		}
		$rs = array_shift($FILES);
		/**
		 * 统计总文件大小
		 */
		$upObj->totalSize += $rs['size'];
		return $rs;
	}

	/**
	 * 工厂、静态
	 *
	 * @return object
	 */
	private function _getInstance() {
		if (is_object($this) && $this instanceof MooUpload) {
			return $this;
		}
		static $upObj = null;
		if (!$upObj) {
			$upObj = new MooUpload();
		}
		return $upObj;
	}
}