<%@page contentType="application/json; charset=UTF-8"%>
<%@include file="../../../../core/framework/includes/bundleInitialization.jspf"%>
<%
    if (context == null) {
        ResponseHelper.sendUnauthorizedResponse(response);
    } else {
    /*
     * Here we are pulling the parameters for the ars helpers call from the request
     * object and processing a few of them as necessary.
     *
     * Retrieve the form and qualification parameters.  These are simply passed
     * as Strings and no further processing is needed.
     */
    String form = request.getParameter("form");
    String qualification = request.getParameter("qualification");

    /*
     * Retrieve the pageSize and pageNumber parameters.  These need to be converted
     * from Strings to ints.  Also we must use the pageSize and pageNumber values
     * to calculate the proper offset.
     */
    int pageSize = Integer.parseInt(request.getParameter("pageSize"));
    int pageNumber = Integer.parseInt(request.getParameter("pageNumber"));
    int pageOffset = (pageNumber - 1) * pageSize;

    /*
     * Retrieve the fieldIds parameters.  This is passed as a string with comma
     * separated values, therefor we will create a String array by splitting the
     * given string on comma.
     */
    String[] fieldIds = request.getParameter("fieldIds").split(",");

    /*
     * Retrieve the sortFieldIds parameter.  This is passed as a String but ars
     * helpers requires a String Array of sort field ids, therefore we create an
     * array of length 1 to passed to ars helpers.
     */
    String[] sortFieldIds = new String[]{request.getParameter("sortFieldId")};

    /*
     * Retrieve the sortOrder parameter.  This is passed as either "ascending" or
     * "descending".  Ars helpers expects a value of 1 for ascending sort order
     * and a value of 2 for a descending sort order.
     */
    int sortOrder = request.getParameter("sortOrder").equals("descending") ? 2 : 1;


    /*
     * Here we are preparing to make the ars helpers call.
     *
     * Here we verify that the context variable is not null, otherwise we cannot
     * continue with this operation
     */
    if (context == null) {
        throw new IllegalArgumentException("The \"context\" argument can't be null.");
    }

    /*
     * Retrieve the entries with the parameters gathered above.  Also retrieve a
     * count of the total number of entries that match the qualification.
     */
    SimpleEntry[] entries = ArsBase.find(context, form, qualification, fieldIds, sortFieldIds, pageSize, pageOffset, sortOrder);
    int count = ArsBase.count(context, form, qualification);

    /*
     * Here we are parsing the results of the ars helpers call and building the
     * json string that is to be returned by this page.
     */
    String[][] tableData = new String[entries.length][fieldIds.length];
    for (int i = 0; i < entries.length; i++) {
        SimpleEntry entry = entries[i];
        for (int j = 0; j < fieldIds.length; j++) {
            tableData[i][j] = entry.getEntryFieldValue(fieldIds[j]);
            logger.debug("this: " + tableData[i][j]);
        }
    }

    /*
     * Finally, iterate through the table data and print the JSON output.  Note
     * that we escape any new-line characters in the data.  We also escape the
     * double-quote chracter in the as well because they are our delimiter.
     */
        // Build result map
        Map<String,Object> results = new LinkedHashMap<String,Object>();
        results.put("count", count);
        results.put("limit", pageSize);
        results.put("offset", pageOffset);
        // Build submission array
        List<List> submissionData = new LinkedList<List>();
        for (int i = 0; i < tableData.length; i++) {
            List list1 = Arrays.asList(tableData[i]);
            submissionData.add(list1);
        }
        // Add submission array to data


                    logger.debug("TABLEJSON: " + submissionData);
        results.put("data", submissionData);
                            logger.debug("RESULTS: " + results);
        // Output json string
        out.print(JSONValue.toJSONString(results));

    }
%>