$(function() {
    // Show last modified time in the from now format
    $('span.modified').text(moment($('span.modified').text()).fromNow());
    // qTip
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
    // Modify header to show
    $('span.service-item-details').css({'display': 'inline-block'});
});