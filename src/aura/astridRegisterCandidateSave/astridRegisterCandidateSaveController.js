({
    init : function(component, event, helper) {
        $A.get('e.c:astridSessionEvent').fire({
            type: 'get'    
        });  
    },
    
    setSession : function(component, event, helper) {
    	component.set('v._sessionId', event.getParam('sessionId'));
        if (component.get('v.initializeAction') && event.getParam('sessionId')) {
            var action = component.get('c.' + component.get('v.initializeAction'));
            action.setParams({
            	sessionId: component.get('v._sessionId')
        	});
            
            action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                    var fields = component.get('v._fields');
                    if (!fields) {
                        fields = {};
                    }
                    
                    Object.keys(result).forEach(function(field) {
                        
                        fields[field] = result[field];
                        
                        $A.get('e.c:astridFieldInitialValue').fire({
                            name: field,
                            value: result[field]
                        });
                    });
                    component.set('v._fields', fields);
        			console.log('Intialize Field Updates', fields);
                    
                } if (state === "ERROR") {
                    $A.get('e.c:astridErrorEvent').fire({
                        message: response.getError()
                    });
                }
            });
            
            $A.enqueueAction(action);
        }
    },
    
	fieldChange : function(component, event, helper) {
        
		var fields = component.get('v._fields');
        
        if (!fields) {
            fields = {};
        }
        
        fields[event.getParam('name')] = event.getParam('value');
        component.set('v._fields', fields);
        //console.log('Field Updates', fields);
	},
    
    save : function(component, event, helper) {
        event.preventDefault();
        var action = component.get('c.' + component.get('v.action'));
        
        action.setParams({
            sessionId: component.get('v._sessionId'),
            fields: component.get('v._fields') ? component.get('v._fields') : {}
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var response = response.getReturnValue();
                //console.log('c.' + component.get('v.action'),'fired result : ', response);
                if (response.status == 'success') {
                    
                    $A.get('e.c:astridSessionEvent').fire({
                        type: 'set',
                        sessionId: response.identifier
                    }); 
                    
                    if (component.get('v.URL').substring(0, 4) != 'http') {
                    	$A.get("e.force:navigateToURL").fire({
                            url: '/' + component.get('v.URL')   
                        });    
                    } else {
                        var link = document.createElement('a');
                        link.href = component.get('v.URL');
                        link.click();
                    }
                } else {
                    $A.get('e.c:astridErrorEvent').fire({
                        message: response.errorMessage
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