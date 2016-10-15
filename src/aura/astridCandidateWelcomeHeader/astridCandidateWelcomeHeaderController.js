({
	init : function(component, event, helper) {
		var action = component.get('c.getUsersFirstName');
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set('v._contactName', response.getReturnValue());
            } if (state === "ERROR") {
                $A.get('e.c:astridErrorEvent').fire({
                    message: response.getError()
                });
            }
        });
        
        $A.enqueueAction(action);
	}
})