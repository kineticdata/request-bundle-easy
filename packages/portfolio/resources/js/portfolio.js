$(function() {
    // Vars
    var loader = $('div#loader');

    // Reset select menu on page load
    $('select[name="attributes"]').prop('selectedIndex', 0);

    // Format date time for modified
    var modified = new Object();
    $('ul.default li span.modified').each(function() { 
        var fromNow = moment($(this).data('value')).fromNow();
        var seconds = moment($(this).data('value')).format('X');
        // Build modified object based on all available dates
        modified[fromNow] = seconds;
        $(this).attr('data-from', fromNow);
    });

    // Build modified value options select based on option object
    $.each(modified, function(index,value) {
        var count = $('ul.default li span[data-from="' + index + '"]').length;
        $('select[name="modified-date"]').append(
            $('<option>').val(index)
                .text(index + ' (' + count + ')')
                .attr('data-sort', value) /* data doesn't work on options */
        );
        // Sort options by seconds
        $('select[name="modified-date"] > option').tsort('',{order:'desc', attr:'data-sort'});
    });

    // qTip for date time
    var qtipOptions = {
        content: {
            attr: 'data-value'
        },
        style: {
            corner: 'bottom left',
            classes: 'ui-tooltip-tipsy ui-tooltip-shadow'
        },
        position: {
            my: 'bottom center',
            at: 'middle'
        }
    };
    $('span.modified').qtip(qtipOptions);

    // Format times
    $('ul.templates li span.modified').each(function() { 
        $(this).text(moment($(this).data('value')).fromNow());
        $(this).data('value', moment($(this).data('value')).format('X'));
    });

    // Modified date filter
    $('select.modified-date').on('change', function(event) {
        var target = $(this).find(':selected').data('target');
        var targetHide = $(this).find(':selected').data('target-hide');
        $(targetHide).hide();
        $(target).show();
    });

    // Time ago filter
    $('select[name="modified-date"]').on('change', function(event) {
        var selectDateValue = $(this).find(':selected').val();
        var target = $(this).data('target');
        var targetHide = $(this).data('target-hide');
        var targetShow = $(this).data('target-show');
        var targetSort = $(this).data('target-sort');        
        $(targetHide).hide();
        // Build new list to prevent border top with first child
        var ul = $('<ul>');
        $(target + ' li').each(function() {
            var modified = $(this).find('span.modified').data('from');
            if(modified === selectDateValue) {
                ul.append($(this).clone());
            }
        });
        // Sort
        var sortOrder = $(this).data('order');
        var options = {data:'value', order:sortOrder};
        ul.tsort(targetSort,options);
        // Show
        $(targetShow).html(ul.html()).show();
        $(targetShow).find('span.modified').qtip(qtipOptions);
    });

    // Search input
    if(getUrlParameters()['q'] && getUrlParameters()['q'] !== ''){
        $('input[name="q"]').val(decodeURI(getUrlParameters()['q']).replace(/\+/g,' '));
        $(this).find('button.fa').toggleClass('fa-search fa-times');
    }
    $('form.catalog-search').submit(function(event){
        if($('button[type="submit"].fa').hasClass('fa-times')){
            $('input[name="q"]').val('');
        }
    });
    $('input[name="q"]').on('keydown keypress keyup',function() {
        if($('input[name="q"]').val() === ""){
            $('form.catalog-search button.fa').removeClass('fa-times').addClass('fa-search');
        }
        else if($('input[name="q"]').val() !== decodeURI(getUrlParameters()['q']).replace(/\+/g,' ')){
            $('form.catalog-search button.fa').removeClass('fa-times').addClass('fa-search');
        }
    });

    // Sort attributes
    $('select[name="attributes"] > option').tsort('',{order:'asc', attr:'value'});
    // Attribute filter
    $('select[name="attributes"]').on('change', function(event) {
        // Start all previous attribute value selects from the top
        $('select.attribute-values').find('option:first').attr('selected','selected');
        var target = $(this).find(':selected').data('target');
        var targetHide = $(this).data('target-hide');
        $(targetHide).hide();
        $(target).show();
        $('h2.response').text($(this).find(':selected').val());
    });

    // Attribute value filter
    $('select.attribute-values').on('change', function(event) {
        var target = $(this).find(':selected').data('target');
        var targetHide = $(this).find(':selected').data('target-hide');
        $(targetHide).hide();
        $(target).show();
    });

    /*
    var subtractDates = {
        'hours': 6,
        'days': 1,
        'weeks': 1,
        'months': 1,
        'years': 1
    }
    $.each(subtractDates, function(index,value) {
        var timeAgo = moment().subtract(index, value).format('X');
        var fromNow = moment().subtract(index, value).fromNow();
        $('select[name="modified-date"]').append(
            $('<option>').val(timeAgo)
                .text(fromNow)
        );
    });

    // Modified date filter
    $('select.modified-date').on('change', function(event) {
        var target = $(this).find(':selected').data('target');
        var targetHide = $(this).find(':selected').data('target-hide');
        $(targetHide).hide();
        $(target).show();
    });

    // Time ago filter
    $('select[name="modified-date"]').on('change', function(event) {
        var selectDateValue = $(this).find(':selected').val();
        var targetHide = $(this).data('target-hide');
        var targetShow = $(this).data('target-show');
        var targetSort = $(this).data('target-sort');        
        $(targetHide).hide();
        $(targetShow + ' li').each(function() {
            var modified = $(this).find('span.modified').data('value');
            if(modified < selectDateValue) {
                $(this).hide();
            } else {
                $(this).show();
            }
        });
        // Sort
        var sortOrder = $(this).data('order');
        var options = {data:'value', order:sortOrder};
        $(targetShow + ' > li').tsort(targetSort,options);
        $(targetShow).show();
    });
    */
});