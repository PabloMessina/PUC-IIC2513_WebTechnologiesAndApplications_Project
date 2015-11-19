
// otros...

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
