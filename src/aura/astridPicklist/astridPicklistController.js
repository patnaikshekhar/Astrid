({
    init : function(component, event, helper) {
        
        if (component.get('v.conditionIdentifier') != '') {
            component.set('v._display', false);
        }
        
        var action = component.get('c.getPicklistValues');
        
        action.setParams({
            objectName: component.get('v.objectName'),
            fieldName: component.get('v.fieldName')
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set('v.options', response.getReturnValue());
                if (component.get('v._initialValue') == '') {
                	$A.get('e.c:astridFieldChange').fire({
                        name: component.get('v.identifier'), 
                        value: response.getReturnValue()[0]
                    });    
                } else {
                	component.set('v.value', component.get('v._initialValue'));    
                }
            } if (state === "ERROR") {
                $A.get('e.c:astridErrorEvent').fire({
                    message: response.getError()
                });
            }
        });
        
        $A.enqueueAction(action);
    },
    
	onChange : function(component, event, helper) {
        for (var w = 0; w < event.target.children.length; w++) {
            if (event.target.children[w].selected) {
                $A.get('e.c:astridFieldChange').fire({
                    name: component.get('v.identifier'), 
                    value: event.target.children[w].value
                });
                break;
            }    
        }
	},
    
    initialValue: function(component, event, helper) {
        if (component.get('v.identifier') == event.getParam('name')) {
            component.set('v.value', event.getParam('value'));
            component.set('v._initialValue', event.getParam('value'));
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