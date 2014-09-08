<%-- Set the page content type, ensuring that UTF-8 is used. --%>
<%@page contentType="text/html; charset=UTF-8"%>
<%-- Include the package initialization file. --%>
<%@include file="framework/includes/packageInitialization.jspf"%>

<%-- Retrieve the Catalog --%>
<!DOCTYPE html>
<html>
    <head>
        <%-- Include the common content. --%>
        <%@include file="../../common/interface/fragments/head.jspf"%>
        <title>
            <%= bundle.getProperty("companyName")%>&nbsp;|&nbsp;Operations Support Console
        </title>

        <!-- Page Stylesheets -->
        <link rel="stylesheet" href="<%= bundle.packagePath()%>resources/css/jquery.qtip.css" type="text/css" />
        <link rel="stylesheet" href="<%= bundle.packagePath()%>resources/css/package.css" type="text/css" />
        <link rel="stylesheet" href="<%= bundle.packagePath()%>resources/css/supportConsole.css" type="text/css" />
        <!--[if lt IE 9]>
            <script type="text/javascript" src="<%=bundle.packagePath()%>resources/js/ECMAScript.functions.js"></script>
        <![endif]-->
        <!-- Javascript Plugins -->
        <script type="text/javascript" src="<%=bundle.packagePath()%>resources/js/moment.min.js"></script>
        <script type="text/javascript" src="<%=bundle.packagePath()%>resources/js/jquery.qtip.min.js"></script>
        <script type="text/javascript" src="<%=bundle.packagePath()%>resources/js/jquery.combobox.js"></script>
        <script type="text/javascript" src="<%=bundle.packagePath()%>resources/js/jquery.oscTable.js"></script>
        <script type="text/javascript" src="<%=bundle.packagePath()%>resources/js/jquery.alert.js"></script>
        <!-- Page Javascript -->
        <script type="text/javascript" src="<%=bundle.packagePath()%>resources/js/ajax.js"></script>
        <script type="text/javascript" src="<%=bundle.packagePath()%>resources/js/util.js"></script>
        <script type="text/javascript" src="<%=bundle.packagePath()%>resources/js/supportConsole.js"></script>
    </head>
    <body>
        <div class="view-port">
            <%@include file="../../common/interface/fragments/navigationSlide.jspf"%>
            <div class="content-slide" data-target="div.navigation-slide">
                <div class="fixed-header-spacer"></div>
                <div class="pointer-events">
                    <header class="main operations-support-console">
                        <div class="container">
                            <a href="<%= bundle.getProperty("homeUrl")%>">
                                <img src="<%= bundle.packagePath()%>resources/images/orange-grey-cogs.png" />
                                <div class="logo"><%= bundle.getProperty("companyName")%></div>
                            </a>
                            <h2>Operations Support Console</h2>
                            <ul class="list-unstyled">
                                <%@include file="../../common/interface/fragments/contentUser.jspf"%>
                            </ul>
                            <form class="ksr-search" method="get">
                                <p>
                                    <label class="infield" for="ksr-search">
                                        Search by KSR
                                    </label>
                                    <input id="ksr-search" class="form-control" name="ksrSearch" type="text"/>
                                </p>
                            </form>
                        </div>
                    </header>
                    <section class="container">
                        <p class="filter-search hide">
                            <a href="javascript:void(0);">Return To Filter Search</a>
                        </p>
                        <ul class="hide filters searched-filters">
                        </ul>
                        <div class="clearfix"></div>
                        <h3>
                            Submission Filter Search
                        </h3>
                        <form class="operations-support-console" method="get">
                            <div class="group wrap">
                                <p class="template-attributes primary">
                                    <label class="infield" for="template-filter">
                                        Add Template Filter
                                    </label>
                                    <select data-target="p.template-attribute-value">
                                    </select>
                                </p>
                                <p class="template-attribute-value dependent hide">
                                    <label class="infield" for="template-filter-value">
                                        Add Template Attribute Value
                                    </label>
                                    <select>
                                    </select>
                                </p>
                                <ul class="template-attributes nested">
                                </ul>
                            </div>
                            <div class="wrap">
                                <p class="templates">
                                    <label class="infield" for="add-templates">
                                        Add Templates
                                    </label>
                                    <select data-target="ul.template-filters" data-type="template">
                                    </select>
                                    <ul class="filters template-filters non-nested">
                                    </ul>
                                </p>
                            </div>
                            <hr class="soften">
                            <!-- Not in use yet
                            <div class="wrap hide">
                                <p class="request-by">
                                    <label class="hide">Add Requested By</label>
                                    <select data-target="ul.request-by-filters" data-type="Requested By">
                                        <option value=""></option>
                                        <option value="Demo">Demo</option>
                                    </select>
                                </p>
                                <ul class="filters request-by-filters">
                                </ul>
                            </div>
                            <div class="wrap hide">
                                <p class="request-for">
                                    <label class="hide">Add Requested For</label>
                                    <select data-target="ul.request-for-filters" data-type="Requested For">
                                        <option value=""></option>
                                        <option value="Demo">Demo</option>
                                    </select>
                                </p>
                                <ul class="filters request-for-filters">
                                </ul>
                            </div> -->
                            <div class="wrap">
                                <p class="status">
                                    <label class="infield" for="status">Add Status</label>
                                    <select data-target="ul.status-filters" data-type="Status">
                                        <option value=""></option>
                                        <option value="Open">Open</option>
                                        <option value="Processing">Processing</option>
                                        <option value="Closed">Closed</option>
                                        <option value="Canceled">Canceled</option>
                                    </select>
                                </p>
                                <ul class="filters status-filters non-nested">
                                </ul>
                            </div>
                            <div class="wrap">
                                <p class="display-status">
                                    <label class="infield" for="display-status">
                                        Add Display Status
                                    </label>
                                    <select data-target="ul.display-status-filters" data-type="Display Status">
                                        <option value=""></option>
                                        <% for (String status : bundle.getProperty("oscDisplayStatuses").split(",")) { %>
                                            <option value="<%=status%>"><%=status%></option>
                                        <% } %>
                                    </select>
                                </p>
                                <ul class="filters display-status-filters non-nested">
                                </ul>
                            </div>
                            <div class="wrap">
                                <p class="answers">
                                    <label class="infield" for="answer">
                                        Add Answer
                                    </label>
                                    <select data-target="p.answer-value">
                                    </select>
                                </p>
                                <p class="answer-value hide">
                                    <label class="infield" for="answer-value">
                                        Answer Value
                                    </label>
                                    <input type="text" id="answer-value" class="form-control ui-value-input ui-state-default ui-corner-left ui-corner-right" name="answerValue" value="" data-target="ul.answers" data-type="answerFilters" />
                                </p>
                                <div class="error-message">
                                </div>
                                <ul class="answers nested">
                                </ul>
                            </div>
                            <div class="wrap">
                                <p class="attributes">
                                    <label class="infield" for="attribute">
                                        Add Attribute
                                    </label>
                                    <select data-target="p.attribute-value">
                                    </select>                 
                                </p>
                                <p class="attribute-value hide">
                                    <label class="infield" for="attribute-value">
                                        Add Attribute Value
                                    </label>
                                    <input type="text" id="attribute-value" class="form-control ui-value-input ui-state-default ui-corner-left ui-corner-right" name="attributeValue" value="" data-target="ul.attributes" data-type="attributeFilters" />
                                </p>
                                <div class="error-message">
                                </div>
                                <ul class="attributes nested">
                                </ul>
                            </div>
                            <div class="wrap">
                                <p class="ranges-created">
                                    <label>
                                        Created:
                                    </label>
                                    <select class="range form-control" data-type="created">
                                        <option value="Past Hour">Past Hour</option>
                                        <option value="Past Day">Past Day</option>
                                        <option value="Past Week" selected>Past Week</option>
                                        <option value="Past Month">Past Month</option>
                                        <option value="Anytime">Anytime</option>
                                        <option value="Custom">Custom</option>
                                    </select>
                                </p>
                                <p class="ranges-updated">
                                    <label>
                                        Updated:
                                    </label>
                                    <select class="range form-control" data-type="updated">
                                        <option value="Past Hour">Past Hour</option>
                                        <option value="Past Day">Past Day</option>
                                        <option value="Past Week">Past Week</option>
                                        <option value="Past Month">Past Month</option>
                                        <option value="Anytime" selected>Anytime</option>
                                        <option value="Custom">Custom</option>
                                    </select>
                                </p>
                            </div>
                            <p>
                                <input class="templateButton btn-orange" type="submit" value="Search" />
                            </p>
                        </form>
                        <div id="loader" class="hide">
                            <img alt="Please Wait." src="<%=bundle.bundlePath()%>common/resources/images/spinner.gif" />
                            <br />
                            Loading Results
                        </div>
                        <div class="hide results"></div>
                        <div class="hide results-message">
                        </div>
                    </section>
                </div>
            <%@include file="../../common/interface/fragments/footer.jspf"%>
            </div>
        </div>
    </body>
</html>
