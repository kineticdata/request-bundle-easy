<jsp:useBean id="UserContext" scope="session" class="com.kd.kineticSurvey.beans.UserContext"/>
<%@include file="../../../../core/framework/models/ArsBase.jspf" %>
<%@include file="../../../../common/framework/models/Preferences.jspf" %>
<%
	/* Defined here because this jsp will be called seperately. That is, not part of the Catalog jsp. */
    HelperContext context = UserContext.getArContext();
%>

<%
	String favValue = request.getParameter("value");
        
        try {
            // Save the Favorite Record
            Preference.addFavorite(context, context.getUserName(), favValue);
			
			%>SUCCESSFUL<%
			
        } catch (Exception e){
%>
			FAILED (<%=e.getCause()%>)
<%
        }
%>
