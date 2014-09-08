<%-- Set the page content type, ensuring that UTF-8 is used. --%>
<%@page contentType="text/html; charset=UTF-8"%>
<%-- Include the package initialization file. --%>
<%@include file="framework/includes/packageInitialization.jspf"%>

<%
     // Retrieve the main catalog object
    CatalogPortfolio catalog = CatalogPortfolio.findByName(context, customerRequest.getCatalogName());
    // Preload the catalog child objects (such as Categories, Templates, etc) so
    // that they are available.  Preloading all of the related objects at once
    // is more efficient than loading them individually.
    catalog.preload(context);
    // Retrieve objects
    TemplatePortfolio currentTemplate = catalog.getTemplateById(request.getParameter("id"));
    if(currentTemplate == null) {
        throw new Exception("Current template does not exist!");
    }
    // Get the template attribute map
    Map<String,List<TemplateAttribute>> templateAttributeMap = currentTemplate.getTemplateAttributesMap();
    // Set up profiles
    Map<String, String> profiles = new HashMap<String, String>();
    profiles.put("SLA Profile", "Service Request SLA Profile");
    profiles.put("Approval Profile", "Service Request Approval Profile");
    profiles.put("Cost Profile", "Service Request Cost Profile");

    String chartData = SubmissionStatistic.getRecentSubmissionJsonData(context, customerRequest.getCatalogName(), currentTemplate.getName());
