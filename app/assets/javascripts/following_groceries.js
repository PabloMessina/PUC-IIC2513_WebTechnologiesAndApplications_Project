$(function() {
	$(".stop-following-button").on('click',function(){

		var $btn = $(this);
		var grocery_id = $btn.data('grocery-id');
		$btn.hide();
		var $rc = $(".following-grocery-container#"+grocery_id+" .removing-container");
		$rc.show();

		$.post(Routes.grocery_unfollow_path(grocery_id),null,null,'json')
		.done(function() {
			$(".following-grocery-container#"+grocery_id).remove();
			refreshGroceriesCount();
			refreshRowsSeparators();
		})
		.fail(function(){
			$rc.hide();
			$btn.show();
			alert("Error from server while trying to unfollow grocery");
		});	

	});
});

function refreshGroceriesCount() {
	var $title = $("#following-groceries-title");
	var count = $(".following-grocery-container").size();
	$title.html("Following Groceries ("+count+")");
}

function refreshRowsSeparators() {
	$(".floats-separator").remove();
	$(".following-grocery-container").each(function(index) {
		if(index > 0 && (index+1) % 5 == 0) {
			$(this).after('<div style="clear:both;width:100%;height:5px;"></div>');
		}
	});
}