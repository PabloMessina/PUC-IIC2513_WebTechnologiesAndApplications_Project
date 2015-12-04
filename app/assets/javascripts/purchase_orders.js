// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

var purchases_data_map = null;
var PAGE_SIZE = 10;
var purchase_orders_details = new Map();
var purchases_data_map = new Map();
var purchases_data_array = [];

$(function() {

	//configure datepickers
	var from = $("#custom_period_container #from_date");
	var to = $("#custom_period_container #to_date");
	from.datepicker({ dateFormat: 'yy-mm-dd' });
	to.datepicker({ dateFormat: 'yy-mm-dd' });

	//create chart
	generateChartData();
	createChart();

	//render pagination links and table
	renderPaginationLinks(1);
	renderPurchaseOrdersTable(1);

	//setup refresh sales button
	$("#refresh_sales_button").on('click', refreshSales);

	//setup click actions for nav links
	$("#sales_link").on("click", function(){
		if( $(this).hasClass("clickable") ) {
			$("#menu_nav .separator").hide();
			$("#details_link").hide();
			var slink = $("#sales_link");
			slink.removeClass("clickable");			
			slink.addClass("selected");			
			$("#details_container").hide();
			$("#sales_container").show();
		}
	});

});

function refreshSalesGUIfromData(data) {
	purchases_raw_data = data;

	var sales_container = $("#sales_container");
	var details_container = $("#details_container");
	var not_found_container = $("#no_found");

	if(data.length > 0) {
		sales_container.show();
		details_container.hide();
		not_found_container.hide();

		generateChartData();
		createChart();
		renderPage(1);
	} else {

		sales_container.hide();
		details_container.hide();
		not_found_container.html("<h2>No sales found in the period</h2>");		
		not_found_container.show();
	}
}

function refreshSales() {

	//data to send
	var data = {
		period: $("input[type='radio'][name='period']:checked").val(),
		from_date: $("#from_date").val(),
		to_date: $("#to_date").val()
	};

	//display loading div
	$("#loading_div .feedback-message").html("Loading Sales");
	$("#loading_div").show();
	$("#refresh_sales_button").prop('disabled', true);

	//make ajax request for json
	$.ajax({
		dataType: "json",
		url: Routes.grocery_purchase_orders_path(grocery_id),
		data: data
	})
	.done(function(data, textStatus, jqXHR) {
		refreshSalesGUIfromData(data);		
	})
	.fail(function(jqXHR, textStatus, errorThrown) {
	  alert( "error: "+jqXHR+",\n "+textStatus+",\n " + errorThrown);
	})
	.always(function() {
		$("#loading_div").hide();  
		$("#refresh_sales_button").prop('disabled', false);
	});

}

function generateChartData() {

	purchases_data_map.clear();
	purchases_data_array.length = 0;

	for (var i = purchases_raw_data.length - 1; i >= 0; i--) {

		var raw_data = purchases_raw_data[i];
		var date = raw_data.date.substring(0,10);

		if(purchases_data_map.has(date)) {
			var tuple = purchases_data_map.get(date);
			tuple.total_price += parseInt(raw_data.total_price);
			tuple.total_sales++;
		} else {
			var dateParts = date.split("-");
			var dateObj = new Date(dateParts[0],dateParts[1]-1,dateParts[2]);
			var tuple = {
				date: dateObj, 
				total_price: parseInt(raw_data.total_price), 
				total_sales: 1
			}
			purchases_data_map.set(date,tuple);
			purchases_data_array.push(tuple);
		}	

	};

	purchases_data_array.sortBy(function(o){return o.date;});

}

function renderPage(curr_page) {
	renderPaginationLinks(curr_page);
	renderPurchaseOrdersTable(curr_page);
}

function renderPaginationLinks(curr_page) {

	console.log("renderPaginationLinks()");
	console.log("curr_page = "+curr_page);

	var numPages = Math.ceil(purchases_raw_data.length/PAGE_SIZE);
	var first_page = Math.max(1,curr_page-4);
	var last_page = Math.min(first_page+8,numPages);

	var html = "";
	if(curr_page > 1) {
		html+="<a href='javascript:void(0)' onclick='renderPage("+(curr_page-1)+");'>Previous</a>";
	}
	for(var i = first_page; i <= last_page; i++) {
		if(i == curr_page)
			html += "<span class='selected'>"+i+"</span>";
		else
			html += "<a href='javascript:void(0)' onclick = 'renderPage("+i+");'>"+i+"</a>";
	}
	if(curr_page < last_page) {
		html+="<a href='javascript:void(0)' onclick='renderPage("+(curr_page+1)+");'>Next</a>";
	}

	$("#purchase_orders_container #pagination").html(html);

}

