@RestResource(urlMapping = '/application/apply/*')
global class ApplicationsApi {
    
    //only 1 x 1 format will be got by this url
    @HttpPost
    global static String applyDisapply(String tournamentId, String playerId){
        try {
            String status = AURA_TournamentController.applyForTournament(tournamentId, playerId);
        } catch(Exception e){
            return 'error '+e.getMessage();
        }
        return 'success';
    }
    
    
}