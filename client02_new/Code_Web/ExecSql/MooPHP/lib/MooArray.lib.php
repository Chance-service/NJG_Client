<?php
require_once dirname(__FILE__) . '/config.inc.php';
require_once dirname(__FILE__) . '/lib.interface.php';

class MooArray {
	/**
	 * 无限分类
	 *
	 * @param string $layer
	 * @param string $label_colum
	 * @return array
	 */
	static function getLayer($layer, $idFiled, $label_colum = 'label') {
		$new_layer = array();

		if (!is_array($layer) || !is_array(current($layer)) || !array_key_exists($label_colum, current($layer))) {
			return array();
		}
		foreach ($layer as $row) {
			$row_str = '';
			foreach ($row as $key => $value) {
				$row_str .= ",'$key' => '$value'";
			}
			$row_str = "array(" . substr($row_str, 1) . ')';

			$label_arr = explode('-', $row[$label_colum]);
			unset($label_arr[0]);
			$label_arr[] = $row[$idFiled];
			$layer_str = '$new_layer';
			foreach ($label_arr as $label) {
				$layer_str .= "['child']['$label']";
			}
			eval("$layer_str=$row_str;");
		}
		return array_values($new_layer['child']);
	}

	/**
	 * 重新设置数组索引
	 *
	 * @param array $arr
	 * @param string $field
	 * @return array
	 */
	static function resetIndex(&$arr, $field) {
		if (!is_array($arr)) {
			return array();
		}
		foreach ($arr as $row) {
			$tmp[$row[$field]] = $row;
		}
		$arr = $tmp;
		return $arr;
	}

	/**
	 * 二维数组排序(td是two-dimension的意思)
	 *
	 * @param array $arr
	 * @param string $fieldA
	 * @param string $sortA
	 * @param string $fieldB
	 * @param string $sortB
	 * @param string $fieldC
	 * @param string $sortC
	 */
	static function tdSort(&$arr, $fieldA, $sortA = SORT_ASC, $fieldB = '', $sortB = SORT_ASC, $fieldC = '', $sortC = SORT_ASC) {
		if (!is_array($arr) || count($arr) < 1) {
			return false;
		}
		$arrTmp = array();
		foreach ($arr as $rs) {
			foreach ($rs as $key => $value) {
				$arrTmp["{$key}"][] = $value;
			}
		}
		if (empty($fieldB)) {
			if (!$arrTmp[$fieldA]) {
				return false;
			}
			array_multisort($arrTmp[$fieldA], $sortA, $arr);
		} elseif (empty($fieldC)) {
			if (!$arrTmp[$fieldA] || !$arrTmp[$fieldB]) {
				return false;
			}
			array_multisort($arrTmp[$fieldA], $sortA, $arrTmp[$fieldB], $sortB, $arr);
		} else {
			if (!$arrTmp[$fieldA] || !$arrTmp[$fieldB] || !$arrTmp[$fieldC]) {
				return false;
			}
			array_multisort($arrTmp[$fieldA], $sortA, $arrTmp[$fieldB], $sortB, $arrTmp[$fieldC], $sortC, $arr);
		}
		return true;
	}

	/**
	 * 获取数组中的某一列
	 *
	 * @param array $array
	 * @param string $field
	 * @return array
	 */
	static function getCol($array, $field) {
		if (!is_array($array) || count($array) < 1) {
			return array();
		}
		$temp = array();
		foreach ($array as $key => $value) {
			if (array_key_exists($field, $value)) {
				$temp[] = $value[$field];
			}
		}
		return $temp;
	}

	/**
	 * 把对象转换为数组
	 * @param $obj 对象
	 * @return array
	*/
	static function objToArray($obj) {
		$return= array();
		if (is_array($obj)) {
			$keys = array_keys($obj);
		} elseif (is_object($obj)) {
			$keys = array_keys(get_object_vars($obj));
		} else {
			return $obj;
		}

		foreach ($keys as $key) {
			if (is_array($obj)) {
				$return[$key] = self::objToArray($obj[$key]);
			} else {
				$return[$key] = self::objToArray($obj->$key);
			}
		}
		return $return;
	}
}