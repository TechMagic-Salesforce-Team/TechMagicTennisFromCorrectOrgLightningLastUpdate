({
    doInit: function (component, event, helper) {
        var action = component.get("c.getAllGamesJSONS");
        action.setParams ({
            "tournamentId" : component.get("v.tournamentId"),
            "playerId": component.get("v.playerId"),
            "pageName": component.get("v.pageName")
        });
        action.setCallback(component, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var games  = response.getReturnValue();
                var gameJSONList = JSON.parse(games);
                var winGamesSize = 0;

                for (var i = 0; i < games.length; i++) {
                        if (games[i].length != 0) {
                            winGamesSize++;
                            break;
                        }
                }

                component.set("v.games", gameJSONList);
                component.set("v.winGamesSize", winGamesSize);
            }
        })
        $A.enqueueAction(action);
    },

    showSpinner: function (component, event, helper) {

    },

    setScrollWinners: function (component) {
        component.set("v.scrollX__OfWinnersBasket", $("#winBasket").scrollLeft());
    },

    scriptsLoaded: function (component) {
        console.log('jquery was loaded');
    }
})