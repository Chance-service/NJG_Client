<?php
require_once dirname(__FILE__) . '/config.inc.php';
require_once dirname(__FILE__) . '/lib.interface.php';
require_once dirname(__FILE__) . '/MooCosUtil.php';

define('COS_HOST', "cosapi.myqcloud.com");
define('COS_HOST_INNER', "cosapi.tencentyun.com");
define('COS_DOWNLOAD_HOST', "cos.myqcloud.com");
define('COS_DOWNLOAD_HOST_INNER', "cos.tencentyun.com");
define('COS_W_PRIVATE_R_PRIVATE', 0);
define('COS_W_PRIVATE_R_PUBLIC', 1);
define('COS_ERROR_REQUIRED_PARAMETER_EMPTY', 1001); // 参数为空
define('COS_ERROR_REQUIRED_PARAMETER_INVALID', 1002); // 参数格式错误
define('COS_ERROR_RESPONSE_DATA_INVALID', 1003); // 返回包格式错误
define('COS_ERROR_CURL', 1004); // 网络错误

define('COS_ERROR_REQUIRED_NOT_OPEN', 0); // 关闭 cosAPI


class MooCos {
	
	static private $accessId;
	static private $accessKey;
	static private $secretId;
	static private $host;

	/**
	 * 初始化  cos 配置
	 * Enter description here ...
	 */	
	private static function initialize() {
		$main 	= MooConfig::get('main.cos');			
		$isOpen 	= $main['isOpen'];		
		// 已经关闭
		if ($isOpen != 1) {
			return false;
		}
		$host 		= $main['host'];
		$accessId 	= $main['accessId'];
		$screctKey 	= $main['screctKey'];
		$secretId 	= $main['secretId'];
		self::$host	   		= $host;
		self::$accessId   	= $accessId;
		self::$secretId   	= $secretId;
		self::$accessKey   	= $screctKey; 
		return true;
		
	}

	private static function initializeDown() {
		$main 	= MooConfig::get('main.cos');
		$host 		= $main['host'];
		$accessId 	= $main['accessId'];
		$screctKey 	= $main['screctKey'];
		$secretId 	= $main['secretId'];
		self::$host	   		= $host;
		self::$accessId   	= $accessId;
		self::$secretId   	= $secretId;
		self::$accessKey   	= $screctKey; 
		return true;
		
	} 
	
	/**
	 * 创建bucket 
	 * Enter description here ...
	 * @param string $bucketId bucket名称
	 * @param array $opt $opt['acl'] = 1 | 0 权限设置
	 */
	public static function create_bucket($bucketId, $opt = array()) {
		$ret = array (
			'code'=>0,
			'msg'=>'ok',
		);
		
		if(empty($bucketId)) {
			$ret['code'] = COS_ERROR_REQUIRED_PARAMETER_EMPTY;
			$ret['msg'] = 'BucketId is empty!';
			return $ret;
		}
				
		$script_name = '/api/cos_create_bucket';
		$params = array(
			'bucketId' => $bucketId,			
		);
		
		if(isset($opt['acl'])) {
			$acl = $opt['acl'];
			if($acl != 0 && $acl != 1) {
				$ret['code'] = COS_ERROR_REQUIRED_PARAMETER_INVALID;
				$ret['msg'] = 'Invalid acl!';
				return $ret;
			}
			$params['acl'] = $acl;
		}
		if(isset($opt['referer'])) {
			$params['referer'] = $opt['referer'];
		}
		return self::api($script_name , $params , 'PUT');
	}
	
	
	/**
	 * 获取 bucket 列表
	 * @param int $offset     起始地址（可选，默认为 0）
	 * @param int $count      获取数量（可选，取值范围为0 到100，默认值为 20）
	 * @param string $prefix  按照该名字前缀拉取bucket（可选，默认为空）
	 * @return array          结果数组
	 */
	public static function get_bucket_list($offset = 0, $count = 20, $prefix = "") {
		$ret = array (
			'code'=>0,
			'msg'=>'ok',
		);
		
		if($offset < 0) {
			$ret['code'] = COS_ERROR_REQUIRED_PARAMETER_INVALID;
			$ret['msg'] = 'Illegal offset!';
			return $ret;
		}
		
		if($count < 0 || $count > 100)
		{
			$ret['code'] = COS_ERROR_REQUIRED_PARAMETER_INVALID;
			$ret['msg'] = 'Illegal count!';
			return $ret;
		}
		
		$script_name = '/api/cos_list_bucket';
		$params = array(
			'offset' => $offset,
			'count'  => $count,
		);
		
		if(strlen($prefix) > 0) {
			$params['prefix'] = $prefix;
		}
		
		return self::api($script_name, $params, 'GET');
	}
	
	
	/**
	 * 获取bucket信息，包括：referer、acl等
	 *
	 * @param string $bucketId 桶Id, 长度<=64、字符（123456789 and A~Z and a~z  and _  - .）
	 *
	 * @return array 结果数组
	 */
	
