public with sharing class AfterUpdateGameTriggerHelper {
    public static void generateGamesOrFinishTournament(List<Game__c> oldGames, List<Game__c> newGames) {
        for (integer i = 0; i < newGames.size(); i++) {
            if (!(oldGames[i].FirstCompetitorAccept__c && oldGames[i].SecondCompetitorAccept__c) &&
                    newGames[i].FirstCompetitorAccept__c && newGames[i].SecondCompetitorAccept__c) {
                // update player statistics
                genGamesOrFinTour(newGames[i]);
            }
        }
    }


    private static void genGamesOrFinTour(Game__c game) {
        List<Tournament__c> ts =
        [SELECT Id, Type__c, Status__c, Format__c FROM Tournament__c WHERE Id = :game.Tournament__c];
        if (ts.size() > 0) {
            Tournament__c t = ts[0];
            // update player statistics
            if (t.Format__c == '1 x 1') {
                List<PlayerStatistics__c> pSs =
                [SELECT Id, Player__c, CountLostGames__c, CountWonGames__c, CountLostSets__c, CountWonSets__c
                        FROM PlayerStatistics__c WHERE Tournament__c = :t.Id AND (Player__c = :game.FirstCompetitor__c OR Player__c = :game.SecondCompetitor__c)];
                if (pSs.size() > 1) {
                    PlayerStatistics__c pS0 = pSs[0];
                    PlayerStatistics__c pS1 = pSs[1];
                    if (pS0.Player__c == game.FirstCompetitor__c) {
                        pS0.CountLostGames__c = game.FirstCompetitorScore__c < game.SecondCompetitorScore__c ?
                                                pS0.CountLostGames__c + 1 : pS0.CountLostGames__c;
                        pS0.CountWonGames__c = game.FirstCompetitorScore__c > game.SecondCompetitorScore__c ?
                                               pS0.CountWonGames__c + 1 : pS0.CountWonGames__c;
                        pS0.CountLostSets__c = pS0.CountLostSets__c + game.SecondCompetitorScore__c;
                        pS0.CountWonSets__c = pS0.CountWonSets__c + game.FirstCompetitorScore__c;

                        pS1.CountLostGames__c = game.FirstCompetitorScore__c > game.SecondCompetitorScore__c ?
                                                pS1.CountLostGames__c + 1 : pS1.CountLostGames__c;
                        pS1.CountWonGames__c = game.FirstCompetitorScore__c < game.SecondCompetitorScore__c ?
                                               pS1.CountWonGames__c + 1 : pS1.CountWonGames__c;
                        pS1.CountLostSets__c = pS1.CountLostSets__c + game.FirstCompetitorScore__c;
                        pS1.CountWonSets__c = pS1.CountWonSets__c + game.SecondCompetitorScore__c;
                    } else {
                        pS1.CountLostGames__c = game.FirstCompetitorScore__c < game.SecondCompetitorScore__c ?
                                                pS1.CountLostGames__c + 1 : pS1.CountLostGames__c;
                        pS1.CountWonGames__c = game.FirstCompetitorScore__c > game.SecondCompetitorScore__c ?
                                               pS1.CountWonGames__c + 1 : pS1.CountWonGames__c;
                        pS1.CountLostSets__c = pS1.CountLostSets__c + game.SecondCompetitorScore__c;
                        pS1.CountWonSets__c = pS1.CountWonSets__c + game.FirstCompetitorScore__c;

                        pS0.CountLostGames__c = game.FirstCompetitorScore__c > game.SecondCompetitorScore__c ?
                                                pS0.CountLostGames__c + 1 : pS0.CountLostGames__c;
                        pS0.CountWonGames__c = game.FirstCompetitorScore__c < game.SecondCompetitorScore__c ?
                                               pS0.CountWonGames__c + 1 : pS0.CountWonGames__c;
                        pS0.CountLostSets__c = pS0.CountLostSets__c + game.FirstCompetitorScore__c;
                        pS0.CountWonSets__c = pS0.CountWonSets__c + game.SecondCompetitorScore__c;
                    }
                    update (pS0);
                    update (pS1);
                }
            } else {
                List<Team__c> pSteams =
                [SELECT Id, (SELECT Player__c FROM PlayerTeams__r) FROM Team__c WHERE Tournament__c = :t.Id AND (Id = :game.FirstCompetitor__c OR Id = :game.SecondCompetitor__c)];
                if (pSteams.size() > 1) {
                    Team__c t111 = pSteams[0];
                    Team__c t222 = pSteams[1];
                    List<PlayerTeam__c> pts111 = t111.PlayerTeams__r;
                    List<PlayerTeam__c> pts222 = t222.PlayerTeams__r;
                    PlayerStatistics__c pS0 =
                    [SELECT Id, Player__c, CountLostGames__c, CountWonGames__c, CountLostSets__c, CountWonSets__c
                            FROM PlayerStatistics__c WHERE Tournament__c = :t.Id AND Player__c = :pts111[0].Player__c];
                    PlayerStatistics__c pS1 =
                    [SELECT Id, Player__c, CountLostGames__c, CountWonGames__c, CountLostSets__c, CountWonSets__c
                            FROM PlayerStatistics__c WHERE Tournament__c = :t.Id AND Player__c = :pts111[1].Player__c];
                    PlayerStatistics__c pS2 =
                    [SELECT Id, Player__c, CountLostGames__c, CountWonGames__c, CountLostSets__c, CountWonSets__c
                            FROM PlayerStatistics__c WHERE Tournament__c = :t.Id AND Player__c = :pts222[0].Player__c];
                    PlayerStatistics__c pS3 =
                    [SELECT Id, Player__c, CountLostGames__c, CountWonGames__c, CountLostSets__c, CountWonSets__c
                            FROM PlayerStatistics__c WHERE Tournament__c = :t.Id AND Player__c = :pts222[1].Player__c];
                    if (t111.Id == game.FirstCompetitor__c) {
                        pS0.CountLostGames__c = game.FirstCompetitorScore__c < game.SecondCompetitorScore__c ?
                                                pS0.CountLostGames__c + 1 : pS0.CountLostGames__c;
                        pS0.CountWonGames__c = game.FirstCompetitorScore__c > game.SecondCompetitorScore__c ?
                                               pS0.CountWonGames__c + 1 : pS0.CountWonGames__c;
                        pS0.CountLostSets__c = pS0.CountLostSets__c + game.SecondCompetitorScore__c;
                        pS0.CountWonSets__c = pS0.CountWonSets__c + game.FirstCompetitorScore__c;
                        pS1.CountLostGames__c = game.FirstCompetitorScore__c < game.SecondCompetitorScore__c ?
                                                pS1.CountLostGames__c + 1 : pS1.CountLostGames__c;
                        pS1.CountWonGames__c = game.FirstCompetitorScore__c > game.SecondCompetitorScore__c ?
                                               pS1.CountWonGames__c + 1 : pS1.CountWonGames__c;
                        pS1.CountLostSets__c = pS1.CountLostSets__c + game.SecondCompetitorScore__c;
                        pS1.CountWonSets__c = pS1.CountWonSets__c + game.FirstCompetitorScore__c;

                        pS2.CountLostGames__c = game.FirstCompetitorScore__c > game.SecondCompetitorScore__c ?
                                                pS2.CountLostGames__c + 1 : pS2.CountLostGames__c;
                        pS2.CountWonGames__c = game.FirstCompetitorScore__c < game.SecondCompetitorScore__c ?
                                               pS2.CountWonGames__c + 1 : pS2.CountWonGames__c;
                        pS2.CountLostSets__c = pS2.CountLostSets__c + game.FirstCompetitorScore__c;
                        pS2.CountWonSets__c = pS2.CountWonSets__c + game.SecondCompetitorScore__c;
                        pS3.CountLostGames__c = game.FirstCompetitorScore__c > game.SecondCompetitorScore__c ?
                                                pS3.CountLostGames__c + 1 : pS3.CountLostGames__c;
                        pS3.CountWonGames__c = game.FirstCompetitorScore__c < game.SecondCompetitorScore__c ?
                                               pS3.CountWonGames__c + 1 : pS3.CountWonGames__c;
                        pS3.CountLostSets__c = pS3.CountLostSets__c + game.FirstCompetitorScore__c;
                        pS3.CountWonSets__c = pS3.CountWonSets__c + game.SecondCompetitorScore__c;
                    } else {
                        pS2.CountLostGames__c = game.FirstCompetitorScore__c < game.SecondCompetitorScore__c ?
                                                pS2.CountLostGames__c + 1 : pS2.CountLostGames__c;
                        pS2.CountWonGames__c = game.FirstCompetitorScore__c > game.SecondCompetitorScore__c ?
                                               pS2.CountWonGames__c + 1 : pS2.CountWonGames__c;
                        pS2.CountLostSets__c = pS2.CountLostSets__c + game.SecondCompetitorScore__c;
                        pS2.CountWonSets__c = pS2.CountWonSets__c + game.FirstCompetitorScore__c;
                        pS3.CountLostGames__c = game.FirstCompetitorScore__c < game.SecondCompetitorScore__c ?
                                                pS3.CountLostGames__c + 1 : pS3.CountLostGames__c;
                        pS3.CountWonGames__c = game.FirstCompetitorScore__c > game.SecondCompetitorScore__c ?
                                               pS3.CountWonGames__c + 1 : pS3.CountWonGames__c;
                        pS3.CountLostSets__c = pS3.CountLostSets__c + game.SecondCompetitorScore__c;
                        pS3.CountWonSets__c = pS3.CountWonSets__c + game.FirstCompetitorScore__c;

                        pS0.CountLostGames__c = game.FirstCompetitorScore__c > game.SecondCompetitorScore__c ?
                                                pS0.CountLostGames__c + 1 : pS0.CountLostGames__c;
                        pS0.CountWonGames__c = game.FirstCompetitorScore__c < game.SecondCompetitorScore__c ?
                                               pS0.CountWonGames__c + 1 : pS0.CountWonGames__c;
                        pS0.CountLostSets__c = pS0.CountLostSets__c + game.FirstCompetitorScore__c;
                        pS0.CountWonSets__c = pS0.CountWonSets__c + game.SecondCompetitorScore__c;
                        pS1.CountLostGames__c = game.FirstCompetitorScore__c > game.SecondCompetitorScore__c ?
                                                pS1.CountLostGames__c + 1 : pS1.CountLostGames__c;
                        pS1.CountWonGames__c = game.FirstCompetitorScore__c < game.SecondCompetitorScore__c ?
                                               pS1.CountWonGames__c + 1 : pS1.CountWonGames__c;
                        pS1.CountLostSets__c = pS1.CountLostSets__c + game.FirstCompetitorScore__c;
                        pS1.CountWonSets__c = pS1.CountWonSets__c + game.SecondCompetitorScore__c;
                    }
                    update (pS0);
                    update (pS1);
                    update (pS2);
                    update (pS3);
                }
            }
            if (t.Type__c == 'Round Robin') {
                List<Game__c> games =
                [SELECT Id, FirstCompetitorAccept__c, SecondCompetitorAccept__c FROM Game__c WHERE Tournament__c = :t.Id];
                if (checkOneAccept(games)) {
                    TournamentController.finish(t);
                }
            } else if (t.Type__c == 'Single Elimination') {
                List<Game__c> games =
                [SELECT Id, FirstCompetitor__c, SecondCompetitor__c, FirstCompetitorAccept__c, SecondCompetitorAccept__c, FirstCompetitorScore__c, SecondCompetitorScore__c, Tournament__c, Stage__c, Type__c
                        FROM Game__c WHERE Tournament__c = :t.Id AND Stage__c = :game.Stage__c];
                boolean areFinal = true;
                for (Game__c g : games) {
                    areFinal = areFinal && g.Type__c == 'Final';
                    if (!areFinal) break;
                }
                if (checkOneAccept(games)) {
                    if (areFinal) {
                        TournamentController.finish(t);
                    } else {
                        SingleEliminationTournament.createNextSingleEliminationStage(games, t);
                    }
                }
            } else if (t.Type__c == 'Double Elimination') {
                if (game.Type__c == 'Final') {
                    List<Game__c> nextWinningGames =
                    [SELECT Id, FirstCompetitor__c, SecondCompetitor__c, Tournament__c, Stage__c
                            FROM Game__c WHERE Tournament__c = :t.Id AND WinningGroup__c = true AND Type__c = 'Super Final' LIMIT 1];
                    Game__c superFinal = nextWinningGames[0];
                    if (game.WinningGroup__c == true) {
                        List<Game__c> notSuperFinalGames =
                        [SELECT Id, FirstCompetitor__c, SecondCompetitor__c, Tournament__c, Stage__c
                                FROM Game__c WHERE Tournament__c = :t.Id AND WinningGroup__c = true AND Type__c != 'Super Final'];
                        if (notSuperFinalGames.size() == 1) {
                            superFinal.SecondCompetitor__c = game.FirstCompetitorScore__c <
                                                             game.SecondCompetitorScore__c ? game.FirstCompetitor__c : game.SecondCompetitor__c;
                        }
                        superFinal.FirstCompetitor__c = game.FirstCompetitorScore__c >
                                                        game.SecondCompetitorScore__c ? game.FirstCompetitor__c : game.SecondCompetitor__c;
                        List<Game__c> nextLosingGames =
                        [SELECT Id, FirstCompetitor__c, SecondCompetitor__c, Tournament__c, Stage__c
                                FROM Game__c WHERE Tournament__c = :t.Id AND WinningGroup__c = false AND (FirstCompetitor__c = '?' OR SecondCompetitor__c = '?') AND Stage__c = :game.Stage__c];
                        Integer cnt = 0;
                        for (Game__c g : nextLosingGames) {
                            if (g.FirstCompetitor__c == '?') cnt++;
                            if (g.SecondCompetitor__c == '?') cnt++;
                        }
                        //
                        List<Game__c> stageBeforeLosingGames =
                        [SELECT Id, FirstCompetitor__c, SecondCompetitor__c, Tournament__c, Stage__c
                                FROM Game__c WHERE Tournament__c = :t.Id AND WinningGroup__c = false AND (FirstCompetitorAccept__c = false OR SecondCompetitorAccept__c = false) AND Stage__c = :(game.Stage__c-1)];
                        if (nextLosingGames.size() > 0 && cnt > stageBeforeLosingGames.size()) {
                            if (nextLosingGames[0].FirstCompetitor__c == '?') {
                                nextLosingGames[0].FirstCompetitor__c = game.FirstCompetitorScore__c <
                                                                        game.SecondCompetitorScore__c ? game.FirstCompetitor__c : game.SecondCompetitor__c;
                            } else {
                                nextLosingGames[0].SecondCompetitor__c = game.FirstCompetitorScore__c <
                                                                         game.SecondCompetitorScore__c ? game.FirstCompetitor__c : game.SecondCompetitor__c;
                            }
                            try {
                                update (nextLosingGames[0]);
                            } catch (System.DmlException e) {
                                System.debug(e);
                            }
                        } else {
                            nextLosingGames =
                            [SELECT Id, FirstCompetitor__c, SecondCompetitor__c, Tournament__c, Stage__c
                                    FROM Game__c WHERE Tournament__c = :t.Id AND WinningGroup__c = false AND (FirstCompetitor__c = '?' OR SecondCompetitor__c = '?') AND Stage__c = :(game.Stage__c+1) LIMIT 1];
                            if (nextLosingGames.size() > 0) {
                                if (nextLosingGames[0].FirstCompetitor__c == '?') {
                                    nextLosingGames[0].FirstCompetitor__c = game.FirstCompetitorScore__c <
                                                                            game.SecondCompetitorScore__c ? game.FirstCompetitor__c : game.SecondCompetitor__c;
                                } else {
                                    nextLosingGames[0].SecondCompetitor__c = game.FirstCompetitorScore__c <
                                                                             game.SecondCompetitorScore__c ? game.FirstCompetitor__c : game.SecondCompetitor__c;
                                }
                                try {
                                    update (nextLosingGames[0]);
                                } catch (System.DmlException e) {
                                    System.debug(e);
                                }
                            }
                        }
                    } else {
                        superFinal.SecondCompetitor__c = game.FirstCompetitorScore__c >
                                                         game.SecondCompetitorScore__c ? game.FirstCompetitor__c : game.SecondCompetitor__c;
                    }
                    try {
                        update (superFinal);
                    } catch (System.DmlException e) {
                        System.debug(e);
                    }
                } else if (game.Type__c == 'Super Final') {
                    List<Game__c> finalGames =
                    [SELECT Id, FirstCompetitor__c, SecondCompetitor__c, FirstCompetitorScore__c, SecondCompetitorScore__c, Tournament__c, Stage__c
                            FROM Game__c WHERE Tournament__c = :t.Id AND WinningGroup__c = true AND Type__c = 'Final' LIMIT 1];
                    if (finalGames.size() > 0) {
                        String finalWinnerId = finalGames[0].FirstCompetitorScore__c >
                                               finalGames[0].SecondCompetitorScore__c ? finalGames[0].FirstCompetitor__c : finalGames[0].SecondCompetitor__c;
                        String superFinalWinnerId = game.FirstCompetitorScore__c >
                                                    game.SecondCompetitorScore__c ? game.FirstCompetitor__c : game.SecondCompetitor__c;
                        if (finalWinnerId == superFinalWinnerId) {
                            delete [SELECT Id, FirstCompetitor__c, SecondCompetitor__c, FirstCompetitorScore__c, SecondCompetitorScore__c, Tournament__c, Stage__c
                                    FROM Game__c WHERE Tournament__c = :t.Id AND WinningGroup__c = true AND Type__c = 'Super Final 2' LIMIT 1];
                            TournamentController.finish(t);
                        } else {
                            Game__c secondSuperFinal = [SELECT Id, FirstCompetitor__c, SecondCompetitor__c, FirstCompetitorScore__c, SecondCompetitorScore__c, Tournament__c, Stage__c
                                    FROM Game__c WHERE Tournament__c = :t.Id AND WinningGroup__c = true AND Type__c = 'Super Final 2' LIMIT 1];
                            secondSuperFinal.FirstCompetitor__c = game.SecondCompetitor__c;
                            secondSuperFinal.SecondCompetitor__c = game.FirstCompetitor__c;
                            try {
                                update (secondSuperFinal);
                            } catch (System.DmlException e) {
                                System.debug(e);
                            }
                        }
                    }
                } else if (game.Type__c == 'Super Final 2') {
                    TournamentController.finish(t);
                } else {
                    if (game.WinningGroup__c == true) {
                        if (game.Stage__c == 0) {
                            List<Game__c> thisStageGames =
                            [SELECT Id, FirstCompetitor__c, SecondCompetitor__c, Tournament__c, Stage__c
                                    FROM Game__c WHERE Tournament__c = :t.Id AND WinningGroup__c = true AND Stage__c = 0 ORDER BY Name ASC];
                            Integer i;
                            for (i = 0; i < thisStageGames.size(); i++) {
                                if (thisStageGames.get(i).Id == game.Id) {
                                    break;
                                }
                            }
                            System.debug(i);
                            List<Game__c> nextWinningGames =
                            [SELECT Id, FirstCompetitor__c, SecondCompetitor__c, Tournament__c, Stage__c
                                    FROM Game__c WHERE Tournament__c = :t.Id AND WinningGroup__c = true AND Stage__c = 1 ORDER BY Name ASC];
                            if (Math.mod(thisStageGames.size() - i, 2) != 0) {
                                nextWinningGames.get(nextWinningGames.size() - 1 -
                                        i / 2).SecondCompetitor__c =
                                game.FirstCompetitorScore__c >
                                game.SecondCompetitorScore__c ? game.FirstCompetitor__c : game.SecondCompetitor__c;
                            } else {
                                nextWinningGames.get(nextWinningGames.size() - 1 -
                                        i / 2).FirstCompetitor__c =
                                game.FirstCompetitorScore__c >
                                game.SecondCompetitorScore__c ? game.FirstCompetitor__c : game.SecondCompetitor__c;
                            }
                            update nextWinningGames.get(nextWinningGames.size() - 1 -  i / 2);
                        } else {
                            List<Game__c> thisStageGames =
                            [SELECT Id, FirstCompetitor__c, SecondCompetitor__c, Tournament__c, Stage__c
                                    FROM Game__c WHERE Tournament__c = :t.Id AND WinningGroup__c = true AND Stage__c = :game.Stage__c ORDER BY Name ASC];
                            Integer i;
                            for (i = 0; i < thisStageGames.size(); i++) {
                                if (thisStageGames.get(i).Id == game.Id) {
                                    break;
                                }
                            }
                            List<Game__c> nextWinningGames =
                            [SELECT Id, FirstCompetitor__c, SecondCompetitor__c, Tournament__c, Stage__c
                                    FROM Game__c WHERE Tournament__c = :t.Id AND WinningGroup__c = true AND Stage__c = :(game.Stage__c + 1) ORDER BY Name ASC];
                            if (nextWinningGames.size() > 0) {
                                Game__c nextStageWinningGame = nextWinningGames.get(i / 2);
                                if (Math.mod(i, 2) == 0) {
                                    nextStageWinningGame.FirstCompetitor__c = game.FirstCompetitorScore__c >
                                                                              game.SecondCompetitorScore__c ? game.FirstCompetitor__c : game.SecondCompetitor__c;
                                } else {
                                    nextStageWinningGame.SecondCompetitor__c = game.FirstCompetitorScore__c >
                                                                               game.SecondCompetitorScore__c ? game.FirstCompetitor__c : game.SecondCompetitor__c;
                                }
                                try {
                                    update (nextStageWinningGame);
                                } catch (System.DmlException e) {
                                    System.debug(e);
                                }
                            }
                        }
                        if (game.Stage__c == 1) {
                            List<Game__c> zeroStageWinningGames =
                            [SELECT Id, FirstCompetitor__c, SecondCompetitor__c, Tournament__c, Stage__c
                                    FROM Game__c WHERE Tournament__c = :t.Id AND WinningGroup__c = true AND Stage__c = 0];
                            List<Game__c> zeroStageLosingGames =
                            [SELECT Id, FirstCompetitor__c, SecondCompetitor__c, Tournament__c, Stage__c
                                    FROM Game__c WHERE Tournament__c = :t.Id AND WinningGroup__c = false AND Stage__c = 0];
                            Game__c tmpG;
                            if (zeroStageLosingGames.size() >= zeroStageWinningGames.size()) {
                                for (Game__c g : zeroStageLosingGames) {
                                    if (g.FirstCompetitor__c == '?' || g.SecondCompetitor__c == '?') {
                                        tmpG = g;
                                        break;
                                    }
                                }
                                if (tmpG != null) {
                                    if (tmpG.FirstCompetitor__c == '?') {
                                        tmpG.FirstCompetitor__c = game.FirstCompetitorScore__c <
                                                                  game.SecondCompetitorScore__c ? game.FirstCompetitor__c : game.SecondCompetitor__c;
                                    } else {
                                        tmpG.SecondCompetitor__c = game.FirstCompetitorScore__c <
                                                                   game.SecondCompetitorScore__c ? game.FirstCompetitor__c : game.SecondCompetitor__c;
                                    }
                                }
                                update tmpG;
                            }
                            if (tmpG == null) {
                                List<Game__c> nextLosingGames =
                                [SELECT Id, FirstCompetitor__c, SecondCompetitor__c, Tournament__c, Stage__c
                                        FROM Game__c WHERE Tournament__c = :t.Id AND WinningGroup__c = false AND (FirstCompetitor__c = '?' OR SecondCompetitor__c = '?') AND Stage__c = :game.Stage__c];
                                Integer cnt = 0;
                                for (Game__c g : nextLosingGames) {
                                    if (g.FirstCompetitor__c == '?') cnt++;
                                    if (g.SecondCompetitor__c == '?') cnt++;
                                }
                                //
                                List<Game__c> stageBeforeLosingGames =
                                [SELECT Id, FirstCompetitor__c, SecondCompetitor__c, Tournament__c, Stage__c
                                        FROM Game__c WHERE Tournament__c = :t.Id AND WinningGroup__c = false AND (FirstCompetitorAccept__c = false OR SecondCompetitorAccept__c = false) AND Stage__c = :(game.Stage__c-1)];
                                if (nextLosingGames.size() > 0 && cnt > stageBeforeLosingGames.size()) {
                                    if (nextLosingGames[0].FirstCompetitor__c == '?') {
                                        nextLosingGames[0].FirstCompetitor__c = game.FirstCompetitorScore__c <
                                                                                game.SecondCompetitorScore__c ? game.FirstCompetitor__c : game.SecondCompetitor__c;
                                    } else {
                                        nextLosingGames[0].SecondCompetitor__c = game.FirstCompetitorScore__c <
                                                                                 game.SecondCompetitorScore__c ? game.FirstCompetitor__c : game.SecondCompetitor__c;
                                    }
                                    try {
                                        update (nextLosingGames[0]);
                                    } catch (System.DmlException e) {
                                        System.debug(e);
                                    }
                                } else {
                                    nextLosingGames =
                                    [SELECT Id, FirstCompetitor__c, SecondCompetitor__c, Tournament__c, Stage__c
                                            FROM Game__c WHERE Tournament__c = :t.Id AND WinningGroup__c = false AND (FirstCompetitor__c = '?' OR SecondCompetitor__c = '?') AND Stage__c = :(game.Stage__c+1) LIMIT 1];
                                    if (nextLosingGames.size() > 0) {
                                        if (nextLosingGames[0].FirstCompetitor__c == '?') {
                                            nextLosingGames[0].FirstCompetitor__c = game.FirstCompetitorScore__c <
                                                                                    game.SecondCompetitorScore__c ? game.FirstCompetitor__c : game.SecondCompetitor__c;
                                        } else {
                                            nextLosingGames[0].SecondCompetitor__c = game.FirstCompetitorScore__c <
                                                                                     game.SecondCompetitorScore__c ? game.FirstCompetitor__c : game.SecondCompetitor__c;
                                        }
                                        try {
                                            update (nextLosingGames[0]);
                                        } catch (System.DmlException e) {
                                            System.debug(e);
                                        }
                                    }
                                }
                            }
                        } else {
                            List<Game__c> nextLosingGames =
                            [SELECT Id, FirstCompetitor__c, SecondCompetitor__c, Tournament__c, Stage__c
                                    FROM Game__c WHERE Tournament__c = :t.Id AND WinningGroup__c = false AND (FirstCompetitor__c = '?' OR SecondCompetitor__c = '?') AND Stage__c = :game.Stage__c];
                            Integer cnt = 0;
                            for (Game__c g : nextLosingGames) {
                                if (g.FirstCompetitor__c == '?') cnt++;
                                if (g.SecondCompetitor__c == '?') cnt++;
                            }
                            //
                            List<Game__c> stageBeforeLosingGames =
                            [SELECT Id, FirstCompetitor__c, SecondCompetitor__c, Tournament__c, Stage__c
                                    FROM Game__c WHERE Tournament__c = :t.Id AND WinningGroup__c = false AND (FirstCompetitorAccept__c = false OR SecondCompetitorAccept__c = false) AND Stage__c = :(game.Stage__c-1)];
                            if (nextLosingGames.size() > 0 && cnt > stageBeforeLosingGames.size()) {
                                if (nextLosingGames[0].FirstCompetitor__c == '?') {
                                    nextLosingGames[0].FirstCompetitor__c = game.FirstCompetitorScore__c <
                                                                            game.SecondCompetitorScore__c ? game.FirstCompetitor__c : game.SecondCompetitor__c;
                                } else {
                                    nextLosingGames[0].SecondCompetitor__c = game.FirstCompetitorScore__c <
                                                                             game.SecondCompetitorScore__c ? game.FirstCompetitor__c : game.SecondCompetitor__c;
                                }
                                try {
                                    update (nextLosingGames[0]);
                                } catch (System.DmlException e) {
                                    System.debug(e);
                                }
                            } else {
                                nextLosingGames =
                                [SELECT Id, FirstCompetitor__c, SecondCompetitor__c, Tournament__c, Stage__c
                                        FROM Game__c WHERE Tournament__c = :t.Id AND WinningGroup__c = false AND (FirstCompetitor__c = '?' OR SecondCompetitor__c = '?') AND Stage__c = :(game.Stage__c+1) LIMIT 1];
                                if (nextLosingGames.size() > 0) {
                                    if (nextLosingGames[0].FirstCompetitor__c == '?') {
                                        nextLosingGames[0].FirstCompetitor__c = game.FirstCompetitorScore__c <
                                                                                game.SecondCompetitorScore__c ? game.FirstCompetitor__c : game.SecondCompetitor__c;
                                    } else {
                                        nextLosingGames[0].SecondCompetitor__c = game.FirstCompetitorScore__c <
                                                                                 game.SecondCompetitorScore__c ? game.FirstCompetitor__c : game.SecondCompetitor__c;
                                    }
                                    try {
                                        update (nextLosingGames[0]);
                                    } catch (System.DmlException e) {
                                        System.debug(e);
                                    }
                                }
                            }
                        }
                    } else {
                        List<Game__c> nextLosingGames =
                        [SELECT Id, FirstCompetitor__c, SecondCompetitor__c, Tournament__c, Stage__c
                                FROM Game__c WHERE Tournament__c = :t.Id AND WinningGroup__c = false AND Stage__c = :(game.Stage__c+1) AND (FirstCompetitor__c = '?' OR SecondCompetitor__c = '?') LIMIT 1];
                        if (nextLosingGames.size() > 0) {
                            if (nextLosingGames[0].FirstCompetitor__c == '?') {
                                nextLosingGames[0].FirstCompetitor__c = game.FirstCompetitorScore__c >
                                                                        game.SecondCompetitorScore__c ? game.FirstCompetitor__c : game.SecondCompetitor__c;
                            } else {
                                nextLosingGames[0].SecondCompetitor__c = game.FirstCompetitorScore__c >
                                                                         game.SecondCompetitorScore__c ? game.FirstCompetitor__c : game.SecondCompetitor__c;
                            }
                            try {
                                update (nextLosingGames[0]);
                            } catch (System.DmlException e) {
                                System.debug(e);
                            }
                        }
                    }
                }
            }
        }
    }


    private static Boolean checkOneAccept(List<Game__c> games) {
        Boolean result = true;
        for (Game__c g: games) {
            result = result && g.FirstCompetitorAccept__c && g.SecondCompetitorAccept__c;
        }
        return result;
    }

}