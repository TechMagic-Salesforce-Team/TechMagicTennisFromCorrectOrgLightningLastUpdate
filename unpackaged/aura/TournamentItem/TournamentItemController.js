({
    clickOntournament: function (component, event, helper) {
        if (component.get("v.refreshTournament")) {
            var tournament = component.get("v.tournament");
            var updateEvent = component.getEvent("tournamentSelector");
            updateEvent.setParams({"tournament": tournament});
            updateEvent.fire();
        }
    },

    startTournament: function (component, event, helper) {
        component.set("v.refreshTournament", false);
        var action = component.get("c.start");
        action.setParams({
            "tournamentId": component.get("v.tournament").Id,
        });

        // action.setCallback(component, function (response) {
        //     var state = response.getState();
        //     if (state === "SUCCESS") {
        //         var tournament = response.getReturnValue();
        //         component.set("v.tournament", tournament);
        //     }
        // })
        $A.enqueueAction(action);

    },

    deleteTournamentAction: function (component, event, helper) {
        component.set("v.refreshTournament", false);
        //var tournamentJsonStr = component.get("v.tournament");
        // var tournamentToDelete = {};
        //
        // tournamentToDelete.Id = tournamentJsonStr.Id;
        // tournamentToDelete.Type__c = tournamentJsonStr.Type__c;
        // tournamentToDelete.Format__c = tournamentJsonStr.Format__c;
        // tournamentToDelete.StartDate__c = tournamentJsonStr.StartDate__c;
        // tournamentToDelete.Name = tournamentJsonStr.Name;
        //
        //
        //
        // alert(JSON.stringify(tournamentToDelete));

        var action = component.get("c.deleteTournament");
        action.setParams({
            "tournamentId": component.get("v.tournament").Id
        });
        action.setCallback(component, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
            }
        })
        $A.enqueueAction(action);

        var tournament = component.get("v.tournament");
        var deleteEvent = component.getEvent("tournamentUpdate");
        deleteEvent.setParams({"tournament": tournament});
        deleteEvent.fire();
    },

    dontRefreshTournamentAndRedirectPage: function (component, event, helper) {
        component.set("v.refreshTournament", false);
    }
})