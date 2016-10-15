({
    init : function(component, event, helper) {
        var action = component.get('c.query');
        action.setParams({
            query: component.get('v.query')
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set('v.options', result.map(function(o) {
                    return o[component.get('v.fieldName')];
                }));
                component.set('v._options', result.map(function(o) {
                    return o.Id;
                }));
                
                if (component.get('v._initialValue') != '') {
                    helper.setInitialValue(component, event, helper);
                } else {
                	component.set('v.selected', []);
                	component.set('v._selected', []);    
                }   
            } if (state === "ERROR") {
                $A.get('e.c:astridErrorEvent').fire({
                    message: response.getError()
                });
            }
        });
        
        $A.enqueueAction(action);
    },
    
	selectOption : function(component, event, helper) {
		var index = event.target.dataset.index;
        console.log('index selected', index);
		component.set('v.selectedOptionsIndex', index);
	},
    
    selectSelection : function(component, event, helper) {
		var index = event.target.dataset.index;
		component.set('v.selectedSelectionIndex', index);
	},
    
    addOption : function(component, event, helper) {
		var selectedIndex = component.get('v.selectedOptionsIndex');
        
        if (component.get('v.options')[selectedIndex]) {
        	
            var currentSelection = component.get('v.options')[selectedIndex];
            var currentSelectionId = component.get('v._options')[selectedIndex];
            
            component.set('v.options', component.get('v.options').filter(function(o, index) {
                return index != selectedIndex; 
            }));
            
            component.set('v._options', component.get('v._options').filter(function(o, index) {
                return index != selectedIndex; 
            }));
            
            component.set('v.selected', component.get('v.selected').concat(currentSelection));
            component.set('v._selected', component.get('v._selected').concat(currentSelectionId));
            
            $A.get('e.c:astridFieldChange').fire({
                name: component.get('v.identifier'),
                value: JSON.stringify(component.get('v._selected'))
            });
            
            component.set('v.selectedOptionsIndex', selectedIndex);
        }
        
	},
    
    removeSelection : function(component, event, helper) {
		var selectedIndex = component.get('v.selectedSelectionIndex');
        
        if (component.get('v.selected')[selectedIndex]) {
            
            var currentSelection = component.get('v.selected')[selectedIndex];
            var currentSelectionId = component.get('v._selected')[selectedIndex];
            
            component.set('v.selected', component.get('v.selected').filter(function(o, index) {
                return index != selectedIndex; 
            }));
            
            component.set('v._selected', component.get('v._selected').filter(function(o, index) {
                return index != selectedIndex; 
            }));
            
            component.set('v.options', component.get('v.options').concat(currentSelection));
            component.set('v._options', component.get('v._options').concat(currentSelectionId));
            
            $A.get('e.c:astridFieldChange').fire({
                name: component.get('v.identifier'),
                value: JSON.stringify(component.get('v._selected'))
            });
            
            component.set('v.selectedSelectionIndex', selectedIndex);
        }
	},
    
    selectedOptionsIndexChanged : function(component, event, helper) {
        helper.selectedOptionsIndexChanged(component, event, helper);
    },
    
    selectedSelectionIndexChanged : function(component, event, helper) {
        helper.selectedSelectionIndexChanged(component, event, helper);
    },
    
    initialValue: function(component, event, helper) {
        if (component.get('v.identifier') == event.getParam('name')) {
            component.set('v._initialValue', event.getParam('value'));
            helper.setInitialValue(component, event, helper);
        }
    }
})