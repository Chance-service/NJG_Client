<?php
/**
 * More & Original PHP Framwork
 * Copyright (c) 2010 - 2011 IsMole Inc.
 * document 
 * id: format_array_to_string.php Dec 9, 2013 starten
 */

class format_array_to_string_class {
	/**
	 * 格式话数据
	 */
	public function formart($arr) {
		$str = 'array(';
		$str .= $this->dealResponse($arr);
		$str .= "\n);";
		return $str;
	}
	
	// array 页面换行解析
    private function dealResponse($arr, $num = 1) {
        $space = $this->getSpace($num);
        $num += 1;
        if ($arr && is_array($arr)) {
        	$tmIntArr = $this->isIntKeyArray($arr);
            $isInt 	= $tmIntArr['isInt'];
            $conInt = $tmIntArr['conInt'];
            $tm = array();
            foreach ($arr as $k => $v) {
                $tmp = array();
                $tmp[] = $space;
                if (is_array($v)) {
                    $tmpStr = $this->dealResponse($v, $num);
                    if ($isInt) {
                    	if ($conInt) {
                    		if (!$v) {
                    			$tmp[] = "array({$tmpStr})";
                    		} else {
                    			$tmp[] = "array({$tmpStr}\n{$space})";
                    		}
                    	} else {
                    		if (!$v) {
                    			$tmp[] = "{$k} => array({$tmpStr})";
                    		} else {
                    			$tmp[] = "{$k} => array({$tmpStr}\n{$space})";
                    		}
                    	}
                    } else {
                    	if (!$v) {
                			$tmp[] = "'{$k}' => array({$tmpStr})";
                		} else {
                    		$tmp[] = "'{$k}' => array({$tmpStr}\n{$space})";
                    	}
                    }
                } else {
                    if (is_numeric($v)) {
                        if ($isInt) {
                        	if ($conInt) {
                        		$tmp[] = "{$v}";
                        	} else {
                        		$tmp[] = "{$k} => {$v}";
                        	}
                        } else {
                            $tmp[] = "'{$k}' => {$v}";
                        }
                    } else {
                        if ($isInt) {
                        	if ($conInt) {
                        		 $tmp[] = "'{$v}'";
                        	} else {
                        		$tmp[] = "{$k} => '{$v}'";
                        	}
                        } else {
                            $tmp[] = "'{$k}' => '{$v}'";
                        }
                    }
                }
                $tm[] = join("\n" . $space, $tmp);
            }
        }
        if (!$tm) $tm = array();
        return join(',', $tm);
    }
    
    // 增加空格
    private function getSpace($num) {
        $r = '';
        if ($num <= 0) return $r;
        $space = '	';
        for ($i = 0; $i < $num; $i ++) $r .= $space;
        return $r;
    }
    
    // 验证数组
    private function isIntKeyArray($arr) {
    	$isInt 		= true; // 是纯数字键值数组
    	$isConInt 	= true; // 是不连续的纯数字键值数组
    	$num = 0;
        foreach ($arr as $k => $v) {
            if (is_string($k)) {
            	$isInt = false;
            }
            
            if ($num != $k) $isConInt = false;
            $num ++;
        }
		
		$rs = array('isInt' => $isInt, 'conInt' => $isConInt);
        return $rs;
    }
}

/**
 * 
 * @param array $arr 要格式化的数组
 * 
 */
function format_array_to_string_byStarten($arr) {
	static $obj = null;
	if (!$obj) $obj = new format_array_to_string_class();
	return $obj->formart($arr);
}