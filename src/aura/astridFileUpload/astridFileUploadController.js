({
	onChange : function(component, event, helper) {
		var fileInput = event.target;
        var file = fileInput.files[0];
        var reader = new FileReader();
        
        reader.onload = function() {
            var contents = reader.result;
            var base64Mark = 'base64,';
            var dataStart = contents.indexOf(base64Mark) + base64Mark.length;
            contents = contents.substring(dataStart);
            
            $A.get('e.c:astridFieldChange').fire({
                name: component.get('v.identifier'), 
                value: JSON.stringify({
                    name: file.name,
                    contents: contents
                })
            });
            
            component.set('v._name', file.name);
        };
     	
        reader.readAsDataURL(file);
	},
    
    initialValue: function(component, event, helper) {
        if (component.get('v.identifier') == event.getParam('name')) {
            component.set('v._name', event.getParam('value'));
        }
    }
})