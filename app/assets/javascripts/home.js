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
