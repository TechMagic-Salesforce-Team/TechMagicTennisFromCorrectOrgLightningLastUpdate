@isTest
public with sharing class TournamentStarter_TEST {
    
    public static Tournament__c t = new Tournament__c(Name='qwer', Type__c='Double Elimination', Format__c='2 x 2', StartDate__c=DateTime.now(), Status__c='Upcoming');
    public static Tournament__c t1 = new Tournament__c(Name='1qwer', Type__c='Single Elimination', Format__c='1 x 1', StartDate__c=DateTime.now(), Status__c='Upcoming');
    public static Tournament__c t2 = new Tournament__c(Name='2qwer', Type__c='Round Robin', Format__c='1 x 1', StartDate__c=DateTime.now(), Status__c='Upcoming');
    public static Player__c p0 = new Player__c(Email__c = 'vdv@vdv.dv', IsManager__c = true, Password__c = '1234567890', Name = 'bdf', Status__c = 'Active');
    public static Player__c p1 = new Player__c(Email__c = '1vdv@vdv.dv', IsManager__c = true, Password__c = '1234567890', Name = 'bdf', Status__c = 'Active');
    
    public static testMethod void testTournamentStarterScheduler() {
        insert (t);
        insert (t1);
        insert (t2);
        
        insert (p0);
        insert (p1);
        
        Team__c team = new Team__c(Name = 'test', Tournament__c = t.Id, IsComplete__c = true);
        
        insert (team);
        
        PlayerTeam__c pT1 = new PlayerTeam__c(Team__c = team.Id, Player__c = p0.Id);
        PlayerTeam__c pT2 = new PlayerTeam__c(Team__c = team.Id, Player__c = p1.Id);
        
        insert (pT1);
        insert (pT2);
        
        PlayerTournament__c pT3 = new PlayerTournament__c(Tournament__c = t1.Id, Player__c = p0.Id);
        PlayerTournament__c pT4 = new PlayerTournament__c(Tournament__c = t1.Id, Player__c = p1.Id);
        
        insert (pT3);
        insert (pT4);
        
        PlayerTournament__c pT5 = new PlayerTournament__c(Tournament__c = t2.Id, Player__c = p0.Id);
        PlayerTournament__c pT6 = new PlayerTournament__c(Tournament__c = t2.Id, Player__c = p1.Id);
        
        insert (pT5);
        insert (pT6);
        
        Test.startTest();
        
        TournamentStarter tss = new TournamentStarter();
        tss.execute(null);
        
        List<Game__c> games = [SELECT Id FROM Game__c WHERE Tournament__c = :t.Id];
        
        System.assertEquals(0, games.size());
        
        games = [SELECT Id FROM Game__c WHERE Tournament__c = :t1.Id];
        
        System.assertEquals(1, games.size());
        
        games = [SELECT Id FROM Game__c WHERE Tournament__c = :t2.Id];
        
        System.assertEquals(1, games.size());
        
        Test.stopTest();
        
    }

}