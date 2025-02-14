<?php
require_once dirname(__FILE__) . '/config.inc.php';
require_once dirname(__FILE__) . '/lib.interface.php';

/**
 * @author kimi
 * @desc MooPHP老版本的封装类
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
final class MooTemplate implements MooViewInterface {
	private $templateDir;
	private $compileDir;
	private $cacheDir;
	private $tplHz;
	private $cacheId;

	private $var_regexp = "\@?\\\$[a-zA-Z_]\w*(?:\[[\w\.\"\'\[\]\$]+\])*";

	          //var $vtag_regexp = "\<\?=(\@?\\\$[a-zA-Z_]\w*(?:\[[\w\.\"\'\[\]\$]+\])*)\?\>";
	private $vtag_regexp = "\<\?php echo (\@?\\\$[a-zA-Z_][\\\$\w]*(?:\[[\w\-\.\"\'\[\]\$]+\])*)\;\?\>";
	private $const_regexp = "\{([\w]+)\}";

	/**
	 * 需要传入模板的数据
	 *
	 * @var array
	 */
	private $dataReg = array();

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
		if (!defined('MOOVIEW_TEMPLATE_DIR') || !defined('MOOVIEW_COMPILE_DIR')) {
			exit('ERROR: You must define MOOVIEW_TEMPLATE_DIR and MOOVIEW_COMPILE_DIR first.');
		}
		$this->templateDir = MOOVIEW_TEMPLATE_DIR;
		$this->compileDir = MOOVIEW_COMPILE_DIR;
	}
	
	public function __destruct() {
	}

	/**
	 * 设置传入模板的变量
	 *
	 * @param string $k
	 * @param value $v
	 */
	static public function set($k, $v = '') {
		$viewObj = self::_getInstance();
		$viewObj->dataReg[$k] = $v;
	}

	static public function fetch($tpl) {
	}

	/**
	 * 载入模板
	 *
	 * @param string $tpl
	 * @return string
	 */
	static public function render($tpl) {
		$viewObj = self::_getInstance();
		//note 释放所有需要传入模板的变量
		extract($viewObj->dataReg, EXTR_SKIP);
		include $viewObj->gettpl($tpl);
		exit;
	}

	/**
	 * 控制缓存的方法
	 *
	 * @param int $timeout
	 */
	static public function cache($timeout = -1) {

	}

	/**
	 * 返回编译后的路径
	 *
	 * @param string $tpl
	 * @return string
	 */
	private function gettpl($tpl) {
		$viewObj = self::_getInstance();

		$templateFile = $viewObj->templateDir.'/'.$tpl.MOOVIEW_SUFFIX;
		$compileFile = $viewObj->compileDir.'/'.$tpl.'.php';

		//note 判断文件是否存在
		$templateFileTime = @filemtime($templateFile);
		if($templateFileTime === FALSE) {
			exit('MooPHP File:<br>'.$templateFile.'<br>This file does not exist or have no access to read!');
		}

		//note 重新编辑模板
		if(($templateFileTime) > @filemtime($compileFile)) {
			$viewObj->complie($tpl);
		}

		return $compileFile;
	}

	/**
	 *  读模板页进行替换后写入到compileDir目录里
	 *
	 * @param string $tpl ：模板源文件地址
	 * @return string
	 */
	private function complie($tpl) {
		$viewObj = self::_getInstance();

		$templateFile = $viewObj->templateDir.'/'.$tpl.MOOVIEW_SUFFIX;
		$compileFile = $viewObj->compileDir.'/'.$tpl.'.php';


		$templateContent = MooFile::readAll($templateFile);
		$templateContent = $viewObj->parse($templateContent);

		if(!MooFile::write($compileFile,$templateContent)) {
			exit('MooPHP File :<br>'.$compileFile.'<br>Have no access to write!');
		}
	}

	/**
	 *  解析模板标签
	 *
	 * @param string $template ：模板源文件内容
	 * @return string
	 */
	private function parse($template) {
		$viewObj = self::_getInstance();
		$template = preg_replace("/\<\!\-\-\{(.+?)\}\-\-\>/s", "{\\1}", $template);//去除html注释符号<!---->
		$template = preg_replace("/\{($viewObj->var_regexp)\}/", "<?php echo \\1;?>", $template);//替换带{}的变量
		$template = preg_replace("/\{($viewObj->const_regexp)\}/", "<?php echo \\1;?>", $template);//替换带{}的常量
		$template = preg_replace("/(?<!\<\?php echo |\\\\)$viewObj->var_regexp/", "<?php echo \\0;?>", $template);//替换重复的<?php echo
		$template = preg_replace("/\<\?php echo (\@?\\\$[a-zA-Z_]\w*)((\[[\\$\[\]\w]+\])+)\;\?\>/ies", "\$viewObj->arrayindex('\\1', '\\2')", $template);//替换重复的<?php echo
		$template = preg_replace("/\{\{php (.*?)\}\}/ies", "\$viewObj->stripvtag('<? \\1?>')", $template);//替换php标签
		$template = preg_replace("/\{php (.*?)\}/ies", "\$viewObj->stripvtag('<? \\1?>')", $template);//替换php标签
		$template = preg_replace("/\{for (.*?)\}/ies", "\$viewObj->stripvtag('<? for(\\1) {?>')", $template);//替换for标签
		$template = preg_replace("/\{elseif\s+(.+?)\}/ies", "\$viewObj->stripvtag('<? } elseif(\\1) { ?>')", $template);//替换elseif标签
		for($i=0; $i<3; $i++) {
			$template = preg_replace("/\{loop\s+$viewObj->vtag_regexp\s+$viewObj->vtag_regexp\s+$viewObj->vtag_regexp\}(.+?)\{\/loop\}/ies", "\$viewObj->loopsection('\\1', '\\2', '\\3', '\\4')", $template);
			$template = preg_replace("/\{loop\s+$viewObj->vtag_regexp\s+$viewObj->vtag_regexp\}(.+?)\{\/loop\}/ies", "\$viewObj->loopsection('\\1', '', '\\2', '\\3')", $template);
		}
		$template = preg_replace("/\{if\s+(.+?)\}/ies", "\$viewObj->stripvtag('<? if(\\1) { ?>')", $template);//替换if标签
		$template = preg_replace("/\{template\s+(\w+?)\}/is", "<? include \$viewObj->gettpl('\\1');?>", $template);//替换include标签
		$template = preg_replace("/\{template\s+(.+?)\}/ise", "\$viewObj->stripvtag('<? include \$viewObj->gettpl(\\1); ?>')", $template);//替换template标签
		$template = preg_replace("/\{block (.*?)\}/ies", "\$viewObj->stripBlock('\\1')", $template);//替换block标签
		$template = preg_replace("/\{else\}/is", "<? } else { ?>", $template);//替换else标签
		$template = preg_replace("/\{\/if\}/is", "<? } ?>", $template);//替换/if标签
		$template = preg_replace("/\{\/for\}/is", "<? } ?>", $template);//替换/for标签
		$template = preg_replace("/$viewObj->const_regexp/", "<?php echo \\1;?>", $template);//note {else} 也符合常量格式，此处要注意这句语句的先后顺序
		$template = "<? if(!defined('IN_MOOPHP')) exit('Access Denied: Please Define Constant IN_MOOPHP!');?>\r\n$template";//添加模板的权限验证
		$template = preg_replace("/(\\\$[a-zA-Z_]\w+\[)([a-zA-Z_]\w+)\]/i", "\\1'\\2']", $template);//将二维数组替换成带单引号的标准模式

		return $template;
	}

	/**
	 * 替换重复的<?php echo
	 *
	 * @param string $name :
	 * @param string $items :
	 * @return string
	 */
	private function arrayindex($name, $items) {
		$items = preg_replace("/\[([a-zA-Z_]\w*)\]/is", "['\\1']", $items);
		return "<?php echo $name$items;?>";
	}

	/**
	 * 正则表达式匹配替换
	 *
	 * @param string $s :
	 * @return string
	 */
	private function stripvtag($s) {
		return preg_replace("/$this->vtag_regexp/is", "\\1", str_replace("\\\"", '"', $s));
	}

	/**
	 * 替换模板中的LOOP循环
	 *
	 * @param string $arr :
	 * @param string $k :
	 * @param string $v :
	 * @param string $statement :
	 * @return string
	 */
	private function loopsection($arr, $k, $v, $statement) {
		$arr = $this->stripvtag($arr);
		$k = $this->stripvtag($k);
		$v = $this->stripvtag($v);
		$statement = str_replace("\\\"", '"', $statement);
		return $k ? "<? foreach((array)$arr as $k => $v) {?>$statement<?}?>" : "<? foreach((array)$arr as $v) {?>$statement<? } ?>";
	}

	/**
	 * 将模板中的块替换成BLOCK函数
	 *
	 * @param string $blockname :
	 * @param string $parameter :
	 * @return string
	 */
	private function stripBlock($parameter) {
		return $this->stripTagQuotes("<?php echo 'it will been supported';//Mooblock(\"$parameter\"); ?>");
	}

	/**
	 * 处理stripBlock中的字符串
	 *
	 * @param string $expr :
	 * @return string
	 */
	private function stripTagQuotes($expr) {
		$expr = preg_replace("/\<\?php echo (\\\$.+?);\?\>/s", "{\\1}", $expr);
		$expr = str_replace("\\\"", "\"", preg_replace("/\[\'([a-zA-Z0-9_\-\.\x7f-\xff]+)\'\]/s", "[\\1]", $expr));
		return $expr;
	}

	/**
	 * 单件、工厂
	 *
	 * @return object
	 */
	private function _getInstance() {
		if (is_object($this) && $this instanceof MooTemplate) {
			return $this;
		}
		static $viewObj = null;
		if (!is_object($viewObj)) {
			$viewObj = new MooTemplate();
		}

		return $viewObj;
	}

}