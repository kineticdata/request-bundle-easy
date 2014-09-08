/**
 * The KINETIC global namespace object
 * @class KINETIC
 * @static
 */
/*if (typeof KINETIC == "undefined") {
    KINETIC = {};
}
if (typeof KINETIC.fulfillment == "undefined") {
    KINETIC.fulfillment = {};
}

if (! KINETIC.fulfillment.Helper) {*/
	/* ########  START Remove ########## */
	this.removePanel =null;

	this.applyRemove = function() {
            // Set approver name for removal & function question
            KD.utils.Action.setQuestionValue("Function", "Remove");

            // Submit page...
            Dom.getElementsByClassName('templateButton', 'input', KD.utils.Util.getElementObject("Submit"))[0].click();
	};

	this.closeRemove = function() {
            KD.utils.Action.setQuestionValue("Alternate Record ID", "");
			
            removeSection = KD.utils.Util.getElementObject("Remove Section");
            removeSection.style.display="block";

            this.removePanel.hide();
	};

	this._buildRemovePanel = function(elId) {
            var  panelCfg, panelBody;

            if (this.removePanel == null) {
                var pageEl = KD.utils.Util.getElementObject("Alternates List Section");
                var top = YAHOO.util.Dom.getY(pageEl);
                var left = YAHOO.util.Dom.getX(pageEl)+200;

                panelCfg = {
                    width:"480px",
                    x:left,
                    y:top,
                    zIndex:10000,
                    visible:false,
                    draggable:true,
                    close:false,
                    modal:true,
                    /*constraintoviewport:true,*/
                    underlay:"shadow",
                    iframe:false
                };

                this.removePanel = new YAHOO.widget.SimpleDialog("panelRemove_", panelCfg);
                this.removePanel.setHeader("Confirm Removal");
                removeSection = KD.utils.Util.getElementObject("Remove Section");
                removeSection.style.display="block";
                this.removePanel.setBody(removeSection);

                YAHOO.util.Event.throwErrors=false;  // This is needed for some  issues with IE6,7,8
                this.removePanel.render(elId);
                YAHOO.util.Event.throwErrors=true;

                // give the panel body an id to grab onto
                panelBody = KD.utils.Util.getElementsByClassName("bd", "div", "panelRemove_")[0];
                if (panelBody) {
                    panelBody.id = "remove_body";
                }
            }

            // show the panel
            this.removePanel.show();
	};       

	this.removeAlternate = function(altId) {
	        KD.utils.Action.setQuestionValue("Alternate Record ID", altId);
            this._buildRemovePanel (Dom.get("removeAlternateDialog"));
	}
	/* ########  END Remove ########## */
/*}

var fulfillmentHelper = KINETIC.fulfillment.Helper;
var foo = "bar";
*/