	public static function get_bucket_info($bucketId) {
		$ret = array (
			'code'=>0,
			'msg'=>'ok',
		);
		
		if(empty($bucketId)) {
			$ret['code'] = COS_ERROR_REQUIRED_PARAMETER_EMPTY;
			$ret['msg'] = 'BucketId is empty!';
			return $ret;
		}
				
		$script_name = '/api/cos_get_bucket';
		$params = array(
			'bucketId' => $bucketId
		);

		return self::api($script_name , $params , 'GET');
	}
	
	
	/**
	 * 设置bucket信息，包括：referer、acl等
	 *
	 * @param string $bucketId 桶Id, 长度<=64、字符（123456789 and A~Z and a~z  and _  - .）
	 * @param array opt 可选参数列表: 
	 *                "acl"  取值 0：必需在签名授权的情况下可读；1：公开读
	 *                "referer" 允许访问 bucket的referer，如 "http://qq.com"
	 *                
	 * @return array 结果数组
	 */
	public static function set_bucket_info($bucketId, $opt = array()) {
		$ret = array (
			'code'=>0,
			'msg'=>'ok',
		);
		
		if(empty($bucketId)) {
			$ret['code'] = COS_ERROR_REQUIRED_PARAMETER_EMPTY;
			$ret['msg'] = 'BucketId is empty!';
			return $ret;
		}
		
		if(empty($opt)) {
			$ret['code'] = COS_ERROR_REQUIRED_PARAMETER_EMPTY;
			$ret['msg'] = 'Empty params!';
			return $ret;
		}
		
		$script_name = '/api/cos_set_bucket';
		$params = array(
			'bucketId' => $bucketId,
		);
		
		if(isset($opt['acl'])) {
			$acl = $opt['acl'];
			if($acl != 0 && $acl != 1) {
				$ret['code'] = -1;
				$ret['msg'] = 'acl param error.';
				return $ret;
			}
			$params["acl"] = $acl;
		}
		
		if(isset($opt['referer'])) {
			$params["referer"] = $opt['referer'];
		}
		
		return self::api($script_name, $params, 'PUT');
	}
	
