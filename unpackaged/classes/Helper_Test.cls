@isTest
public with sharing class Helper_Test {
    
 @isTest private static void getIdAndNameMapbyPlayerTest(){
        Player__c newPlayer3 = new Player__c(name = 'newPlayer1',email__c = 'dd@ddd.dd',IsManager__c=false,Password__c = '66666666666',Status__c = 'Active');
        insert newPlayer3;
        Tournament__C tournament = new Tournament__c(name='ddd',format__c = '1 x 1',StartDate__c = Datetime.now(),Status__c='Current',type__c= 'Round Robin');
        insert tournament;
        PlayerTournament__c playerTournament = new PlayerTournament__c();
        playerTournament.Player__c = newPlayer3.Id;
        playerTournament.Tournament__c = tournament.Id;
        insert playerTournament;
        System.assertEquals(1, Helper.getIdAndNameMap(tournament).size()); 
    }
     @isTest private static void getIdAndNameMapbyTeamTest(){
        Tournament__C tournament = new Tournament__c(name='ddd',format__c = '2 x 2',StartDate__c = Datetime.now(),Status__c='Current',type__c= 'Round Robin');  
        insert tournament;
        Team__c team = new Team__c(name='bigDogsTeam',Tournament__c = tournament.id);
        insert team;
        Map<String , String> idAndName= new Map<String , String>();
        System.assertEquals(1, Helper.getIdAndNameMap(tournament).size());  
    }
}