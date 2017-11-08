({
    doInit: function (component, event, helper) {
        //alert("Id from cookie: "+component.get("v.playerFromCookie")+', game: '+component.get("v.gameId")+', exists in current game:' + component.get("v.existsInCurrentGame"));
        var action = component.get("c.findGame");
        action.setParams({
            "gameId" : component.get("v.gameId")
        });

        action.setCallback(component, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var respDataJson = response.getReturnValue();
                component.set("v.game", respDataJson);
            }
        })
        $A.enqueueAction(action);
        
        if (typeof component.get("v.playerFromCookie")!=='undefined' && component.get("v.playerFromCookie")!=='') {
            helper.defineIfPlayerCanSubmitCurrentGameFunc(component);
        } else {
            component.set("v.isUndefined", true);
        }
        //alert(component.get('v.isUndefined')+','+component.get("v.playerFromCookie"));
    },

    inputScoreFunc: function (component) {
        var action = component.get("c.insertScore");
        action.setParams({
             "tournamentId" : component.get("v.tournamentId"),
             "currentPlayer" : component.get("v.playerFromCookie"),
             "game" : component.get("v.game")
        });
        action.setCallback(component, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var respDataJson = response.getReturnValue();
                alert(respDataJson);
            }
        })
        $A.enqueueAction(action);
    }
})