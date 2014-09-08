// Declare the activityTable variable that will point to the activity table
// instance in the global scope.
var tables = {};
var loaded = {};
var activeTable;

jQuery(document).ready(function() {
	var tableNames = ["Open", "Closed", "Draft", "PendingApproval", "ClosedApproval"];
	for (var i in tableNames) {
    // Here we instantiate the main activity table of the page.  This invovles
    // passing in a few configuration parameters as well as defining some
    // callback handlers that are called when requests are sent and responded to
    // as well as one for configuration of the underlying datatable.
    tables[tableNames[i]] = new ActivityTable({
        name: tableNames[i],
        container: "#" + tableNames[i],
        templateId: BUNDLE.config.templateId,
        // Use the column configuration defined above.
        configurationCallback: function(self, options) {
            options.aoColumns = [
				// Create a column that acts as a table control but does not represent
				// any data.  This column will show maximize/minimize controls if the
				// record contains related child records.  This cell callback has been
				// put in another method named childrenCellCallback (see below) for
				// cleanliness.
				{mData: null,
					fnCreatedCell: function(element, sData, oData, iRow, iColumn) {
						if (oData["Has Children"] === "Has Children") {
							childrenCellCallback(element, sData, oData, iRow, iColumn);
						}
						jQuery(element).wrapInner('<div class="wrapper links">');
					}},
				{mData: "Description", sTitle: "Description".localize(),
					fnCreatedCell: function(element, sData, oData, iRow, iColumn) {
					    // Here we look at the current table object (self) to see if
						// it is the PendingApproval table.  If so we add the Requester
						// information to the description.
						if (self.name === "PendingApproval") {
							jQuery(element).append(" (" + oData["Requester"] + ")");
						}
						jQuery(element).wrapInner('<div class="wrapper description">');
					}},
				{mData: "Status", sTitle: "Status (Reason)".localize(),
					fnRender: function(o){
						if (o.aData["Status Reason"] != null && o.aData["Status Reason"].length>0) {
							return (o.aData["Status"].localize() + " (" + o.aData["Status Reason"].localize() + ")");
						} else {
							return o.aData["Status"].localize();
						}
					},
					fnCreatedCell: function(element) {
						jQuery(element).wrapInner('<div class="wrapper status">');
					}},
				//{mData: "Status Reason", sTitle: "Status Reason",
				//	fnCreatedCell: function(element) {
				//		jQuery(element).wrapInner('<div class="wrapper status">');
				//	}},
				// For the Created At column we use the formatDate function to convert
				// the date to a more user-friendly format.
				{mData: "Created At", sTitle: "Created At".localize(),
					fnRender: function(o) {
						return formatDate(o.aData["Created At"]);
					},
					fnCreatedCell: function(element) {
						jQuery(element).wrapInner('<div class="wrapper createdAt">');
					}},
				// For the Expected Resolution column we use the formatDate function to convert
				// the date to a more user-friendly format.  This comes from an attribute field 
				// on the KSR record, and is formatted to modify slightly to replace the 'Z' from
				// the data stored in the text field to be +0000 for the time zone offset of UTC time.
				//{mData: "Expected Resolution Date", sTitle: "Target Resolution".localize(),
				//	fnRender: function(o) {
				//		if (o.aData["Expected Resolution Date"] != null && o.aData["Expected Resolution Date"] != "") {
				//			return formatDate(o.aData["Expected Resolution Date"]);
							//return o.aData["Expected Resolution Date"];
				//		} else {
				//			return o.aData["Expected Resolution Date"];
				//		}
				//	},
				//	fnCreatedCell: function(element) {
				//		jQuery(element).wrapInner('<div class="wrapper expectedResolution">');
				//	}},
				// For the Id column we replace the text content with a link that has a
				// javascript click event bound to it.  This cell callback has been put
				// in another method named idCellCallback (see below) for cleanliness.
				{mData: "Id", sTitle: "Id".localize(),
					fnCreatedCell: function(element, sData, oData, iRow, iColumn) {
						idCellCallback(element, sData, oData, iRow, iColumn);
						jQuery(element).wrapInner('<div class="wrapper id">');
					}},
				// For the Source column, there is initially no data, but we get the
				// source by using the recordSources array returned within the activity
				// table to determine which source this row belongs to.
				{mData: "Source", sTitle: "Source".localize(),
					fnRender: function(o) {return self.recordSources[o.iDataRow];},
					fnCreatedCell: function(element) {
						jQuery(element).addClass("source");
						jQuery(element).text(jQuery(element).text().localize());
						jQuery(element).wrapInner('<div class="wrapper source">');
					}}
			];
        },
        // Add a modal overlay that prevents users from clicking on other
        // controls.  Also hide any current messages and display the loading
        // message.
        loadStartCallback: function(self) {
            jQuery("#overlay").show();
			var tableContainer = jQuery(self.container).parents(".tableContainer");
            jQuery(tableContainer).find(".messages .message").hide();
            jQuery(tableContainer).find(".messages .message.loading").show();
        },
        // Remove the modal overlay.  If the request returned successfully we
        // update each of the controls with metadata from the call.  We also
        // hide the loading message and display a success message.  If the
        // request returned with an error we will display an error message.
        loadCompleteCallback: function(self) {
            var tableContainer = jQuery(self.container).parents(".tableContainer");
			jQuery(tableContainer).find(".messages .message.loading").hide();
            if (self.status === "success") {
                // If this is the first time the table has been loaded we will
                // generate a checkbox for each source in the sources control.
                // We assume that it is the first time loaded when there are no
                // source checkboxes already existing.
				var tableContainer = jQuery(self.container).parents(".tableContainer");
                if (jQuery(tableContainer).find(".tableControls .tableControl.sources .sourcesCheckboxes input[type=checkbox]").length === 0) {
                    var sources = jQuery(tableContainer).find(".tableControls .tableControl.sources .sourcesCheckboxes");
                    jQuery.each(self.sources, function(index, value) {
                        var input = jQuery('<div><input type="checkbox" value="' + value + '">' + value.localize() + '</option></div>');
                        jQuery(sources).append(input);
                    });
                }
                // Here we set the value of each checkbox in the sources control
                // to reflect the sources in the metadata of the response.
                jQuery(tableContainer).find(".tableControls .tableControl.sources .sourcesCheckboxes input[type=checkbox]").each(function(index, element) {
                    if (arrayContains(self.sources, jQuery(element).val())) {
                        jQuery(element).attr("checked", "checked");
                    } else {
                        jQuery(element).attr("checked", null);
                    }
                });
                // Update the other controls to reflect the metadata of the
                // response.
                jQuery(tableContainer).find(".tableControls .tableControl.sortOrder select").val(self.sortOrder);
                jQuery(tableContainer).find(".tableControls .tableControl.pageSize select").val(self.pageSize);
				jQuery(tableContainer).find('.tableControls .tableControl.searchValue input[type="text"]').val(self.searchValue);
                // Generate a success message that contains some information
                // about how many and which records are being viewed out of the
                // total.  These values are calculated using metadata of the
                // response.
                var offset = 0;
                jQuery.each(self.stack[self.stack.length-1], function(index, number) { offset += number; });
                var count = 0;
                jQuery.each(self.counts, function(index, number) { count += number; });
                var total = 0;
                jQuery.each(self.totals, function(index, number) { total += number; });
                jQuery(tableContainer).find(".messages .message.success .content").text((offset+1) + "-" + (offset+count) + " " + "of".localize() + " " + total + " " + "records".localize());
                jQuery(tableContainer).find(".messages .message.success").show();
            } else if (self.status === "error") {
                jQuery(tableContainer).find(".messages .message.error .content").text(self.statusText);
                jQuery(tableContainer).find(".messages .message.error").show();
            }
            jQuery("#overlay").hide();
        }
    });
	}
    //activityTable.initialize();
	
    // Here we bind functions to the table controls.
    jQuery(".tableControls .tableControl.nextPage").click(function() {
        activeTable.nextPage();
    });
    jQuery(".tableControls .tableControl.previousPage").click(function() {
        activeTable.previousPage();
    });
    jQuery(".tableControls .tableControl.refresh").click(function() {
        activeTable.refreshPage();
    });
    jQuery(".tableControls .tableControl.sources input.modify").click(function() {
        jQuery(this).parents(".tableControl.sources").find(".sourcesSelector").slideToggle();
    });
    jQuery(".tableControls .tableControl.sources input.save").click(function() {
        jQuery(this).parents(".sourcesSelector").slideUp();
        activeTable.sources = [];
        jQuery(this).parents(".tableControl.sources").find(".sourcesCheckboxes input:checked").each(function(index, element) {
            activeTable.sources.push(jQuery(element).val());
        });
        activeTable.initialize();
    });
    jQuery(".tableControls .tableControl.sortOrder select").change(function() {
        activeTable.sortOrder = jQuery(this).val();
        activeTable.initialize();
    });
    jQuery(".tableControls .tableControl.pageSize select").change(function() {
        activeTable.pageSize = jQuery(this).val();
        activeTable.initialize();
    });
	jQuery('.tableControls .tableControl.searchValue input[type="button"]').click(function() {
		activeTable.searchValue = jQuery(this).parents(".tableControl.searchValue").find('input[name="searchValue"]').val();
		activeTable.initialize();
	});
		
	/*
	 * Bind events to table links that hide/show different tables.
	 */
	$(".summaryItem").click(function() {
		catalogHelper.resetSearch();
		catalogHelper.hideMyInfo();
		jQuery(".searchInput").css("visibility","hidden");
		jQuery("#serviceItems").hide();
		jQuery("#categoryServiceItems").hide();
		jQuery("#upperFooter").hide();
		jQuery("#quick_links_box2").hide();
		
		var tableName = jQuery(this).data("table-name");
		activeTable = tables[tableName];
		
		if (loaded[tableName] !== true) {
			loaded[tableName] = true;
			activeTable.initialize();
		}
		jQuery("#submissionSection").show();
		jQuery(".tableContainer").hide();
		jQuery(tables[tableName].container).parent().show();
		jQuery(tables[tableName].container).parents(".tableContainer").show();
	});
	
	// This variable tells us whether or not the plot has been drawn.  We
	// do not always draw the plot on document ready because it may be
	// hidden and will not draw properly.
	BUNDLE.plotDrawn = false;
	
	// Here we check the URL parameters to see if it includes the status
	// parameter.  If it does we will show the specified table automatically
	// when the page is loaded.  If a status is not specified we will show
	// the catalog page by default.
	var status = decodeURIComponent(KD.utils.Util.getParameter("status"));
	if (tables.hasOwnProperty(status)) {
		jQuery(".searchInput").css("visibility","hidden");
		activeTable = tables[status];
		activeTable.initialize();
		jQuery("#submissionSection").show();
		jQuery(".tableContainer").hide();
		jQuery(tables[status].container).parent().show();
		jQuery(tables[status].container).parents(".tableContainer").show();
    } else {
        // This function is a helper that hides the activity tables and shows
		// the catalog page items.  It is defined in the catalog.js, it is
		// the function called when you click on the "Home" button.
		KINETIC.catalog.Helper.showMainDisplay();
		BUNDLE.drawPlot();
		BUNDLE.plotDrawn = true;
    }
});

