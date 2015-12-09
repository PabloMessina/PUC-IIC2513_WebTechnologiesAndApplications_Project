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
