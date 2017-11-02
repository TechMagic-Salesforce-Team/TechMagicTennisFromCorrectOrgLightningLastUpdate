({
    helperMethod: function () {

    },


    getPlayerStatistics: function (component, playerId) {
        var action = component.get("c.getPlayerStatistics");
        action.setParams({
            "tournamentId" : component.get("v.tournamentId"),
            "playerId": playerId
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
            }
        })
        $A.enqueueAction(action);
    },

    updateAttributes: function (component) {
        component.set("v.playerImage", '');
        component.set("v.player1Name", '');
        component.set("v.player2Name", '');
    }
})