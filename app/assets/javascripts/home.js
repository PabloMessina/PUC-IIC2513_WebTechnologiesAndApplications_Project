function toggleSearchContainer(btn) {	
	$('#radios_div').toggleClass('hide-element');
	$('#search_fields_div').toggleClass('hide-element');
	if(btn.innerHTML == 'Show search box')
		btn.innerHTML = 'Hide search box';
	else
		btn.innerHTML = 'Show search box';
}

function showGroceriesSearchDiv() {
	var gsd = $('#groceries_search_div');
	var psd = $('#products_search_div');
	gsd.removeClass('hide-element');
	psd.addClass('hide-element');
}

function showProductsSearchDiv() {
	var gsd = $('#groceries_search_div');
	var psd = $('#products_search_div');
	gsd.addClass('hide-element');
	psd.removeClass('hide-element');
}

$(document).ready(function() {  
  $(".awesome-select").select2({
    width: "300px",
    placeholder: "No filter"
  });

  $('.pagination a').click(function () {  
    $('.pagination').html('Loading groceries...');  	        
    $.get(this.href, null, null, 'script');
    return false;  

	});

});  