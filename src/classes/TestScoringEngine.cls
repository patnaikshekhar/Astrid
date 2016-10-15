@isTest
public class TestScoringEngine {
	
    public static testmethod void totalScore_WhenNoSettingsHaveBeenCreated_Returns0() {
        Account a = new Account(name='Test');
        insert a;
        
        Requirement__c requirement = new Requirement__c(Account__c = a.Id, Experience_Type__c = 'Private Sector', Completed__c = true);
        insert requirement;
        
        Test.startTest();
        System.assertEquals(0, ScoringEngine.totalScore(requirement));
        Test.stopTest();
    }
    
    public static void setupAllCustomSettings() {
        Score_Table__c settings = Score_Table__c.getOrgDefaults();
		settings.Public_Private_Match__c = 5;
        settings.Sector_Match__c = 10;
        settings.Sector_Cap__c = 40;
        settings.Skill_Match__c = 10;
        settings.Skill_Cap__c = 40;
        settings.Language_Match__c = 10;
        settings.Language_Cap__c = 40;
        settings.Max_Education_Score__c = 5;
        settings.Max_Position_Score__c = 5;
		upsert settings Score_Table__c.Id;
        
        createEducationScoreCustomSettings();
		createPositionScoreCustomSettings();
    }
    
    public static testmethod void totalScore_WhenRequirementHasOnlyExperienceType_ReturnsScore() {
        Account a = new Account(name='Test');
        insert a;
        
        Requirement__c requirement = new Requirement__c(Account__c = a.Id, Experience_Type__c = 'Private Sector', Completed__c = true);
        insert requirement;
        
        setupAllCustomSettings();
		
		List<Requirement__c> requirements = (List<Requirement__c>) Database.query(
            (new MatchingEngine(
                new List<Id> {requirement.Id}, false
            )).requirementQuery());        
        
        Test.startTest();
        System.assertEquals(Score_Table__c.getOrgDefaults().Public_Private_Match__c, ScoringEngine.totalScore(requirements[0]));
        Test.stopTest();
    }
    
    public static testmethod void totalScore_WhenRequirementHasOnlyEducation_ReturnsScore() {
        Account a = new Account(name='Test');
        insert a;
        
        Requirement__c requirement = new Requirement__c(Account__c = a.Id, Final_Education_Level__c = 'College / 6th Form', Completed__c = true);
        insert requirement;
        
        setupAllCustomSettings();
        
        List<Requirement__c> requirements = (List<Requirement__c>) Database.query(
            (new MatchingEngine(
                new List<Id> {requirement.Id}, false
            )).requirementQuery());
        
        Test.startTest();
        System.assertEquals(25, ScoringEngine.totalScore(requirements[0]));
        Test.stopTest();
    }
    
    public static testmethod void totalScore_WhenRequirementHasEverything_ReturnsScore() {
        Account a = new Account(name='Test');
        insert a;
        
        Requirement__c requirement = new Requirement__c(Account__c = a.Id, Level_Required__c='Director', Final_Education_Level__c = 'Bachelors Degree', Completed__c = true);
        insert requirement;
        
        Sector__c sector1 = new Sector__c(name = 'Test1');
        insert sector1;
        
        Desired_Sector__c desiredSector = new Desired_Sector__c(Requirement__c = requirement.Id, Sector__c = sector1.Id);
        insert desiredSector;
        
        Skill__c skill1 = new Skill__c(name = 'Test1');
        insert skill1;
        
        Desired_Skill__c desiredSkill = new Desired_Skill__c(Requirement__c = requirement.Id, Skill__c = skill1.Id);
        insert desiredSkill;
        
        Language__c lang1 = new Language__c(name = 'Test1');
        Language__c lang2 = new Language__c(name = 'Test2');
        insert new List<Language__c> {lang1,lang2};
        
        Desired_Language__c desiredLanguage1 = new Desired_Language__c(Requirement__c = requirement.Id, Language__c = lang1.Id);
        insert desiredLanguage1;
                
        Desired_Language__c desiredLanguage2 = new Desired_Language__c(Requirement__c = requirement.Id, Language__c = lang2.Id);
        insert desiredLanguage2;
        
        setupAllCustomSettings();
        
        List<Requirement__c> requirements = (List<Requirement__c>) Database.query(
            (new MatchingEngine(
                new List<Id> {requirement.Id}, false
            )).requirementQuery());
        
        Test.startTest();
        System.assertEquals(65, ScoringEngine.totalScore(requirements[0]));
        Test.stopTest();
    }
    
    public static testmethod void scorePublicPrivate_WhenContactIsInPublicSectorAndJobIsInPrivateSector_Returns0() {
        Contact candidate = new Contact(LastName='Test', Experience_Type__c = 'Public Sector', Profile_Complete__c = true, Eligible_to_Work_in_the_UK__c = true);
        insert candidate;
        
        Account a = new Account(name='Test');
        insert a;
        
        Requirement__c requirement = new Requirement__c(Account__c = a.Id, Experience_Type__c = 'Private Sector', Completed__c = true);
        insert requirement;
        
        Score_Table__c settings = Score_Table__c.getOrgDefaults();
		settings.Public_Private_Match__c = 5;
		upsert settings Score_Table__c.Id;
        
        List<Requirement__c> requirements = (List<Requirement__c>) Database.query(
            (new MatchingEngine(
                new List<Id> {requirement.Id}, false
            )).requirementQuery());
        
        List<Contact> candidates = (List<Contact>) Database.query(
            (new MatchingEngine(
                new List<Id> {candidate.Id}, true
            )).contactQuery());
        
        Test.startTest();
        Decimal score = ScoringEngine.score(requirements[0], candidates[0]);
        Test.stopTest();
        
        System.assertEquals(0, score);
    }
    
