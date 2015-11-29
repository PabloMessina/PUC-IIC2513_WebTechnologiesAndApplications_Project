// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

function togglePasswordDiv(checkbox) {
	if(checkbox.checked) {
		$("#password_div").removeClass("hide-element");
		$("#password_div").addClass("size-of-content");
	} else {
		$("#password_div").removeClass("size-of-content");
		$("#password_div").addClass("hide-element");
	}
}

var users_ready = function() {
	
  $("#advanced_button").on('click', function() {
    $("#advanced_fields#categories").val('').trigger('change');
    $("#advanced_fields#tags").val('').trigger('change');
    $("#advanced_fields").toggleClass('hide-element');
    var btn = $("#advanced_button");
    var content = btn.html();
    if(content == "Show advanced fields") {
      btn.html("Hide advanced fields");
    } else {
      btn.html("Show advanced fields");
    }
  });
};


function follow_id(set_to) {
  return "#" + (set_to ? "" : "un") + "follow";
}

function follow(set_to) {
  $("button"+follow_id(set_to)).prop('disabled', true);

  $.post("/groceries/"+grocery_id+"/follow", { to: set_to })
    .done(function() {
      $("div"+follow_id(set_to)).addClass("hidden");
      $("button"+follow_id(!set_to)).prop('disabled', false);
      $("div"+follow_id(!set_to)).removeClass("hidden");
    });
}


$(document).ready(grocery_ready);
$(document).on('page:load', grocery_ready);

function refreshProductsPagination() {
  $('#grocery_products_pagination .pagination a').click(function () {
      $('#grocery_products_pagination .pagination').html('Loading products...');
      $.get(this.href, null, null, 'script');
      return false;
  });
}


