trigger GeneratePlayersStatisticsOfTournament on Tournament__c (after update) {
    List<Tournament__c> beforeUpdateTournaments = new List<Tournament__c>(Trigger.old);
    List<Tournament__c> afterUpdateTournaments = new List<Tournament__c>(Trigger.new);
    PlayersStatisticsGenerator.generatePlayerStatisticsObjects(beforeUpdateTournaments,afterUpdateTournaments);
}