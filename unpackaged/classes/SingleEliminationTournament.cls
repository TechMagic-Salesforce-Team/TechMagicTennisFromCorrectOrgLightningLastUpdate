public with sharing class SingleEliminationTournament implements ISingleEliminationTournament{
    public Integer ijz{get{return 1;}set;}
    public Tournament__c oneTournament{get;set;}
    public Boolean lightningSync {get;set;}
    public Id playerIdLightning {get;set;}
    public String lightningPageName {get;set;}
    public Map<String, String> competitorsName{
        get{
            if(oneTournament !=null && oneTournament.Type__c !=null && oneTournament.Type__c=='Single Elimination'){
                if(competitorsName == null){
                    Map<String, String> localCompetitorsName = Helper.getIdAndNameMap(oneTournament);
                    localCompetitorsName.put('?','?');
                    return localCompetitorsName;
                }
                return competitorsName;
            }else{return new Map<String, String>();}
        }
        set;
    }
    
    public GameJSON selectedGameJSON {get;set;}
    public String gameJsonId{
        get{
            if (gameJsonId == null) gameJsonId = '';
            return gameJsonId;
        }
        set;
    }
    
    public Map<Id,Team__c> teams {get;set;}


    public List<List<GameJSON>> representSingleEliminationGrid{
        get{
            if(representSingleEliminationGrid == null && oneTournament !=null){
                SYSTEM.debug('REPRESENT'+oneTournament);
                return generateSingleEliminationStageGrid(oneTournament);
            }
            if(representSingleEliminationGrid == null && oneTournament ==null) {
                SYSTEM.debug('NULL,NULL');
                return new List<List<GameJSON>>();
            }
            SYSTEM.DEBUG('END OF REPRESENT');
            return representSingleEliminationGrid;
        }
        set;
    }
    public Integer countOfStageOneTournament{
        get{
            if(representSingleEliminationGrid !=null && representSingleEliminationGrid.size() == 2)countOfStageOneTournament = 2;
            else if(representSingleEliminationGrid !=null &&  representSingleEliminationGrid.size()<=1){countOfStageOneTournament = 3;}
            else{countOfStageOneTournament = 1;}
            return countOfStageOneTournament;
        }
        set;
    }

    public SingleEliminationTournament(){
        lightningSync = false;
    }

    public static void StartSingleEliminationTournament(List<String> CompetitorsIds, Tournament__c currentTournament){
        if(currentTournament !=null && currentTournament.Type__c !=null && currentTournament.Type__c == 'Single Elimination' && currentTournament.Format__c !=null){
            if(CompetitorsIds.size()<=1){
                TournamentController.finish(currentTournament);
                return;
            }
            
            if(CompetitorsIds.size() == 2){
                try{insert new Game__c(FirstCompetitor__c= CompetitorsIds.get(0),SecondCompetitor__c = CompetitorsIds.get(1),FirstCompetitorScore__c = 0,
                                                  SecondCompetitorScore__c = 0, Tournament__c = currentTournament.Id, Stage__c = 1, Type__c = 'Final');}
                catch(DMLException e){}
                return;            
            }
            Integer i = 0;
            Integer countStages = 0;
            for(Integer j = 1; j<=CompetitorsIds.size(); j *=2){
                i = j;
                countStages++;
            }
            Integer z;
            if(i == CompetitorsIds.size()){z = 0;}
            else{z = 2*i-CompetitorsIds.size();}
            Integer round=0;
            List<Game__c> thisGames = new List<Game__c>();
            for(; round<CompetitorsIds.size()-z;round +=2){
                Integer match=round+1;
                Game__c currentGame = new Game__c(FirstCompetitor__c= CompetitorsIds.get(round),SecondCompetitor__c = CompetitorsIds.get(match),FirstCompetitorScore__c = 0,
                                                  SecondCompetitorScore__c = 0, Tournament__c = currentTournament.Id, Stage__c = 1);
                thisGames.add(CurrentGame);
            }
            if(i == CompetitorsIds.size()){
                for(Integer stages = 2; stages<countStages;stages++){
                    for(Integer gamesPerRound = 1; gamesPerRound <= i/4;gamesPerRound++){
                        if(i != 4)thisGames.add(new Game__c(FirstCompetitor__c = '?', SecondCompetitor__c = '?', FirstCompetitorScore__c  = 0, SecondCompetitorScore__c = 0, 
                                                  Stage__c = stages, Tournament__c = currentTournament.Id));
                        
                        if(i == 4){
                            thisGames.add(new Game__c(FirstCompetitor__c = '?', SecondCompetitor__c = '?', FirstCompetitorScore__c  = 0, SecondCompetitorScore__c = 0, 
                                                      Stage__c = stages, Tournament__c = currentTournament.Id, Type__c = 'Final'));
                            thisGames.add(new Game__c(FirstCompetitor__c = '?', SecondCompetitor__c = '?', FirstCompetitorScore__c  = 0, SecondCompetitorScore__c = 0, 
                                                      Stage__c = stages, Tournament__c = currentTournament.Id, WinningGroup__c = false, Type__c = 'Final'));
                        }
                    }
                    i /=2;
                }
            }
            else if (i != CompetitorsIds.size()){
                if(CompetitorsIds.size()==3){
                thisGames.add(new Game__c(FirstCompetitor__c= CompetitorsIds.get(2) ,SecondCompetitor__c = '?',FirstCompetitorScore__c = 0,
                                                  SecondCompetitorScore__c = 0, Tournament__c = currentTournament.Id, Stage__c = 2, Type__c = 'Final'));
                }
                else if(CompetitorsIds.size()>4){
                    String currentTournamentId = currentTournament.Id;
                    for(Integer stages = 2; stages<=countStages; stages++){
                        for(Integer gamesPerRound = 1; gamesPerRound <=i/2; gamesPerRound++){
                            Game__c currentGame = new Game__c(FirstCompetitor__c = '?', SecondCompetitor__c = '?', FirstCompetitorScore__c  = 0, SecondCompetitorScore__c = 0, 
                                                      Stage__c = stages, Tournament__c = currentTournamentId);
                            if(stages == countStages) currentGame.Type__c = 'Final';
                            if(round < CompetitorsIds.size()){
                                currentGame.FirstCompetitor__c = CompetitorsIds.get(round);
                                if(round + 1 < CompetitorsIds.size()){
                                    currentGame.SecondCompetitor__c = CompetitorsIds.get(round+1);
                                }                            
                                round+=2;
                            }
                            thisGames.add(currentGame);
                           
                        }
                        i /=2;
                    }
                    Game__c currentGameThirdPlace = new Game__c(FirstCompetitor__c = '?', SecondCompetitor__c = '?', FirstCompetitorScore__c  = 0, SecondCompetitorScore__c = 0, 
                                                                Stage__c = countStages, Tournament__c = currentTournamentId, WinningGroup__c = false, Type__c = 'Final');
                    thisGames.add(currentGameThirdPlace);
                }
            }          
            try{insert thisGames;}
            catch(DMLException e){}
        }    
    }
    
    public static void createNextSingleEliminationStage(List<Game__c> gamesByPreviousRound, Tournament__c currentTournament){
        if(currentTournament!=null && gamesByPreviousRound !=null && !gamesByPreviousRound.isEmpty()){
            Decimal thisRoundStage = gamesByPreviousRound.get(0).Stage__c;
            thisRoundStage++;
            List<Game__c> gamesByThisStage = new List<Game__c>();
            gamesByThisStage = [Select Name, WinningGroup__c, FirstCompetitor__c, SecondCompetitor__c, 
                                FirstCompetitorScore__c, SecondCompetitorScore__c, Stage__c, Tournament__c  
                                From Game__c Where Stage__c = :thisRoundStage AND Tournament__c = :currentTournament.Id];
            if(!gamesByPreviousRound.isEmpty() && !gamesByThisStage.isEmpty()){
               List<String> winnerCompetitors = new List<String>();
               List<String> loserCompetitors = new List<String>();
               if(gamesByPreviousRound.size() == 1){
                    if(gamesByPreviousRound.get(0).FirstCompetitorScore__c > gamesByPreviousRound.get(0).SecondCompetitorScore__c){winnerCompetitors.add(gamesByPreviousRound.get(0).FirstCompetitor__c);}
                    else{winnerCompetitors.add(gamesByPreviousRound.get(0).SecondCompetitor__c);}
                    Game__c myUpdateGame = new Game__c();
                    for(Game__c x :gamesByThisStage){
                        if(x.SecondCompetitor__c == '?'){
                            x.SecondCompetitor__c = winnerCompetitors.get(0);
                            myUpdateGame = x;
                        }
                    }
                    try{update myUpdateGame;}
                    catch(DMLException e){}
                    return;
               }
               List<Game__c> thisGames = new List<Game__c>();
               Boolean isFinal = false;
               for(Game__c x : gamesByThisStage){
                   if(x.WinningGroup__c == false) isFinal = true;
               }
               if(gamesByPreviousRound.size() == 2 && gamesByThisStage.size() == 2 && isFinal){
                    for(Game__c g : gamesByPreviousRound){
                        if(g.FirstCompetitorScore__c > gamesByPreviousRound.get(0).SecondCompetitorScore__c){
                            winnerCompetitors.add(g.FirstCompetitor__c);
                            loserCompetitors.add(g.SecondCompetitor__c);
                        }
                        else{
                            winnerCompetitors.add(g.SecondCompetitor__c);
                            loserCompetitors.add(g.FirstCompetitor__c);
                        }
                    }
                    if(gamesByThisStage.get(0).WinningGroup__c){
                        gamesByThisStage.get(0).FirstCompetitor__c = winnerCompetitors.get(0);
                        gamesByThisStage.get(0).SecondCompetitor__c = winnerCompetitors.get(1);                        
                        gamesByThisStage.get(1).FirstCompetitor__c = loserCompetitors.get(0);
                        gamesByThisStage.get(1).SecondCompetitor__c = loserCompetitors.get(1);
                    
                        thisGames.add(gamesByThisStage.get(0));
                        thisGames.add(gamesByThisStage.get(1));
                       
                    }else{
                        gamesByThisStage.get(1).FirstCompetitor__c = winnerCompetitors.get(0);
                        gamesByThisStage.get(1).SecondCompetitor__c = winnerCompetitors.get(1);                        
                        gamesByThisStage.get(0).FirstCompetitor__c = loserCompetitors.get(0);
                        gamesByThisStage.get(0).SecondCompetitor__c = loserCompetitors.get(1);
                    
                        thisGames.add(gamesByThisStage.get(0));
                        thisGames.add(gamesByThisStage.get(1));
                    }
                    
                    try{update thisGames;}
                    catch(DMLException e){}
                    return;
               }
               if(gamesByPreviousRound.size() >= 2 && gamesByThisStage.size() >= 2 && !isFinal){
                    for(Game__c g : gamesByPreviousRound){
                        if(g.FirstCompetitorScore__c > g.SecondCompetitorScore__c){winnerCompetitors.add(g.FirstCompetitor__c);}
                        else{winnerCompetitors.add(g.SecondCompetitor__c);}
                    }
               }
               Integer competitorCount = 0;
               for(Game__c x : gamesByThisStage){
                    if(x.FirstCompetitor__c == '?'){
                        x.FirstCompetitor__c = winnerCompetitors.get(competitorCount);
                        competitorCount++;
                    }
                    if(x.SecondCompetitor__c == '?'){
                        x.SecondCompetitor__c = winnerCompetitors.get(competitorCount);
                        competitorCount++; 
                    }
                    thisGames.add(x);
               }
               try{update thisGames;}
               catch(DMLException e){throw e;}
            } 
        }else{}
    }
    
    public List<List<GameJSON>> generateSingleEliminationStageGrid(Tournament__c currentTournament){
        System.debug('SET');
        teams = new Map<Id,Team__c>();
        Map<Id, Player__c> players = new Map<Id, Player__c>();
        if(currentTournament != null && currentTournament.Type__c =='Single Elimination'){
            //List<List<Game__c>> thisGames = new List<List<Game__c>>();
            List<List<GameJSON>> gameJSONList = new List<List<GameJSON>>();
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

//            if (ApexPages.currentPage().getCookies().get('PlayerFromCookie')!=null){
//                Id playerId = ApexPages.currentPage().getCookies().get('PlayerFromCookie').getValue();
//                currentPlayer = currentPlayer = [select Id,Name,Email__c,Password__c,IsManager__c from Player__c where Id = :playerId];
//            }
            System.debug('is logged in: '+isLoggedIn+',current player'+currentPlayer);
            String playerOrTeamRelatedToPlayerFromCookie = null;
            Map<Id,Sobject> teamsOrPlayers = null;
            if (!String.isBlank(lightningPageName) && lightningPageName.equals('Tournament')){
                lightningPageName+='?id='+currentTournament.Id;
            }
            if (currentTournament.Format__c=='1 x 1'){
                teamsOrPlayers = new Map<Id,Player__c>([select Id,Name from Player__c]);
                if (currentPlayer!=null) playerOrTeamRelatedToPlayerFromCookie = currentPlayer.Id;
            } else {
                teamsOrPlayers = new Map<Id,Team__c>([select Id,Name, (select Player__c,Player__r.Name from PlayerTeams__r) from Team__c where Tournament__c =: currentTournament.Id]);
                if (currentPlayer!=null){
                    for (Team__c team: (List<Team__c>)teamsOrPlayers.Values()){
                        playerOrTeamRelatedToPlayerFromCookie = 
                            team.PlayerTeams__r.get(0).Player__c==currentPlayer.Id || team.PlayerTeams__r.get(1).Player__c == currentPlayer.Id?team.Id:null;
                        if (playerOrTeamRelatedToPlayerFromCookie!=null) break;
                    }
                }
            }
            
            List<Game__c>gamesForCurrentTournament = [Select Name, WinningGroup__c, FirstCompetitor__c, SecondCompetitor__c, FirstCompetitorScore__c, 
                    SecondCompetitorScore__c, Stage__c, Tournament__c, Type__c 
                    From Game__c Where Tournament__c = :currentTournament.Id Order By Stage__c];
            
            if (currentTournament.Format__c=='2 x 2'){
                teams = (Map<Id,Team__c>) teamsOrPlayers;
            } else {
                players = (Map<Id, Player__c>) teamsOrPlayers;
            }
            if(gamesForCurrentTournament !=null && !gamesForCurrentTournament.isEmpty()){
                for(Integer j = 1; j<=gamesForCurrentTournament.get(gamesForCurrentTournament.size()-1).Stage__c.intValue();j++){
                    List<GameJSON> gameJson = new List<GameJSON>();
                    for(Game__c x : gamesForCurrentTournament){
                        if(j == x.Stage__c.intValue()){
                            //stageLists.add(x);
                            GameJSON gamejs = new GameJSON();
                            gamejs.gameId = x.Id; gamejs.firstCompetitorId = x.FirstCompetitor__c; gamejs.secondCompetitorId = x.SecondCompetitor__c;
                            gamejs.firstCompetitorScore = ''+x.FirstCompetitorScore__c; gamejs.secondCompetitorScore = ''+x.SecondCompetitorScore__c;
                            gamejs.gameType = x.Type__c;
                            gamejs.stage = x.Stage__c.intValue();
                            gamejs.winningGroup = x.WinningGroup__c;
                            gamejs.firstCompetitorColor = x.FirstCompetitor__c==playerOrTeamRelatedToPlayerFromCookie?'#FF69B4':'black';
                            gamejs.secondCompetitorColor = x.SecondCompetitor__c==playerOrTeamRelatedToPlayerFromCookie?'#FF69B4':'black';
                            gamejs.editable = 
                                gamejs.firstCompetitorId==playerOrTeamRelatedToPlayerFromCookie || gamejs.secondCompetitorId==playerOrTeamRelatedToPlayerFromCookie;    
                            if (gamejs.editable) gamejs.hrefTo = 'Game?id='+gamejs.gameId+'&redirectUrl='+lightningPageName;
                            else gamejs.hrefTo = '#table1';
                            
                            if (currentTournament.Format__c=='2 x 2'){
                                gamejs.player1OfTeam = gamejs.firstCompetitorId!='?'?teams.get(gamejs.firstCompetitorId).PlayerTeams__r.get(0).Player__r.Name:'?';
                                gamejs.player2OfTeam = gamejs.firstCompetitorId!='?'?teams.get(gamejs.firstCompetitorId).PlayerTeams__r.get(1).Player__r.Name:'?';
                                gamejs.player1OfTeam2 = gamejs.secondCompetitorId!='?'?teams.get(gamejs.secondCompetitorId).PlayerTeams__r.get(0).Player__r.Name:'?';
                                gamejs.player2OfTeam2 = gamejs.secondCompetitorId!='?'?teams.get(gamejs.secondCompetitorId).PlayerTeams__r.get(1).Player__r.Name:'?';
                                if (currentPlayer!=null){
                                    gamejs.player1OfTeamColor = gamejs.firstCompetitorId!='?'?teams.get(gamejs.firstCompetitorId).PlayerTeams__r.get(0).Player__c==currentPlayer.Id?'#FF69B4':'black':'black';
                                    gamejs.player2OfTeamColor = gamejs.firstCompetitorId!='?'?teams.get(gamejs.firstCompetitorId).PlayerTeams__r.get(1).Player__c==currentPlayer.Id?'#FF69B4':'black':'black';
                                    gamejs.player1OfTeam2Color = gamejs.secondCompetitorId!='?'?teams.get(gamejs.secondCompetitorId).PlayerTeams__r.get(0).Player__c==currentPlayer.Id?'#FF69B4':'black':'black';
                                    gamejs.player2OfTeam2Color = gamejs.secondCompetitorId!='?'?teams.get(gamejs.secondCompetitorId).PlayerTeams__r.get(1).Player__c==currentPlayer.Id?'#FF69B4':'black':'black';
                                } else {
                                    gamejs.player1OfTeamColor = gamejs.player2OfTeamColor = gamejs.player1OfTeam2Color = gamejs.player2OfTeam2Color = 'black';
                                }
                            } else {
                                gamejs.firstCompetitorName = gamejs.firstCompetitorId != '?' ? players.get(gamejs.firstCompetitorId).Name : '?';
                                gamejs.secondCompetitorName = gamejs.secondCompetitorId != '?' ?  players.get(gamejs.secondCompetitorId).Name : '?';
                            }
                            
                            gameJson.add(gamejs);
                        }
                    }
                    gameJSONList.add(gameJson);
                }
            }else{return new List<List<GameJSON>>();}
            return gameJSONList;
        }else{
            competitorsName = new Map<String, String>();
            return new List<List<GameJSON>>();
        }    
    }
    
    public void changeSelectedGameJSON(){
        Boolean exitCycle = false;
        for (List<GameJSON> gameJsons: representSingleEliminationGrid){
            for (GameJSON g: gameJsons){
                if (g.gameId==gameJsonId){
                    selectedGameJson = g;
                    exitCycle = true;
                }
                if (exitCycle) break;
            }
        }
        system.debug('selected game json: '+selectedGameJSON);
    }

    public Id getPlayerByPage(){
        if (!lightningSync) {
            System.debug('false');
            if (ApexPages.currentPage().getCookies().get('PlayerFromCookie') != null)
                return ApexPages.currentPage().getCookies().get('PlayerFromCookie').getValue();
            else return null;
        } else {
            return playerIdLightning;
        }
    }

}