//------- FUNCTION AND VALUE OVERRIDES TO ADD LOCALIZATION --------//
KD.utils.ClientManager.requiredWarningStr = KD.utils.ClientManager.requiredWarningStr.localize();
KD.utils.ClientManager.validFormatWarningStr = KD.utils.ClientManager.validFormatWarningStr.localize();
KD.utils.ClientManager.tooManyCharactersForSubmitStr = KD.utils.ClientManager.tooManyCharactersForSubmitStr.localize();

var origAlertPanel = KD.utils.ClientManager.alertPanel;
KD.utils.ClientManager.alertPanel = function(options) {
	options.header =options.header.localize();
	origAlertPanel(options);
}

//------- NOTE:  IF THE _attachMenuCallback function changes in the core code, it will NOT work, as this function
//               overrides that function.
KD.utils.Action._attachMenuCallback = function (o) {
	var clientAction=o.argument[0];
	var recordsXML=KD.utils.Action.getMultipleRequestRecords(o);
	//Only populate the menu if we find some records
	if(recordsXML){
		//The second parameter is the attach menu object
		var action=eval('('+clientAction.params[1]+')');
		if (action) {
			var attachMenu=action.AttachMenu[0];
			var optionValueField, optionTextField;

			if (clientAction.source == "bridge") {
				optionValueField = attachMenu.ValueField;
				optionTextField = attachMenu.LabelField;
			} else {
				var oOptionValue = attachMenu.ValueField.split(";");
				optionValueField = oOptionValue[1];
				var oOptionLabel = attachMenu.LabelField.split(";");
				optionTextField = oOptionLabel[1];
			}
			// SHARMS 7/2/13
			// Change to get specific elelment even when dom structure changes
			// KD.utls
			//var targetList = KD.utils.Util.getQuestionInput(attachMenu.AttachTo);
			var targetList = $('select[id*='+attachMenu.AttachTo+']')[0];

			// remove existing options
			for (var h=targetList.options.length-1; h>=0; h--) {
				targetList.remove(h);
			}
			// add a blank option
			var blankOption = document.createElement("option");
			blankOption.setAttribute("value", "");
			targetList.appendChild(blankOption);
			//Reset width to avoid IE bug
			targetList.style.width = "1";
			// add the unique option(s) found by the request
			var uniqueValueHash=new KD.utils.Hash();
			for (var i=0; i<recordsXML.length; i++) {
				var optionValue = KD.utils.Util._escapeSpecialChars(KD.utils.Action.getRequestValue(recordsXML[i], optionValueField));
				var optionText = KD.utils.Action.getRequestValue(recordsXML[i], optionTextField)
//-------------------------------------------------------->override function to add the .localize() to this next line.<----------------------------------------
				optionText=optionText.localize();
				var checkExists=uniqueValueHash.getItem(optionValue+"--"+optionText);
				if(checkExists == null){
					var newOption = document.createElement("option");
					newOption.setAttribute("value", optionValue);
					newOption.appendChild(document.createTextNode(optionText));
					targetList.appendChild(newOption);
					uniqueValueHash.setItem(optionValue+"--"+optionText, optionValue);
				}
			}
			//Reset width back to avoid IE bug
			targetList.style.width = "auto";
			//fire an onchange for the field menu attached to
			targetList.setAttribute('menuAttached','true');
					//$(targetList).trigger('menuAttached');
		}
		//Set the attached menu to the original value if this is an onload event
		KD.utils.Action.setQuestionValue(attachMenu.AttachTo, targetList.getAttribute("originalValue"));
	}
	KD.utils.ClientManager.onAttachMenu.fire(clientAction);
}