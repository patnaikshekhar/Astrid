({
	selectedOptionsIndexChanged : function(component, event, helper) {
        
        // Update the class based on what is currently selected (clicked).
        var selectedIndex = component.get('v.selectedOptionsIndex');
        var currentOptions = component.get('v.options');
        
        if (component.getElement().querySelector('li.source.highlighted'))
        	component.getElement().
        		querySelector('li.source.highlighted').className = 'slds-picklist__item source';
        
        if (component.getElement().
        	querySelector('li.source.slds-picklist__item[data-index="' + selectedIndex + '"]'))
        	component.getElement().
        		querySelector('li.source.slds-picklist__item[data-index="' + selectedIndex + '"]').
        		className = 'slds-picklist__item source highlighted';
    },
    
    selectedSelectionIndexChanged : function(component, event, helper) {
        // Update the class based on what is currently selected (clicked).
        var selectedIndex = component.get('v.selectedSelectionIndex');
        var currentOptions = component.get('v.selected');
        
        if (component.getElement().querySelector('li.dest.highlighted'))
        	component.getElement().
        		querySelector('li.dest.highlighted').className = 'slds-picklist__item dest';
        
        if (component.getElement().
        	querySelector('li.dest.slds-picklist__item[data-index="' + selectedIndex + '"]'))
            component.getElement().
                querySelector('li.dest.slds-picklist__item[data-index="' + selectedIndex + '"]').
                className = 'slds-picklist__item dest highlighted';
    },
    
    setInitialValue : function(component, event, helper) {
        var selectedIds = JSON.parse(component.get('v._initialValue'));
        var options = component.get('v.options');
        var optionsIds = component.get('v._options');
        var selected = [];
        var finalOptions = options.slice(0);
        
        if (optionsIds.length <= 0) {
            return;
        }
        
        var optionsIds = optionsIds.filter(function(o, index) {
            if (selectedIds.indexOf(o) > -1) {
                selected.push(options[index]);
                finalOptions = finalOptions.filter(function(x, i) {
                    return i != index;    
                });
                return false;
            } else {
                return true;
            }
        });
        
        component.set('v.selected', selected);
        component.set('v._selected', selectedIds);
        component.set('v.options', finalOptions);
        component.set('v._options', optionsIds);
        
        component.set('v._initialValue', '');
    }
})