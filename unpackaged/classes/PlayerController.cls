public with sharing class PlayerController extends PlayerCookie{
    public List<Player__c> players {get;set;}
    public Player__c player {get{
          return player;
        }
        set;}
    public String confirmPassword {get;set;} 
    public Boolean registrationPage {get;set;} 
    public List<Tournament__c> tournamentsOfPlayer {get;set;}
    public List<Tournament__c> currentTournamentsOfPlayer {get;set;}
    public List<Game__c> gamesOfCurrentPlayerInSelectedTournament {get;set;}
    public Tournament__c currentOrCompleteTournament {get;set;}
    public String currentOrCompletedTournamentId {get;set;}
    public Document document {get;set;}
    public String imageUrl {get;set;}
    public Boolean playerCookieIsCurrentPlayer{get;set;}
    public Boolean hasCurrentTournaments {get;set;}
    public List<PlayerStatistics__c> playerStatisticList {get;set;}
    public Integer countWonGames {get;set;}
    public Integer countLostGames {get;set;}
    public Integer countWonSets {get;set;}
    public Integer countLostSets {get;set;}
    public String rating {get;set;}
    public String emailToFind {get;set;}
    public String nameTournamentForWonStatistics {get;set;}
    public List<Tournament__c> completedAndCurrentTournamentsOfPlayer {get;set;}
    public List<String> codesOfException {get;set;}
    private Blob key = Blob.valueOf('bvH'+String.valueOf(Date.today())+'cvx');
	public String message {get;set;}
    public Map<Id,String> playerImages {get;set;}
	public Player__c searchPlayer {get;set;}
    public Double ratingFrom {get;set;}
	public Double ratingTo {get;set;}

    public PlayerController(){
        playerCookieIsCurrentPlayer = false;
        try {
            findPlayer();
        } catch (Exception ex){

        }
        codesOfException = new List<String>();
		message='';
    }
    
    
    
    public PageReference registration() {
        codesOfException = new List<String>();
        try {
            Integer parseNameToInteger = Integer.valueOf(player.Name);
            codesOfException.add('Name can not be number');
        } catch (TypeException ex){}
        
        
        List<Player__c> playersWithSuchEmail = [select Email__c from Player__c where Email__c =: player.Email__c];
        if (playersWithSuchEmail.size()>0){
            codesOfException.add('Player with the same email is already exists');
        }
        
            if (player.Password__c==confirmPassword && playersWithSuchEmail.size()==0){
                try{
                        insert player;
                        System.schedule('Deleting player if status will not be Active', '0 19 * * * ? *',new DeletePlayerSchedule());
                    } catch (Exception ex){
                        System.debug('Dml exception while registration new player');
                    }
            } else {
                codesOfException.add('Passwords are not the same');
           }
        
        if (player.Password__c.length()<8){
            codesOfException.add('Password is too short!!! Length of password must be at least 8 symbols');
        }
        
        return null;
    }
    
    public PageReference sendEmail(){
        if (codesOfException.size()==0){
            System.debug('Sending email');
            try {
            String REDIRECT_URL = (''+URL.getSalesforceBaseUrl()).split('=')[1].split(']')[0]+'/ConfirmRegistration?confirmPlayer='+player.Id;
            //MailSender.sendEmail(player.Email__c,'Confirmation your account',REDIRECT_URL);
            MailSender.sendEmailJSON(HerokuToken.JSONFormatEmails(player.Email__c, 'Confirmation your account', REDIRECT_URL));
            } catch (Exception ex){
                System.debug('exception');
            }
            return Page.Home;
        } else {
                for (String code: codesOfException){
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.FATAL,code));
                }
                return null;
            }
            
        }
    
    public PageReference login(){
        List<Player__c> players = [select Id,Password__c,Status__c from Player__c where Email__c =: player.Email__c limit 1];
        if (players != null && players.size()>0){
            if (players.get(0).Password__c==player.Password__c) {
                if (players.get(0).Status__c=='Active'){
                    Cookie playerFromCookie = new Cookie('PlayerFromCookie', players.get(0).Id, null, 7*86400, false);
                    ApexPages.currentPage().setCookies(new Cookie[]{playerFromCookie});
                return Page.Home;
                } else {
                    ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'You did not confirm account, please check your email to complete registration'));
                    return null;
                  } 
            } else {
                 ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Wrong password'));
                 return null; 
              }
           } else {
             ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'No users found with the same email'));
             return null;
           }
        return Page.Home;
    }


	public PageReference emailEntered(){
		message = '';
		try {
			List<Player__c> players = [select Id from Player__c where Email__c=:emailToFind];
			if (players.size() > 0) {
				Date dt = Date.today();
				sendEmail(emailToFind, 'Reset your password','Link: '+(''+URL.getSalesforceBaseUrl()).split('=')[1].split(']')[0]+'/ForgotPassword?email='+ encryptData(emailToFind));
				//String thisUrl =
				//('' + URL.getSalesforceBaseUrl()).split('=')[1].split(']')[0] + '/ForgotPassword?email=' + emailToFind;
				//PageReference pr = new PageReference(thisUrl);
				//pr.setRedirect(true);
				//return null;
				message = 'We have sent you an email with the link to reset your password';
				return null;
			} else {
				ApexPages.addMessage(
						new ApexPages.message(ApexPages.severity.ERROR, 'No player found with such email'));
				return null;
			}
		} catch (Exception ex){
			ApexPages.addMessage(
					new ApexPages.message(ApexPages.severity.ERROR, 'No player found with such email'));
			return null;
		}
	}

	@future(callout = true)
	public static void sendEmail(String to, String subject, String body){
		MailSender.sendEmailJSON(HerokuToken.JSONFormatEmails(to, subject, body));
	}

    public PageReference resetPassword(){
        if (player!=null && player.Password__c==confirmPassword && player.Password__c.length()>=8){
            update player;
            return Page.Home;
        } else if (player!=null && player.Password__c!=confirmPassword){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Passwords are not the same'));
            return null;
        } else if (player!=null && player.Password__c.length()<8){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Passwords is too short'));
            return null;
        } else {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'No player found'));
            return null;
        }
    }

	public String encryptData(String email){
		Blob data = Blob.valueOf(email);
		Blob encryptedData = Crypto.encryptWithManagedIV('AES128', key , data);
		return EncodingUtil.convertToHex(encryptedData);
	}

	public String decryptData(String encryptedData){
		Blob data = EncodingUtil.convertFromHex(encryptedData);
		Blob decryptedData = Crypto.decryptWithManagedIV('AES128', key , data);
		return decryptedData.toString();
	}
    
    public PageReference logout(){
        Cookie playerFromCookie = new Cookie('PlayerFromCookie', '', null, 0, false);
        ApexPages.currentPage().setCookies(new Cookie[]{playerFromCookie});
        return Page.Home;
    }
    
    
    public void findAllPlayers(){
		searchPlayer = new Player__c();
        playerImages = new Map<Id,String>();
        players = [select Id,Name,Email__c,Image__c from Player__c];
        for (Player__c player: players){
            if (player.Image__c != null) {
                playerImages.put(player.Id, ''+player.Image__c);
            } else {
                playerImages.put(player.Id, 'https://cdn3.iconfinder.com/data/icons/rcons-user-action/32/boy-512.png');
            }
        }
    }

	public void findAllPlayersByParams(){
		String name = searchPlayer.Name==null?'%':'%'+searchPlayer.Name+'%';
		ratingFrom = ratingFrom == null ? -100000 : ratingFrom;
		ratingTo = ratingTo == null ? 100000 : ratingTo;
		players = [select Id,Name,Email__c,Image__c from Player__c where Name like: name and Rating__c>= :ratingFrom and Rating__c<=:ratingTo];
	}

    public void getPlayerTournaments(){
        currentTournamentsOfPlayer = new List<Tournament__c>();
        completedAndCurrentTournamentsOfPlayer = new List<Tournament__c>();
        if (player==null) return;
        
        List<Team__c> teamsOfPlayer = [select Id from Team__c where Id in (select Team__c from PlayerTeam__c where Player__c =:player.Id)];
        
        tournamentsOfPlayer = [select Id,Name,Status__c,Format__c,Type__c,StartDate__c from 
        Tournament__c where Id in (select Tournament__c from PlayerTournament__c where 
        Player__c=:player.Id)];
        
        
        List<Tournament__c> teamTournamentOfPlayer = 
        [select Id,Name,Status__c,Format__c,Type__c,StartDate__c from Tournament__c 
        where Id in (select Tournament__c from Team__c where Id in: teamsOfPlayer)];
        
        for (Tournament__c tournament: teamTournamentOfPlayer){
            tournamentsOfPlayer.add(tournament);
        }
        
        for (Tournament__c tournament: tournamentsOfPlayer){
            if (tournament.Status__c=='Current'){
                currentTournamentsOfPlayer.add(tournament);
            }
            
            if (tournament.Status__c!='Upcoming'){
                completedAndCurrentTournamentsOfPlayer.add(tournament);
            }
        }
        hasCurrentTournaments = (currentTournamentsOfPlayer != null && currentTournamentsOfPlayer.size()>0);
    }
    
    public List<SelectOption> formOptionsByTournament(List<Tournament__c> tournaments){
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','---None---'));
        for (Tournament__c tournament: tournaments){
            options.add(new SelectOption(tournament.Id,tournament.Name+' format: '+tournament.Format__c));
         }
        return options;
    }
    /*
    public List<SelectOption> getCurrentTournamentsOptions() {
 	 List<SelectOption> options = formOptionsByTournament(currentTournamentsOfPlayer);
        
         if (options.size()>0){
            currentTournamentId = options.get(0).getValue();
         }
        
 	 return options;
    }
    */
    
   
    public PageReference getCurrentOrCompletedTournament(){
        try {
            currentOrCompleteTournament = [select Id,Name,Type__c,Status__c,Format__c,StartDate__c from Tournament__c where Id=:currentOrCompletedTournamentId limit 1];
            System.debug('Current or compl tournament: '+currentOrCompleteTournament);
            PlayerStatistics__c playerStatisticsInSelectedTournament = [select Id,Tournament__c, CountWonGames__c, CountLostGames__c, CountWonSets__c, CountLostSets__c from PlayerStatistics__c where Player__c=:player.Id and Tournament__c =:currentOrCompleteTournament.Id];
                system.debug('ID of ps:'+playerStatisticsInSelectedTournament.Id+',cwg:'+playerStatisticsInSelectedTournament.CountWonGames__c);
                countWonGames = (Integer)playerStatisticsInSelectedTournament.CountWonGames__c;
                countLostGames = (Integer)playerStatisticsInSelectedTournament.CountLostGames__c;
                countWonSets=(Integer) playerStatisticsInSelectedTournament.CountWonSets__c;
                countLostSets=(Integer) playerStatisticsInSelectedTournament.CountLostSets__c;
                nameTournamentForWonStatistics = currentOrCompleteTournament.Name;
            System.debug('wongames:'+countWonGames);
            System.debug('lostgames:'+countLostGames);
            System.debug('wonsets:'+countWonSets);
            System.debug('lostsets:'+countLostSets);
            } catch (Exception ex){
                System.debug('Hello world');
                    countWonGames = 0; countLostGames = 0; countWonSets = 0; countLostSets = 0;
                        for (PlayerStatistics__c ps: playerStatisticList){
                        countWonGames+=(Integer)ps.CountWonGames__c;
                        countLostGames+=(Integer)ps.CountLostGames__c;
                        countWonSets+=(Integer) ps.CountWonSets__c;
                        countLostSets+=(Integer) ps.CountLostSets__c;
                        nameTournamentForWonStatistics = 'all tournaments';   
                 }
            }
        return null;
    }
    
    public List<SelectOption> getCompletedAndCurrentTournamentsOfPlayerOptions(){
        return formOptionsByTournament(completedAndCurrentTournamentsOfPlayer);
    }
    
    /*
    public PageReference getCurrentTournamentById(){
        if (currentTournamentId==null) return null;
        List<Tournament__c> tournaments = [select Id,Name,Status__c,Format__c,Type__c from Tournament__c where Id =: currentTournamentId limit 1];
        currentTournament = tournaments.size()>0?tournaments.get(0):null;
        return null;
    }
    
    
    public void getGamesOfCurrentTournamentForPlayer(){
        if (currentTournament==null) return;
        gamesOfCurrentPlayerInSelectedTournament = 
        [select FirstCompetitor__c, SecondCompetitor__c, FirstCompetitorScore__c, SecondCompetitorScore__c,Stage__c
        from Game__c where Tournament__c =: currentTournament.Id and (FirstCompetitor__c =: player.Id or 
        SecondCompetitor__c =: player.Id)
        ];
    }
    */
    
    
    public void findPlayer(){
        Map<String,String> apexPageParams = new Map<String,String>();
        apexPageParams.put('playerId',ApexPages.currentPage().getParameters().get('playerId'));
        apexPageParams.put('pageType',ApexPages.currentPage().getParameters().get('pageType'));
        apexPageParams.put('email',ApexPages.currentPage().getParameters().get('email'));

        
        if (apexPageParams.get('pageType')!=null){
            String pageType = apexPageParams.get('pageType');
            player = new Player__c();
            document = new Document();
        if (pageType=='registration'){
            registrationPage = true;
        } else if (pageType=='login'){
            registrationPage = false;
          }
       } else if (apexPageParams.get('playerId')!=null){
            System.debug('player');
            String idPlayer = apexPageParams.get('playerId');
            player = [select Id,Name,Email__c,Password__c,Image__c, Rating__c from Player__c where Id=:idPlayer limit 1];
            rating = ''+player.Rating__c;
            imageUrl = ''+player.Image__c;
            document = new Document();
            if (isLoggedIn){
                    playerCookieIsCurrentPlayer = currentPlayer.Id==player.Id;
            } else playerCookieIsCurrentPlayer = false;
            countWonGames = 0; countLostGames = 0;
            
            
            
            getPlayerStatisticsList();
            
            //AggregateResult[] aggregateResultTotal  = 
                //[select Tournament__c, sum(CountWonGames__c) sumCwg, sum(CountLostGames__c) sumClg from PlayerStatistics__c where Player__c='a000Y00000DqZlu' group by Tournament__c];
            
            
            getPlayerTournaments();
       } else if (apexPageParams.get('email')!=null){
            String email = apexPageParams.get('email');
			try {
				player =
				[select Id,Name,Email__c,Password__c,Image__c, Rating__c from Player__c where Email__c=:decryptData(email) limit 1];
			} catch (Exception ex){
				player = null;
			}
        }
    }
    
    public void getPlayerStatisticsList(){
        playerStatisticList = [select Tournament__c, CountWonGames__c, CountLostGames__c, CountLostSets__c, CountWonSets__c from PlayerStatistics__c where Player__c=:player.Id];
            for (PlayerStatistics__c ps: playerStatisticList){
                countWonGames+=(Integer)ps.CountWonGames__c;
                countLostGames+=(Integer)ps.CountLostGames__c;
            }
    }


    public PageReference uploadNewImage(){
        Folder folder;
        try {
            folder = [select Id,Name from Folder where name = 'Folder' limit 1];
        } catch (Exception ex){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'No folder with name Folder'));
            return null;
        }
        
        document.FolderId = folder.Id;
        document.AuthorId = UserInfo.getUserId();
        insert document;    
        player.Image__c = (''+URL.getSalesforceBaseUrl()).split('=')[1].split(']')[0]+'/servlet/servlet.FileDownload?file='+document.Id;
        update player;
        String thisUrl = (''+URL.getSalesforceBaseUrl()).split('=')[1].split(']')[0]+'/player?playerId='+player.Id;
        System.debug('this url:'+thisUrl);
        PageReference retURL = new PageReference(thisUrl);
        retURL.setRedirect(true);
        return retURL; 
    }
    
    
    public PageReference confirmRegistration(){
        String idPlayer = ApexPages.currentPage().getParameters().get('confirmPlayer');
        List<Player__c> playerConfirm = [select Id,Status__c from Player__c where Id=:idPlayer limit 1];
        if (playerConfirm.size()>0){
            playerConfirm.get(0).Status__c = 'Active';
            update playerConfirm;
        } 
        return Page.Home;
    }
    
    
    public PageReference redirectPage(){
        PageReference redirectURL = null;
        String pageType = ApexPages.currentPage().getParameters().get('pageType');
        if (pageType=='login'){
            String thisUrl = (''+URL.getSalesforceBaseUrl()).split('=')[1].split(']')[0]+'/LoginRegister?pageType=registration';
            redirectURL = new PageReference(thisUrl);
            redirectURL.setRedirect(true);
            return redirectURL;
        } else if (pageType=='registration'){
            String thisUrl = (''+URL.getSalesforceBaseUrl()).split('=')[1].split(']')[0]+'/LoginRegister?pageType=login';
            redirectURL = new PageReference(thisUrl);
            redirectURL.setRedirect(true);
            return redirectURL;
        }
        return null;
    }

    public PageReference updatePlayer(){
            //throw new DmlException();
            //ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.WARNING,'aaaaaaa'));
            //Double rat = Double.valueOf(rating);
            try {
                Double rat = Double.valueOf(rating);
                System.debug(rating);
                player.Rating__c = rat;
                update player;
            } catch (Exception ex) {

            }
            PageReference redirectUrl = null;
            String thisUrl = (''+URL.getSalesforceBaseUrl()).split('=')[1].split(']')[0]+'/player?playerId='+player.Id;
            redirectURL = new PageReference(thisUrl);
            redirectURL.setRedirect(true);
            return redirectURL;
    }

}