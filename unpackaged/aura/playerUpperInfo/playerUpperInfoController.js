({
    /*handleUploadFinished: function (component, event, helper) {
		var uploadedFiles = event.getSource().get("v.files");
        alert("Files uploaded : " + uploadedFiles[0].name + ', type: '+uploadedFiles[0].type+', size: '+uploadedFiles[0].size);
        alert(encodeURIComponent(uploadedFiles[0]));
        
        var action = component.get("c.uploadImage");
        action.setParams({
            "doc" : encodeURIComponent(uploadedFiles[0])
            //"doc" : (uploadedFiles[0])
        });
        
        action.setCallback(component, function (response) {
                var state = response.getState();
                alert(state);
        })
        $A.enqueueAction(action);
    }*/
    
    
    handleUploadFinished: function (component, event, helper) {
        component.set("v.loadingNewImage", true);
        var uploadedFiles = event.getSource().get("v.files");
    	var reader = new FileReader();
        var self = this;
        reader.onload = function () {
             var action = component.get("c.uploadImage");
             action.setParams(
                 { "doc" : encodeURIComponent(reader.result),
                   "idPlayerFromCookie" : component.get("v.idPlayerFromCookie"), 
                   "fileName" : uploadedFiles[0].name
             });
             action.setCallback(self, function(actionResult) {
                 console.log((actionResult.getReturnValue()));
                 var state = actionResult.getState();
                 if (state === 'SUCCESS') {
                     var player = component.get("v.player");
                     player.Image__c = actionResult.getReturnValue();
                     component.set("v.player", player);
                     component.set("v.loadingNewImage", false);
                 }
             });
             $A.enqueueAction(action);
        };
        reader.readAsDataURL(uploadedFiles[0]);
    },
    
    initPlayer: function (component, event, helper) {
        if (component.get("v.player") == null) {
            var action = component.get("c.getPlayer")
            action.setParams({
                "idPlayer" : component.get("v.idCurrentPlayer")
            });
            
            action.setCallback(component, function (response) {
                var state = response.getState();
                if (state === 'SUCCESS') {
                    component.set("v.player" , response.getReturnValue());
                    helper.initStatisticsOfPlayer(component);
                    helper.getCurrentAndCompletedTournamentsOfPlayerForOptions(component);
                }
            });
            $A.enqueueAction(action);
        } else {
            helper.initStatisticsOfPlayer(component);
            helper.getCurrentAndCompletedTournamentsOfPlayerForOptions(component);
        }
        helper.loadTeamInvitations(component);
    },

    selectTournament: function (component, event, helper) {
        helper.getStatisticsOfSelectedTournament(component);
    }
    
})