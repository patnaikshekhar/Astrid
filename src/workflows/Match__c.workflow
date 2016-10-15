<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Send_Match_Email_to_Candidate</fullName>
        <description>Send Match Email to Candidate</description>
        <protected>false</protected>
        <recipients>
            <field>Contact__c</field>
            <type>contactLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Astrid_Candidate_Match</template>
    </alerts>
    <rules>
        <fullName>Send email when Match is made</fullName>
        <actions>
            <name>Send_Match_Email_to_Candidate</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Match__c.Score__c</field>
            <operation>greaterThan</operation>
            <value>50</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
