({
	onChange : function(component, event, helper) {
        var currentValue = component.get('v.checked');
        var newValue = currentValue ? false : true;
        $A.get('e.c:astridFieldChange').fire({
            name: component.get('v.identifier'), 
            value: newValue
        });
        component.set('v.checked', newValue);
	},
    
    initialValue : function(component, event, helper) {
        if (component.get('v.identifier') == event.getParam('name')) {
            component.set('v.checked', event.getParam('value'));
        }
    }
})