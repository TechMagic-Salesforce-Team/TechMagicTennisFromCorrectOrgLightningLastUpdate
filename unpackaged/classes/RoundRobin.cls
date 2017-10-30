public with sharing class RoundRobin{
    public Tournament__c tournament{get;set;}
    public Boolean lightningSync {get;set;}
    public Id playerIdLightning {get;set;}
    public String lightningPageName {get;set;}
        public List<List<GameJSON>> roundRobinMatrix{
        get{
            if(roundRobinMatrix == null) return RoundRobinGrid(tournament);
            return roundRobinMatrix;
        }
        set;
    }
    public RoundRobin(){}
   
    
    
    public static void RoundRobinTournament(Tournament__c myTournament,List<String> allIds){        
        List<Game__c> currentTournamentGames = new List<Game__c>();
        for(Integer round=0; round<allIds.size();round++){
            for(Integer match=round+1;match<allIds.size();match++){
                    Game__c currentGame = new Game__c();
                    currentGame.FirstCompetitor__c = allIds.get(round); 
                    currentGame.SecondCompetitor__c = allIds.get(match);
                    currentGame.Tournament__c = myTournament.Id;
                    currentTournamentGames.add(currentGame);    
            }
        } 
        insert currentTournamentGames;
    }
     public List<List<GameJSON>> RoundRobinGrid(Tournament__c myTournament) {
        System.debug('RR Grid');
        Integer count = 0;
        Player__c currentPlayer = null;
        Boolean isLoggedIn = null;
         try {
             isLoggedIn = getPlayerByPage() != null;
             if (!lightningSync) {
                 if (isLoggedIn) {
                     Id playerId = getPlayerByPage();
                     currentPlayer =
                     [select Id,Name,Email__c,Password__c,IsManager__c from Player__c where Id = :playerId];
                     System.debug('current player: ' + currentPlayer);
                 }
             } else {
                 currentPlayer = [select Id,Name,Email__c,Password__c,IsManager__c from Player__c where Id = :playerIdLightning];
                 System.debug('Current player lightning: '+currentPlayer);
             }
         }catch (Exception ex) {

         }
        
        List<Game__c> games = [Select id,firstCompetitor__c,secondCompetitor__c,SecondCompetitorAccept__c,FirstCompetitorAccept__c ,SecondCompetitorScore__c,FirstCompetitorScore__c,Stage__c,Tournament__c
                               from Game__c 
                               where Tournament__c =: myTournament.id];
        //from id competitor gets name of competitor
        Map<String, String> idNameMap = Helper.getIdAndNameMap(myTournament);
        System.debug(idNameMap);
        List<List<GameJSON>> result = new List<List<GameJSON>>();
        List<String> Ids = new List<String>(idNameMap.keySet());
        System.debug(Ids.size()+'size');
        List<GameJSON> firstRow = new List<GameJSON>();
        firstRow.add(new GameJSON('','black','',''));
        Map<Id,Team__c> teams = new Map<Id,Team__c>([select Id,Name,(select Player__c from PlayerTeams__r) from Team__c where Tournament__c=:myTournament.Id]);
        Map<Id,Player__c> players = new Map<Id,Player__c>([select Id,Name from Player__c]);
        Id idPlayerOrTeamThatRelatedToPlayerFromCookie;
         if (lightningPageName==null) lightningPageName = 'Home';
         if (lightningPageName.equals('Tournament')){
             lightningPageName+='?tournamentId='+myTournament.Id;
         }
        if (isLoggedIn != null && isLoggedIn) {
           if (myTournament.Format__c == '1 x 1'){
             System.debug('1x1...');
             idPlayerOrTeamThatRelatedToPlayerFromCookie = currentPlayer.Id;
           } else {
               List<PlayerTeam__c> playerTeams = [select Player__c,Team__c from PlayerTeam__c where Player__c=:currentPlayer.Id and Team__c in (select Id from Team__c where Tournament__c=:myTournament.Id)];        
               if (playerTeams.size()>0) idPlayerOrTeamThatRelatedToPlayerFromCookie = playerTeams.get(0).Team__c;
           }     
        } 
        for (String id : Ids) {
            GameJSON gamejs = new GameJSON('','FFFFFF',idNameMap.get(id),'');
            gamejs.idGameJSONUnique = 'id_'+count;
            gamejs.playerId = id;
            if (myTournament.Format__c!='1 x 1'){
                gamejs.player1OfTeam = players.get(teams.get(id).PlayerTeams__r.get(0).Player__c).Name;
                gamejs.player2OfTeam = players.get(teams.get(id).PlayerTeams__r.get(1).Player__c).Name;
            }
            if (isLoggedIn != null && isLoggedIn && id==idPlayerOrTeamThatRelatedToPlayerFromCookie){
                gamejs.fontColor = '#FF69B4';
            } else gamejs.fontColor = 'black';
            firstRow.add(gamejs);
            count++;
        }
        
        //System.debug('idPlayerOrTeamThatRelatedToPlayerFromCookie '+idPlayerOrTeamThatRelatedToPlayerFromCookie+',currentplayer: '+currentPlayer.Id);
        result.add(firstRow);
        for (Integer i = 0; i < Ids.size(); i++) {       
                   List<GameJSON> row = new List<GameJSON>();
                   GameJSON gamejs = new GameJSON('','FFFFFF',idNameMap.get(Ids[i]),'');
                   gamejs.idGameJSONUnique = 'id_'+count;
                   gamejs.playerId = Ids[i];
                   if (myTournament.Format__c!='1 x 1'){
                        gamejs.playerId = Ids[i];
                        gamejs.player1OfTeam = players.get(teams.get(Ids[i]).PlayerTeams__r.get(0).Player__c).Name;
                        gamejs.player2OfTeam = players.get(teams.get(Ids[i]).PlayerTeams__r.get(1).Player__c).Name;
                   }
                   
                   if (isLoggedIn!=null && isLoggedIn && Ids[i]==idPlayerOrTeamThatRelatedToPlayerFromCookie){
                    gamejs.fontColor = '#FF69B4';
                   } else gamejs.fontColor = 'black';
                   row.add(gamejs);
                   for (Integer j = 0; j < Ids.size(); j++) {
         if (i == j) {
                           row.add(new GameJSON('','black','',''));
          } else {
           for (Game__c g : games) {
                                           if (g.firstCompetitor__c == Ids[i] && g.secondCompetitor__c == Ids[j]) {
            if (g.SecondCompetitorAccept__c && g.FirstCompetitorAccept__c) {
                                                 Integer firstCompetitorScore = (Integer)g.FirstCompetitorScore__c;
                                                 Integer secondCompetitorScore = (Integer)g.SecondCompetitorScore__c;
                                                 //String color = firstCompetitorScore>secondCompetitorScore?'green':'red';
                                                 String color = 'lightgrey';
                                                 gamejs = new GameJSON(g.Id,color,'',''+g.FirstCompetitorScore__c);
                                                 gamejs.editable = g.FirstCompetitor__c==idPlayerOrTeamThatRelatedToPlayerFromCookie||g.SecondCompetitor__c==idPlayerOrTeamThatRelatedToPlayerFromCookie;
                                                 gamejs.hrefTo = gamejs.editable ? 'game?id='+gamejs.gameId+'&redirectUrl='+lightningPageName:'#myTable';
                                                 row.add(gamejs);
                                            } else {
                                                 gamejs = new GameJSON(''+g.Id,'lightgrey','','0');
                                                 gamejs.editable = g.FirstCompetitor__c==idPlayerOrTeamThatRelatedToPlayerFromCookie||g.SecondCompetitor__c==idPlayerOrTeamThatRelatedToPlayerFromCookie;
                                                 gamejs.hrefTo = gamejs.editable ? 'game?id='+gamejs.gameId+'&redirectUrl='+lightningPageName:'#myTable';
                                                 row.add(gamejs);
                                           }
                                        }
                                           if (g.firstCompetitor__c == Ids[j] && g.secondCompetitor__c == Ids[i]) {
                                                if (g.SecondCompetitorAccept__c && g.FirstCompetitorAccept__c) {
                                                   Integer firstCompetitorScore = (Integer)g.FirstCompetitorScore__c;
                                                   Integer secondCompetitorScore = (Integer)g.SecondCompetitorScore__c;
                                                   //String color = secondCompetitorScore>firstCompetitorScore?'green':'red'; 
                                                   String color = 'lightgrey';
                                                   gamejs = new GameJSON(g.Id,color,'',''+g.SecondCompetitorScore__c);
                                                   gamejs.editable = g.FirstCompetitor__c==idPlayerOrTeamThatRelatedToPlayerFromCookie||g.SecondCompetitor__c==idPlayerOrTeamThatRelatedToPlayerFromCookie;
                                                   gamejs.hrefTo = gamejs.editable ? 'game?id='+gamejs.gameId+'&redirectUrl='+lightningPageName : '#myTable';
                                                   row.add(gamejs);
                                               } else {
                                                   gamejs = new GameJSON(g.Id,'lightgrey','','0');
                                                   gamejs.editable = g.FirstCompetitor__c==idPlayerOrTeamThatRelatedToPlayerFromCookie||g.SecondCompetitor__c==idPlayerOrTeamThatRelatedToPlayerFromCookie;
                                                   gamejs.hrefTo = gamejs.editable ? 'game?id='+gamejs.gameId+'&redirectUrl='+lightningPageName : '#myTable';
                                                   row.add(gamejs);
                                               }
                                           } 
                                       }
                                 } 
                         }
                  result.add(row);
                  count++;
               }

               return result;
           }

    public Id getPlayerByPage(){
        if (!lightningSync) {
            if (ApexPages.currentPage().getCookies().get('PlayerFromCookie') != null)
                return ApexPages.currentPage().getCookies().get('PlayerFromCookie').getValue();
            else return null;
        } else {
            return playerIdLightning;
        }
    }
    
}