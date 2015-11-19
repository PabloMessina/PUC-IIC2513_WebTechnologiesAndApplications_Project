
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
