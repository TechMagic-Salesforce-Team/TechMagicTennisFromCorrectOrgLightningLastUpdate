({
    helperMethod: function () {

    },
    
    
    initStatisticsOfPlayer: function (component) {
        var getStatisticsAction = component.get("c.statisticsOfPlayer");
        getStatisticsAction.setParams({
            "player" : component.get("v.player")
        });

        getStatisticsAction.setCallback(component, function (responseStatistics) {
            var stateStatistics = responseStatistics.getState();
            if (stateStatistics === 'SUCCESS') {
                var jsonStatistics = responseStatistics.getReturnValue();
                var wonGames = JSON.parse(jsonStatistics).wonGames;
                var lostGames = JSON.parse(jsonStatistics).lostGames;
                component.set("v.wonGames", wonGames);
                component.set("v.lostGames", lostGames);
                if (wonGames==0 && lostGames==0) component.set("v.percent", 50);
                else component.set("v.percent", Math.round(100*wonGames/(wonGames+lostGames) * 100) / 100);
            }
        });
        $A.enqueueAction(getStatisticsAction);
    },
    
    getCurrentAndCompletedTournamentsOfPlayerForOptions: function (component) {
        var action = component.get("c.getCurrentAndCompletedTournamentsOfPlayer");
        action.setParams({
            "player" : component.get("v.player")
        });
        action.setCallback(component, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var opts = [];
                var data = response.getReturnValue();
                var first = {};
                first.label = '---All---';
                first.value = 'All';
                first.disabled = false;
                first.selected = true;
                opts.push(first);
                for (var i = 0; i < data.length; i++) {
                    var dataStr = JSON.stringify(data[i]);
                    dataStr = dataStr.substring(1, dataStr.length-1);
                    var obj = {};
                    obj.value = dataStr.split(":")[0].substring(1, dataStr.split(":")[0].length-1);
                    obj.label = dataStr.split(":")[1].substring(1, dataStr.split(":")[1].length-1);
                    obj.disabled = false;
                    obj.selected = false;
                    console.log(obj);
                    opts.push(obj);
                }

                component.find("TournamentsOfPlayer").set("v.options", opts);
                console.log(opts);
            }
        });
        $A.enqueueAction(action);
    },
    
    
    getStatisticsOfSelectedTournament: function (component) {
        var action = component.get("c.getPlayerStatistics");
        action.setParams({
            "tournamentId" : component.get("v.idTournamentSelected"),
            "playerId" : component.get("v.idCurrentPlayer")
        });
        action.setCallback(component, function (response) {
            var state = response.getState();
            if (state === 'SUCCESS') {
                var data = response.getReturnValue();
                var wonGames = JSON.parse(data).countWonGames;
                var lostGames = JSON.parse(data).countLostGames;
                component.set("v.wonGames", wonGames);
                component.set("v.lostGames", lostGames);
                if (wonGames==0 && lostGames==0) component.set("v.percent", 50);
                else component.set("v.percent", Math.round(100*wonGames/(wonGames+lostGames) * 100) / 100);
            }
        });
        $A.enqueueAction(action);
    }
    
})