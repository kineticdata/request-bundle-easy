//changes the cookie, see the function updateLanguage for that.
function changeLanguage(language) {
	var today=new Date();
	var expire=new Date();
	expire.setTime(today.getTime()+86400000);
	document.cookie="preferredLocale="+escape(language)+";expires="+expire.toGMTString();
	changeTemplateLanguage(language);
	/* Reload the page */
    window.location=window.location;
}
//changes the session attribute which stores the language a service template is displayed in.  This is used for multiple-page requests to keep the language the user selected.
function changeTemplateLanguage(language) {
	/* Reload the page */
	success = function(o) {
		//window.location=window.location;
	};
	failure = function(o) {
		alert("An error has occurred attempting to change the displayed language.  Please close your browser and try again.".localize());
	};

	connection = new KD.utils.Callback(success,failure,[]);

	// Setup a failure message that is needed by _makeSyncRequest 
	connection.failure=failure;
	var now = new Date();
	KD.utils.Action._makeSyncRequest(BUNDLE.bundlePath+'common/interface/callbacks/updateTemplateLanguage.jsp?&templateInstanceID='+clientManager.templateId+'&language='+language+'&noCache='+now.getTime(), connection);
}