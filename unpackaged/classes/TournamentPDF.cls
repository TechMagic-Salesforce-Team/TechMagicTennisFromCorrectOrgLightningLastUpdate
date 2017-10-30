public with sharing class TournamentPDF extends TournamentController{

    public Tournament__c pdfCurrentTournament{get;set;}
    private Map<String, String> competitorsMap{get;set;}
    public List<String> competitorsName{get;set;}
    public Map<String, String> teamNameLinkedToPlayer{
        get{
            if(pdfCurrentTournament!=null){
                if(teamNameLinkedToPlayer== null){
                    Map<String, String> localCompetitorsName = getIdAndNameMap(pdfCurrentTournament);
                    localCompetitorsName.put('?','?');
                    return localCompetitorsName;
                }
                return teamNameLinkedToPlayer;
            }else{return new Map<String, String>();}
        }
        set;
    }
    public String myURL{get;set;}
    public List<String> winnerOfThisTournamentId{
        get{
            if(winnerOfThisTournamentId == null && pdfCurrentTournament !=null && pdfCurrentTournament.Type__c == 'Single Elimination'){
              List<Game__c> thisListGame = new List<Game__c>();
              thisListGame = [Select Id,FirstCompetitor__c, SecondCompetitor__c, FirstCompetitorScore__c, SecondCompetitorScore__c, WinningGroup__c,Stage__c, Type__c From Game__c Where Tournament__c = :pdfCurrentTournament.Id Order By Stage__c DESC, WinningGroup__c DESC];
              //Set<Game__c> thisSetGame = new Set<Game__c>();
              //thisSetGame.addAll(thisListGame);
              List<String> localyWinnersList = new List<String>();
              if(thisListGame.size()>=1){
                  if(thisListGame.get(0).FirstCompetitorScore__c > thisListGame.get(0).SecondCompetitorScore__c){
                      localyWinnersList.add(thisListGame.get(0).FirstCompetitor__c);
                      localyWinnersList.add(thisListGame.get(0).SecondCompetitor__c);
                  }
                  else{
                      localyWinnersList.add(thisListGame.get(0).SecondCompetitor__c);
                      localyWinnersList.add(thisListGame.get(0).FirstCompetitor__c);
                  }
                  if(thisListGame.size() >=2){
                      if(thisListGame.get(1).FirstCompetitorScore__c > thisListGame.get(0).SecondCompetitorScore__c){
                          localyWinnersList.add(thisListGame.get(1).FirstCompetitor__c);
                      }
                      else{
                          localyWinnersList.add(thisListGame.get(1).SecondCompetitor__c);
                      }
                  }
              }
            return localyWinnersList;
            }
            if(winnerOfThisTournamentId == null && pdfCurrentTournament == null) return new List<String>();
            return winnerOfThisTournamentId;            
        }
        set;
    }
    public String goldId{
        get{
            if(winnerOfThisTournamentId.size() > 0){
                return winnerOfThisTournamentId.get(0);
            }return '?';
        }
        set;
    }
    public String silverId{
        get{
            if(winnerOfThisTournamentId.size() > 1){
                return winnerOfThisTournamentId.get(1);
            }return '?';
        }
        set;
    }
    public String bronzeId{
        get{
            if(winnerOfThisTournamentId.size() > 2){
                return winnerOfThisTournamentId.get(2);
            }return '?';
        }
        set;
    }
    public List<PlayerStatistics__c> playerStatistic{
        get{
            if(playerStatistic == null && pdfCurrentTournament !=null) return [Select CountLostGames__c, CountLostSets__c, CountWonGames__c, CountWonSets__c,Player__r.Id, Player__r.Name, Tournament__c From PlayerStatistics__c 
                                                                               Where Tournament__c = :pdfCurrentTournament.Id Order By CountWonGames__c DESC, CountWonSets__c DESC];
            if(playerStatistic == null && pdfCurrentTournament ==null) return new List<PlayerStatistics__c>();
            return playerStatistic;            
        }
        set;
    }
    
    public List<String> teamStatistic{
        get{
            if(teamStatistic == null && pdfCurrentTournament !=null) return new List<String>();
            if(teamStatistic == null && pdfCurrentTournament ==null) return new List<String>();
            return teamStatistic;            
        }
        set;
    }
    
    public TournamentPDF(){
        if(ApexPages.currentPage().getParameters().get('id') !=null){
            List<Tournament__c> correctTournamentId = new List<Tournament__c>();    
            correctTournamentId =  [SELECT ID,Name, Status__c, Format__c, Type__c, StartDate__c FROM Tournament__c WHERE ID = :ApexPages.currentPage().getParameters().get('id')];
            if(correctTournamentId !=null && correctTournamentId.size()>0) pdfCurrentTournament = correctTournamentId.get(0);
        }else{pdfCurrentTournament = new Tournament__c();}
        
        if(pdfCurrentTournament !=null && pdfCurrentTournament.Type__c !=null){
            if(pdfCurrentTournament.Status__c !='Completed'){
                if(competitorsName == null){ competitorsMap = Helper.getIdAndNameMap(pdfCurrentTournament);
                }else{competitorsMap = new Map<String, String>();}
                competitorsName = new List<String>();
                if(competitorsMap.size()>0){
                    for(String x : competitorsMap.values()){
                        if(x != '-' && x != '?') competitorsName.add(x);
                    }
                }
            } 
            else{
                competitorsName = new List<String>();
                competitorsName = getFinalResultForSingleEliminationTournament(pdfCurrentTournament);
            }
        }
        myURL = (''+URL.getSalesforceBaseUrl()).split('=')[1].split(']')[0];
    } 
    
    private List<String> getFinalResultForSingleEliminationTournament(Tournament__c currentTournament){
        if(currentTournament !=null && currentTournament.Type__c == 'Single Elimination' && currentTournament.Status__c == 'Completed'){
            List<Game__c> allGamesForCurrentTournament = [Select Id, FirstCompetitor__c, SecondCompetitor__c, Stage__c,FirstCompetitorScore__c, SecondCompetitorScore__c From Game__c Where Tournament__c = :currentTournament.Id ORDER BY Stage__c];
            Decimal maxStage = allGamesForCurrentTournament.get(allGamesForCurrentTournament.size()-1).Stage__c;
            List<Decimal> Stages = new List<Decimal>();
            for(Decimal stage = 1; stage == maxStage; stage++){
                Stages.add(stage);
            }
            List<String> finalCompetitorsResult = new List<String>();
            Map<String, String> finalCompetitorsMap = new Map<String, String>();
            if(pdfCurrentTournament.Format__c == '1 x 1'){
                List<PlayerStatistics__c> PlayerStatistic = new List<PlayerStatistics__c>();
                PlayerStatistic = [Select CountLostGames__c, CountLostSets__c, CountWonGames__c, CountWonSets__c, Player__r.Name, Tournament__c From PlayerStatistics__c Where Tournament__c = :pdfCurrentTournament.Id];
                for(PlayerStatistics__c x : PlayerStatistic){
                    if(x.Player__r.Name != '-' && x.Player__r.Name != '?') {finalCompetitorsResult.add('Player : ' + x.Player__r.Name + 
                                                                            ' - Won Games: ' + x.CountWonGames__c + ', Lost Games: ' + x.CountLostGames__c +
                                                                            ', Won Sets: ' + x.CountWonSets__c + ', Lost Sets: ' + x.CountLostSets__c);}
                }
            }
            
            else{
                List<PlayerStatistics__c> PlayerStatistic = new List<PlayerStatistics__c>();
                for(String x : finalCompetitorsMap.values()){
                    
                    if(x != '-' && x != '?'){
                        finalCompetitorsResult.add(x);
                    }
                }
            }
            return finalCompetitorsResult;    
        }else{return new List<String>();}
    }
    private Map<String, String> getIdAndNameMap(Tournament__c tournament){
        Map<String,String> result = new Map<String,String>();
        List<PlayerStatistics__c> playersFromTeam = [Select Player__r.Id From PlayerStatistics__c Where Tournament__c = :tournament.Id];
        List<Id> playerIds = new List<Id>();
        for(PlayerStatistics__c x : playersFromTeam){
            playerIds.add(x.Player__r.Id);
        }
        List<Team__c> teams = [Select Id, Name From Team__c Where Tournament__c =:tournament.id];
        List<Id> teamIds = new List<Id>();
        for(Team__c x : teams){
            teamIds .add(x.Id);
        }
        List<PlayerTeam__c> pt = [Select Player__r.Id, Team__r.Name, Id From PlayerTeam__c WHERE Player__c = :playerIds and Team__c = :teamIds];
        for(PlayerTeam__c x : pt){
            result.put(x.Player__r.Id, x.Team__r.Name);
        }
        for(Team__c x : teams){
            result.put(x.Id, x.Name);
        }
        return result;
    }
       
}