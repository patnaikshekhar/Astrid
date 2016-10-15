<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Update_Owner_to_Admin</fullName>
        <field>OwnerId</field>
        <lookupValue>spatnaik+astriddemo@salesforce.com</lookupValue>
        <lookupValueType>User</lookupValueType>
        <name>Update Owner to Admin</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Set Account Owner to Admin</fullName>
        <actions>
            <name>Update_Owner_to_Admin</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Account.Name</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
