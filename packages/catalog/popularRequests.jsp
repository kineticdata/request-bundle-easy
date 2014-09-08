<%-- Set the page content type, ensuring that UTF-8 is used. --%>
<%@page contentType="text/html; charset=UTF-8"%>
<%-- Include the package initialization file. --%>
<%@include file="framework/includes/packageInitialization.jspf"%>

<%-- Retrieve the Catalog --%>
<%
    // Retrieve the main catalog object
    Catalog catalog = Catalog.findByName(context, customerRequest.getCatalogName());
    // Preload the catalog child objects (such as Categories, Templates, etc) so
    // that they are available.  Preloading all of the related objects at once
    // is more efficient than loading them individually.
    catalog.preload(context);

    // Get map of description templates
    Map<String, String> templateDescriptions = DescriptionHelper.getTemplateDescriptionMap(context, catalog);
    // Get popular requests
    HelperContext systemContext = com.kd.kineticSurvey.impl.RemedyHandler.getDefaultHelperContext();
    List<String> globalTopTemplates = SubmissionStatisticsHelper.getMostCommonTemplateNames(systemContext, new String[] {customerRequest.getCatalogName()}, templateTypeFilterTopSubmissions, 5);
%>
<!DOCTYPE html>
<html>
    <head>
        <%-- Include the common content. --%>
        <%@include file="../../common/interface/fragments/head.jspf"%>
        <title>
            <%= bundle.getProperty("companyName")%>&nbsp;<%= bundle.getProperty("catalogName")%>
        </title>
        <!-- Page Stylesheets -->
        <link rel="stylesheet" href="<%= bundle.packagePath()%>resources/css/package.css" type="text/css" />
        <link rel="stylesheet" href="<%= bundle.packagePath()%>resources/css/popularRequests.css" type="text/css" />
        <!-- Page Javascript -->
        <script type="text/javascript" src="<%=bundle.packagePath()%>resources/js/popularRequests.js"></script>
    </head>
    <body>
        <div class="view-port">
            <%@include file="../../common/interface/fragments/navigationSlide.jspf"%>
            <div class="content-slide" data-target="div.navigation-slide">
                <%@include file="../../common/interface/fragments/header.jspf"%>
                <div class="pointer-events">
                    <section class="container">
                        <% if(globalTopTemplates.size() > 0){%>
                        	<header class="container">
                                <h2>
                                    Popular Requests
                                </h2>
                                <hr class="soften">
                            </header>
                            <ul class="templates unstyled">
                                <% for(String templateName : globalTopTemplates) { %>
                                    <li class="border-top clearfix">
                                        <% Template popularRequest = catalog.getTemplateByName(templateName); %>
                                        <div class="content-wrap"> 
                                            <% if (popularRequest.hasTemplateAttribute("ServiceItemImage")) { %>
                                                <div class="image">
                                                    <img width="40" src="<%= bundle.getProperty("serviceItemImagePath") + popularRequest.getTemplateAttributeValue("ServiceItemImage")%>" />
                                                </div>
                                                <div class="col-sm-6 description-small">
                                            <% } else {%>
                                                <div class="col-sm-6 description-wide">
                                            <% }%>
                                            <h3>
                                                <%= popularRequest.getName()%>
                                            </h3>
                                            <p>
                                                <%= popularRequest.getDescription() %>
                                            </p>
                                            <div class="visible-xs left">
                                                <a class="templateButton" href="<%= popularRequest.getAnonymousUrl() %>">
                                                    <i class="fa fa-share"></i>Request
                                                </a>
                                            </div>
                                            <% if (templateDescriptions.get(popularRequest.getId()) != null ) { %>
                                                <a class="read-more" href="<%= bundle.applicationPath()%>DisplayPage?srv=<%= templateDescriptions.get(popularRequest.getId()) %>">
                                                    Read More
                                                </a>
                                            <% }%>                                         
                                        </div>
                                        <div class="col-sm-5">
                                            <div class="hidden-xs">
                                                <!-- Load description attributes config stored in package config -->
                                                <% for (String attributeDescriptionName : attributeDescriptionNames) {%>
                                                    <% if (popularRequest.hasTemplateAttribute(attributeDescriptionName)) { %>
                                                        <p>
                                                            <strong><%= attributeDescriptionName%>:</strong> <%= popularRequest.getTemplateAttributeValue(attributeDescriptionName) %>
                                                        </p>
                                                    <% }%>
                                                <%}%>
                                            </div>
                                            <div class="hidden-xs">
                                                <a class="templateButton" href="<%= popularRequest.getAnonymousUrl() %>">
                                                    <i class="fa fa-share"></i>Request
                                                </a>
                                            </div>
                                        </div>
                                    </li>
                                <% } %>
                            </ul>
                        <% } else {%>
                            <h3>
                                <i>No popular requests. Please start requesting services to see them.</i>
                            </h3>
                        <% } %>
                    </section>
                </div>
                <%@include file="../../common/interface/fragments/footer.jspf"%>
            </div>
        </div>
    </body>
</html>