// This function is a callback handler for the cells that represent record ids.
// It replaces the standard text with a link that contains the record id.  Also
// a javascript click event is bound to each link.  When clicked another
// function will be called depending on the source of record.
function idCellCallback(element, sData, oData, iRow, iColumn) {
    jQuery(element).empty();
	var title='title="' + 'View request fulfillment details'.localize() + '"';
	var anchorElement = jQuery('<a ' + title + ' href="javascript:void(0)">'+oData["Id"]+'</a>');
    if (activeTable.name==="Draft") {
		title='title="' + 'Complete current In Progress Request'.localize() + '"';
		anchorElement = jQuery('<a ' + title + ' href="DisplayPage?csrv='+oData["Instance Id"]+'&return=yes">'+oData["Id"]+'</a>');
	} else if (activeTable.name==="PendingApproval") {
		title='title="' + 'Complete approval response'.localize() + '"';
		anchorElement = jQuery('<a ' + title + ' href="DisplayPage?csrv='+oData["Instance Id"]+'">'+oData["Id"]+'</a>');
	} else if (activeTable.name==="ClosedApproval") {
		title='title="' + 'Review approval response'.localize() + '"';
		anchorElement = jQuery('<a ' + title + ' href="ReviewRequest?csrv='+oData["Instance Id"]+'&reviewPage='+BUNDLE.config.reviewJsp+'">'+oData["Id"]+'</a>');
	} else {
	    jQuery(anchorElement).click(function() {
			if (oData["Source"] === "Request") {
				getRequestDialog(oData["Instance Id"]);
			} else if (oData["Source"] === "Change") {
				getChangeDialog(oData["Id"]);
			} else if (oData["Source"] === "Incident") {
				getIncidentDialog(oData["Id"]);
			} else if (oData["Source"] === "Work Order") {
				getWorkOrderDialog(oData["Id"]);
			}
		});
	}
    jQuery(element).append(anchorElement);

}

