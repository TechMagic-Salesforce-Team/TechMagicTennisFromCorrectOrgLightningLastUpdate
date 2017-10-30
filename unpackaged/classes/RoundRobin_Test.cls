@isTest
public with sharing class RoundRobin_Test {  
    @isTest private static void roundRobinCreateGames(){
        Player__c newPlayer3 = new Player__c(name = 'newPlayer1',email__c = 'dd@ddd.dd',IsManager__c=false,Password__c = '6666666666666666',Status__c = 'Active');
        Player__c newPlayer1 = new Player__c(name = 'newPlayer2',email__c = 'dd@dd.dd',IsManager__c=false,Password__c = '6666666666666',Status__c = 'Active');
        Player__c newPlayer2 = new Player__c(name = 'newPlayer3',email__c = 'dd@dddd.dd',IsManager__c=false,Password__c = '666666666666',Status__c = 'Active');
        insert newPlayer2;
        insert newPlayer3;
        insert newPlayer1;
        Tournament__C tournament1 = new Tournament__c(name='dd',format__c = '1 x 1',StartDate__c = Datetime.now(),Status__c='Current',type__c= 'Round Robin');
        insert tournament1;
        List<String> allnames = new List<String>();
        allnames.add(newPlayer1.id+'');
        allnames.add(newPlayer2.id+'');
        allnames.add(newPlayer3.id+'');
        List<Game__c> games = new List<Game__c>();
        RoundRobin.RoundRobinTournament(tournament1, allnames);
        games = [Select id from Game__c where Tournament__c =:tournament1.id];
        System.assertEquals(3, games.size()); 
    }
      
    
    @isTest private static void gridTest(){
        RoundRobin roundRobin = new RoundRobin();  
        Tournament__C tournament = new Tournament__c(name='ddd',format__c = '2 x 2',StartDate__c = Datetime.now(),Status__c='Current',type__c= 'Round Robin');  
        insert tournament;
        System.assertEquals(1, roundRobin.RoundRobinGrid(tournament).size()); 
    }
     @isTest private static void gridTest2(){
        RoundRobin roundRobin = new RoundRobin();  
        Tournament__C tournament = new Tournament__c(name='ddd',format__c = '1 x 1',StartDate__c = Datetime.now(),Status__c='Current',type__c= 'Round Robin');  
        insert tournament;
        Player__c newPlayer1 = new Player__c(name = 'newPlayer1',email__c = 'dd@ddd.dd',IsManager__c=false,Password__c = '666666666',Status__c = 'Active');
        insert newPlayer1;
        Player__c newPlayer2 = new Player__c(name = 'newPlayer2',email__c = 'ddd@ddd.dd',IsManager__c=false,Password__c = '666666666',Status__c = 'Active');
        insert newPlayer2;
        Player__c newPlayer3 = new Player__c(name = 'newPlayer3',email__c = 'ddddd@ddd.dd',IsManager__c=false,Password__c = '666666666',Status__c = 'Active');
        insert newPlayer3;
        PlayerTournament__c playerTournament1 = new PlayerTournament__c();
        playerTournament1.Player__c = newPlayer1.Id;
        playerTournament1.Tournament__c = tournament.Id;
        insert playerTournament1;
        PlayerTournament__c playerTournament2 = new PlayerTournament__c();
        playerTournament2.Player__c = newPlayer2.Id;
        playerTournament2.Tournament__c = tournament.Id;
        insert playerTournament2;
        PlayerTournament__c playerTournament3 = new PlayerTournament__c();
        playerTournament3.Player__c = newPlayer3.Id;
        playerTournament3.Tournament__c = tournament.Id;
        insert playerTournament3;
        Game__c currentGame1 = new Game__c(FirstCompetitor__c = newPlayer1.id+'',SecondCompetitor__c=newPlayer2.id+'',Tournament__c =tournament.id);
        Game__c currentGame2 = new Game__c(FirstCompetitor__c = newPlayer1.id+'',SecondCompetitor__c=newPlayer3.id+'',Tournament__c =tournament.id);
        Game__c currentGame3 = new Game__c(FirstCompetitor__c = newPlayer2.id+'',SecondCompetitor__c=newPlayer3.id+'',Tournament__c =tournament.id);
        insert currentGame1;
        insert currentGame2;
        insert currentGame3;
        //List<List<GameJSO>> d = roundRobin.RoundRobinGrid(tournament);
        //System.assertEquals(4,d.size()); 
    }
}