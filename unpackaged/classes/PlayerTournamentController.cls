public with sharing class PlayerTournamentController {

	public Boolean isAlreadyApplied { get; set; }
        public Boolean isValidParameter { get; set; }
    
        public Tournament__c currentTournament { get; set; }
        public Player__c currentPlayer { get; set; }

	public PlayerTournamentController() {
		String tp = ApexPages.currentPage().getParameters().get('tp');
                isValidParameter = false;
                if (tp.length() == 36) {
                    String currentTournamentId = tp.substring(0, 18);
                    List<Tournament__c> tournaments = [SELECT Id, Name, Type__c, Format__c, Status__c, StartDate__c
                        FROM Tournament__c
                        WHERE Id = :currentTournamentId];
                    String currentPlayerId = tp.substring(18);
                    List<Player__c> players = [SELECT Id FROM Player__c WHERE Id = :currentPlayerId AND Status__c = 'Active'];
                    if (tournaments.size() > 0 && players.size() > 0) {
                        isValidParameter = true;
                        currentTournament = tournaments[0];
                        currentPlayer = players[0];
                    }
                }
	}

	public PageReference apply() {
		if (isValidParameter) {
                    List<PlayerTournament__c> playerTournaments = [SELECT Id FROM PlayerTournament__c 
                        WHERE Player__c = :currentPlayer.Id AND Tournament__c = :currentTournament.Id];
                    isAlreadyApplied = playerTournaments.size() > 0;
                    if (!isAlreadyApplied && currentTournament.Status__c == 'Upcoming') {
                        try {
                            PlayerTournament__c playerTournament = new PlayerTournament__c(Player__c = currentPlayer.Id, Tournament__c = currentTournament.Id);
                            insert (playerTournament);
                        } catch (Exception e) {
                            System.debug(e);
                        }
                    }
                    return null;
                }
                PageReference pR = Page.Home;
                pR.setRedirect(true);
		return pR;
	}

}