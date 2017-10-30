({
    loadFirstIfHomePage: function (component) {
        var action = component.get("c.getFirstCurrent");

        action.setParams({
            "home": component.get("v.home")
        });


        action.setCallback(component, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var tournament = response.getReturnValue();
                component.set("v.tournamentToDisplay", tournament);
            }
        })
        $A.enqueueAction(action);
    },

    loadPlayer: function (component) {
        var action = component.get("c.loadPlayer");

        action.setParams({
            "playerId": component.get("v.currentPlayerId")
        });


        action.setCallback(component, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var player = response.getReturnValue();
                component.set("v.currentPlayer", player);
            }
        })
        $A.enqueueAction(action);
    }
})