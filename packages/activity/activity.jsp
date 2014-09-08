<%-- Set the page content type, ensuring that UTF-8 is used. --%>
<%@page contentType="text/html; charset=UTF-8"%>

<%-- Include the package initialization file. --%>
<%@include file="framework/includes/packageInitialization.jspf"%>

<!DOCTYPE html>

<html>
    <head>
        <title><%= bundle.getProperty("catalogName")%></title>

        <%-- Include the common content. --%>
		<%-- @include file="interface/fragments/headContent.jspf" --%>
		<%@include file="../../core/interface/fragments/applicationHeadContent.jspf"%>
        <%@include file="../../common/interface/fragments/head.jspf"%>
        
        <!-- Page Stylesheets -->
        <link rel="stylesheet" href="<%= bundle.packagePath()%>resources/css/activity.css" type="text/css">
		<link rel="stylesheet" href="<%= bundle.packagePath()%>resources/css/activityDialog.css" type="text/css">
        <link rel="stylesheet" href="<%= bundle.packagePath()%>resources/css/messages.css" type="text/css">
        <link rel="stylesheet" href="<%= bundle.packagePath()%>resources/css/dialog.css" type="text/css">
        <link rel="stylesheet" href="<%= bundle.packagePath()%>resources/css/misc.css" type="text/css">
        <!-- Page Javascript -->
        <script type="text/javascript" src="<%=bundle.packagePath()%>resources/js/date.format.js"></script>
        <script type="text/javascript" src="<%=bundle.packagePath()%>resources/js/jquery.dataTables.js"></script>
        <script type="text/javascript" src="<%=bundle.packagePath()%>resources/js/activityTable.js"></script>
        <script type="text/javascript" src="<%=bundle.packagePath()%>resources/js/activity.js"></script>
        <script type="text/javascript">
            BUNDLE.config.locale = '<%= context.getContext().getLocale() %>';
        </script>
    </head>

    <body>
        <div id="bodyContainer">
            <%-- @include file="interface/fragments/contentHeader.jspf" --%>
			<%@include file="../../common/interface/fragments/header.jspf"%>
            <div id="contentBody">
                <div id="messages" class="messages">
                    <div class="message success "><span class="label">Viewing: </span><span class="content"></span></div>
                    <div class="message loading "><span class="label">Loading </span><span class="content"></span><img height="20" src="<%= bundle.bundlePath()%>packages/activity/resources/images/spinner_00427E_FFFFFF.gif"></div>
                    <div class="message error "><span class="label">Error: </span><span class="content"></span></div>
                </div>
                <div id="overlayContainer">
                    <div id="overlay"></div>
                    <%@include file="interface/fragments/defaultControls.jspf"%>
                    <div id="tableContainer" class="tableContainer">
                        <table id="status"></table>
                    </div>
                </div>
            </div>
            <%@include file="../../common/interface/fragments/footer.jspf"%>
        </div>
    </body>
</html>