    public static testmethod void scorePublicPrivate_WhenContactIsInPublicSectorAndJobIsInPublicSector_ReturnsScore() {
        Contact candidate = new Contact(LastName='Test', Experience_Type__c = 'Public Sector', Profile_Complete__c = true, Eligible_to_Work_in_the_UK__c = true);
        insert candidate;
        
        Account a = new Account(name='Test');
        insert a;
        
        Requirement__c requirement = new Requirement__c(Account__c = a.Id, Experience_Type__c = 'Public Sector', Completed__c = true);
        insert requirement;
        
        Score_Table__c settings = Score_Table__c.getOrgDefaults();
		settings.Public_Private_Match__c = 5;
		upsert settings Score_Table__c.Id;
        
        List<Requirement__c> requirements = (List<Requirement__c>) Database.query(
            (new MatchingEngine(
                new List<Id> {requirement.Id}, false
            )).requirementQuery());
        
        List<Contact> candidates = (List<Contact>) Database.query(
            (new MatchingEngine(
                new List<Id> {candidate.Id}, true
            )).contactQuery());
        
        Test.startTest();
        Decimal score = ScoringEngine.score(requirements[0], candidates[0]);
        Test.stopTest();
        
        System.assertEquals(Score_Table__c.getOrgDefaults().Public_Private_Match__c, score);
    }
    
    public static testmethod void scorePublicPrivate_WhenContactIsInBothAndJobIsInPublicSector_ReturnsScore() {
        Contact candidate = new Contact(LastName='Test', Experience_Type__c = 'Both', Profile_Complete__c = true, Eligible_to_Work_in_the_UK__c = true);
        insert candidate;
        
        Account a = new Account(name='Test');
        insert a;
        
        Requirement__c requirement = new Requirement__c(Account__c = a.Id, Experience_Type__c = 'Public Sector', Completed__c = true);
        insert requirement;
        
        Score_Table__c settings = Score_Table__c.getOrgDefaults();
		settings.Public_Private_Match__c = 5;
		upsert settings Score_Table__c.Id;
        
        List<Requirement__c> requirements = (List<Requirement__c>) Database.query(
            (new MatchingEngine(
                new List<Id> {requirement.Id}, false
            )).requirementQuery());
        
        List<Contact> candidates = (List<Contact>) Database.query(
            (new MatchingEngine(
                new List<Id> {candidate.Id}, true
            )).contactQuery());
        
        Test.startTest();
        Decimal score = ScoringEngine.score(requirements[0], candidates[0]);
        Test.stopTest();
        
        System.assertEquals(Score_Table__c.getOrgDefaults().Public_Private_Match__c, score);
    }
    
    public static testmethod void sectorMatch_WhenContactIsNotInTheSameSectorAsRequirement_Returns0() {
        
        Sector__c sector1 = new Sector__c(name = 'Test1');
        Sector__c sector2 = new Sector__c(name = 'Test2');
        insert new List<Sector__c> {sector1,sector2};
        
        Contact candidate = new Contact(LastName='Test', Profile_Complete__c = true, Eligible_to_Work_in_the_UK__c = true);
        insert candidate;
        
        Contact_Sector__c sec = new Contact_Sector__c(Contact__c = candidate.Id, Sector__c = sector1.Id);
        insert sec;
        
        Account a = new Account(name='Test');
        insert a;
        
        Requirement__c requirement = new Requirement__c(Account__c = a.Id, Experience_Type__c = 'Public Sector', Completed__c = true);
        insert requirement;
        
        Desired_Sector__c desiredSector = new Desired_Sector__c(Requirement__c = requirement.Id, Sector__c = sector2.Id);
        insert desiredSector;
        
        Score_Table__c settings = Score_Table__c.getOrgDefaults();
		settings.Sector_Match__c = 10;
		upsert settings Score_Table__c.Id;
        
        List<Requirement__c> requirements = (List<Requirement__c>) Database.query(
            (new MatchingEngine(
                new List<Id> {requirement.Id}, false
            )).requirementQuery());
        
        List<Contact> candidates = (List<Contact>) Database.query(
            (new MatchingEngine(
                new List<Id> {candidate.Id}, true
            )).contactQuery());
        
        Test.startTest();
        Decimal score = ScoringEngine.score(requirements[0], candidates[0]);
        Test.stopTest();
        
        System.assertEquals(0, score);
    }
    
    public static testmethod void sectorMatch_WhenContactIsInTheSameSectorAsRequirement_ReturnsScore() {
        
        Sector__c sector1 = new Sector__c(name = 'Test1');
        insert new List<Sector__c> {sector1};
        
        Contact candidate = new Contact(LastName='Test', Profile_Complete__c = true, Eligible_to_Work_in_the_UK__c = true);
        insert candidate;
        
        Contact_Sector__c sec = new Contact_Sector__c(Contact__c = candidate.Id, Sector__c = sector1.Id);
        insert sec;
        
        Account a = new Account(name='Test');
        insert a;
        
        Requirement__c requirement = new Requirement__c(Account__c = a.Id, Experience_Type__c = 'Public Sector', Completed__c = true);
        insert requirement;
        
        Desired_Sector__c desiredSector = new Desired_Sector__c(Requirement__c = requirement.Id, Sector__c = sector1.Id);
        insert desiredSector;
        
        Score_Table__c settings = Score_Table__c.getOrgDefaults();
		settings.Sector_Match__c = 10;
		upsert settings Score_Table__c.Id;
        
        List<Requirement__c> requirements = (List<Requirement__c>) Database.query(
            (new MatchingEngine(
                new List<Id> {requirement.Id}, false
            )).requirementQuery());
        
        List<Contact> candidates = (List<Contact>) Database.query(
            (new MatchingEngine(
                new List<Id> {candidate.Id}, true
            )).contactQuery());
        
        Test.startTest();
        Decimal score = ScoringEngine.score(requirements[0], candidates[0]);
        Test.stopTest();
        
        System.assertEquals(Score_Table__c.getOrgDefaults().Sector_Match__c, score);
    }
    
