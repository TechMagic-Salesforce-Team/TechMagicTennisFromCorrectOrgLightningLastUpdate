trigger BeforeInsertTeamTrigger on Team__c (before insert) {
    List<Team__c> beforeInsertTeams = new List<Team__c>(Trigger.new);
    List<String> tournamentIds = new List<String>();
    for (Team__c t : beforeInsertTeams) {
        tournamentIds.add(t.Tournament__c);
    }
    List<Team__c> allTeams = [SELECT Id, Tournament__c, Name FROM Team__c WHERE Tournament__c IN :tournamentIds];
    for (Team__c t1 : allTeams) {
        for (Team__c t2 : beforeInsertTeams) {
            if (t1.Tournament__c == t2.Tournament__c && t1.Name == t2.Name) {
                t2.Name = t2.Name + '2';
            }
        }
    }
}