<%-- Set the page content type, ensuring that UTF-8 is used. --%>
<%@page contentType="text/html; charset=UTF-8"%>
<%-- Include the package initialization file. --%>
<%@include file="framework/includes/packageInitialization.jspf"%>

<!DOCTYPE html>
<html>
    <head>
        <%-- Include the common content. --%>
        <%@include file="../../common/interface/fragments/head.jspf"%>
        <title><%= bundle.getProperty("companyName") + " " + bundle.getProperty("catalogName")%></title>

        <!-- Page Stylesheets -->
        <link rel="stylesheet" href="<%= bundle.packagePath()%>resources/css/package.css" type="text/css" />
        <link rel="stylesheet" href="<%= bundle.packagePath()%>resources/css/oscDetails.css" type="text/css" />
        <!-- Page Javascript -->
        <script type="text/javascript" src="<%=bundle.packagePath()%>resources/js/moment.min.js"></script>
        <script type="text/javascript" src="<%=bundle.packagePath()%>resources/js/util.js"></script>
        <script type="text/javascript" src="<%=bundle.packagePath()%>resources/js/oscDetails.js"></script>
    </head>
    
    <body style="display:none;">
        <div class="view-port">
            <header class="operations-support-console">
                <div class="container">
                    <a href="http://www.kineticdata.com/">
                        <img src="<%= bundle.packagePath()%>resources/images/orange-grey-cogs.png" />
                        <div class="logo"><%= bundle.getProperty("companyName")%></div>
                    </a>
                    <h2>Operations Support Console</h2>
                </div>
            </header>
            <section class="container"></section>
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