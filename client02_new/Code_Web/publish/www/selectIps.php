<?php
require_once 'common.php';

$dao = MooDao::get('Server');
$serverAll = $dao->getAll('select * from @TABLE where s_game_id = :s_game_id order by s_platforms asc', array('s_game_id' => 2));


echo "<pre>";
print_r($serverAll);
echo "</pre>";
$rs = null;
foreach ($serverAll as $key => $val) {
	$res = $val['s_tag'] . "	" . $val['s_ip'] . "	" . $val['s_port'] . "	  " . $val['s_user'] . "    " . $val['s_online_dir'];
	if($rs == null) {
		$rs = $res;
	} else {
		$rs = $rs . "\n" . $res;
	}
}

MooFile::write('ipLists.txt', $rs);

?>
