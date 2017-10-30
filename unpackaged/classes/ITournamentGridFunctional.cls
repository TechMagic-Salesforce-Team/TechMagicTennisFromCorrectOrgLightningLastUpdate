public interface ITournamentGridFunctional{
    void startTournament(List<String> CompetitorsIds, Tournament__c currentTournament); 
    List<List<Game__c>> generateGrid(Tournament__c currentTournament);
    void createNextStage(List<Game__c> gamesByPreviousRound, Tournament__c currentTournament);
}