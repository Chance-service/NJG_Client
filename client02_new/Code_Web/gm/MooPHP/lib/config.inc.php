<?php
// 设置模块类(MooModule)的所在目录
!defined('MOOMOD_MOD_DIR')		&& define('MOOMOD_MOD_DIR', dirname(dirname(__FILE__)) . '/module');

// 设置缓存类(MooCache)的缓存目录
!defined('MOOCACHE_CACHE_DIR')	&& define('MOOCACHE_CACHE_DIR', ROOT_PATH . '/data/cache');

// 设置MooDao类的所在目录
!defined('MOODAO_DAO_DIR')		&& define('MOODAO_DAO_DIR', ROOT_PATH . '/dao');

// 定义单元测试的文件夹
!defined('MOOOBJ_UNITTEST_DIR')	&& define('MOOOBJ_UNITTEST_DIR', ROOT_PATH . '/unitTest');

// 定义缓存使用的类型 (MEMCACHE, FILECACHE)
!defined('MOOCACHE_CACE_TYPE')	&& define('MOOCACHE_CACE_TYPE', 'FILECACHE');

// 定义是否使用DaoObj缓存
!defined('DAOOBJ_CACHE')		&& define('DAOOBJ_CACHE', 0);
!defined('DAOOBJ_CACHE_TIME')	&& define('DAOOBJ_CACHE_TIME', 86400);

// 设置MooLog类的日志目录
!defined('MOOLOG_LOG_DIR')		&& define('MOOLOG_LOG_DIR', ROOT_PATH . '/logs');

// 设置MooLog类需要过滤的目录
!defined('MOOLOG_FILTER_DIR')	&& define('MOOLOG_FILTER_DIR', ROOT_PATH);

// 设置MooConfig的配置文件所在目录
!defined('MOOCONFIG_CONF_DIR')	&& define('MOOCONFIG_CONF_DIR', ROOT_PATH . '/conf');

// 设置语言包所在的目录
!defined('MOOLANGUAGE_DIR')		&& define('MOOLANGUAGE_DIR', ROOT_PATH . '/lang');

// 设置对象类(MooObject)的所在目录
!defined('MOOOBJ_OBJ_DIR')		&& define('MOOOBJ_OBJ_DIR', ROOT_PATH . '/object');

// 设置模板类
!defined('MOOVIEW_LEFT_DELIMITER')		&& define('MOOVIEW_LEFT_DELIMITER', '<%');
!defined('MOOVIEW_RIGHT_DELIMITER')		&& define('MOOVIEW_RIGHT_DELIMITER', '%>');
!defined('MOOVIEW_TEMPLATE_DIR')		&& define('MOOVIEW_TEMPLATE_DIR', ROOT_PATH . '/tpl');
!defined('MOOVIEW_COMPILE_DIR')			&& define('MOOVIEW_COMPILE_DIR', ROOT_PATH . '/data/tpl_compile');
!defined('MOOVIEW_CACHE_DIR')			&& define('MOOVIEW_CACHE_DIR', ROOT_PATH . '/data/tpl_cache');
!defined('MOOVIEW_COMPILE_CHECK')		&& define('MOOVIEW_COMPILE_CHECK', true);
!defined('MOOVIEW_SUFFIX')				&& define('MOOVIEW_SUFFIX', '.html');

/**
 * 自动加载MooPHP的类
 *
 * @param string $className
 * @return boolean
 */
