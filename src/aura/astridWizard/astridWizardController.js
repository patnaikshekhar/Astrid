({
	init : function(component, event, helper) {
        var stepNames = component.get('v.stepNames');
        var stepNamesArray = stepNames.split(',').map(function(name) {
            return name.trim();
        });
        
        component.set('v._stepNames', stepNamesArray);
        
        var currentStep = component.get('v.activeStep');
        
        component.set('v._progressPercent', ((currentStep - 1) / (stepNamesArray.length - 1)) * 100 );
	}
})