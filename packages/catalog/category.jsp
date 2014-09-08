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
    Category currentCategory = catalog.getCategoryByName(request.getParameter("category"));
    // Get map of description templates
	Map<String, String> categoryDescriptions = DescriptionHelper.getCategoryDescriptionMap(context, catalog);
	// Map<String, String> categoryDescriptions = new java.util.HashMap<String, String>();
    Map<String, String> templateDescriptions = new java.util.HashMap<String, String>();
    if (currentCategory != null) {
        templateDescriptions = DescriptionHelper.getTemplateDescriptionMap(context, catalog);
    }
%>
<!DOCTYPE html>
<html>
    <head>
        <%-- Include the common content. --%>
        <%@include file="../../common/interface/fragments/head.jspf"%>
        <title>
            <%= bundle.getProperty("companyName")%>
            <% if(currentCategory != null) {%>
                |&nbsp;<%=ThemeLocalizer.getString(categoryResourceBundle,currentCategory.getName())%>
            <% }%>
        </title>
		
		<%-- Include the application head content. --%>
        <%@include file="../../core/interface/fragments/applicationHeadContent.jspf"%>
        <%@include file="../../core/interface/fragments/displayHeadContent.jspf"%>
		
        <!-- Package Stylesheets -->
        <link rel="stylesheet" href="<%= bundle.packagePath()%>resources/css/package.css" type="text/css" />
        <!-- Page Stylesheets -->
        <link rel="stylesheet" href="<%= bundle.packagePath()%>resources/css/category.css" type="text/css" />
        <!-- Language Javascript -->
        <script type="text/javascript" src="<%=bundle.bundlePath()%>common/resources/js/languageChange.js"></script>
        <!-- Page Javascript -->
        <script type="text/javascript" src="<%=bundle.packagePath()%>resources/js/package.js"></script>
        <script type="text/javascript" src="<%=bundle.packagePath()%>resources/js/category.js"></script>
        <!-- SBAdmin includes -->
            <!-- MetisMenu CSS -->
    <link href="<%=bundle.bundlePath()%>libraries/metisMenu/metisMenu.min.css" rel="stylesheet">

    <!-- Timeline CSS -->
    <link href="<%=bundle.bundlePath()%>libraries/sb-admin/timeline.css" rel="stylesheet">

    <!-- Custom CSS -->
    <link href="<%=bundle.bundlePath()%>libraries/sb-admin/sb-admin-2.css" rel="stylesheet">

    <!-- Morris Charts CSS -->
    <link href="<%=bundle.bundlePath()%>libraries/morris/morris.css" rel="stylesheet">

    <!-- Custom Fonts -->
    <link href="<%=bundle.bundlePath()%>libraries/font-awesome-4.1.0/css/font-awesome.min.css" rel="stylesheet" type="text/css">

    <!-- HTML5 Shim and Respond.js IE8 support of HTML5 elements and media queries -->
    <!-- WARNING: Respond.js doesn't work if you view the page via file:// -->
    <!--[if lt IE 9]>
        <script src="https://oss.maxcdn.com/libs/html5shiv/3.7.0/html5shiv.js"></script>
        <script src="https://oss.maxcdn.com/libs/respond.js/1.4.2/respond.min.js"></script>
    <![endif]-->

    <!-- jQuery Version 1.11.0 -->
    <script src="<%=bundle.bundlePath()%>libraries/jquery/jquery-1.11.0.js"></script>

    <!-- Bootstrap Core JavaScript -->
    <script src="<%=bundle.bundlePath()%>libraries/bootstrap/bootstrap.min.js"></script>

    <!-- Metis Menu Plugin JavaScript -->
    <script src="<%=bundle.bundlePath()%>libraries/metisMenu/metisMenu.min.js"></script>

    <!-- Morris Charts JavaScript -->
    <script src="<%=bundle.bundlePath()%>libraries/morris/raphael.min.js"></script>
    <!--script src="<%=bundle.bundlePath()%>libraries/morris/morris.min.js"></script-->
    <!--script src="<%=bundle.bundlePath()%>libraries/morris/morris-data.js"></script-->

    <!-- Custom Theme JavaScript -->
    <script src="<%=bundle.bundlePath()%>libraries/sb-admin/sb-admin-2.js"></script>
    </head>
    </head>
    <body>
        <div class="view-port">
            <%@include file="../../common/interface/fragments/navigationSlide.jspf"%>
            <div class="content-slide" data-target="div.navigation-slide">
                <%@include file="../../common/interface/fragments/header.jspf"%>
                <div style="height: 50px">
                    <form class="user-search" method="get" action="<%= bundle.applicationPath()%>DisplayPage">
                        <input type="hidden" name="name" value="<%= bundle.getProperty("searchNameParam") %>" />
                        <div style="width: 80%; margin: 10px auto;" class="input-group custom-search-form">
                            <label class="hide" for="search">Search everything</label>
                            <input id="search" class="form-control" type="text" name="q" value="<% if(request.getParameter("q") != null && !request.getParameter("q").equals("")) {%> <%= request.getParameter("q") %> <% }%>" placeholder="<%=ThemeLocalizer.getString(standardsResourceBundle,"Search Catalog")%>" />
                            <!-- span deals with button floating incorrectly next to input in ie 7 fail -->
                            <span class="input-group-btn">
                                <button class="btn btn-default" type="submit">
                                    <i class="fa fa-search"></i>
                                </button>
                            <span>
                        </div>
                    </form>
                </div>
                <div class="pointer-events">
                    <!--%@include file="interface/fragments/flyout.jspf"%-->
                    <% if(currentCategory != null) {%>
                        <header class="container">
                            <div class="breadcrumbs clearfix">
                                <% 
                                    List<Category> parentCategories = CategoryHelper.getCategoryTrail(catalog, currentCategory);
                                    Iterator<Category> iterator = parentCategories.iterator();
                                %>
                                <ul class="unstyled">
                                    <% 
                                        while(iterator.hasNext()) {
                                        Category category = iterator.next();
                                    %>
                                        <li>
                                            <a href="<%= bundle.getProperty("categoryUrl") %>&category=<%= URLEncoder.encode(category.getFullName(), "UTF-8")%>">    
                                                <%=ThemeLocalizer.getString(categoryResourceBundle,category.getName())%>
                                                <% if(iterator.hasNext()) {%>
                                                    &nbsp;/&nbsp;
                                                <%}%>
                                            </a>
                                        </li>
                                    <% } %>
                                </ul>
                            </div>
                            <% if(currentCategory.getImageTag().length() > 0) {%>
                                <div class="category-image">
                                    <%= currentCategory.getImageTag()%>
                                </div>
                                <div class="wrap-float">
                            <% } else { %>
                                <div class="wrap">
                            <% }%>
                                <div class="category-description container" data-description-id="<%= categoryDescriptions.get(currentCategory.getId()) %>">
                                    <%if (categoryDescriptions.get(currentCategory.getId()) == null) {%>
										<%=ThemeLocalizer.getString(categoryResourceBundle,currentCategory.getDescription())%>	
									<%}%>
                                </div>
								<div id="loader" class="hide">
									<img alt="<%=ThemeLocalizer.getString(categoryResourceBundle,"Please Wait.")%>" src="<%=bundle.bundlePath()%>common/resources/images/spinner.gif" />
									<br />
									<%=ThemeLocalizer.getString(categoryResourceBundle,"Loading Results")%>
								</div>
                            </div>
                            <div class="clearfix"></div>
                        </header>
                    <% }%>
                    <section class="container">
                        <% if(currentCategory != null) {%>
							<section class="container">
								<% if (currentCategory.getTemplates().length > 0) {%>
								<!--div class="container-header">
									<h3><%=ThemeLocalizer.getString(catalogResourceBundle,"Requestable Services")%></h3>
								</div-->
								<% }%>
								<ul class="templates col-sm-12 unstyled">
									<% for (Template template : currentCategory.getTemplates()) {%>
										<li class="border-top clearfix">
											<div class="content-wrap">
												<% if (template.hasTemplateAttribute("ServiceItemImage")) { %>
													<div class="image">
														<img width="40" src="<%= ServiceItemImageHelper.buildImageSource(template.getTemplateAttributeValue("ServiceItemImage"), bundle.getProperty("serviceItemImagePath"))%>" />
													</div>
													<div class="col-md-8 description-small">
												<% } else {%>
													<div class="col-md-8 description-wide">
												<% }%>
												<h4>
													<%=ThemeLocalizer.getString(serviceItemsResourceBundle,template.getName())%>
												</h4>
												<p>
													<%=ThemeLocalizer.getString(serviceItemsResourceBundle,template.getDescription())%>
												</p>
												
												<div class="visible-xs visible-sm left">
													<a class="templateButton" href="<%= template.getAnonymousUrl() %>">
														<i class="fa fa-share"></i><%=ThemeLocalizer.getString(standardsResourceBundle,"Request")%>
													</a>
												</div>
												
												<div class="hidden-xs hidden-sm attributes">
													<!-- Load description attributes config stored in package config -->
													<% for (String attributeDescriptionName : attributeDescriptionNames) {%>
														<% if (template.hasTemplateAttribute(attributeDescriptionName)) { %>
															<div class="attribute">
																<span class="attr_fa attr_fa_<%= attributeDescriptionName.replaceAll("[^A-Za-z0-9]", "") %>"></span>
																<strong><%= attributeDescriptionName%>:</strong> <span class="attr-value"><%= template.getTemplateAttributeValue(attributeDescriptionName) %></span>
															</div>
														<% }%>
													<%}%>
												</div>
												<% if (templateDescriptions.get(template.getId()) != null ) { %>
													<a class="" href="<%= bundle.applicationPath()%>DisplayPage?srv=<%= templateDescriptions.get(template.getId()) %>&category=<%= URLEncoder.encode(currentCategory.getFullName(), "UTF-8")%>">
														<%=ThemeLocalizer.getString(standardsResourceBundle,"Read More")%>
													</a>
												<% }%>                                           
											</div></div>
											<div class="hidden-xs hidden-sm col-sm-3">
												<div class="template-request-button">
													<a class="templateButton" href="<%= template.getAnonymousUrl() %>&category=<%= URLEncoder.encode(currentCategory.getFullName(), "UTF-8")%>">
														<i class="fa fa-share"></i><%=ThemeLocalizer.getString(standardsResourceBundle,"Request")%>
													</a>
												</div>
											</div>
										</li>
									<%}%>
								</ul>
							</section>
                        <% }%>
                        <% if (currentCategory.hasNonEmptySubcategories()) {%>
                            <hr class="soften">
                                <section class="container">
                                    <div class="subcategories">
                                        <!--h3>
                                            <%=ThemeLocalizer.getString(catalogResourceBundle,"Subcategories")%>
                                        </h3-->
                                        <ul class=" col-sm-12">
                                            <% for (Category subcategory : currentCategory.getSubcategories()) { %>
                                                <% if (subcategory.hasTemplates()) { %>
                                                <li class="subcategory" data-id="<%= subcategory.getId()%>" data-name="<%= subcategory.getName()%>">
                                                    <a href="<%= bundle.getProperty("categoryUrl") %>&category=<%= URLEncoder.encode(subcategory.getFullName(), "UTF-8")%>" class="name h4">
                                                        <%=ThemeLocalizer.getString(categoryResourceBundle,subcategory.getName())%>
                                                        <% if (subcategory.getDescription() != null){ %>
                                                            -&nbsp;<%=ThemeLocalizer.getString(categoryResourceBundle,subcategory.getDescription())%>
                                                        <% }%>
                                                    </a>
                                                </li>
                                                <% }%>
                                            <% }%>
                                            <div class="clearfix"></div>
                                        </ul>
                                    </div>
                                </section>
                            <% }%>
                    </section>
                </div>
                <%@include file="../../common/interface/fragments/footer.jspf"%>
            </div>
        </div>
    </body>
</html>