	/**
	 * 创建目录
	 *
	 * @param string $bucketId  桶Id, 长度<=64、字符（123456789 and A~Z and a~z  and _  - .）
	 * @param string $path      目录路径，以"/"开头（注：上级目录必须存在）
	 *
	 * 
	 * @param array $opt 可选参数列表:
	 * 			   "mkType"  批量创建目录标识:p 标识可以批量创建目录
	 *             "expires"  该目录下的”直接”文件（一级文件），下载时的 Expires header （可选，默认为7200）
	 *             "cacheControl" 文件被下载时的 Cache-Control header （可选，默认为空）
	 *             "contentEncoding" 文件被下载时的 Content-Encoding （可选，默认为空）
	 *             "contentLanguage" 文件被下载时的 Content-Language （可选，默认为空）
	 *             "contentDisposition" 文件被下载时的 Content-Disposition（可选，默认为空）
	 * 
	 * @return array 结果数组
	 */
	public static function create_dir($bucketId, $path, $opt) {
		$ret = array (
			'code'=>0,
			'msg'=>'ok',
		);
		
		if(empty($bucketId)) {
			$ret['code'] = COS_ERROR_REQUIRED_PARAMETER_EMPTY;
			$ret['msg']  = 'BucketId is empty!';
			return $ret;
		}
		
		if(empty($path)) {
			$ret['code'] = COS_ERROR_REQUIRED_PARAMETER_EMPTY;
			$ret['msg'] = 'Empty path param!';
			return $ret;
		}
		
		if($path[0] != "/") {
			$path = "/".$path;
		}
		$script_name = '/api/cos_mkdir';
		$params = array(
			'bucketId' => $bucketId,
			'path' => $path,
		);
		
		if(isset($opt["mkType"])) {
			$params["mkType"] = $opt['mkType'];
		}
		
		if(isset($opt['expires'])) {
			$params["expires"] = $opt['expires'];
		}
		if(isset($opt['cacheControl'])) {
			$params["cacheControl"] = $opt['cacheControl'];
		}
		if(isset($opt['contentEncoding'])) {
			$params["contentEncoding"] = $opt['contentEncoding'];
		}
		if(isset($opt['contentLanguage'])) {
			$params["contentLanguage"] = $opt['contentLanguage'];
		}
		if(isset($opt['contentDisposition'])) {
			$params["contentDisposition"] = $opt['contentDisposition'];
		}
		
		return self::api($script_name, $params, 'PUT');
	}
	
	/**
	 * 获取文件或目录信息
	 *
	 * @param string $bucketId 桶Id, 长度<=64、字符（123456789 and A~Z and a~z  and _  - .）
	 * @param string $path 文件或者目录路径，以 "/" 开头
	 *
	 * @return array 结果数组
	 */
	public static function get_meta($bucketId , $path) {
		$ret = array (
			'code'=>0,
			'msg'=>'ok',
		);
		
		if(empty($bucketId)) {
			$ret['code'] = COS_ERROR_REQUIRED_PARAMETER_EMPTY;
			$ret['msg'] = 'BucketId is empty!';
			return $ret;
		}
		
		if(empty($path)) {
			$ret['code'] = COS_ERROR_REQUIRED_PARAMETER_EMPTY;
			$ret['msg'] = 'Empty path param!';
			return $ret;
		}
		
		if($path[0] != "/") {
			$path = "/".$path;
		}
		
		$script_name = '/api/cos_get_meta';
		$params = array(
			'bucketId' => $bucketId,
			'path' => $path
		);
		return self::api($script_name , $params , 'GET');
	}
	
	/**
	 * 设置 目录 属性，设置后，该目录下的所有文件被下载时将会输出对应的HTTP头
	 *
	 * @param string $bucketId 桶Id, 长度<=64、字符（123456789 and A~Z and a~z  and _  - .）
	 * @param string $path 文件或者目录路径
	 * 
	 * @param array $opt 可选参数列表：
	 *             "expires"  该目录下的”直接”文件（一级文件），下载时的 Expires header （可选，默认为7200）
	 *             "cacheControl" 文件被下载时的 Cache-Control header（可选）
	 *             "contentEncoding" 文件被下载时的 Content-Encoding（可选）
	 *             "contentLanguage" 文件被下载时的 Content-Language（可选）
	 *             "contentDisposition" 文件被下载时的 Content-Disposition（可选）
	 *
	 * @return array 结果数组
	 */
	public static function set_meta($bucketId, $path, $opt) {
		$ret = array (
			'code'=>0,
			'msg'=>'ok',
		);
		
		if(empty($bucketId)) {
			$ret['code'] = COS_ERROR_REQUIRED_PARAMETER_EMPTY;
			$ret['msg'] = 'BucketId is empty!';
			return $ret;
		}
		
		if(empty( $path )) {
			$ret['code'] = COS_ERROR_REQUIRED_PARAMETER_INVALID;
			$ret['msg'] = 'Invalid path param!';
			return $ret;
		}
		
		if(empty($opt)) {
			$ret['code'] = COS_ERROR_REQUIRED_PARAMETER_EMPTY;
			$ret['msg'] = 'Empty params! Nothing to be set!';
			return $ret;
		}
		
		$script_name = '/api/cos_set_meta';
		$params = array(
			'bucketId' => $bucketId,
			'path'     => $path,
		);
		
		if(isset($opt['expires'])){
			$params["expires"] = $opt['expires'];
		}
		if(isset($opt['cacheControl'])){
			$params["cacheControl"] = $opt['cacheControl'];
		}
		if(isset($opt['contentEncoding'])){
			$params["contentEncoding"] = $opt['contentEncoding'];
		}
		if(isset($opt['contentLanguage'])){
			$params["contentLanguage"] = $opt['contentLanguage'];
		}
		if(isset($opt['contentDisposition'])){
			$params["contentDisposition"] = $opt['contentDisposition'];
		}

		return self::api($script_name , $params , 'PUT');
	}
	
