<%-- Set the page content type, ensuring that UTF-8 is used. --%>
<%@page contentType="text/html; charset=UTF-8"%>

<%-- Include the package initialization file. --%>
<%@include file="framework/includes/packageInitialization.jspf"%>

<%-- Retrieve the Catalog --%>
<%
    // Retrieve the main catalog object
    CatalogPortfolio catalog = CatalogPortfolio.findByName(context, customerRequest.getCatalogName());
    // Preload the catalog child objects (such as Categories, Templates, etc) so
    // that they are available.  Preloading all of the related objects at once
    // is more efficient than loading them individually.
    catalog.preload(context);
    // Define variables
    String[] querySegments;
    String responseMessage = null;
    List<TemplatePortfolio> templates = new ArrayList();
    TemplatePortfolio[] matchingTemplates = templates.toArray(new TemplatePortfolio[templates.size()]);
    Pattern combinedPattern = Pattern.compile("");
    // Retrieve the searchableAttribute property
    String searchableAttributeString = bundle.getProperty("searchableAttributes");
    // Initialize the searchable attributes array
    String[] searchableAttributes = new String[0];
    if(request.getParameter("q") != null) {
        // Build the array of querySegments (query string separated by a space)
        querySegments = request.getParameter("q").split(" ");
        // Display an error message if there are 0 querySegments or > 10 querySegments
        if (querySegments.length == 0 || querySegments[0].length() == 0) {
            responseMessage = "Please enter a search term.";
        } else if (querySegments.length > 10) {
            responseMessage = "Search is limited to 10 search terms.";
        } else {
            // Default the searchableAttribute property to "Keyword" if it wasn't specified
            if (searchableAttributeString == null) {searchableAttributeString = "Keyword";}
            // If the searchableAttributeString is not empty
            if (!searchableAttributeString.equals("")) {
                searchableAttributes = searchableAttributeString.split("\\s*,\\s*");
            }
            PortfolioSearch catalogSearch = new PortfolioSearch(context, catalog, querySegments);
            //Category[] matchingCategories = catalogSearch.getMatchingCategories();
            matchingTemplates = catalogSearch.getMatchingTemplates(searchableAttributes);
            combinedPattern = catalogSearch.getCombinedPattern();
            if (matchingTemplates.length == 0) {
                responseMessage = "No results were found.";
            }
        }
    } else {
        responseMessage = "Please Start Your Search";
    }
