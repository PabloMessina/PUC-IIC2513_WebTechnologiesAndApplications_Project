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