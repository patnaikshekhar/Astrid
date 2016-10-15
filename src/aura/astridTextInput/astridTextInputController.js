({
	onChange : function(component, event, helper) {
        $A.get('e.c:astridFieldChange').fire({
            name: component.get('v.identifier'), 
            value: event.target.value 
        });
	},
    
    init: function(component, event, helper) {
        if (component.get('v.conditionIdentifier') != '') {
            component.set('v._display', false);
        }
    },
    
    initialValue: function(component, event, helper) {
        if (component.get('v.identifier') == event.getParam('name')) {
            component.set('v.value', event.getParam('value'));
        }
        
        if (component.get('v.conditionIdentifier') == event.getParam('name')) {
            if (event.getParam('value').toString() == component.get('v.conditionValue')) {
                component.set('v._display', true);
            } else {
                component.set('v._display', false);
            } 
        }
    },
    
    checkCondition: function(component, event, helper) {
        if (event.getParam('name') == component.get('v.conditionIdentifier')) {
            if (event.getParam('value').toString() == component.get('v.conditionValue')) {
                component.set('v._display', true);
            } else {
                component.set('v._display', false);
            }
        }
    }
})