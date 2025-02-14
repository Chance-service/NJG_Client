<?php
/**
 * 自定义异常处理
 *
 * @param string $msg 错误信息
 * @param string $type 异常类型 默认为Exceptions
 * 如果指定的异常类不存在，则直接输出错误信息
 * @return void
 * @version 1.0
 */

function throwException($msg, $type = 'Exceptions', $code=0)
{
    if(class_exists($type,FALSE)){
        throw new $type($msg, $code, TRUE);
    }else {
        // 异常类型不存在则输出错误信息字串
        exit($msg);
    }
}
class Socket
{

    private static $_connection;


    function __construct ($server, $port, $timeout = 10, $p = TRUE)
    {
        $this->connect($server, $port, $timeout, $p);
    }


    function __destruct ()
    {
    }

    /**
     * 连接
     * @param unknown_type $server
     * @param unknown_type $port
     * @param unknown_type $timeout
     * @param unknown_type $p
     */
    public function connect($server, $port, $timeout = 10, $p = false)
    {
        if ($p) {
            $this->_connection = @pfsockopen($server,$port, $this->errorNo, $errorMessage, $timeout);
        }else {
            $this->_connection = @fsockopen($server,$port, $this->errorNo, $errorMessage, $timeout);
        }

        if (!$this->_connection) {
            throwException(sprintf('%s, %s', $this->errorNo, $errorMessage));
        }
    }

    /**
     * 关闭
     */
    public function disconnect()
    {
        if ($this->_connection) {
            @fclose($this->_connection);
            $this->_connection = null;
            return TRUE;
        }
        return FALSE;
    }

    /**
     * 读取
     * @param int $length
     */
    public function read($length)
    {
        if ($this->_connection === false) {
            throwException('socket not connected');
        }

        if (@feof($this->_connection))
        {
            throwException('socket read eof error');
        }

        $ret = '';
        $read = 0;

        while ($read < $length && ($buf = fread($this->_connection, $length - $read))) {
            $read += strlen($buf);
            $ret .= $buf;
        }
        if ($ret === false) {
            throwException('socket read error');
        }
        return $ret;

    }

    /**
     * 写入
     * @param string $data
     */
    public function write($data)
    {
        $total = 0;
        $len = strlen($data);

        while ($total < $len && ($written = fwrite($this->_connection, $data))) {
            $total += $written;
            $buf = substr($data, $written);
        }
        return $total;
    }

    public function readInt4()
    {
        $result = '';
        $res = $this->read(4);
        $res = unpack('L', $res);
        return $res[1];
    }

}

class MySocket extends Socket
{
	const SERVER = 'passport_i.25pp.com';
    const PORT = 8080;

	private static $_instance;
	
	private static $_types = array('username' => 'a*',
                      			   'password' => 'a32',
								   'token_key' => 'a32',
                            );

    function __construct ()
    {
        parent::__construct(self::SERVER, self::PORT, 5, false);
    }


    function __destruct ()
    {
    }

    public static function instance()
    {
        if (self::$_instance == null) {
            self::$_instance = new self;
        }
        return self::$_instance;
    }

    private function _read($format = FALSE)
    {
        $body_len = parent::readInt4();
        $body_string =  parent::read($body_len-4);
        $head_string = substr($body_string, 0, 8);

        list(, $cmd, $status) = unpack("L*", $head_string);

        $body = FALSE;
        if ($status == 0) {
            if (!$format) {
                $body = substr($body_string, 8, $body_len);
            }else {
                $body = unpack($format, substr($body_string, 8, $body_len));
            }
        }
        return array('cmd' => $cmd, 'status' => $status, 'body' => $body);
    }
	
	private function _pack($cmd, $string)
    {
        $tmp = array();
        $len = 8;
        $tmp[0] = $len;
        $tmp[1] = pack("L", $cmd);
        foreach ($string as $key => $value) {
            $tmp_pack = pack(self::$_types[$key], $value);
            $len += strlen($tmp_pack);
            $tmp[] = $tmp_pack;
        }
        $tmp[0] = pack("L", $len);
        return join("", $tmp);

    }

    public function login_check($cmd,$body)
    {
        $tmp[0] = pack("L", 8 + strlen($body));
        $tmp[1] = pack("L", $cmd);
        $tmp[2] = $body;
        parent::write(join("", $tmp));

        /*$body_len = parent::readInt4();
        $body_string =  parent::read($body_len-4);
        $body = unpack("Lcmd/Lstatus/a*username", $body_string);
		$username = '';
		if ( $body['status'] == 0 ){
			$place = stripos( $body['username'], "\0");
			$username = substr($body['username'], 0, $place);
		}else{
			$body['username'] = '';
		}
		return $body;*/

		$body_format = "a*";
        $body_format = FALSE;
        $rs = $this->_read($body_format);

		if ( $rs['status'] == 0 ){
			$place = stripos( $rs['body'], "\0");
			$username = substr($rs['body'], 0, $place);

			list(, $lo0, $lo1, $hi0, $hi1) = unpack('v*', substr($rs['body'], $place+1));
            $uid =  ($hi1 << 16 | $hi0) << 32 | ($lo1 << 16 | $lo0);
			$rs['body'] = array('username' => $username, 'uid' => $uid);
		}
		return $rs;
    }
	
	/**
	 * 通过CURL模拟POST提交数据。
	 *
	 * @param $token_key
	 * @return string
	 */		
    public function postCurl($token_key)
	{
	   $url = 'http://passport_i.25pp.com:8080/index?tunnel-command=2852126756';
       $data = $token_key;
       $ch = curl_init();
       curl_setopt($ch, CURLOPT_URL,$url);
       curl_setopt($ch, CURLOPT_HEADER, 0);
       curl_setopt($ch, CURLOPT_POST, 1);
       curl_setopt($ch, CURLOPT_POSTFIELDS, $data);
       curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
       curl_setopt($ch, CURLOPT_HTTPHEADER,array('Host: passport_i.25pp.com', 'Content-Length: '.strlen($token_key).'\''));
       $result = curl_exec ($ch);
       curl_close($ch);
	   return '{'.$result.'}';
	}
	
}
