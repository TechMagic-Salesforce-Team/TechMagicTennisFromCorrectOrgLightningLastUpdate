({
    doInit: function (component, event, helper) {
        //alert(component.get("v.playerFromCookie"));
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

    inputScoreFunc: function (component, event, helper) {
        //alert(component.get("v.playerFromCookie"));
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
                //alert(respDataJson);
                if (JSON.parse(respDataJson).type=='SUCCESS') {
                    helper.setDisabledStatusForButtons(component);
                    component.set("v.messageStatus","Game was successfully updated");
                } else {
                    component.set("v.messageStatus","Error with updating game : "+JSON.parse(respDataJson).message);
                }
                var x = document.getElementById("snackbar");
                x.className = "show";

                setTimeout(function(){
                    x.className = x.className.replace("show", "");
                    if (component.get("v.messageStatus").indexOf("Game was successfully updated")!=-1) {
                            location.reload();
                        }
                }, 3000);
            }

        })
        $A.enqueueAction(action);
    },

    submitScoreFunc : function (component,event, helper) {
        var action = component.get("c.submitScore");
        action.setParams({
            "tournamentId" : component.get("v.tournamentId"),
            "currentPlayer" : component.get("v.playerFromCookie"),
            "game" : component.get("v.game")
        });

        action.setCallback(component, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var respDataJson = response.getReturnValue();
                if (JSON.parse(respDataJson).type=='SUCCESS') {
                    helper.setDisabledStatusForButtons(component);
                    component.set("v.messageStatus","Game was successfully approved");
                } else {
                    component.set("v.messageStatus","Error with updating game : "+JSON.parse(respDataJson).message);
                }
                var x = document.getElementById("snackbar")
                x.className = "show";
                setTimeout(function(){
                        x.className = x.className.replace("show", "");
                        if (component.get("v.messageStatus").indexOf("Game was successfully submitted")!=-1) location.reload();
                        }, 3000);
            }
        });
        $A.enqueueAction(action); 
    },

    closeWindow : function (component) {
        var closeWindowEv = component.getEvent("windowCloser");
        closeWindowEv.fire();
    },

    setDisabledStatusForButtonsCmp : function (component) {
        alert('aaa');
    }
})