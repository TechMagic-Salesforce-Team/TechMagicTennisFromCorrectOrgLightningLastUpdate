({
    acceptTeamInvitationFunc: function (component, event, helper) {
        var action = component.get("c.acceptTeamInvitation");
        action.setParams({
            "teamId" : component.get("v.item").teamId,
            "playerFromCookieId" : component.get("v.currentPlayerId"),
            "playerId" : component.get("v.item").playerId
        });
        
        
        action.setCallback(component, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                component.set("v.item", null);
                var teamInvitationEventFire = component.getEvent("teamInvitationEvent");
                teamInvitationEventFire.setParams({"tournamentApplied": response.getReturnValue()});
                teamInvitationEventFire.fire();
            }
        })
        
        $A.enqueueAction(action);
    },

    declineTeamInvitationFunc: function (component, event, helper) {
        var action = component.get("c.declineTeamInvitation");
        action.setParams({
            "teamId" : component.get("v.item").teamId
        });


        action.setCallback(component, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                component.set("v.item", null);
            }
        })
        $A.enqueueAction(action);
    }
    
})