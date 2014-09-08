<%@page contentType="text/html; charset=UTF-8"%>
<%@include file="../../framework/includes/packageInitialization.jspf"%>
<%
    if (context == null) {
        ResponseHelper.sendUnauthorizedResponse(response);
    } else {
        try {
            // Retrieve the search terms from the request parameters.
            String mustHave = request.getParameter("mustHave");
            String mayHave = request.getParameter("mayHave");
            String mustNotHave = request.getParameter("mustNotHave");

            // Perform the multi form search and write the result to the out
            // stream.
            MultiFormSearch mfs = new MultiFormSearch(mustHave, mayHave, mustNotHave, systemUser);
            String jsonData = mfs.search(serverUser);
            out.println(jsonData);
        } catch (Exception e) {
            // Write the exception to the kslog and re-throw it
            logger.error("Exception in RKMQuery.json.jsp", e);
            throw e;
        }
    }
%>