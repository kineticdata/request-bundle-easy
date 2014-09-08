$(function() {
	// Add class based on category for color changes
	var bodyClass = getUrlParameters()['category'].toLowerCase().replace('+','-').replace(' ','-');
	console.log(bodyClass);
	bodyClass.indexOf("request-it") >= 0 ? bodyClass = "request-it" : bodyClass = "fix-it";
	$('body').addClass(bodyClass);
	/* This will display template and category descriptions */
    var descriptionId = $('.category-description').data("description-id");
	getDescription(descriptionId);
    function getDescription(descriptionId) {
        if (descriptionId) {
		   var loader = '#loader';
		   BUNDLE.ajax({
			   cache: false,
			   type: "get",
			   url: BUNDLE.applicationPath + "DisplayPage?srv=" + encodeURIComponent(descriptionId),
			   beforeSend: function(jqXHR, settings) {
					$(loader).show();
			   },
			   success: function(data, textStatus, jqXHR) {
				   $(loader).hide();
				   $('.category-description').html(data).show();
			   },
			   error: function(jqXHR, textStatus, errorThrown) {
				   // A 401 response will be handled by the BUNDLE.ajax function
				   // so we will not handle that response here.
				   if (jqXHR.status !== 401) {
					   $(loader).hide();
					   $('.category-description').html("Could not load description.")
				   }
			   }
		   });
        } 
    }
});