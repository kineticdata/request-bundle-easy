$(function() {
    // Instantiate classes.
    var msg = new Message();

    /****************************************************************************************************
    Combo boxes
    ****************************************************************************************************/

	// Initialize template attributes combo box
	$('p.template-attributes select').combobox({
		selectHandler: function(event, ui) {
            // Input value has been changed, reset infield label
            $($(this.element).parent().find('label')).inFieldLabels();
			$(this.element.data('target')).show()
                .find('input')
                .data('key', ui.item.value)
                .data('type', 'templateFilters')
                .data('target', 'ul.template-attributes')
                .focus();

			// Set the template filter values select options
            var attributeValuesSelect = $(this.element.data('target')).find('select').empty();
			$.each(getAllTemplateAttributeValues(ui.item.value), function(index, attribute) {
                attributeValuesSelect.append($('<option>').attr('value', attribute).text(attribute));
            });
		},
		sourceHandler: function(request, response) {
			sourceHelper.call(this, $(this.element.data('target')).children(), request, response);
		},
        complete: function() {
            // Start infield label
            this.input.attr('id', $(this.element).parent().find('label').attr('for'));
            $($(this.element).parent().find('label')).inFieldLabels();
        }
	});
    
    // Initialize template attribute value combo box
	$('p.template-attribute-value select').combobox({
		selectHandler: function(event, ui) {
			this.input.val(ui.item.value);
			// Nested ul li like answer attributes
			generateNestedAttributeAnswer.call(this.input);
			return false;
		},
		sourceHandler: function(request, response) {
			sourceHelper.call(this, $(this.element.data('target')).children(), request, response);
		},
        complete: function() {
            // Start infield label
            this.input.attr('id', $(this.element).parent().find('label').attr('for'));
            $('label.infield').inFieldLabels();
        }
	});

	// Initialize template, status and display status combo box
	$('p.templates select, p.status select, p.display-status select').combobox({
		selectHandler: function(event, ui) {
			selectHelper.call(this, event, ui);
			this.input.val('');
			return false;
		},
		sourceHandler: function(request, response) {
			sourceHelper.call(this, $(this.element.data('target')).children(), request, response);
		},
		complete: function() {
            // Start infield label
            this.input.attr('id', $(this.element).parent().find('label').attr('for'));
            $($(this.element).parent().find('label')).inFieldLabels();
        }
	});

	// Initialize answers and attributes combo box 
	$('p.answers select, p.attributes select').combobox({
		selectHandler: function(event, ui) {
            // Input value has been changed, reset infield label
            $($(this.element).parent().find('label')).inFieldLabels();
			$(this.element.data('target')).show()
                .find('input')
                .data('key', ui.item.value)
                .focus();
		},
		sourceHandler: function(request, response) {
			sourceHelper.call(this, $(this.element.data('target')).children(), request, response);
		},
        complete: function() {
            // Start infield label
            this.input.attr('id', $(this.element).parent().find('label').attr('for'));
            $($(this.element).parent().find('label')).inFieldLabels();
            // jQuery unobstrusive live on focusout event for answer/attribute values
            var widget = this;
            $(this.element.data('target')).find('input').on('focusout', function(event) {
                $(this).parent().hide();
                widget.input
                    .val('')
                    .blur()
                    .focus();
            });
            // On click event for setting answer/attribute values
            $(this.element.data('target')).find('input').on('keypress', function(event) {
                // Determine if user hit enter before starting event
                if(event.keyCode === 13) {
                    // Prevent enter from submitting the form
                    event.preventDefault();
                    // Add the answer value
                    generateNestedAttributeAnswer.call(this);
                }
            });
        }
	});

	/****************************************************************************************************
	UI Events
	****************************************************************************************************/
    entryOptionSelected = 5;
    // On click event for search which starts the consoleTable
    $('form.operations-support-console p').on('click', 'input[type="submit"]', function(event) {
        event.preventDefault();
        // Clear any error messages from before
        $('div.error-message').empty();
        // Set pagination flag for client vs server side pagination
        paginationFlag = false;
        // Server side or client side pagination
        if(Object.keys(query.answerFilters).length === 0 && Object.keys(query.attributeFilters).length === 0) {
            paginationFlag = true;
        }
        // Start Ars Table
        $('div.results').consoleTable({
            displayFields: {
                'Id': 'KSR',
                'Template Name': 'Template',
                'Status': 'Status',
                'Display Status': 'Display Status', 
                'Requested By': 'Requested By',
                'Created At': 'Created',
                'Updated At': 'Updated'
            },
            paginationPageRange: 5,
            pagination: true,
            entryOptionSelected: entryOptionSelected,
            entryOptions: [5, 10, 20, 50, 100],
            entries: true,
            info: true,
            sortOrder: 'DESC',
            serverSidePagination: paginationFlag,
            sortOrderField: 'Updated At',
            dataSource: function(limit, index, sortOrder, sortOrderField) {
                var widget = this;
                var responseMessage = $('div.results-message');
                var loader = $('div#loader');
                var searchedFilters = $('ul.searched-filters');
                // Pagination
                setMetadata('limit', limit);
                setMetadata('offset', index);
                // Sort
                setOrder(sortOrderField, sortOrder);
                // Execute the ajax request.
                BUNDLE.ajax({
                    dataType: 'json',
                    cache: false,
                    type: 'get',
                    traditional: true,
                    url: BUNDLE.config.apiPath+"/requests",
                    data: buildQueryData(query),
                    beforeSend: function(jqXHR, settings) {
                        widget.consoleTable.hide();
                        responseMessage.empty();
                        searchedFilters.hide().empty();
                        loader.show();
                    },
                    success: function(data, textStatus, jqXHR) {
                        loader.hide();
                        if(data.data.metadata.count > 0) {
                            widget.buildResultSet(data.data.records, data.data.metadata.count);
                            // Slide and display
                            $('form.operations-support-console').slideUp();
                            $('h3').hide();
                            $('p.filter-search').show();
                            widget.consoleTable.show();
                            listQueryHtmlFilters(searchedFilters, query);
                        } else {
                            responseMessage.html(msg.setMessage('No results found.').getErrorMessage()).show();
                            widget.destroy.call(widget);
                        }
                    },
                    error: function(jqXHR, textStatus, errorThrown) {
                        loader.hide();
                        responseMessage.html(msg.setMessage(errorThrown).getErrorMessage()).show();
                        widget.destroy.call(widget);
                    }
                });
            },
            rowCallback: function(tr, value, index) { 
                tr.data('ksr', value['Id']); 
            },
            columnCallback: function(td, value, fieldname, label) {
                // qtip options
                var qtipOptions = {
                    content: {
                        attr: 'data-timestamp'
                    },
                    style: {
                        corner: 'bottom left',
                        classes: 'ui-tooltip-tipsy ui-tooltip-shadow'
                    },
                    position: {
                        my: 'right bottom',
                        at: 'top middle'
                    }
                };
                // Note::jQuery data doesn't work on td
                if(fieldname === 'Created At' || fieldname === 'Updated At') {
                    td.attr('data-timestamp', ((value !== null) ? moment(value).format('YYYY-MM-DD hh:mm:ss a') : ""))
                    .qtip(qtipOptions)
                    .text(
                        moment(td.text()).fromNow()
                    )
                }
                if(fieldname === 'Id') { td.html($('<a>').addClass('review').attr('href', 'javascript:void()').append(value)); }
            },
            completeCallback: function() {
                // Unobstrusive live click event for view details
                this.consoleTable.on('click', 'table tbody tr', function(event) {
                    // Prevent default action.
                    event.preventDefault();
                    event.stopImmediatePropagation();
                    window.open(BUNDLE.config['submissionDetailsUrl']+'&id=' + $(this).data('ksr'));
                });

                // jQuery unobstrusive live on click event for review request
                this.consoleTable.on('click', 'table tbody tr td a.review', function(event) {
                    event.preventDefault();
                    event.stopImmediatePropagation();
                    window.open(BUNDLE.config.submissionReviewUrl + '?ksr=' + $(this).parents('tr').data('ksr'));
                });
            }
        });
    });

    // Return to search event
    $('p.filter-search').on('click', function(event) {
        event.preventDefault();
        // Slide
        $('form.operations-support-console').slideDown();
        $(this).hide();
        $('div.results').hide();
        $('h3').show();
        $('ul.searched-filters').empty().hide();
        // Set new selected option for later
        entryOptionSelected = parseInt($('select.limit').val());
        $('div.results').consoleTable('destroy');
    });

	$('select.range').change(function() {
		var value = $(this).val();
		if (value === "Custom") {
			alert('Custom range has not been implemented.')
			$(this).find('option[value="Past Week"]').attr('selected', 'selected');
		} else {
			if($(this).data('type') === 'updated') {
				query.updatedWithin = value;
			} else if($(this).data('type') === 'created') {
				query.createdWithin = value;
			}
		}
	});

	$('input[name="ksrSearch"]')
		.on('keypress', function(event) {
			if(event.keyCode === 13) {
				event.preventDefault();
				openRequest($(this).val());
			}
		})
		.on('blur', function() {
			$(this).val('');
		});

	// On click event for removing filters before search
	$('div.wrap ul.non-nested').on('click', 'li.filter a.close', function(event) {
		var type = $(this).parent().data('type');
		var id = $(this).parent().data('id');
        var templateIndex = $(this).parent().data('index');
        // Remove query filters
		removeQueryFilters(type, id, templateIndex, null, null);
        if(query.templates.length === 0) {
            // Clear answer/attributes
            // @TODO this might have to get more complex later so the ui and query are properly updated based on the template removed.
            $('ul.attributes, ul.answers').empty();
            $('p.answers input[name="answerValue"], p.attributes input[name="attributeValue"]').hide();
            query.answerFilters = new Object();
            query.attributeFilters = new Object();
        }
		// Return to ancestor autocomplete input
        $(this).parents('div.wrap').find('p input').focus();
	});

    // On click event for removing filters that were previously searched
    $('ul.searched-filters').on('click', 'li a.close', function(event) {
        var type = $(this).parent().data('type');
        var id = $(this).parent().data('id');
        var templateIndex = $(this).parent().data('index');
        var key = $(this).parent().data('key');
        var value = $(this).parent().data('value');
        // Remove query filters
        removeQueryFilters(type, id, templateIndex, key, value);
        if(query.templates.length === 0) {
            // Clear answer/attributes
            // @TODO this might have to get more complex later so the ui and query are properly updated based on the template removed.
            $('ul.attributes, ul.answers').empty();
            $('p.answers input[name="answerValue"], p.attributes input[name="attributeValue"]').hide();
            query.answerFilters = new Object();
            query.attributeFilters = new Object();
        }
        // Remove ui filter from search
        $('form.operations-support-console').find('li[data-id="'+ id + '"]').remove();
        // Remove ui answer/attribute filter from search
        var nestedFilter = $('form.operations-support-console').find('li[data-key="' + key + '"]li[data-value="'+ value + '"]');
        if(nestedFilter.parents('div.wrap ul.filters').children().length == 1) {
            nestedFilter.parents('div.wrap ul.filters')
                .parent()
                .remove();
        } else {
            nestedFilter.parents('div.wrap ul.filters')
                .remove();
        }
        // Refresh table
        $('a.refresh').trigger('click');
    });

	// jQuery unobstrusive live on click event for removing the answer or attribute filter if no children exist
	$('div.wrap ul.nested').on('click', 'li.filter a.close', function(event) {
		// Return to ancestor autocomplete input, this needs to call before removing the last li
		$(this).parents('div.wrap').find('p input:first').focus();
        var type = $(this).parent().data('type');
        var key = $(this).parent().data('key');
        var value = $(this).parent().data('value');
        // Remove query filters
        removeQueryFilters(type, null, null, key, value);
		if($(this).parents('ul.filters').children().length == 1) {
			$(this).parents('ul.filters').parent().remove();
		} else {
            $(this).parent().remove();
        }
	});

    // jQuery unobstrusive live on click event for validation attribute/answer selection
	$('div.wrap p.answers, div.wrap p.attributes').on('keypress click', 'input, button', function(event) {
		// Display error message if template not selected
		if($(this).parents('div.wrap').find('select option').length === 0) {
			event.preventDefault();
            $(this).parents('div.wrap')
                .find('div.error-message')
                .html(msg.setMessage('Select Template').getErrorMessage())
                .show();
		}
	});

	var previousFocus = null;
	$('body').on('blur', 'input, textarea', function(event) {
		previousFocus = event.target;
	});
	$('body').on('click', function(event) {
		if (previousFocus != null) {
			var previouslyFocusedGroup = $(previousFocus).parents('.group').first().get(0); 
			var currentFocusedGroup = $(event.target).parents('.group').first().get(0); 
			if (previouslyFocusedGroup != currentFocusedGroup) {
				$(previouslyFocusedGroup).find('.primary input').val('');
                $(previouslyFocusedGroup).find('.primary input').blur();
				$(previouslyFocusedGroup).find('.dependent input').val('');
				$(previouslyFocusedGroup).find('.dependent').hide();
			}
		}
	});
	$('body').on('focus', 'input, textarea', function(event) {
		if (previousFocus != null) {
			var previouslyFocusedGroup = $(previousFocus).parents('.group').first().get(0); 
			var currentFocusedGroup = $(event.target).parents('.group').first().get(0); 
			if (previouslyFocusedGroup != currentFocusedGroup) {
				$(previouslyFocusedGroup).find('.primary input').val('');
                $(previouslyFocusedGroup).find('.primary input').blur();
				$(previouslyFocusedGroup).find('.dependent input').val('');
				$(previouslyFocusedGroup).find('.dependent').hide();
			}
		}
	});

	/****************************************************************************************************
	UI Helper Functions
	****************************************************************************************************/

    /**
     * @param type
     * @param id
     * @param templateIndex
     */
    function removeQueryFilters(type, id, templateIndex, key, value) {
        // Select Template
        if(type == 'template') {
            unselectTemplate(templateIndex);
            removeTemplate(id)
        } else if (type === "category") {
            removeCategory(id);
        } else if (type === "requested-by") {
            removeField("Requested By", id);
        } else if (type === "requested-for") {
            removeField("Requested For", id);
        } else if (type === 'Status') {
            removeField('Status', id);
        } else if (type === 'Display Status') {
            removeField('Display Status', id);
        } else if (type === 'templateFilters') {
            removeTemplateFilter(key, value);
        } else if (type === 'answerFilters') {
            removeAnswer(key, value);
        } else if (type === 'attributeFilters') {
            removeAttribute(key, value);
        } else {
            throw "Unexpected type: " + type;
        }
    }

    /**
     * @param type
     * @param id
     * @param templateIndex
     */
    function addQueryFilters(type, id, templateIndex) {
        // Select Template
        if(type === 'template') {
            addTemplate(id);
            selectTemplate(templateIndex);
        } else if (type === 'category') {
            addCategory(id);
        } else if (type === 'Requested By') {
            addField('Requested By', id);
        } else if (type === 'Requested For') {
            addField('Requested For', id);
        } else if (type === 'Status') {
            addField('Status', id);
        } else if (type === 'Display Status') {
            addField('Display Status', id);
        }
    }

	/**
	 * @param event
	 * @param ui
	 */
	function selectHelper(event, ui) {
		var type = $(ui.item.option).parent().data('type');
		var id = $(ui.item.option).val();
        var templateIndex = $(ui.item.option).data('index');
        // Add query filters
        addQueryFilters(type, id, templateIndex);
        // Determine if message can be removed
        if(query.templates.length > 0) { $('div.error-message').empty(); }
		// Add filter to ui
        var html = $('<li>')
            .addClass('filter filter-green')
            .html(id)
            .prepend(
                $('<a>').addClass('close')
                    .attr('data-dismiss', 'filter')
                    .html('x')
            )
            .attr('data-id', id)
            .attr('data-type', type);
        if(type === 'template') { html.attr('data-index', templateIndex); }
        $(this.element.data('target')).append(html);
	}

	/**
	 * @param targetSelector
	 * @param request
	 * @param response
	 */
	function sourceHelper(selectedFilters, request, response) {
		var matcher = new RegExp($.ui.autocomplete.escapeRegex(request.term), 'i');
		// Set initial available options
		var availableOptions = this.element.children('option');
		// Create array which will store filtered available options
		var results = new Array();
		// Filter out available options that have already been added to the list of filters
		$.each(availableOptions, function(optionsIndex, optionsValue) {
			$(selectedFilters).each(function(filterIndex, filterValue) {
				if($(optionsValue).val() == $(filterValue).data('id') || $(optionsValue).val() == '') {	
					delete availableOptions[optionsIndex];
				}
			});
			if(availableOptions[optionsIndex] !== undefined) {
                results.push(optionsValue)
            }
		})
		// Confirm there are results to display
		//if(typeof results != undefined && results.length > 0) {
			response($(results).map(function() {
				var text = $(this).text();
				if (this.value && (!request.term || matcher.test(text))) {
					return {
						label: text,
						value: text,
						option: this
					};
				} 
			}));
		//} else {
		//	response(new Object({'label': 'No results found.'}));
		//}
	}

	function generateNestedAttributeAnswer() {
		// Obtain a reference to the answer/attribute key and value
		var type = $(this).data('type');
        var key = $(this).data('key');
        var value = $(this).val();
        // Validate blank key
        if(!value) {
            alert('Enter Value!');
            return false;
        }

        // Obtain a reference to the value list (IE list of values for a given answer/attribute)
        var list = $('ul[data-type="'+type+'"][data-key="'+key+'"]');
        // If this is the first time a value has been added for this answer/attribute
        if(list.size() == 0) {
            // Create the list of answer/attribute values 
            // Note: data doesn't work with uls
            list = $('<ul>').addClass('filters')
                .attr('data-type', type)
                .attr('data-key', key);
            // Create the container (which includes the label and list of values)
            $($(this).data('target')).prepend(
                $('<li>')
                    .append($('<span>').html(key + '&#58;'))
                    .append(list));
        }

        // Check if filter value has been added to this answer/attribute before
        var isUniqueValue = true;
        list.find('li').each(function(index, li) {
            if($(li).data('value') === value) {
                isUniqueValue = false;
                return false; 
            }
        });
        // If this is a unique value
        if(isUniqueValue) {
            // Add filter to search state
            if ($(this).data('type') === 'templateFilters') {
                addTemplateFilter(key, value);
            } else if (type === 'answerFilters') {
                addAnswer(key, value);
            } else if ($(this).data('type') === 'attributeFilters') {
                addAttribute(key, value);
            } else {
                throw "Unexpected type: " + $(this).parent().data('type');
            }

            // Append the value pillbox to the list
            list.append(
                $('<li>')
                    .addClass('filter filter-green')
                    .html($(this).val())
                    .prepend(
                        $('<a>').addClass('close')
                            .attr('data-dismiss', 'filter')
                            .html('x')
                    )
                    .attr('data-type', type)
                    .attr('data-key', key)
                    .attr('data-value', value)
            );
            // Clear input
            $(this).val('');
        }
	}

    function listQueryHtmlFilters(selector, query) {
    $.each(query, function(type, value) {
        if(type === 'templates') {
            $.each(value, function(index, id) {
                selector.append(
                    $('<li>')
                        .addClass('filter filter-green')
                        .append(
                            $('<span>').append('Template')
                                .append(':&nbsp;')
                        )
                        .append(id)
                        .prepend(
                            $('<a>').addClass('close')
                                .attr('data-dismiss', 'filter')
                                .html('x')
                        )
                        .attr('data-type', 'template')
                        .attr('data-id', id)
                        .attr('data-index', index)
                );
            });
        } else if(type === 'fields') {
            $.each(value, function(type, value) {
                $.each(value, function(index, id) {
                    selector.append(
                        $('<li>')
                            .addClass('filter filter-green')
                            .append(
                                $('<span>').append(type)
                                    .append(':&nbsp;')
                            )
                            .append(id)
                            .prepend(
                                $('<a>').addClass('close')
                                    .attr('data-dismiss', 'filter')
                                    .html('x')
                            )
                            .attr('data-type', type)
                            .attr('data-id', id)
                    );
                });
            });
        } else if(type === 'answerFilters' || type === 'attributeFilters' || type === 'templateFilters') {
            $.each(value, function(key, value) {
                $.each(value, function(index, value) {
                    selector.append(
                        $('<li>')
                            .addClass('filter filter-green')
                            .append(
                                $('<span>').append(key)
                                    .append(':&nbsp;')
                            )
                            .append(value)
                            .prepend(
                                $('<a>').addClass('close')
                                    .attr('data-dismiss', 'filter')
                                    .html('x')
                            )
                            .attr('data-type', type)
                            .attr('data-key', key)
                            .attr('data-value', value)
                    );
                });
            });
        }
    });
    selector.show();
}
});