    public static testmethod void sectorMatch_WhenContactHasNoSector_Returns0() {
        
        Sector__c sector1 = new Sector__c(name = 'Test1');
        insert new List<Sector__c> {sector1};
        
        Contact candidate = new Contact(LastName='Test', Profile_Complete__c = true, Eligible_to_Work_in_the_UK__c = true);
        insert candidate;
         
        Account a = new Account(name='Test');
        insert a;
        
        Requirement__c requirement = new Requirement__c(Account__c = a.Id, Experience_Type__c = 'Public Sector', Completed__c = true);
        insert requirement;
        
        Desired_Sector__c desiredSector = new Desired_Sector__c(Requirement__c = requirement.Id, Sector__c = sector1.Id);
        insert desiredSector;
        
        Score_Table__c settings = Score_Table__c.getOrgDefaults();
		settings.Sector_Match__c = 10;
		upsert settings Score_Table__c.Id;
        
        List<Requirement__c> requirements = (List<Requirement__c>) Database.query(
            (new MatchingEngine(
                new List<Id> {requirement.Id}, false
            )).requirementQuery());
        
        List<Contact> candidates = (List<Contact>) Database.query(
            (new MatchingEngine(
                new List<Id> {candidate.Id}, true
            )).contactQuery());
        
        Test.startTest();
        Decimal score = ScoringEngine.score(requirements[0], candidates[0]);
        Test.stopTest();
        
        System.assertEquals(0, score);
    }
    
    public static testmethod void sectorMatch_WhenContactHasMutipleSectorsAndBothMatch_ReturnsScoreTimes2() {
        
        Sector__c sector1 = new Sector__c(name = 'Test1');
        Sector__c sector2 = new Sector__c(name = 'Test2');
        insert new List<Sector__c> {sector1, sector2};
        
        Contact candidate = new Contact(LastName='Test', Profile_Complete__c = true, Eligible_to_Work_in_the_UK__c = true);
        insert candidate;
        
        Contact_Sector__c sec1 = new Contact_Sector__c(Contact__c = candidate.Id, Sector__c = sector1.Id);
        Contact_Sector__c sec2 = new Contact_Sector__c(Contact__c = candidate.Id, Sector__c = sector2.Id);
        insert new List<Contact_Sector__c> {sec1, sec2};
        
        Account a = new Account(name='Test');
        insert a;
        
        Requirement__c requirement = new Requirement__c(Account__c = a.Id, Experience_Type__c = 'Public Sector', Completed__c = true);
        insert requirement;
        
        Desired_Sector__c desiredSector1 = new Desired_Sector__c(Requirement__c = requirement.Id, Sector__c = sector1.Id);
        Desired_Sector__c desiredSector2 = new Desired_Sector__c(Requirement__c = requirement.Id, Sector__c = sector2.Id);
        insert new List<Desired_Sector__c> {desiredSector1, desiredSector2};
        
        Score_Table__c settings = Score_Table__c.getOrgDefaults();
		settings.Sector_Match__c = 10;
		upsert settings Score_Table__c.Id;
        
        List<Requirement__c> requirements = (List<Requirement__c>) Database.query(
            (new MatchingEngine(
                new List<Id> {requirement.Id}, false
            )).requirementQuery());
        
        List<Contact> candidates = (List<Contact>) Database.query(
            (new MatchingEngine(
                new List<Id> {candidate.Id}, true
            )).contactQuery());
        
        Test.startTest();
        Decimal score = ScoringEngine.score(requirements[0], candidates[0]);
        Test.stopTest();
        
        System.assertEquals(Score_Table__c.getOrgDefaults().Sector_Match__c * 2, score);
    }
    
    public static testmethod void sectorMatch_WhenContactHasMutipleSectorsAndOneMatches_ReturnsScore() {
        
        Sector__c sector1 = new Sector__c(name = 'Test1');
        Sector__c sector2 = new Sector__c(name = 'Test2');
        Sector__c sector3 = new Sector__c(name = 'Test3');
        insert new List<Sector__c> {sector1, sector2, sector3};
        
        Contact candidate = new Contact(LastName='Test', Profile_Complete__c = true, Eligible_to_Work_in_the_UK__c = true);
        insert candidate;
        
        Contact_Sector__c sec1 = new Contact_Sector__c(Contact__c = candidate.Id, Sector__c = sector1.Id);
        Contact_Sector__c sec2 = new Contact_Sector__c(Contact__c = candidate.Id, Sector__c = sector2.Id);
        insert new List<Contact_Sector__c> {sec1, sec2};
        
        Account a = new Account(name='Test');
        insert a;
        
        Requirement__c requirement = new Requirement__c(Account__c = a.Id, Experience_Type__c = 'Public Sector', Completed__c = true);
        insert requirement;
        
        Desired_Sector__c desiredSector1 = new Desired_Sector__c(Requirement__c = requirement.Id, Sector__c = sector2.Id);
        Desired_Sector__c desiredSector2 = new Desired_Sector__c(Requirement__c = requirement.Id, Sector__c = sector3.Id);
        insert new List<Desired_Sector__c> {desiredSector1, desiredSector2};
        
        Score_Table__c settings = Score_Table__c.getOrgDefaults();
		settings.Sector_Match__c = 10;
		upsert settings Score_Table__c.Id;
        
        List<Requirement__c> requirements = (List<Requirement__c>) Database.query(
            (new MatchingEngine(
                new List<Id> {requirement.Id}, false
            )).requirementQuery());
        
        List<Contact> candidates = (List<Contact>) Database.query(
            (new MatchingEngine(
                new List<Id> {candidate.Id}, true
            )).contactQuery());
        
        Test.startTest();
        Decimal score = ScoringEngine.score(requirements[0], candidates[0]);
        Test.stopTest();
        
        System.assertEquals(Score_Table__c.getOrgDefaults().Sector_Match__c, score);
    }
    
