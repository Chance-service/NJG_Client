<?php
require_once dirname(__FILE__) . '/config.inc.php';
require_once dirname(__FILE__) . '/lib.interface.php';

class MooXml {
	private function _getChildren($vals, &$i) {
		$children = array();
		if (isset($vals[$i]['value'])) {
			$children['VALUE'] = $vals[$i]['value'];
		}
		
		while (++$i < count($vals)) {
			switch ($vals[$i]['type']) {
				
				case 'cdata' :
					if (isset($children['VALUE'])) {
						$children['VALUE'] .= $vals[$i]['value'];
					} else {
						$children['VALUE'] = $vals[$i]['value'];
					}
					break;
				
				case 'complete' :
					if (isset($vals[$i]['attributes'])) {
						$children[$vals[$i]['tag']][]['ATTRIBUTES'] = $vals[$i]['attributes'];
						$index = count($children[$vals[$i]['tag']]) - 1;
						
						if (isset($vals[$i]['value'])) {
							$children[$vals[$i]['tag']][$index]['VALUE'] = $vals[$i]['value'];
						} else {
							$children[$vals[$i]['tag']][$index]['VALUE'] = '';
						}
					} else {
						if (isset($vals[$i]['value'])) {
							$children[$vals[$i]['tag']][]['VALUE'] = $vals[$i]['value'];
						} else {
							$children[$vals[$i]['tag']][]['VALUE'] = '';
						}
					}
					break;
				
				case 'open' :
					if (isset($vals[$i]['attributes'])) {
						$children[$vals[$i]['tag']][]['ATTRIBUTES'] = $vals[$i]['attributes'];
						$index = count($children[$vals[$i]['tag']]) - 1;
						$children[$vals[$i]['tag']][$index] = array_merge($children[$vals[$i]['tag']][$index], self::_getChildren($vals, $i));
					} else {
						$children[$vals[$i]['tag']][] = self::_getChildren($vals, $i);
					}
					break;
				
				case 'close' :
					return $children;
			}
		}
	}
	
	/**
	 * 执行解析
	 *
	 * @param array $data
	 * @return array
	 */
	public function getXMLTree($data) {
		$data = iconv('utf-8', 'utf-8//IGNORE', $data);
		$index = $vals = null;
		// 过滤掉xml中的特殊字符
		$data = StringUtil::escape($data);
		
		$parser = xml_parser_create('utf-8');
		xml_parser_set_option($parser, XML_OPTION_SKIP_WHITE, 1);
		xml_parser_set_option($parser, XML_OPTION_CASE_FOLDING, 0);
		xml_parse_into_struct($parser, $data, $vals, $index);
		xml_parser_free($parser);
		
		$tree = array();
		$i = 0;
		
		if (isset($vals[$i]['attributes'])) {
			$tree[$vals[$i]['tag']][]['ATTRIBUTES'] = $vals[$i]['attributes'];
			$index = count($tree[$vals[$i]['tag']]) - 1;
			$tree[$vals[$i]['tag']][$index] = array_merge($tree[$vals[$i]['tag']][$index], (array)self::_getChildren($vals, $i));
		} else {
			$tree[$vals[$i]['tag']][] = self::_getChildren($vals, $i);
		}
		return $tree;
	}
}