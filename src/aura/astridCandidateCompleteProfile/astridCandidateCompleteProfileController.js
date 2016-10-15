({
	init : function(component, event, helper) {
		var action = component.get('c.getContactProfileComplete');
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log(result);
                if (!result.profileCompleted) {
                	component.set('v._display', true);    
                    $A.get('e.c:astridSessionEvent').fire({
                        type: 'set',
                        sessionId: result.contactId
                    }); 
                }
            } if (state === "ERROR") {
                $A.get('e.c:astridErrorEvent').fire({
                    message: response.getError()
                });
            }
        });
        
        $A.enqueueAction(action);
	}
})