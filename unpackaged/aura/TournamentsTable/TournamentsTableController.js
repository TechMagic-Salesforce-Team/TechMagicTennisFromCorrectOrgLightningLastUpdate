({

    initFunc: function (component, event, helper) {
        //alert("Table init");
    },

    myFunc: function (component, event, helper) {

    },

    newAcceptedTournament: function (component, event, helper) {
        //alert(component.get("v.justAcceptedTournament").tournament.Name);
        var tournamentsWrappers = component.get("v.tournamentsWrapper");
        tournamentsWrappers.push(component.get("v.justAcceptedTournament"));
        component.set("v.tournamentsWrapper", tournamentsWrappers);
    },

    changedTournamentIdApplied: function (component, event, helper) {
        //alert("changed"+component.get("v.tournamentIdApplied"));
    }
})