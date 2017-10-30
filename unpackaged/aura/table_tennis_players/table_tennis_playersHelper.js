({
	getPlayersByInputFunc : function(component, event, param) {
            var action = component.get("c.getPlayersByInput");
        	action.setParams({ "player" : param ? param: "null"});
        	action.setCallback(this, function(response) {
       		var state = response.getState();
        	if (component.isValid() && state === "SUCCESS") {
            	 component.set("v.players", response.getReturnValue());
        	} else {
            	console.log("Failed with state: " + state);
        	}
   		 });
   		$A.enqueueAction(action);  
   }
})