	/**
	 * 上传本地文件
	 *
	 * @param string $bucketId  桶Id, 长度<=64、字符（123456789 and A~Z and a~z  and _  - .）
	 * @param string $path      文件将要存放的目录路径，以"/" 开头
	 * @param string $cosFile   存储到COS之后的文件名
	 * @param string $localFile 本地文件路径
	 * @return array            结果数组
	 */
	public static function upload_file_by_file($bucketId, $path, $cosFile, $localFile) {
		$ret = array (
			'code'=>0,
			'msg'=>'ok',
		);

		if(empty($bucketId)) {
			$ret['code'] = COS_ERROR_REQUIRED_PARAMETER_EMPTY;
			$ret['msg'] = 'bucketId is empty.';
			return $ret;
		}

		if(empty($localFile)) {
			$ret['code'] = COS_ERROR_REQUIRED_PARAMETER_EMPTY;
			$ret['msg'] = 'localFile is empty.';
			return $ret;
		}
		
		if(empty($cosFile)) {
			$ret['code'] = COS_ERROR_REQUIRED_PARAMETER_EMPTY;
			$ret['msg'] = 'cosFile is empty.';
			return $ret;
		}
		
		if(empty( $path )) {
			$ret['code'] = COS_ERROR_REQUIRED_PARAMETER_EMPTY;
			$ret['msg'] = 'Empty path param!';
			return $ret;
		}
		
		if($path[0] != "/") {
			$path = "/".$path;
		}

		$script_name = '/api/cos_upload';
		$params = array(
			'bucketId' => $bucketId,
			'path' => $path,
			'cosFile'=>$cosFile,
		);

		$post_param = array(
			'cosFile'=>'@'.$localFile,
		);

		return self::api($script_name, $params, 'POST', 'http', true, $post_param);
 	}
	
/**
	 * 直接上传文件内容
	 *
	 * @param string $bucketId 桶Id, 长度<=64、字符（123456789 and A~Z and a~z  and _  - .）
	 * @param string $path     文件将要存放的目录，以 "/" 开头
	 * @param string $filename 存储到COS之后的文件名
	 * @param string $content  文件内容
	 * @return array           结果数组
	 */
	public static function upload_file_by_content( $bucketId, $path, $filename, $content) {
		$ret = array (
			'code'=>0,
			'msg'=>'ok',
		);

		if(empty($bucketId)) {
			$ret['code'] = COS_ERROR_REQUIRED_PARAMETER_EMPTY;
			$ret['msg'] = 'bucketId is empty.';
			return $ret;
		}
		if(empty($filename)) {
			$ret['code'] = COS_ERROR_REQUIRED_PARAMETER_EMPTY;
			$ret['msg'] = 'filename is empty.';
			return $ret;
		}
		
		if(!is_string($content)) {
			$ret['code'] = COS_ERROR_REQUIRED_PARAMETER_INVALID;
			$ret['msg'] = 'bad content body.';
			return $ret;
		}
		
		if(empty($path)) {
			$ret['code'] = COS_ERROR_REQUIRED_PARAMETER_EMPTY;
			$ret['msg'] = 'Empty path param!';
			return $ret;
		}
		
		if($path[0] != "/") {
			$path = "/".$path;
		}

		$script_name = '/api/cos_upload';
		$params = array(
			'bucketId' => $bucketId,
			'path' => $path,
			'cosFile' => $filename,
		);

		return self::api($script_name, $params, 'POST', 'http', true, $content);
	}
 	
