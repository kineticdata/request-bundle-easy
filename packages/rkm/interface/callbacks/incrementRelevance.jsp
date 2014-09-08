<%@page contentType="text/html; charset=UTF-8"%>
<%@include file="../../framework/includes/packageInitialization.jspf"%>
<%
    if (context == null) {
        ResponseHelper.sendUnauthorizedResponse(response);
    } else {
        // Retrieve the article id url parameter and use it to retrieve the
        // general knowledge article.  Fields from this record will be used
        // when populating the action below.
        String articleId = request.getParameter("articleId");
        KnowledgeArticle article = KnowledgeArticle.findById(serverUser, articleId);

        // Create the entry that will represent the SYS:Action record.  Each
        // of the fields that is populated is either populated by a constant
        // value, or is derived from the knowledge article retrieved above.
        com.bmc.arsys.api.Entry entry = new com.bmc.arsys.api.Entry();
        // ID01 InstanceId, set to Instance Id of Knowledge Article
        entry.put(1000005888, new com.bmc.arsys.api.Value(article.getInstanceId()));
        // Start Date 01, set to the current time
        entry.put(1000005080, new com.bmc.arsys.api.Value(System.currentTimeMillis() / 1000));
        // Action, set to USEARTICLE
        entry.put(1000001151, new com.bmc.arsys.api.Value("USEARTICLE"));
        // Request ID02, set o to Doc ID of Knowledge Article
        entry.put(1000000205, new com.bmc.arsys.api.Value(article.getDocId()));
        // Request ID01, set to Request ID of Knowledge Article
        entry.put(1000000204, new com.bmc.arsys.api.Value(article.getId()));
        // Form Name01, set to the form name of the knowledege article form
        entry.put(1000000101, new com.bmc.arsys.api.Value("RKM:KnowledgeArticleManager"));
        // Description, set to Article Title (100 character max) of Knowledge Article
        String truncatedTitle;
        if (article.getTitle() != null && article.getTitle().length()>100) {
            truncatedTitle = article.getTitle().substring(0, 100);
        } else {
            truncatedTitle = article.getTitle();
        }
        entry.put(1000000000, new com.bmc.arsys.api.Value(truncatedTitle));
        // Request ID03, set to Company of Knowledge Article
        entry.put(304080700, new com.bmc.arsys.api.Value(article.getCompany()));
        // Submitter, set to the current user name
        entry.put(2, new com.bmc.arsys.api.Value(context.getUserName()));
        
        // Save the entry
        serverUser.createEntry("SYS:Action", entry);
    }
%>