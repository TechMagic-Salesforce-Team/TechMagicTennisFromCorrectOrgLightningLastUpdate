@isTest
public with sharing class SingleEliminationTournamentTest{
    
     public static testMethod void propertiesTest(){
         
         //Right Parameters For players
         Tournament__c t = new Tournament__c(StartDate__c = DateTime.now(),Format__c ='1 x 1', Type__c = 'Single Elimination', Status__c = 'Current', Name = 'MyTournament3');
         Player__c myPlayer = new Player__c(Name = 'MyName' , Password__c ='zxcvczzxc' , Email__c = 'www@gmail.com');
         insert t;
         insert myPlayer;
         SingleEliminationTournament thisSET = new SingleEliminationTournament();
         System.assertEquals(1,thisSET.ijz);
         List<String> myIds = new List<String>();
         myIds.add('1');
         myIds.add('2');
         myIds.add('3');
         myIds.add('4');
         myIds.add('5');
         myIds.add('6');
         SingleEliminationTournament.StartSingleEliminationTournament(myIds, t);
         Integer gamesCount = [Select COUNT() From Game__c];
         System.assertEquals(6,gamesCount);
         myIds.add('7');
         SingleEliminationTournament.StartSingleEliminationTournament(myIds, t);
         gamesCount = [Select COUNT() From Game__c];
         System.assertEquals(13,gamesCount);
         myIds.add('8');
         SingleEliminationTournament.StartSingleEliminationTournament(myIds, t);
         gamesCount = [Select COUNT() From Game__c];
         System.assertEquals(21,gamesCount);
         myIds.add('9');
         SingleEliminationTournament.StartSingleEliminationTournament(myIds, t);
         gamesCount = [Select COUNT() From Game__c];
         System.assertEquals(30,gamesCount);
         myIds.add('10');
         SingleEliminationTournament.StartSingleEliminationTournament(myIds, t);
         gamesCount = [Select COUNT() From Game__c];
         System.assertEquals(40,gamesCount);
         myIds.add('11');
         myIds.add('12');
         myIds.add('13');
         myIds.add('14');
         myIds.add('15');
         myIds.add('16');
         myIds.add('17');
         SingleEliminationTournament.StartSingleEliminationTournament(myIds, t);
         gamesCount = [Select COUNT() From Game__c];
         System.assertEquals(57,gamesCount);
     
         //Wrong Parameters, and method get DMLException
         Tournament__c t2 = new Tournament__c(StartDate__c = DateTime.now(),Format__c ='1 x 1', Type__c = 'Double Elimination', Status__c = 'Current', Name = 'MyTournament3');
         SingleEliminationTournament.StartSingleEliminationTournament(myIds, t2);
         gamesCount = [Select COUNT() From Game__c];
         System.assertEquals(57,gamesCount);
         delete [SELECT ID FROM Game__c]; 
         
         //Test size which will have pageblocktable single elimination tournament 
         Player__c myPlayer10 = new Player__c(Name = 'MyName' , Password__c ='zxcvczzxc' , Email__c = 'www10@gmail.com');
         Player__c myPlayer11 = new Player__c(Name = 'MyName' , Password__c ='zxcvczzxc' , Email__c = 'www11@gmail.com');
         insert myPlayer10;
         insert myPlayer11;
         //without games, countOfStageOneTournament don't throw any exceptions 
         System.assertNotEquals(null,thisSET.countOfStageOneTournament); 
         SingleEliminationTournament thisSET2Games = new SingleEliminationTournament();
         
         //tournament will have only one stage, if countOfStageOneTournament = 3 than table will have only 33% width
         Tournament__c t4 = new Tournament__c(StartDate__c = DateTime.now(),Format__c ='1 x 1', Type__c = 'Single Elimination', Status__c = 'Current', Name = 'MyTournament4');
         insert t4;
         Game__c game1 = new Game__c(FirstCompetitor__c = myPlayer10.Id, SecondCompetitor__c = myPlayer11.Id, FirstCompetitorScore__c = 0, SecondCompetitorScore__c = 0, Stage__c = 1, Tournament__c = t4.id, WinningGroup__c = true); 
         insert game1;
         SingleEliminationTournament thisTestCount33WidthTest = new SingleEliminationTournament();
         thisTestCount33WidthTest.representSingleEliminationGrid = thisTestCount33WidthTest.generateSingleEliminationStageGrid(t4);
         System.assertEquals(3,thisTestCount33WidthTest.countOfStageOneTournament);

         //tournament will have 2 stage, if countOfStageOneTournament = 2 than table will have only 50% width
         Tournament__c t5 = new Tournament__c(StartDate__c = DateTime.now(),Format__c ='1 x 1', Type__c = 'Single Elimination', Status__c = 'Current', Name = 'MyTournament5');
         insert t5;
         Game__c game2 = new Game__c(FirstCompetitor__c = myPlayer10.Id, SecondCompetitor__c = myPlayer11.Id, FirstCompetitorScore__c = 0, SecondCompetitorScore__c = 0, Stage__c = 1, Tournament__c = t5.id, WinningGroup__c = true); 
         Game__c game3 = new Game__c(FirstCompetitor__c = myPlayer11.Id, SecondCompetitor__c = myPlayer10.Id, FirstCompetitorScore__c = 0, SecondCompetitorScore__c = 0, Stage__c = 1, Tournament__c = t5.id, WinningGroup__c = true); 
         Game__c game4 = new Game__c(FirstCompetitor__c = myPlayer11.Id, SecondCompetitor__c = myPlayer10.Id, FirstCompetitorScore__c = 0, SecondCompetitorScore__c = 0, Stage__c = 2, Tournament__c = t5.id, WinningGroup__c = true); 
         Game__c game5 = new Game__c(FirstCompetitor__c = myPlayer11.Id, SecondCompetitor__c = myPlayer10.Id, FirstCompetitorScore__c = 0, SecondCompetitorScore__c = 0, Stage__c = 2, Tournament__c = t5.id, WinningGroup__c = false); 
         insert game2;
         insert game3;
         insert game4;
         insert game5;
         SingleEliminationTournament thisTestCount = new SingleEliminationTournament();
         thisTestCount.representSingleEliminationGrid = thisTestCount.generateSingleEliminationStageGrid(t5);
         /*System.assertEquals(2,thisTestCount.countOfStageOneTournament);
         
         thisTestCount.representSingleEliminationGrid = null;
         //tournament will have 3+ stages, if countOfStageOneTournament = 1 than table will have 100% width
         Tournament__c tournamentTestCountOfStage = new Tournament__c(StartDate__c = DateTime.now(),Format__c ='1 x 1', Type__c = 'Single Elimination', Status__c = 'Current', Name = 'tournamentTestCountOfStage');
         insert tournamentTestCountOfStage;
         Game__c gameTest1 = new Game__c(FirstCompetitor__c = myPlayer10.Id, SecondCompetitor__c = myPlayer11.Id, FirstCompetitorScore__c = 0, SecondCompetitorScore__c = 0, Stage__c = 1, Tournament__c = tournamentTestCountOfStage.id, WinningGroup__c = true); 
         Game__c gameTest2 = new Game__c(FirstCompetitor__c = myPlayer11.Id, SecondCompetitor__c = myPlayer10.Id, FirstCompetitorScore__c = 0, SecondCompetitorScore__c = 0, Stage__c = 1, Tournament__c = tournamentTestCountOfStage.id, WinningGroup__c = true); 
         Game__c gameTest3 = new Game__c(FirstCompetitor__c = myPlayer10.Id, SecondCompetitor__c = myPlayer11.Id, FirstCompetitorScore__c = 0, SecondCompetitorScore__c = 0, Stage__c = 1, Tournament__c = tournamentTestCountOfStage.id, WinningGroup__c = true); 
         Game__c gameTest4 = new Game__c(FirstCompetitor__c = myPlayer11.Id, SecondCompetitor__c = myPlayer10.Id, FirstCompetitorScore__c = 0, SecondCompetitorScore__c = 0, Stage__c = 1, Tournament__c = tournamentTestCountOfStage.id, WinningGroup__c = true); 
         Game__c gameTest5 = new Game__c(FirstCompetitor__c = myPlayer11.Id, SecondCompetitor__c = myPlayer10.Id, FirstCompetitorScore__c = 0, SecondCompetitorScore__c = 0, Stage__c = 2, Tournament__c = tournamentTestCountOfStage.id, WinningGroup__c = true); 
         Game__c gameTest6 = new Game__c(FirstCompetitor__c = myPlayer11.Id, SecondCompetitor__c = myPlayer10.Id, FirstCompetitorScore__c = 0, SecondCompetitorScore__c = 0, Stage__c = 2, Tournament__c = tournamentTestCountOfStage.id, WinningGroup__c = true); 
         Game__c gameTest7 = new Game__c(FirstCompetitor__c = myPlayer11.Id, SecondCompetitor__c = myPlayer10.Id, FirstCompetitorScore__c = 0, SecondCompetitorScore__c = 0, Stage__c = 3, Tournament__c = tournamentTestCountOfStage.id, WinningGroup__c = true); 
         Game__c gameTest8 = new Game__c(FirstCompetitor__c = myPlayer11.Id, SecondCompetitor__c = myPlayer10.Id, FirstCompetitorScore__c = 0, SecondCompetitorScore__c = 0, Stage__c = 3, Tournament__c = tournamentTestCountOfStage.id, WinningGroup__c = false); 
         insert gameTest1;
         insert gameTest2;
         insert gameTest3;
         insert gameTest4;
         insert gameTest5;
         insert gameTest6;
         insert gameTest7;
         insert gameTest8;
         thisTestCount.representSingleEliminationGrid = thisTestCount.generateSingleEliminationStageGrid(tournamentTestCountOfStage);
         System.assertEquals(1,thisTestCount.countOfStageOneTournament);
       
         //Test loserGroupGame in List<List<Game__c>>()
         delete [SELECT ID FROM Game__c]; 
         Player__c myPlayer1 = new Player__c(Name = 'MyName' , Password__c ='zxcvczzxc' , Email__c = 'www1@gmail.com');
         Player__c myPlayer2 = new Player__c(Name = 'MyName' , Password__c ='zxcvczzxc' , Email__c = 'www2@gmail.com');
         insert myPlayer1;
         insert myPlayer2;
         Game__c gameTestLoserGroup1 = new Game__c(FirstCompetitor__c = myPlayer1.Id, SecondCompetitor__c = myPlayer2.Id, FirstCompetitorScore__c = 0, SecondCompetitorScore__c = 0, Stage__c = 1, Tournament__c = t.id, WinningGroup__c = true); 
         Game__c gameTestLoserGroup2 = new Game__c(FirstCompetitor__c = myPlayer2.Id, SecondCompetitor__c = myPlayer1.Id, FirstCompetitorScore__c = 0, SecondCompetitorScore__c = 0, Stage__c = 1, Tournament__c = t.id, WinningGroup__c = false); 
         insert gameTestLoserGroup1;
         insert gameTestLoserGroup2;
         thisSET.representSingleEliminationGrid = thisSET.generateSingleEliminationStageGrid(t);
         //thisSET.representSingleEliminationGrid.get(0).add(gameTestLoserGroup1);
         //thisSET.representSingleEliminationGrid.get(0).add(gameTestLoserGroup2);*/

     } 
     
     /*public static testMethod void generateSingleEliminationStageGridTest(){
         //Test when method get right Parameters
         Tournament__c t = new Tournament__c(StartDate__c = DateTime.now(),Format__c ='1 x 1', Type__c = 'Single Elimination', Status__c = 'Current', Name = 'MyTournament3');
         insert t;
         List<List<Game__c>> thisListListGames = new List<List<Game__c>>();
         List<Game__c> thisListGames = new List<Game__c>();
         thisListGames.add(
             new Game__c(FirstCompetitor__c='zxc', SecondCompetitor__c='cxz', FirstCompetitorScore__c=0, SecondCompetitorScore__c=0, Stage__c=1, Tournament__c=t.id)
         );         
         thisListGames.add(
             new Game__c(FirstCompetitor__c='zxc', SecondCompetitor__c='cxz', FirstCompetitorScore__c=0, SecondCompetitorScore__c=0, Stage__c=1, Tournament__c=t.id)
         );         
         thisListGames.add(
             new Game__c(FirstCompetitor__c='zxc', SecondCompetitor__c='cxz', FirstCompetitorScore__c=0, SecondCompetitorScore__c=0, Stage__c=1, Tournament__c=t.id)
         );         
         thisListGames.add(
             new Game__c(FirstCompetitor__c='zxc', SecondCompetitor__c='cxz', FirstCompetitorScore__c=0, SecondCompetitorScore__c=0, Stage__c=1, Tournament__c=t.id)
         );
         thisListGames.add(
             new Game__c(FirstCompetitor__c='zxc', SecondCompetitor__c='cxz', FirstCompetitorScore__c=0, SecondCompetitorScore__c=0, Stage__c=2, Tournament__c=t.id)
         );         
         thisListGames.add(
             new Game__c(FirstCompetitor__c='zxc', SecondCompetitor__c='cxz', FirstCompetitorScore__c=0, SecondCompetitorScore__c=0, Stage__c=2, Tournament__c=t.id)
         );
         thisListGames.add(
             new Game__c(FirstCompetitor__c='zxc', SecondCompetitor__c='cxz', FirstCompetitorScore__c=0, SecondCompetitorScore__c=0, Stage__c=3, Tournament__c=t.id)
         );
         insert thisListGames;    
         SingleEliminationTournament thisSET = new SingleEliminationTournament();
         System.assertEquals(null,thisSET.oneTournament);
         System.assertEquals(0,thisSET.competitorsName.size());
         thisSet.oneTournament = t;
         System.assertEquals(t.id,thisSet.oneTournament.id);
         //because first and second competitor has wrong id
         System.assertEquals(1,thisSet.competitorsName.size());
         
         thisListListGames = thisSET.generateSingleEliminationStageGrid(t);
         //thisSET.representSingleEliminationGrid = thisSET.generateSingleEliminationStageGrid(thisSET.oneTournament);
         if(thisSET.oneTournament == null) throw new NullPointerException(); 
         //if(thisSET.representSingleEliminationGrid.size() == 0){throw new NullPointerException();}
         //System.assertEquals(3, thisListListGames.size());
         //System.assertEquals(thisSET.generateSingleEliminationStageGrid(thisSET.oneTournament).size(), thisListListGames.size());
         //System.assertEquals(thisSET.representSingleEliminationGrid.size(), thisListListGames.size());
         Integer countGames = 0;
         for(List<Game__c> eachListGame : thisSET.representSingleEliminationGrid){
             for(Game__c ecahGame : eachListGame){
                 countGames++;
             }
         }
         System.assertEquals(7, countGames); 
         
         //Test when method get wrong Parameters(Wrong Type)
         Tournament__c tWrong = new Tournament__c(StartDate__c = DateTime.now(),Format__c ='1 x 1', Type__c = 'Round Robin', Status__c = 'Current', Name = 'MyTournament');
         insert tWrong ;
         List<List<Game__c>> wrongTestList = thisSET.generateSingleEliminationStageGrid(tWrong);
         System.assertEquals(0,wrongTestList.size());
         //Invalid Parameter Format
         Tournament__c tWrongFormat = new Tournament__c(StartDate__c = DateTime.now(),Format__c ='1 x 2', Type__c = 'Round Robin', Status__c = 'Current', Name = 'MyTournament');
         try{
             insert tWrong;
             List<List<Game__c>> wrongTestListFormat = thisSET.generateSingleEliminationStageGrid(tWrongFormat);
             System.assertEquals(0,wrongTestListFormat.size());
         }
         catch(DMLException e){}
         
         //One Game             
         Tournament__c tOneParameter = new Tournament__c(StartDate__c = DateTime.now(),Format__c ='1 x 1', Type__c = 'Single Elimination', Status__c = 'Current', Name = 'MyTournament');
         insert tOneParameter;
         upsert new Game__c(FirstCompetitor__c='zxc1', SecondCompetitor__c='cxz1', FirstCompetitorScore__c=0, SecondCompetitorScore__c=0, Stage__c=1, Tournament__c=tOneParameter.id);
         SingleEliminationTournament thisSETOneParameter = new SingleEliminationTournament();
         System.assertEquals(null,thisSETOneParameter.oneTournament);
         thisSETOneParameter.oneTournament = tOneParameter;
         System.assertEquals(tOneParameter.id,thisSETOneParameter.oneTournament.id);
         List<List<Game__c>> ListByOneGame = new List<List<Game__c>>();
         ListByOneGame = thisSETOneParameter.generateSingleEliminationStageGrid(tOneParameter);
         System.assertEquals(1, ListByOneGame.size());
         Integer countGamesByOneGames = 0;
         for(List<Game__c> eachListGame : thisSETOneParameter.representSingleEliminationGrid){
             for(Game__c ecahGame : eachListGame){
                 countGamesByOneGames ++;
             }
         }
         System.assertEquals(1, countGamesByOneGames );
         List<Game__c> deleteList = [Select ID FROM Game__c Where Tournament__c = :tOneParameter.Id];
         delete deleteList;
         //5 games
         upsert new Game__c(FirstCompetitor__c='zxc2', SecondCompetitor__c='cxz2', FirstCompetitorScore__c=0, SecondCompetitorScore__c=0, Stage__c=1, Tournament__c=tOneParameter.id);
         upsert new Game__c(FirstCompetitor__c='zxc2', SecondCompetitor__c='cxz2', FirstCompetitorScore__c=0, SecondCompetitorScore__c=0, Stage__c=2, Tournament__c=tOneParameter.id);
         upsert new Game__c(FirstCompetitor__c='zxc2', SecondCompetitor__c='cxz2', FirstCompetitorScore__c=0, SecondCompetitorScore__c=0, Stage__c=2, Tournament__c=tOneParameter.id);
         upsert new Game__c(FirstCompetitor__c='zxc2', SecondCompetitor__c='cxz2', FirstCompetitorScore__c=0, SecondCompetitorScore__c=0, Stage__c=3, Tournament__c=tOneParameter.id);
         upsert new Game__c(FirstCompetitor__c='zxc2', SecondCompetitor__c='cxz2', FirstCompetitorScore__c=0, SecondCompetitorScore__c=0, Stage__c=3, Tournament__c=tOneParameter.id, WinningGroup__c = false);
         List<List<Game__c>> ListByTwoGame = new List<List<Game__c>>();
         ListByTwoGame = thisSETOneParameter.generateSingleEliminationStageGrid(tOneParameter);
         System.assertEquals(3, ListByTwoGame .size());
         deleteList = [Select ID FROM Game__c Where Tournament__c = :tOneParameter.Id];
         delete deleteList;
         //4 games
         upsert new Game__c(FirstCompetitor__c='zxc2', SecondCompetitor__c='cxz2', FirstCompetitorScore__c=0, SecondCompetitorScore__c=0, Stage__c=1, Tournament__c=tOneParameter.id);
         upsert new Game__c(FirstCompetitor__c='zxc2', SecondCompetitor__c='cxz2', FirstCompetitorScore__c=0, SecondCompetitorScore__c=0, Stage__c=1, Tournament__c=tOneParameter.id);
         upsert new Game__c(FirstCompetitor__c='zxc2', SecondCompetitor__c='cxz2', FirstCompetitorScore__c=0, SecondCompetitorScore__c=0, Stage__c=2, Tournament__c=tOneParameter.id);
         upsert new Game__c(FirstCompetitor__c='zxc2', SecondCompetitor__c='cxz2', FirstCompetitorScore__c=0, SecondCompetitorScore__c=0, Stage__c=2, Tournament__c=tOneParameter.id, WinningGroup__c = false);
         List<List<Game__c>> ListByThreeGame = new List<List<Game__c>>();
         ListByThreeGame = thisSETOneParameter.generateSingleEliminationStageGrid(tOneParameter);         
         System.assertEquals(2, ListByThreeGame .size());
         deleteList = [Select ID FROM Game__c Where Tournament__c = :tOneParameter.Id];
         delete deleteList;
         //8 games at first stage
         upsert new Game__c(FirstCompetitor__c='zxc1', SecondCompetitor__c='cxz8', FirstCompetitorScore__c=0, SecondCompetitorScore__c=0, Stage__c=1, Tournament__c=tOneParameter.id);
         upsert new Game__c(FirstCompetitor__c='zxc2', SecondCompetitor__c='cxz7', FirstCompetitorScore__c=0, SecondCompetitorScore__c=0, Stage__c=1, Tournament__c=tOneParameter.id);
         upsert new Game__c(FirstCompetitor__c='zxc3', SecondCompetitor__c='cxz6', FirstCompetitorScore__c=0, SecondCompetitorScore__c=0, Stage__c=1, Tournament__c=tOneParameter.id);
         upsert new Game__c(FirstCompetitor__c='zxc4', SecondCompetitor__c='cxz5', FirstCompetitorScore__c=0, SecondCompetitorScore__c=0, Stage__c=1, Tournament__c=tOneParameter.id);
         upsert new Game__c(FirstCompetitor__c='zxc5', SecondCompetitor__c='cxz4', FirstCompetitorScore__c=0, SecondCompetitorScore__c=0, Stage__c=1, Tournament__c=tOneParameter.id);
         upsert new Game__c(FirstCompetitor__c='zxc6', SecondCompetitor__c='cxz3', FirstCompetitorScore__c=0, SecondCompetitorScore__c=0, Stage__c=1, Tournament__c=tOneParameter.id);
         upsert new Game__c(FirstCompetitor__c='zxc7', SecondCompetitor__c='cxz2', FirstCompetitorScore__c=0, SecondCompetitorScore__c=0, Stage__c=1, Tournament__c=tOneParameter.id);
         upsert new Game__c(FirstCompetitor__c='zxc8', SecondCompetitor__c='cxz1', FirstCompetitorScore__c=0, SecondCompetitorScore__c=0, Stage__c=1, Tournament__c=tOneParameter.id);
         upsert new Game__c(FirstCompetitor__c='zxc1', SecondCompetitor__c='cxz8', FirstCompetitorScore__c=0, SecondCompetitorScore__c=0, Stage__c=2, Tournament__c=tOneParameter.id);
         upsert new Game__c(FirstCompetitor__c='zxc1', SecondCompetitor__c='cxz8', FirstCompetitorScore__c=0, SecondCompetitorScore__c=0, Stage__c=2, Tournament__c=tOneParameter.id);
         upsert new Game__c(FirstCompetitor__c='zxc1', SecondCompetitor__c='cxz8', FirstCompetitorScore__c=0, SecondCompetitorScore__c=0, Stage__c=2, Tournament__c=tOneParameter.id);
         upsert new Game__c(FirstCompetitor__c='zxc1', SecondCompetitor__c='cxz8', FirstCompetitorScore__c=0, SecondCompetitorScore__c=0, Stage__c=2, Tournament__c=tOneParameter.id);
         upsert new Game__c(FirstCompetitor__c='zxc1', SecondCompetitor__c='cxz8', FirstCompetitorScore__c=0, SecondCompetitorScore__c=0, Stage__c=3, Tournament__c=tOneParameter.id);
         upsert new Game__c(FirstCompetitor__c='zxc1', SecondCompetitor__c='cxz8', FirstCompetitorScore__c=0, SecondCompetitorScore__c=0, Stage__c=3, Tournament__c=tOneParameter.id);
         upsert new Game__c(FirstCompetitor__c='zxc1', SecondCompetitor__c='cxz8', FirstCompetitorScore__c=0, SecondCompetitorScore__c=0, Stage__c=4, Tournament__c=tOneParameter.id);
         upsert new Game__c(FirstCompetitor__c='zxc1', SecondCompetitor__c='cxz8', FirstCompetitorScore__c=0, SecondCompetitorScore__c=0, Stage__c=4, Tournament__c=tOneParameter.id, WinningGroup__c = false);

         List<List<Game__c>> ListByEightGameAtFirstStage = new List<List<Game__c>>();
         ListByEightGameAtFirstStage = thisSETOneParameter.generateSingleEliminationStageGrid(tOneParameter);          
         System.assertEquals(4, ListByEightGameAtFirstStage .size());
         for(List<Game__c> thisListGame : ListByEightGameAtFirstStage ){
             for(Game__c game : thisListGame){
                 
             }
         }
     }*/
     
     public static testmethod void createNextSingleEliminationStageTestForEvenNumberGames(){
         List<Game__c> thisListGames = new List<Game__c>();
         Tournament__c t = new Tournament__c(StartDate__c = DateTime.now(),Format__c ='1 x 1', Type__c = 'Single Elimination', Status__c = 'Current', Name = 'MyTournament3');
         insert t;
         Player__c myPlayer1 = new Player__c(Name = 'MyName' , Password__c ='zxcvczzxc' , Email__c = 'wwwTest1@gmail.com');
         Player__c myPlayer8 = new Player__c(Name = 'MyName' , Password__c ='zxcvczzxc' , Email__c = 'wwwTest8@gmail.com');
         Player__c myPlayer2 = new Player__c(Name = 'MyName' , Password__c ='zxcvczzxc' , Email__c = 'wwwTest2@gmail.com');
         Player__c myPlayer3 = new Player__c(Name = 'MyName' , Password__c ='zxcvczzxc' , Email__c = 'wwwTest3@gmail.com');
         Player__c myPlayer4 = new Player__c(Name = 'MyName' , Password__c ='zxcvczzxc' , Email__c = 'wwwTest4@gmail.com');
         Player__c myPlayer5 = new Player__c(Name = 'MyName' , Password__c ='zxcvczzxc' , Email__c = 'wwwTest5@gmail.com');
         Player__c myPlayer6 = new Player__c(Name = 'MyName' , Password__c ='zxcvczzxc' , Email__c = 'wwwTest6@gmail.com');
         Player__c myPlayer7 = new Player__c(Name = 'MyName' , Password__c ='zxcvczzxc' , Email__c = 'wwwTest7@gmail.com');
         Player__c myFreeSlot = new Player__c(Name = '-' , Password__c ='zxcvczzxc' , Email__c = 'www@gmail.com');
         List<Player__c> myPlayerList = new List<Player__c>();
         myPlayerList.add(myPlayer1);
         myPlayerList.add(myPlayer2);
         myPlayerList.add(myPlayer3);
         myPlayerList.add(myPlayer4);
         myPlayerList.add(myPlayer5);
         myPlayerList.add(myPlayer6);
         myPlayerList.add(myPlayer7);
         myPlayerList.add(myPlayer8);
         insert myPlayerList;
         insert myFreeSlot;
         thisListGames.add(
             new Game__c(FirstCompetitor__c=myPlayer1.Id, SecondCompetitor__c=myPlayer2.id, FirstCompetitorScore__c=0, SecondCompetitorScore__c=1, Stage__c=1, Tournament__c=t.id)
         );
         thisListGames.add(
             new Game__c(FirstCompetitor__c=myPlayer3.Id, SecondCompetitor__c=myPlayer4.id, FirstCompetitorScore__c=0, SecondCompetitorScore__c=2, Stage__c=1, Tournament__c=t.id)
         );
         thisListGames.add(
             new Game__c(FirstCompetitor__c=myPlayer6.Id, SecondCompetitor__c=myPlayer5.id, FirstCompetitorScore__c=0, SecondCompetitorScore__c=3, Stage__c=1, Tournament__c=t.id)
         );
         thisListGames.add(
             new Game__c(FirstCompetitor__c='?', SecondCompetitor__c='?', FirstCompetitorScore__c=0, SecondCompetitorScore__c=4, Stage__c=1, Tournament__c=t.id)
         );
         thisListGames.add(
             new Game__c(FirstCompetitor__c='?', SecondCompetitor__c='?', FirstCompetitorScore__c=0, SecondCompetitorScore__c=4, Stage__c=2, Tournament__c=t.id)
         );
         thisListGames.add(
             new Game__c(FirstCompetitor__c='?', SecondCompetitor__c='?', FirstCompetitorScore__c=0, SecondCompetitorScore__c=4, Stage__c=2, Tournament__c=t.id)
         );
         thisListGames.add(
             new Game__c(FirstCompetitor__c='?', SecondCompetitor__c='?', FirstCompetitorScore__c=0, SecondCompetitorScore__c=4, Stage__c=3, Tournament__c=t.id)
         );
         thisListGames.add(
             new Game__c(FirstCompetitor__c='?', SecondCompetitor__c='?', FirstCompetitorScore__c=0, SecondCompetitorScore__c=4, Stage__c=3, Tournament__c=t.id, WinningGroup__c = false)
         );
         insert thisListGames;
         SingleEliminationTournament.createNextSingleEliminationStage([SELECT Id, FirstCompetitor__c, SecondCompetitor__c, Stage__c, WinningGroup__c, Tournament__c,FirstCompetitorScore__c,SecondCompetitorScore__c From Game__c Where Stage__c = 1],t);
         List<Game__c> testStage2 = [SELECT Id, FirstCompetitor__c, SecondCompetitor__c, Stage__c, WinningGroup__c, Tournament__c,FirstCompetitorScore__c,SecondCompetitorScore__c FROM Game__c Where Stage__c = 2];
         System.assertEquals(2,testStage2.size());
         SingleEliminationTournament.createNextSingleEliminationStage(testStage2,t);
         List<Game__c> loserGames= [SELECT Id, FirstCompetitor__c, SecondCompetitor__c, Stage__c, WinningGroup__c, Tournament__c,FirstCompetitorScore__c,SecondCompetitorScore__c FROM Game__c Where Stage__c = 3];
         List<Game__c> WinningGroupStage3= [SELECT Id, FirstCompetitor__c, SecondCompetitor__c, Stage__c, WinningGroup__c, Tournament__c,FirstCompetitorScore__c,SecondCompetitorScore__c FROM Game__c 
                                            Where Stage__c = 3 AND WinningGroup__c = true AND Tournament__c = :t.id];
         List<Game__c> loserGroupStage3= [SELECT Id, FirstCompetitor__c, SecondCompetitor__c, Stage__c, WinningGroup__c, Tournament__c,FirstCompetitorScore__c,SecondCompetitorScore__c FROM Game__c 
                                          Where Stage__c = 3 AND WinningGroup__c = false AND Tournament__c = :t.id];
         System.assertEquals(2,loserGames.size()); 
         System.assertEquals(1,WinningGroupStage3.size()); 
         System.assertEquals(1,loserGroupStage3.size()); 
     }
     public static testmethod void createNextSingleEliminationStageTestFor5Games(){
         List<Game__c> thisListGames = new List<Game__c>();
         Tournament__c t = new Tournament__c(StartDate__c = DateTime.now(),Format__c ='1 x 1', Type__c = 'Single Elimination', Status__c = 'Current', Name = 'MyTournament3');
         insert t;
         Player__c myPlayer1 = new Player__c(Name = 'MyName' , Password__c ='zxcvczzxc' , Email__c = 'wwwTest1@gmail.com');
         Player__c myPlayer2 = new Player__c(Name = 'MyName' , Password__c ='zxcvczzxc' , Email__c = 'wwwTest2@gmail.com');
         Player__c myPlayer3 = new Player__c(Name = 'MyName' , Password__c ='zxcvczzxc' , Email__c = 'wwwTest3@gmail.com');
         Player__c myPlayer4 = new Player__c(Name = 'MyName' , Password__c ='zxcvczzxc' , Email__c = 'wwwTest4@gmail.com');
         Player__c myPlayer5 = new Player__c(Name = 'MyName' , Password__c ='zxcvczzxc' , Email__c = 'wwwTest5@gmail.com');
         List<Player__c> myPlayerList = new List<Player__c>();
         myPlayerList.add(myPlayer1);
         myPlayerList.add(myPlayer2);
         myPlayerList.add(myPlayer3);
         myPlayerList.add(myPlayer4);
         myPlayerList.add(myPlayer5);
         insert myPlayerList;
         thisListGames.add(
             new Game__c(FirstCompetitor__c=myPlayer1.Id, SecondCompetitor__c=myPlayer2.id, FirstCompetitorScore__c=0, SecondCompetitorScore__c=1, Stage__c=1, Tournament__c=t.id)
         );
         thisListGames.add(
             new Game__c(FirstCompetitor__c=myPlayer3.Id, SecondCompetitor__c=myPlayer4.id, FirstCompetitorScore__c=3, SecondCompetitorScore__c=2, Stage__c=2, Tournament__c=t.id)
         );
         thisListGames.add(
             new Game__c(FirstCompetitor__c=myPlayer5.Id, SecondCompetitor__c = '?', FirstCompetitorScore__c=0, SecondCompetitorScore__c=3, Stage__c=2, Tournament__c=t.id)
         );
         thisListGames.add(
             new Game__c(FirstCompetitor__c='?', SecondCompetitor__c='?', FirstCompetitorScore__c=2, SecondCompetitorScore__c=0, Stage__c=3, Tournament__c=t.id)
         );
         thisListGames.add(
             new Game__c(FirstCompetitor__c='?', SecondCompetitor__c='?', FirstCompetitorScore__c=0, SecondCompetitorScore__c=1, Stage__c=3, Tournament__c=t.id, WinningGroup__c = false)
         );
         insert thisListGames;
         SingleEliminationTournament.createNextSingleEliminationStage([SELECT Id, FirstCompetitor__c, SecondCompetitor__c, Stage__c, WinningGroup__c, Tournament__c,FirstCompetitorScore__c,SecondCompetitorScore__c FROM Game__c Where Stage__c = 1],t);
         List<Game__c> testStage2 = [SELECT Id, FirstCompetitor__c, SecondCompetitor__c, Stage__c, WinningGroup__c, Tournament__c,FirstCompetitorScore__c,SecondCompetitorScore__c FROM Game__c Where Stage__c = 2 AND SecondCompetitor__c != '?'];
         System.assertEquals(2,testStage2.size());
         SingleEliminationTournament.createNextSingleEliminationStage(testStage2,t);
         List<Game__c> loserGames= [SELECT Id, FirstCompetitor__c, SecondCompetitor__c, Stage__c, WinningGroup__c, Tournament__c,FirstCompetitorScore__c,SecondCompetitorScore__c FROM Game__c Where Stage__c = 3];
         List<Game__c> WinningGroupStage3= [SELECT Id, FirstCompetitor__c, SecondCompetitor__c, Stage__c, WinningGroup__c, Tournament__c,FirstCompetitorScore__c,SecondCompetitorScore__c FROM Game__c 
                                            Where Stage__c = 3 AND WinningGroup__c = true AND Tournament__c = :t.id AND FirstCompetitor__c != '?' AND SecondCompetitor__c !='?'];
         List<Game__c> loserGroupStage3= [SELECT Id, FirstCompetitor__c, SecondCompetitor__c, Stage__c, WinningGroup__c, Tournament__c,FirstCompetitorScore__c,SecondCompetitorScore__c FROM Game__c 
                                          Where Stage__c = 3 AND WinningGroup__c = false AND Tournament__c = :t.id AND FirstCompetitor__c != '?' AND SecondCompetitor__c !='?'];
         System.assertEquals(2,loserGames.size()); 
         System.assertEquals(1,WinningGroupStage3.size()); 
         System.assertEquals(1,loserGroupStage3.size());
     }
     public static testmethod void createNextSingleEliminationStageTestFor6Games(){
         List<Game__c> thisListGames = new List<Game__c>();
         Tournament__c t = new Tournament__c(StartDate__c = DateTime.now(),Format__c ='1 x 1', Type__c = 'Single Elimination', Status__c = 'Current', Name = 'MyTournament3');
         insert t;
         Player__c myPlayer1 = new Player__c(Name = 'MyName' , Password__c ='zxcvczzxc' , Email__c = 'wwwTest1@gmail.com');
         Player__c myPlayer2 = new Player__c(Name = 'MyName' , Password__c ='zxcvczzxc' , Email__c = 'wwwTest2@gmail.com');
         Player__c myPlayer3 = new Player__c(Name = 'MyName' , Password__c ='zxcvczzxc' , Email__c = 'wwwTest3@gmail.com');
         Player__c myPlayer4 = new Player__c(Name = 'MyName' , Password__c ='zxcvczzxc' , Email__c = 'wwwTest4@gmail.com');
         Player__c myPlayer5 = new Player__c(Name = 'MyName' , Password__c ='zxcvczzxc' , Email__c = 'wwwTest5@gmail.com');
         Player__c myPlayer6 = new Player__c(Name = 'MyName' , Password__c ='zxcvczzxc' , Email__c = 'wwwTest6@gmail.com');
         List<Player__c> myPlayerList = new List<Player__c>();
         myPlayerList.add(myPlayer1);
         myPlayerList.add(myPlayer2);
         myPlayerList.add(myPlayer3);
         myPlayerList.add(myPlayer4);
         myPlayerList.add(myPlayer5);
         myPlayerList.add(myPlayer6);
         insert myPlayerList;
         thisListGames.add(
             new Game__c(FirstCompetitor__c=myPlayer1.Id, SecondCompetitor__c=myPlayer2.id, FirstCompetitorScore__c=0, SecondCompetitorScore__c=1, Stage__c=1, Tournament__c=t.id)
         );
         thisListGames.add(
             new Game__c(FirstCompetitor__c=myPlayer3.Id, SecondCompetitor__c=myPlayer4.id, FirstCompetitorScore__c=0, SecondCompetitorScore__c=1, Stage__c=1, Tournament__c=t.id)
         );
         thisListGames.add(
             new Game__c(FirstCompetitor__c=myPlayer5.Id, SecondCompetitor__c=myPlayer6.id, FirstCompetitorScore__c=2, SecondCompetitorScore__c=0, Stage__c=2, Tournament__c=t.id)
         );
         thisListGames.add(
             new Game__c(FirstCompetitor__c = '?', SecondCompetitor__c = '?', FirstCompetitorScore__c=0, SecondCompetitorScore__c=3, Stage__c=2, Tournament__c=t.id)
         );
         thisListGames.add(
             new Game__c(FirstCompetitor__c='?', SecondCompetitor__c='?', FirstCompetitorScore__c=2, SecondCompetitorScore__c=0, Stage__c=3, Tournament__c=t.id)
         );
         thisListGames.add(
             new Game__c(FirstCompetitor__c='?', SecondCompetitor__c='?', FirstCompetitorScore__c=0, SecondCompetitorScore__c=1, Stage__c=3, Tournament__c=t.id, WinningGroup__c = false)
         );
         insert thisListGames;
         List<Game__c> thisGamesTest = [SELECT Id, FirstCompetitor__c, SecondCompetitor__c, Stage__c, WinningGroup__c, Tournament__c,FirstCompetitorScore__c,SecondCompetitorScore__c FROM Game__c Where Stage__c = 1 AND Tournament__c = :t.id];
         //if(thisGamesTest.size() == 2) throw new nullpointerexception();
         SingleEliminationTournament.createNextSingleEliminationStage(thisGamesTest ,t);
         List<Game__c> testStage2 = [SELECT Id, FirstCompetitor__c, SecondCompetitor__c, Stage__c, WinningGroup__c, Tournament__c,FirstCompetitorScore__c,SecondCompetitorScore__c FROM Game__c Where Stage__c = 2 AND FirstCompetitor__c != '?'];
         System.assertEquals(2,testStage2.size());
         SingleEliminationTournament.createNextSingleEliminationStage(testStage2,t);
         List<Game__c> loserGames= [SELECT Id, FirstCompetitor__c, SecondCompetitor__c, Stage__c, WinningGroup__c, Tournament__c,FirstCompetitorScore__c,SecondCompetitorScore__c FROM Game__c Where Stage__c = 3];
         List<Game__c> WinningGroupStage3= [SELECT Id, FirstCompetitor__c, SecondCompetitor__c, Stage__c, WinningGroup__c, Tournament__c,FirstCompetitorScore__c,SecondCompetitorScore__c FROM Game__c 
                                            Where Stage__c = 3 AND WinningGroup__c = true AND Tournament__c = :t.id];
         List<Game__c> loserGroupStage3= [SELECT Id, FirstCompetitor__c, SecondCompetitor__c, Stage__c, WinningGroup__c, Tournament__c,FirstCompetitorScore__c,SecondCompetitorScore__c FROM Game__c 
                                          Where Stage__c = 3 AND WinningGroup__c = false AND Tournament__c = :t.id];
         System.assertEquals(2,loserGames.size()); 
         System.assertEquals(1,WinningGroupStage3.size()); 
         System.assertEquals(1,loserGroupStage3.size());
     }
     public static testmethod void createNextSingleEliminationStageTestFor2Games(){
         List<Game__c> thisListGames = new List<Game__c>();
         Tournament__c t = new Tournament__c(StartDate__c = DateTime.now(),Format__c ='1 x 1', Type__c = 'Single Elimination', Status__c = 'Current', Name = 'MyTournament3');
         insert t;
         Player__c myPlayer1 = new Player__c(Name = 'MyName' , Password__c ='zxcvczzxc' , Email__c = 'wwwTest1@gmail.com');
         Player__c myPlayer2 = new Player__c(Name = 'MyName' , Password__c ='zxcvczzxc' , Email__c = 'wwwTest2@gmail.com');
         Player__c myPlayer3 = new Player__c(Name = 'MyName' , Password__c ='zxcvczzxc' , Email__c = 'wwwTest3@gmail.com');
         List<Player__c> myPlayerList = new List<Player__c>();
         myPlayerList.add(myPlayer1);
         myPlayerList.add(myPlayer2);
         myPlayerList.add(myPlayer3);
         insert myPlayerList;
         thisListGames.add(
             new Game__c(FirstCompetitor__c=myPlayer1.Id, SecondCompetitor__c=myPlayer2.id, FirstCompetitorScore__c=0, SecondCompetitorScore__c=1, Stage__c=1, Tournament__c=t.id)
         );
         thisListGames.add(
             new Game__c(FirstCompetitor__c=myPlayer3.Id, SecondCompetitor__c='?', FirstCompetitorScore__c=0, SecondCompetitorScore__c=2, Stage__c=2, Tournament__c=t.id)
         );
         insert thisListGames;
         SingleEliminationTournament.createNextSingleEliminationStage([SELECT Id, FirstCompetitor__c, SecondCompetitor__c, Stage__c, WinningGroup__c, Tournament__c,FirstCompetitorScore__c,SecondCompetitorScore__c FROM Game__c Where Stage__c = 1],t);
         List<Game__c> testStage2 = [SELECT Id, FirstCompetitor__c, SecondCompetitor__c, Stage__c, WinningGroup__c, Tournament__c,FirstCompetitorScore__c,SecondCompetitorScore__c FROM Game__c Where Stage__c = 2 AND SecondCompetitor__c != '?'];
         System.assertEquals(1,testStage2.size());
         //do nothing, and dont throw any errors
         SingleEliminationTournament.createNextSingleEliminationStage(testStage2,t);
         List<Game__c> WinningGroupStage3= [SELECT Id, FirstCompetitor__c, SecondCompetitor__c, Stage__c, WinningGroup__c, Tournament__c,FirstCompetitorScore__c,SecondCompetitorScore__c FROM Game__c 
                                            Where Stage__c = 2 AND WinningGroup__c = true AND Tournament__c = :t.id AND SecondCompetitor__c != '?'];
         List<Game__c> loserGroupStage3= [SELECT Id, FirstCompetitor__c, SecondCompetitor__c, Stage__c, WinningGroup__c, Tournament__c,FirstCompetitorScore__c,SecondCompetitorScore__c FROM Game__c 
                                          Where Stage__c = 2 AND WinningGroup__c = false AND Tournament__c = :t.id];
         System.assertEquals(1,WinningGroupStage3.size()); 
         System.assertEquals(0,loserGroupStage3.size());
     }
     
     public static testmethod void startSingleELiminationTournamentV2Test(){
         delete [Select Id From Game__c];
         Tournament__c t = new Tournament__c(StartDate__c = DateTime.now(),Format__c ='1 x 1', Type__c = 'Single Elimination', Status__c = 'Current', Name = 'MyTournament3');
         Tournament__c myT = new Tournament__c(StartDate__c = DateTime.now(),Format__c ='1 x 1', Type__c = 'Single Elimination', Status__c = 'Current', Name = 'MyTournament');
         Player__c myPlayer1 = new Player__c(Name = 'MyName1' , Password__c ='zxcvczzxc' , Email__c = 'www1@gmail.com');
         Player__c myPlayer2 = new Player__c(Name = 'MyName2' , Password__c ='zxcvczzxc' , Email__c = 'www2@gmail.com');
         Player__c myPlayer3 = new Player__c(Name = 'MyName3' , Password__c ='zxcvczzxc' , Email__c = 'www3@gmail.com');
         Player__c myPlayer4 = new Player__c(Name = 'MyName4' , Password__c ='zxcvczzxc' , Email__c = 'www4@gmail.com');
         Player__c myPlayer5 = new Player__c(Name = 'MyName5' , Password__c ='zxcvczzxc' , Email__c = 'www5@gmail.com');
         Player__c myPlayer6 = new Player__c(Name = 'MyName6' , Password__c ='zxcvczzxc' , Email__c = 'www6@gmail.com');
         Player__c myPlayer7 = new Player__c(Name = 'MyName7' , Password__c ='zxcvczzxc' , Email__c = 'www7@gmail.com');
         Player__c myPlayer8 = new Player__c(Name = 'MyName8' , Password__c ='zxcvczzxc' , Email__c = 'www8@gmail.com');
         Player__c myPlayer9 = new Player__c(Name = 'MyName9' , Password__c ='zxcvczzxc' , Email__c = 'www9@gmail.com');
         Player__c myPlayer10 = new Player__c(Name = 'MyName10' , Password__c ='zxcvczzxc' , Email__c = 'www10@gmail.com');
         Player__c myPlayer11 = new Player__c(Name = 'MyName11' , Password__c ='zxcvczzxc' , Email__c = 'www11@gmail.com');
         Player__c myPlayer12 = new Player__c(Name = 'MyName12' , Password__c ='zxcvczzxc' , Email__c = 'www12@gmail.com');
         Player__c myPlayer13 = new Player__c(Name = 'MyName13' , Password__c ='zxcvczzxc' , Email__c = 'www13@gmail.com');
         Player__c myPlayer14 = new Player__c(Name = 'MyName14' , Password__c ='zxcvczzxc' , Email__c = 'www14@gmail.com');
         Player__c myPlayer15 = new Player__c(Name = 'MyName15' , Password__c ='zxcvczzxc' , Email__c = 'www15@gmail.com');
         Player__c myPlayer16 = new Player__c(Name = 'MyName16' , Password__c ='zxcvczzxc' , Email__c = 'www16@gmail.com');
         List<Player__c> myPlayers = new List<Player__c>();
         myPlayers.add(myPlayer1);
         myPlayers.add(myPlayer2);
         myPlayers.add(myPlayer3);
         myPlayers.add(myPlayer4);
         myPlayers.add(myPlayer5);
         myPlayers.add(myPlayer6);
         myPlayers.add(myPlayer7);
         myPlayers.add(myPlayer8);
         myPlayers.add(myPlayer9);
         myPlayers.add(myPlayer10);
         myPlayers.add(myPlayer11);
         myPlayers.add(myPlayer12);
         myPlayers.add(myPlayer13);
         myPlayers.add(myPlayer14);
         myPlayers.add(myPlayer15);
         myPlayers.add(myPlayer16);
         insert t;
         insert myT;
         insert myPlayers; 
         List<PlayerTournament__c> myPlayerTournaments = new List<PlayerTournament__c>();
         myPlayerTournaments.add(new PlayerTournament__c(Player__c = myPlayer1.Id, Tournament__c = t.id));
         myPlayerTournaments.add(new PlayerTournament__c(Player__c = myPlayer2.Id, Tournament__c = t.id));    
         myPlayerTournaments.add(new PlayerTournament__c(Player__c = myPlayer3.Id, Tournament__c = t.id));    
         myPlayerTournaments.add(new PlayerTournament__c(Player__c = myPlayer4.Id, Tournament__c = t.id));    
         myPlayerTournaments.add(new PlayerTournament__c(Player__c = myPlayer5.Id, Tournament__c = t.id));    
         myPlayerTournaments.add(new PlayerTournament__c(Player__c = myPlayer6.Id, Tournament__c = t.id));    
         myPlayerTournaments.add(new PlayerTournament__c(Player__c = myPlayer7.Id, Tournament__c = t.id));    
         myPlayerTournaments.add(new PlayerTournament__c(Player__c = myPlayer8.Id, Tournament__c = t.id)); 
         myPlayerTournaments.add(new PlayerTournament__c(Player__c = myPlayer9.Id, Tournament__c = t.id));    
         myPlayerTournaments.add(new PlayerTournament__c(Player__c = myPlayer10.Id, Tournament__c = t.id));    
         myPlayerTournaments.add(new PlayerTournament__c(Player__c = myPlayer11.Id, Tournament__c = t.id));    
         myPlayerTournaments.add(new PlayerTournament__c(Player__c = myPlayer12.Id, Tournament__c = t.id));    
         myPlayerTournaments.add(new PlayerTournament__c(Player__c = myPlayer13.Id, Tournament__c = t.id));    
         myPlayerTournaments.add(new PlayerTournament__c(Player__c = myPlayer14.Id, Tournament__c = t.id));    
         myPlayerTournaments.add(new PlayerTournament__c(Player__c = myPlayer15.Id, Tournament__c = t.id));    
         myPlayerTournaments.add(new PlayerTournament__c(Player__c = myPlayer16.Id, Tournament__c = t.id)); 
         insert myPlayerTournaments;
         List<String> myCompetitorsIds = new List<String>();
         for(PlayerTournament__c x : myPlayerTournaments){
             myCompetitorsIds.add(x.Player__c);
         }   
         SingleEliminationTournament.StartSingleEliminationTournament(myCompetitorsIds, t);
         List<Game__c> myGamesInLoserGroup = [Select ID, WinningGroup__c From Game__c where WinningGroup__c = false AND Tournament__c = :t.id AND Type__c = 'Final'];
         System.assertEquals(1,myGamesInLoserGroup.size()); 
         System.assertEquals(16, [Select Id From Game__c Where Tournament__c = :t.id].size());
         System.assertEquals(0,[Select Id From Game__c Where Tournament__c = :t.id AND Stage__c = 1 AND (FirstCompetitor__c = '?' OR SecondCompetitor__c = '?')].size());
        
         List<PlayerTournament__c> myPlayerTournamentsTest = new List<PlayerTournament__c>();
         myPlayerTournamentsTest.add(new PlayerTournament__c(Player__c = myPlayer1.Id, Tournament__c = myT.id));    
         myPlayerTournamentsTest.add(new PlayerTournament__c(Player__c = myPlayer2.Id, Tournament__c = myT.id));    
         myPlayerTournamentsTest.add(new PlayerTournament__c(Player__c = myPlayer3.Id, Tournament__c = myT.id));    
         myPlayerTournamentsTest.add(new PlayerTournament__c(Player__c = myPlayer4.Id, Tournament__c = myT.id));    
         myPlayerTournamentsTest.add(new PlayerTournament__c(Player__c = myPlayer5.Id, Tournament__c = myT.id)); 
         insert myPlayerTournamentsTest;
         List<String> myCompetitorsIdsTest = new List<String>();
         for(PlayerTournament__c x : myPlayerTournamentsTest){
             myCompetitorsIdsTest.add(x.Player__c);
         }
         SingleEliminationTournament.StartSingleEliminationTournament(myCompetitorsIdsTest, myT);
         System.assertEquals(1,[Select Id From Game__c Where Tournament__c = :myT.id AND WinningGroup__c = false AND Type__c = 'Final'].size()); 
         System.assertEquals(1,[Select Id From Game__c Where Tournament__c = :myT.id AND WinningGroup__c = true AND Type__c = 'Final'].size()); 
         System.assertEquals(5,[Select Id From Game__c Where Tournament__c = :myT.id].size()); 
         System.assertEquals(0,[Select Id From Game__c Where Tournament__c = :myT.id AND Stage__c = 1 AND (FirstCompetitor__c = '?' OR SecondCompetitor__c = '?')].size());
         
         //tournament doesn't start, he already finished
         Tournament__c tournamentWichHaveOnlyOneCompetitor = new Tournament__c(StartDate__c = DateTime.now(),Format__c ='1 x 1', Type__c = 'Single Elimination', Status__c = 'Current', Name = 'MyTournament3');
         insert tournamentWichHaveOnlyOneCompetitor ;
         insert new PlayerTournament__c(Player__c = myPlayer1.Id, Tournament__c = tournamentWichHaveOnlyOneCompetitor .id);
         List<String> onlyOneCompetitort = new List<String>();
         onlyOneCompetitort.add([Select Player__c From PlayerTournament__c Where Tournament__c = :tournamentWichHaveOnlyOneCompetitor.id Limit 1].Player__c);   
         SingleEliminationTournament.StartSingleEliminationTournament(onlyOneCompetitort, tournamentWichHaveOnlyOneCompetitor);
         System.assertEquals(0,[Select id From Game__c Where Tournament__c = :tournamentWichHaveOnlyOneCompetitor.id].size());
         
         Tournament__c myT2Competitors = new Tournament__c(StartDate__c = DateTime.now(),Format__c ='1 x 1', Type__c = 'Single Elimination', Status__c = 'Current', Name = 'MyTournament2Comp');
         insert myT2Competitors; 
         List<PlayerTournament__c> myPlayerTournamentsTest2Competitors = new List<PlayerTournament__c>();
         myPlayerTournamentsTest2Competitors.add(new PlayerTournament__c(Player__c = myPlayer1.Id, Tournament__c = myT2Competitors.id));    
         myPlayerTournamentsTest2Competitors.add(new PlayerTournament__c(Player__c = myPlayer2.Id, Tournament__c = myT2Competitors.id)); 
         insert myPlayerTournamentsTest2Competitors;
         List<String> myPlayerTournamentsTest2CompetitorsIDs = new List<String>();
         for(PlayerTournament__c x : myPlayerTournamentsTest2Competitors){
             myPlayerTournamentsTest2CompetitorsIDs.add(x.Player__c);
         }
         SingleEliminationTournament.StartSingleEliminationTournament(myPlayerTournamentsTest2CompetitorsIDs, myT2Competitors);
         System.assertEquals(0,[Select Id From Game__c Where Tournament__c = :myT2Competitors.id AND WinningGroup__c = false AND Type__c = 'Final'].size()); 
         System.assertEquals(1,[Select Id From Game__c Where Tournament__c = :myT2Competitors.id AND WinningGroup__c = true AND Type__c = 'Final'].size());
     }
}