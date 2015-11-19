$(document).ready(function() {
  $(".awesome-select").select2({
    width: "100%",
    placeholder: "No filter"
  });

  $("#advanced_button").on('click', function() {
    $("#advanced_fields #categories").val('').trigger('change');
    $("#advanced_fields #tags").val('').trigger('change');
    $("#advanced_fields").toggleClass('hide-element');
    var btn = $("#advanced_button");
    var content = btn.html();
    if(content == "Show advanced fields") {
      btn.html("Hide advanced fields");
    } else {
      btn.html("Show advanced fields");
    }
  });

});