<jsp:useBean id="UserContext" scope="session" class="com.kd.kineticSurvey.beans.UserContext"/>

<%
	String templateId = request.getParameter("templateInstanceID");
	String langValue = request.getParameter("language");
	System.out.println("Template ID: " + templateId + ".  Language Value: " + langValue);
        
        try {
            // update the Session Variable that was user (or created) when the page was loaded.
            session.setAttribute(templateId+"-DisplayLanguage",langValue);
			
			%>SUCCESSFUL<%
			
        } catch (Exception e){
%>
			FAILED (<%=e.getCause()%>)
<%
        }
%>
