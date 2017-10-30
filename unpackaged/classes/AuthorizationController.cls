public class AuthorizationController {
    
    Public Player__c currentPlayer{
        get{
            if(currentPlayer == null) currentPlayer = new Player__c();   
            currentPlayer = getCurrentPlayer();
            return currentPlayer;
        }set;
    }
    
    public AuthorizationController(){
        
    }
    
    public Player__c getCurrentPlayer(){
        if(ApexPages.currentPage().getCookies().get('PlayerSession').getValue() !=null) 
        return [Select Id, Name, Email__c, IsManager__c From Player__c Where Id = :ApexPages.currentPage().getCookies().get('PlayerSession').getValue()];
        return new Player__c();
    }
    
    
    public PageReference loginUser(){
        List<Player__c> selectPlayer = [Select Status__c, Password__c from Player__c where Id = :currentPlayer.Id Limit 1];
        if(selectPlayer.size() > 0){
            if(selectPlayer.get(0).Status__c == 'active'){
                if(selectPlayer.get(0).Password__c != null && selectPlayer.get(0).Password__c == currentPlayer.Password__c){
                    Cookie ps = new Cookie('PlayerSession', currentPlayer.Id, null, 10000, false); //ps = player session
                    ApexPages.currentPage().setCookies(new Cookie[]{ps});
                    PageReference acctPage = new PageReference('/apex/Home');
                    acctPage.setRedirect(true);
                    return acctPage ;
                }else{ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Incorrect password'));
                      return null;}
            }else{ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'To begin with you must activate your account'));
                  return null;}
        }else {ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Incorect Email'));
               return null;}
    }
    
    public void logout(){
        
    }
    
}