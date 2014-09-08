<%-- Set the page content type, ensuring that UTF-8 is used. --%>
<%@page contentType="text/html; charset=UTF-8"%>

<%-- Include the package initialization file. --%>
<%@include file="framework/includes/packageInitialization.jspf"%>

<%-- Retrieve the Catalog --%>
<%
    // Retrieve the main catalog object
    CatalogPortfolio catalog = CatalogPortfolio.findByName(context, customerRequest.getCatalogName());
    // Preload the catalog child objects (such as Categories, Templates, etc)
    catalog.preload(context);
    // Build map of templates to attributes and their values
    Map<String,Map<String,Map<String,TemplatePortfolio>>> mappedTemplates = new TreeMap<String,Map<String,Map<String,TemplatePortfolio>>>();  
    // For each of the Templates in the catalog
    for (TemplatePortfolio template : catalog.getTemplates(context)) {
        // For each of the template attribute instances
        for (String attributeName : template.getTemplateAttributeNames()) {
            if (attributeName == null || "".equals(attributeName)) {break;}
            // Ensure the attribute value map for the current attribute name exists
            Map<String,Map<String,TemplatePortfolio>> valueMap = mappedTemplates.get(attributeName);
            if (valueMap == null) {
                valueMap = new TreeMap<String,Map<String,TemplatePortfolio>>();
                mappedTemplates.put(attributeName, valueMap);
            }
            // For each of the attribute values
            for (String attributeValue : template.getTemplateAttributeValues(attributeName)) {
                // Ensure the template map exists
                Map<String,TemplatePortfolio> templateMap = valueMap.get(attributeValue);
                if (templateMap == null) {
                    templateMap = new TreeMap<String,TemplatePortfolio>();
                    valueMap.put(attributeValue, templateMap);
                }
                // Add the template to the attribute name->value->templates map
                templateMap.put(template.getName(), template);
            }
            // Build template map of templates that don't have the attribute
            Map<String,TemplatePortfolio> noMatchingTemplateMap = new TreeMap<String,TemplatePortfolio>();
            for (TemplatePortfolio temp : catalog.getTemplates(context)) {
                if(!temp.hasTemplateAttribute(attributeName)) {
                    noMatchingTemplateMap.put(temp.getName(), temp);
                }
            }
            valueMap.put("No Matching Attributes", noMatchingTemplateMap);
        }   
    }
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
            responseMessage = "Browse by attributes or enter a search term.";
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
        responseMessage = "Browse by attributes or enter a search term.";
    }
