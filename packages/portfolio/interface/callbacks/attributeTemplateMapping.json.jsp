<%@page contentType="application/json; charset=UTF-8"%>
<%@include file="../../framework/includes/packageInitialization.jspf"%>
<%
    if (context == null) {
        ResponseHelper.sendUnauthorizedResponse(response);
    } else {
        // Retrieve the main catalog object
        CatalogPortfolio catalog = CatalogPortfolio.findByName(context, bundle.getProperty("catalogName"));
        catalog.preload(context);

        // Define vars
        //Map<String,List<String>> attributeMap = new LinkedHashMap<String,List<String>>();
        Map<String,Map<String,Map<String,TemplatePortfolio>>> mappedTemplates = new TreeMap<String,Map<String,Map<String,TemplatePortfolio>>>();
        
        // For each of the Templates in the catalog
        for (TemplatePortfolio template : catalog.getTemplates(context)) {
            // For each of the template attribute instances
            for (String attributeName : template.getTemplateAttributeNames()) {
                if (attributeName == null || "".equals(attributeName)) {break;}
                //attributeMap.put(template.getName()+"["+attributeName+"]", Arrays.asList(template.getTemplateAttributeValues(attributeName)));

                // Ensure the attribute value map for the current attribute name exists
                Map<String,Map<String,TemplatePortfolio>> valueMap = mappedTemplates.get(attributeName);
                if (valueMap == null) {
                    valueMap = new TreeMap<String,Map<String,TemplatePortfolio>>();
                    mappedTemplates.put(attributeName, valueMap);
                }

                //if (!mappedTemplates.containsKey(attributeName)) {
                //    mappedTemplates.put(attributeName, new TreeMap<String,Map<String,TemplatePortfolio>>());
                //}
                //Map<String,Map<String,TemplatePortfolio>> valueMap = mappedTemplates.get(attributeName);


                // For each of the attribute values
                for (String attributeValue : template.getTemplateAttributeValues(attributeName)) {
                    // Ensure the template map exists
                    Map<String,TemplatePortfolio> templateMap = valueMap.get(attributeValue);
                    if (templateMap == null) {
                        templateMap = new TreeMap<String,TemplatePortfolio>();
                        valueMap.put(attributeValue, templateMap);
                    }
                    // Add the template to the attribute name->value->templates map
                    templateMap.put(template.getName(), null);
                }
                // Build template map of templates that don't have the attribute
                Map<String,TemplatePortfolio> noMatchingTemplateMap = new TreeMap<String,TemplatePortfolio>();
                for (TemplatePortfolio test : catalog.getTemplates(context)) {
                    if(!test.hasTemplateAttribute(attributeName)) {
                        noMatchingTemplateMap.put(test.getName(), null);
                    }
                }
                valueMap.put("No Matching Attributes", noMatchingTemplateMap);
            }
        }
        out.print(JSONValue.toJSONString(mappedTemplates));
    }
%>