<aura:application >
    <ltng:require styles="/resource/SLDS/assets/styles/salesforce-lightning-design-system.css" />
    <c:astridMultiselect sourceCategory="Elements" destCategory="Selected" query="SELECT Id, Name FROM Skill__c" fieldName="Name" />
</aura:application>