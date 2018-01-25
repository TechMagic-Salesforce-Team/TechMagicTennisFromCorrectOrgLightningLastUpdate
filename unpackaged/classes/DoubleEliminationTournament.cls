public with sharing class DoubleEliminationTournament {

    public integer ijz {get {return 1;} set;}
    public Tournament__c oneTournament{get;set;}
    public Boolean lightningSync {get;set;}
    public Id playerIdLightning {get;set;}
    public String lightningPageName {get;set;}
    public List<List<GameJSON>> representDoubleEliminationGridJSON{get{
        if (representDoubleEliminationGridJSON==null && oneTournament!=null){
            System.debug('represent==null'+oneTournament);
            generateDoubleEliminationGrid(oneTournament);
        }
        return representDoubleEliminationGridJSON;
    }set;}

    public List<List<Game__c>> representDoubleEliminationGrid{
        get{
            if(representDoubleEliminationGrid == null) return generateDoubleEliminationGrid(oneTournament);
            return representDoubleEliminationGrid;
        }
        set;
    }

    public Map<Id,Team__c> teams {get;set;}


    public Map<String, String> competitorsName{
        get{
            if(oneTournament !=null && representDoubleEliminationGrid !=null && oneTournament.Type__c=='Double Elimination'){
                if(competitorsName== null) competitorsName = Helper.getIdAndNameMap(oneTournament);
                competitorsName.put('?', '?');
                return competitorsName;
            } else {
                competitorsName = new Map<String, String>();
                competitorsName.put('?', '?');
                return competitorsName;
            }
        }
        set;
    }


    public DoubleEliminationTournament(){
        lightningSync = false;
    }

    public List<List<Game__c>> generateDoubleEliminationGrid(Tournament__c currentTournament){
        System.debug('DET grid');
        representDoubleEliminationGridJSON = new List<List<GameJSON>>();
        if(currentTournament.id != null && currentTournament.Type__c !=null && currentTournament.Type__c =='Double Elimination'){
            System.debug('Current t: '+currentTournament);
            Decimal i = 0; //Stage count
            List<List<Game__c>> thisGames = new List<List<Game__c>>();

            List<Game__c>gamesForCurrentTournament = [Select Name, WinningGroup__c, FirstCompetitor__c, SecondCompetitor__c, FirstCompetitorScore__c,
                    SecondCompetitorScore__c, Stage__c, Tournament__c
                    From Game__c Where Tournament__C = :currentTournament.Id];
            Integer countCompetitors = gamesForCurrentTournament.size();
            for (Game__c g : gamesForCurrentTournament) {
                if (g.Stage__c > i) {
                    i = g.Stage__c;
                }
            }
            if(gamesForCurrentTournament != null){
                for(Integer j = 0; j <= i; j++){
                    List<Game__c> stageLists = new List<Game__c>();
                    for(Game__c x : gamesForCurrentTournament){
                        if(j !=null && j == x.Stage__c.intValue()){
                            stageLists.add(x);
                        }
                    }
                    thisGames.add(stageLists);
                }
            }


            Player__c currentPlayer = null;
            Boolean isLoggedIn = null;
			String playerOrTeamRelatedToPlayerFromCookie = null;


            try {
                isLoggedIn = getPlayerByPage() != null;
                System.debug('is logged in '+ isLoggedIn+', lightning sync: '+lightningSync);
                if (!lightningSync) {
                    if (isLoggedIn) {
                        Id playerId = getPlayerByPage();
                        currentPlayer =
                        [select Id,Name,Email__c,Password__c,IsManager__c from Player__c where Id = :playerId];
                        System.debug('current player: ' + currentPlayer);
                    }
                } else {
                    if (isLoggedIn) {
                        currentPlayer =
                        [select Id,Name,Email__c,Password__c,IsManager__c from Player__c where Id = :playerIdLightning];
                        System.debug('Current player lightning: ' + currentPlayer);
                    } else currentPlayer = null;
                }
            }catch (Exception ex) {
				System.debug('Exception');
            }

            Map<Id,Sobject> teamsOrPlayers = new Map<Id,Sobject>();
            if (currentTournament.Format__c=='1 x 1'){
                teamsOrPlayers = new Map<Id,Player__c>([select Id,Name from Player__c]);
            } else teamsOrPlayers = new Map<Id,Team__c>([select Id,Name, (select Player__c,Player__r.Name from PlayerTeams__r) from Team__c 
                                                         where Tournament__c =: currentTournament.Id]);

            if (!String.isBlank(lightningPageName) && lightningPageName.equals('Tournament')){
                lightningPageName += '?id='+currentTournament.Id;
            }


            /////////////////////////////////////////////////////////////////////

//            if (isLoggedIn){
                if (currentTournament.Format__c!='1 x 1') {
                    if (currentPlayer != null){
                    for (Team__c team: (List<Team__c>)teamsOrPlayers.Values()){
                        playerOrTeamRelatedToPlayerFromCookie =
                                        team.PlayerTeams__r.get(0).Player__c == currentPlayer.Id || team.PlayerTeams__r.get(1).Player__c == currentPlayer.Id?team.Id:null;
                        if (playerOrTeamRelatedToPlayerFromCookie!=null) break;
                    }
                } else {
                    playerOrTeamRelatedToPlayerFromCookie = null;
                }
              } else {
                    if (currentPlayer != null) {
                        playerOrTeamRelatedToPlayerFromCookie = currentPlayer.Id;
                    } else {
                        playerOrTeamRelatedToPlayerFromCookie = null;
                    }
				}
            //}

            System.debug('I am here'+teamsOrPlayers.size());

            if (currentTournament.Format__c=='2 x 2'){
                teams = (Map<Id,Team__c>) teamsOrPlayers;
            }
            for (List<Game__c> gameList: thisGames){
                List<GameJSON> gamejsList = new List<GameJSON>();
                for (Game__c g: gameList){
                    GameJSON gamejs = new GameJSON();
                    gamejs.gameId = g.Id;
                    gamejs.firstCompetitorId = g.FirstCompetitor__c;
                    gamejs.SecondCompetitorId = g.SecondCompetitor__c;


                    gamejs.firstCompetitorScore = ''+g.FirstCompetitorScore__c;
                    gamejs.secondCompetitorScore = ''+g.SecondCompetitorScore__c; //gamejs.hrefTo = 'game?id='+g.Id;
                    gamejs.firstCompetitorColor = g.FirstCompetitor__c==playerOrTeamRelatedToPlayerFromCookie?'#FF69B4':'black';
                    gamejs.secondCompetitorColor = g.SecondCompetitor__c==playerOrTeamRelatedToPlayerFromCookie?'#FF69B4':'black';
                    gamejs.winningGroup = g.WinningGroup__c; gamejs.stage = g.Stage__c.intValue();
                    gamejs.editable = gamejs.firstCompetitorId==playerOrTeamRelatedToPlayerFromCookie||gamejs.secondCompetitorId==playerOrTeamRelatedToPlayerFromCookie;
                    System.debug('FirstCompetitorId == '+gamejs.firstCompetitorId+', SecondCompetitorId == '+gamejs.secondCompetitorId+', editable '+gamejs.editable+', playerOrTeamRelatedToPlayerFromCookie: '+playerOrTeamRelatedToPlayerFromCookie);
                    if (gamejs.editable) gamejs.hrefTo = 'Game?id='+gamejs.gameId+'&redirectUrl='+lightningPageName;
                    else gamejs.hrefTo = '#table1';

                    if (currentTournament.Format__c=='1 x 1'){
                        if (gamejs.firstCompetitorId!='?'){
                            Player__c player = (Player__c) teamsOrPlayers.get(gamejs.firstCompetitorId);
                            gamejs.firstCompetitorName = player.Name;
                        } else gamejs.firstCompetitorName='?';
                        if (gamejs.secondCompetitorId!='?'){
                            Player__c player = (Player__c) teamsOrPlayers.get(gamejs.secondCompetitorId);
                            gamejs.secondCompetitorName = player.Name;
                        } else gamejs.secondCompetitorName='?';
                    } else {
                        if (gamejs.firstCompetitorId!='?'){
                            Team__c team = (Team__c) teamsOrPlayers.get(gamejs.firstCompetitorId);
                            gamejs.firstCompetitorName = team.Name;
                        } else gamejs.firstCompetitorName='?';
                        if (gamejs.secondCompetitorId!='?'){
                            Team__c team = (Team__c) teamsOrPlayers.get(gamejs.secondCompetitorId);
                            gamejs.secondCompetitorName = team.Name;
                        } else gamejs.secondCompetitorName='?';
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
                    }
                    gamejsList.add(gamejs);
                }
                representDoubleEliminationGridJSON.add(gamejsList);
            }
            System.debug((representDoubleEliminationGridJSON.size()==thisGames.size())+',,,,,'+representDoubleEliminationGridJSON.size());
            return thisGames;
        }
        return new List<List<Game__c>>();
    }

    public static void generateRounds(List<String> competitorsIds, String tournamentId) {
        Double size = competitorsIds.size();
        System.debug('size: '+size);
        Double lvl = Math.floor(Math.log(size)/Math.log(2));
        System.debug('lvl: '+lvl);
        Double newSize = Math.pow(2, lvl);
        System.debug('newSize: '+newSize);
        Double diff = size - newSize;
        System.debug('diff: '+diff);

        List<Double> winners = new List<Double>();
        List<Double> losers = new List<Double>();

        if (diff > 0) {
            winners.add(diff);
            losers.add(diff/2.0);
        }

        Double numCurGames = newSize/2;

        if (numCurGames < 1) {
            // finish tournament
            Tournament__c t = [SELECT Id, Status__c FROM Tournament__c WHERE Id =:tournamentId];
            TournamentController.finish(t);
            return;
        }

        while(numCurGames >= 1) {
            winners.add(numCurGames);
            losers.add(numCurGames/2.0);
            numCurGames = numCurGames/2.0;
        }

        System.debug('winners: ' + winners);
        System.debug('losers: ' + losers);

        for(integer i = 0; i < losers.size(); i++) {
            if(Math.ceil(losers[i]) != Math.floor(losers[i]) && losers[i] >= 0.5) {
                if(i != losers.size()-1) {
                    losers[i+1] = losers[i+1] + 0.5;
                } else {
                    if (losers[i] > 0.5) {
                        losers.add(0.5);
                    }
                }
                losers[i] = Math.floor(losers[i]);
            }
            if(i != losers.size()-1) {
                losers[i+1] = losers[i+1] + losers[i]/2;
            } else {
                if (losers[i] > 1) {
                    losers.add(losers[i]/2);
                }
            }
        }

        System.debug('losers: ' + losers);
        List<Game__c> otherGames = new List<Game__c>();

        for(integer i = 0; i < winners.size(); i++) {
            double currentStageGames = winners[i];
            for(integer j = 0; j < currentStageGames; j++) {
                Game__c game = new Game__c(FirstCompetitor__c = '?', SecondCompetitor__c = '?', FirstCompetitorScore__c = 0,
                        SecondCompetitorScore__c = 0, Stage__c = i, Tournament__c = tournamentId);
                otherGames.add(game);
            }
        }

        for(integer i = 0; i < losers.size(); i++) {
            double currentStageGames = losers[i];
            for(integer j = 0; j < currentStageGames; j++) {
                Game__c game = new Game__c(FirstCompetitor__c = '?', SecondCompetitor__c = '?', FirstCompetitorScore__c = 0,
                        SecondCompetitorScore__c = 0, Stage__c = i, Tournament__c = tournamentId, WinningGroup__c = false);
                otherGames.add(game);
            }
        }

        System.debug('otherGames: '+otherGames);

        try {
            insert(otherGames);
        } catch(System.DmlException e) {
            System.debug(e);
        }

        List<Game__c> gamesToUpdate = [Select Name, WinningGroup__c, FirstCompetitor__c, SecondCompetitor__c, FirstCompetitorScore__c,
                SecondCompetitorScore__c, Stage__c, Tournament__c, Type__c
                From Game__c Where Tournament__C = :tournamentId AND WinningGroup__c = true ORDER BY Stage__c ASC LIMIT :(competitorsIds.size()/2 + 1)];
        integer cnt = 0;
        for (Game__c g : gamesToUpdate) {
            g.FirstCompetitor__c = cnt >= competitorsIds.size() ? '?' : competitorsIds[cnt];
            g.SecondCompetitor__c = (cnt + 1) >= competitorsIds.size() ? '?' : competitorsIds[cnt + 1];
            cnt = cnt + 2;
        }

        System.debug('gamesToUpdate: '+gamesToUpdate);

        try {
            update(gamesToUpdate);
        } catch(System.DmlException e) {
            System.debug(e);
        }

        gamesToUpdate = [Select Name, WinningGroup__c, FirstCompetitor__c, SecondCompetitor__c, FirstCompetitorScore__c,
                SecondCompetitorScore__c, Stage__c, Tournament__c, Type__c
                From Game__c Where Tournament__C = :tournamentId AND WinningGroup__c = true ORDER BY Stage__c DESC LIMIT :1];
        if (gamesToUpdate.size() > 0) {
            gamesToUpdate[0].Type__c = 'Final';
            try {
                update(gamesToUpdate[0]);
            } catch(System.DmlException e) {
                System.debug(e);
            }

            Game__c superFinal = new Game__c(FirstCompetitor__c = '?', SecondCompetitor__c = '?', FirstCompetitorScore__c = 0,
                    SecondCompetitorScore__c = 0, Stage__c = (gamesToUpdate[0].Stage__c + 1.0), Tournament__c = gamesToUpdate[0].Tournament__c,
                    Type__c = 'Super Final');
            Game__c superFinal2 = new Game__c(FirstCompetitor__c = '?', SecondCompetitor__c = '?', FirstCompetitorScore__c = 0,
                    SecondCompetitorScore__c = 0, Stage__c = (gamesToUpdate[0].Stage__c + 2.0), Tournament__c = gamesToUpdate[0].Tournament__c,
                    Type__c = 'Super Final 2');
            try {
                insert (superFinal);
                insert (superFinal2);
            } catch (System.DmlException e) {
                System.debug(e);
            }
        }

        gamesToUpdate = [Select Name, WinningGroup__c, FirstCompetitor__c, SecondCompetitor__c, FirstCompetitorScore__c,
                SecondCompetitorScore__c, Stage__c, Tournament__c, Type__c
                From Game__c Where Tournament__C = :tournamentId AND WinningGroup__c = false ORDER BY Stage__c DESC LIMIT :1];
        if (gamesToUpdate.size() > 0) {
            gamesToUpdate[0].Type__c = 'Final';
            try {
                update(gamesToUpdate[0]);
            } catch(System.DmlException e) {
                System.debug(e);
            }
        }
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