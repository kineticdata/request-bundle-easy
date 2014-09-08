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
//    HelperContext systemContext = com.kd.kineticSurvey.impl.RemedyHandler.getDefaultHelperContext();
    List<String> globalTopTemplates = SubmissionStatisticsHelper.getMostCommonTemplateNames(systemContext, new String[] {customerRequest.getCatalogName()}, templateTypeFilterTopSubmissions, 5);

    // Get catalog Attributes
    CatalogAttribute[] catalogAttr = CatalogAttribute.findByCategoryInstanceId(systemContext,catalog.getCategoryId());

    Integer apprcount = ArsBase.count(context, "KS_SRV_CustomerSurvey", displayGroups.get("Pending Approval"));
	Integer rcount = ArsBase.count(context, "KS_SRV_CustomerSurvey", displayGroups.get("Open Request"));

	Category rcat = catalog.getCategoryByName("Request It");
	Integer ricount = rcat.getTemplates().length;
	Category fcat = catalog.getCategoryByName("Fix It");
	Integer ficount = fcat.getTemplates().length;
%>
<!DOCTYPE html>
<html>
    <head>
        <%-- Include the common content. --%>
        <%@include file="../../common/interface/fragments/head.jspf"%>
        <title>
            <%= bundle.getProperty("companyName")%>&nbsp;<%=ThemeLocalizer.getString(standardsResourceBundle,"Home")%>
        </title>
		
		<%-- Include the application head content. --%>
        <%@include file="../../core/interface/fragments/applicationHeadContent.jspf"%>
        <%@include file="../../core/interface/fragments/displayHeadContent.jspf"%>
		
        <!-- Page Stylesheets -->
        <!--link rel="stylesheet" href="<%= bundle.packagePath()%>resources/css/package.css" type="text/css" />
        <link rel="stylesheet" href="<%= bundle.packagePath()%>resources/css/catalog.css" type="text/css" /-->
        <!-- Language Javascript -->
        <script type="text/javascript" src="<%=bundle.bundlePath()%>common/resources/js/languageChange.js"></script>
		<!-- Page Javascript -->
        <script type="text/javascript" src="<%=bundle.packagePath()%>resources/js/jquery.carouFredSel-6.2.1-packed.js"></script>
		<!--script type="text/javascript" src="<%=bundle.packagePath()%>resources/js/package.js"></script-->
        <!--script type="text/javascript" src="<%=bundle.packagePath()%>resources/js/catalog.js"></script-->
        <script type="text/javascript" src="<%=bundle.packagePath()%>resources/js/jquery.ba-hashchange.min.js"></script>

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
            <!-- /.row -->
            <section class="container">
            <div class="row">
                <div class="col-lg-3 col-md-6">
                    <div class="category panel panel-primary" data-id="Request It">
                        <div class="panel-heading">
                            <div class="row">
                                <div class="col-xs-3">
                                    <i class="fa fa-comments fa-5x"></i>
                                </div>
                                <div class="col-xs-9 text-right">
                                    <div class="huge">&nbsp;</div>
                                    <div class="large">Request It!</div>
                                </div>
                            </div>
                        </div>
                        <a href="#">
                            <div class="panel-footer" data-id="Request It">
                                <span class="pull-left">View Details</span>
                                <span class="pull-right"><i class="fa fa-arrow-circle-right"></i></span>
                                <div class="clearfix"></div>
                            </div>
                        </a>
                    </div>
                </div>
                <div class="col-lg-3 col-md-6">
                    <div class="category panel panel-green" data-id="Fix It">
                        <div class="panel-heading">
                            <div class="row">
                                <div class="col-xs-3">
                                    <i class="fa fa-tasks fa-5x"></i>
                                </div>
                                <div class="col-xs-9 text-right">
                                    <div class="huge">&nbsp;</div>
                                    <div class="large">Fix It!</div>
                                </div>
                            </div>
                        </div>
                        <a href="#">
                            <div class="panel-footer" data-id="Fix It">
                                <span class="pull-left">View Details</span>
                                <span class="pull-right"><i class="fa fa-arrow-circle-right"></i></span>
                                <div class="clearfix"></div>
                            </div>
                        </a>
                    </div>
                </div>
                <div class="col-lg-3 col-md-6">
                    <div class="category panel panel-yellow" data-id="My Requests">
                        <div class="panel-heading">
                            <div class="row">
                                <div class="col-xs-3">
                                    <i class="fa fa-shopping-cart fa-5x"></i>
                                </div>
                                <div class="col-xs-9 text-right">
                                    <div class="huge"><%= rcount %></div>
                                    <div class="large">My Requests</div>
                                </div>
                            </div>
                        </div>
                        <a href="#">
                            <div class="panel-footer" data-id="My Requests">
                                <span class="pull-left">View Details</span>
                                <span class="pull-right"><i class="fa fa-arrow-circle-right"></i></span>
                                <div class="clearfix"></div>
                            </div>
                        </a>
                    </div>
                </div>
                <div class="col-lg-3 col-md-6">
                    <div class="category panel panel-red" data-id="My Approvals">
                        <div class="panel-heading">
                            <div class="row">
                                <div class="col-xs-3">
                                    <i class="fa fa-support fa-5x"></i>
                                </div>
                                <div class="col-xs-9 text-right">
                                    <div class="huge"><%= apprcount  %></div>
                                    <div class="large">My Approvals</div>
                                </div>
                            </div>
                        </div>
                        <a href="#">
                            <div class="panel-footer" data-id="My Approvals">
                                <span class="pull-left">View Details</span>
                                <span class="pull-right"><i class="fa fa-arrow-circle-right"></i></span>
                                <div class="clearfix"></div>
                            </div>
                        </a>
                    </div>
                </div>
            </div>
        </section>

                    <!--section class="container">
						<div class="vertical-spacer">
							<div class="col-sm-8">
								<div>
									<% for (CatalogAttribute attr : catalogAttr){ %>
										<strong><%= attr.getName() %></strong> : <%= attr.getValue() %><br />
									<% } %>
								</div>
								<div class="service-item-content">
									< % @include file="../../core/interface/fragments/displayBodyContent.jspf"% >
								</div>
								<div class="catalog-contents">
									<div class="category_boxes">
										<% for (Category category : catalog.getRootCategories(context)) { %>
											<% if(!(category.getName().equals("Activity") || category.getName().equals("Help") || category.getName().equals("Portals") || category.getName().equals("Utility"))) { %>
												<% if(!categoryFilterHashSet.contains(category.getName())) {%>
													<% if (category.hasTemplates() || category.hasNonEmptySubcategories()) { %>
															<div class="category_box cat_<%= category.getFullName().replaceAll("[^A-Za-z0-9]", "") %>">
															<a href="<%= bundle.getProperty("categoryUrl") %>&category=<%= URLEncoder.encode(category.getFullName(), "UTF-8")%>" class="name">
																<%-- <i class="fa fa-pencil fa-4x" style="width:100px"></i> --%>
																<span class="cat_fa cat_fa_<%= category.getFullName().replaceAll("[^A-Za-z0-9]", "") %>"></span>
																<%=ThemeLocalizer.getString(categoryResourceBundle,category.getName())%>
																<%= category.getImageTag()%>
															</a>
															</div>
													<% } %>
												<% } %>
											<% } %>
										<% }%>
									</div>
									<div class="catalog-popular-requests">
										<h2>
											<%=ThemeLocalizer.getString(standardsResourceBundle,"Popular Requests")%>
										</h2>
										<hr class="soften">
											
										<% if(globalTopTemplates.size() > 0){%>
											<ul class="templates unstyled">
												<% for(String templateName : globalTopTemplates) { %>
													<li class="border-top clearfix">
														<% Template popularRequest = catalog.getTemplateByName(templateName); %>
														<div class="content-wrap"> 
															<h3>
																<a class="" href="<%= popularRequest.getAnonymousUrl() %>">
																<%=ThemeLocalizer.getString(serviceItemsResourceBundle,popularRequest.getName())%>
																</a>
															</h3>
														</div>
														<div class="col-sm-5">
															<div class="hidden-xs">
																<%--
																<% for (String attributeDescriptionName : attributeDescriptionNames) {%>
																	<% if (popularRequest.hasTemplateAttribute(attributeDescriptionName)) { %>
																		<p>
																			<strong><%= attributeDescriptionName%>:</strong> <%= popularRequest.getTemplateAttributeValue(attributeDescriptionName) %>
																		</p>
																	<% }%>
																<%}%>
																--%>
															</div>
														</div>
													</li>
												<% } %>
											</ul>
										<% } else {%>
											<h3>
												<i><%=ThemeLocalizer.getString(catalogResourceBundle,"No popular requests. Please start requesting services to see them.")%></i>
											</h3>
										<% } %>
									</div>
								</div>
							</div>
							<div class="col-sm-4">
								<div class="right-widget">
									<div class="content">
										<h2 style="color:#ED1C24;"><i class="fa fa-exclamation fa-lg"></i>&nbsp; Alerts/Outages</h2>
										<ul>
											<li><%=ThemeLocalizer.getString(catalogResourceBundle,"Email performance slow in Singapore")%></li>
										</ul>
									</div>
								</div>
								<div class="right-widget">
									<div class="content">
										<h2><i class="fa fa-bullhorn fa-lg"></i>&nbsp; Announcements</h2>
										<ul>
											<li><%=ThemeLocalizer.getString(catalogResourceBundle,"DWS proud to announce New Hire process release")%></li>
											<li><%=ThemeLocalizer.getString(catalogResourceBundle,"Financial system cutover planned")%></li>
											<li><%=ThemeLocalizer.getString(catalogResourceBundle,"Corporate blood drive on Monday")%></li>
										</ul>
									</div>
								</div>
								<div class="right-widget">
									<div class="content">
										<h2><i class="fa fa-stethoscope fa-lg"></i>&nbsp; System Status</h2>
										<ul>
											<li><%=ThemeLocalizer.getString(catalogResourceBundle,"Email System")%></li>
											<li><%=ThemeLocalizer.getString(catalogResourceBundle,"Phone System")%></li>
											<li><%=ThemeLocalizer.getString(catalogResourceBundle,"Bank Transfer System")%></li>
										</ul>
									</div>
								</div>
							</div>
						</div>
                    </section>
                    <nav class="catalog">
                        <%-- BREADCRUMBS NAV --%>
                        <ul class="breadcrumbs unstyled">
                            <li data-id="root">
                                <%=ThemeLocalizer.getString(standardsResourceBundle,"Catalog")%>
                            </li>
                        </ul>
                        <%-- TEMPLATES NAV --%>
                        <ul class="templates unstyled">
                        </ul>
                        <%-- CATAGORIES NAV --%>
                        <ul class="categories unstyled">
                        </ul>
                        <%-- TEMPLATE DETAILS --%>
                        <div class="template-details">
                        </div>
                        
                    </nav-->
                </div>
                <%@include file="../../common/interface/fragments/footer.jspf"%>
            </div>
        </div>
        <!-- Data used for jQuery manipulation -->
        <%-- ROOT CATEGORIES DATA --%>
        <ul class="root-category-data hide">
            <% for (Category category : catalog.getRootCategories(context)) { %>
                <% if (category.hasTemplates()) { %>
                    <li data-id="<%= category.getId()%>" data-name="<%= category.getName()%>" data-description="<%= category.getDescription()%>">
                        <%=ThemeLocalizer.getString(categoryResourceBundle,category.getName())%>
                        <i class="fa fa-chevron-circle-right"></i>
                    </li>
                <% } %>
            <% }%>
        </ul>
        <%-- CATEGORY DATA --%>
        <ul class="category-data hide">
            <% for (Category category : catalog.getAllCategories(context)) {%>
                <% if (category.hasTemplates()) { %>
                    <li class="" data-id="<%= category.getId()%>" data-name="<%= category.getName()%>" data-description="<%= category.getDescription()%>">
                        <%= category.getName()%>
                        <i class="fa fa-chevron-circle-right"></i>
                        <%-- SUBCATEGORIES DATA --%>
                        <% if (category.hasNonEmptySubcategories()) {%>
                            <ul class="subcategory-data">
                                <% for (Category subcategory : category.getSubcategories()) { %>
                                    <% if (subcategory.hasTemplates()) { %>
                                        <li data-id="<%= subcategory.getId()%>" data-name="<%= subcategory.getName()%>" data-description="<%= subcategory.getDescription()%>">
                                            <%=ThemeLocalizer.getString(categoryResourceBundle,subcategory.getName())%>
                                            <i class="fa fa-chevron-circle-right"></i>
                                        </li>
                                    <% }%>
                                <% }%>
                            </ul>
                        <% }%>
                        <%-- TEMPLATES DATA --%>
                        <% if (category.hasTemplates()) {%>
                            <ul class="template-data">
                                <% for (Template template : category.getTemplates()) {%>
                                    <li data-id="<%= template.getId()%>" data-name="<%= template.getName()%>">
                                        <%=ThemeLocalizer.getString(serviceItemsResourceBundle,template.getName())%>
                                        <div class="template-details-data hide">
                                            <% if (template.hasTemplateAttribute("ServiceItemImage")) { %>
                                                <div class="image">
                                                    <img width="40" src="<%= ServiceItemImageHelper.buildImageSource(template.getTemplateAttributeValue("ServiceItemImage"), bundle.getProperty("serviceItemImagePath"))%>" />
                                                </div>
                                            <% }%>
                                            <p>
                                                <%=ThemeLocalizer.getString(serviceItemsResourceBundle,template.getDescription())%>
                                            </p>
                                            <% if (templateDescriptions.get(template.getId()) != null) { %>
                                                <a class="read-more" href="<%= bundle.applicationPath()%>DisplayPage?srv=<%= templateDescriptions.get(template.getId()) %>">
                                                    <%=ThemeLocalizer.getString(standardsResourceBundle,"Read More")%>
                                                </a>
                                            <% }%>
                                            <a class="templateButton" href="<%= template.getAnonymousUrl() %>">
                                                <i class="fa fa-share"></i>
                                                <%=ThemeLocalizer.getString(standardsResourceBundle,"Request")%>
                                            </a>
                                        </div>
                                    </li>
                                <% }%>
                            </ul>
                        <% }%>
                    </li>
                <% }%>
            <% }%>
        </ul>
    </body>
</html>
