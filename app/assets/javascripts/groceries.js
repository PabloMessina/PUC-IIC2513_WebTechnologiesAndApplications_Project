$(document ).ajaxStop(function() {
  $('#products_pagination .pagination a').click(function () {  
  		$('#products_pagination .pagination').html('Page is loading...');  
      $.get(this.href, null, null, 'script');  
      return false;  
  }); 
});

$(document).ready(function() {  
	$('#products_pagination .pagination a').click(function () {  
		$('#products_pagination .pagination').html('Page is loading...');  
    $.get(this.href, null, null, 'script');  
    return false;  
  }); 
});  