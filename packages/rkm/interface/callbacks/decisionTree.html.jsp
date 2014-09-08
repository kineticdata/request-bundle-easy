<%@page contentType="text/html; charset=UTF-8"%>
<%@include file="../../framework/includes/packageInitialization.jspf"%>
<%
    if (context == null) {
        ResponseHelper.sendUnauthorizedResponse(response);
    } else {
        String articleId = request.getParameter("articleId");
        DecisionTree decisionTree = DecisionTree.findById(serverUser, articleId);
%>
<div class="article">
    <% if (decisionTree.getDecisionTree() != null) { %>
    <div class="field">
        <div class="label">Decision Tree</div>
        <div class="value"><%= decisionTree.getDecisionTree() %></div>
    </div>
    <% } %>
</div>
<%
   }
%>