$(function() {
    $(window).hashchange(function(event) {
        console.log(window.location.hash.substring(1))
    });
    // Set some states
    $('ul li.catalog').addClass('active').append($('<div>').addClass('arrow-left'));
    $('ul.categories').append($('ul.root-category-data').html());

    // Selectors that are used quite a bit
    var breadcrumbs = 'nav.catalog ul.breadcrumbs';
    var templates = 'nav.catalog ul.templates';
    var templateDetails = 'nav.catalog div.template-details';
    var categories = 'nav.catalog ul.categories';
    
    // Click event for menus
    $(categories).on('click', 'li', function(event) {
        event.preventDefault();
        // Get current clicked category id and name
        var categoryId =  $(this).data('id');
        var categoryName =  $(this).data('name');
        // Find category's children and get the html
        var currentSubcategories = $('ul.category-data li[data-id=' + categoryId + ']').find('ul.subcategory-data').html();
        // Display the category's children if not undefined
        currentSubcategories !== undefined ? $(categories).html(currentSubcategories) : $(categories).empty();
        // Find category's templates and get the html
        var currentTemplates = $('ul.category-data li[data-id=' + categoryId + ']').find('ul.template-data').html();
        // Display the category's templates into div
        currentTemplates !== undefined ? $(templates).html(currentTemplates) : $(templates).empty();
        // Create new bread crumb with the category's information
        $(breadcrumbs).append(
            $('<li>').attr('data-id', $(this).data('id'))
                .attr('data-name', $(this).data('name'))
                .append($(this).data('name'))
                .append(
                    $('<i>').addClass('fa fa-chevron-circle-left')
                )
        ).show();
        // Update hash
        window.location.hash = categoryName;
    });
    // Click event for template details
    $(templates).on('click', 'li', function(event) {
        event.preventDefault();
        var templateName =  $(this).data('name');
        // Clean up
        $(templates).empty();
        $(categories).empty();
        // Show details
        $(templateDetails).html($(this).find('div.template-details-data').html());
        // Create new bread crumb with the template's information
        $(breadcrumbs).append(
            $('<li>').attr('data-id', $(this).data('id'))
                .attr('data-name', $(this).data('name'))
                .append($(this).data('name'))
                .append(
                    $('<i>').addClass('fa fa-chevron-circle-left')
                )
        ).show();
    });
    
    // Click event for breadcrumbs
    $(breadcrumbs).on('click', 'li', function(event) {
        event.preventDefault();
        $(templateDetails).empty();
        // Get previous id
        var previousCategoryId = $(this).prev().data('id');
        // Check if root bread crumb is selected or prev undefined
        if(previousCategoryId === 'root' || previousCategoryId === undefined) {
            $(categories).html($('ul.root-category-data').html());
            $(templates).empty();
            if(previousCategoryId !== undefined) {
                $(this).remove();
            }  
        } else {
            var currentSubcategories = $('ul.category-data li[data-id=' + previousCategoryId + ']').find('ul.subcategory-data').html();
            // Display the category's children if not undefined
            currentSubcategories !== undefined ? $(categories).html(currentSubcategories) : $(categories).empty();
            var currentTemplates = $('ul.category-data li[data-id=' + previousCategoryId + ']').find('ul.template-data').html();
            // Display the category's templates into div
            currentTemplates !== undefined ? $(templates).html(currentTemplates) : $(templates).empty();
            // Remove current breadcrumb
            $(this).remove();
        }
    });
});

$(document).ready(function() {
    // Using default configuration
    //$('#carousel').carouFredSel();
	$('#carousel').carouFredSel({
		items : {
			visible			: 1,
			width			: 730
		},
        direction           : "left",
        scroll : {
            pauseOnHover	: true,
			items           : 1,
            easing          : "linear",
            duration        : 500,                         
            pauseOnHover    : true
        },
		auto : {
		    play			: false
		}
    });
});