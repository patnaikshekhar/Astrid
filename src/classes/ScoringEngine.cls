public class ScoringEngine {
    public static Decimal totalScore(Requirement__c requirement) {
        
        Decimal totalScore = 0;
        Decimal publicPrivateMatchSetting = Score_Table__c.getOrgDefaults().Public_Private_Match__c;
        
        Decimal sectorCapSetting = Score_Table__c.getOrgDefaults().Sector_Cap__c;
        Decimal sectorMatchSetting = Score_Table__c.getOrgDefaults().Sector_Match__c;
        
        Decimal skillCapSetting = Score_Table__c.getOrgDefaults().Skill_Cap__c;
        Decimal skillMatchSetting = Score_Table__c.getOrgDefaults().Skill_Match__c;
        
        Decimal languageCapSetting = Score_Table__c.getOrgDefaults().Language_Cap__c;
        Decimal languageMatchSetting = Score_Table__c.getOrgDefaults().Language_Match__c;
        
        Decimal educationBaseScore = Score_Table__c.getOrgDefaults().Score_Per_Education_Level__c;
        Decimal maxEducationScore = Score_Table__c.getOrgDefaults().Max_Education_Score__c;
        Education_Scores__c educationScoreRequirement = 
            requirement.Final_Education_Level__c != null ? Education_Scores__c.getValues(requirement.Final_Education_Level__c) : null;
        
        Decimal positionBaseScore = Score_Table__c.getOrgDefaults().Score_Per_Position_Level__c;
        Decimal maxPositionScore = Score_Table__c.getOrgDefaults().Max_Position_Score__c;
        Position_Scores__c positionScoreRequirement = 
            requirement.Level_Required__c != null ? Position_Scores__c.getValues(requirement.Level_Required__c) : null;
        
        totalScore += publicPrivateMatchSetting != null ? publicPrivateMatchSetting : 0;
        
        if (sectorCapSetting != null && sectorMatchSetting != null) {
        	totalScore += (requirement.Desired_Sectors__r.size() * sectorMatchSetting) > sectorCapSetting ? sectorCapSetting : (requirement.Desired_Sectors__r.size() * sectorMatchSetting);    
        }
        
        if (skillCapSetting != null && skillMatchSetting != null) {
        	totalScore += (requirement.Desired_Skills__r.size() * skillMatchSetting) > skillCapSetting ? skillCapSetting : (requirement.Desired_Skills__r.size() * skillMatchSetting);    
        }
        
        if (languageCapSetting != null && languageMatchSetting != null) {
        	totalScore += (requirement.Desired_Languages__r.size() * languageMatchSetting) > languageCapSetting ? languageCapSetting : (requirement.Desired_Languages__r.size() * languageMatchSetting);    
        }
        
        if (educationScoreRequirement != null && educationBaseScore != null && maxEducationScore != null) {
            if (educationScoreRequirement.Score__c != null) {
                Decimal maxPossibleScore = ((maxEducationScore - educationScoreRequirement.Score__c) + 1) * educationBaseScore;
				totalScore += maxPossibleScore > 0 ? maxPossibleScore : 0;            
            }
        }
        
        if (positionScoreRequirement != null && positionBaseScore != null && maxPositionScore != null) {
            if (positionScoreRequirement.Score__c != null) {
                Decimal maxPossibleScore = ((maxPositionScore - positionScoreRequirement.Score__c) + 1) * positionBaseScore;
				totalScore += maxPossibleScore > 0 ? maxPossibleScore : 0;            
            }
        }
        
        return totalScore;
    }
    
	public static Decimal score(Requirement__c requirement, Contact candidate) {
        
        return 
            publicPrivateMatch(requirement, candidate) +
            sectorMatch(requirement, candidate) +
            skillMatch(requirement, candidate) +
            languageMatch(requirement, candidate) +
            educationLevelMatch(requirement, candidate) +
            positionLevelMatch(requirement, candidate);
    }
    
    public static Decimal publicPrivateMatch(Requirement__c requirement, Contact candidate) {
        System.debug('******In publicPrivateMatch Match');
        
        if (requirement.Experience_Type__c != null) {
        	if (requirement.Experience_Type__c == 'Both' || candidate.Experience_Type__c == 'Both') {
            	return Score_Table__c.getOrgDefaults().Public_Private_Match__c;
            } else if (requirement.Experience_Type__c == candidate.Experience_Type__c) {
                return Score_Table__c.getOrgDefaults().Public_Private_Match__c;
            } else {
                return 0;
            }    
        } else {
            return 0;
        }
    }
    
    public static Decimal sectorMatch(Requirement__c requirement, Contact candidate) {
        
        System.debug('******In Sector Match');
        Decimal score = 0;
        
        if (requirement.Desired_Sectors__r.size() > 0 && candidate.Contact_Sectors__r.size() > 0) {
            for (Desired_Sector__c desiredSector : requirement.Desired_Sectors__r) {
                for (Contact_Sector__c contactSector : candidate.Contact_Sectors__r) {
                    if (desiredSector.Sector__c == contactSector.Sector__c) {
                        score += Score_Table__c.getOrgDefaults().Sector_Match__c;
                    }
                }
            }
        } 
        
        if (Score_Table__c.getOrgDefaults().Sector_Cap__c != null) {
            if (score > Score_Table__c.getOrgDefaults().Sector_Cap__c) {
                return Score_Table__c.getOrgDefaults().Sector_Cap__c;
            } else {
                return score;
            }
        } else {
        	return score;    
        }
    }
    
    public static Decimal skillMatch(Requirement__c requirement, Contact candidate) {
        
        System.debug('******In Skills Match');
        Decimal score = 0;
        
        if (requirement.Desired_Skills__r.size() > 0 && candidate.Contact_Skills__r.size() > 0) {
            for (Desired_Skill__c desiredSkill : requirement.Desired_Skills__r) {
                for (Contact_Skill__c contactSkill : candidate.Contact_Skills__r) {
                    if (desiredSkill.Skill__c == contactSkill.Skill__c) {
                        score += Score_Table__c.getOrgDefaults().Skill_Match__c;
                    }
                }
            }
        } 
        
        if (Score_Table__c.getOrgDefaults().Skill_Cap__c != null) {
            if (score > Score_Table__c.getOrgDefaults().Skill_Cap__c) {
                return Score_Table__c.getOrgDefaults().Skill_Cap__c;
            } else {
                return score;
            }
        } else {
        	return score;    
        }
    }
    
    public static Decimal languageMatch(Requirement__c requirement, Contact candidate) {
        
        System.debug('******In Language Match');
        Decimal score = 0;
        
        if (requirement.Desired_Languages__r.size() > 0 && candidate.Contact_Languages__r.size() > 0) {
            for (Desired_Language__c desiredLanguage : requirement.Desired_Languages__r) {
                for (Contact_Language__c contactLanguage : candidate.Contact_Languages__r) {
                    if (desiredLanguage.Language__c == contactLanguage.Language__c) {
                        score += Score_Table__c.getOrgDefaults().Language_Match__c;
                    }
                }
            }
        } 
        
        if (Score_Table__c.getOrgDefaults().Language_Cap__c != null) {
            if (score > Score_Table__c.getOrgDefaults().Language_Cap__c) {
                return Score_Table__c.getOrgDefaults().Language_Cap__c;
            } else {
                return score;
            }
        } else {
        	return score;    
        }
    }
    
    public static Decimal educationLevelMatch(Requirement__c requirement, Contact candidate) {
        
        Decimal baseScore = Score_Table__c.getOrgDefaults().Score_Per_Education_Level__c;
        
        if (baseScore != null) {
            if (requirement.Final_Education_Level__c != null && candidate.Final_Education_Level__c != null) {
                Education_Scores__c educationScoreRequirement = Education_Scores__c.getValues(requirement.Final_Education_Level__c);
                Education_Scores__c educationScoreCandidate = Education_Scores__c.getValues(candidate.Final_Education_Level__c);
                
                if (educationScoreRequirement != null && educationScoreCandidate != null) {
                    Decimal score = ((educationScoreCandidate.Score__c - educationScoreRequirement.Score__c) + 1) * baseScore;
                    return score < 0 ? 0 : score;    
                } else {
                    return 0;
                }
                
            } else {
                return 0;
            }
        } else {
            return 0;
        }
    }
    
    public static Decimal positionLevelMatch(Requirement__c requirement, Contact candidate) {
        
        Decimal baseScore = Score_Table__c.getOrgDefaults().Score_Per_Position_Level__c;
        
        if (baseScore != null) {
            if (requirement.Level_Required__c != null && candidate.Last_Position__c != null) {
                Position_Scores__c positionScoreRequirement = Position_Scores__c.getValues(requirement.Level_Required__c);
                Position_Scores__c positionScoreCandidate = Position_Scores__c.getValues(candidate.Last_Position__c);
                
                if (positionScoreRequirement != null && positionScoreCandidate != null) {
                    Decimal score = ((positionScoreCandidate.Score__c - positionScoreRequirement.Score__c) + 1) * baseScore;
                    return score < 0 ? 0 : score;    
                } else {
                    return 0;
                }
                
            } else {
                return 0;
            }
        } else {
            return 0;
        }
    }
}