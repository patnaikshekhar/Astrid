({
	handleEvent : function(component, event, helper) {
        if (event.getParam('type') == 'set') {
            component.set('v._sessionId', event.getParam('sessionId'));
        } else if (event.getParam('type') == 'get') {
            $A.get('e.c:astridOpenSessionEvent').fire({
                sessionId: component.get('v._sessionId')
            });
        }
	}
})