    public static testmethod void sectorMatch_WhenContactHasMutipleSectorsAndSectorsAreCapped_ReturnsCappedValue() {
        
        Sector__c sector1 = new Sector__c(name = 'Test1');
        Sector__c sector2 = new Sector__c(name = 'Test2');
        insert new List<Sector__c> {sector1, sector2};
        
        Contact candidate = new Contact(LastName='Test', Profile_Complete__c = true, Eligible_to_Work_in_the_UK__c = true);
        insert candidate;
        
        Contact_Sector__c sec1 = new Contact_Sector__c(Contact__c = candidate.Id, Sector__c = sector1.Id);
        Contact_Sector__c sec2 = new Contact_Sector__c(Contact__c = candidate.Id, Sector__c = sector2.Id);
        insert new List<Contact_Sector__c> {sec1, sec2};
        
        Account a = new Account(name='Test');
        insert a;
        
        Requirement__c requirement = new Requirement__c(Account__c = a.Id, Experience_Type__c = 'Public Sector', Completed__c = true);
        insert requirement;
        
        Desired_Sector__c desiredSector1 = new Desired_Sector__c(Requirement__c = requirement.Id, Sector__c = sector1.Id);
        Desired_Sector__c desiredSector2 = new Desired_Sector__c(Requirement__c = requirement.Id, Sector__c = sector2.Id);
        insert new List<Desired_Sector__c> {desiredSector1, desiredSector2};
        
        Score_Table__c settings = Score_Table__c.getOrgDefaults();
		settings.Sector_Match__c = 10;
        settings.Sector_Cap__c = 9;
		upsert settings Score_Table__c.Id;
        
        List<Requirement__c> requirements = (List<Requirement__c>) Database.query(
            (new MatchingEngine(
                new List<Id> {requirement.Id}, false
            )).requirementQuery());
        
        List<Contact> candidates = (List<Contact>) Database.query(
            (new MatchingEngine(
                new List<Id> {candidate.Id}, true
            )).contactQuery());
        
        Test.startTest();
        Decimal score = ScoringEngine.score(requirements[0], candidates[0]);
        Test.stopTest();
        
        System.assertEquals(Score_Table__c.getOrgDefaults().Sector_Cap__c, score);
    }
    
    public static testmethod void sectorMatch_WhenContactHasMutipleSectorsAndScoreIsBelowCapped_ReturnsScore() {
        
        Sector__c sector1 = new Sector__c(name = 'Test1');
        Sector__c sector2 = new Sector__c(name = 'Test2');
        insert new List<Sector__c> {sector1, sector2};
        
        Contact candidate = new Contact(LastName='Test', Profile_Complete__c = true, Eligible_to_Work_in_the_UK__c = true);
        insert candidate;
        
        Contact_Sector__c sec1 = new Contact_Sector__c(Contact__c = candidate.Id, Sector__c = sector1.Id);
        Contact_Sector__c sec2 = new Contact_Sector__c(Contact__c = candidate.Id, Sector__c = sector2.Id);
        insert new List<Contact_Sector__c> {sec1, sec2};
        
        Account a = new Account(name='Test');
        insert a;
        
        Requirement__c requirement = new Requirement__c(Account__c = a.Id, Experience_Type__c = 'Public Sector', Completed__c = true);
        insert requirement;
        
        Desired_Sector__c desiredSector1 = new Desired_Sector__c(Requirement__c = requirement.Id, Sector__c = sector1.Id);
        Desired_Sector__c desiredSector2 = new Desired_Sector__c(Requirement__c = requirement.Id, Sector__c = sector2.Id);
        insert new List<Desired_Sector__c> {desiredSector1, desiredSector2};
        
        Score_Table__c settings = Score_Table__c.getOrgDefaults();
		settings.Sector_Match__c = 10;
        settings.Sector_Cap__c = 30;
		upsert settings Score_Table__c.Id;
        
        List<Requirement__c> requirements = (List<Requirement__c>) Database.query(
            (new MatchingEngine(
                new List<Id> {requirement.Id}, false
            )).requirementQuery());
        
        List<Contact> candidates = (List<Contact>) Database.query(
            (new MatchingEngine(
                new List<Id> {candidate.Id}, true
            )).contactQuery());
        
        Test.startTest();
        Decimal score = ScoringEngine.score(requirements[0], candidates[0]);
        Test.stopTest();
        
        System.assertEquals(Score_Table__c.getOrgDefaults().Sector_Match__c * 2, score);
    }
    
    public static testmethod void skillsMatch_WhenContactDoesNotHaveTheSameSkillsAsRequirement_Returns0() {
        
        Skill__c skill1 = new Skill__c(name = 'Test1');
        Skill__c skill2 = new Skill__c(name = 'Test2');
        insert new List<Skill__c> {skill1,skill2};
        
        Contact candidate = new Contact(LastName='Test', Profile_Complete__c = true, Eligible_to_Work_in_the_UK__c = true);
        insert candidate;
        
        Contact_Skill__c sec = new Contact_Skill__c(Contact__c = candidate.Id, Skill__c = skill1.Id);
        insert sec;
        
        Account a = new Account(name='Test');
        insert a;
        
        Requirement__c requirement = new Requirement__c(Account__c = a.Id, Experience_Type__c = 'Public Sector', Completed__c = true);
        insert requirement;
        
        Desired_Skill__c desiredSkill = new Desired_Skill__c(Requirement__c = requirement.Id, Skill__c = skill2.Id);
        insert desiredSkill;
        
        Score_Table__c settings = Score_Table__c.getOrgDefaults();
		settings.Skill_Match__c = 10;
		upsert settings Score_Table__c.Id;
        
        List<Requirement__c> requirements = (List<Requirement__c>) Database.query(
            (new MatchingEngine(
                new List<Id> {requirement.Id}, false
            )).requirementQuery());
        
        List<Contact> candidates = (List<Contact>) Database.query(
            (new MatchingEngine(
                new List<Id> {candidate.Id}, true
            )).contactQuery());
        
        Test.startTest();
        Decimal score = ScoringEngine.score(requirements[0], candidates[0]);
        Test.stopTest();
        
        System.assertEquals(0, score);
    }
    
