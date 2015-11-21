$(document).ready(function(){
  $('#new_comment_form')
  .on('ajax:success', handleSuccess)
  .on('ajax:error', handleError);    
  refreshCommentsCount();
  addShowMoreLessToAllComments();
});

function refreshCommentsCount() {
	comments_count = $('#comments_div .report-comment-container').size();
	$('#comment-section-title').html("Comments ("+comments_count+")");
}

function commentFormSubmit_clicked() {
	$("#new_comment_form fieldset *").prop('readonly',true);
	$("#new_comment_form [name=commit]").attr('value','Posting comment, please wait ...');
	$("#new_comment_form [name=commit]").prop('disabled',true);
	$("#new_comment_form [name=cancel]").prop('disabled',true);
}

function handleSuccess() {
	$("#new_comment_form fieldset *").prop('readonly',false);
	$("#new_comment_form [name=commit]").attr('value','Post comment');
	$("#new_comment_form [name=commit]").prop('disabled',false);
	$("#new_comment_form [name=cancel]").prop('disabled',false);
	$("#new_comment_form textarea").val('');
}

function handleError(e, xhr, status, error) {

	alert(xhr.responseText);
	console.log(xhr.responseText);

  alert("e = "+e+"\nxhr = "+xhr+"\nstatus = "+status+"\nerror = "+error);
  $("#new_comment_form fieldset *").prop('readonly',false);
	$("#new_comment_form [name=commit]").attr('value','Post comment');
	$("#new_comment_form [name=commit]").prop('disabled',false);
	$("#new_comment_form [name=cancel]").prop('disabled',false);
}

function hideNewCommentForm() {
	$('#add_comment_div').removeClass('hide-element');
	$('#post_comment_div').addClass('hide-element');
}

function showNewCommentForm() {
	$('#add_comment_div').addClass('hide-element');
	$('#post_comment_div').removeClass('hide-element');	
}

function cancelNewComment() {
	hideNewCommentForm();
	$("#new_comment_form textarea").val('');
}

function getLastCommentId() {
	return $('.report-comment-container:last').attr('id');
}

function showMoreComments(btn) {		
	var last_id = getLastCommentId();
	var data = (last_id == undefined) ? null : "last_id="+last_id;
	var url = btn.dataset.url;
  $.get(url, data, null, 'script');
  $("#more_comments_button").html("Loading more comments ...");
  $("#more_comments_button").prop('disabled',true);
}

var comments_data = {};
var MAX_LENGTH = 100;

function addShowMoreLessToAllComments() {
	$('.report-comment-container').each(function() {
		var id = $(this).attr('id');
		var txt_container = $(this).find('.text-container');
		var content = txt_container.html();

		if(content.length > MAX_LENGTH) {
			var less_content = content.substring(0,MAX_LENGTH) +"...<a href='javascript:void(0)' onclick='showMore("+id+")'>show more</a>";
			var more_content = content+" <a href='javascript:void(0)' onclick='showLess("+id+")'>show less</a>";
			comments_data[id] = {more: more_content, less: less_content};
			txt_container.html(less_content);
		}
	});
}

function addShowMoreLessToComment(id) {

	var container = $('#'+id+'.report-comment-container');
	var txt_container = container.find('.text-container');
	var content = txt_container.html();

	if(content.length > MAX_LENGTH) {
		var less_content = content.substring(0,MAX_LENGTH) +"...<a href='javascript:void(0)' onclick='showMore("+id+")'>show more</a>";
		var more_content = content+" <a href='javascript:void(0)' onclick='showLess("+id+")'>show less</a>";
		comments_data[id] = {more: more_content, less: less_content};
		txt_container.html(less_content);
	}

}

function showMore(id) {
	$('#'+id+'.report-comment-container .text-container').html(comments_data[id].more);
}

function showLess(id) {
	$('#'+id+'.report-comment-container .text-container').html(comments_data[id].less);
}


