public with sharing class GameController extends PlayerCookie{
    public boolean isHoverSubmittButton {get;set;}
    public boolean isExistInCurrentGame {get;set;} 
    public Game__c currentGame {get; set;}
    public Tournament__c tournament {get;set;}
    public PlayerTeam__c playersFromTeam {
        get{
            if(playersFromTeam == null) return new PlayerTeam__c();
            return playersFromTeam;
        }
        set;
    }
    public String FirstCompetitor{get;set;}
    public String SecondCompetitor{get;set;} 
    public boolean isHoverCommandButton {get;set;}
    public String redirectUrl {get;set;}

    public GameController(){
        List<Game__c> currentGames  = [Select FirstCompetitor__c, FirstCompetitorScore__c, FirstCompetitorAccept__c,
                                       SecondCompetitor__c, SecondCompetitorScore__c, SecondCompetitorAccept__c,
                                       Tournament__c
                                       From Game__c 
                                       Where id =:ApexPages.currentPage().getParameters().get('id')
                                       limit 1];
        redirectUrl = ApexPages.currentPage().getParameters().get('redirectUrl');
        if (redirectUrl==null) redirectUrl = 'Home';
        if(currentGames.size() == 0 || currentPlayer ==null) return;
        currentGame = currentGames.get(0);
        
        tournament = [Select id,Name,Format__c,Type__c
                      from tournament__c 
                      where id = :currentGame.Tournament__c];
        
        if(currentGame.FirstCompetitor__c == '?' || currentGame.SecondCompetitor__c == '?') return;
        if((currentGame.FirstCompetitorAccept__c || currentGame.SecondCompetitorAccept__c)) isHoverCommandButton = true;
        if((tournament.Format__c == '1 x 1')&&
            ((currentPlayer.id == currentGame.FirstCompetitor__c)||(currentPlayer.id == currentGame.SecondCompetitor__c))&&
            (!currentGame.FirstCompetitorAccept__c||!currentGame.SecondCompetitorAccept__c)){
                isExistInCurrentGame = true;
        } else if(tournament.Format__c == '2 x 2' && (!currentGame.FirstCompetitorAccept__c||!currentGame.SecondCompetitorAccept__c)){
            List<PlayerTeam__c> thisPlayerTeam = new List<PlayerTeam__c>();
            thisPlayerTeam = [Select Player__c,Team__c 
                              from PlayerTeam__c 
                              where (Player__c =:currentPlayer.id and (Team__c = :currentGame.FirstCompetitor__c OR Team__c = :currentGame.SecondCompetitor__c)) limit 1];    
           if(thisPlayerTeam.size()>0){
                playersFromTeam = thisPlayerTeam.get(0);
                    if((playersFromTeam.Team__c == currentGame.FirstCompetitor__c || playersFromTeam.Team__c == currentGame.SecondCompetitor__c))
                        isExistInCurrentGame = true;
            }
        }
       String player = getTeamOrPlayer();
       if(((player == currentGame.FirstCompetitor__c) && currentGame.FirstCompetitorAccept__c)||((player == currentGame.SecondCompetitor__c) && currentGame.SecondCompetitorAccept__c)) {
            isHoverSubmittButton = true;
       }
       FirstCompetitor = getNameById(currentGame.FirstCompetitor__c);
       SecondCompetitor = getNameById(currentGame.SecondCompetitor__c);
    }

    public PageReference insertScore(){
        String player = getTeamOrPlayer();
        String idPlayer;
        if(player == currentGame.FirstCompetitor__c){
          currentGame.FirstCompetitorAccept__c = true;  
          currentGame.SecondCompetitorAccept__c = false;
            idPlayer = currentGame.SecondCompetitor__c;
        } else {
           currentGame.FirstCompetitorAccept__c = false;
           currentGame.SecondCompetitorAccept__c = true;
            idPlayer = currentGame.FirstCompetitor__c;
        }
        if(((currentGame.FirstCompetitorScore__c > currentGame.SecondCompetitorScore__c)||(currentGame.FirstCompetitorScore__c < currentGame.SecondCompetitorScore__c))&&
        ((currentGame.FirstCompetitorScore__c >= 0)&&(currentGame.SecondCompetitorScore__c >= 0))&&
        (currentGame.FirstCompetitorScore__c !=currentGame.SecondCompetitorScore__c)){
            update currentGame;
            //sendMassageWithAutoSubmitLink(currentGame.id,idPlayer,currentGame.FirstCompetitorScore__c,currentGame.SecondCompetitorScore__c,[SELECT Email__c from Player__c where id=:idPlayer][0].Email__c);
            sendNotifications(player,currentGame.Id);
        }
        else {
            ApexPages.addMessage(
                    new ApexPages.message(ApexPages.severity.FATAL, 'Wrong score. Pelase input correct score!'));
            return null;
        }
        return redirectPage();
    }

    /*@future (callout=true)
    public static void sendMassageWithAutoSubmitLink(ID game,Id playerToEncode,Decimal fcs,Decimal scs,String to){
        String link = playerToEncode;
        Blob encrypted = Crypto.encryptWithManagedIV('AES128', Blob.valueOf('0000000000000001') , Blob.valueOf(link));
        MailSender.sendEmailJSON(to,'Fast Submit', 'You' + fcs+':'+scs + 'link: https://techmagic-table-tennis-developer-edition.eu11.force.com/Game?id='+game +'&Code='+ EncodingUtil.convertToHex(encrypted));
    }*/

    public PageReference getInfoFromUrl() {
        if (ApexPages.currentPage().getParameters().containsKey('Code')) {
            Blob fromHex = EncodingUtil.convertFromHex(ApexPages.currentPage().getParameters().get('Code'));
            Blob decryptedData = Crypto.decryptWithManagedIV('AES128', Blob.valueOf('0000000000000001'), fromHex);
            String dryptData = decryptedData.toString();
            System.debug(dryptData);
            if (currentPlayer == null) {
                Player__c player =
                [select Id,Name,Email__c,Password__c,IsManager__c from Player__c where Id=:dryptData];
                if (player != null) {
                    Cookie playerFromCookie = new Cookie('PlayerFromCookie', player.Id, null, 7 * 86400, false);
                    ApexPages.currentPage().setCookies(new Cookie[]{playerFromCookie});
                    currentPlayer = player;
                    PageReference pageRef = ApexPages.currentPage();
                    //new PageReference('/Game?id='+ApexPages.currentPage().getParameters().get('id')+'&Code'+ApexPages.currentPage().getParameters().get('Code'));
                    pageRef.setRedirect(true);
                    return pageRef;
                } else {
                    return null;
                }
            }
            if (currentPlayer != null) {
                if (tournament.Format__c == '1 x 1') {
                    if ((currentPlayer.Id == currentGame.FirstCompetitor__c && currentGame.SecondCompetitorAccept__c && !currentGame.FirstCompetitorAccept__c) ||
                            (currentPlayer.Id == currentGame.SecondCompetitor__c &&
                                    currentGame.FirstCompetitorAccept__c && !currentGame.SecondCompetitorAccept__c)) {
                        currentGame.FirstCompetitorAccept__c = true;
                        currentGame.SecondCompetitorAccept__c = true;
                        update currentGame;
                        PageReference pageRef =
                                new PageReference('/Tournament?tournamentId=' + currentGame.Tournament__c);
                        pageRef.setRedirect(true);
                        return pageRef;
                    }
                } else {
                    Boolean updateGame = false;
                    Map<Id,Team__c> teams = new Map<Id,Team__c>(
                            [select Id, (select Player__c from PlayerTeams__r) from Team__c where Tournament__c=:currentGame.Tournament__c]
                    );
                    if (!currentGame.FirstCompetitorAccept__c && currentGame.SecondCompetitorAccept__c) {
                        if (currentPlayer.Id ==
                                teams.get(currentGame.FirstCompetitor__c).PlayerTeams__r.get(0).Player__c ||
                                        currentPlayer.Id ==
                                        teams.get(currentGame.FirstCompetitor__c).PlayerTeams__r.get(1).Player__c) {
                            updateGame = true;
                        }
                    } else if (!currentGame.SecondCompetitorAccept__c && currentGame.FirstCompetitorAccept__c) {
                        if (currentPlayer.Id ==
                                teams.get(currentGame.SecondCompetitor__c).PlayerTeams__r.get(0).Player__c ||
                                        currentPlayer.Id ==
                                        teams.get(currentGame.SecondCompetitor__c).PlayerTeams__r.get(1).Player__c) {
                            updateGame = true;
                        }
                    }
                    if (updateGame) {
                        currentGame.FirstCompetitorAccept__c = true;
                        currentGame.SecondCompetitorAccept__c = true;
                        update currentGame;
                        PageReference pageRef =
                                new PageReference('/Tournament?tournamentId=' + currentGame.Tournament__c);
                        pageRef.setRedirect(true);
                        return pageRef;
                    }  else {
                        PageReference pageRef =
                                new PageReference('/Game?id=' + currentGame.Id);
                        pageRef.setRedirect(true);
                        return pageRef;
                    }
                }
            }
        }
        return null;
    }

    @future (callout=true)
    public static void sendNotifications(String playerId, String gameId){
        Game__c currentGame = [Select FirstCompetitor__c, FirstCompetitorScore__c, FirstCompetitorAccept__c,
                SecondCompetitor__c, SecondCompetitorScore__c, SecondCompetitorAccept__c,
                Tournament__c
                From Game__c
                Where id =:gameId
                limit 1];

        Tournament__c tournament = [Select id,Format__c
                from tournament__c
                where id = :currentGame.Tournament__c];


        String link = 'https://techmagic-table-tennis-developer-edition.eu11.force.com/Game?id='+currentGame.Id;
        String message = '';
        if (playerId==currentGame.FirstCompetitor__c) {
            if (currentGame.FirstCompetitorScore__c > currentGame.SecondCompetitorScore__c) {
                message = '(you have lost)';
            } else {
                message = '(you have won)';
            }
            if (tournament.Format__c == '1 x 1') {
                String fastlink = currentGame.SecondCompetitor__c;
                Blob encrypted =
                        Crypto.encryptWithManagedIV('AES128', Blob.valueOf('0000000000000001'), Blob.valueOf(fastlink));
                String email =
                        [select Email__c from Player__c WHERE Id =: currentGame.SecondCompetitor__c limit 1].Email__c;

                String subject = 'Reminder to submit result of the game';
                String htmlText = 'You have to submit score that was inserted by your competitor: (' +
                        currentGame.FirstCompetitorScore__c + ':' + currentGame.SecondCompetitorScore__c + message +
                        ')' +
                        '.Here is the link of this game:   ' +
                +link + ', and link to fast submit results: ' +
                        'https://techmagic-table-tennis-developer-edition.eu11.force.com/Game?id=' + currentGame.Id +
                        '&Code=' + EncodingUtil.convertToHex(encrypted);
                MailSender.sendEmailJSON(HerokuToken.JSONFormatEmails(email, subject,
                        HtmlBodies.htmlBodyToSubmitScoreOfTheGame(link,
                                        'https://techmagic-table-tennis-developer-edition.eu11.force.com/Game?id=' +
                                        currentGame.Id + '&Code=' + EncodingUtil.convertToHex(encrypted), message,
                                currentGame.FirstCompetitorScore__c, currentGame.SecondCompetitorScore__c)));


                email = [select Email__c from Player__c WHERE Id =: currentGame.FirstCompetitor__c limit 1].Email__c;
                subject = 'Inserting score of game';
                htmlText = 'You have inserted score of the game (' + currentGame.FirstCompetitorScore__c + ':' +
                        currentGame.SecondCompetitorScore__c + ')' +
                        '.Here is the link of this game:   ' + link;
                MailSender.sendEmailJSON(HerokuToken.JSONFormatEmails(email, subject, htmlText));
            } else {
                List<Team__c> teams = [select Id, (select Player__r.Email__c from PlayerTeams__r) from Team__c where Id =: currentGame.SecondCompetitor__c or Id=:currentGame.FirstCompetitor__c];
                Set<String> emailsOfTeamThatInsertedScore = new Set<String>();
                List<String> emailsOfTeamToSubmitScore =  new List<String>();
                for (Team__c team: teams) {
                    if (team.Id == currentGame.FirstCompetitor__c){
                        for (PlayerTeam__c playerTeam: team.PlayerTeams__r){
                            emailsOfTeamThatInsertedScore.add(playerTeam.Player__r.Email__c);
                        }
                    } else {
                        for (PlayerTeam__c playerTeam: team.PlayerTeams__r){
                            emailsOfTeamToSubmitScore.add(playerTeam.Player__r.Email__c);
                        }
                    }
                }

                Blob encrypted =
                        Crypto.encryptWithManagedIV('AES128', Blob.valueOf('0000000000000001'), Blob.valueOf([select Id from Player__c where Email__c =:emailsOfTeamToSubmitScore.get(0) limit 1].Id));


                String subject = 'Reminder to submit result of the game';
                String htmlText = 'You have to submit score that was inserted by your competitor: (' +
                        currentGame.FirstCompetitorScore__c + ':' + currentGame.SecondCompetitorScore__c + message +
                        ')' +
                        '.Here is the link of this game:   ' +
                +link + ', and link to fast submit results: ' +
                        'https://techmagic-table-tennis-developer-edition.eu11.force.com/Game?id=' + currentGame.Id +
                        '&Code=' + EncodingUtil.convertToHex(encrypted);
                MailSender.sendEmailJSON(HerokuToken.JSONFormatEmails(emailsOfTeamToSubmitScore.get(0), subject,
                        HtmlBodies.htmlBodyToSubmitScoreOfTheGame(link,
                                        'https://techmagic-table-tennis-developer-edition.eu11.force.com/Game?id=' +
                                        currentGame.Id + '&Code=' + EncodingUtil.convertToHex(encrypted), message,
                                currentGame.FirstCompetitorScore__c, currentGame.SecondCompetitorScore__c)));


                encrypted =
                        Crypto.encryptWithManagedIV('AES128', Blob.valueOf('0000000000000001'), Blob.valueOf([select Id from Player__c where Email__c =:emailsOfTeamToSubmitScore.get(1) limit 1].Id));
                MailSender.sendEmailJSON(HerokuToken.JSONFormatEmails(emailsOfTeamToSubmitScore.get(1), subject,
                        HtmlBodies.htmlBodyToSubmitScoreOfTheGame(link,
                                        'https://techmagic-table-tennis-developer-edition.eu11.force.com/Game?id=' +
                                        currentGame.Id + '&Code=' + EncodingUtil.convertToHex(encrypted), message,
                                currentGame.FirstCompetitorScore__c, currentGame.SecondCompetitorScore__c)));




                subject = 'Inserting score of game';
                htmlText = 'You have inserted score of the game (' + currentGame.FirstCompetitorScore__c + ':' +
                        currentGame.SecondCompetitorScore__c + ')' +
                        '.Here is the link of this game:   ' + link;
                MailSender.sendEmailJSON(HerokuToken.JSONFormatEmails(emailsOfTeamThatInsertedScore, subject, htmlText));
            }
        }else {
            if (currentGame.SecondCompetitorScore__c>currentGame.FirstCompetitorScore__c) {
                message = '(you have lost)';
            } else {
                message = '(you have won)';
            }
            if (tournament.Format__c == '1 x 1'){
                String fastlink = currentGame.FirstCompetitor__c;
                Blob encrypted = Crypto.encryptWithManagedIV('AES128', Blob.valueOf('0000000000000001') , Blob.valueOf(fastlink));

                String email = [select Email__c from Player__c WHERE Id =: currentGame.FirstCompetitor__c limit 1].Email__c;

                String subject = 'Reminder to submit result of the game';
                String htmlText = 'You have to submit score that was inserted by your competitor: ('+currentGame.FirstCompetitorScore__c+':'+currentGame.SecondCompetitorScore__c+message+')'+
                        '.Here is the link of the game:   ' +
                +link + ', and link to fast submit results: '+  'https://techmagic-table-tennis-developer-edition.eu11.force.com/Game?id='+currentGame.Id+'&Code='+ EncodingUtil.convertToHex(encrypted);
                MailSender.sendEmailJSON(HerokuToken.JSONFormatEmails(email,subject,HtmlBodies.htmlBodyToSubmitScoreOfTheGame(link,'https://techmagic-table-tennis-developer-edition.eu11.force.com/Game?id='+currentGame.Id+'&Code='+ EncodingUtil.convertToHex(encrypted),message, currentGame.FirstCompetitorScore__c, currentGame.SecondCompetitorScore__c)));


                email = [select Email__c from Player__c WHERE Id =: currentGame.SecondCompetitor__c limit 1].Email__c;
                subject = 'Inserting score of game';
                htmlText = 'You have inserted score of the game ('+currentGame.FirstCompetitorScore__c+':'+currentGame.SecondCompetitorScore__c+')'+
                        '.Here is the link of this game:   ' + link;
                MailSender.sendEmailJSON(HerokuToken.JSONFormatEmails(email,subject,htmlText));
            } else {
                List<Team__c> teams = [select Id, (select Player__r.Email__c from PlayerTeams__r) from Team__c where Id =: currentGame.SecondCompetitor__c or Id=:currentGame.FirstCompetitor__c];
                Set<String> emailsOfTeamThatInsertedScore = new Set<String>();
                List<String> emailsOfTeamToSubmitScore =  new List<String>();
                for (Team__c team: teams) {
                    if (team.Id == currentGame.SecondCompetitor__c){
                        for (PlayerTeam__c playerTeam: team.PlayerTeams__r){
                            emailsOfTeamThatInsertedScore.add(playerTeam.Player__r.Email__c);
                        }
                    } else {
                        for (PlayerTeam__c playerTeam: team.PlayerTeams__r){
                            emailsOfTeamToSubmitScore.add(playerTeam.Player__r.Email__c);
                        }
                    }
                }

                Blob encrypted =
                        Crypto.encryptWithManagedIV('AES128', Blob.valueOf('0000000000000001'), Blob.valueOf([select Id from Player__c where Email__c=:emailsOfTeamToSubmitScore.get(0) limit 1].Id));

                String subject = 'Reminder to submit result of the game';
                String htmlText = 'You have to submit score that was inserted by your competitor: (' +
                        currentGame.FirstCompetitorScore__c + ':' + currentGame.SecondCompetitorScore__c + message +
                        ')' +
                        '.Here is the link of this game:   ' +
                +link + ', and link to fast submit results: ' +
                        'https://techmagic-table-tennis-developer-edition.eu11.force.com/Game?id=' + currentGame.Id +
                        '&Code=' + EncodingUtil.convertToHex(encrypted);
                MailSender.sendEmailJSON(HerokuToken.JSONFormatEmails(emailsOfTeamToSubmitScore.get(0), subject,
                        HtmlBodies.htmlBodyToSubmitScoreOfTheGame(link,
                                        'https://techmagic-table-tennis-developer-edition.eu11.force.com/Game?id=' +
                                        currentGame.Id + '&Code=' + EncodingUtil.convertToHex(encrypted), message,
                                currentGame.FirstCompetitorScore__c, currentGame.SecondCompetitorScore__c)));

                encrypted =
                        Crypto.encryptWithManagedIV('AES128', Blob.valueOf('0000000000000001'), Blob.valueOf([select Id from Player__c where Email__c=:emailsOfTeamToSubmitScore.get(1) limit 1].Id));
                MailSender.sendEmailJSON(HerokuToken.JSONFormatEmails(emailsOfTeamToSubmitScore.get(1), subject,
                        HtmlBodies.htmlBodyToSubmitScoreOfTheGame(link,
                                        'https://techmagic-table-tennis-developer-edition.eu11.force.com/Game?id=' +
                                        currentGame.Id + '&Code=' + EncodingUtil.convertToHex(encrypted), message,
                                currentGame.FirstCompetitorScore__c, currentGame.SecondCompetitorScore__c)));


                subject = 'Inserting score of game';
                htmlText = 'You have inserted score of the game (' + currentGame.FirstCompetitorScore__c + ':' +
                        currentGame.SecondCompetitorScore__c + ')' +
                        '.Here is the link of this game:   ' + link;
                MailSender.sendEmailJSON(HerokuToken.JSONFormatEmails(emailsOfTeamThatInsertedScore, subject, htmlText));
            }
        }
    }

    public PageReference redirectPage(){
        PageReference pageRef = new PageReference('/'+redirectUrl);
        pageRef.setRedirect(true);
        return pageRef;
    }
    
    
    public PageReference submitScore(){
        String player = getTeamOrPlayer();
        Game__c previousGame = [select Id,FirstCompetitorScore__c,SecondCompetitorScore__c from Game__c where Id=:currentGame.Id limit 1];
        if(currentGame.FirstCompetitorAccept__c && player == currentGame.SecondCompetitor__c){
                currentGame.SecondCompetitorAccept__c = true; 
            }else if(currentGame.SecondCompetitorAccept__c && player == currentGame.FirstCompetitor__c){
                currentGame.FirstCompetitorAccept__c = true;
            }
        if ((previousGame.FirstCompetitorScore__c==currentGame.FirstCompetitorScore__c && 
            previousGame.SecondCompetitorScore__c == currentGame.SecondCompetitorScore__c)){
            update currentGame;
        } else {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.FATAL,'Submit button is only to submit existing score. To change result of current game, please click InputScore button'));
            return null;
        }
        
        
        return redirectPage();
    }
    
    private String getTeamOrPlayer(){
        String player;
        if(tournament.Format__c == '1 x 1'){
            player = currentPlayer.id;
            return player;
        }
        else {
            player = playersFromTeam.Team__c;
            return player;
        }
    }
    
    public String getNameById(String id){
        Map<String,String> newMap = Helper.getIdAndNameMap(tournament);
        return newMap.get(id);
    }
    public PageReference changeStatic(){
        isHoverCommandButton = false;
        currentGame.FirstCompetitorAccept__c = false;  
        currentGame.SecondCompetitorAccept__c = false; 
        return null;
    }
}