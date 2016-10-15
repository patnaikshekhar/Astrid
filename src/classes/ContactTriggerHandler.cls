public class ContactTriggerHandler {
    public static void beforeInsert(List<Contact> newList, Map<Id, Contact> newMap) {}
    public static void afterInsert(List<Contact> newList, Map<Id, Contact> newMap) {
        // Start Job
        startMatching(newList, new Map<Id,Contact>());
    }
    
    public static void beforeUpdate(List<Contact> oldList, Map<Id, Contact> oldMap, List<Contact> newList, Map<Id, Contact> newMap) {}
    
    public static void afterUpdate(List<Contact> oldList, Map<Id, Contact> oldMap, List<Contact> newList, Map<Id, Contact> newMap) {
        // Start Job
        startMatching(newList, oldMap);
    }
    
    public static void startMatching(List<Contact> contacts, Map<Id, Contact> oldMap) {
        List<Id> contactIdsToStartJobFor = new List<Id>();
        for (Contact con : contacts) {
            if (con.Profile_Complete__c) {
                if (oldMap.containsKey(con.Id)) {
                    if(!oldMap.get(con.Id).Profile_Complete__c) {
                        contactIdsToStartJobFor.add(con.Id);
                    }    
                } else {
                    contactIdsToStartJobFor.add(con.Id);
                } 
            }
        }
        
        if (contactIdsToStartJobFor.size() > 0) {
            System.enqueueJob(new MatchingEngine(contactIdsToStartJobFor, true));
        }
    }
}