    public static testmethod void skillsMatch_WhenContactDoesHaveTheSameSkillsAsRequirement_Returns0() {
        
        Skill__c skill1 = new Skill__c(name = 'Test1');
        insert new List<Skill__c> {skill1};
        
        Contact candidate = new Contact(LastName='Test', Profile_Complete__c = true, Eligible_to_Work_in_the_UK__c = true);
        insert candidate;
        
        Contact_Skill__c sec = new Contact_Skill__c(Contact__c = candidate.Id, Skill__c = skill1.Id);
        insert sec;
        
        Account a = new Account(name='Test');
        insert a;
        
        Requirement__c requirement = new Requirement__c(Account__c = a.Id, Experience_Type__c = 'Public Sector', Completed__c = true);
        insert requirement;
        
        Desired_Skill__c desiredSkill = new Desired_Skill__c(Requirement__c = requirement.Id, Skill__c = skill1.Id);
        insert desiredSkill;
        
        Score_Table__c settings = Score_Table__c.getOrgDefaults();
		settings.Skill_Match__c = 10;
		upsert settings Score_Table__c.Id;
        
        List<Requirement__c> requirements = (List<Requirement__c>) Database.query(
            (new MatchingEngine(
                new List<Id> {requirement.Id}, false
            )).requirementQuery());
        
        List<Contact> candidates = (List<Contact>) Database.query(
            (new MatchingEngine(
                new List<Id> {candidate.Id}, true
            )).contactQuery());
        
        Test.startTest();
        Decimal score = ScoringEngine.score(requirements[0], candidates[0]);
        Test.stopTest();
        
        System.assertEquals(Score_Table__c.getOrgDefaults().Skill_Match__c, score);
    }
    
    public static testmethod void skillsMatch_WhenContactDoesHaveTheSameSkillsAsRequirementButSkillsAreCapped_ReturnsCap() {
        
        Skill__c skill1 = new Skill__c(name = 'Test1');
        insert new List<Skill__c> {skill1};
        
        Contact candidate = new Contact(LastName='Test', Profile_Complete__c = true, Eligible_to_Work_in_the_UK__c = true);
        insert candidate;
        
        Contact_Skill__c sec = new Contact_Skill__c(Contact__c = candidate.Id, Skill__c = skill1.Id);
        insert sec;
        
        Account a = new Account(name='Test');
        insert a;
        
        Requirement__c requirement = new Requirement__c(Account__c = a.Id, Experience_Type__c = 'Public Sector', Completed__c = true);
        insert requirement;
        
        Desired_Skill__c desiredSkill = new Desired_Skill__c(Requirement__c = requirement.Id, Skill__c = skill1.Id);
        insert desiredSkill;
        
        Score_Table__c settings = Score_Table__c.getOrgDefaults();
		settings.Skill_Match__c = 10;
        settings.Skill_Cap__c = 9;
		upsert settings Score_Table__c.Id;
        
        List<Requirement__c> requirements = (List<Requirement__c>) Database.query(
            (new MatchingEngine(
                new List<Id> {requirement.Id}, false
            )).requirementQuery());
        
        List<Contact> candidates = (List<Contact>) Database.query(
            (new MatchingEngine(
                new List<Id> {candidate.Id}, true
            )).contactQuery());
        
        Test.startTest();
        Decimal score = ScoringEngine.score(requirements[0], candidates[0]);
        Test.stopTest();
        
        System.assertEquals(Score_Table__c.getOrgDefaults().Skill_Cap__c, score);
    }
    
    public static testmethod void skillsMatch_WhenContactDoesHaveTheSameSkillsAsRequirementAndSkillsAreCappedButScoreIsLessThanCap_ReturnsScore() {
        
        Skill__c skill1 = new Skill__c(name = 'Test1');
        insert new List<Skill__c> {skill1};
        
        Contact candidate = new Contact(LastName='Test', Profile_Complete__c = true, Eligible_to_Work_in_the_UK__c = true);
        insert candidate;
        
        Contact_Skill__c sec = new Contact_Skill__c(Contact__c = candidate.Id, Skill__c = skill1.Id);
        insert sec;
        
        Account a = new Account(name='Test');
        insert a;
        
        Requirement__c requirement = new Requirement__c(Account__c = a.Id, Experience_Type__c = 'Public Sector', Completed__c = true);
        insert requirement;
        
        Desired_Skill__c desiredSkill = new Desired_Skill__c(Requirement__c = requirement.Id, Skill__c = skill1.Id);
        insert desiredSkill;
        
        Score_Table__c settings = Score_Table__c.getOrgDefaults();
		settings.Skill_Match__c = 10;
        settings.Skill_Cap__c = 20;
		upsert settings Score_Table__c.Id;
        
        List<Requirement__c> requirements = (List<Requirement__c>) Database.query(
            (new MatchingEngine(
                new List<Id> {requirement.Id}, false
            )).requirementQuery());
        
        List<Contact> candidates = (List<Contact>) Database.query(
            (new MatchingEngine(
                new List<Id> {candidate.Id}, true
            )).contactQuery());
        
        Test.startTest();
        Decimal score = ScoringEngine.score(requirements[0], candidates[0]);
        Test.stopTest();
        
        System.assertEquals(Score_Table__c.getOrgDefaults().Skill_Match__c, score);
    }
    
