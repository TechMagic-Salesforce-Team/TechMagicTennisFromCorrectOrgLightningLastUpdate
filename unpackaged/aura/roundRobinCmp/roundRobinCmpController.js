({
    myAction: function (component, event, helper) {

    },

    doInit: function (component, event, helper) {
        var action = component.get("c.getAllGamesJSONS");
        action.setParams({
            "tournamentId" : component.get("v.tournamentId"),
            "playerId": component.get("v.playerId"),
            "pageName": component.get("v.pageName")
        });
        action.setCallback(component, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var games  = response.getReturnValue();
                var gameJSONList = JSON.parse(games);
                var winGamesSize = gameJSONList.length;
                component.set("v.gamesRR", gameJSONList);
                component.set("v.wingamesSize", winGamesSize);
            }
        })
        $A.enqueueAction(action);
    },

    setScroll: function (component) {
            component.set("v.scrollX", $("#rrscroll").scrollLeft());
    }
})