({
    doInit: function (component, event, helper) {
        //alert('init');
        var action = component.get("c.getAllInvitations");

        action.setParams({
            "playerId" : component.get("v.playerFromCookie")
        });
        action.setCallback(component, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
               var data = response.getReturnValue();
               var jsonData = JSON.parse(data);
               component.set("v.teamInvitations", jsonData);
            }
        })
        $A.enqueueAction(action);
    },


    handleTournamentByAccepting: function (component, event, helper) {
        var tournament = event.getParam("tournamentApplied");
        component.set("v.tournamentJustAccepted", JSON.parse(tournament));
    }
})