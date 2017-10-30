public with sharing class GeneralController {
    
    Public Player__c currentPlayer{
        get{
            if(currentPlayer == null) currentPlayer = new Player__c();   
            currentPlayer = getCurrentPlayer();
            return currentPlayer;
        }set;
    }
    
    public GeneralController(){
        
    }
    
    public Player__c getCurrentPlayer(){
        if(ApexPages.currentPage().getCookies().get('PlayerSession').getValue() !=null) 
        return [Select Id, Name, Email__c, IsManager__c From Player__c Where Id = :ApexPages.currentPage().getCookies().get('PlayerSession').getValue()];
        return new Player__c();
    }

}