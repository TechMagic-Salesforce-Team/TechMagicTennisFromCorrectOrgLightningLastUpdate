({
    myAction: function (component, event, helper) {

    },
    
    showWindowForFirstCompetitor: function (component, event, helper) {
        component.set("v.playerImage", '');
        component.set("v.isOpenFirstCompetitor", true);
        var playerId = component.get("v.firstCompetitorId");
        helper.getPlayerStatistics(component, playerId);
        //alert(component.get("v.scrollX"));
    },


    showWindowForSecondCompetitor: function (component, event, helper) {
        component.set("v.playerImage", '');
        component.set("v.isOpenSecondCompetitor", true);
        var playerId = component.get("v.secondCompetitorId");
        helper.getPlayerStatistics(component, playerId);
        //alert(component.get("v.firstCompetitorId")+','+component.get("v.tournamentId"));
    },
    
    hideWindowFirstCompetitor: function (component, event, helper) {
        component.set("v.isOpenFirstCompetitor", false);
    },

    hideWindowSecondCompetitor: function (component, event, helper) {
        component.set("v.isOpenSecondCompetitor", false);
    },
    
    
    
})