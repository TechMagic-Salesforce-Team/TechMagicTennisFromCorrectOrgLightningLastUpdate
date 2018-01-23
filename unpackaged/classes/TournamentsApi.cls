@RestResource(urlMapping='/api/get/tournaments/*')
global class TournamentsApi {

    @HttpGet
    global static String doGet(){
        RestRequest req = RestContext.request;
        String tournamentsArr='[';
        //if (req.requestURI.substring(req.requestURI.lastIndexOf('/'), 
                //req.requestURI.length()).contains('player')) {
                String playerId = req.params.get('playerId');
                System.debug('PlayerId: '+playerId);
                if (!String.isEmpty(playerId)) {
                    List<Player__c> players = [select Id,Name,Email__c,IsManager__c,Image__c from Player__c where Id =: playerId];
                    System.debug('Players : '+players);
                    if (players.size() > 0) {
                        Player__c player = players.get(0);
                        PlayerController playerCtrl = new PlayerController();
                        playerCtrl.player = player;
                        playerCtrl.getPlayerTournaments();
                        System.debug('Tournaments (current or completed) size : '+ playerCtrl.tournamentsOfPlayer);
                        for (Tournament__c tournament : playerCtrl.tournamentsOfPlayer) {
                            if (tournament.Status__c != 'Upcoming') {
                                tournamentsArr+=makeTournament(tournament);
                           }
                        }
                        tournamentsArr = tournamentsArr.substring(0,tournamentsArr.length()-1);
                    }
                }  
        //}
        tournamentsArr+=']';
        return tournamentsArr;
    }
    
    
    private static String makeTournament(Tournament__c tournament){
        String tournamentJSON = '{\'Id\' : \''+tournament.Id+'\''
        +makeOneField('Name', tournament.Name)
        +makeOneField('Status__c', tournament.Status__c)
        +makeOneField('Format__c', tournament.Format__c)
        +makeOneField('Type__c', tournament.Type__c)
        +'},';
        return tournamentJSON;
    }
    
    private static String makeOneField(String fieldName, String value) {
        return ',\''+fieldName+'\' : \''+value+'\'';
    }

}