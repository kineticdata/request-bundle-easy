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

	Template currentTemplate = catalog.getTemplateByName(customerRequest.getTemplateName());
    if(currentTemplate == null) {
        throw new Exception("Current template does not exist!");
    }
	
    // Get map of description templates
    Map<String, String> templateDescriptions = DescriptionHelper.getTemplateDescriptionMap(context, catalog);
    // Get popular requests
    HelperContext systemContext = com.kd.kineticSurvey.impl.RemedyHandler.getDefaultHelperContext();
    List<String> globalTopTemplates = SubmissionStatisticsHelper.getMostCommonTemplateNames(systemContext, new String[] {customerRequest.getCatalogName()}, templateTypeFilterTopSubmissions, 5);
	
	String chartData1 = SubmissionStatistic.getRecentSubmissionJsonDataAll(context, customerRequest.getCatalogName());
	String chartData2 = SubmissionStatistic.getRecentMissedSLAJsonDataAll(context, customerRequest.getCatalogName());
	String chartData3 = SubmissionStatistic.getAgingJsonDataAll(context, customerRequest.getCatalogName());
    String chartData4 = SubmissionStatistic.getServiceItemJsonDataAll(context, customerRequest.getCatalogName());
%>
<!DOCTYPE html>
<html>
    <head>
        <%-- Include the common content. --%>
        <%@include file="../../common/interface/fragments/head.jspf"%>
        <title>
            <%= bundle.getProperty("companyName")%>&nbsp;Home
        </title>
		
		<%-- Include the application head content. --%>
        <%@include file="../../core/interface/fragments/applicationHeadContent.jspf"%>
        <%@include file="../../core/interface/fragments/displayHeadContent.jspf"%>
		
        <!-- Page Stylesheets -->
        <link rel="stylesheet" href="<%= bundle.packagePath()%>resources/css/package.css" type="text/css" />
        
		<link rel="stylesheet" href="<%= bundle.packagePath()%>resources/css/adminDashboard.css" type="text/css" />
        <!-- Language Javascript -->
        <script type="text/javascript" src="<%=bundle.bundlePath()%>common/resources/js/languageChange.js"></script>
		<!-- Page Javascript -->
		<script type="text/javascript" src="<%=bundle.packagePath()%>resources/js/package.js"></script>
        
        <script type="text/javascript" src="<%=bundle.packagePath()%>resources/js/jquery.ba-hashchange.min.js"></script>
		<script src="https://code.highcharts.com/highcharts.js"></script>
        <script src="https://code.highcharts.com/modules/exporting.js"></script>
    </head>
    <body>
        <div class="view-port">
            <%@include file="../../common/interface/fragments/navigationSlide.jspf"%>
            <div class="content-slide" data-target="div.navigation-slide">
                <%@include file="../../common/interface/fragments/header.jspf"%>
                <div class="pointer-events">
                    <%--@include file="interface/fragments/flyout.jspf"--%>
                    <section class="container">
						<div class="adminTitle">
							Administration Dashboard
						</div>
						<div class="vertical-spacer" style="clear:both">
                            <div id="info-chart-1" class="col-sm-6" style="clear:left;"></div>
                            <div id="info-chart-2" class="col-sm-6"></div>
                            <div class="vertical-spacer">&nbsp;</div>
							<div id="info-chart-3" class="col-sm-6" style="clear:left;"></div>
                            <div id="info-chart-4" class="col-sm-6" ></div>
						</div>&nbsp;
						<hr class="soften">
						<div class="vertical-spacer adminDashboards">
							<div class="col-sm-4">
								<div class="admin-widget priority-requests">
									<div class="widget-title">
										Priority Requests
									</div>
									<div class="widget-content">
										<ul>
											<li class="even"><span class="reference">KSR000000000123 - Hire someone</span></li>
											<li class="odd"><span class="reference">KSR000000000125 - iPad Request</span></li>
											<li class="even"><span class="reference">KSR000000002150 - Hire Someone</span></li>
											<li class="odd"><span class="reference">KSR000000006100 - Replace PC</span></li>
											<li class="even"><span class="reference">KSR000000011520 - New Account</span></li>
											<li class="odd"><span class="reference">KSR000000055872 - Badge Request</span></li>
										</ul>
									</div>
								</div>
							</div>
							<div class="col-sm-4">
								<div class="admin-widget sla-breach">
									<div class="widget-title">
										Nearing SLA Breach
									</div>
									<div class="widget-content">
										<ul>
											<li class="even"><span class="reference">KSR000000000123 - Hire Someone</span><span class="col-right">Due: 2014-05-18</span></li>
											<li class="odd"><span class="reference">KSR000000000125 - iPad Request</span><span class="col-right">Due: 2014-05-18</span></li>
											<li class="even"><span class="reference">KSR000000002150 - Hire Someone</span><span class="col-right">Due: 2014-05-18</span></li>
											<li class="odd"><span class="reference">KSR000000006100 - Replace PC</span><span class="col-right">Due: 2014-05-18</span></li>
											<li class="even"><span class="reference">KSR000000011520 - New Account</span><span class="col-right">Due: 2014-05-18</span></li>
											<li class="odd"><span class="reference">KSR000000055872 - Badge Order</span><span class="col-right">Due: 2014-05-18</span></li>
										</ul>
									</div>
								</div>
							</div>
							<div class="col-sm-4">
								<div class="admin-widget recent-changes">
									<div class="widget-title">
										Recent Changes
									</div>
									<div class="widget-content">
										<ul>
											<li class="even"><span class="reference">New Hire form updated to include Blackberry.</span></li>
											<li class="odd"><span class="reference">New DWS portal released.</span></li>
											<li class="even"><span class="reference">Form ABC process updated 2014-05-11.</span></li>
											<li class="odd"><span class="reference">Release of updated iPad Order Request delayed 2 weeks.</span></li>
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
                                Catalog
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
                        
                    </nav>
                </div>
                <%@include file="../../common/interface/fragments/footer.jspf"%>
            </div>
        </div>
		<script type="text/javascript">
        var chartData = <%= chartData1 %>;
        var chart = $('#info-chart-1').highcharts({
            chart: {
                type: 'spline',
                marginBottom: 70,
                borderWidth: 2,
                events: {
                    click: function(e){
                        <% if(currentTemplate.hasTemplateAttribute("Info Path")){ %>
                        window.open('https://info.kineticdata.com/info_systems/<%=  currentTemplate.getTemplateAttributeValue("Info Path")%>','width=200,height=400');
                        <%}%>
                    }
                },
                backgroundColor: "aliceblue"
            },
            credits: {
                enabled: false
            },
            title: {
                text: 'Submissions - Last 30 days'
            },
            xAxis: {
                categories: chartData.days,
                labels: {
                    formatter: function() {
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
                    rotation: -90,
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
		<script type="text/javascript">
        var chartData = <%= chartData2 %>;
        var chart = $('#info-chart-2').highcharts({
            chart: {
                type: 'column',
                marginBottom: 70,
                borderWidth: 2,
                events: {
                    click: function(e){
                        <% if(currentTemplate.hasTemplateAttribute("Info Path")){ %>
                        window.open('https://info.kineticdata.com/info_systems/<%=  currentTemplate.getTemplateAttributeValue("Info Path")%>','width=200,height=400');
                        <%}%>
                    }
                },
                backgroundColor: "rgb(255,250,173)",
            },
            credits: {
                enabled: false
            },
            title: {
                text: 'Missed SLAs - Last 30 days'
            },
            xAxis: {
                categories: chartData.days,
                labels: {
                    formatter: function() {
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
                    rotation: -90,
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
		<script type="text/javascript">
        var chartData = <%= chartData3 %>;
        var chart = $('#info-chart-3').highcharts({
            chart: {
                type: 'column',
                marginBottom: 70,
                borderWidth: 2,
                events: {
                    click: function(e){
                        <% if(currentTemplate.hasTemplateAttribute("Info Path")){ %>
                        window.open('https://info.kineticdata.com/info_systems/<%=  currentTemplate.getTemplateAttributeValue("Info Path")%>','width=200,height=400');
                        <%}%>
                    }
                },
                backgroundColor: "rgb(249,236,249)"
            },
            credits: {
                enabled: false
            },
            title: {
                text: 'Aging approvals'
            },
            xAxis: {
                categories: chartData.days,
                labels: {
                    //step: 2,
                    x: 5,
                    y: 35,
                    align: 'right',
                    rotation: -90,
                    useHTML: true
                },
                title: {
                    text: 'Days Outstanding'
                }
            },
            yAxis: {
                title: {
                    text: 'Approvals'
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
        <script type="text/javascript">
        
        var chartRawData = <%= chartData4 %>;
        var chartData = new Array(0);
        for (var serviceItem in chartRawData){
            chartData.push(new Array(serviceItem,chartRawData[serviceItem]));
        }
        
        var chart = $('#info-chart-4').highcharts({
            chart: {
                type: 'pie',
                marginBottom: 70,
                borderWidth: 2,
                events: {
                    click: function(e){
                        <% if(currentTemplate.hasTemplateAttribute("Info Path")){ %>
                        window.open('https://info.kineticdata.com/info_systems/<%=  currentTemplate.getTemplateAttributeValue("Info Path")%>','width=200,height=400');
                        <%}%>
                    }
                },
                backgroundColor: "rgb(236,246,207)"
            },
            credits: {
                enabled: false
            },
            title: {
                text: 'Service Item Usage - Last 30 days'
            },
            tooltip: {
                formatter: function() {
                    return '<span style="color:'+this.series.color+'">'+this.point.name+'</span>: <b>'+this.y+'</b>';
                }
            },
            plotOptions: {
            },
            legend: {
                enabled: false
            },
            series: [{
                name: 'Submissions',
                data: chartData
            }]
        });
        </script>
    </body>
</html>