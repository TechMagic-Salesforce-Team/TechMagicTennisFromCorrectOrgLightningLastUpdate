public with sharing abstract class PlayerCookie {
    public Player__c currentPlayer {get;set;}
    public Boolean isLoggedIn {get;set;}
    public Boolean isManager{get;set;}
    public static String playerCookieId = '';
    
    
    public PlayerCookie(){
       try {
           isLoggedIn = ApexPages.currentPage().getCookies().get('PlayerFromCookie') != null;
           if (isLoggedIn) {
               Id playerId = ApexPages.currentPage().getCookies().get('PlayerFromCookie').getValue();
               currentPlayer = [select Id,Name,Email__c,Password__c,IsManager__c from Player__c where Id = :playerId];
               isManager = currentPlayer.isManager__c;
               playerCookieId = currentPlayer.Id;
           } else isManager = false;
       } catch (Exception ex) {
           isManager = false;
       }
    }
    
    public Player__c getCurrentPlayer(){
        if (ApexPages.currentPage().getCookies().get('PlayerFromCookie')!=null) {
            Id playerId = ApexPages.currentPage().getCookies().get('PlayerFromCookie').getValue();
            currentPlayer = [select Id,Name,Email__c,Password__c,IsManager__c from Player__c where Id = :playerId];
            playerCookieId = currentPlayer.Id;
            return currentPlayer;
        } else return new Player__c(); 
    }
}