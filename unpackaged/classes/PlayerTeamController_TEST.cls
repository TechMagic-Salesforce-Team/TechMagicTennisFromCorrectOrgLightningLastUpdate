@isTest
public with sharing class PlayerTeamController_TEST {
    
    public static PlayerTeamController ptc = new PlayerTeamController();

    public static Tournament__c t = new Tournament__c(Name='qwer', Type__c='Double Elimination', Format__c='2 x 2', StartDate__c=DateTime.now(), Status__c='Upcoming');
    public static Player__c p0 = new Player__c(Email__c = 'vdv@vdv.dv', IsManager__c = true, Password__c = '1234567890', Name = 'bdf', Status__c = 'Active');
    public static Player__c p1 = new Player__c(Email__c = '1vdv@vdv.dv', IsManager__c = true, Password__c = '1234567890', Name = 'bdf', Status__c = 'Active');
    
    public static testMethod void testTournamentProperties() {
        System.assertEquals(null, ptc.tournamentId);
        System.assertEquals(null, ptc.currentPlayerId);
        System.assertEquals(0, ptc.players.size());
        System.assertEquals(null, ptc.team.Id);
        System.assertEquals(0, ptc.playersOptions.size());
        System.assertEquals(null, ptc.selectedPlayer);
        System.assertEquals(null, ptc.currentPlayer2);
        System.assertEquals(null, ptc.invitationTournamentId);
        System.assertEquals(null, ptc.invitationTeamId);
        System.assertEquals(null, ptc.invitationPlayerId);
        System.assertEquals(0, ptc.teamInvitations.size());
    }
    
    public static testMethod void testCancel() {
        PageReference pR = ptc.cancel();
        Test.startTest();
        
        System.assertEquals(Page.Tournaments.getUrl(), pR.getUrl());
        
        Test.stopTest(); 
    }
    
    public static testMethod void testValidatePageVisitor() {
        insert t;
        Test.setCurrentPageReference(new PageReference('Page.PlayerTeamCreate')); 
        System.currentPageReference().getParameters().put('tournamentId', t.Id);
        insert (p0);
        
        ptc = new PlayerTeamController();
        
        System.assertEquals(Page.Home.getUrl(), ptc.validatePageVisitor().getUrl());
        
        Cookie playerFromCookie = new Cookie('PlayerFromCookie', p0.Id, null, 1440, false);
        System.currentPageReference().setCookies(new Cookie[]{playerFromCookie});
        
        ptc = new PlayerTeamController();
        
        Test.startTest();
        
        System.assertEquals(null, ptc.validatePageVisitor());
        
        Test.stopTest();
    }
    
    public static testMethod void testCreate() {
        insert t;
        Test.setCurrentPageReference(new PageReference('Page.PlayerTeamCreate')); 
        System.currentPageReference().getParameters().put('tournamentId', t.Id);
        insert (p0);
        insert (p1);
        Cookie playerFromCookie = new Cookie('PlayerFromCookie', p0.Id, null, 1440, false);
        System.currentPageReference().setCookies(new Cookie[]{playerFromCookie});
        ptc = new PlayerTeamController();
        
        System.assertEquals(1, ptc.playersOptions.size());
        
        ptc.team.Name = 'qqq';
        ptc.selectedPlayer = p1.Id;
        
        Test.setMock(HttpCalloutMock.class,new MailSenderMock_Test());
        
        System.assertEquals(Page.Tournaments.getUrl(), ptc.create().getUrl());
        
        System.assertEquals(1, ptc.playersOptions.size());
        
        ptc.currentPlayer2 = p1;
        System.assertEquals(1, ptc.teamInvitations.size());
        
        ptc.invitationPlayerId = p0.Id;
        ptc.invitationTeamId = ptc.team.Id;
        
        ptc.acceptInvitation();
        
        List<Team__c> teams = [SELECT Id FROM Team__c WHERE IsComplete__c = true];
        
        System.assertEquals(1, teams.size());
        
        System.assertEquals(0, ptc.teamInvitations.size());
        
    }
}