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
%>
<!DOCTYPE html>
<html>
    <head>
        <%-- Include the common content. --%>
        <%@include file="../../common/interface/fragments/head.jspf"%>
        <title>
            <%= bundle.getProperty("companyName")%>&nbsp;|&nbsp;About
        </title>
        <!-- Common Flyout navigation -->
        <script type="text/javascript" src="<%=bundle.bundlePath()%>common/resources/js/flyout.js"></script>

        <!-- Page Stylesheets -->
        <link rel="stylesheet" href="<%= bundle.packagePath()%>resources/css/about.css" type="text/css" />
        <%-- Include the application head content. --%>
        <%@include file="../../core/interface/fragments/applicationHeadContent.jspf"%>
        <%@include file="../../core/interface/fragments/displayHeadContent.jspf"%>
        <%-- Include the form head content, including attached css/javascript files and custom header content --%>
        <%@include file="../../core/interface/fragments/formHeadContent.jspf"%>

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
        <div class="sticky-footer">
            <%@include file="../../common/interface/fragments/header.jspf"%>
            <section class="container">
                <%@include file="../../core/interface/fragments/displayBodyContent.jspf"%>
            </section>
            <div class="sticky-footer-push"></div>
        </div>
        <%@include file="../../common/interface/fragments/footer.jspf"%>
    </body>
</html>