%>
<!DOCTYPE html>
<html>
    <head>
        <%-- Include the common content. --%>
        <%@include file="../../common/interface/fragments/head.jspf"%>
        
        <title>
            <% if(responseMessage != null) {%>
                Portfolio Listing
            <% } else {%>
                Portfolio&nbsp;|&nbsp;Search Results&nbsp;for&nbsp;'<%= request.getParameter("q") %>'
            <%}%>
        </title>

        <!-- Page Stylesheets -->
        <link rel="stylesheet" href="<%= bundle.packagePath()%>resources/css/package.css" type="text/css" />
        <link rel="stylesheet" href="<%= bundle.packagePath()%>resources/css/portfolio.css" type="text/css" />
        <!-- Page Javascript -->
        <script type="text/javascript" src="<%=bundle.packagePath()%>resources/js/jquery.tinysort.min.js"></script>
        <script type="text/javascript" src="<%=bundle.packagePath()%>resources/js/jquery-listnav.min.2.1.js"></script>
        <script type="text/javascript" src="<%=bundle.packagePath()%>resources/js/moment.min.js"></script>
        <script type="text/javascript" src="<%=bundle.packagePath()%>resources/js/portfolio.js"></script>
    </head>
    <body>
        <div class="view-port">
            <header class="landing-page">
                <div class="container">
                    <a href="<%= bundle.getProperty("gartnerHomeUrl")%>">
                        <img src="<%= bundle.packagePath()%>resources/images/orange-grey-folders.png" />
                        <div class="logo"><%= bundle.getProperty("companyName")%></div>
                    </a>
                    <h2>Portfolio</h2>
                    <%@include file="../../common/interface/fragments/contentUser.jspf"%>
                </div>
            </header>
            <header class="container">
                <form id="catalog-search" method="get" action="<%= bundle.applicationPath()%>DisplayPage">
                    <input type="hidden" name="name" value="<%= bundle.getProperty("searchNameParamPortfolio")%>" />
                    <p>
                        <label class="infield" for="search">Search Portfolio</label>
                        <input id="search" class="input-large" type="search" name="q" value="" />
                        <!-- span deals with button floating incorrectly next to input in ie 7 fail -->
                        <span>
                            <button class="fa fa-search" type="submit"></button>
                        <span>
                    </p>
                </form>
                <div class="filter">
                    <h2>
                        A-Z
                    </h2>
                    <nav>
                        <div id="alpha-nav" class="alphabetical-navigation">
                        </div>
                    </nav>
                </div>
            </header>
            <% if(responseMessage != null) {%>
                <header class="container">
                    <h2>
                        <%= responseMessage %>
                    </h2>
                    <hr class="soften">
                </header>
                <section class="container">
                    <ul id="alpha" class="templates unstyled">
                        <% for (TemplatePortfolio template : catalog.getTemplates(context)) {%>
                            <li class="border-top clearfix" title="<%= template.getName().substring(0,1).toUpperCase() %>">
                                <div class="content-wrap">
                                    <% if (template.hasTemplateAttribute("ServiceItemImage")) { %>
                                        <div class="image">
                                            <img width="100px" src="<%= ServiceItemImageHelper.buildImageSource(template.getTemplateAttributeValue("ServiceItemImage"), bundle.getProperty("serviceItemImagePath"))%>" />
                                        </div>
                                        <div class="description">
                                    <% } else {%>
                                            <div class="description-wide">
                                        <% }%>
                                        <h3>
                                            <a class="" href="<%= bundle.getProperty("portfolioDetailsUrl")%>&id=<%= template.getId()%>">
                                                <%= template.getName()%>
                                            </a>
                                        </h3>
                                        <p>
                                            <%= template.getDescription()%> 
                                        </p>
                                        <a class="" href="<%= bundle.getProperty("portfolioDetailsUrl")%>&id=<%= template.getId()%>">
                                            Read More
                                        </a>                                    
                                    </div>
                                    <div class="description-attributes">
                                        <strong>Status:</strong> <i><%= template.getStatus()%></i>
                                        <% if (!template.getType().equals("")) { %>
                                            <br />
                                            <strong>Type:</strong> <i><%= template.getType()%></i>
                                        <% }%>
                                        <% if (!template.getDisplayName().equals("")) { %>
                                            <br />
                                            <strong>Display Name:</strong> <i><%= template.getDisplayName()%></i>
                                        <% }%>
                                        <% if (!template.getCategorizationString().equals("")) { %>
                                            <br />
                                            <strong>Categories:</strong> <i><%= template.getCategorizationString()%></i>
                                        <% }%>
                                        <% if (!template.getModified().equals("")) { %>
                                            <br />
                                            <strong>Active:</strong> <i><span class="modified"><%= template.getModified()%></span></i>
                                        <% }%>
                                    </div>
                                </div>
                            </li>
                        <%}%>
                    </ul>
                </section>
            <% } else {%>
                <header class="container">
                    <h2>
                        Results found for '<%= request.getParameter("q")%>'.
                    </h2>
                    <hr class="soften">
                </header>
                <section class="container">
                    <ul id="alpha" class="templates unstyled">
                        <% for (int i = 0; i < matchingTemplates.length; i++) {%>
                            <li class="border-top clearfix">
                                <div class="content-wrap">
                                    <% if (matchingTemplates[i].hasTemplateAttribute("ServiceItemImage")) { %>
                                        <div class="image">
                                            <img width="100px" src="<%= ServiceItemImageHelper.buildImageSource(matchingTemplates[i].getTemplateAttributeValue("ServiceItemImage"), bundle.getProperty("serviceItemImagePath"))%>" />
                                        </div>
                                        <div class="description">
                                    <% } else {%>
                                        <div class="description-wide">
                                    <% }%>
                                    <h3>
                                        <a class="" href="<%= bundle.getProperty("portfolioDetailsUrl")%>&id=<%= matchingTemplates[i].getId()%>">
                                            <%= matchingTemplates[i].getName()%>
                                        </a>  
                                    </h3>
                                    <p>
                                        <%= PortfolioSearch.replaceAll(combinedPattern, matchingTemplates[i].getDescription())%>
                                    </p>
                                    <a class="" href="<%= bundle.getProperty("portfolioDetailsUrl")%>&id=<%= matchingTemplates[i].getId()%>">
                                        Read More
                                    </a>
                                </div>
                                <div class="description-attributes">
                                    <strong>Status:</strong> <i><%= matchingTemplates[i].getStatus()%></i>
                                    <% if (!matchingTemplates[i].getType().equals("")) { %>
                                        <br />
                                        <strong>Type:</strong> <i><%= matchingTemplates[i].getType()%></i>
                                    <% }%>
                                    <% if (!matchingTemplates[i].getDisplayName().equals("")) { %>
                                        <br />
                                        <strong>Display Name:</strong> <i><%= matchingTemplates[i].getDisplayName()%></i>
                                    <% }%>
                                    <% if (!matchingTemplates[i].getCategorizationString().equals("")) { %>
                                        <br />
                                        <strong>Categories:</strong> <i><%= matchingTemplates[i].getCategorizationString()%></i>
                                    <% }%>
                                    <% if (!matchingTemplates[i].getModified().equals("")) { %>
                                        <br />
                                        <strong>Active:</strong> <i><span class="modified"><%= matchingTemplates[i].getModified()%></span></i>
                                    <% }%>
                                </div>
                            </li>
                        <% }%>
                    </ul>
                </section>
            <% }%>
            <!-- Footer -->
            <footer class="footer">
                <span style="display:none">&nbsp;</span>
                <div class="container" style="text-align: center;">
                    <span class="left">
                    <a href="http://www.kineticdata.com/">Kinetic Data</a>
                    </span>
                    <span class="right">
                       <a href="http://community.kineticdata.com/">Kinetic Community</a>
                       &nbsp;&nbsp;
                       <a href="http://www.kineticdata.com/AboutUs/ContactUs.html">Contact Us</a>
                    </span>
                </div>
            </footer>
        </div>
    </body>
</html>