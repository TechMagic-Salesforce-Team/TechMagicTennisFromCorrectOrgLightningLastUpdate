@isTest
public with sharing class DoubleEliminationTournament_TEST {
    
    public static DoubleEliminationTournament det = new DoubleEliminationTournament();
    public static Tournament__c t = new Tournament__c(Name='qwer', Type__c='Double Elimination', Format__c='1 x 1', StartDate__c=DateTime.now(), Status__c='Upcoming');
    
    public static testMethod void testProperties() {
        
        System.assertEquals(1, det.competitorsName.size());
        
        det.oneTournament = new Tournament__c();
        
        System.assertEquals(0, det.representDoubleEliminationGrid.size());
        
        System.assertEquals(1, det.ijz);
        
        insert(t);
        det.oneTournament = t;
        
        System.assertEquals(1, det.competitorsName.size());
        System.assertEquals(1, det.representDoubleEliminationGrid.size());
    }
    
    public static testMethod void testGenerateRounds() {

        insert(t);

        DoubleEliminationTournament.generateRounds(new List<String>(), t.Id);

        Tournament__c t11 = [SELECT Id, Status__c FROM Tournament__c WHERE Id = :t.Id];

        System.assertEquals('Completed', t11.Status__c);

        t11.Status__c = 'Upcoming';
        update(t11);

        Player__c p0 = new Player__c(Email__c = 'vdv@vdv.dv', IsManager__c = true, Password__c = '1234567890', Name = 'bdf', Status__c = 'Active');
        insert (p0);
        Player__c p1 = new Player__c(Email__c = '1vdv@vdv.dv', IsManager__c = true, Password__c = '1234567890', Name = 'bdf', Status__c = 'Active');
        insert (p1);
        Player__c p2 = new Player__c(Email__c = '2vdv@vdv.dv', IsManager__c = true, Password__c = '1234567890', Name = 'bdf', Status__c = 'Active');
        insert (p2);

        List<Player__c> players = [select Id,Password__c from Player__c];

        List<String> ids = new List<String>();

        for (Player__c p : players) {
            ids.add(p.Id);
        }

        DoubleEliminationTournament.generateRounds(ids, t.Id);

        List<Game__c> games = [select Id from Game__c];

        System.assertEquals(3, games.size());

    }

}