	/**
	 * 删除文件
	 *
	 * @param string $bucketId  桶Id, 长度<=64、字符（123456789 and A~Z and a~z  and _  - .）
	 * @param string $path      需要删除文件的目录路径，以 "/" 开头
	 * @param array  $file_list 需要删除的文件列表
	 * @return array 结果数组
	 */
	public static function delete_file($bucketId, $path, $file_list)
	{
		$ret = array (
			'code'=>0,
			'msg'=>'ok',
		);
		
		if(empty($bucketId)) {
			$ret['code'] = COS_ERROR_REQUIRED_PARAMETER_EMPTY;
			$ret['msg'] = 'BucketId is empty!';
			return $ret;
		}
		
		if(empty($path)) {
			$ret['code'] = COS_ERROR_REQUIRED_PARAMETER_EMPTY;
			$ret['msg'] = 'Empty path param!';
			return $ret;
		}
		
		if($path[0] != "/") {
			$path = "/".$path;
		}
		
		if(!is_array($file_list) || empty($file_list)) {
			$ret['code'] = COS_ERROR_REQUIRED_PARAMETER_INVALID;
			$ret['msg'] = 'Illegal file list!';
			return $ret;
		}
		
		$script_name = '/api/cos_delete_file';
		$params = array(
			'bucketId' => $bucketId,
			'deleteObj' => join($file_list,'|'),
			'path'	    =>	$path,
		);

		return self::api($script_name , $params , 'DELETE');
	}
	
	/**
	 * 获取文件列表
	 *
	 * @param string $bucketId 桶Id, 长度<=64、字符（123456789 and A~Z and a~z  and _  - .）
	 * @param string $path     目录路径， 以 "/" 开头
 	 * @param int    $offset   起始地址（可选，默认为 0）
 	 * @param int    $count    获取数量（可选，取值范围为0到100，默认值为 20）
	 * @param int    $prefix   按照该名字前缀拉取file（可选，默认为空）
	 * @return array           结果数组
	 */
	public static function get_file_list($bucketId, $path, $offset=0, $count=20, $prefix="")  {
		$ret = array (
			'code'=>0,
			'msg'=>'ok',
		);
		
		if(empty($bucketId)) {
			$ret['code'] = COS_ERROR_REQUIRED_PARAMETER_EMPTY;
			$ret['msg'] = 'BucketId is empty!';
			return $ret;
		}
		
		if(empty($path)) {
			$ret['code'] = COS_ERROR_REQUIRED_PARAMETER_EMPTY;
			$ret['msg'] = 'Empty path param!';
			return $ret;
		}
		
		if($path[0] != "/") {
			$path = "/".$path;
		}
		
		if($offset < 0) {
			$ret['code'] = -1;
			$ret['msg'] = 'Illegal offset!';
			return $ret;
		}
		
		if($count < 0 || $count > 100) {
			$ret['code'] = -1;
			$ret['msg'] = 'Illegal count!';
			return $ret;
		}
		
		$script_name = '/api/cos_list_file';
		$params = array(
			'bucketId' => $bucketId,
			'path' => $path,
			'offset' => $offset,
			'count' => $count,
		);
		
		if(strlen($prefix) > 0) {
			$params['prefix'] = $prefix;
		}
		
		return self::api($script_name , $params , 'GET');
	}
	