function renderPurchaseOrdersTable(curr_page) {

	var html = "<table border><tr><th>Date</th><th>order lines</th><th>total price</th><th>details</th></tr>";
	var begin = (curr_page-1)*PAGE_SIZE;
	var end  = Math.min(purchases_raw_data.length,begin + PAGE_SIZE);
	for(var i = begin; i < end; ++i) {
		var data = purchases_raw_data[i];
		var date = data.date;
		var olcount = data.order_lines_count;
		var tprice = data.total_price;
		var date_str = date.substring(0,10) + " at "+date.substring(11,19);
		html+= "<tr><td>"+date_str+"</td><td>"+olcount+"</td><td>"+tprice+"</td><td><a href='javascript:void(0)' onclick='showDetails("+data.id+");'>see details</a></td></tr>";
	}
	html+="</table>";
	$("#purchase_orders_container #rows").html(html);

}


function showDetails(purchase_order_id) {
	var po_id = purchase_order_id;

	if (purchase_orders_details.has(po_id)) {

		//use already cached html
		var html = purchase_orders_details.get(po_id);
		$("#details_container").html(html);
		switchToDetails();

	} else {

		//display loading div
		$("#loading_div .feedback-message").html("Loading Purchase Order Details");
		$("#loading_div").show();
		$("#refresh_sales_button").prop('disabled', true);

		//request the html from server
		$.ajax({
			dataType: "script",
			url: Routes.grocery_purchase_order_path(grocery_id,po_id)
		})
		.done(function(data, textStatus, jqXHR) {
			switchToDetails();
		})
		.fail(function(jqXHR, textStatus, errorThrown) {
		  alert( "error: "+jqXHR+",\n "+textStatus+",\n " + errorThrown);
		})
		.always(function() {
			$("#loading_div").hide();  
			$("#refresh_sales_button").prop('disabled', false);
		});

	}
}

function switchToDetails() {
	$("#menu_nav .separator").show();
	var dlink = $("#details_link");
	dlink.removeClass("clickable");
	dlink.addClass("selected");
	dlink.show();
	var slink = $("#sales_link");
	slink.addClass("clickable");			
	slink.removeClass("selected");
	$("#sales_container").hide();
	$("#details_container").show();
}

function createChart() {

	var chart = AmCharts.makeChart("chartdiv", {

		type: "stock",
		pathToImages: "/images/amcharts/",

		dataSets: [{
			color: "#b0de09",
			fieldMappings: [{
				fromField: "total_price",
				toField: "total_price"
			}],
			dataProvider: purchases_data_array,
			categoryField: "date"
		}],

		panelsSettings:{
			creditsPosition: "bottom-right"
		},

		panels: [{
			showCategoryAxis: true,
			title: "Total Price",
			eraseAll: false,
			labels: [{
				x: 0,
				y: 100,
				text: "Click on the pencil icon on top-right to start drawing",
				align: "center",
				size: 16
			}],

			stockGraphs: [{
				id: "g1",
				valueField: "total_price",
				bullet: "round",
				bulletColor: "#FFFFFF",
				bulletBorderColor: "#00BBCC",
				bulletBorderAlpha: 1,
				bulletBorderThickness: 2,
				bulletSize: 7,
				lineThickness: 2,
				lineColor: "#00BBCC",
				useDataSetColors: false,
				balloonText: "Total price: $[[total_price]] <br> Purchase orders: [[total_sales]]",
		    balloonFunction: function(item, graph) {
		      var result = graph.balloonText;
		      var dc = item.dataContext.dataContext;
		      for (var key in dc) {
		        if (dc.hasOwnProperty(key) && !isNaN(dc[key])) {
		          result = result.replace("[[" + key + "]]", dc[key]);
		        }
		      }
		      return result;
		    }
			}],

			stockLegend: {
				valueTextRegular: " ",
				markerType: "none"
			},

			drawingIconsEnabled: true
		}],

		chartScrollbarSettings: {
			graph: "g1"
		},
		periodSelector: {
			position: "bottom",
			periods: [{
				period: "DD",
				count: 10,
				label: "10 days"
			}, {
				period: "MM",
				count: 1,
				label: "1 month"
			}, {
				period: "YYYY",
				count: 1,
				label: "1 year"
			}, {
				period: "YTD",
				label: "YTD"
			}, {
				period: "MAX",
				label: "MAX"
			}]
		}
	});
}