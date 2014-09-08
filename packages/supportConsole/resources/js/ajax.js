var loadedTemplates;
var selectedTemplates = []; // TODO: Refactor this into query['templates'] ?
var matchingTemplates = []; // TODO: Make this a function that processes query['templateFilters']?

// This is an example query structure that will modified by adding/removing filters.
// When search is clicked this structure will be converted to a query to the request api
// and the results will be displayed.
var query = {
    createdWithin: "Past Week",
    updatedWithin: "Anytime",
    order: {
        'field': 'Updated At',
        'sortOrder': 'DESC'
    },
    categories: [],
    templates: [],
    fields: {
        "Requested By": [],
        "Requested For": [],
        "Status": [],
        "Display Status": []
    },
    answerFilters: {},
    attributeFilters: {},
    templateFilters: {},
    metadata: {}
}

function getAllTemplateAttributes() {
    // Array of template attribute names
    var resultArray = [];
    // Map used to ensure the same attribute is not added to the result array multiple times
    var resultSet = {};
    // For each template
    $.each(loadedTemplates, function(index, template) {
        // For each of the templates attributes
        $.each(template['Attributes'], function(index, attribute) {
            if (!(attribute['Name'] in resultSet)) {
                resultArray.push(attribute['Name']);
                resultSet[attribute['Name']] = true;
            }
        });
    });
    // Sort the array
    resultArray.sort();
    // Return the array
    return resultArray;
}

function getAllTemplateAttributeValues(attributeName) {
    // Array of template attribute names
    var resultArray = [];
    // Map used to ensure the same attribute is not added to the result array multiple times
    var resultSet = {};
    // For each template
    $.each(loadedTemplates, function(index, template) {
        // For each of the templates attributes
        $.each(template['Attributes'], function(index, attribute) {
            if (attribute['Name'] === attributeName) {
                // If the attribute is of type Multiple
                if ($.isArray(attribute['Value'])) {
                    // For each of the values
                    $.each(attribute['Value'], function(index, value) {
                        // If the value is not in the result set
                        if (!(attribute['Value'] in resultSet)) {
                            resultArray.push(attribute['Value']);    
                            resultSet[attribute['Value']] = true;
                        }
                    });
                }
                // If the attribute is of type Single, and the value is not in the result set
                else if (!(attribute['Value'] in resultSet)) {
                    resultArray.push(attribute['Value']);    
                    resultSet[attribute['Value']] = true;
                }
            }
        });
    });
    // Sort the array
    resultArray.sort();
    // Return the array
    return resultArray;
}

function getTemplateAttributeValues(templateId, attributeName) {
    var values = [];
    $.each(loadedTemplates, function(index, template) {
        if (template['Id'] === templateId) {
            $.each(template['Attributes'], function(index, attribute) {
                if (attribute['Name'] === attributeName) {
                    if ($.isArray(attribute['Value'])) {
                        values = values.concat(attribute['Value']);
                    } else {
                        values.push(attribute['Value']);    
                    }
                }
            });
        }
    });
    return values;
}

function filterTemplates() {
    // Clear the matching templates
    matchingTemplates = [];
    // For each template
    $.each(loadedTemplates, function(index, template) {
        var matches = true;
        // For each filter
        $.each(query['templateFilters'], function(attributeName, values) {
            var matchesFilter = false;
            // For each filter value
            $.each(values, function(index, filterValue) {
                var hasMatchingAttributeValue = false;
                // For each template attribute value
                $.each(getTemplateAttributeValues(template['Id'], attributeName), function(index, value) {
                    if (filterValue === value) { hasMatchingAttributeValue = true; }
                });
                // If there was a matching attribute value
                if (hasMatchingAttributeValue) { matchesFilter = true; }
            });
            // If there was a matching filter value
            if (!matchesFilter) { matches = false; }
        });
        // Add the template to the templates array
        if (matches) { matchingTemplates.push(template['Name']); }
    });

    // Clear the existing options from the templates select
    var select = $("p.templates select").empty();
    // Set the templates select options
    $.each(matchingTemplates, function(index, templateName) {
        var templateIndex = 0;
        $.each(loadedTemplates, function(index, template) {
            if (template['Name'] === templateName) {
                templateName + "("+templateIndex+")";
                templateIndex = index;
                return false;
            }
        });
        var option = $('<option value="' + templateName + '">' + templateName + '</option>')
            .data('index', templateIndex);
        select.append(option);
    })
}