%>
<!DOCTYPE html>
<html>
    <head>
        <%-- Include the common content. --%>
        <%@include file="interface/fragments/head.jspf"%>
        <title>
           Portfolio details for <%= currentTemplate.getName()%> 
        </title>
        <!-- Page Stylesheets -->
        <link rel="stylesheet" href="<%= bundle.packagePath()%>resources/css/package.css" type="text/css" />
        <link rel="stylesheet" href="<%= bundle.packagePath()%>resources/css/jquery.qtip.min.css" type="text/css" />
        <link rel="stylesheet" href="<%= bundle.packagePath()%>resources/css/portfolioDetails.css" type="text/css" />
        <!-- Page Javascript -->
        <script type="text/javascript" src="<%=bundle.packagePath()%>resources/js/jquery.qtip.min.js"></script>
        <script type="text/javascript" src="<%=bundle.packagePath()%>resources/js/moment.min.js"></script>
        <script type="text/javascript" src="<%=bundle.packagePath()%>resources/js/portfolioDetails.js"></script>
        <script src="http://code.highcharts.com/highcharts.js"></script>
        <script src="http://code.highcharts.com/modules/exporting.js"></script>
    </head>
    <body>
        <div class="view-port">
            <%@include file="interface/fragments/navigationSlide.jspf"%>
            <div class="content-slide" data-target="div.navigation-slide">
                <%@include file="interface/fragments/header.jspf"%>
                <div class="pointer-events">
                    <header>
                        <div class="container">
                            <h2><%= currentTemplate.getName()%></h2>
                            <hr class="soften">
                        </div>
                    </header>
                    <section class="container">
                        <div class="row">
                            <div class="profile col-sm-5">
                                <% if (currentTemplate.hasTemplateAttribute("ServiceItemImage")) { %>
                                    <div class="image">
                                        <img width="120px" src="<%= ServiceItemImageHelper.buildImageSource(currentTemplate.getTemplateAttributeValue("ServiceItemImage"), bundle.getProperty("serviceItemImagePath"))%>" />
                                    </div>
                                <%}%>
                                <p>
                                    <strong>Status:</strong> <i><%= currentTemplate.getStatus()%></i>
                                    <% if (!currentTemplate.getType().equals("")) { %>
                                        <br />
                                        <strong>Type:</strong> <i><%= currentTemplate.getType()%></i>
                                    <% }%>
                                    <% if (!currentTemplate.getDisplayName().equals("")) { %>
                                        <br />
                                        <strong>Display Name:</strong> <i><%= currentTemplate.getDisplayName()%></i>
                                    <% }%>
                                    <% if (!currentTemplate.getCategorizationString().equals("")) { %>
                                        <br />
                                        <strong>Categories:</strong> <i><%= currentTemplate.getCategorizationString()%></i>
                                    <% }%>
                                    <% if (!currentTemplate.getModified().equals("")) { %>
                                        <br />
                                        <strong>Active:</strong> <i><span class="modified" data-value="<%= currentTemplate.getModified()%>"><%= currentTemplate.getModified()%></span></i>
                                    <% }%>
                                </p>
                                <p class="description">
                                    <% if(!currentTemplate.getDescription().equals("")) {%> 
                                        <%= currentTemplate.getDescription()%>
                                    <%} else {%>
                                        <i>Description Not Configured</i>
                                    <%}%>
                                </p>
                            </div>
                            <div id="info-chart" class="col-sm-7"></div>
                        </div>
                        <div class="row">
                            <div class="col-md-12">
                                <% if(templateAttributeMap.size() > 1) {%>
                                    <h3>Attributes</h3>
                                    <hr class="soften">
                                    <ul class="attributes unstyled">
                                        <%
                                        for (Map.Entry<String, List<TemplateAttribute>> entry : templateAttributeMap.entrySet()) {
                                            List templateAttributeList = entry.getValue();
                                            for (Iterator<TemplateAttribute> iterator = templateAttributeList.iterator(); iterator.hasNext();) {
                                              TemplateAttribute templateAttribute = iterator.next();
                                                // check for profile
                                                TemplateProfile attributeProfile = null;
                                                for (Map.Entry<String, String> profile : profiles.entrySet()){
                                                    if( profile.getKey().equals(templateAttribute.getName()) ){
                                                        attributeProfile = TemplateProfile.find(context, profile.getValue(), templateAttribute.getValue());
                                                    }
                                                }
                                        %>
                                            <li>
                                                <strong><%= templateAttribute.getName()%>:</strong> <%= templateAttribute.getValue()%>
                                                <% 
                                                if(attributeProfile != null){ 
                                                %>
                                                    <div class="attribute-description"><%= attributeProfile.getDescription()%></div>
                                                <% } %>
                                                <%
                                                if(templateAttribute.getName().equals("Cost Profile")){
                                                    TemplateCostDetail[] costDetails = TemplateCostDetail.find(context, currentTemplate.getTemplateAttributeValue("Cost Profile"));
                                                    if(costDetails.length > 0){
                                                        for(TemplateCostDetail costDetail : costDetails){
                                                %>
                                                    <ul class="cost-details">
                                                        <li><%= costDetail.getDefinedInputBase()%>
                                                            <ul class="cost-nested">
                                                                <li><%= costDetail.getActualEstimate()%></li>
                                                                <li><%= costDetail.getExpenseType()%></li>
                                                                <% if(costDetail.getQuantity() != null && costDetail.getQuantity() != "" && costDetail.getAmountUnits() != null && costDetail.getAmountUnits() != "" ){ 
                                                                    DecimalFormat df = new DecimalFormat("#.00");
                                                                    String totalCost = df.format(Double.valueOf(costDetail.getQuantity()) * Double.valueOf(costDetail.getAmountUnits()));
                                                                %>
                                                                    <li>$<%= totalCost %></li>
                                                                <% } %>
                                                                <li><%= costDetail.getCostDescription()%></li>
                                                            </ul>
                                                        </li>
                                                    </ul>
                                                <%      }
                                                    } 
                                                }%>
                                            </li>
                                        <%
                                            }
                                        }
                                        %>
                                    </ul>
                                <%} else {%>
                                    <p>
                                        <i>Attributes Not Configured</i>
                                    </p>
                                <%}%>
                            </div>
                        </div>
                        <div class="row">
                            <div class="col-md-12">
                                <% if(currentTemplate.getCategories().length > 0) {%>
                                    <% 
                                        // Build linked hash map for JSON conversion
                                        Map<String, TemplatePortfolio> relatedServices = new LinkedHashMap<String, TemplatePortfolio>();
                                        for(CategoryPortfolio templateCategory : currentTemplate.getCategories()) {
                                            for(TemplatePortfolio template : templateCategory.getTemplates()) {
                                                if(!template.getName().equals(currentTemplate.getName())) {
                                                    relatedServices.put(template.getName(), template);
                                                }
                                            }
                                        }
                                    %>
                                    <% if(relatedServices.size() > 0) {%>
                                        <h3>Related Services</h3>
                                        <hr class="soften">
                                        <ul class="related-services unstyled">
                                            <% for(TemplatePortfolio relatedService : relatedServices.values()) {%>
                                                <li>
                                                    <a href="<%= bundle.getProperty("portfolioDetailsUrl")%>&id=<%= relatedService.getId()%>"><%= relatedService.getName()%></a>
                                                </li>
                                            <%}%>
                                        </ul>
                                    <%}%>
                                <%} else {%>
                                    <p>
                                        <i>No Related Services</i>
                                    </p>
                                <%}%>
                            </div>
                        </div>
                    </section>
                </div>
                <%@include file="interface/fragments/footer.jspf"%>
            </div>
        </div>
        <script type="text/javascript">
        var chartData = <%= chartData %>;
        var chart = $('#info-chart').highcharts({
            chart: {
                type: 'spline',
                marginBottom: 60,
                events: {
                    click: function(e){
                        <% if(currentTemplate.hasTemplateAttribute("Info Path")){ %>
                        window.open('https://info.kineticdata.com/info_systems/<%=  currentTemplate.getTemplateAttributeValue("Info Path")%>','width=200,height=400');
                        <%}%>
                    }
                }
            },
            credits: {
                enabled: false
            },
            title: {
                text: ''
            },
            xAxis: {
                categories: chartData.days,
                labels: {
                    formatterr: function() {
                        var date = new Date(Date.parse(this.value));
                        console.log(date);
                        var isWeekend = date.getDay() % 6 == 0;
                        var defaultColor = this.axis.options.labels.style.color.toString();
                        var match = defaultColor.match(/^#([0-9a-fxA-FX])([0-9a-fxA-FX])([0-9a-fxA-FX])$/);
                        if (match) {
                            defaultColor = '#'+match[1]+match[1]+match[2]+match[2]+match[3]+match[3];
                        }
                        var color = Highcharts.Color(defaultColor).brighten(0.2).get();
                        var day = date.getDate().toString();
                        if (day.length == 1) { day = "0"+day; }
                        var monthNames = [ "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec" ];
                        var month = monthNames[date.getMonth()];

                        return isWeekend ? '<span style="color:'+color+';">'+month+' '+day+'</span>' : month+' '+day;
                    },
                    //step: 2,
                    x: 5,
                    y: 35,
                    align: 'right',
                    rotation: -45,
                    useHTML: true
                }
            },
            yAxis: {
                title: {
                    text: 'Submissions'
                },
                allowDecimals: false,
                min: 0
            },
            tooltip: {
                formatter: function() {
                    return '<span style="color:'+this.series.color+'">'+this.point.category+'</span>: <b>'+this.y+'</b>';
                }
            },
            plotOptions: {
                spline: {
                    lineWidth: 2,
                    states: {
                        hover: {
                            lineWidth: 2
                        }
                    },
                    marker: {
                        enabled: false
                    }
                }
            },
            legend: {
                enabled: false
            },
            series: [{
                name: 'Day',
                data: chartData.counts
            }]
        });
        </script>
    </body>
</html>
