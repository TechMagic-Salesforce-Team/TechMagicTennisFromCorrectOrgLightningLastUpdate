({
    showWindow: function (component, event, helper) {
        component.set("v.isOpen", true);
        //alert(component.get("v.playerId")+','+component.get("v.tournamentId"));
        console.log(component.get("v.playerId"));
        var action = component.get("c.getPlayerStatistics");
        action.setParams({
            "tournamentId" : component.get("v.tournamentId"),
            "playerId": component.get("v.playerId")
        });

        action.setCallback(component, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = JSON.parse(response.getReturnValue());
                if (data.tournamentFormat == '1 x 1') {
                    component.set("v.playerImage", data.urlImage == 'null' ? 'https://cdn3.iconfinder.com/data/icons/rcons-user-action/32/boy-512.png' : data.urlImage);
                }
                component.set("v.countWongames", data.countWonGames);
                component.set("v.countLostgames", data.countLostGames);
                component.set("v.player1Name", data.player1OfTeamName);
                component.set("v.player2Name", data.player2OfTeamName);
                //alert(response.getReturnValue());
            }
        })
        $A.enqueueAction(action);
    },

    hideWindow: function (component, event, helper) {
        component.set("v.isOpen", false);
    }
})