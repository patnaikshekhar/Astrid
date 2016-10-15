({
    handleEvent : function(component, event, helper) {
    	var messages = component.get('v._messages');
        messages.push(event.getParam('message'));
        component.set('v._messages', messages);
    },
    
	close : function(component, event, helper) {
        component.set('v._messages', component.get('v._messages').filter(function(val, index) {
            return index != event.getSource().get('v.data'); 
        }));
	}
})