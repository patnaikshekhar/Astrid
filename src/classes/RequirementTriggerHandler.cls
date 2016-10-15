public class RequirementTriggerHandler {
	public static void beforeInsert(List<Requirement__c> newList, Map<Id, Requirement__c> newMap) {}
    public static void afterInsert(List<Requirement__c> newList, Map<Id, Requirement__c> newMap) {
        // Start Job
        startMatching(newList, new Map<Id,Requirement__c>());
    }
    
    public static void beforeUpdate(List<Requirement__c> oldList, Map<Id, Requirement__c> oldMap, List<Requirement__c> newList, Map<Id, Requirement__c> newMap) {}
    
    public static void afterUpdate(List<Requirement__c> oldList, Map<Id, Requirement__c> oldMap, List<Requirement__c> newList, Map<Id, Requirement__c> newMap) {
        // Start Job
        startMatching(newList, oldMap);
    }
    
    public static void startMatching(List<Requirement__c> requirements, Map<Id, Requirement__c> oldMap) {
        List<Id> reqIdsToStartJobFor = new List<Id>();
        for (Requirement__c req : requirements) {
            if (req.Completed__c) {
                if (oldMap.containsKey(req.Id)) {
                    if(!oldMap.get(req.Id).Completed__c) {
                        reqIdsToStartJobFor.add(req.Id);
                    }    
                } else {
                    reqIdsToStartJobFor.add(req.Id);
                } 
            }
        }
        
        if (reqIdsToStartJobFor.size() > 0) {
            System.enqueueJob(new MatchingEngine(reqIdsToStartJobFor, false));
        }
    }
}