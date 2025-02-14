<?php
/**
 * Smarty plugin
 * @package Smarty
 * @subpackage plugins
 */

/**
 * 使用方法
 * <%assign var="test" value="a{b}c"%>
 * <%batch_replace var=$test b="d"%>
 */

/**
 * Smarty {batch_replace} function plugin
 *
 * Type:     function<br>
 * Name:     batch_replace<br>
 * Purpose:  批量替换 <br>
 * @author 郭瑞超
 * @param array
 * @param Smarty
 */
function smarty_function_batch_replace($params, &$smarty){
	
	if (!isset($params['var'])) {
        $smarty->trigger_error("eval: missing 'var' parameter");
        return;
    }
	
	$string = $params['var'];
	foreach($params as $key => $val){
		if($key == 'var'){
			continue;
		}
		$string = str_replace('{'.$key.'}',$val,$string);
	}
	
	return $string;
}

?>
