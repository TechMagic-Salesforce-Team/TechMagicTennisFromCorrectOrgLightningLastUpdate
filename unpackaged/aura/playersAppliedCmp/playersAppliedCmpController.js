({
    getAppliedPlayers: function (component, event, helper) {
        var action = component.get("c.getAppliedPlayersByTournament");

        action.setParams({
            "tournamentId": component.get("v.upcomingTournament") != null
                ?  component.get("v.upcomingTournament").Id : component.get("v.upcomingTournamentId")
        });

        action.setCallback(component, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var competitorsResponse = response.getReturnValue();
                console.log(JSON.parse(competitorsResponse));
                component.set("v.competitorsData", JSON.parse(competitorsResponse));
            }
        });

        $A.enqueueAction(action);
     }
})