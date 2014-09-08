<%@page contentType="text/html; charset=UTF-8"%>
<%-- @include file="../../framework/includes/packageInitializationShim.jspf" --%>
<%@include file="../../framework/includes/packageInitialization.jspf"%>
<%
    if (context == null) {
        ResponseHelper.sendUnauthorizedResponse(response);
    } else {
        String id = request.getParameter("id");
        String templateId = request.getParameter("templateId");
        BridgeConnector connector = new KsrBridgeConnector(context, templateId);
        Map<String, String> parameters = new java.util.HashMap<String, String>();
        parameters.put("Submitter", context.getUserName());
        parameters.put("Work Order Id", id);
        Record workorderRecord = connector.retrieve("Activity Work Order", "By Work Order Id", parameters);
        parameters.clear();
        parameters.put("Work Order Id", id);
        String[] attributes = new String[]{"Source", "Type", "Created At", "Summary", "Details"};
		Map<String,String> metadata = new java.util.HashMap();
		metadata.put("order", "<"+"%=attribute[\"Created At\"]%"+">:asc");
        RecordList workInfoRecords = connector.search("Work Order Work Info", "By Work Order Id", parameters, metadata, attributes);
        out.clear();
%>
<div class="sourceDetails" title="Work Order Details">
    <div class="header">
        <div class="id"><%= id%></div>
        <div class="close"></div>
        <div class="clear"></div>
    </div>
    <div class="info">
        <div class="label">Priority</div>
		<div class="value"><a href="javascript:;" onclick="catalogHelper.popUpFulfillmentTypeDetails('workOrder')"><%= workorderRecord.get("Priority")%></a></div>
		<div class="label">Status</div>
        <div class="value"><%= workorderRecord.get("Status")%></div>
        <div class="clear"></div>
        <div class="label">Status Reason</div>
        <div class="value"><%= workorderRecord.get("Status Reason")%></div>
        <div class="clear"></div>
        <div class="label">Created At</div>
        <div class="value dateTime"><%= workorderRecord.get("Created At")%></div>
        <div class="clear"></div>
        <div class="label">Updated At</div>
        <div class="value dateTime"><%= workorderRecord.get("Updated At")%></div>
        <div class="clear"></div>
		<div class="label">Summary</div>
        <div class="value"><%= workorderRecord.get("Summary")%></div>
        <div class="clear"></div>
    </div>
    <div class="workLog">
		<div class="workLogTitle">Work Information Entries</div>
        <% CycleHelper zebraCycle = new CycleHelper(new String[]{"odd", "even"});%>
        <% for (Record workInfo : workInfoRecords) { %>
        <div class="workInfo <%= zebraCycle.cycle()%>">
            <div class="label">Type</div>
            <div class="value"><%= workInfo.get("Type")%></div>
            <div class="clear"></div>
			<div class="label">Created At</div>
            <div class="value dateTime"><%= workInfo.get("Created At")%></div>
            <div class="clear"></div>
			<div class="label">Summary</div>
            <div class="value"><%= workInfo.get("Summary")%></div>
            <div class="clear"></div>
			<div class="label">Details</div>
            <div class="value"><% if (workInfo.get("Details")!=null){%><%=workInfo.get("Details").replaceAll("\n","<br>")%><%}%></div>
            <div class="clear"></div>
        </div>
        <% } %>
    </div>
</div>
<%
    }
%>