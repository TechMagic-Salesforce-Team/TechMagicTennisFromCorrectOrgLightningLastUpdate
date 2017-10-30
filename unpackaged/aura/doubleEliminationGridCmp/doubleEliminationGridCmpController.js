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
                var losGamesSize = 0;
                for (var i = 0; i < gameJSONList.length; i++) {
                    for (var j = 0; j < gameJSONList[i].length; j++) {
                        if (gameJSONList[i][j].winningGroup == true) {
                            winGamesSize++;
                            break;
                        }
                    }
                }
                for (var i = 0; i < gameJSONList.length; i++) {
                    for (var j = 0; j < gameJSONList[i].length; j++) {
                        if (gameJSONList[i][j].winningGroup == false) {
                            losGamesSize++;
                            break;
                        }
                    }
                }
                component.set("v.games", gameJSONList);
                component.set("v.winGamesSize", winGamesSize);
                component.set("v.losGamesSize", losGamesSize);
            }
        })
        $A.enqueueAction(action);
    },

    showSpinner: function (component, event, helper) {

    }
})