// This function is a callback handler for the cells that contain child data
// controls (maximize/minimize).  It replaces the standard text with the
// maximize/minimize links and binds events to each.  When the maximize link is
// clicked we make a call to the activity.json.jsp to retrieve child data.  A
// row is then added below the current one and the new data is presented using
// a slide down animation.  Also the maximize link is then hidden and a minimize
// link will be shown.  When the minimize link is clicked the child data row is
// hidden using a slide up animation and the minimize link is hidden and the
// maximize link is redisplayed.
function childrenCellCallback(element, sData, oData, iRow, iColumn) {
    jQuery(element).empty();
    var minAnchor = jQuery('<a class="minimize hidden" href="javascript:void(0)">-</a>');
    var maxAnchor = jQuery('<a class="maximize" href="javascript:void(0)">+</a>');
    var loadingImage = jQuery('<img class="hidden" src="' + BUNDLE.packagePath + 'resources/images/spinner_00427E_FFFFFF.gif"></img>');
    jQuery(element).addClass("links");
    jQuery(element).append(maxAnchor);
    jQuery(element).append(minAnchor);
    jQuery(element).append(loadingImage);
    var currentRow = jQuery(element).parent("tr");
    var childRow, childContent;
    maxAnchor.click(function() {
        maxAnchor.hide();
        loadingImage.show();
        BUNDLE.ajaxRetry({
            url: BUNDLE.packagePath + "interface/callbacks/activity.json.jsp",
            data: {
                name: "children",
                requestId: oData["Id"],
                templateId: BUNDLE.config.templateId,
                pageSize: 0
            },
			error: function(data) {
                loadingImage.hide();
                maxAnchor.show();
			},
            success: function(data) {
                loadingImage.hide();
                minAnchor.show();
                var response = jQuery.parseJSON(data);
                childRow = jQuery('<tr class="childRow"><td colspan="8"><div class="childContainer"><table class="childTable"></table></div></td></tr>');
                currentRow.after(childRow);
                var dataTableOptions = {
                    bPaginate: false,
                    bFilter: false,
                    bSort: false,
                    bInfo: false,
                    bAutoWidth: false,
                    aoColumns: [
						{mData: null,
						fnCreatedCell: function(element, sData, oData, iRow, iColumn) {
							jQuery(element).wrapInner('<div class="wrapper links">');
						}},
						{mData: "Description", sTitle: "Description",
							fnCreatedCell: function(element) {
								jQuery(element).wrapInner('<div class="wrapper description">');
							}},
						{mData: "Status", sTitle: "Status (Reason)",
							fnRender: function(o){
								if (o.aData["Status Reason"] != null && o.aData["Status Reason"].length>0) {
									return (o.aData["Status"].localize() + " (" + o.aData["Status Reason"].localize() + ")");
								} else {
									return o.aData["Status"].localize();
								}
							},
							fnCreatedCell: function(element) {
								jQuery(element).wrapInner('<div class="wrapper status">');
							}},
						//{mData: "Status Reason", sTitle: "Status Reason",
						//	fnCreatedCell: function(element) {
						//		jQuery(element).wrapInner('<div class="wrapper status">');
						//	}},
						// For the Created At column we use the formatDate function to convert
						// the date to a more user-friendly format.
						{mData: "Created At", sTitle: "Created At",
							fnRender: function(o) {
								return formatDate(o.aData["Created At"]);
							},
							fnCreatedCell: function(element) {
								jQuery(element).wrapInner('<div class="wrapper createdAt">');
							}},
						// For the Expected Resolution column we use the formatDate function to convert
						// the date to a more user-friendly format.  This comes from an attribute field 
						// on the KSR record, and is formatted to modify slightly to replace the 'Z' from
						// the data stored in the text field to be +0000 for the time zone offset of UTC time.
						//{mData: null, sTitle: "Expected Resolution",
						//	fnCreatedCell: function(element) {
						//		jQuery(element).wrapInner('<div class="wrapper expectedResolution">');
						//	}},						
						// For the Id column we replace the text content with a link that has a
						// javascript click event bound to it.  This cell callback has been put
						// in another method named idCellCallback (see below) for cleanliness.
						{mData: "Id", sTitle: "Id",
							fnCreatedCell: function(element, sData, oData, iRow, iColumn) {
								idCellCallback(element, sData, oData, iRow, iColumn);
								jQuery(element).wrapInner('<div class="wrapper id">');
							}},
						// For the Source column, there is initially no data, but we get the
						// source by using the recordSources array returned within the activity
						// table to determine which source this row belongs to.
						{mData: "Source",
							fnRender: function(o) {return response.recordSources[o.iDataRow];},
							fnCreatedCell: function(element) {
								jQuery(element).addClass("source");
								jQuery(element).text(jQuery(element).text().localize());
								jQuery(element).wrapInner('<div class="wrapper source">');
							}}
					],
                    aaData: response["records"]
                };
                childRow.find(".childTable").dataTable(dataTableOptions);
                childRow.find(".childContainer").slideDown(200);
				
				//need to set odd/even class on the child row to match that of the parent.  By default
				//the table will use the zebra strips to identify each row within the table.  Since the child
				//records are actually a new table, every one will start with an odd row and then start zebra
				//striping within the list of children.  Instead, we should use the same background as the 
				//parent record.  We also need to look for multiple possible children rows - which really 
				//aren't "children", but sibling rows with a differnet class ("childRow") on them.
				var childElements = (jQuery(currentRow).nextUntil(".odd,.even"));
				jQuery(childElements).find("tr").attr("class",jQuery(currentRow).attr("class"));
            }
        });
    });
    minAnchor.click(function() {
        childRow.find(".childContainer").slideUp(200, function() {
            childRow.remove();
            minAnchor.hide();
            maxAnchor.show();
        });
    });
}


