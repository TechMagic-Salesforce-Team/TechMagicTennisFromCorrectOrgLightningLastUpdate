({
	findPlayersByInput : function(component, event, helper) {
        var player = component.get("v.player");
        var findPlayersByNameEvent = component.getEvent("findPlayers");
        findPlayersByNameEvent.setParams({ "player": player});
        findPlayersByNameEvent.fire();
	}
})