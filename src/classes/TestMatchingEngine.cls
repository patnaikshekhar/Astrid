@isTest
public class TestMatchingEngine {
	
    public static testmethod void contactQuery_PassingIds_GeneratesTheCorrectQuery() {
        
        Contact c1 = new Contact(LastName='Test');
        Contact c2 = new Contact(LastName='Test');
        insert c1;
        insert c2;
        
        MatchingEngine m = new MatchingEngine(new List<Id> {c1.Id, c2.Id}, true);
        
        Test.startTest();
        String result = m.contactQuery();
        Test.stopTest();
        
        System.assertEquals(true, result.contains('Id IN (\''+ c1.Id + '\',\'' + c2.Id + '\')') );
    }
    
    public static testmethod void requirementQuery_PassingIds_GeneratesTheCorrectQuery() {
        
        Account a1 = new Account(name = 'Test');
        Account a2 = new Account(name = 'Test');
        insert a1;
        insert a2;
        
        Requirement__c r1 = new Requirement__c(Account__c=a1.Id);
        Requirement__c r2 = new Requirement__c(Account__c=a2.Id);
        insert r1;
        insert r2;
        
        MatchingEngine m = new MatchingEngine(new List<Id> {r1.Id, r2.Id}, true);
        
        Test.startTest();
        String result = m.contactQuery();
        Test.stopTest();
        
        System.assertEquals(true, result.contains('Id IN (\''+ r1.Id + '\',\'' + r2.Id + '\')') );
    }
    
    public static testmethod void ContactTrigger_UpdatingAContactWithTheProfileCompletedFlag_StartsTheMatchingEngine() {
        Account a1 = new Account(name = 'Test');
        insert a1;
        
        Test.startTest();
        
        Requirement__c r1 = new Requirement__c(Account__c=a1.Id, Completed__c = true);
        insert r1;
        
        Contact c1 = new Contact(LastName='Test', Eligible_to_Work_in_the_UK__c = true);
        insert c1;
        
        c1.Profile_Complete__c = true;
        update c1;
        
        Test.stopTest();
        
        List<Match__c> matches = [SELECT Id, Requirement__c, Contact__c FROM Match__c];
        System.assertEquals(1, matches.size());
        System.assertEquals(r1.Id, matches[0].Requirement__c);
        System.assertEquals(c1.Id, matches[0].Contact__c);
    }
    
    public static testmethod void ContactTrigger_InsertingAContactWithTheProfileCompletedFlag_StartsTheMatchingEngine() {
        Account a1 = new Account(name = 'Test');
        insert a1;
        
        Test.startTest();
        
        Requirement__c r1 = new Requirement__c(Account__c=a1.Id, Completed__c = true);
        insert r1;
        
        Contact c1 = new Contact(LastName='Test', Eligible_to_Work_in_the_UK__c = true, Profile_Complete__c = true);
        insert c1;
        
        Test.stopTest();
        
        List<Match__c> matches = [SELECT Id, Requirement__c, Contact__c FROM Match__c];
        System.assertEquals(1, matches.size());
        System.assertEquals(r1.Id, matches[0].Requirement__c);
        System.assertEquals(c1.Id, matches[0].Contact__c);
    }
    
    public static testmethod void ContactTrigger_InsertingAContactWithoutTheProfileCompletedFlag_DoesNotStartTheMatchingEngine() {
        Account a1 = new Account(name = 'Test');
        insert a1;
        
        Requirement__c r1 = new Requirement__c(Account__c=a1.Id, Completed__c = true);
        insert r1;
                
        Test.startTest();
        
        Contact c1 = new Contact(LastName='Test', Eligible_to_Work_in_the_UK__c = true);
        insert c1;
        
        Test.stopTest();
        
        List<Match__c> matches = [SELECT Id, Requirement__c, Contact__c FROM Match__c];
        System.assertEquals(0, matches.size());
    }
    
    public static testmethod void ContactTrigger_UpdatingAContactWithoutTheProfileCompletedFlag_DoesNotStartTheMatchingEngine() {
        Account a1 = new Account(name = 'Test');
        insert a1;
        
        Requirement__c r1 = new Requirement__c(Account__c=a1.Id, Completed__c = true);
        insert r1;
        
        Contact c1 = new Contact(LastName='Test', Eligible_to_Work_in_the_UK__c = true);
        insert c1;
        
        Test.startTest();
        
        c1.FirstName = 'Test';
        update c1;
        
        Test.stopTest();
        
        List<Match__c> matches = [SELECT Id, Requirement__c, Contact__c FROM Match__c];
        System.assertEquals(0, matches.size());
    }
    
    public static testmethod void RequirementTrigger_UpdatingARequirementWithTheCompletedFlag_StartsTheMatchingEngine() {
        Account a1 = new Account(name = 'Test');
        insert a1;
        
        Test.startTest();
        
        Contact c1 = new Contact(LastName='Test', Eligible_to_Work_in_the_UK__c = true, Profile_Complete__c = true);
        insert c1;
        
        Requirement__c r1 = new Requirement__c(Account__c=a1.Id);
        insert r1;
        
        r1.Completed__c = true;
        update r1;
        Test.stopTest();
        
        List<Match__c> matches = [SELECT Id, Requirement__c, Contact__c FROM Match__c];
        System.assertEquals(1, matches.size());
        System.assertEquals(r1.Id, matches[0].Requirement__c);
        System.assertEquals(c1.Id, matches[0].Contact__c);
    }
    
    public static testmethod void RequirementTrigger_InsertingARequirementWithTheCompletedFlag_StartsTheMatchingEngine() {
        Account a1 = new Account(name = 'Test');
        insert a1;
        
        Test.startTest();
        
        Contact c1 = new Contact(LastName='Test', Eligible_to_Work_in_the_UK__c = true, Profile_Complete__c = true);
        insert c1;
        
        Requirement__c r1 = new Requirement__c(Account__c=a1.Id, Completed__c = true);
        insert r1;
        
        Test.stopTest();
        
        List<Match__c> matches = [SELECT Id, Requirement__c, Contact__c FROM Match__c];
        System.assertEquals(1, matches.size());
        System.assertEquals(r1.Id, matches[0].Requirement__c);
        System.assertEquals(c1.Id, matches[0].Contact__c);
    }
}