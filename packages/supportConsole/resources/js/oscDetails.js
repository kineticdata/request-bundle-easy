$(function() {
    var params = getUrlParameters();

    BUNDLE.ajax({
        url: BUNDLE.config.apiPath+"/requests/"+params.id+"?include=attributes,answers,request-items",
        success: function(response) {
            submission = response.data;
            // Build the header section
            var headerSection = $('<div>');
            var container = $('section.container');
            // Build the header section
            if (submission === null) {
                headerSection.append($('<h1>').html(params.id+" Not Found"));
                container.append(headerSection);
            } else {
                headerSection.append($('<h1>').html(submission["Template Name"] + " -- " + submission["Id"]))
                    .append('<hr class="soften">');
                // Append the header section
                container.append(headerSection);
                
                // Build the fields section
                var fields = ['Catalog Name', 'Template Name', 'Id', 'Created At', 'Requested By', 'Requested For', 'Status', 'Display Status'];
                var fieldsSection = $('<div class="fields">');
                $.each(fields, function(index, field) {
                    if (submission[field]) {
                        fieldsSection.append($('<div class="clearfix">')
                            .append($('<label>').html(field))
                            .append($('<div class="value">').html(((field === 'Created At') ? moment(submission[field]).format('YYYY-MM-DD hh:mm:ss a') : submission[field]))));
                    }
                });

                // Append the fields section
                container.append(fieldsSection)

                // If there are any related request items
                if (submission['Request Items'].length > 0) {
                    // Build the request item section
                    var requestItemSection = $('<div class="request-items">');
                    $.each(submission['Request Items'], function(index, value) {
                        requestItemSection.append($('<div class="clearfix">')
                            .append($('<label>').html(value['Template Name']))
                            .append($('<div class="value">').html(value['Id'])));
                    });

                    // Append the attributes header and section
                    container.append($('<h2>').html("Request Items"))
                        .append(requestItemSection)
                }

                // If there are any attributes
                if (!$.isEmptyObject(submission['Attributes'])) {
                    // Build the attributes section
                    var attributesSection = $('<div class="attributes">');
                    $.each(submission['Attributes'], function(index, attribute) {
                        var name = attribute['Name'];
                        var value = attribute['Value'];
                        attributesSection.append($('<div class="clearfix">')
                            .append($('<label>').html(name))
                            .append($('<div class="value">').html(value)));
                    });

                    // Append the attributes header and section
                    container.append($('<h2>').html("Attributes"))
                        .append(attributesSection)
                }
                
                // If there are any answers
                if (!$.isEmptyObject(submission['Answers'])) {
                    // Build the answers section
                    var answersSection = $('<div class="answers">');
                    $.each(submission['Answers'], function(index, answer) {
                        var name = answer['Name'];
                        var value = answer['Value'];
                        answersSection.append($('<div class="clearfix">')
                            .append($('<label>').html(name))
                            .append($('<div class="value">').html(value)));
                    });

                    // Append the answer header and section
                    container.append($('<h2>').html("Answers"))
                        .append(answersSection);
                }
            }

            $('body').show();
        }
    });
});