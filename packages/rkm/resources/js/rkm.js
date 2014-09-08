$(document).ready(function() {
    // Here we set the focus to the input box that gathers the search terms
    $("#rkmSearch").focus();
    
    // On submit of the search terms form we call the RKMQuery jsp which returns
    // a json result that represents the matching articles.  We use this json
    // result to generate an html table.  Each row in the table has a clicked
    // handler bound to it that retrieves the article (defined below).
    $("form.knowledge-search").on('submit', function(event){
        event.preventDefault();
        event.stopImmediatePropagation();
        getArticles($('#rkmSearch').val());
    });
    $(".knowledge-search button.fa-search").on("click",function(event) {
        event.preventDefault();
        event.stopImmediatePropagation();
        getArticles($('#rkmSearch').val());
    });

});

function getArticles(searchTerm){

    // This object maps the source type returned by the multi query jsp to a
    // camel-case version used in css classes and jsp names.
    var rkmSourceMap = {
        "Decision Tree": "decisionTree",
        "How To": "howTo",
        "Known Error": "knownError",
        "Problem Solution": "problemSolution",
        "Reference": "reference"
    };

    $('.portlet-content.rkm li.message').remove();
    if ( searchTerm === "" ) {
        $(".portlet-content.rkm").append('<li class="clearfix message"><div class="summary">Please enter search terms</div></li>');
    } else {
        BUNDLE.ajax({
            url: BUNDLE.packagePath + "../rkm/interface/callbacks/RKMQuery.json.jsp?mustHave="+searchTerm,
            beforeSend: function(){
                $(".portlet-content.rkm").empty();
				$(".portlet-content.rkm").append('<li id="loader" class="clearfix"><div class="summary"><img src="'+BUNDLE.bundlePath+'common/resources/images/spinner.gif" /></div></li>');
            },
            success: function(data) {
                $('#loader').remove();
                var results = $.parseJSON(data);
                if(results.length > 0){
                    for (var i in results) {
                        var resultDiv = $('<li class="clearfix"></li>');
                        resultDiv.data("article-id", results[i]["Article ID"]);
						resultDiv.data("article-type", rkmSourceMap[results[i]["Source"]]);
                        resultDiv.append('<div class="summary"><a href="javascript: void(0);">' + results[i]["Article Title"] + 
                            '</a><p>' + results[i]["Summary"] + '</p></div>' +
                            '<div class="status" title="' + results[i]["Created Date"] + '">' +
                            results[i]["Created Ago"] + ' ago</div>' +
							'<div class="article-content"></div>');
                        $(".portlet-content.rkm").append(resultDiv).show();
                    }
					$(".portlet-content.rkm > li > div.summary > a").click(toggleArticle);
                }
                else {
                    $(".portlet-content.rkm").append('<li class="clearfix message"><div class="summary">No articles found.</div></li>').show();
                }
            },
            error: function(data) {
                $(".portlet-content.rkm").append('<li class="clearfix message"><div class="summary">An error occured during the search</div></li>').show();
            }
        });
    }
    return false;
}
function toggleArticle() {
    // Retrieve the result dom element that this link refers to.
    var resultDiv = $(this).parent().parent();
    
    // Retrieve parameters used in the call from data attributes of the clicked
    // dom element.
    var articleType = resultDiv.data("article-type");
    var articleId = resultDiv.data("article-id");

    // If the article has not been retrieve do an ajax call to retrieve the
    // article partial and append it to the result div, then show it.  Otherwise
    // we simple show the article that is already there.
    if ( resultDiv.find(".article").length === 0 ) {
        BUNDLE.ajax({
            url: BUNDLE.packagePath + "interface/callbacks/" + articleType + '.html.jsp',
            data: { articleId: articleId },
            success: function(data) {
                resultDiv.find(".article-content").append(data);
                var articleButtons = $('<div class="buttons"></div>');
                var commentUrl = BUNDLE.config["commentUrl"] + "&id=" + articleId;
                var commentAnchor = $('<a href="' + commentUrl + '"></a>');
                var commentButton = $('<img alt="Comment" class="button comment" src="' +
                    BUNDLE.packagePath + 'resources/images/comments.png"/ title="Comment">');
                commentAnchor.append(commentButton)
                articleButtons.append(commentAnchor);
                var useButton = $('<img alt="Use" class="button use" src="' +
                    BUNDLE.packagePath +'resources/images/blog_accept.png"/ title="Use">');
                var useMessage = $('<span class="hidden">Feedback submitted</span>');
                useButton.click(function() {
                    BUNDLE.ajax({
                       url: BUNDLE.packagePath + 'interface/callbacks/incrementRelevance.jsp',
                       data: {
                           articleId: $(this).parents("#results .result").data("article-id")
                       },
                       success: function(data) {
                           $(useButton).fadeOut(function() {
                               $(useMessage).fadeIn();
                           });
                       }
                   }) 
                });
				
				$(resultDiv).find("img").each(function(){
						
						var src = "DownloadAttachment/" 
						+ $(this).attr("arschema") 
						+ "/" 
						+ $(this).attr("arattid") 
						+ "/"
						+ $(this).attr("arentryid");
						  $(this).attr("src", src);
				});
				
                articleButtons.append(useButton);
                articleButtons.append(useMessage);
                resultDiv.find(".article").append(articleButtons);
                //resultDiv.find(".article").slideToggle();
                //resultDiv.find(".title .sprite").toggle();

            }
        });
    } else {
        resultDiv.find(".article").slideToggle();
        resultDiv.find(".title .sprite").toggle();
    }
}