    public static testmethod void languageMatch_WhenContactDoesNotHaveTheSameLanguageAsRequirement_Returns0() {
        
        Language__c lang1 = new Language__c(name = 'Test1');
        Language__c lang2 = new Language__c(name = 'Test2');
        insert new List<Language__c> {lang1,lang2};
        
        Contact candidate = new Contact(LastName='Test', Profile_Complete__c = true, Eligible_to_Work_in_the_UK__c = true);
        insert candidate;
        
        Contact_Language__c lang = new Contact_Language__c(Contact__c = candidate.Id, Language__c = lang1.Id);
        insert lang;
        
        Account a = new Account(name='Test');
        insert a;
        
        Requirement__c requirement = new Requirement__c(Account__c = a.Id, Experience_Type__c = 'Public Sector', Completed__c = true);
        insert requirement;
        
        Desired_Language__c desiredLanguage = new Desired_Language__c(Requirement__c = requirement.Id, Language__c = lang2.Id);
        insert desiredLanguage;
        
        Score_Table__c settings = Score_Table__c.getOrgDefaults();
		settings.Language_Match__c = 10;
		upsert settings Score_Table__c.Id;
        
        List<Requirement__c> requirements = (List<Requirement__c>) Database.query(
            (new MatchingEngine(
                new List<Id> {requirement.Id}, false
            )).requirementQuery());
        
        List<Contact> candidates = (List<Contact>) Database.query(
            (new MatchingEngine(
                new List<Id> {candidate.Id}, true
            )).contactQuery());
        
        Test.startTest();
        Decimal score = ScoringEngine.score(requirements[0], candidates[0]);
        Test.stopTest();
        
        System.assertEquals(0, score);
    }
    
    public static testmethod void languageMatch_WhenContactDoesHaveTheSameLanguageAsRequirement_ReturnsScore() {
        
        Language__c lang1 = new Language__c(name = 'Test1');
        insert new List<Language__c> {lang1};
        
        Contact candidate = new Contact(LastName='Test', Profile_Complete__c = true, Eligible_to_Work_in_the_UK__c = true);
        insert candidate;
        
        Contact_Language__c lang = new Contact_Language__c(Contact__c = candidate.Id, Language__c = lang1.Id);
        insert lang;
        
        Account a = new Account(name='Test');
        insert a;
        
        Requirement__c requirement = new Requirement__c(Account__c = a.Id, Experience_Type__c = 'Public Sector', Completed__c = true);
        insert requirement;
        
        Desired_Language__c desiredLanguage = new Desired_Language__c(Requirement__c = requirement.Id, Language__c = lang1.Id);
        insert desiredLanguage;
        
        Score_Table__c settings = Score_Table__c.getOrgDefaults();
		settings.Language_Match__c = 10;
		upsert settings Score_Table__c.Id;
        
        List<Requirement__c> requirements = (List<Requirement__c>) Database.query(
            (new MatchingEngine(
                new List<Id> {requirement.Id}, false
            )).requirementQuery());
        
        List<Contact> candidates = (List<Contact>) Database.query(
            (new MatchingEngine(
                new List<Id> {candidate.Id}, true
            )).contactQuery());
        
        Test.startTest();
        Decimal score = ScoringEngine.score(requirements[0], candidates[0]);
        Test.stopTest();
        
        System.assertEquals(Score_Table__c.getOrgDefaults().Language_Match__c, score);
    }
    
    public static testmethod void languageMatch_WhenContactDoesHaveTheSameLanguageAsRequirementButScoreIsCapped_ReturnsCap() {
        
        Language__c lang1 = new Language__c(name = 'Test1');
        insert new List<Language__c> {lang1};
        
        Contact candidate = new Contact(LastName='Test', Profile_Complete__c = true, Eligible_to_Work_in_the_UK__c = true);
        insert candidate;
        
        Contact_Language__c lang = new Contact_Language__c(Contact__c = candidate.Id, Language__c = lang1.Id);
        insert lang;
        
        Account a = new Account(name='Test');
        insert a;
        
        Requirement__c requirement = new Requirement__c(Account__c = a.Id, Experience_Type__c = 'Public Sector', Completed__c = true);
        insert requirement;
        
        Desired_Language__c desiredLanguage = new Desired_Language__c(Requirement__c = requirement.Id, Language__c = lang1.Id);
        insert desiredLanguage;
        
        Score_Table__c settings = Score_Table__c.getOrgDefaults();
		settings.Language_Match__c = 10;
        settings.Language_Cap__c = 9;
		upsert settings Score_Table__c.Id;
        
        List<Requirement__c> requirements = (List<Requirement__c>) Database.query(
            (new MatchingEngine(
                new List<Id> {requirement.Id}, false
            )).requirementQuery());
        
        List<Contact> candidates = (List<Contact>) Database.query(
            (new MatchingEngine(
                new List<Id> {candidate.Id}, true
            )).contactQuery());
        
        Test.startTest();
        Decimal score = ScoringEngine.score(requirements[0], candidates[0]);
        Test.stopTest();
        
        System.assertEquals(Score_Table__c.getOrgDefaults().Language_Cap__c, score);
    }
    
