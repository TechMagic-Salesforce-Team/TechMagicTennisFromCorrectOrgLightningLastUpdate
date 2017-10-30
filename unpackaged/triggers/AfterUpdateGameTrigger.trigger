trigger AfterUpdateGameTrigger on Game__c (after update) {
    AfterUpdateGameTriggerHelper.generateGamesOrFinishTournament(Trigger.old, Trigger.new);
    
}