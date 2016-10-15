public without sharing class AstridCandidateRegistrationController {
    
    public class SimpleResponse {
        @AuraEnabled
        public String status;
        
        @AuraEnabled
        public String errorMessage = '';
        
        @AuraEnabled
        public String identifier;
    }
    
    public static final Integer MAX_USERS = 4;
    
    public static void inactivateOldUsers() {
        List<Profile> profiles = [SELECT Id FROM Profile WHERE Name = 'Astrid: Candidate User'];
        
        if (profiles.size() > 0) {
        	List<User> users = [SELECT Id, isActive FROM User WHERE isActive = true AND ProfileId = :profiles[0].Id ORDER BY CreatedDate DESC OFFSET :MAX_USERS];
            if (users.size() > 0) {
                for (User u : users) {
                    u.isActive = false;
                }
                
                update users;
            }
        } 
    }
    
    public static void createUser(Id contactId, String email, String firstName, String lastName) {
        List<Profile> profiles = [SELECT Id FROM Profile WHERE Name = 'Astrid: Candidate User'];
        
        if (profiles.size() > 0) {
        	User u = new User();
            u.ProfileId = profiles[0].Id;
            u.Username = email;
            u.FirstName = firstName;
            u.LastName = lastName;
            u.ContactId = contactId;
            u.IsActive = true;
            u.email = email;
            u.alias = (firstName + lastName + email).substring(0, 6);
            u.TimeZoneSidKey = 'GMT';
            u.LanguageLocaleKey = 'en_US';
            u.EmailEncodingKey = 'UTF-8';
            u.LocaleSidKey = 'en_US';
            insert u;
        } 
    }
    
    public static SimpleResponse validateStep1(Map<String,String> fields) {
        
        SimpleResponse result = new SimpleResponse();
        
        if (fields != null) {
            if (fields.containsKey('LastName')) {
                if (fields.get('LastName') == '') {
                    result.errorMessage += 'Last Name is required. ';	
                }    
            } else {
                result.errorMessage += 'Last Name is required. ';
            }
            
            if (fields.containsKey('FirstName')) {
                if (fields.get('FirstName') == '') {
                    result.errorMessage += 'First Name is required. ';	
                }    
            } else {
                result.errorMessage += 'First Name is required. ';
            }
            
            if (fields.containsKey('Email')) {
                if (fields.get('Email') == '') {
                    result.errorMessage += 'Email is required. ';	
                }    
            } else {
                result.errorMessage += 'Email is required. ';
            }
        } else {
            result.errorMessage += 'Unknown Error. ';
        }
        
        
        return result;
    }
    
    
    @AuraEnabled
    public static SimpleResponse createAccountAndContact(String sessionId, Map<String, String> fields) {
        
        SimpleResponse result = validateStep1(fields);
        
        if (result.errorMessage != '') {
            result.status = 'error';
        } else {
            
            Contact c = new Contact();
            
            if (sessionId == '' || sessionId == null) {
                RecordType art = [select Id from RecordType where Name = 'Candidate' and SobjectType = 'Account' limit 1];
                Account a = new Account(name = fields.get('FirstName') + fields.get('LastName'));
                a.RecordTypeId = art.Id;
                insert a;
                
                RecordType crt = [select Id from RecordType where Name = 'Candidate' and SobjectType = 'Contact' limit 1];
                
                for (String field : fields.keySet()) {
                    c.put(field, fields.get(field));
                }
                c.RecordTypeId = crt.Id;
                c.AccountId = a.Id;
                
                insert c;
                
                inactivateOldUsers();
                createUser(c.Id, fields.get('Email'), fields.get('FirstName'), fields.get('LastName'));
            } else {
                
                c.Id = sessionId;
                for (String field : fields.keySet()) {
                    c.put(field, fields.get(field));
                }
                update c;
            }
            
        	result.status = 'success';  
            result.identifier = c.Id;
        }
        
        return result;
    } 
    
    @AuraEnabled
    public static Map<String, Object> initializeStage1Fields(String sessionId) {
        return initializeContactFields(sessionId, 'Contact', new List<String>{ 'FirstName', 'LastName', 'Email', 'Phone', 'MobilePhone', 'Skype_Id__c', 'MailingStreet', 'MailingCity', 'MailingPostalCode', 'Charity__c'});
    }
    
    @AuraEnabled
    public static Map<String, Object> initializeStage2Fields(String sessionId) {
        return initializeContactFields(sessionId, 'Contact', new List<String>{ 'Eligible_to_Work_in_the_UK__c', 'Convicted_of_a_Criminal_Offence__c', 'Details_of_Criminal_Offence__c' });
    }
    
	@AuraEnabled
    public static Map<String, Object> initializeStage3Fields(String sessionId) {
        Map<String, Object> result = initializeContactFields(sessionId, 'Contact', new List<String>{ 'LinkedIn_Profile__c', 'Experience_Type__c' });
        
        // Get attachment names
        List<Attachment> attachments = [SELECT Id, Name FROM Attachment WHERE ParentId = :sessionId ORDER BY CREATEDDATE DESC];
        if (attachments.size() > 0) {
            result.put('CV', attachments[0].Name);
        }
        
        List<Contact_Skill__c> skills = [Select Id, Skill__c, Skill__r.Name FROM Contact_Skill__c WHERE Contact__c = :sessionId];
        if (skills.size() > 0) {
            List<Id> items = new List<Id>();
            for (Contact_Skill__c skill : skills) {
                items.add(skill.Skill__c);
            }
            
            result.put('skills', JSON.serialize(items));
        }
        
        return result;
    }
    
    @AuraEnabled
    public static Map<String, Object> initializeStage4Fields(String sessionId) {
        Map<String, Object> result = initializeContactFields(sessionId, 'Contact', new List<String>{ 'Last_Position__c' });
        
        List<Contact_Sector__c> sectors = [Select Id, Sector__c, Sector__r.Name FROM Contact_Sector__c WHERE Contact__c = :sessionId];
        if (sectors.size() > 0) {
            List<Id> items = new List<Id>();
            for (Contact_Sector__c sector : sectors) {
                items.add(sector.Sector__c);
            }
            
            result.put('sectors', JSON.serialize(items));
        }
        
        return result;
    }
    
    @AuraEnabled
    public static Map<String, Object> initializeStage5Fields(String sessionId) {
        return initializeContactFields(sessionId, 'Contact', new List<String>{ 'Final_Education_Level__c', 'Other_Qualifications__c' });
    }
    
    @AuraEnabled
    public static Map<String, Object> initializeStage6Fields(String sessionId) {
        Map<String, Object> result = initializeContactFields(sessionId, 'Contact', new List<String>{ 'Other_Languages__c' });
        
        List<Contact_Language__c> languages = [Select Id, Language__c, Language__r.Name FROM Contact_Language__c WHERE Contact__c = :sessionId];
        if (languages.size() > 0) {
            List<Id> items = new List<Id>();
            for (Contact_Language__c lang : languages) {
                items.add(lang.Language__c);
            }
            
            result.put('languages', JSON.serialize(items));
        }
        
        return result;
    }
    
    @AuraEnabled
    public static Map<String, Object> initializeStage7Fields(String sessionId) {
        return initializeContactFields(sessionId, 'Contact', new List<String>{ 'Work_Frequency_Type_Monthly__c', 'Work_Frequency_Type_Weekly__c' });
    }
    
    @AuraEnabled
    public static Map<String, Object> initializeStage8Fields(String sessionId) {
        return initializeContactFields(sessionId, 'Contact', new List<String>{ 'Work_from_home__c', 'Max_Travel_Distance__c' });
    }
    
    @AuraEnabled
    public static Map<String, Object> initializeStage9Fields(String sessionId) {
        return initializeContactFields(sessionId, 'Contact', new List<String>{ 'Profile_Complete__c ' });
    }
    
    @AuraEnabled
    public static Map<String, Object> intializeStep1Company(String sessionId) {
        Map<String, Object> result = initializeContactFields(sessionId, 'Account', new List<String> {'Id', 'Name', 'AccountNumber', 'BillingStreet', 'BillingCity', 'BillingPostalCode' });
        
        List<Contact> contacts = [SELECT Id, Name FROM Contact WHERE AccountId = :sessionId];
        if (contacts.size() > 0) {
           Map<String, Object> resultContact = initializeContactFields(contacts[0].Id, 'Contact', new List<String> { 'FirstName', 'LastName', 'Email', 'Phone', 'MobilePhone', 'Skype_Id__c' });
        
            for (String key : resultContact.keySet()) {
                result.put(key, resultContact.get(key));
            } 
        }
        
        
        return result;
    }
    
    @AuraEnabled
    public static Map<String, Object> intializeStep2Company(String sessionId) {
        return initializeContactFields(sessionId, 'Account', new List<String> {'Eligible__c', 'Agree_to_Terms__c'});
    }
    
    @AuraEnabled
    public static Map<String, Object> initializeStage1CreateReq(String sessionId) {
        Map<String, Object> result = initializeContactFields(sessionId, 'Requirement__c', new List<String>{ 'Level_Required__c' });
        
        List<Desired_Skill__c> skills = [Select Id, Skill__c, Skill__r.Name FROM Desired_Skill__c WHERE Requirement__c = :sessionId];
        if (skills.size() > 0) {
            List<Id> items = new List<Id>();
            for (Desired_Skill__c skill : skills) {
                items.add(skill.Skill__c);
            }
            
            result.put('skills', JSON.serialize(items));
        }
        
        return result;
    }
    
    @AuraEnabled
    public static Map<String, Object> initializeStage2CreateReq(String sessionId) {
        Map<String, Object> result = initializeContactFields(sessionId, 'Requirement__c', new List<String>{ 'Experience_Type__c' });
        
        List<Desired_Sector__c> sectors = [Select Id, Sector__c FROM Desired_Sector__c WHERE Requirement__c = :sessionId];
        if (sectors.size() > 0) {
            List<Id> items = new List<Id>();
            for (Desired_Sector__c sector : sectors) {
                items.add(sector.Sector__c);
            }
            
            result.put('sectors', JSON.serialize(items));
        }
        
        return result;
    }
    
    @AuraEnabled
    public static Map<String, Object> initializeStage3CreateReq(String sessionId) {
        Map<String, Object> result = initializeContactFields(sessionId, 'Requirement__c', new List<String>{ 'Final_Education_Level__c', 'Other_Language__c', 'Other_Qualifications__c' });
        
        List<Desired_Language__c> languages = [Select Id, Language__c FROM Desired_Language__c WHERE Requirement__c = :sessionId];
        if (languages.size() > 0) {
            List<Id> items = new List<Id>();
            for (Desired_Language__c language : languages) {
                items.add(language.Language__c);
            }
            
            result.put('languages', JSON.serialize(items));
        }
        
        return result;
    }
    
    @AuraEnabled
    public static Map<String, Object> initializeStage4CreateReq(String sessionId) {
        return initializeContactFields(sessionId, 'Requirement__c', new List<String> {'Work_Frequency_Type_Weekly__c', 'Work_Frequency_Type_Monthly__c', 'Laptop__c' });
    }
    
    @AuraEnabled
    public static Map<String, Object> initializeStage5CreateReq(String sessionId) {
        return initializeContactFields(sessionId, 'Requirement__c', new List<String> {'Completed__c'});
    }
    	
    public static Map<String, Object> initializeContactFields(String identifier, String objectName, List<String> fields) {
        
        Map<String, Object> result = new Map<String, Object>();
        String query = 'SELECT ' + String.join(fields, ', ') + ' FROM ' + objectName + ' WHERE ID = \'' + identifier +'\'';
        
        for (SObject o : Database.query(query)) {
            for (String field : fields) {
            	result.put(field, o.get(field));    
            }
        }
        
        return result;
    }
    
    public static SimpleResponse validateSession(String sessionId, Map<String, Object> fields) {
        
        SimpleResponse result = new SimpleResponse();
        
        if (sessionId == null || sessionId == '') {
            result.errorMessage += 'Invalid Session';	
        }
        
        return result;
    }
    
    @AuraEnabled
    public static SimpleResponse updateContact(String sessionId, Map<String, Object> fields) {
        
        SimpleResponse result = validateSession(sessionId, fields);
        
        if (result.errorMessage != '') {
            result.status = 'error';
        } else {
        
            Map<String, Schema.SObjectField> fieldMap = Schema.sObjectType.Contact.fields.getMap();
                
            Contact c = new Contact();
            
            c.Id = sessionId;
            for (String field : fields.keySet()) {
                if (fieldMap.containsKey(field)) {
                    Schema.DescribeFieldResult fieldResult = fieldMap.get(field).getDescribe();
                    Schema.DisplayType t = fieldResult.getType();
                    if (t == Schema.DisplayType.STRING || t == Schema.DisplayType.TEXTAREA || t == Schema.DisplayType.PICKLIST) {
                    	c.put(field, fields.get(field));    
                    } else if (t == Schema.DisplayType.BOOLEAN) {
                        c.put(field, fields.get(field));
                    } else if (t == Schema.DisplayType.DOUBLE) {
                        c.put(field, Double.valueOf(fields.get(field)));
                    } else if (t == Schema.DisplayType.INTEGER) {
                        c.put(field, Integer.valueOf(fields.get(field)));
                    }
                }
            }
            
            update c;
            
        	result.status = 'success';  
            result.identifier = c.Id;
        }
        
        return result;
    } 
    
    @AuraEnabled
    public static SimpleResponse updateStage3Fields(String sessionId, Map<String, Object> fields) {
        
        SimpleResponse result = validateSession(sessionId, fields);
        
        if (result.errorMessage != '') {
            result.status = 'error';
        } else {
    
            Contact c = new Contact();
            
            c.Id = sessionId;
			c.LinkedIn_Profile__c = (String) fields.get('LinkedIn_Profile__c');
            c.Experience_Type__c = (String) fields.get('Experience_Type__c');
           
            update c;
 			
            if (fields.containsKey('CV')) {
                // Insert Attachment
                List<Attachment> currentAttachments = [SELECT Id FROM Attachment WHERE ParentId = :sessionId];
                delete currentAttachments;
                
                FileInput file = (FileInput) JSON.deserialize((String) fields.get('CV'), FileInput.class);

                Attachment a = new Attachment();
                a.Name = file.name;
                a.Body = EncodingUtil.base64Decode(file.contents);
                a.ParentId = sessionId;
                insert a;
            }
            
            if (fields.containsKey('skills')) {
                // Delete existing skills and insert
                List<Contact_Skill__c> currentSkills = [SELECT Id FROM Contact_Skill__c WHERE Contact__c = :sessionId];
                delete currentSkills;
                
                List<Id> skillIds = (List<Id>) JSON.deserialize((String) fields.get('skills'), List<Id>.class);
                List<Contact_Skill__c> newSkills = new List<Contact_Skill__c>();
                for (Id skillId : skillIds) {
                    newSkills.add(new Contact_Skill__c(Contact__c = sessionId, Skill__c = skillId));
                }
                
                insert newSkills;
            }
            
        	result.status = 'success';  
            result.identifier = c.Id;
        }
        
        return result;
    } 
    
    @AuraEnabled
    public static SimpleResponse updateStage4Fields(String sessionId, Map<String, Object> fields) {
        
        SimpleResponse result = validateSession(sessionId, fields);
        
        if (result.errorMessage != '') {
            result.status = 'error';
        } else {
    
            Contact c = new Contact();
            
            c.Id = sessionId;
            if (fields.containsKey('Last_Position__c')) {
                c.Last_Position__c  = (String) fields.get('Last_Position__c');
            }
            update c;
            
            if (fields.containsKey('sectors')) {
                // Delete existing sectors and insert
                List<Contact_Sector__c> currentSectors = [SELECT Id FROM Contact_Sector__c WHERE Contact__c = :sessionId];
                delete currentSectors;
                
                List<Id> sectorIds = (List<Id>) JSON.deserialize((String) fields.get('sectors'), List<Id>.class);
                List<Contact_Sector__c> newSectors = new List<Contact_Sector__c>();
                for (Id sectorId : sectorIds) {
                    newSectors.add(new Contact_Sector__c(Contact__c = sessionId, Sector__c = sectorId));
                }
                
                insert newSectors;
            }
            
        	result.status = 'success';  
            result.identifier = c.Id;
        }
        
        return result;
    } 
    
    @AuraEnabled
    public static SimpleResponse updateStage6Fields(String sessionId, Map<String, Object> fields) {
        
        SimpleResponse result = validateSession(sessionId, fields);
        
        if (result.errorMessage != '') {
            result.status = 'error';
        } else {
    
            Contact c = new Contact();
            
            c.Id = sessionId;
            if (fields.containsKey('Other_Languages__c')) {
                c.Other_Languages__c  = (String) fields.get('Other_Languages__c');
            }
            update c;
            
            if (fields.containsKey('languages')) {
                // Delete existing sectors and insert
                List<Contact_Language__c> currentLanguages = [SELECT Id FROM Contact_Language__c WHERE Contact__c = :sessionId];
                delete currentLanguages;
                
                List<Id> languageIds = (List<Id>) JSON.deserialize((String) fields.get('languages'), List<Id>.class);
                List<Contact_Language__c> newLanguages = new List<Contact_Language__c>();
                for (Id languageId : languageIds) {
                    newLanguages.add(new Contact_Language__c(Contact__c = sessionId, Language__c = languageId));
                }
                
                insert newLanguages;
            }
            
        	result.status = 'success';  
            result.identifier = c.Id;
        }
        
        return result;
    } 
    
    public static SimpleResponse validateCompanyStep1(Map<String, String> fields) {
        
        SimpleResponse result = validateStep1(fields);
        
        if (fields != null) {
            if (fields.containsKey('Name')) {
                if (fields.get('Name') == '') {
                    result.errorMessage += 'Company Name is required. ';	
                }    
            } else {
                result.errorMessage += 'Name is required. ';
            }
            
            if (fields.containsKey('AccountNumber')) {
                if (fields.get('AccountNumber') == '') {
                    result.errorMessage += 'Company Number is required. ';	
                }    
            } else {
                result.errorMessage += 'Company Number is required. ';
            }
        } else {
            result.errorMessage += 'Unknown Error. ';
        }
        
        
        return result;
    }
    
    @AuraEnabled
    public static SimpleResponse updateCompanyStep1(String sessionId, Map<String, String> fields) {
        SimpleResponse result = validateCompanyStep1(fields);
        
        if (result.errorMessage != '') {
            result.status = 'error';
        } else {
            
            Contact c = new Contact(FirstName=fields.get('FirstName'),LastName=fields.get('FirstName'),
                                    Phone=fields.get('Phone'),MobilePhone=fields.get('MobilePhone'),
                                    Email=fields.get('Email'),Skype_Id__c=fields.get('Skype_Id__c')
                                   );
            Account a = new Account(Name=fields.get('Name'), AccountNumber=fields.get('AccountNumber'), 
                                    BillingStreet=fields.get('BillingStreet'), BillingCity=fields.get('BillingCity'),
                                    BillingPostalCode=fields.get('BillingPostalCode')
                                   );
            
            if (sessionId == '' || sessionId == null) {
                RecordType art = [select Id from RecordType where Name = 'Business' and SobjectType = 'Account' limit 1];
                a.RecordTypeId = art.Id;
                insert a;
                
                RecordType crt = [select Id from RecordType where Name = 'Business' and SobjectType = 'Contact' limit 1];
                c.AccountId = a.Id;
                c.RecordTypeId = crt.Id;
                insert c;
            } else {
                
                a.Id = sessionId;
                update a;
                
                List<Contact> contacts = [SELECT Id FROM Contact WHERE Email = :c.Email AND AccountId = :a.Id];
                if (contacts.size() > 0) {
                    c.Id = contacts[0].Id;
                    update c;
                } else {
                    insert c;
                }
            }
            
        	result.status = 'success';  
            result.identifier = a.Id;
        }
        
        return result;
    }
    
    @AuraEnabled
    public static SimpleResponse updateCompanyStep2(String sessionId, Map<String, Object> fields) {
        SimpleResponse result = validateSession(sessionId, fields);
        
        if (result.errorMessage != '') {
            result.status = 'error';
        } else {
            Account a = new Account();
            a.Id = sessionId;
            a.Eligible__c = (Boolean) fields.get('Eligible__c');
            a.Agree_to_Terms__c = (Boolean) fields.get('Agree_to_Terms__c');
            update a;
            
            result.status = 'success';  
            result.identifier = a.Id;
        }
        
        return result;
    }
    
    @AuraEnabled
    public static SimpleResponse createRequirementStep1(String sessionId, Map<String, Object> fields) {
        SimpleResponse result = validateSession(sessionId, fields);
        
        if (result.errorMessage != '') {
            result.status = 'error';
        } else {
            
            String newSessionId = null;
            
			List<Account> acc = [SELECT Id FROM Account WHERE Id = :sessionId];
            if (acc.size() > 0) {
            	Requirement__c r = new Requirement__c();
            	r.Account__c = sessionId;
                r.Level_Required__c = (String) fields.get('Level_Required__c');
            	insert r;  
                
                newSessionId = r.Id;
            } else {
                Requirement__c r = new Requirement__c();
                r.Id = sessionId;
                r.Level_Required__c = (String) fields.get('Level_Required__c');
                update r;
            	newSessionId = sessionId;
            }
            
            if (fields.containsKey('skills')) {
                // Delete existing skills and insert
                List<Desired_Skill__c> currentSkills = [SELECT Id FROM Desired_Skill__c WHERE Requirement__c = :newSessionId];
                delete currentSkills;
                
                List<Id> skillIds = (List<Id>) JSON.deserialize((String) fields.get('skills'), List<Id>.class);
                List<Desired_Skill__c> newSkills = new List<Desired_Skill__c>();
                for (Id skillId : skillIds) {
                    newSkills.add(new Desired_Skill__c(Requirement__c = newSessionId, Skill__c = skillId));
                }
                
                insert newSkills;
            } 
            
            result.status = 'success';  
            result.identifier = newSessionId;
        }
        
        return result;
    }
    
    @AuraEnabled
    public static SimpleResponse createRequirementStep2(String sessionId, Map<String, Object> fields) {
        SimpleResponse result = validateSession(sessionId, fields);
        
        if (result.errorMessage != '') {
            result.status = 'error';
        } else {
            Requirement__c r = new Requirement__c();
            r.Id = sessionId;
            r.Experience_Type__c = (String) fields.get('Experience_Type__c');
            update r;
            
            if (fields.containsKey('sectors')) {
                // Delete existing skills and insert
                List<Desired_Sector__c> currentSectors = [SELECT Id FROM Desired_Sector__c WHERE Requirement__c = :sessionId];
                delete currentSectors;
                
                List<Id> sectorIds = (List<Id>) JSON.deserialize((String) fields.get('sectors'), List<Id>.class);
                List<Desired_Sector__c> newSectors = new List<Desired_Sector__c>();
                for (Id sectorId : sectorIds) {
                    newSectors.add(new Desired_Sector__c(Requirement__c = sessionId, Sector__c = sectorId));
                }
                
                insert newSectors;
            } 
            
            result.status = 'success';  
            result.identifier = sessionId;
        }
        
        return result;
    }
    
    @AuraEnabled
    public static SimpleResponse createRequirementStep3(String sessionId, Map<String, Object> fields) {
        SimpleResponse result = validateSession(sessionId, fields);
        
        if (result.errorMessage != '') {
            result.status = 'error';
        } else {
            Requirement__c r = new Requirement__c();
            r.Id = sessionId;
            if (fields.containsKey('Final_Education_Level__c')) {
                r.Final_Education_Level__c = (String) fields.get('Final_Education_Level__c');    
            }
            if (fields.containsKey('Other_Language__c')) {
                r.Other_Language__c = (String) fields.get('Other_Language__c');    
            }
            if (fields.containsKey('Other_Qualifications__c')) {
                r.Other_Language__c = (String) fields.get('Other_Qualifications__c');    
            }
            update r;
            
            if (fields.containsKey('languages')) {
                // Delete existing skills and insert
                List<Desired_Language__c> currentLanguage = [SELECT Id FROM Desired_Language__c WHERE Requirement__c = :sessionId];
                delete currentLanguage;
                
                List<Id> languageIds = (List<Id>) JSON.deserialize((String) fields.get('languages'), List<Id>.class);
                List<Desired_Language__c> newLanguages = new List<Desired_Language__c>();
                for (Id languageId : languageIds) {
                    newLanguages.add(new Desired_Language__c(Requirement__c = sessionId, Language__c = languageId));
                }
                
                insert newLanguages;
            } 
            
            result.status = 'success';  
            result.identifier = sessionId;
        }
        
        return result;
    }
    
    @AuraEnabled
    public static SimpleResponse createRequirementStep4(String sessionId, Map<String, Object> fields) {
        SimpleResponse result = validateSession(sessionId, fields);
        
        if (result.errorMessage != '') {
            result.status = 'error';
        } else {
            Requirement__c r = new Requirement__c();
            r.Id = sessionId;
            if (fields.containsKey('Work_Frequency_Type_Weekly__c')) {
                r.Work_Frequency_Type_Weekly__c = (String) fields.get('Work_Frequency_Type_Weekly__c');    
            }
            if (fields.containsKey('Work_Frequency_Type_Monthly__c')) {
                r.Work_Frequency_Type_Monthly__c = (String) fields.get('Work_Frequency_Type_Monthly__c');    
            }
            if (fields.containsKey('Laptop__c')) {
                r.Laptop__c = (Boolean) fields.get('Laptop__c');    
            }
            
            update r;
            
            result.status = 'success';  
            result.identifier = sessionId;
        }
        
        return result;
    }
    
    @AuraEnabled
    public static SimpleResponse createRequirementStep5(String sessionId, Map<String, Object> fields) {
        SimpleResponse result = validateSession(sessionId, fields);
        
        if (result.errorMessage != '') {
            result.status = 'error';
        } else {
            Requirement__c r = new Requirement__c();
            r.Id = sessionId;
            if (fields.containsKey('Completed__c')) {
                r.Completed__c = (Boolean) fields.get('Completed__c');    
            }
            
            update r;
            
            result.status = 'success';  
            result.identifier = sessionId;
        }
        
        return result;
    }
    
    private class FileInput {
        public String name;
        public String contents;
    }
}