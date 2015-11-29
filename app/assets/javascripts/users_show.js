var reports_data = {};
var MAX_LENGTH = 20;

$(document).ready(function() {

  //set function to load more feeds
  $("#more_feed_button").on('click', function() {
    var last_id = getLastReportId();
    var data = (last_id == undefined) ? null : "last_id="+last_id;
    var btn = $(this);
    var url = btn.data("url");
    $.get(url, data, null, 'script');
    btn.html("Loading more news ...");
    btn.prop('disabled',true);        
  });

  //add show more/less links to reports that are too large
  addShowMoreLessToAllReports();

});

function getLastReportId() {
  return $('.report-container:last').attr('id');
}

function addShowMoreLessToAllReports() {
  $('.report-container').each(function() {
    var id = $(this).attr('id');
    var txt_container = $(this).find('.text-container');
    var content = txt_container.html();

    if(content.length > MAX_LENGTH) {
      var less_content = content.substring(0,MAX_LENGTH) +"...<a href='javascript:void(0)' onclick='showMore("+id+")'>show more</a>";
      var more_content = content+" <a href='javascript:void(0)' onclick='showLess("+id+")'>show less</a>";
      reports_data[id] = {more: more_content, less: less_content};
      txt_container.html(less_content);
    }
  });
}

function addShowMoreLessToReport(id) {

  var container = $('#'+id+'.report-container');
  var txt_container = container.find('.text-container');
  var content = txt_container.html();

  if(content.length > MAX_LENGTH) {
    var less_content = content.substring(0,MAX_LENGTH) +"...<a href='javascript:void(0)' onclick='showMore("+id+")'>show more</a>";
    var more_content = content+" <a href='javascript:void(0)' onclick='showLess("+id+")'>show less</a>";
    reports_data[id] = {more: more_content, less: less_content};
    txt_container.html(less_content);
  }
}

function showMore(id) {
  $('#'+id+'.report-container .text-container').html(reports_data[id].more);
}

function showLess(id) {
  $('#'+id+'.report-container .text-container').html(reports_data[id].less);
}

function refreshNewsCount() {
  var news_count = $(".report-container").size();
  $("#news_title").html("News feed ("+news_count+")");
}