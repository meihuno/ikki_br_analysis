$("td#sample").on({
    'mouseenter':function(ev){
	var top = $(this).position().top;
	var left = $(this).position().left;
	top = Math.floor(top); // Fx対策：整数にする
	left = Math.floor(left); // Fx対策：整数にする
	var text = $(this).attr('data-text');
	$("body").append('<div id="sample4-tooltips-'+top+'-'+left+'" class="sample4-tooltips">'+text+'</div>');
	var obj = $("#sample4-tooltips-"+top+"-"+left);
	var x = ev.pageX;
	var y = ev.pageY;
	obj.css({top: y + 34, left: x + 14}); // ← 表示する位置を適当に調整
    },
    'mousemove':function(ev){
	var top = $(this).position().top;
	var left = $(this).position().left;
	top = Math.floor(top); // Fx対策：整数にする
	left = Math.floor(left); // Fx対策：整数にする
	var obj = $("#sample4-tooltips-"+top+"-"+left);
	var x = ev.pageX;
	var y = ev.pageY;
	obj.css({top: y + 34, left: x + 14});
    },
    'mouseleave':function(){
	var top = $(this).position().top;
	var left = $(this).position().left;
	top = Math.floor(top); // Fx対策：整数にする
	left = Math.floor(left); // Fx対策：整数にする
	$("#sample4-tooltips-"+top+"-"+left).remove();
    }
});
