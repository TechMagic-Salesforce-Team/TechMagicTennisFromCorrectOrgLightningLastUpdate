public class AURA_PlayerController { 
    @AuraEnabled
    public static List<Player__c> getPlayersByInput(Player__c player){
        String searchName = player != null ? '%'+player.Name+'%' : '%%';
        String status = player != null ? '%'+player.Status__c+'%' : '%%';
        List<Player__c> players = [select Name,Email__c,Status__c,Image__c from Player__c where (Name like: searchName or Email__c like: searchName)
                                  and Status__c like : status];
        return players;
    }


    @AuraEnabled
    public static String getPlayerStatistics(Id tournamentId, Id playerId) {
        Tournament__c tournament = [select Id, Format__c, Status__c from Tournament__c where Id=:tournamentId];
        Player__c player = null;
        Team__c team = null;
        if (tournament.Format__c == '1 x 1') {
            player = [select Id, Name, Image__c from Player__c where Id=:playerId];
        }
        PlayerController pc = new PlayerController();
        StatisticsOfPlayer statisticsOfPlayer = new StatisticsOfPlayer();
        try {
            if (tournament.Format__c == '1 x 1') {
                if (tournament.Status__c != 'Upcoming') {
                    pc.currentOrCompletedTournamentId = tournamentId;
                    pc.player = player;
                    pc.getCurrentOrCompletedTournament();
                    System.debug('cwg:'+pc.countWonGames+',clg:'+pc.countLostGames);
                    statisticsOfPlayer.countWonGames = pc.countWonGames;
                    statisticsOfPlayer.countLostGames = pc.countLostGames;
                    statisticsOfPlayer.urlImage = '' + player.Image__c;
                    statisticsOfPlayer.playerName = player.Name;
                    statisticsOfPlayer.tournamentFormat = '1 x 1';
                }
            } else {
                team = [select Id, (select Player__r.Name from PlayerTeams__r) from Team__c where Id=:playerId];
                statisticsOfPlayer.player1OfTeamName = team.PlayerTeams__r.get(0).Player__r.Name;
                statisticsOfPlayer.player2OfTeamName = team.PlayerTeams__r.get(1).Player__r.Name;
                statisticsOfPlayer.tournamentFormat = '2 x 2';
            }
            return JSON.serialize(statisticsOfPlayer);
        } catch (Exception ex){
            return '';
        }
    }

    class StatisticsOfPlayer {
        Double countWonGames;
        Double countLostGames;
        String urlImage;
        String playerName;
        String player1OfTeamName;
        String player2OfTeamName;
        String tournamentFormat;
    }

}