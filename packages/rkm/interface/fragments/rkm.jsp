<%-- Set the page content type, ensuring that UTF-8 is used. --%>
<%@page contentType="text/html; charset=UTF-8"%>

<%-- Include the package initialization file. --%>
<%@include file="framework/includes/packageInitialization.jspf"%>

<!DOCTYPE html>
<html>
    <head>
        <meta charset="utf-8">
        <%-- Include the common content. --%>
        <%@include file="../../common/interface/fragments/head.jspf"%>

        <title><%= bundle.getProperty("companyName")%> Knowledge Management Search"</title>

        <%-- Include the application head content. --%>
        <%@include file="../../core/interface/fragments/applicationHeadContent.jspf"%>
        <%@include file="../../core/interface/fragments/displayHeadContent.jspf"%>

        <!-- Page Stylesheets -->
        <link rel="stylesheet" href="<%= bundle.packagePath()%>resources/css/rkm.css" type="text/css" />
        <!-- Language Javascript -->
        <script type="text/javascript" src="<%=bundle.bundlePath()%>common/resources/js/languageChange.js"></script>
        <!-- Page Javascript -->
        <script type="text/javascript" src="<%=bundle.packagePath()%>resources/js/rkm.js"></script>
    </head>

    <body>
        <div class="view-port">
            <%@include file="../../common/interface/fragments/navigationSlide.jspf"%>
            <div class="content-slide" data-target="div.navigation-slide">
                <%@include file="../../common/interface/fragments/header.jspf"%>
                <div class="pointer-events">
                    <%@include file="../../common/interface/fragments/flyout.jspf" %>
                    <section class="container">
                        <ul class="portlets unstyled">
                            <li class="border-top col-sm-6 wide" style="clear: left;">
                                <div class="content-wrap"> 
                                    <div class="description-wide">
                                        <h3><div class="title">Search</div> <i class="fa fa-question"></i></h3>
                                        <p class="uppercase">Enter Key Word, Product or Search Topic</p>
                                        <p class="knowledge-search">
                                            <input id="rkmSearch" class="form-control" type="search" name="q" value="" autofocus="autofocus">
                                            <span>
                                                <button class="btn btn-primary fa fa-search" type="submit"></button>
                                                <span></span>
                                            </span>
                                        </p>
                                    </div>
                                </div>
                            </li>
                            <li class="border-top col-sm-6 wide" id="knowledgeSearch">
                                <div class="content-wrap"> 
                                    <div class="description-wide">
                                        <h3><div class="title">Knowledge Base</div> <i class="fa fa-cart"></i></h3>
                                        <ul class="portlet-content rkm">
                                            <li class="clearfix">
                                                <div class="summary title">Article</div>
                                                <div class="status title">Created</div>
                                            </li>
                                        </ul>
                                    </div>
                                </div>
                            </li>
                        </div>
                    </section>
                </div>
                <%@include file="../../common/interface/fragments/footer.jspf"%>
            </div>
        </div>
    </body>
</html>