({
	myAction : function(component, event, helper) {
		
	},
    
	playerClicked: function(component, event, helper) {
		component.set("v.showSpinner", true);
		location.href = '/player?playerId='+component.get("v.player").Id;
    }
})