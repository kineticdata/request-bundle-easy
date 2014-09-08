$(document).ready(function() {
    $('nav ul.nav li.root a.a-z').addClass('nav-hover');
    // Define selectors
    var subCategories = '#alpha';
    // Call functions
    $('ul#alpha > li').tsort({attr:'title'});
    initializeAlphabeticalNavigation(subCategories, true);
});

/**
 * @param ulSelector string
 * @param includeAll boolean
 */
function initializeAlphabeticalNavigation(ulSelector, includeAll) {
    $(ulSelector+'-nav').empty();
    $(ulSelector).listnav({
        includeAll: includeAll,
        noMatchText: '<div id="listNavCustomError" class="message alert alert-error"><a class="close" data-dismiss="alert">x</a> There are no matching entries.</div>',
        showCounts: false,
        onClick: function(letter) {
            $('#listNavCustomError').show();
        }
    });
}