    public static testmethod void languageMatch_WhenContactDoesHaveTheSameLanguageAsRequirementButScoreIsCappedAndScoreIsBelowCap_ReturnsScore() {
        
        Language__c lang1 = new Language__c(name = 'Test1');
        insert new List<Language__c> {lang1};
        
        Contact candidate = new Contact(LastName='Test', Profile_Complete__c = true, Eligible_to_Work_in_the_UK__c = true);
        insert candidate;
        
        Contact_Language__c lang = new Contact_Language__c(Contact__c = candidate.Id, Language__c = lang1.Id);
        insert lang;
        
        Account a = new Account(name='Test');
        insert a;
        
        Requirement__c requirement = new Requirement__c(Account__c = a.Id, Experience_Type__c = 'Public Sector', Completed__c = true);
        insert requirement;
        
        Desired_Language__c desiredLanguage = new Desired_Language__c(Requirement__c = requirement.Id, Language__c = lang1.Id);
        insert desiredLanguage;
        
        Score_Table__c settings = Score_Table__c.getOrgDefaults();
		settings.Language_Match__c = 10;
        settings.Language_Cap__c = 20;
		upsert settings Score_Table__c.Id;
        
        List<Requirement__c> requirements = (List<Requirement__c>) Database.query(
            (new MatchingEngine(
                new List<Id> {requirement.Id}, false
            )).requirementQuery());
        
        List<Contact> candidates = (List<Contact>) Database.query(
            (new MatchingEngine(
                new List<Id> {candidate.Id}, true
            )).contactQuery());
        
        Test.startTest();
        Decimal score = ScoringEngine.score(requirements[0], candidates[0]);
        Test.stopTest();
        
        System.assertEquals(Score_Table__c.getOrgDefaults().Language_Match__c, score);
    }
    
    public static void createEducationScoreCustomSettings() {
        Score_Table__c settings = Score_Table__c.getOrgDefaults();
		settings.Score_Per_Education_Level__c = 5;
		upsert settings Score_Table__c.Id; 
        
        List<Education_Scores__c> educationScores = new List<Education_Scores__c> {
        	new Education_Scores__c(Name = 'Masters Degree', Score__c = 5),
            new Education_Scores__c(Name = 'Bachelors Degree', Score__c = 4),
            new Education_Scores__c(Name = 'Apprenticeship', Score__c = 3),
            new Education_Scores__c(Name = 'College / 6th Form', Score__c = 2),
            new Education_Scores__c(Name = 'School', Score__c = 1)
        };
            
        insert educationScores;
    }
    
    public static testmethod void scoreEducationLevel_WhenContactHasNoEducationLevelDefined_Returns0() {
        Contact candidate = new Contact(LastName='Test', Profile_Complete__c = true, Eligible_to_Work_in_the_UK__c = true);
        insert candidate;
        
        Account a = new Account(name='Test');
        insert a;
        
        Requirement__c requirement = new Requirement__c(Account__c = a.Id, Final_Education_Level__c = 'College / 6th Form', Completed__c = true);
        insert requirement;
        
        createEducationScoreCustomSettings();
        
        List<Requirement__c> requirements = (List<Requirement__c>) Database.query(
            (new MatchingEngine(
                new List<Id> {requirement.Id}, false
            )).requirementQuery());
        
        List<Contact> candidates = (List<Contact>) Database.query(
            (new MatchingEngine(
                new List<Id> {candidate.Id}, true
            )).contactQuery());
        
        Test.startTest();
        Decimal score = ScoringEngine.score(requirements[0], candidates[0]);
        Test.stopTest();
        
        System.assertEquals(0, score);
    }
    
    public static testmethod void scoreEducationLevel_WhenContactHasEducationLevelHigherThanRequirement_ReturnsScore() {
        Contact candidate = new Contact(LastName='Test', Final_Education_Level__c = 'Masters Degree', Profile_Complete__c = true, Eligible_to_Work_in_the_UK__c = true);
        insert candidate;
        
        Account a = new Account(name='Test');
        insert a;
        
        Requirement__c requirement = new Requirement__c(Account__c = a.Id, Final_Education_Level__c = 'College / 6th Form', Completed__c = true);
        insert requirement;
        
        createEducationScoreCustomSettings();
        
        List<Requirement__c> requirements = (List<Requirement__c>) Database.query(
            (new MatchingEngine(
                new List<Id> {requirement.Id}, false
            )).requirementQuery());
        
        List<Contact> candidates = (List<Contact>) Database.query(
            (new MatchingEngine(
                new List<Id> {candidate.Id}, true
            )).contactQuery());
        
        Test.startTest();
        Decimal score = ScoringEngine.score(requirements[0], candidates[0]);
        Test.stopTest();
        
        System.assertEquals(20, score);
    }
    
    public static testmethod void scoreEducationLevel_WhenContactHasEducationLevelSameAsRequirement_ReturnsScore() {
        Contact candidate = new Contact(LastName='Test', Final_Education_Level__c = 'College / 6th Form', Profile_Complete__c = true, Eligible_to_Work_in_the_UK__c = true);
        insert candidate;
        
        Account a = new Account(name='Test');
        insert a;
        
        Requirement__c requirement = new Requirement__c(Account__c = a.Id, Final_Education_Level__c = 'College / 6th Form', Completed__c = true);
        insert requirement;
        
        createEducationScoreCustomSettings();
        
        List<Requirement__c> requirements = (List<Requirement__c>) Database.query(
            (new MatchingEngine(
                new List<Id> {requirement.Id}, false
            )).requirementQuery());
        
        List<Contact> candidates = (List<Contact>) Database.query(
            (new MatchingEngine(
                new List<Id> {candidate.Id}, true
            )).contactQuery());
        
        Test.startTest();
        Decimal score = ScoringEngine.score(requirements[0], candidates[0]);
        Test.stopTest();
        
        System.assertEquals(5, score);
    }
    
