public with sharing class Helper {
     
public static Map<String , String> getIdAndNameMap(Tournament__c tournament){
        Map<String,String> result = new Map<String,String>();
        if(tournament.Format__c == '1 x 1'){
            for(Player__c player: [Select Id,Name
                                   From Player__c  
                                   Where Id IN (Select Player__c 
                                                From PlayerTournament__c
                                                Where Tournament__c =:tournament.id)]){
                 result.put(player.id, player.name);
            }
        }else{
            for(Team__c team: [Select Id,Name
                               From Team__c  
                               Where Tournament__c =:tournament.id]){
                result.put(team.id, team.name);
            }
        }
        return result;
    }
}