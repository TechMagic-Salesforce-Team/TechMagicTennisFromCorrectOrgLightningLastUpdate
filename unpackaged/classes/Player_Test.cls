@isTest
public with sharing class Player_Test {
    public static testMethod void registrationTest(){
        Player__c player = new Player__c();
        player.Name = 'name';
        player.Email__c = 'email.com';
        player.Password__c = 'password';

        String confirmPassword = 'password';
        
        PlayerController playerController = new PlayerController();
        playerController.player = player;
        playerController.confirmPassword = confirmPassword;
        
       
        //expect null because email is not valid
        Boolean dmlSuccessful = playerController.registration()==null;
        if (dmlSuccessful){
            System.debug('Email is incorrect, so page we are getting equals to null');
        } else {
            throw new DmlException();
        }
        
        playerController.player.Email__c = 'email@gmail.com';
        playerController.player.Name = '';
        
        playerController.player.Name = 'Some name';
        playerController.player.Password__c = 'password';
        playerController.confirmPassword = 'confirmpassword';
        
        //expect null because passwords are not the same
        dmlSuccessful = playerController.registration()==null;
        if (!dmlSuccessful) throw new DmlException();
        
        //all data is valid
        playerController.confirmPassword = 'password';
        
        dmlSuccessful = playerController.registration()==null;
        //if (!dmlSuccessful) {
            //System.debug('All data is valid - inserted new player');
        //}
        
        //expect null,because of registering new player with email that is already exists in the db
        try {
            player = [select Id,Email__c from Player__c limit 1];
            playerController.player.Email__c = player.Email__c;
            dmlSuccessful = playerController.registration()==null;
            if (!dmlSuccessful) {
                throw new DmlException();
            }   
        } catch (QueryException ex){
            System.debug('There are no players in db');
        }
        
        //expect null,because passwords are the same, but equals to null
        playerController.player.Password__c = '';
        playerController.confirmPassword = '';
        
        dmlSuccessful = playerController.registration()==null;
        if (!dmlSuccessful) throw new DmlException();
    }
    
    public static testMethod void loginTest(){
        Player__c player = new Player__c();
        player.Name = 'Some name';
        player.Email__c = 'email@gmail.com';
        player.Password__c = '12345678';
        insert player;
        
        PlayerController playerController = new PlayerController();
        playerController.player = player;
        
        //all is OK
        Boolean playerSetToCookie = playerController.login()!=null;
        if (playerSetToCookie) throw new DmlException();
        
        player.Status__c = 'Active';
        playerController.login();
        
        //wrong password
        playerController.player.Password__c = '123456789';
        playerSetToCookie = playerController.login()==null;
        if (!playerSetToCookie) throw new DmlException();
        
        playerController.player.Email__c = 'this.email.not.exists@gmail.com';
        playerSetToCookie = playerController.login()==null;
        if (!playerSetToCookie) throw new DmlException();
    }
    
    public static testMethod void logoutTest(){
        PlayerController playerController = new PlayerController();
        if (playerController.logout()==null) throw new DmlException();
    }
    
    public static testMethod void constructorTest(){
        new PlayerController();
    }
    
    //is not necessary to test this just to cover code
    public static testMethod void findAllPlayersTest(){
        PlayerController playerController = new PlayerController();
        playerController.findAllPlayers();
    }
    
    public static testMethod void getPlayerTournamentsTest(){
        PlayerController playerController = new PlayerController();
        playerController.player = null;
        playerController.getPlayerTournaments();
        playerController.player = new Player__c();
        playerController.getPlayerTournaments();
        
        Player__c player = new Player__c();
        player.Name = 'Some name';
        player.Email__c = 'some.email@gmail.com';
        player.Password__c = 'password';
        insert player;
        
        
        Tournament__c tournament = new Tournament__c(
            Name = 'Some tournament',
            Status__c = 'Current',
            Format__c = '1 x 1',
            Type__c = 'Round Robin',
            StartDate__c = DateTime.now()
        );
        
        insert tournament;
        
        PlayerTournament__c playerTournament = new PlayerTournament__c(
            Player__c = player.Id,
            Tournament__c = tournament.Id
        );
        insert playerTournament;
        
        playerController.player = player;
        playerController.getPlayerTournaments();
        //System.assertEquals(playerController.currentTournamentsOfPlayer.size(),playerController.getCurrentTournamentsOptions().size());
        System.assertEquals(playerController.currentTournamentsOfPlayer.size(),1);
        
        //////////////////////////////////////////////////////////////////////////////////////
        tournament = new Tournament__c(
            Name = 'Some team tournament',
            Status__c = 'Current',
            Format__c = '2 x 2',
            Type__c = 'Round Robin',
            StartDate__c = DateTime.now()
        );
        
        insert tournament;
        
        Player__c teamMate = new Player__c(
            Name = 'Some name1',
            Email__c = 'email1@gmail.com',
            Password__c = 'password1'
        ); 
        
        insert teamMate;
        
        Team__c team = new Team__c(
            Name = 'player1_player2',
            Tournament__c = tournament.Id,
            IsComplete__c = true
        );
        
        insert team;
        
        PlayerTeam__c playerTeam = new PlayerTeam__c(
            Player__c = player.Id,
            Team__C = team.Id
        );
        
        insert playerTeam;
        
        playerTeam = new PlayerTeam__c(
            Player__c = teamMate.Id,
            Team__C = team.Id
        );
        
        insert playerTeam;
        
        playerController = new PlayerController();
        playerController.player = player;
        playerController.getPlayerTournaments();
        System.assertEquals(playerController.currentTournamentsOfPlayer.size(),2);
    }
    
    
    public static testMethod void testUntestedProps(){
        PlayerController playerController = new PlayerController();
        playerController.registrationPage = false;
        playerController.sendEmail();
        playerController.codesOfException.add('aaa');
        playerController.sendEmail();
        playerController.logout();
    }
    
    public static testMethod void uploadNewImageTest(){
        PlayerController playerController = new PlayerController();
        Player__c player = new Player__c();
        player.Name = 'Some name';
        player.Email__c = 'email@gmail.com';
        player.Password__c = '12345678';
        insert player;
        
        playerController.player = player;
        playerController.document = new Document();
        playerController.document.Name = 'image.png';
        System.assertNotEquals(playerController.uploadNewImage(),null);
    }
    
    public static testMethod void statisticsTest(){
        
        Player__c player = new Player__c();
        player.Name = 'Some name';
        player.Email__c = 'email@gmail.com';
        player.Password__c = '12345678';
        insert player;

        
        Tournament__c tournamentCurrent = new Tournament__c(
            Name = 'Some team tournament',
            Status__c = 'Upcoming',
            Format__c = '1 x 1',
            Type__c = 'Round Robin',
            StartDate__c = DateTime.now()
        );
        
        insert tournamentCurrent;
        
        Tournament__c tournamentCompleted = new Tournament__c(
            Name = 'Some tournament',
            Status__c = 'Upcoming',
            Format__c = '1 x 1',
            Type__c = 'Round Robin',
            StartDate__c = DateTime.now()
        );
        
        insert tournamentCompleted;
        PlayerTournament__c playerTournament = new PlayerTournament__c(Player__c = player.Id, Tournament__c = tournamentCurrent.Id);
        PlayerTournament__c playerTournamentNew = new PlayerTournament__c(Player__c = player.Id, Tournament__c = tournamentCompleted.Id);
        
        tournamentCurrent.Status__c = 'Current';
        tournamentCompleted.Status__c = 'Current';
        
        update tournamentCurrent;
        update tournamentCompleted;
        
        tournamentCompleted.Status__c = 'Completed';
        update tournamentCompleted;
        
        PlayerStatistics__c ps = new PlayerStatistics__c(Player__c = player.Id, Tournament__c = tournamentCurrent.Id,CountLostSets__c = 0, CountWonSets__c = 0);
        PlayerStatistics__c ps1 = new PlayerStatistics__c(Player__c = player.Id, Tournament__c = tournamentCompleted.Id, CountLostSets__c = 0, CountWonSets__c = 0);
        insert ps; 
        insert ps1;
        
        
        PlayerController playerController = new PlayerController();
        playerController.player = player;
        playerController.countWonGames = 0;
        playerController.countLostGames = 0;
        playerController.countWonSets = 0;
        playerController.countLostSets = 0;
        playerController.getPlayerStatisticsList();
        System.assertEquals(2,playerController.playerStatisticList.size());
        
        
        playerController.currentOrCompletedTournamentId = tournamentCompleted.Id;
        playerController.getCurrentOrCompletedTournament();
        
        playerController.currentOrCompletedTournamentId = null;
        playerController.getCurrentOrCompletedTournament();
        
        playerController.imageUrl = '';
        playerController.confirmRegistration();
        
        playerController.getPlayerTournaments();
        playerController.getCompletedAndCurrentTournamentsOfPlayerOptions();
        
        Test.setCurrentPageReference(new PageReference('Page.Player')); 
        System.currentPageReference().getParameters().put('pageType', 'login');
        playerController = new PlayerController();
        System.currentPageReference().getParameters().put('pageType', 'registration');
        playerController = new PlayerController();
        Test.setCurrentPageReference(new PageReference('Page.Player'));
        System.currentPageReference().getParameters().put('playerId', player.Id);
        playerController = new PlayerController();
    }
}