    public static testmethod void scoreEducationLevel_WhenContactHasEducationLevelLowerThanRequirement_Returns0() {
        Contact candidate = new Contact(LastName='Test', Final_Education_Level__c = 'College / 6th Form', Profile_Complete__c = true, Eligible_to_Work_in_the_UK__c = true);
        insert candidate;
        
        Account a = new Account(name='Test');
        insert a;
        
        Requirement__c requirement = new Requirement__c(Account__c = a.Id, Final_Education_Level__c = 'Masters Degree', Completed__c = true);
        insert requirement;
        
        createEducationScoreCustomSettings();
        
        List<Requirement__c> requirements = (List<Requirement__c>) Database.query(
            (new MatchingEngine(
                new List<Id> {requirement.Id}, false
            )).requirementQuery());
        
        List<Contact> candidates = (List<Contact>) Database.query(
            (new MatchingEngine(
                new List<Id> {candidate.Id}, true
            )).contactQuery());
        
        Test.startTest();
        Decimal score = ScoringEngine.score(requirements[0], candidates[0]);
        Test.stopTest();
        
        System.assertEquals(0, score);
    }
    
    public static void createPositionScoreCustomSettings() {
        Score_Table__c settings = Score_Table__c.getOrgDefaults();
		settings.Score_Per_Position_Level__c = 5;
		upsert settings Score_Table__c.Id; 
        
        List<Position_Scores__c> positionScores = new List<Position_Scores__c> {
        	new Position_Scores__c(Name = 'Board Level', Score__c = 5),
            new Position_Scores__c(Name = 'Director', Score__c = 4),
            new Position_Scores__c(Name = 'Regional / Area manager', Score__c = 3),
            new Position_Scores__c(Name = 'Middle Management', Score__c = 2),
            new Position_Scores__c(Name = 'First Level Manager', Score__c = 1)
        };
            
        insert positionScores;
    }
    
    public static testmethod void scorePosition_WhenContactHasNoPositionDefined_Returns0() {
        Contact candidate = new Contact(LastName='Test', Profile_Complete__c = true, Eligible_to_Work_in_the_UK__c = true);
        insert candidate;
        
        Account a = new Account(name='Test');
        insert a;
        
        Requirement__c requirement = new Requirement__c(Account__c = a.Id, Level_Required__c = 'Middle Management', Completed__c = true);
        insert requirement;
        
        createPositionScoreCustomSettings();
        
        List<Requirement__c> requirements = (List<Requirement__c>) Database.query(
            (new MatchingEngine(
                new List<Id> {requirement.Id}, false
            )).requirementQuery());
        
        List<Contact> candidates = (List<Contact>) Database.query(
            (new MatchingEngine(
                new List<Id> {candidate.Id}, true
            )).contactQuery());
        
        Test.startTest();
        Decimal score = ScoringEngine.score(requirements[0], candidates[0]);
        Test.stopTest();
        
        System.assertEquals(0, score);
    }
    
    public static testmethod void scorePosition_WhenContactHasAPositionHigherThanRequirement_ReturnsScore() {
        Contact candidate = new Contact(LastName='Test', Last_Position__c = 'Director', Profile_Complete__c = true, Eligible_to_Work_in_the_UK__c = true);
        insert candidate;
        
        Account a = new Account(name='Test');
        insert a;
        
        Requirement__c requirement = new Requirement__c(Account__c = a.Id, Level_Required__c = 'Middle Management', Completed__c = true);
        insert requirement;
        
        createPositionScoreCustomSettings();
        
        List<Requirement__c> requirements = (List<Requirement__c>) Database.query(
            (new MatchingEngine(
                new List<Id> {requirement.Id}, false
            )).requirementQuery());
        
        List<Contact> candidates = (List<Contact>) Database.query(
            (new MatchingEngine(
                new List<Id> {candidate.Id}, true
            )).contactQuery());
        
        Test.startTest();
        Decimal score = ScoringEngine.score(requirements[0], candidates[0]);
        Test.stopTest();
        
        System.assertEquals(15, score);
    }
    
    public static testmethod void scorePosition_WhenContactHasAPositionLowerThanRequirement_Returns0() {
        Contact candidate = new Contact(LastName='Test', Last_Position__c = 'Middle Management', Profile_Complete__c = true, Eligible_to_Work_in_the_UK__c = true);
        insert candidate;
        
        Account a = new Account(name='Test');
        insert a;
        
        Requirement__c requirement = new Requirement__c(Account__c = a.Id, Level_Required__c = 'Director', Completed__c = true);
        insert requirement;
        
        createPositionScoreCustomSettings();
        
        List<Requirement__c> requirements = (List<Requirement__c>) Database.query(
            (new MatchingEngine(
                new List<Id> {requirement.Id}, false
            )).requirementQuery());
        
        List<Contact> candidates = (List<Contact>) Database.query(
            (new MatchingEngine(
                new List<Id> {candidate.Id}, true
            )).contactQuery());
        
        Test.startTest();
        Decimal score = ScoringEngine.score(requirements[0], candidates[0]);
        Test.stopTest();
        
        System.assertEquals(0, score);
    }
    
    public static testmethod void scorePosition_WhenContactHasAPositionSameAsRequirement_ReturnsScore() {
        Contact candidate = new Contact(LastName='Test', Last_Position__c = 'Middle Management', Profile_Complete__c = true, Eligible_to_Work_in_the_UK__c = true);
        insert candidate;
        
        Account a = new Account(name='Test');
        insert a;
        
        Requirement__c requirement = new Requirement__c(Account__c = a.Id, Level_Required__c = 'Middle Management', Completed__c = true);
        insert requirement;
        
        createPositionScoreCustomSettings();
        
        List<Requirement__c> requirements = (List<Requirement__c>) Database.query(
            (new MatchingEngine(
                new List<Id> {requirement.Id}, false
            )).requirementQuery());
        
        List<Contact> candidates = (List<Contact>) Database.query(
            (new MatchingEngine(
                new List<Id> {candidate.Id}, true
            )).contactQuery());
        
        Test.startTest();
        Decimal score = ScoringEngine.score(requirements[0], candidates[0]);
        Test.stopTest();
        
        System.assertEquals(5, score);
    }
}