// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require turbolinks
//= require_tree ../../../vendor/assets/javascripts/


$(function() {

  $(".awesome-select").select2({
    width: "100%",
    placeholder: "No filter"
  });

  $("#advanced_button_global").click(function() {
    $("#advanced_fields#categories").val('').trigger('change');
    $("#advanced_fields#tags").val('').trigger('change');

    $("#advanced_fields").toggleClass("hidden");

    var btn = $("#advanced_button");
    var content = btn.html();
    if(content == "Show advanced fields") {
      btn.html("Hide advanced fields");
    } else {
      btn.html("Show advanced fields");
    }
  });

});

function groceriesSearchSelected() {
	$("#search_form").attr("action", "/search_groceries");
  $("#search_button").val("Search groceries");
}

function productsSearchSelected() {
	$("#search_form").attr("action", "/search_products");
  $("#search_button").val("Search products");
}