	/**
	 * 删除目录（递归删除,目录不为空也可以删除）
	 *
	 * @param string $bucketId 桶Id, 长度<=64、字符（123456789 and A~Z and a~z  and _  - .）
	 * @param string $path 待删除的目录路径，以 "/" 开头
	 * @return array 结果数组
	 */
	public static function delete_dir($bucketId, $path) {
		
		$ret = array (
			'code'=>0,
			'msg'=>'ok',
		);
		
		if(empty($bucketId)) {
			$ret['code'] = COS_ERROR_REQUIRED_PARAMETER_EMPTY;
			$ret['msg'] = 'BucketId is empty!';
			return $ret;
		}
		
		if(empty($path)) {
			$ret['code'] = COS_ERROR_REQUIRED_PARAMETER_EMPTY;
			$ret['msg'] = 'Empty path param!';
			return $ret;
		}
		
		$allFiles = self::get_file_list($bucketId, $path);
	
		$fileLists = array();
		$dirs = array();
		if ($allFiles['data']['files']) {
			foreach($allFiles['data']['files'] as $key => $val) {
				if ($val['type'] == 1) {
					$fileLists[] = $val['name'];
				} else if($val['type'] == 2) {
					$dirs[] = $val['name'];
				} 		
				
			}
		}
		
		
		if ($fileLists) {
			$delFile = self::delete_file($bucketId, $path, $fileLists);
		}
		
		if ($dirs) {
			foreach ($dirs as $key => $val) {
				$delDirs = self::delete_dir($bucketId, $path . '/' .$val);
			}
		}

		if($path[0] != "/") {
			$path = "/".$path;
		}
		
		$script_name = '/api/cos_rmdir';
		$params = array(
			'bucketId' => $bucketId,
			'path'	   => $path,
		);

		return self::api($script_name, $params, 'DELETE');
	}
	
	/**
	 * 删除 bucket
	 *
	 * @param string $bucketId 桶Id, 长度<=64、字符（123456789 and A~Z and a~z  and _  - .）
	 * @return array 结果数组
	 */
	public static function delete_bucket($bucketId) {
		$ret = array (
			'code'=>0,
			'msg'=>'ok',
		);
	
		if(empty($bucketId)) {
			$ret['code'] = COS_ERROR_REQUIRED_PARAMETER_EMPTY;
			$ret['msg'] = 'BucketId is empty!';
			return $ret;
		}

		$dirLists = MooCos::get_file_list($bucketId, "/");
		
		$dirs = array();
		if ($dirLists['data']['files']) {
			foreach ($dirLists['data']['files'] as $key => $val) {
				$dirs[] = $val['name'];
			}
		}
		
		if ($dirs) {
			foreach ($dirs as $key => $val) {
				 $rs = self::delete_dir($bucketId, "/".$val);
				if ($rs['code'] != 0) {
					return $rs;
				}
			}
		}

		$script_name = '/api/cos_delete_bucket';
		$params = array(
			'bucketId' => $bucketId,
		);
	
		return self::api($script_name, $params, 'DELETE');
	}
	
/**
	 * 获取下载链接
	 * 
	 * @param string 桶Id, 长度<=64、字符（123456789 and A~Z and a~z  and _  - .）
	 * @param string $path 文件的路径
	 * @param bool   $need_sig 是否需要签名，如果为公有读则建议设置为false，如果为私有读则一定设置为true
	 * @param array $option=array(
	 *				"res_cache_control"=>"",
	 *				"res_content_disposition"=>"",
	 *				"res_content_type"	=>	"",
	 *				"res_encoding"		=>"",
	 *				"res_expires"		=>"",
	 *				"res_content_language"=>"",
	 *			)
	 *
	 * @return string;
	 */
	public static function get_download_url($bucketId, $path, $need_sig, $option=array()) {
		$ret = array (
			'code'=>0,
			'msg'=>'ok',
		);
		
		if(empty($bucketId)) {
			$ret['code'] = COS_ERROR_REQUIRED_PARAMETER_EMPTY;
			$ret['msg'] = 'BucketId is empty!';
			return $ret;
		}
		
		if(empty($path)) {
			$ret['code'] = COS_ERROR_REQUIRED_PARAMETER_INVALID;
			$ret['msg'] = 'Invalid path param!';
			return $ret;
		}
		
		$filter =array(
			"res_cache_control"=>1,
			"res_content_disposition"=>1,
			"res_content_type"	=>	1,
			"res_encoding"		=>1,
			"res_expires"		=>1,
			"res_content_language"=>1,
		);
		
		foreach($option as $key=> $item){
			if(!isset($filter[$key])){
				unset($option[$key]);
			}
		}
		
		if(strlen($path)>0 && $path[0]!="/"){
			$path = "/".$path;
		}
		
		self::initializeDown();
		
		if ($need_sig) {
			$url = COS_DOWNLOAD_HOST.'/'.self::$accessId.'/'.$bucketId.$path.'?';
		} else {
			$url = COS_DOWNLOAD_HOST.'/'.self::$accessId.'/'.$bucketId.$path;
		}
		
		if($need_sig)
		{
			$option['accessId'] = self::$accessId;
			$option['path'] = $path;
			$option['bucketId'] = $bucketId;
			if(!empty(self::$secretId)){
				$option['secretId']=self::$secretId;
			}
		    $option['time'] = time();
			$option['sign'] =  MooCosUtil::getDownloadSign($option, self::$accessKey);
			unset($option['accessId']);
			unset($option['path']);
			unset($option['bucketId']);
		}
		$query_string = array();
		foreach ($option as $key => $val ) 
		{ 
			array_push($query_string, rawurlencode($key) . '=' . rawurlencode($val));
		}  
		$query_string = join('&', $query_string);
		return $url.$query_string;
	}
	
