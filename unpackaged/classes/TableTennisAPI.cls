@RestResource(urlMapping='/api/tournaments/*')
global class TableTennisAPI {
	
    @HttpGet
    global static String getTournament() {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        if (req.requestURI.contains('/get/')) {
             String tournamentId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        	 List<Tournament__c> ts = [select Id, Name from Tournament__c where Id =: tournamentId];
             return ts.size() > 0 ? JSON.serialize(ts) : 'No such tournament';
        } else {
            return 'wrong request';
        }
    }
    
    @HttpPost
    global static String addTournament(Tournament__c tournament, List<sObject> players) {
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        System.debug(tournament);
        Map<Id, Player__c> allPlayers = new Map<Id,Player__c>([select Id from Player__c]);
        System.savepoint sp = Database.setSavepoint();
        if (req.requestURI.contains('/add/')) {
            List<Folder> folders = [select Id, Name from Folder where Name='FolderHttpRequests']; 
            if (folders.size() > 0) {
                Document doc = new Document();
                doc.Name = 'PostHttpTest';
                doc.FolderId = folders.get(0).Id;
                doc.Body = Blob.valueOf(JSON.serialize(tournament)+''+JSON.serialize(players));
                doc.AuthorId = UserInfo.getUserId();
                doc.ContentType = 'text/plain';
                doc.Type = 'txt';
                insert doc;
                System.debug('Success');
                try {
                    if (tournament.StartDate__c==null) tournament.StartDate__c = Datetime.now();
                    upsert tournament;
                    if (tournament.Format__c == '1 x 1') {
                        List<Player__c> playersList = (List<Player__c>) players;
                        List<Player__c> playersListToInsert = new List<Player__c>();
                        for (Player__c pl : playersList) {
                            if (pl.Id != null) {
                                if (!allPlayers.containsKey(pl.Id)) {
                                	//playersListToInsert.add(pl);
                                }
                            } else {
                                playersListToInsert.add(pl);
                            }
                        }
                        insert playersListToInsert;
                        List<PlayerTournament__c> playerTournaments = new List<PlayerTournament__c>();
                        for (Player__c player : playersList) {
                            playerTournaments.add(new PlayerTournament__c(Player__c = player.Id, Tournament__c = tournament.Id));
                        }
                        insert playerTournaments;
                    }
                } catch (Exception ex) {
                    Database.rollback(sp);
                    return ex.getMessage();
                }
            } else {
                System.debug('wrong address');
            }
        }
        TournamentStarter ts = new TournamentStarter();
        ts.start(tournament);
        String gamesJSON = '';
        List<Game__c> games = [select Id, FirstCompetitor__c, SecondCompetitor__c, FirstCompetitorScore__c, SecondCompetitorScore__c,
                               Stage__c, FirstCompetitorAccept__c, SecondCompetitorAccept__c, Type__c
                               from Game__c where Tournament__c =: tournament.Id];
        gamesJSON = JSON.serialize(games);
        Database.rollback(sp);
        return JSON.serialize(games);
    }
}