function addTemplateFilter(attribute, value) {
    if ( query["templateFilters"][attribute] === undefined ) {
        query["templateFilters"][attribute] = [];
    }
    query["templateFilters"][attribute].push(value);
    filterTemplates();
}
function removeTemplateFilter(attribute, value) {
    var index = query["templateFilters"][attribute].indexOf(value);
    query["templateFilters"][attribute].splice(index, 1);
    if (query['templateFilters'][attribute].length == 0) {
        delete query['templateFilters'][attribute];
    }
    filterTemplates();
}

// Functions for adding/removing filters from the query structure.
function addCategory(category) {
    query.categories.push(category);
}
function removeCategory(category) {
    var index = query.categories.indexOf(category);
    query.categories.splice(index, 1);
}
function addTemplate(template) {
    query.templates.push(template);
}
function removeTemplate(template) {
    var index = query.templates.indexOf(template);
    query.templates.splice(index, 1);
}
function addField(field, value) {
    query.fields[field].push(value);
}
function removeField(field, value) {
    var index = query.fields[field].indexOf(value);
    query.fields[field].splice(index, 1);
}
function addAnswer(question, value) {
    if ( query["answerFilters"][question] === undefined ) {
        query["answerFilters"][question] = [];
    }
    query["answerFilters"][question].push(value);
}
function removeAnswer(question, value) {
    var index = query["answerFilters"][question].indexOf(value);
    query["answerFilters"][question].splice(index, 1);
    if (query['answerFilters'][question].length == 0) {
        delete query['answerFilters'][question];
    }
}
function addAttribute(name, value) {
    if ( query["attributeFilters"][name] === undefined ) {
        query["attributeFilters"][name] = [];
    }
    query["attributeFilters"][name].push(value);
}
function removeAttribute(name, value) {
    var index = query["attributeFilters"][name].indexOf(value);
    query["attributeFilters"][name].splice(index, 1);
    if (query['attributeFilters'][name].length == 0) {
        delete query['attributeFilters'][name];
    }
}
function setMetadata(field, value) {
    query.metadata[field] = value;
}
function setOrder(field, sortOrder) {
    query.order.field = field;
    query.order.sortOrder = sortOrder;
}

