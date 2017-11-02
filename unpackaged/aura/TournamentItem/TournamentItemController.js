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
    },
    
    applyFunc: function (component, event, helper) {
        component.set("v.refreshTournament", false);
        if (component.get("v.tournament").Format__c == '1 x 1') {
            var action = component.get("c.applyForTournament");
            action.setParams({
                "tournamentId": component.get("v.tournament").Id,
                "playerId": component.get("v.player").Id
            });
            action.setCallback(component, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    component.set("v.isApplied", !component.get("v.isApplied"));
                }
            })
            $A.enqueueAction(action);
        } else {
            var action = component.get("c.playersToInviteForTeam");
            action.setParams({
                "tournamentId" : component.get("v.tournament").Id
            });
            action.setCallback(component, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    component.set("v.createTeamWindow", true);
                    var data = JSON.parse(response.getReturnValue());
                    var opts = [];
                    var opt1 = {};
                    opt1.label = '---None---';
                    opt1.value = 'Null';
                    opt1.disabled = false;
                    opt1.selected = true;
                    opts.push(opt1);
                    for (var i = 0; i < data.length; i++){
                        var opt = {};
                        if (data[i].teamName) {
                            opt.label = data[i].playerName + '---(' + data[i].teamName + ')';
                        } else opt.label = data[i].playerName;
                        opt.value = data[i].playerId;
                        if (data[i].playerId == component.get("v.player").Id) opt.disabled = true;
                        else opt.disabled = !data[i].enabled;
                        opts.push(opt);
                    }
                    component.find("TeamMatesSelect").set("v.options", opts);
                }
            })
            $A.enqueueAction(action);
        }
    },
    
    closeTeamWindow: function (component) {
        component.set("v.createTeamWindow", false);
    },
    
    createTeamFunc: function (component) {
        var teamName = component.get("v.teamName");
        var idPlayerSelected = component.get("v.idPlayerSelected");
        if (teamName != null && idPlayerSelected != null && teamName != '' && teamName && idPlayerSelected != 'Null') {
            //String playerCookieId, String teamName, String idPlayerSelected, String tournamentId
            var action = component.get("c.createTeam");
            action.setParams({
                "playerCookieId" : component.get("v.player").Id,
                "teamName" : teamName,
                "idPlayerSelected" : idPlayerSelected,
                "tournamentId" : component.get("v.tournament").Id
            });

            action.setCallback(component, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    component.set("v.teamName", "");
                    component.set("v.idPlayerSelected", "");
                }
            })
            $A.enqueueAction(action);
        } else {
            alert('Incorrect data, please, input the name of your team and select available teammate')
        }
    }
    
    
})