({
    onClick : function(component, event, helper) {
        component.getEvent('onClick').fire({ domEvent: event });
	},
    
	onClose : function(component, event, helper) {
        component.getEvent('onClose').fire({ domEvent: event });
	}
})