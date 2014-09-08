<%@page contentType="text/html; charset=UTF-8"%>
<%@include file="../../framework/includes/packageInitialization.jspf"%>
<%
    if (context == null) {
        ResponseHelper.sendUnauthorizedResponse(response);
    } else {
        String articleId = request.getParameter("articleId");
        ProblemSolution problemSolution = ProblemSolution.findById(serverUser, articleId);
%>
<div class="article">
    <% if (problemSolution.getProblem() != null) { %>
    <div class="field">
        <div class="label">Problem</div>
        <div class="value"><%= problemSolution.getProblem() %></div>
    </div>
    <% } %>
    <% if (problemSolution.getSolution() != null) { %>
    <div class="field">
        <div class="label">Solution</div>
        <div class="value"><%= problemSolution.getSolution() %></div>
    </div>
    <% } %>
    <% if (problemSolution.getTechnicalNotes() != null) { %>
    <div class="field">
        <div class="label">Technical Notes</div>
        <div class="value"><%= problemSolution.getTechnicalNotes() %></div>
    </div>
    <% } %>
</div>
<%
   }
%>