%>
<!DOCTYPE html>
<html>
    <head>
        <%-- Include the common content. --%>
        <%@include file="interface/fragments/head.jspf"%>
        
        <title>
            <% if(responseMessage != null) {%>
                Portfolio Listing
            <% } else {%>
                Portfolio&nbsp;|&nbsp;Search Results&nbsp;for&nbsp;'<%= request.getParameter("q") %>'
            <%}%>
        </title>

        <!-- Page Stylesheets -->
        <link rel="stylesheet" href="<%= bundle.packagePath()%>resources/css/jquery.qtip.min.css" type="text/css" />
        <link rel="stylesheet" href="<%= bundle.packagePath()%>resources/css/package.css" type="text/css" />   
        <link rel="stylesheet" href="<%= bundle.packagePath()%>resources/css/portfolio.css" type="text/css" />
        <!-- Page Javascript -->
        <script type="text/javascript" src="<%=bundle.packagePath()%>resources/js/jquery.qtip.min.js"></script>
        <script type="text/javascript" src="<%=bundle.packagePath()%>resources/js/jquery.tinysort.min.js"></script>
        <script type="text/javascript" src="<%=bundle.packagePath()%>resources/js/moment.min.js"></script>
        <script type="text/javascript" src="<%=bundle.packagePath()%>resources/js/portfolio.js"></script>
    </head>
    <body>
        <div class="view-port">
            <%@include file="interface/fragments/navigationSlide.jspf"%>
            <div class="content-slide" data-target="div.navigation-slide">
                <%@include file="interface/fragments/header.jspf"%>
                <div class="pointer-events">
                    <header class="container">
                        <div class="row">
                            <div class="col-md-3">
                                <p>
                                    <!-- Attribute opitions -->
                                    <select name="attributes" class="form-control" data-target-hide="select.attribute-values, ul.templates">
                                        <option value="">Select Attribute</option>
                                        <option value="Modified Date" data-target="select[name=&quot;modified-date&quot;]">
                                            Modified Date
                                        </option>
                                        <%for(Map.Entry <String,Map<String,Map<String,TemplatePortfolio>>> entry : mappedTemplates.entrySet()) {%>
                                            <%
                                                String attribute = entry.getKey();
                                                Map<String,Map<String,TemplatePortfolio>> value = entry.getValue();
                                            %>
                                            <option value="<%= attribute%>" data-target="select[name=&quot;<%= attribute%>&quot;]">
                                                <%= attribute%>
                                            </option>
                                        <%}%>
                                    </select>
                                </p>
                            </div>
                            <div class="col-md-3">
                                <p>
                                    <!-- Custom modified date opitions -->
                                    <select class="attribute-values form-control hide" name="modified-date" data-order="asc" data-target-hide="ul.templates" data-target="ul.default" data-target-show="ul.modified" data-target-sort="span.modified">
                                        <option value="">Select Timeago</option>
                                        </option>
                                    </select>
                                    <!-- Attribute value opitions -->
                                    <%for(Map.Entry <String,Map<String,Map<String,TemplatePortfolio>>> entry : mappedTemplates.entrySet()) {%>
                                        <%
                                            String attribute = entry.getKey();
                                            Map<String,Map<String,TemplatePortfolio>> value = entry.getValue();
                                        %>
                                        <select class="attribute-values form-control hide" name="<%= attribute %>">
                                            <option value="">Select Attribute Value</option>
                                            <%for(Map.Entry <String,Map<String,TemplatePortfolio>> valueEntry : value.entrySet()) {%>
                                                <%
                                                    String attributeValue = valueEntry.getKey();
                                                    // Count service items per each value
                                                    Integer templateMapSize = valueEntry.getValue().size();
                                                %>
                                                <option value="<%= attributeValue%>" data-target="ul[data-attribute=&quot;<%= attribute%>&quot;][data-attribute-value=&quot;<%= attributeValue%>&quot;]" data-target-hide="ul.templates">
                                                    <%= attributeValue%>&nbsp;(<%= templateMapSize%>)
                                                </option>
                                            <%}%>
                                        </select>
                                    <%}%>
                                </p>
                            </div>
                        </div>
                    </header>
                    <% Map<String,String> attributeMap = new TreeMap<String, String>(); %>
                    <header class="container">
                        <h2 class="response">
                            <% if(responseMessage != null) {%>
                                <%= responseMessage %>
                            <%} else {%>
                                Results found for '<%= request.getParameter("q")%>'.
                            <%}%>
                        </h2>
                        <hr class="soften">
                    </header>
                    <section class="container">
                        <!-- Templates with attribute and values -->
                        <%for(Map.Entry <String,Map<String,Map<String,TemplatePortfolio>>> attributeEntry : mappedTemplates.entrySet()) {%>
                            <%
                                String attribute = attributeEntry.getKey();
                                Map<String,Map<String,TemplatePortfolio>> attributeValueMap = attributeEntry.getValue(); 
                            %>
                            <%for(Map.Entry <String,Map<String,TemplatePortfolio>> attributeValueEntry : attributeValueMap.entrySet()) {%>
                                <%
                                    String attributeValue = attributeValueEntry.getKey();
                                    Map<String,TemplatePortfolio> templateMap = attributeValueEntry.getValue();
                                %>
                                <ul data-attribute="<%= attribute%>" data-attribute-value="<%= attributeValue%>" class="templates hide unstyled">
                                    <% for(Map.Entry <String,TemplatePortfolio> templateEntry : templateMap.entrySet()) {%>
                                        <% TemplatePortfolio template = templateEntry.getValue(); %>
                                        <li class="border-top clearfix">
                                            <div class="row">
                                                <div class="col-sm-8 description">
                                                    <a href="<%= bundle.getProperty("portfolioDetailsUrl")%>&id=<%= template.getId()%>">
                                                        <% if (template.hasTemplateAttribute("ServiceItemImage")) { %>
                                                                <img width="100px" src="<%= ServiceItemImageHelper.buildImageSource(template.getTemplateAttributeValue("ServiceItemImage"), bundle.getProperty("serviceItemImagePath"))%>" />
                                                        <% }%>
                                                        <h3>
                                                            <%= template.getName()%>
                                                        </h3>
                                                    </a>
                                                    <p>
                                                        <%= template.getDescription()%> 
                                                        <br>
                                                        <a href="<%= bundle.getProperty("portfolioDetailsUrl")%>&id=<%= template.getId()%>">
                                                            Read More
                                                        </a> 
                                                    </p>                            
                                                </div>
                                                <div class="col-sm-3 description-attributes">
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
                                                        <strong>Active:</strong> <i><span data-value="<%= template.getModified()%>" class="modified"></span></i>
                                                    <% }%>
                                                </div>
                                            </div>
                                        </li>
                                    <%}%>
                                </ul>
                            <%}%>
                        <%}%>
                        <!-- Search results -->
                        <% if(responseMessage != null) {%>
                            <ul class="templates unstyled hide">
                        <%} else {%>
                            <ul class="templates unstyled">
                        <%}%>
                            <% for (int i = 0; i < matchingTemplates.length; i++) {%>
                                <li class="border-top clearfix">
                                    <div class="row">
                                        <div class="col-sm-8 description">
                                            <a href="<%= bundle.getProperty("portfolioDetailsUrl")%>&id=<%= matchingTemplates[i].getId()%>">
                                                <% if (matchingTemplates[i].hasTemplateAttribute("ServiceItemImage")) { %>
                                                    <img width="100px" src="<%= ServiceItemImageHelper.buildImageSource(matchingTemplates[i].getTemplateAttributeValue("ServiceItemImage"), bundle.getProperty("serviceItemImagePath"))%>" />
                                                <% }%>
                                                <h3>
                                                    <%= matchingTemplates[i].getName()%> 
                                                </h3>
                                            </a>
                                            <p>
                                                <%= matchingTemplates[i].getDescription()%>
                                                <br>
                                                <a href="<%= bundle.getProperty("portfolioDetailsUrl")%>&id=<%= matchingTemplates[i].getId()%>">
                                                    Read More
                                                </a>
                                            </p>
                                        </div>
                                        <div class="col-sm-3 description-attributes">
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
                                                <strong>Active:</strong> <i><span data-value="<%= matchingTemplates[i].getModified()%>" class="modified"></span></i>
                                            <% }%>
                                        </div>
                                    </div>
                                </li>
                            <% }%>
                        </ul>
                        <!-- Modified data -->
                        <ul class="templates default unstyled hide">
                            <% for (TemplatePortfolio template : catalog.getTemplates(context)) {%>
                                <li class="border-top clearfix">
                                    <div class="row">
                                        <div class="col-sm-8 description">
                                            <a href="<%= bundle.getProperty("portfolioDetailsUrl")%>&id=<%= template.getId()%>">
                                                <% if (template.hasTemplateAttribute("ServiceItemImage")) { %>
                                                    <div class="image">
                                                        <img width="100px" src="<%= ServiceItemImageHelper.buildImageSource(template.getTemplateAttributeValue("ServiceItemImage"), bundle.getProperty("serviceItemImagePath"))%>" />
                                                    </div>
                                                <% }%>
                                                <h3>
                                                    <%= template.getName()%>
                                                </h3>
                                            </a>
                                            <p>
                                                <%= template.getDescription()%> 
                                                <br>
                                                <a href="<%= bundle.getProperty("portfolioDetailsUrl")%>&id=<%= template.getId()%>">
                                                    Read More
                                                </a>
                                            </p>                      
                                        </div>
                                        <div class="col-sm-3 description-attributes">
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
                                                <strong>Active:</strong> <i><span data-value="<%= template.getModified()%>" class="modified"><%= template.getModified()%></span></i>
                                            <% }%>
                                        </div>
                                    </div>
                                </li>
                            <%}%>
                        </ul>
                        <!-- Results from modified filter -->
                        <ul class="templates modified unstyled hide">
                        </ul>
                        <%-- LOADER --%>
                        <div id="loader" class="hide">
                            <img alt="Please Wait." src="<%=bundle.bundlePath()%>common/resources/images/spinner.gif" />
                            <br />
                            Loading Results
                        </div>
                    </section>
                </div>
                <%@include file="interface/fragments/footer.jspf"%>
            </div>
        </div>
    </body>
</html>
