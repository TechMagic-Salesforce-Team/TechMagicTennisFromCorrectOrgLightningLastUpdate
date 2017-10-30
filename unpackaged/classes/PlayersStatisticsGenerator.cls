public with sharing class PlayersStatisticsGenerator {
    public static void generatePlayerStatisticsObjects(
        List<Tournament__c> beforeUpdateTournaments,
        List<Tournament__c> afterUpdateTournaments
        ){
        System.debug('before update status: '+beforeUpdateTournaments.get(0).Status__c+' after update status: '+afterUpdateTournaments.get(0).Status__c);
        Map<Id,Tournament__c> tournamentsChangedToCurrentStatusForSingleGames = new Map<Id,Tournament__c>();
        Map<Id,Tournament__c> tournamentsChangedToCurrentStatusForTeamGames = new Map<Id,Tournament__c>();
        
        //fixed
        
        //throw new DmlException(''+beforeUpdateTournaments.size());
        for (Integer i = 0; i < beforeUpdateTournaments.size(); i++){
            if (beforeUpdateTournaments.get(i).Status__c != 'Upcoming') continue;
            if (beforeUpdateTournaments.get(i).Status__c == 'Upcoming' && afterUpdateTournaments.get(i).Status__c == 'Current'){
                if (afterUpdateTournaments.get(i).Format__c == '1 x 1'){
                    tournamentsChangedToCurrentStatusForSingleGames.put(afterUpdateTournaments.get(i).Id,afterUpdateTournaments.get(i));
                } else if (afterUpdateTournaments.get(i).Format__c == '2 x 2'){
                    tournamentsChangedToCurrentStatusForTeamGames.put(afterUpdateTournaments.get(i).Id,afterUpdateTournaments.get(i));
                }
            } 
        }
        
        
        
        List<PlayerStatistics__c> playerStatisticList = new List<PlayerStatistics__c>();
        
        ///////////////////////////////////////////////////////////////////////////////////
        List<PlayerTournament__c> playerTournamentsList = [select Player__c,Tournament__c from PlayerTournament__c where Tournament__c in:tournamentsChangedToCurrentStatusForSingleGames.keySet()];
            for (PlayerTournament__c playerTournament: playerTournamentsList){
                playerStatisticList.add(
                new PlayerStatistics__c(
                    Player__c = playerTournament.Player__c,
                    Tournament__c = playerTournament.Tournament__c,
                    CountLostGames__c = 0,
                    CountWonGames__c = 0,
                    CountLostSets__c = 0,
                    CountWonSets__c = 0
                ));
            }
        ///////////////////////////////////////////////////////////////////////////////////
        
        
        List<Team__c> teams = [select Tournament__c , (select Player__c,Team__c from PlayerTeams__r) from Team__c where Tournament__c in:tournamentsChangedToCurrentStatusForTeamGames.keySet()];
        for (Team__c team: teams){
            List<PlayerTeam__c> playersOfCurrentTeam = team.PlayerTeams__r;
                for (PlayerTeam__c playerTeam: playersOfCurrentTeam){
                    playerStatisticList.add(
                        new PlayerStatistics__c(
                        Player__c = playerTeam.Player__c,
                        Tournament__c = team.Tournament__c,
                        CountLostGames__c = 0,
                        CountWonGames__c = 0,
                        CountLostSets__c = 0,
                        CountWonSets__c = 0
                    ));
                }
        }
        System.debug('size of player statistic list: '+playerStatisticList.size());
        insert playerStatisticList;
    }
}