function __autoload($className) {
	
		
	
	if (strtoupper(substr($className, 0, 3)) != 'MOO') {
		return true;
	}
	
	static $reg = array();
	if ($reg[strtoupper($className)]) {
		return true;
	}

	switch (strtoupper($className)) {		
		
		case 'MOOARRAY':
			require_once dirname(__FILE__) . '/MooArray.lib.php';break;
		case 'MOOCACHE':
			require_once dirname(__FILE__) . '/MooCache.lib.php';break;
		case 'MOOCHART':
			require_once dirname(__FILE__) . '/MooChart.lib.php';break;
		case 'MOOCONFIG':
			require_once dirname(__FILE__) . '/MooConfig.lib.php';break;
		case 'MOOCOOKIE':
			require_once dirname(__FILE__) . '/MooCookie.lib.php';break;
		case 'MOODB':
		case 'MOODBSTATEMENT':
			require_once dirname(__FILE__) . '/MooDB.lib.php';break;
		case 'MOODBDEBUG':
			require_once dirname(__FILE__) . '/MooDBDebug.lib.php';break;
		case 'MOODBPAGIN':
			require_once dirname(__FILE__) . '/MooDBPagin.lib.php';break;
		case 'MOODBTABLE':
		case 'MOODAOOBJ':
		case 'MOODAO':
		case 'MOODAOREGISTER':
			require_once dirname(__FILE__) . '/MooDBTable.lib.php';break;
		case 'MOOERROR':
			require_once dirname(__FILE__) . '/MooError.lib.php';break;
		case 'MOOEXCEL':
			require_once dirname(__FILE__) . '/MooExcel.lib.php';break;
		case 'MOOFILE':
			require_once dirname(__FILE__) . '/MooFile.lib.php';break;
		case 'MOOFILECACHE':
			require_once dirname(__FILE__) . '/MooFileCache.lib.php';break;
		case 'MOOFORM':
			require_once dirname(__FILE__) . '/MooForm.lib.php';break;
		case 'MOOIMAGE':
			require_once dirname(__FILE__) . '/MooImage.lib.php';break;
		case 'MOOJSON':
			require_once dirname(__FILE__) . '/MooJson.lib.php';break;
		case 'MOOLANGUAGE':
			require_once dirname(__FILE__) . '/MooLanguage.lib.php';break;
		case 'MOOLOG':
			require_once dirname(__FILE__) . '/MooLog.lib.php';break;
		case 'MOOMEMCACHE':
			require_once dirname(__FILE__) . '/MooMemCache.lib.php';break;
		case 'MOOMODULE':
		case 'MOOMOD':
			require_once dirname(__FILE__) . '/MooModule.lib.php';break;
		case 'MOOOBJECT':
		case 'MOOOBJ':
			require_once dirname(__FILE__) . '/MooObject.lib.php';break;
		case 'MOOPAGIN':
			require_once dirname(__FILE__) . '/MooPagin.lib.php';break;
		case 'MOORANDOM':
			require_once dirname(__FILE__) . '/MooRandom.lib.php';break;
		case 'MOOSECCODE':
			require_once dirname(__FILE__) . '/MooSeccode.lib.php';break;
		case 'MOOSESSION':
			require_once dirname(__FILE__) . '/MooSession.lib.php';break;
		case 'MOOSTATWRITER':
			require_once dirname(__FILE__) . '/MooStatWriter.lib.php';break;
		case 'MOOSTATWRITER':
			require_once dirname(__FILE__) . '/MooStatWriter.lib.php';break;
		case 'MOOSTRING':
			require_once dirname(__FILE__) . '/MooString.lib.php';break;
		case 'MOOTTCACHE':
			require_once dirname(__FILE__) . '/MooTTCache.lib.php';break;
		case 'MOOREDISCACHE':
			require_once dirname(__FILE__) . '/MooRedisCache.lib.php';break;
		case 'MOOUNITTEST':
		case 'MOOUT':
			require_once dirname(__FILE__) . '/MooUnitTest.lib.php';break;
		case 'MOOUPLOAD':
			require_once dirname(__FILE__) . '/MooUpload.lib.php';break;
		case 'MOOUTIL':
			require_once dirname(__FILE__) . '/MooUtil.lib.php';break;
		case 'MOOVALIDATE':
			require_once dirname(__FILE__) . '/MooValidate.lib.php';break;
		case 'MOOVIEW':
			require_once dirname(__FILE__) . '/MooView.lib.php';break;
		case 'MOOXML':
			require_once dirname(__FILE__) . '/MooXml.lib.php';break;
		case 'MOOFILTER':
			require_once dirname(__FILE__) . '/MooFilter.lib.php';break;
		case 'MOOCOS':
			require_once dirname(__FILE__) . '/MooCos.lib.php';break;	
		default:
			require_once dirname(__FILE__) . '/' . $className . '.lib.php';
	}
	
	$reg[$className] = 1;
}

require_once dirname(__FILE__) . '/lib.interface.php';