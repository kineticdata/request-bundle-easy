$(function() {

    $('#side-menu').metisMenu();
    $('div.category.panel').on('click', function(){
        if($(this).data('id') === "My Requests"){
            window.location = BUNDLE.config.submissionsUrl;
        }
        else if($(this).data('id') === "My Approvals"){
            window.location = BUNDLE.config.approvalsUrl;
        }
        else {
            var cat = $(this).data('id');
            window.location = BUNDLE.config.categoryUrl + '&category=' + cat;
        }
    });
    
    $('a.dropdown-toggle').on('click', function(){
        console.log('clicked');
        $(this).parent().toggleClass('open');
    });
});

//Loads the correct sidebar on window load,
//collapses the sidebar on window resize.
// Sets the min-height of #page-wrapper to window size
$(function() {
    $(window).bind("load resize", function() {
        topOffset = 50;
        width = (this.window.innerWidth > 0) ? this.window.innerWidth : this.screen.width;
        if (width < 768) {
            $('div.navbar-collapse').addClass('collapse')
            topOffset = 100; // 2-row-menu
        } else {
            $('div.navbar-collapse').removeClass('collapse')
        }

        height = (this.window.innerHeight > 0) ? this.window.innerHeight : this.screen.height;
        height = height - topOffset;
        if (height < 1) height = 1;
        if (height > topOffset) {
            $("#page-wrapper").css("min-height", (height) + "px");
        }
    })
})
