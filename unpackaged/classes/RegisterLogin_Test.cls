@isTest
public with sharing class RegisterLogin_Test {
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
        if (!dmlSuccessful) {
            System.debug('All data is valid - inserted new player');
        }
        
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
}