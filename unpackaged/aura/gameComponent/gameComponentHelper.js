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
    },


    setDisabledStatusForButtons : function (component) {
         var inputScoreBtn = component.find("inputScoreButton");
         inputScoreBtn.set("v.disabled",true);
         var cancelScoreBtn = component.find("cancelButton");
         cancelScoreBtn.set("v.disabled",true);
         try {
             var submitScoreBtn = component.find("submitScoreButton");
             submitScoreBtn.set("v.disabled", true);
         } catch (error) {
             console.log("no element found with id 'submitScoreButton'")
         }
    }
})