public class CommunityUtilities {
	@AuraEnabled
    public static String getUsersFirstName() {
        return UserInfo.getFirstName();
    }
    
    @AuraEnabled
    public static GetContactProfileCompleteResponse getContactProfileComplete() {
        GetContactProfileCompleteResponse result = new GetContactProfileCompleteResponse();
        result.profileCompleted = true;
        
        List<User> currentUsers = [SELECT Id, ContactId FROM User WHERE Id = :UserInfo.getUserId()];
        if (currentUsers.size() > 0) {
            if (currentUsers[0].ContactId != null) {
            	result.contactId = currentUsers[0].ContactId;    
                List<Contact> contacts = [SELECT Id, Profile_Complete__c FROM Contact WHERE Id = :currentUsers[0].ContactId];
                if (contacts.size() > 0) {
                    result.profileCompleted = contacts[0].Profile_Complete__c;
                }
            }
        }
        
        return result;
    }
    
    public class GetContactProfileCompleteResponse {
        @AuraEnabled
        public String contactId;
        public Boolean profileCompleted;
    }
}