function getRequestDialog(submissionInstanceId) {
	BUNDLE.ajax({
        url: BUNDLE.packagePath + "interface/callbacks/submissionDetails.html.jsp",
        data: {csrv: submissionInstanceId},
        success: function(data) {
            createDialog(data);
        }
    });
}
function getChangeDialog(changeId) {
    BUNDLE.ajax({
        url: BUNDLE.packagePath + "interface/callbacks/changeDialog.html.jsp",
        data: {
            id: changeId,
            templateId: BUNDLE.config.templateId
        },
        success: function(data) {
            createDialog(data);
        }
    });
}
function getIncidentDialog(incidentId) {
    BUNDLE.ajax({
        url: BUNDLE.packagePath + "interface/callbacks/incidentDialog.html.jsp",
        data: {
            id: incidentId,
            templateId: BUNDLE.config.templateId
        },
        success: function(data) {
            createDialog(data);
        }
    });
}
function getWorkOrderDialog(workOrderId) {
    BUNDLE.ajax({
        url: BUNDLE.packagePath + "interface/callbacks/workOrderDialog.html.jsp",
        data: {
            id: workOrderId,
            templateId: BUNDLE.config.templateId

        },
        success: function(data) {
            createDialog(data);
        }
    });
}
function createDialog(content) {
    var element = jQuery(content);
    element.find(".value.dateTime").each(function(index, value) {
       jQuery(value).text(formatDate(jQuery(value).text())); 
    });
    jQuery('body').append(element);
    element.dialog({
        closeText: 'close',
        width: 500
    });
    $(element).parent().append('<div class="kd-shadow"></div>');
}

/*
 * This function takes a ISO8601 date string (the exact format expected from a
 * bridge request) and converts it to a more user-friendly format.  It looks at
 * a BUNDLE.config.locale value to determine which date format mask to use.
 */
function formatDate(dateString) {
    var match = dateString.match(/(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2}):(\d{2})\+0000/);
    if (match === null) {
        throw "Invalid date string given to formatDate: '" + dateString + "'";
    }
    var date = new Date();
    date.setUTCFullYear(match[1], parseInt(match[2].replace(/^0/,""))-1, match[3]);
    date.setUTCHours(match[4], match[5], match[6]);
    if (BUNDLE.config.locale === "EN") {
        //return date.format("mmm d yyyy h:MM:ss TT");
		return date.format("mm/dd/yy h:MM TT");
    } else {
        return date.format("isoDateTime");
    }
}

/*
 * This function takes an array and a value.  It returns true if the value
 * exists within the array otherwise it returns false.  This is useful because
 * the other way of checking this (the indexOf method) is not supported by IE7.
 */
function arrayContains(array, value) {
    for (var i=0; i<array.length; i++) {
        if (array[i] === value) { return true; }
    }
    return false;
}