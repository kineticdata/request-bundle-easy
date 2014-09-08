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
    Map<String, String> templateDescriptions = new java.util.HashMap<String, String>();
    templateDescriptions = DescriptionHelper.getTemplateDescriptionMap(context, catalog);
%>
<!DOCTYPE html>
<html>
    <head>
        <%-- Include the common content. --%>
        <%@include file="../../common/interface/fragments/head.jspf"%>
        <title>
            <%= bundle.getProperty("companyName")%>&nbsp;|&nbsp;A-Z&nbsp;Listing
        </title>
        <!-- Page Stylesheets -->
        <link rel="stylesheet" href="<%= bundle.packagePath()%>resources/css/package.css" type="text/css" />
        <link rel="stylesheet" href="<%= bundle.packagePath()%>resources/css/catalogListing.css" type="text/css" />
        <!-- Page Javascript -->
        <script type="text/javascript" src="<%=bundle.packagePath()%>resources/js/package.js"></script>
		<script type="text/javascript" src="<%=bundle.packagePath()%>resources/js/catalogListing.js"></script>
        <script type="text/javascript" src="<%=bundle.packagePath()%>resources/js/jquery.tinysort.min.js"></script>
        <script type="text/javascript" src="<%=bundle.packagePath()%>resources/js/jquery.listnav.min-2.1.js"></script>
    </head>
    <body>
		<div class="view-port">
            <%@include file="../../common/interface/fragments/navigationSlide.jspf"%>
            <div class="content-slide" data-target="div.navigation-slide">
                <%@include file="../../common/interface/fragments/header.jspf"%>
                <div class="pointer-events">
                    <%@include file="interface/fragments/flyout.jspf"%>
					<header class="container">
						<h2>
							<%=ThemeLocalizer.getString(catalogResourceBundle,"A-Z Listing")%>
						</h2>
						<hr class="soften">
						<nav>
							<div id="alpha-nav" class="alphabetical-navigation">
							</div>
						</nav>
						<hr class="soften">
					</header>
					<section class="container">
						<ul id="alpha" class="templates unstyled">
							<% for (Template template : catalog.getTemplates(context)) {%>
								<% if(template.hasCategories()) {%>
									<li class="border-top clearfix" title="<%= template.getName().substring(0,1).toUpperCase() %>">
										<div class="content-wrap">
											<% if (template.hasTemplateAttribute("ServiceItemImage")) { %>
												<div class="image">
													<img width="120px" src="<%= bundle.getProperty("serviceItemImagePath") + template.getTemplateAttributeValue("ServiceItemImage")%>" />
												</div>
												<div class="description">
											<% } else {%>
												<div class="description-wide">
											<% }%>
											<h3>
												<%=ThemeLocalizer.getString(serviceItemsResourceBundle,template.getName())%>
											</h3>
											<p>
												<%=ThemeLocalizer.getString(serviceItemsResourceBundle,template.getDescription())%>
											</p>
											<% if (templateDescriptions.get(template.getId()) != null ) { %>
												<a class="" href="<%= bundle.applicationPath()%>DisplayPage?srv=<%= templateDescriptions.get(template.getId()) %>">
													<%=ThemeLocalizer.getString(standardsResourceBundle,"Read More")%>
												</a>
											<% }%>                                           
											</div>
											<div class="description-attributes">
												<!-- Load description attributes config stored in package config -->
												<% for (String attributeDescriptionName : attributeDescriptionNames) {%>
													<% if (template.hasTemplateAttribute(attributeDescriptionName)) { %>
														<p>
															<strong><%= attributeDescriptionName%>:</strong> <%= template.getTemplateAttributeValue(attributeDescriptionName) %>
														</p>
													<% }%>
												<%}%>
												<a class="templateButton" href="<%= template.getAnonymousUrl() %>">
													<i class="fa fa-share"></i><%=ThemeLocalizer.getString(standardsResourceBundle,"Request")%>
												</a>
											</div>
										</div>
									</li>
								<%}%>
							<%}%>
						</ul>
					</section>
				</div>
				<%@include file="../../common/interface/fragments/footer.jspf"%>
			</div>
		</div>
    </body>
</html>