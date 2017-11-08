({
    defineIfPlayerCanSubmitCurrentGameFunc: function (component) {
            var action = component.get("c.defineIfPlayerCanSubmitCurrentGame");
            action.setParams({
                "tournamentId": component.get("v.tournamentId"),
                "currentPlayer": component.get("v.playerFromCookie"),
                "gameId": component.get("v.gameId")
            });
            action.setCallback(component, function (response) {
                var state = response.getState();
                if (state === 'SUCCESS') {
                    var respData = response.getReturnValue();
                    component.set("v.canSubmit", respData);
                }
            })
            $A.enqueueAction(action);
    }
})