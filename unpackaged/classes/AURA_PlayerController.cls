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
        if (tournament.Format__c == '1 x 1' || playerId.getSObjectType()==Schema.SObjectType.Player__c.getSObjectType()) {
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
                Id playerOrTeamId = getTeamId(playerId, tournament.Id);
                team = [select Id, (select Player__r.Name from PlayerTeams__r) from Team__c where Id=:playerOrTeamId];
                statisticsOfPlayer.player1OfTeamName = team.PlayerTeams__r.get(0).Player__r.Name;
                statisticsOfPlayer.player2OfTeamName = team.PlayerTeams__r.get(1).Player__r.Name;
                statisticsOfPlayer.tournamentFormat = '2 x 2';
                if (player != null) {
                    pc.currentOrCompletedTournamentId = tournament.Id;
                    pc.player = player;
                    pc.getCurrentOrCompletedTournament();
                    statisticsOfPlayer.countWonGames = pc.countWonGames;
                    statisticsOfPlayer.countLostGames = pc.countLostGames;
                }
            }
            return JSON.serialize(statisticsOfPlayer);
        } catch (Exception ex){
            return '';
        }
    }


    private static Id getTeamId(Id playerOrTeamId, Id tournamentId){
        Schema.SObjectType.Player__c.getSObjectType();
        if (playerOrTeamId.getSObjectType()==Schema.SObjectType.Player__c.getSObjectType()) {
            List<PlayerTeam__c> playersTeams = [select Player__c, Team__c from PlayerTeam__c where Team__r.Tournament__c =: tournamentId];
            for (PlayerTeam__c pt: playersTeams) {
                if (pt.Player__c == playerOrTeamId) {
                    return pt.Team__c;
                    break;
                }
            }
        } else {
            return playerOrTeamId;
        }
        return null;
    }

    @AuraEnabled
    public static Player__c getPlayer(String idPlayer) {
        return [select Id, Name, Image__c, Rating__c, IsManager__c, Status__c from Player__c where Id=:idPlayer limit 1];
    }


    @AuraEnabled
    public static String getAllInvitations(String playerId){
        Player__c player = [select Id, Name, Status__c, Rating__c, Image__c from Player__c where Id =: playerId];
        PlayerTeamController ptc = new PlayerTeamController();
        ptc.currentPlayer2 = player;
        return JSON.serialize(ptc.teamInvitations);
    }
    
    
	@AuraEnabled
    public static String uploadImage(String doc, String idPlayerFromCookie, String fileName) {
        Folder folder;
        try {
            folder = [select Id,Name from Folder where name = 'Folder' limit 1];
        } catch (Exception ex){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'No folder with name Folder'));
            return null;
        }
        
        String myFile = EncodingUtil.urlDecode(doc, 'UTF-8');
        //String myFile = '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';
        System.debug(myFile);
        Blob b = EncodingUtil.base64Decode(myFile.substringAfter(','));
        Document document = new Document();
        document.Type = 'jpg';
        document.ContentType = 'image/jpg';
        document.Body = b;
        document.FolderId = folder.Id;
        document.AuthorId = UserInfo.getUserId();
        document.Name = fileName;
        insert document;

        Player__c player = [select Id, Name, Image__c from Player__c where Id=:idPlayerFromCookie];
        player.Image__c = (''+URL.getSalesforceBaseUrl()).split('=')[1].split(']')[0]+'/servlet/servlet.FileDownload?file='+document.Id;
        update player;

        return ''+player.Image__c;
    }


    @AuraEnabled
    public static String statisticsOfPlayer(Player__c player){
        PlayerController playerController = new PlayerController();
        playerController.player = player;
        playerController.countWonGames = 0;
        playerController.countLostGames = 0;
        playerController.getPlayerStatisticsList();
        return '{"wonGames":'+playerController.countWonGames+',"lostGames":'+playerController.countLostGames+'}';
    }


    @AuraEnabled
    public static List<Map<String, String>> getCurrentAndCompletedTournamentsOfPlayer(Player__c player) {
        PlayerController playerController = new PlayerController();
        playerController.player = player;
        playerController.getPlayerTournaments();
        List<Map<String, String>> tournamentsList = new List<Map<String, String>>();
        for (Tournament__c t: playerController.completedAndCurrentTournamentsOfPlayer) {
            Map<String, String> playersMap = new Map<String, String>();
            playersMap.put(t.Id, t.Name);
            tournamentsList.add(playersMap);
        }
        return tournamentsList;
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