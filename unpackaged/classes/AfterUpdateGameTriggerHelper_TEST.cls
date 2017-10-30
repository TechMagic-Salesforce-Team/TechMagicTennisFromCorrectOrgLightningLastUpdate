@isTest
public with sharing class AfterUpdateGameTriggerHelper_TEST {

    public static Tournament__c t = new Tournament__c(Name='qwer', Type__c='Double Elimination', Format__c='1 x 1', StartDate__c=DateTime.now(), Status__c='Upcoming');
    public static Tournament__c t1 = new Tournament__c(Name='1qwer', Type__c='Single Elimination', Format__c='1 x 1', StartDate__c=DateTime.now(), Status__c='Upcoming');
    public static Tournament__c t2 = new Tournament__c(Name='2qwer', Type__c='Round Robin', Format__c='1 x 1', StartDate__c=DateTime.now(), Status__c='Upcoming');
    public static Player__c p0 = new Player__c(Email__c = 'vdv@vdv.dv', IsManager__c = true, Password__c = '1234567890', Name = 'bdf', Status__c = 'Active');
    public static Player__c p1 = new Player__c(Email__c = '1vdv@vdv.dv', IsManager__c = true, Password__c = '1234567890', Name = 'bdf', Status__c = 'Active');
    public static Player__c p2 = new Player__c(Email__c = '2vdv@vdv.dv', IsManager__c = true, Password__c = '1234567890', Name = 'bdf', Status__c = 'Active');
    
    public static testMethod void testGenerateGamesOrFinishTournament() {
        insert (t);
        
        insert (p0);
        insert (p1);
        insert (p2);
        
        List<String> ids = new List<String>(); 
        
        List<Player__c> players = [select Id, Password__c from Player__c];
        
        for (Player__c p : players) {
            ids.add(p.Id);
        }
        
        PlayerTournament__c pt111 = new PlayerTournament__c(Player__c = p0.Id, Tournament__c = t.Id);
        PlayerTournament__c pt112 = new PlayerTournament__c(Player__c = p1.Id, Tournament__c = t.Id);
        PlayerTournament__c pt113 = new PlayerTournament__c(Player__c = p2.Id, Tournament__c = t.Id);
        
        insert(pt111);
        insert(pt112);
        insert(pt113);
        
        TournamentStarter tsta = new TournamentStarter();
        
        tsta.execute(null);
        
        List<Game__c> games = [SELECT Id, FirstCompetitor__c, SecondCompetitor__c, FirstCompetitorAccept__c, SecondCompetitorAccept__c, FirstCompetitorScore__c, SecondCompetitorScore__c, Tournament__c, Stage__c, WinningGroup__c FROM Game__c ORDER BY Stage__c ASC, WinningGroup__c ASC];
        
        System.assertEquals(3, games.size());
        
        List<PlayerStatistics__c> pSs = [SELECT Id FROM PlayerStatistics__c WHERE Tournament__c = :t.Id];
        
        System.assertEquals(3, pSs.size());
        
        AfterUpdateGameTriggerHelper.generateGamesOrFinishTournament(games, games);
        
        t = [SELECT Id, Name, Format__c, Type__c, Status__c FROM Tournament__c WHERE Id = :t.Id];
        
        System.assertEquals(3, games.size());
        System.assertEquals('Current', t.Status__c);
        System.assertEquals(0, games[0].Stage__c);
        System.assertEquals(1, games[1].Stage__c);
        System.assertEquals(false, games[1].WinningGroup__c);
        System.assertEquals(1, games[2].Stage__c);
        
        Game__c g0 = new Game__c(Id = games[0].Id, FirstCompetitor__c = games[0].FirstCompetitor__c, SecondCompetitor__c = games[0].SecondCompetitor__c,
            FirstCompetitorAccept__c = true, SecondCompetitorAccept__c = true, WinningGroup__c = games[0].WinningGroup__c, FirstCompetitorScore__c = 2, SecondCompetitorScore__c = 1, Stage__c = games[0].Stage__c, Tournament__c = games[0].Tournament__c);
        
        System.assertNotEquals('?', games[2].FirstCompetitor__c, 'qq1');
        
        Test.startTest();
        
        update (g0);
        
        List<Game__c> newGames = [SELECT Id, FirstCompetitor__c, SecondCompetitor__c, FirstCompetitorAccept__c, SecondCompetitorAccept__c, FirstCompetitorScore__c, SecondCompetitorScore__c, Tournament__c, Stage__c, WinningGroup__c FROM Game__c ORDER BY Stage__c ASC, WinningGroup__c ASC];
        
        //AfterUpdateGameTriggerHelper.generateGamesOrFinishTournament(games, newGames);
        
        System.assertEquals(3, newGames.size());
        
        System.debug('1: ' + newGames[2].SecondCompetitor__c);
        System.debug('2: ' + newGames[1].FirstCompetitor__c);
        
        System.assertNotEquals('?', newGames[2].SecondCompetitor__c, 'qq');
        System.assertNotEquals('?', newGames[1].FirstCompetitor__c, 'ww');
        
        g0 = new Game__c(Id = newGames[2].Id, FirstCompetitor__c = newGames[2].FirstCompetitor__c, SecondCompetitor__c = newGames[2].SecondCompetitor__c,
            FirstCompetitorAccept__c = true, SecondCompetitorAccept__c = true, WinningGroup__c = newGames[2].WinningGroup__c, FirstCompetitorScore__c = 2, SecondCompetitorScore__c = 1, Stage__c = newGames[2].Stage__c, Tournament__c = newGames[2].Tournament__c);
        
        update (g0);
        
        games = [SELECT Id, FirstCompetitor__c, SecondCompetitor__c, FirstCompetitorAccept__c, SecondCompetitorAccept__c, FirstCompetitorScore__c, SecondCompetitorScore__c, Tournament__c, Stage__c, WinningGroup__c FROM Game__c ORDER BY Stage__c ASC, WinningGroup__c ASC];
        
        System.assertEquals(4, games.size());
        
        newGames = [SELECT Id, FirstCompetitor__c, SecondCompetitor__c, FirstCompetitorAccept__c, SecondCompetitorAccept__c, FirstCompetitorScore__c, SecondCompetitorScore__c, Tournament__c, Stage__c, WinningGroup__c FROM Game__c WHERE WinningGroup__c = false];
        
        System.assertEquals(1, newGames.size());
        
        g0 = newGames[0];
        g0.FirstCompetitorAccept__c = true;
        g0.SecondCompetitorAccept__c = true;
        g0.FirstCompetitorScore__c = 2;
        g0.SecondCompetitorScore__c = 0;
        
        update (g0);
        
        newGames = [SELECT Id, FirstCompetitor__c, SecondCompetitor__c, FirstCompetitorAccept__c, SecondCompetitorAccept__c, FirstCompetitorScore__c, SecondCompetitorScore__c, Tournament__c, Stage__c, WinningGroup__c FROM Game__c WHERE Type__c = 'Super Final'];
        
        System.assertNotEquals('?', newGames[0].SecondCompetitor__c, 'qq3');
        System.assertNotEquals('?', newGames[0].FirstCompetitor__c, 'ww3');
        
        g0 = newGames[0];
        g0.FirstCompetitorAccept__c = true;
        g0.SecondCompetitorAccept__c = true;
        g0.FirstCompetitorScore__c = 0;
        g0.SecondCompetitorScore__c = 2;
        
        update (g0);
        
        newGames = [SELECT Id, FirstCompetitor__c, SecondCompetitor__c, FirstCompetitorAccept__c, SecondCompetitorAccept__c, FirstCompetitorScore__c, SecondCompetitorScore__c, Tournament__c, Stage__c, WinningGroup__c FROM Game__c];
        
        System.assertEquals(5, newGames.size());
        
        ids = new List<string>();
        ids.add(p0.Id);
        ids.add(p1.Id);
        
        insert (t1);
        insert (t2);
        
        RoundRobin.RoundRobinTournament(t2, ids);
        
        newGames = [SELECT Id, FirstCompetitor__c, SecondCompetitor__c, FirstCompetitorAccept__c, SecondCompetitorAccept__c, FirstCompetitorScore__c, SecondCompetitorScore__c, Tournament__c, Stage__c, WinningGroup__c FROM Game__c WHERE Tournament__c = :t2.Id];
        
        System.assertEquals(1, newGames.size());
        
        g0 = newGames[0];
        g0.FirstCompetitorAccept__c = true;
        g0.SecondCompetitorAccept__c = true;
        g0.FirstCompetitorScore__c = 0;
        g0.SecondCompetitorScore__c = 2;
        
        update (g0);
        
        List<Tournament__c> ts = [SELECT Id, Status__c FROM Tournament__c WHERE Id = :t2.Id];
        
        System.assertEquals('Completed', ts[0].Status__c);
        
        SingleEliminationTournament.StartSingleEliminationTournament(ids, t1);
        
        newGames = [SELECT Id, FirstCompetitor__c, SecondCompetitor__c, FirstCompetitorAccept__c, SecondCompetitorAccept__c, FirstCompetitorScore__c, SecondCompetitorScore__c, Tournament__c, Stage__c, WinningGroup__c FROM Game__c WHERE Tournament__c = :t1.Id];
        
        g0 = newGames[0];
        g0.FirstCompetitorAccept__c = true;
        g0.SecondCompetitorAccept__c = true;
        g0.FirstCompetitorScore__c = 0;
        g0.SecondCompetitorScore__c = 2;
        
        update (g0);
        
        ts = [SELECT Id, Status__c FROM Tournament__c WHERE Id = :t1.Id];
        
        System.assertEquals('Completed', ts[0].Status__c);
        
        Test.stopTest();
    }
    
}