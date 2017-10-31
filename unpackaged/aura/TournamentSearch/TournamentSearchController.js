({
    search: function (component, event, helper) {
        //alert(component.get("v.home"));
        var action = component.get("c.findAll");
        action.setParams({
            "searchTournament": component.get("v.tournament"),
            "home": component.get("v.home")
        });
        action.setCallback(component, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var tournaments = response.getReturnValue();
                component.set("v.tournaments", tournaments);
            }
        })
        $A.enqueueAction(action);

        if (component.get("v.tournamentToDisplay") == null) {
            helper.loadFirstIfHomePage(component);
        }

        //if (component.get("v.currentPlayer") == null) {
            helper.loadPlayer(component);
        //}

        // <c:TournamentInformation tournamentId="{!v.tournamentToDisplay.Id}" player="{!v.currentPlayer}" tournamentType="{!v.tournamentToDisplay.Type__c}"/>



        // $Lightning.use("c:tournamentSearchApp", function () {
        //     $Lightning.createComponent("c:TournamentSearch", {
        //             currentPlayerId : "{!currentPlayer.Id}"
        //         },
        //         "lightning",
        //         function (cmp) {
        //             //alert('Component created, do something cool here');
        //         });
        // });

        // $A.createComponent("c:TournamentInformation", {
        //         "tournamentId": "a010Y00000axHBK",
        //         "player": component.get("v.currentPlayer"),
        //         "tournamentType": "Current"
        //     },
        //     "lght",
        //     function (cmp) {
        //
        //     }
        // );


    },



    handleTournamentByClick: function (component, event, helper) {
        component.set("v.tournamentToDisplay",null);
        if (component.get("v.tournamentToDisplay") == null) component.set("v.tournamentToDisplay",event.getParam("tournament"));
        //alert(component.get("v.tournamentToDisplay").Type__c);
    },

    handleDeletedTournament: function (component, event, helper) {
        var tournaments = component.get("v.tournaments");
        for (var i = 0; i < tournaments.length; i++){
            if (tournaments[i] != null) {
                if (tournaments[i].Id == event.getParam("tournament").Id) {
                    //alert(tournaments[i].Name);
                    delete tournaments[i];
                    break;
                }
            }
        }
        component.set("v.tournaments", null);
        component.set("v.tournaments", tournaments);
    },


    openModalWindow: function (component, event, helper) {
        component.set("v.createTournamentWindow", true);
    },

    closeWindow: function (component, event, helper) {
        component.set("v.tournamentCreated", false);
        component.set("v.createTournamentWindow", false);
    },

    createTournament: function (component, event, helper) {
        if (component.get("v.currentPlayer").IsManager__c) {
            var action = component.get('c.create');
            action.setParams({
                "tournament": component.get("v.tournamentCreate")
            });
            action.setCallback(component, function (response) {
                var tw = JSON.parse(response.getReturnValue());
                if (tw.message === "SUCCESS") {
                    //alert('success');
                    component.set("v.message", "Tournament " + component.get("v.tournamentCreate").Name + " was successfully created");
                    //component.set("v.tournamentCreate", tw.tournament);
                    component.set("v.tournamentCreated", true);
                    var tournaments = component.get("v.tournaments");
                    tournaments.push(tw.tournament);
                    component.set("v.tournaments", tournaments);
                    var tournamentCreated = component.get("v.tournamentCreate");
                    tournamentCreated.Name = '';
                    tournamentCreated.StartDate__c = '';
                    component.set("v.tournamentCreate", tournamentCreated);
                } else {
                    //alert('fail');
                    component.set("v.message", "Error occurred during tournament's creation process");
                    //component.set("v.tournamentCreate", tw.tournament);
                    component.set("v.tournamentCreated", true);
                }
            })
            $A.enqueueAction(action);
        }
    }
})