	/**
	 * 执行API调用，返回结果数组
	 *
	 * @param array $script_name 调用的API方法 参考
	 * @param array $params 调用API时带的参数
	 * @param string $method 请求方法 post / get / put / delete / head
	 * @param string $protocol 协议类型 http / https
	 * @return array 结果数组
	 */
	
	private static function api($script_name, $params, $method='post', $protocol='http' ,$upload=false, $content='') {
		
		// 初始化  cos accessId accessKey 判断是否开启
		if(!self::initialize()) {
			// 未开启
			$ret['code'] = COS_ERROR_REQUIRED_NOT_OPEN;
			$ret['msg'] = 'Cos_file_system not open API!';
			return $ret;
		}
		 		
		if(empty(self::$accessId) || empty(self::$accessKey)) {
			$ret['code'] = COS_ERROR_REQUIRED_PARAMETER_EMPTY;
			$ret['msg'] = 'Empty accessId or accessKey!';
			return $ret;
		}
		
		// 无需传sign, 会自动生成
		unset($params['sign']);
		
		// 添加一些参数
		if(!empty(self::$secretId )){
			$params['secretId'] = self::$secretId;
		}
		
		$params['accessId'] = self::$accessId;
		
		//记录接口调用开始时间
		$params['time'] = time();

		// 生成签名
		$secret = self::$accessKey;

		$sign = MooCosUtil::makeCosSig('', $script_name, $params, $secret);
		
		$params['sign'] = $sign;
	
		$url = $protocol . '://' . self::$host . $script_name;
		
		$cookie = array();
      
		// 发起请求
		if($upload) {
			$ret = MooCosUtil::makeUploadRequest($url, $params, $cookie, $content, $protocol);
		} else {
			$ret = MooCosUtil::makeRequest($url, $params, $cookie, $method, $protocol);
		}
		
		if (false === $ret['result']){
			$result_array = array(
				'code' => COS_ERROR_CURL + $ret['errno'],
				'msg' => $ret['msg'],
			);
		}
		$result_array = json_decode($ret['msg'], true);
		
		// 远程返回的不是 json 格式, 说明返回包有问题
		if (is_null($result_array)) {
			$result_array = array(
				'code' => COS_ERROR_RESPONSE_DATA_INVALID,
				'msg' => $ret['msg']
			);
		}
		
		return $result_array;
	}
}