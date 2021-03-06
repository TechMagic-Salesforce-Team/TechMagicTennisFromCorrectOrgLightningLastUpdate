({
    myAction: function (component, event, helper) {

    },
    
    showWindowForFirstCompetitor: function (component, event, helper) {
        component.set("v.isOpenFirstCompetitor", true);
        var playerId = component.get("v.firstCompetitorId");
        helper.getPlayerStatistics(component, playerId);
        //alert(component.get("v.scrollX"));
    },


    showWindowForSecondCompetitor: function (component, event, helper) {
        component.set("v.isOpenSecondCompetitor", true);
        var playerId = component.get("v.secondCompetitorId");
        helper.getPlayerStatistics(component, playerId);
        //alert(component.get("v.firstCompetitorId")+','+component.get("v.tournamentId"));
    },
    
    hideWindowFirstCompetitor: function (component, event, helper) {
        component.set("v.isOpenFirstCompetitor", false);
        helper.updateAttributes(component);
    },

    hideWindowSecondCompetitor: function (component, event, helper) {
        component.set("v.isOpenSecondCompetitor", false);
        helper.updateAttributes(component);
    },

    doInit: function (component, event, helper) {
        //alert(component.get("v.playerIdFromCookie"));
        if(component.get("v.tournamentId") == 'a010Y00000b9IFuQAM') {
            console.log(component.get("v.game"));
        }
    },

    gameClicked : function (component, event, helper) {
        //alert("clicked");
        component.set("v.editGameSwitched", true);
    },

    closeWindow : function (component, event, helper) {
        //alert("clicked");
        component.set("v.editGameSwitched", false);
    },

    handleWindowClose : function (component) {
        component.set("v.editGameSwitched", false);
    }
    
})