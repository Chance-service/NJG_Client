<?php
require_once dirname(__FILE__) . '/config.inc.php';
require_once dirname(__FILE__) . '/lib.interface.php';
require_once dirname(__FILE__) . '/Smarty/Smarty.class.php';

/**
 * 
 * @desc smarty的封装类
 * 
 * example:
 * // 普通使用
 * view::set('a', 'a');
 * view::render('index');
 * 
 * // 缓存使用
 * view::cache(86400);
 * 
 * view::set('a', 'a');
 * view::render('index');
 */
final class MooView implements MooViewInterface {
	private $templateDir;
	private $compileDir;
	private $cacheDir;
	private $tplHz;
	private $cacheId;
	private $dataReg = array();

	/**
	 * smarty对象
	 *
	 * @var object
	 */
	private $smarty;

	/**
	 * 设置是否缓存
	 *
	 * @var boolean
	 */
	private $cacheTimeOut = false;

	/**
	 * 构造函数
	 *
	 * @return m_html
	 */
	public function __construct() {
		$this->cacheId = 'pageMooCache' . $_SERVER['PHP_SELF'] . '/' . md5($_SERVER['QUERY_STRING']);
	}
	
	public function __destruct() {
	}

	/**
	 * 重载smarty的assign函数
	 *
	 * @param fixed $item1
	 * @param fixes $item2
	 */
	static public function set($item1, $item2 = '') {
		$viewObj = self::_getInstance();
		if ($item2 !== '') {
			$viewObj->dataReg[] = array('k' => $item1, 'v' => $item2);
		} else {
			$viewObj->dataReg[] = array('k' => $item1);
		}
	}

	/**
	 * smarty的fetch函数
	 *
	 * @param string $tpl
	 * @return string
	 */
	static public function fetch($tpl) {
		$viewObj = self::_getInstance();
		$viewObj->loadSmarty();
		$tpl = $tpl . $viewObj->tplHz;
		return $viewObj->smarty->fetch($tpl);
	}

	/**
	 * smarty的display函数
	 *
	 * @param string $tpl
	 * @return string
	 */
	static public function render($tpl) {
		$viewObj = self::_getInstance();
		$viewObj->loadSmarty();

		$tpl = $tpl . $viewObj->tplHz;

		if (!$viewObj->cacheTimeOut) {
			$viewObj->smarty->display($tpl);
		} else {
			$content = $viewObj->smarty->fetch($tpl);

			// 取得当前文件的地址作为缓存标识,将当前文件的内容进行缓存
			MooCache::set($viewObj->cacheId, $content, $viewObj->cacheTimeOut);

			// 输出内容
			echo $content;
		}
		exit;
	}

	/**
	 * 控制缓存的方法
	 *
	 * @param int $timeout
	 */
	static public function cache($timeout = -1, $hz = '') {
		if ($timeout == 0) {
			return;
		}
		$viewObj = MooView::_getInstance();
		$viewObj->cacheId .= $hz;

		$viewObj->cacheTimeOut = intval($timeout);

		// 取得当前文件的地址作为缓存标识,取出缓存
		$content = MooCache::get($viewObj->cacheId);

		if (!$content) {
			return false;
		}
		exit($content);
	}

	/**
	 * 单件、工厂
	 *
	 * @return object
	 */
	static private function _getInstance() {
		if (is_object($this) && $this instanceof MooView) {
			return $this;
		}
		static $viewObj = null;
		if (!is_object($viewObj)) {
			$viewObj = new MooView();
		}

		return $viewObj;
	}

	/**
	 * 加载smarty
	 *
	 */
	private function loadSmarty() {
		$viewObj = self::_getInstance();
		if (is_object($viewObj->smarty)) {
			foreach ($viewObj->dataReg as $v) {
				if ($v['k']) {
					$viewObj->smarty->assign($v['k'], $v['v']);
				} else {
					$viewObj->smarty->assign($v['v']);
				}
			}
			$viewObj->dataReg = array();
			return ;
		}
		$viewObj->smarty = new Smarty();
		$viewObj->smarty->left_delimiter	= MOOVIEW_LEFT_DELIMITER;
		$viewObj->smarty->right_delimiter	= MOOVIEW_RIGHT_DELIMITER;
		$viewObj->smarty->template_dir		= MOOVIEW_TEMPLATE_DIR;
		$viewObj->smarty->compile_dir		= MOOVIEW_COMPILE_DIR;
		$viewObj->smarty->cache_dir			= MOOVIEW_CACHE_DIR;
		$viewObj->smarty->compile_check		= MOOVIEW_COMPILE_CHECK;
		$viewObj->smarty->caching			= false;
		$viewObj->tplHz						= MOOVIEW_SUFFIX;

		if (!MooFile::isExists($viewObj->smarty->template_dir)) {
			MooFile::mkDir($viewObj->smarty->template_dir);
		}
		if (!MooFile::isExists($viewObj->smarty->compile_dir)) {
			MooFile::mkDir($viewObj->smarty->compile_dir);
		}
		if (!MooFile::isExists($viewObj->smarty->cache_dir)) {
			MooFile::mkDir($viewObj->smarty->cache_dir);
		}
		foreach ($viewObj->dataReg as $v) {
			if ($v['k']) {
				$viewObj->smarty->assign($v['k'], $v['v']);
			} else {
				$viewObj->smarty->assign($v['v']);
			}
		}
		$viewObj->dataReg = array();
	}
}