// TODO: Change 'Modified At' to 'Completed At' once implemented
function buildQueryData(query) {
    var expressions = [
        "'Catalog Name' = \""+BUNDLE.config.oscCatalogName+"\""
    ];

    // Add the create date range expressions
    if (query.createdWithin === "Anytime") {} // Do Nothing
    else if (query.createdWithin === "Custom") {
        throw "Not implemented.";
    }
    else {
        expressions.push("'Created At' > \""+generatePastDate(query.createdWithin)+"\"");
    }

    // Add the create date range expressions
    if (query.updatedWithin === "Anytime") {} // Do Nothing
    else if (query.updatedWithin === "Custom") {
        throw "Not implemented.";
    }
    else {
        expressions.push("'Updated At' > \""+generatePastDate(query.updatedWithin)+"\"");
    }

    // Add the field expressions
    $.each(query.fields, function(key, values) {
        if (values && values.length > 0) {
            var valueStrings = $.map(values, function(value) {
                return '"'+value.replace(/"/g, "\\\"")+'"';
            });
            expressions.push("'"+key.replace(/'/g, "\\'")+"' IN ("+valueStrings.join(",")+")");
        }
    });

    // Determine which list of templates to use
    var templates = query.templates.length > 0 ? query.templates : matchingTemplates;
    // Build the list of template ids
    var templateIds = templateIds = $.map(templates, function(templateName) {
        var templateId;
        $.each(loadedTemplates, function(index, template) {
            if (template["Name"] === templateName) {templateId = template["Id"];}
        });
        return templateId;
    });

    // Build the data, in the format of:
    //   {
    //      q: EXPRESSION,
    //      filter-answer: [FILTERS],
    //      filter-attributes: [FILTERS],
    //      filter-templates: [TEMPLATE_IDS],
    //   }
    var data = {
        "q": expressions.join(" AND "),
        "filter-answer": $.map(query.answerFilters, function(values, key) {
            var valueStrings = $.map(values, function(value) {
                return '"'+value.replace(/"/g, "\\\"")+'"';
            });
            return "'"+key.replace(/'/g, "\\'")+"' IN ("+valueStrings.join(",")+")";
        }),
        "filter-attribute": $.map(query.attributeFilters, function(values, key) {
            var valueStrings = $.map(values, function(value) {
                return '"'+value.replace(/"/g, "\\\"")+'"';
            });
            return "'"+key.replace(/'/g, "\\'")+"' IN ("+valueStrings.join(",")+")";
        }),
        "filter-template": templateIds,
        "order": "'" + query.order.field + "':" + query.order.sortOrder + ""
    }

    // Build metadata
    $.each(query.metadata, function(key, value) {
        return data[key] = value;
    });

    return data;
}

function loadTemplates(options) {
    var qual = encodeURIComponent(BUNDLE.config.oscTemplateFilter);

    BUNDLE.ajax({
        url: BUNDLE.config.apiPath+"/templates?q="+qual+"&include=attributes,dataset,questions&order='Name':ASC",
        success: function(response) {
            // Set the response to a variable that is made available to other functions.
            loadedTemplates = response.data;
            // Clear the existing options from the templates select
            var select = $("p.templates select").empty();
            // Iterate through the templates in the response attaching a new option
            // to the select element for each one.
            $.each(loadedTemplates, function(index, template) {
                var option = $('<option value="' + template["Name"] + '">' + template["Name"] + '</option>')
                    .data('index', index);
                select.append(option);
            })

            // Set the template filter select options
            var templateAttributeSelect = $("p.template-attributes select").empty();
            $.each(getAllTemplateAttributes(), function(index, attribute) {
                templateAttributeSelect.append('<option value="' + attribute + '">' + attribute + '</option>');
            });
        }
    });
}

function selectTemplate(selectedIndex) {
    selectedTemplates.push(selectedIndex);
    drawOptions();
}

function unselectTemplate(selectedIndex) {
    var index = selectedTemplates.indexOf(selectedIndex);
    selectedTemplates.splice(index, 1);
    drawOptions();
}

function drawOptions() {
    var answerSelect = $("p.answers select").empty();
    $.each(getIntersection("Questions"), function(index, questionName) {
        answerSelect.append('<option value="' + questionName + '">' + questionName + '</option>');
    });
    var attributeSelect = $("p.attributes select").empty();
    $.each(getIntersection("Dataset"), function(index, attributeName) {
        attributeSelect.append('<option value="' + attributeName + '">' + attributeName + '</option>');
    });
}

function getIntersection(attributeName) {
    var currentIntersection = [];
    var nextIntersection = [];
    $.each(selectedTemplates, function(index, templateIndex) {
        var template = loadedTemplates[templateIndex];
        if (index === 0) {
            $.each(template[attributeName], function(i, attribute) {
                if (attribute['Transient'] !== 'Yes') { nextIntersection.push(attribute["Name"]); }
            });
        } else {
            nextIntersection = [];
            $.each(template[attributeName], function(i, attribute) {
                if (attribute['Transient'] !== 'Yes' && currentIntersection.indexOf(attribute["Name"]) > -1) {
                    nextIntersection.push(attribute["Name"]);
                }
            });
        }
        currentIntersection = nextIntersection.slice();
    });
    return currentIntersection;
}

function openRequest(requestId) {
    // If the requestId does not start with "KSR", prepend it
    var ksr = requestId.indexOf("KSR") !== 0 ? "KSR"+requestId : requestId;

    // If the ksr number is not the full 15 characters
    if (requestId.length < 15) {
        // Determine the number of zeros to pad (use 12 because KSR takes 3 characters)
        var pad = 12-requestId.length;
        // Build the string of zeros (add one because join puts the argument between elements)
        var zeroes = Array(pad+1).join("0");
        // Insert the zeroes after the "KSR" prefix
        ksr = "KSR"+zeroes+ksr.slice(3);

    }

    // Open the window
    window.open(BUNDLE.config['submissionDetailsUrl']+'&id=' + ksr);
}

// Call the loadTemplates function on document ready.
$(function() {
    loadTemplates();  
});