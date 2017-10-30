global class TournamentStarter implements Schedulable {

    global void execute(SchedulableContext ctx) {
        DateTime dt = DateTime.now();
        List<Tournament__c> tournamentsToStart = [SELECT Id, Name, Type__c, Format__c, Status__c, StartDate__c 
            FROM Tournament__c 
            WHERE Status__c = 'Upcoming' AND StartDate__c <= :dt];
        // Let's make a limit to start only 3 tournaments for one time to be sure that we will not exceed salesforce limits
        for(integer i = 0; i < (tournamentsToStart.size() > 3 ? 3 : tournamentsToStart.size()); i++) {
            start(tournamentsToStart[i]);
        }
    }
    
    public void start(Tournament__c tournament) {
        try {
            tournament.Status__c = 'Current';
            update(tournament);
            generateGames(tournament);
        } catch (Exception e) {
            System.debug(e);
        }
    }
    
    private void generateGames(Tournament__c tournament) {
        System.debug('Tournament:'+tournament);
        List<String> ids = getCompetitorsIds(tournament);

        
        ids = PlayerStatisticsSorter.sortPlayersByStatistics(ids,tournament);
        System.debug('ids'+ids);
        Integer pairs = ids.size() / 2;
        List<String> idsUpdated = new List<String>();
        for (Integer i = 0; i < pairs; i++){
            idsUpdated.add(ids.get(i));
            idsUpdated.add(ids.get(ids.size()-i-1));
        }

        if (Math.mod(ids.size() , 2) == 1) {
            idsUpdated.add(ids.get(pairs));
        }
        
        List<String> idsAll = new List<String>();
        idsAll.addAll(ids);
        idsAll.add('\r\n--------------\r\n');
        idsAll.addAll(idsUpdated);

        try {
            Document doc = [select Body from Document where Name='NewTournamentCurrent' limit 1];
            doc.Body = Blob.valueOf(JSON.serialize(ids) + '\r\n---------\r\n' + JSON.serialize(idsUpdated));
            update doc;
        } catch (Exception ex){

        }
        
        if (tournament.Type__c == 'Single Elimination') {
            SingleEliminationTournament.StartSingleEliminationTournament(idsUpdated, tournament);
        } else if (tournament.Type__c == 'Double Elimination') {
            DoubleEliminationTournament.generateRounds(idsUpdated, tournament.Id);
        } else {
            RoundRobin.RoundRobinTournament(tournament, ids);
        }
    }
    
    private List<String> getCompetitorsIds(Tournament__c tournament) {
        List<String> result;
        if (tournament.Format__c == '1 x 1') {
            result = getPlayersIds(tournament.Id);
        } else {
            result = getTeamsIds(tournament.Id);
        }
        return result;
    }
    
    private List<String> getPlayersIds(String tournamentId) {
        List<String> result = new List<String>();
        List<PlayerTournament__c> playerTournaments = [SELECT Player__c 
            FROM PlayerTournament__c 
            WHERE Tournament__c = :tournamentId];
        for (PlayerTournament__c pT : playerTournaments) {
            result.add(pT.Player__c);
        }
        return result;
    }
    
    private List<String> getTeamsIds(String tournamentId) {
        List<String> result = new List<String>();
        List<Team__c> teams = [SELECT Id 
            FROM Team__c 
            WHERE Tournament__c = :tournamentId AND IsComplete__c = true];
        for (Team__c t : teams) {
            result.add(t.Id);
        }
        return result;
    }
}