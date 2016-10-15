public class AstridGenericFormController {
	
    @AuraEnabled
    public static List<String> getPicklistValues(String objectName, String fieldName) {
        List<String> result = new List<String>();
        
        Schema.DescribeSobjectResult[] results = Schema.describeSObjects(new List<String> { objectName });
        for(Schema.DescribeSobjectResult res : results) {
            Map<String, Schema.SObjectField> fieldMap = res.fields.getMap();
            if (fieldMap.containsKey(fieldName)) {
                Schema.DescribeFieldResult fieldResult = fieldMap.get(fieldName).getDescribe();
                for (Schema.PicklistEntry entry : fieldResult.getPicklistValues()) {
                    result.add(entry.getValue());
                }
             }
        }
        
        return result;
    }
    
    @AuraEnabled
    public static List<sObject> query(String query) {
        return Database.query(query);
    }
}