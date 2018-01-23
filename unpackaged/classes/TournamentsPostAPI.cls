@RestResource(urlMapping='/api/post/tournaments/*')
global class TournamentsPostAPI {

    @HttpPost
    global static String doPost() {
        RestRequest request = RestContext.request;
        String headerAppFrom = request.headers.get('From');    
        if (headerAppFrom != null && headerAppFrom.equals('3MVG9HxRZv05HarQDQcBkT_chF.RWVZHSA8FLCkfvwl8OYnEHdvQFtc3lBrlRYzmIRPqz5qzTqPMUUJq1q.xz')) {
            if (request.requestURI.contains('/start')) {
            try {
                //Savepoint sp = Database.setSavepoint();
				Map<String,Object> tournamentIdObj = (Map<String, Object>)JSON.deserializeUntyped(request.requestBody.toString());
				String tournamentId = (String) tournamentIdObj.get('tournamentId');
				Tournament__c tournament = AURA_TournamentController.start(tournamentId);
				//Database.rollback(sp);
                return '{\'success\' : true, \'status\' : \''+tournament.Status__c+'\'}';
            } catch (Exception ex) {
                    return '{"error":"'+ex.getMessage()+'"}';
                }
            } else if (request.requestURI.contains('/create')) {
				Map<String, Object> tournamentMap = (Map<String, Object>) JSON.deserializeUntyped(request.requestBody.toString());
				Tournament__c tournament = new Tournament__c();
				tournament.Name = String.valueOf(tournamentMap.get('Name'));
				tournament.Status__c = String.valueOf(tournamentMap.get('Status__c'));
				tournament.Format__c = String.valueOf(tournamentMap.get('Format__c'));
				tournament.Type__c = String.valueOf(tournamentMap.get('Type__c'));
				tournament.StartDate__c = Datetime.now();
				//Savepoint sp = Database.setSavepoint();
				String responseBody = '';
				insert tournament;
				AURA_TournamentController.sendNotificationsAboutNewTournament(tournament);
				responseBody = '{\'success\':true, \'message\':\'success\'}';
				return responseBody;
            } else {
                return '{"error":"requestURI does not contain START'+headerAppFrom+'"}';
            }
        } else {
             return '{"error":"header FROM is '+headerAppFrom+'"}';
        }
    }
    
}