public class MatchingEngine implements Queueable {
    
    List<Id> recordIds;
    Boolean candidateMode;
    
    public String contactQuery() {
        String result = '';
        result += 'SELECT ';
        result += '   Id, ';
        result += '   Name, 	';
        result += '   Experience_Type__c, ';
        result += '   Final_Education_Level__c, ';
        result += '   Last_Position__c, ';
        result += '   Max_Travel_Distance__c, ';
        result += '   (Select Id, Name, Skill__c, Skill__r.Name From Contact_Skills__r), ';
        result += '   (Select Id, Name, Language__c, Language__r.Name FROM Contact_Languages__r), ';
        result += '   (Select Id, Name, Sector__c, Sector__r.Name From Contact_Sectors__r),';
        result += '   Work_Frequency_Type_Monthly__c,';
        result += '   Work_Frequency_Type_Weekly__c,';
        result += '   Work_from_home__c';
        result += ' FROM ';
        result += '   CONTACT '; 
        result += ' WHERE '; 
        result += '     Profile_Complete__c = true';
        result += ' AND Eligible_to_Work_in_the_UK__c = true';
        
        if (candidateMode) {
            result += ' AND Id IN (\'' + String.join(recordIds, '\',\'') + '\')';
        }
        return result;
    }
    
    public String requirementQuery() {
        String result = '';
        result += 'SELECT'; 
        result += '  Id,'; 
        result += '  Experience_Type__c,'; 	
        result += '  Final_Education_Level__c,'; 
        result += '  Laptop__c,'; 
        result += '  Level_Required__c,';
        result += '  (Select Id, Name, Skill__c, Skill__r.Name From Desired_Skills__r),'; 
        result += '  (Select Id, Name, Language__c, Language__r.Name FROM Desired_Languages__r),'; 
        result += '  (Select Id, Name, Sector__c, Sector__r.Name From Desired_Sectors__r),';
        result += '  Work_Frequency_Type_Monthly__c,';
        result += '  Work_Frequency_Type_Weekly__c';
        result += ' FROM '; 
        result += '    Requirement__c'; 
        result += ' WHERE '; 
        result += '    Completed__c = true';
            
        if (!candidateMode) {
            result += ' AND Id IN (\'' + String.join(recordIds, '\',\'') + '\')';
        }
        
        return result;
    }
    
    public MatchingEngine(List<Id> recordIds, Boolean candidateMode) {
    	this.candidateMode = candidateMode;
        this.recordIds = recordIds;
    }
    
    public void execute(QueueableContext context) {
        
        List<Contact> contacts = (List<Contact>) Database.query(contactQuery());
        List<Requirement__c> requirements = (List<Requirement__c>) Database.query(requirementQuery());
        
        // Iterate and create records
        List<Match__c> matches = new List<Match__c>();
        for (Requirement__c requirement : requirements) {
            
            Decimal totalScore = ScoringEngine.totalScore(requirement);
            
            if (totalScore > 0) {
            	for (Contact candidate : contacts) {
                    matches.add(
                        new Match__c(
                            Requirement__c = requirement.Id, 
                            Contact__c = candidate.Id, 
                            Score__c = (ScoringEngine.score(requirement, candidate) / totalScore) * 100,
                            External_Id__c = requirement.Id + '|' + candidate.Id
                        )
                    );
                }    
            }
        }
        
        // Insert records
        upsert matches Match__c.External_Id__c;
    }
}